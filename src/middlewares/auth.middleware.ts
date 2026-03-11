import { Request, Response, NextFunction } from "express";
import { firebaseAuth } from "../config/firebase";
import { UnauthorizedError } from "../utils/errors";

export interface AuthenticatedRequest extends Request {
  uid?: string;
  email?: string;
}

export async function authMiddleware(
  req: AuthenticatedRequest,
  _res: Response,
  next: NextFunction
): Promise<void> {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return next(new UnauthorizedError("Missing or invalid authorization header"));
  }

  const token = authHeader.split("Bearer ")[1];

  if (!token) {
    return next(new UnauthorizedError("Token not provided"));
  }

  try {
    const decodedToken = await firebaseAuth.verifyIdToken(token);
    req.uid = decodedToken.uid;
    req.email = decodedToken.email;
    next();
  } catch {
    next(new UnauthorizedError("Invalid or expired token"));
  }
}
