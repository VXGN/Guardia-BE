import { Express } from "express";
import swaggerUi from "swagger-ui-express";

const swaggerSpec = {
  openapi: "3.0.0",
  info: {
    title: "Guardia API",
    version: "1.0.0",
    description: "Backend service for a safety map application that displays risk-prone areas and calculates safer routes.",
  },
  servers: [{ url: "/" }],
  components: {
    securitySchemes: {
      bearerAuth: {
        type: "http",
        scheme: "bearer",
        bearerFormat: "JWT",
      },
    },
  },
  security: [{ bearerAuth: [] }],
  paths: {
    "/health": {
      get: {
        summary: "Health check",
        responses: {
          "200": {
            description: "OK",
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    success: { type: "boolean" },
                    message: { type: "string" },
                    data: { type: "object" },
                  },
                },
              },
            },
          },
        },
      },
    },
    "/api/auth/verify": {
      post: {
        summary: "Verify Firebase token",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  token: { type: "string" },
                },
                required: ["token"],
              },
            },
          },
        },
        responses: {
          "200": { description: "Token verified successfully" },
          "400": { description: "Validation error" },
          "401": { description: "Invalid or expired Firebase token" },
        },
      },
    },
    "/api/risk-areas": {
      get: {
        summary: "Get Risk Areas",
        parameters: [
          { name: "lat", in: "query", schema: { type: "number" } },
          { name: "lng", in: "query", schema: { type: "number" } },
          { name: "radius", in: "query", schema: { type: "number" } },
          {
            name: "time_slot",
            in: "query",
            schema: { type: "string", enum: ["morning", "afternoon", "evening", "night"] },
          },
        ],
        responses: {
          "200": { description: "Risk areas retrieved successfully" },
          "400": { description: "Invalid coordinates" },
          "401": { description: "Missing or invalid authorization header" },
        },
      },
    },
    "/api/route/safe": {
      post: {
        summary: "Calculate Safe Route",
        requestBody: {
          required: true,
          content: {
            "application/json": {
              schema: {
                type: "object",
                properties: {
                  start_lat: { type: "number" },
                  start_lng: { type: "number" },
                  end_lat: { type: "number" },
                  end_lng: { type: "number" },
                },
                required: ["start_lat", "start_lng", "end_lat", "end_lng"],
              },
            },
          },
        },
        responses: {
          "200": { description: "Safe route calculated" },
          "400": { description: "Validation error" },
          "401": { description: "Unauthorized" },
        },
      },
    },
  },
};

const swaggerUiOptions = {
    explorer: true,
    customCss:'.swagger-ui .opblock .opblock-summary-path-description-wrapper { align-items: center; display: flex; flex-wrap: wrap; gap: 0 10px; padding: 0 10px; width: 100%; }',
    customCssUrl: 'https://cdnjs.cloudflare.com/ajax/libs/swagger-ui/5.0.0/swagger-ui.min.css'
}

export function setupSwagger(app: Express) {
  app.use(
    "/docs",
    swaggerUi.serve,
    swaggerUi.setup(swaggerSpec, swaggerUiOptions)
);
}
