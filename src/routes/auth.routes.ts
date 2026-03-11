import { Router } from "express";
import { AuthController } from "../controllers/auth.controller";
import { validate } from "../middlewares/validate.middleware";
import { verifyTokenSchema } from "../validators/auth.validator";

const router = Router();
const controller = new AuthController();

router.post("/verify", validate(verifyTokenSchema), controller.verify);

export { router as authRoutes };
