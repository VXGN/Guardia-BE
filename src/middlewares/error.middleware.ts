import { Request, Response, NextFunction } from "express";
import { AppError } from "../utils/errors";
import { sendError } from "../utils/response";
import { env } from "../config/env";

export function errorHandler(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  if (err instanceof AppError) {
    sendError(res, err.message, err.statusCode);
    return;
  }

  const statusCode = 500;
  const message =
    env.nodeEnv === "production"
      ? "Internal Server Error"
      : err.message || "Internal Server Error";

  sendError(res, message, statusCode);
}
