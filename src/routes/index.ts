import { Router } from "express";
import { authRoutes } from "./auth.routes";
import { riskAreaRoutes } from "./risk-area.routes";
import { routeRoutes } from "./route.routes";
import { analysisRoutes } from "./analysis.routes";

const router = Router();

router.use("/auth", authRoutes);
router.use("/risk-areas", riskAreaRoutes);
router.use("/route", routeRoutes);
router.use("/analysis", analysisRoutes);

export { router as apiRouter };
