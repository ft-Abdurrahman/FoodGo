// Firebase Cloud Functions
// Deploy with: cd functions && npm install && firebase deploy --only functions
//
// These functions:
// 1. Send push notifications when order status changes
// 2. Triggered by Firestore document updates on the orders collection

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * Send FCM notification when an order's status changes.
 *
 * Triggered on any write to the orders collection.
 * Looks up the user's FCM token and sends a notification
 * with the new order status.
 */
exports.onOrderStatusChange = functions.firestore
  .document("orders/{orderId}")
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Only proceed if status actually changed
    if (beforeData.status === afterData.status) {
      return null;
    }

    const userId = afterData.userId;
    const newStatus = afterData.status;
    const orderId = afterData.orderId;

    // Get user's FCM token from their user document
    const userDoc = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    if (!userDoc.exists) {
      console.log("User not found for order notification");
      return null;
    }

    const userData = userDoc.data();
    const fcmToken = userData.fcmToken;

    if (!fcmToken) {
      console.log("No FCM token found for user");
      return null;
    }

    // Build notification based on order status
    const notificationMap = {
      confirmed: {
        title: "Order Confirmed!",
        body: `Your order #${orderId} has been confirmed by the restaurant.`,
      },
      preparing: {
        title: "Preparing Your Food",
        body: `The restaurant is preparing your order #${orderId}.`,
      },
      outForDelivery: {
        title: "Order Out for Delivery",
        body: `Your order #${orderId} is on its way!`,
      },
      delivered: {
        title: "Order Delivered",
        body: `Your order #${orderId} has been delivered. Enjoy your meal!`,
      },
      cancelled: {
        title: "Order Cancelled",
        body: `Your order #${orderId} has been cancelled.`,
      },
    };

    const notification = notificationMap[newStatus];
    if (!notification) {
      // No notification for 'placed' status (user already sees it)
      return null;
    }

    // Send the notification via FCM
    const message = {
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: {
        orderId: context.params.orderId,
        status: newStatus,
        type: "order_update",
      },
    };

    try {
      const response = await admin.messaging().send(message);
      console.log("Notification sent successfully:", response);
      return response;
    } catch (error) {
      console.error("Error sending notification:", error);
      return null;
    }
  });

/**
 * Create user document when a new user signs up.
 * This ensures a user document exists even if the app
 * doesn't explicitly create one (e.g., for admin-created users).
 */
exports.onUserCreate = functions.auth.user().onCreate(async (user) => {
  const userRef = admin.firestore().collection("users").doc(user.uid);
  const doc = await userRef.get();

  // Only create if document doesn't exist yet
  if (!doc.exists) {
    await userRef.set({
      name: user.displayName || "",
      email: user.email || "",
      phone: user.phoneNumber || "",
      profileImage: user.photoURL || null,
      role: "customer",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log("Created user document for:", user.uid);
  }
});
