importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDiauPNHTdfPo23sOcwHyolvX3aKvH41AA",
  authDomain: "nivetha-catering.firebaseapp.com",
  projectId: "nivetha-catering",
  storageBucket: "nivetha-catering.firebasestorage.app",
  messagingSenderId: "587544029763",
  appId: "1:587544029763:web:c563187feed892419242f6",
  measurementId: "G-0S9LQZZNTG"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || "Nivetha Catering";
  const options = {
    body: payload.notification?.body || "புதிய அப்டேட் வந்துள்ளது",
    icon: "/vite.svg",
    data: payload.data || {}
  };
  self.registration.showNotification(title, options);
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  const targetUrl = event.notification.data?.url || "/";
  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ("focus" in client) {
          client.focus();
          if (event.notification.data?.url) {
            client.navigate(targetUrl);
          }
          return;
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});