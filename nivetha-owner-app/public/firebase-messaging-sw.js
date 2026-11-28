importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDiauPNHTdfPo23sOcwHyolvX3aKvH41AA",
  authDomain: "nivetha-catering.firebaseapp.com",
  projectId: "nivetha-catering",
  storageBucket: "nivetha-catering.firebasestorage.app",
  messagingSenderId: "587544029763",
  appId: "1:587544029763:web:c563187feed892419242f6",
  measurementId: "G-0S9LQZZNTG",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload?.notification?.title || "Nivetha Catering";
  const options = {
    body: payload?.notification?.body || "New catering booking alert",
    icon: "/vite.svg",
    data: payload?.data || {},
  };
  self.registration.showNotification(title, options);
});