import { Request, Response } from "express";
import { RiskAreaService } from "../services/risk-area.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";

const riskAreaService = new RiskAreaService();

export class RiskAreaController {
  getRiskAreas = asyncHandler(async (req: Request, res: Response) => {
    const filters = {
      lat: req.query.lat ? Number(req.query.lat) : undefined,
      lng: req.query.lng ? Number(req.query.lng) : undefined,
      radius: req.query.radius ? Number(req.query.radius) : undefined,
      time_slot: req.query.time_slot as
        | "morning"
        | "afternoon"
        | "evening"
        | "night"
        | undefined,
    };

    const result = await riskAreaService.getRiskAreas(filters);
    sendSuccess(res, result, "Risk areas retrieved successfully");
  });
}
