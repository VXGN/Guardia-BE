import { z } from "zod";

const latitudeSchema = z.number().min(-90).max(90);
const longitudeSchema = z.number().min(-180).max(180);

export const riskAnalysisSchema = z.object({
  body: z.object({
    start_lat: latitudeSchema,
    start_lng: longitudeSchema,
    end_lat: latitudeSchema,
    end_lng: longitudeSchema,
  }),
});

export type RiskAnalysisInput = z.infer<typeof riskAnalysisSchema>["body"];
