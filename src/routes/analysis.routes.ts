import { Router } from "express";
import { AnalysisController } from "../controllers/analysis.controller";
import { authMiddleware } from "../middlewares/auth.middleware";
import { validate } from "../middlewares/validate.middleware";
import { riskAnalysisSchema } from "../validators/analysis.validator";

const router = Router();
const controller = new AnalysisController();

router.post(
  "/risk",
  authMiddleware,
  validate(riskAnalysisSchema),
  controller.analyzeRisk
);

export { router as analysisRoutes };
