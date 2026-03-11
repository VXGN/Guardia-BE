import express from "express";
import cors from "cors";
import helmet from "helmet";
import { env } from "./config/env";
import { apiRouter } from "./routes";
import { errorHandler } from "./middlewares/error.middleware";
import { notFoundHandler } from "./middlewares/not-found.middleware";
import { setupSwagger } from "./config/swagger";

const app = express();

const cspDirectives = helmet.contentSecurityPolicy.getDefaultDirectives();

cspDirectives["script-src"] = ["'self'", "'unsafe-inline'", "https://unpkg.com"];
cspDirectives["style-src"] = ["'self'", "https://unpkg.com"];
cspDirectives["connect-src"] = ["'self'", "https://unpkg.com"];

app.use(
  helmet({
    contentSecurityPolicy: {
      directives: cspDirectives,
    },
  })
);
app.use(cors());
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true }));
setupSwagger(app);

app.get("/health", (_req, res) => {
  res.status(200).json({
    success: true,
    message: "Guardia API is running",
    data: {
      uptime: process.uptime(),
      timestamp: new Date().toISOString(),
    },
  });
});

app.use("/api", apiRouter);

app.use(notFoundHandler);
app.use(errorHandler);

if (process.env.NODE_ENV !== "production" && !process.env.VERCEL) {
  app.listen(env.port, () => {
    console.log(
      `[Guardia] Server running on port ${env.port} in ${env.nodeEnv} mode`
    );
  });
}

export default app;
