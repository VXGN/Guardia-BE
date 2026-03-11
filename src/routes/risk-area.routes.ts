import { Router } from "express";
import { RiskAreaController } from "../controllers/risk-area.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import { getRiskAreasSchema } from "../validators/risk-area.validator";

const router = Router();
const controller = new RiskAreaController();

router.get(
  "/",
  authMiddleware,
  validate(getRiskAreasSchema),
  controller.getRiskAreas
);

export { router as riskAreaRoutes };
