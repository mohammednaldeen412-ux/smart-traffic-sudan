import { initializeApp } from "firebase/app";
import { getFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyB73YgI4g1DQMU_finohQUjd5q68asrDGU",
  authDomain: "smart-traffic-sudan.firebaseapp.com",
  projectId: "smart-traffic-sudan",
  storageBucket: "smart-traffic-sudan.firebasestorage.app",
  messagingSenderId: "332395737612",
  appId: "1:332395737612:web:679e6a4436da1cc9413429",
  measurementId: "G-HBRVC86D20"
};

export const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
