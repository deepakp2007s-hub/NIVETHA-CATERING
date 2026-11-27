import { initializeApp } from "firebase/app";
import { getMessaging, getToken, onMessage } from "firebase/messaging";

const firebaseConfig = {
  apiKey: "AIzaSyDiauPNHTdfPo23sOcwHyolvX3aKvH41AA",
  authDomain: "nivetha-catering.firebaseapp.com",
  projectId: "nivetha-catering",
  storageBucket: "nivetha-catering.firebasestorage.app",
  messagingSenderId: "587544029763",
  appId: "1:587544029763:web:c563187feed892419242f6",
  measurementId: "G-0S9LQZZNTG"
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

export async function requestOwnerNotificationToken(vapidKey) {
  if (!("Notification" in window)) return null;

  const permission = await Notification.requestPermission();
  if (permission !== "granted") return null;

  const registration = await navigator.serviceWorker.register("/firebase-messaging-sw.js");
  const token = await getToken(messaging, {
    vapidKey,
    serviceWorkerRegistration: registration,
  });

  console.log("OWNER_WEB_FCM_TOKEN:", token);
  return token;
}

export function listenForegroundNotifications(onNotify) {
  return onMessage(messaging, (payload) => {
    onNotify?.(payload);
  });
}