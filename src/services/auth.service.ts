import { firebaseAuth } from "../config/firebase";
import { prisma } from "../config/database";
import { UnauthorizedError } from "../utils/errors";

interface VerifyResult {
  uid: string;
  email?: string;
  name?: string;
  picture?: string;
}

export class AuthService {
  async verifyToken(token: string): Promise<VerifyResult> {
    try {
      const decoded = await firebaseAuth.verifyIdToken(token);

      await prisma.user.upsert({
        where: { id: decoded.uid },
        update: {
          email: decoded.email || null,
          full_name: decoded.name || null,
          updated_at: new Date(),
        },
        create: {
          id: decoded.uid,
          email: decoded.email || null,
          full_name: decoded.name || null,
          role: "user",
          is_anonymous_mode: !decoded.email,
          is_verified: decoded.email_verified || false,
        },
      });

      return {
        uid: decoded.uid,
        email: decoded.email,
        name: decoded.name,
        picture: decoded.picture,
      };
    } catch {
      throw new UnauthorizedError("Invalid or expired Firebase token");
    }
  }
}
