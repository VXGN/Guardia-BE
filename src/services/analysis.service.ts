import { pythonClient } from "../config/axios";
import { InternalServerError } from "../utils/errors";

interface AnalysisCoordinates {
  start_lat: number;
  start_lng: number;
  end_lat: number;
  end_lng: number;
}

interface RiskAnalysisResponse {
  overall_risk_score: number;
  risk_level: "low" | "medium" | "high" | "critical";
  segments: Array<{
    segment_id: string;
    risk_score: number;
    risk_factors: string[];
    lat: number;
    lng: number;
  }>;
  recommendations: string[];
  analyzed_at: string;
}

export class AnalysisService {
  async analyzeRisk(
    coordinates: AnalysisCoordinates
  ): Promise<RiskAnalysisResponse> {
    try {
      const response = await pythonClient.post<RiskAnalysisResponse>(
        "/analyze",
        coordinates
      );
      return response.data;
    } catch (error) {
      if (error instanceof Error) {
        throw new InternalServerError(
          `Failed to analyze risk: ${error.message}`
        );
      }
      throw new InternalServerError("Failed to analyze risk from Python service");
    }
  }
}
