import { initializeApp, getApps } from "firebase/app";
import { getMessaging, getToken, onMessage } from "firebase/messaging";

const firebaseConfig = {
  apiKey: "AIzaSyDiauPNHTdfPo23sOcwHyolvX3aKvH41AA",
  authDomain: "nivetha-catering.firebaseapp.com",
  projectId: "nivetha-catering",
  storageBucket: "nivetha-catering.firebasestorage.app",
  messagingSenderId: "587544029763",
  appId: "1:587544029763:web:c563187feed892419242f6",
  measurementId: "G-0S9LQZZNTG",
};

const DEFAULT_API_BASE_URL =
  import.meta.env.VITE_API_BASE_URL ||
  "https://nivetha-fastapi-backend-dm9u.onrender.com";

const app = getApps().length > 0 ? getApps()[0] : initializeApp(firebaseConfig);
const messaging = getMessaging(app);

export async function requestOwnerNotificationToken(vapidKey) {
  if (typeof window === "undefined" || !("Notification" in window)) return null;

  const permission = await Notification.requestPermission();
  if (permission !== "granted") return null;

  const registration = await navigator.serviceWorker.register(
    "/firebase-messaging-sw.js"
  );

  const resolvedVapidKey =
    (vapidKey && vapidKey.trim()) ||
    import.meta.env.VITE_FIREBASE_VAPID_KEY ||
    undefined;

  const token = await getToken(messaging, {
    ...(resolvedVapidKey ? { vapidKey: resolvedVapidKey } : {}),
    serviceWorkerRegistration: registration,
  });

  console.log("OWNER_WEB_FCM_TOKEN:", token);
  return token;
}

export async function registerOwnerFcmTokenWithBackend(
  authToken,
  { vapidKey, apiBaseUrl = DEFAULT_API_BASE_URL } = {}
) {
  if (!authToken) return null;

  const fcmToken = await requestOwnerNotificationToken(vapidKey);
  if (!fcmToken) return null;

  const response = await fetch(
    `${apiBaseUrl}/api/v1/notifications/register-token`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${authToken}`,
      },
      body: JSON.stringify({
        fcm_token: fcmToken,
        platform: "web",
      }),
    }
  );

  if (!response.ok) {
    throw new Error(`Failed to register owner FCM token: ${response.status}`);
  }

  return fcmToken;
}

export function listenForegroundNotifications(onNotify) {
  return onMessage(messaging, (payload) => {
    onNotify?.(payload);
  });
}

export async function initOwnerNotifications({
  authToken,
  vapidKey,
  apiBaseUrl = DEFAULT_API_BASE_URL,
  onNotify,
} = {}) {
  const token = await registerOwnerFcmTokenWithBackend(authToken, {
    vapidKey,
    apiBaseUrl,
  });
  const unsubscribe = listenForegroundNotifications(onNotify);
  return { token, unsubscribe };
}