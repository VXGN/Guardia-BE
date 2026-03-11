import { Request, Response } from "express";
import { AuthService } from "../services/auth.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";

const authService = new AuthService();

export class AuthController {
  verify = asyncHandler(async (req: Request, res: Response) => {
    const { token } = req.body;
    const result = await authService.verifyToken(token);
    sendSuccess(res, result, "Token verified successfully");
  });
}
