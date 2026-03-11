import { pythonClient } from "../config/axios";
import { InternalServerError } from "../utils/errors";

interface RouteCoordinates {
  start_lat: number;
  start_lng: number;
  end_lat: number;
  end_lng: number;
}

interface SafeRouteResponse {
  route: Array<{
    lat: number;
    lng: number;
  }>;
  total_distance_meters: number;
  total_risk_score: number;
  estimated_duration_seconds: number;
  avoided_risk_zones: number;
}

export class RouteService {
  async calculateSafeRoute(
    coordinates: RouteCoordinates
  ): Promise<SafeRouteResponse> {
    try {
      const response = await pythonClient.post<SafeRouteResponse>(
        "/route/safe",
        coordinates
      );
      return response.data;
    } catch (error) {
      if (error instanceof Error) {
        throw new InternalServerError(
          `Failed to calculate safe route: ${error.message}`
        );
      }
      throw new InternalServerError("Failed to calculate safe route");
    }
  }
}
