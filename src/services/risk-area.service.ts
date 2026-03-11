import { prisma } from "../config/database";
import { NotFoundError } from "../utils/errors";

interface RiskAreaFilters {
  lat?: number;
  lng?: number;
  radius?: number;
  time_slot?: "morning" | "afternoon" | "evening" | "night";
}

interface HeatmapClusterResult {
  id: string;
  center_lat_blurred: number;
  center_lng_blurred: number;
  radius_meters: number;
  intensity: string;
  incident_count: number;
  dominant_type: string | null;
  time_slot: string | null;
  valid_from: Date;
  valid_until: Date;
}

interface RiskScoreResult {
  id: string;
  segment_id: string;
  time_slot: string;
  risk_score: number;
  incident_count: number;
  dominant_incident_type: string | null;
  road_segment: {
    id: string;
    segment_name: string | null;
    start_lat: number;
    start_lng: number;
    end_lat: number;
    end_lng: number;
    has_street_light: boolean;
    is_main_road: boolean;
    near_security_post: boolean;
  };
}

interface RiskAreasResponse {
  heatmap_clusters: HeatmapClusterResult[];
  risk_scores: RiskScoreResult[];
}

export class RiskAreaService {
  async getRiskAreas(filters: RiskAreaFilters): Promise<RiskAreasResponse> {
    const now = new Date();

    const heatmapWhere: Record<string, unknown> = {
      valid_until: { gte: now },
    };

    if (filters.time_slot) {
      heatmapWhere.time_slot = filters.time_slot;
    }

    const heatmapClusters = await prisma.heatmapCluster.findMany({
      where: heatmapWhere,
      orderBy: { incident_count: "desc" },
      take: 100,
    });

    const riskScoreWhere: Record<string, unknown> = {};

    if (filters.time_slot) {
      riskScoreWhere.time_slot = filters.time_slot;
    }

    const riskScores = await prisma.riskScore.findMany({
      where: riskScoreWhere,
      include: {
        road_segment: true,
      },
      orderBy: { risk_score: "desc" },
      take: 100,
    });

    const formattedClusters: HeatmapClusterResult[] = heatmapClusters.map(
      (c: { id: any; center_lat_blurred: any; center_lng_blurred: any; radius_meters: any; intensity: any; incident_count: any; dominant_type: any; time_slot: any; valid_from: any; valid_until: any; }) => ({
        id: c.id,
        center_lat_blurred: Number(c.center_lat_blurred),
        center_lng_blurred: Number(c.center_lng_blurred),
        radius_meters: c.radius_meters,
        intensity: c.intensity,
        incident_count: c.incident_count,
        dominant_type: c.dominant_type,
        time_slot: c.time_slot,
        valid_from: c.valid_from,
        valid_until: c.valid_until,
      })
    );

    const formattedScores: RiskScoreResult[] = riskScores.map((r: { id: any; segment_id: any; time_slot: any; risk_score: any; incident_count: any; dominant_incident_type: any; road_segment: { id: any; segment_name: any; start_lat: any; start_lng: any; end_lat: any; end_lng: any; has_street_light: any; is_main_road: any; near_security_post: any; }; }) => ({
      id: r.id,
      segment_id: r.segment_id,
      time_slot: r.time_slot,
      risk_score: Number(r.risk_score),
      incident_count: r.incident_count,
      dominant_incident_type: r.dominant_incident_type,
      road_segment: {
        id: r.road_segment.id,
        segment_name: r.road_segment.segment_name,
        start_lat: Number(r.road_segment.start_lat),
        start_lng: Number(r.road_segment.start_lng),
        end_lat: Number(r.road_segment.end_lat),
        end_lng: Number(r.road_segment.end_lng),
        has_street_light: r.road_segment.has_street_light,
        is_main_road: r.road_segment.is_main_road,
        near_security_post: r.road_segment.near_security_post,
      },
    }));

    return {
      heatmap_clusters: formattedClusters,
      risk_scores: formattedScores,
    };
  }
}
