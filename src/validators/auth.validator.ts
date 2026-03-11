import { z } from "zod";

export const verifyTokenSchema = z.object({
  body: z.object({
    token: z.string().min(1),
  }),
});

export type VerifyTokenInput = z.infer<typeof verifyTokenSchema>["body"];
