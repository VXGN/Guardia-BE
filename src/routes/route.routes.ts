import { Router } from "express";
import { RouteController } from "../controllers/route.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import { safeRouteSchema } from "../validators/route.validator";

const router = Router();
const controller = new RouteController();

router.post(
  "/safe",
  authMiddleware,
  validate(safeRouteSchema),
  controller.calculateSafeRoute
);

export { router as routeRoutes };
