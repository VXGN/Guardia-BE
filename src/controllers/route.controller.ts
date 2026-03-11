import { Request, Response } from "express";
import { RouteService } from "../services/route.service";
import { sendSuccess } from "../utils/response";
import { asyncHandler } from "../utils/async-handler";

const routeService = new RouteService();

export class RouteController {
  calculateSafeRoute = asyncHandler(async (req: Request, res: Response) => {
    const { start_lat, start_lng, end_lat, end_lng } = req.body;

    const result = await routeService.calculateSafeRoute({
      start_lat,
      start_lng,
      end_lat,
      end_lng,
    });

    sendSuccess(res, result, "Safe route calculated successfully");
  });
}
