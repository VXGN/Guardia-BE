import { Request, Response } from "express";
import { AnalysisService } from "../services/analysis.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";

const analysisService = new AnalysisService();

export class AnalysisController {
  analyzeRisk = asyncHandler(async (req: Request, res: Response) => {
    const { start_lat, start_lng, end_lat, end_lng } = req.body;

    const result = await analysisService.analyzeRisk({
      start_lat,
      start_lng,
      end_lat,
      end_lng,
    });

    sendSuccess(res, result, "Risk analysis completed successfully");
  });
}
