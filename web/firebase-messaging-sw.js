importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js");

// Cole aqui as mesmas configurações que você usa no seu Firebase inicial
firebase.initializeApp({
  apiKey: "AIzaSyAM3IZDLqLY3FdWf-j33uzAzMO8P9BaOmg",
  authDomain: "baja-sun-city.firebaseapp.com",
  projectId: "baja-sun-city",
  storageBucket: "baja-sun-city.firebasestorage.app",
  messagingSenderId: "308621725070",
  appId: "1:308621725070:web:8894104821c0a3458ba8df"
});

const messaging = firebase.messaging();

// Opcional: Lidar com mensagens em background
messaging.onBackgroundMessage((payload) => {
  console.log("Mensagem em background recebida: ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png", // caminho para o seu ícone
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});