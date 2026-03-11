import { z } from "zod";

const latitudeSchema = z.number().min(-90).max(90);
const longitudeSchema = z.number().min(-180).max(180);

export const getRiskAreasSchema = z.object({
  query: z.object({
    lat: z
      .string()
      .transform(Number)
      .pipe(latitudeSchema)
      .optional(),
    lng: z
      .string()
      .transform(Number)
      .pipe(longitudeSchema)
      .optional(),
    radius: z
      .string()
      .transform(Number)
      .pipe(z.number().positive().max(50000))
      .optional(),
    time_slot: z
      .enum(["morning", "afternoon", "evening", "night"])
      .optional(),
  }),
});

export type GetRiskAreasInput = z.infer<typeof getRiskAreasSchema>["query"];
