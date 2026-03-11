import * as admin from "firebase-admin";
import { env } from "./env";

let app: admin.app.App | null = null;

function getFirebaseApp(): admin.app.App {
  if (!app) {
    app = admin.initializeApp({
      credential: admin.credential.cert({
        projectId: env.firebase.projectId,
        clientEmail: env.firebase.clientEmail,
        privateKey: env.firebase.privateKey,
      }),
    });
  }
  return app;
}

export const firebaseAuth = new Proxy({} as admin.auth.Auth, {
  get(_target, prop) {
    const auth = getFirebaseApp().auth();
    return (auth as unknown as Record<string | symbol, unknown>)[prop];
  },
});
