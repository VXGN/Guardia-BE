import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

async function main() {
  const adminUser = await prisma.user.create({
    data: {
      full_name: "Admin Guardia",
      email: "admin@guardia.id",
      role: "admin",
      is_anonymous_mode: false,
      is_verified: true,
    },
  });

  const regularUser = await prisma.user.create({
    data: {
      full_name: "Siti Nurhaliza",
      email: "siti@example.com",
      phone_number: "+6281234567890",
      role: "user",
      is_anonymous_mode: false,
      is_verified: true,
    },
  });

  const anonUser = await prisma.user.create({
    data: {
      role: "user",
      is_anonymous_mode: true,
      is_verified: false,
    },
  });

  await prisma.trustedContact.createMany({
    data: [
      {
        user_id: regularUser.id,
        contact_name: "Budi Santoso",
        contact_phone: "+6281298765432",
        contact_email: "budi@example.com",
        is_active: true,
      },
      {
        user_id: regularUser.id,
        contact_name: "Rina Wati",
        contact_phone: "+6285611223344",
        is_active: true,
      },
    ],
  });

  const report1 = await prisma.incidentReport.create({
    data: {
      user_id: regularUser.id,
      incident_type: "stalking",
      description: "Diikuti oleh orang tidak dikenal di sepanjang jalan menuju halte bus.",
      incident_at: new Date("2026-03-10T21:30:00Z"),
      latitude: -6.20876543,
      longitude: 106.84567890,
      latitude_blurred: -6.20900,
      longitude_blurred: 106.84600,
      location_label: "Jl. Sudirman, Jakarta Pusat",
      is_anonymous: false,
      status: "verified",
      severity_score: 4,
    },
  });

  const report2 = await prisma.incidentReport.create({
    data: {
      user_id: null,
      incident_type: "verbal_harassment",
      description: "Pelecehan verbal dari pengendara motor yang berlalu.",
      incident_at: new Date("2026-03-09T19:15:00Z"),
      latitude: -6.17512345,
      longitude: 106.86501234,
      latitude_blurred: -6.17500,
      longitude_blurred: 106.86500,
      location_label: "Jl. Thamrin, Jakarta Pusat",
      is_anonymous: true,
      status: "received",
      severity_score: 2,
    },
  });

  const report3 = await prisma.incidentReport.create({
    data: {
      user_id: regularUser.id,
      incident_type: "theft",
      description: "Tas dijambret saat berjalan di trotoar malam hari.",
      incident_at: new Date("2026-03-08T22:45:00Z"),
      latitude: -6.19234567,
      longitude: 106.82345678,
      latitude_blurred: -6.19200,
      longitude_blurred: 106.82300,
      location_label: "Jl. Kebon Kacang, Jakarta Pusat",
      is_anonymous: false,
      status: "resolved",
      severity_score: 5,
    },
  });

  await prisma.reportStatusLog.createMany({
    data: [
      {
        report_id: report1.id,
        changed_by: adminUser.id,
        old_status: "received",
        new_status: "verified",
        notes: "Laporan telah diverifikasi oleh admin.",
        changed_at: new Date("2026-03-10T23:00:00Z"),
      },
      {
        report_id: report3.id,
        changed_by: adminUser.id,
        old_status: "received",
        new_status: "in_progress",
        notes: "Sedang ditindaklanjuti.",
        changed_at: new Date("2026-03-09T10:00:00Z"),
      },
      {
        report_id: report3.id,
        changed_by: adminUser.id,
        old_status: "in_progress",
        new_status: "resolved",
        notes: "Kasus selesai ditangani oleh pihak berwajib.",
        changed_at: new Date("2026-03-10T14:00:00Z"),
      },
    ],
  });

  const segment1 = await prisma.roadSegment.create({
    data: {
      segment_name: "Jl. Sudirman Segmen A",
      start_lat: -6.20900000,
      start_lng: 106.84500000,
      end_lat: -6.20700000,
      end_lng: 106.84600000,
      length_meters: 350,
      has_street_light: true,
      is_main_road: true,
      near_security_post: true,
    },
  });

  const segment2 = await prisma.roadSegment.create({
    data: {
      segment_name: "Jl. Kebon Kacang Segmen B",
      start_lat: -6.19300000,
      start_lng: 106.82200000,
      end_lat: -6.19100000,
      end_lng: 106.82400000,
      length_meters: 280,
      has_street_light: false,
      is_main_road: false,
      near_security_post: false,
    },
  });

  const segment3 = await prisma.roadSegment.create({
    data: {
      segment_name: "Jl. Thamrin Segmen C",
      start_lat: -6.17600000,
      start_lng: 106.86400000,
      end_lat: -6.17400000,
      end_lng: 106.86600000,
      length_meters: 420,
      has_street_light: true,
      is_main_road: true,
      near_security_post: false,
    },
  });

  const segment4 = await prisma.roadSegment.create({
    data: {
      segment_name: "Gang Sempit Menteng",
      start_lat: -6.19500000,
      start_lng: 106.83800000,
      end_lat: -6.19400000,
      end_lng: 106.83900000,
      length_meters: 150,
      has_street_light: false,
      is_main_road: false,
      near_security_post: false,
    },
  });

  await prisma.riskScore.createMany({
    data: [
      {
        segment_id: segment1.id,
        time_slot: "night",
        risk_score: 35.50,
        incident_count: 3,
        dominant_incident_type: "stalking",
        calculated_at: new Date("2026-03-11T00:00:00Z"),
        valid_until: new Date("2026-04-11T00:00:00Z"),
      },
      {
        segment_id: segment1.id,
        time_slot: "evening",
        risk_score: 20.00,
        incident_count: 1,
        dominant_incident_type: "verbal_harassment",
        calculated_at: new Date("2026-03-11T00:00:00Z"),
        valid_until: new Date("2026-04-11T00:00:00Z"),
      },
      {
        segment_id: segment2.id,
        time_slot: "night",
        risk_score: 85.00,
        incident_count: 12,
        dominant_incident_type: "theft",
        calculated_at: new Date("2026-03-11T00:00:00Z"),
        valid_until: new Date("2026-04-11T00:00:00Z"),
      },
      {
        segment_id: segment2.id,
        time_slot: "evening",
        risk_score: 55.00,
        incident_count: 6,
        dominant_incident_type: "theft",
        calculated_at: new Date("2026-03-11T00:00:00Z"),
        valid_until: new Date("2026-04-11T00:00:00Z"),
      },
      {
        segment_id: segment3.id,
        time_slot: "night",
        risk_score: 28.00,
        incident_count: 2,
        dominant_incident_type: "verbal_harassment",
        calculated_at: new Date("2026-03-11T00:00:00Z"),
        valid_until: new Date("2026-04-11T00:00:00Z"),
      },
      {
        segment_id: segment4.id,
        time_slot: "night",
        risk_score: 92.50,
        incident_count: 15,
        dominant_incident_type: "physical_harassment",
        calculated_at: new Date("2026-03-11T00:00:00Z"),
        valid_until: new Date("2026-04-11T00:00:00Z"),
      },
      {
        segment_id: segment4.id,
        time_slot: "evening",
        risk_score: 60.00,
        incident_count: 7,
        dominant_incident_type: "stalking",
        calculated_at: new Date("2026-03-11T00:00:00Z"),
        valid_until: new Date("2026-04-11T00:00:00Z"),
      },
    ],
  });

  await prisma.heatmapCluster.createMany({
    data: [
      {
        center_lat_blurred: -6.19200,
        center_lng_blurred: 106.82300,
        radius_meters: 500,
        intensity: "critical",
        incident_count: 18,
        dominant_type: "theft",
        time_slot: "night",
        valid_from: new Date("2026-03-01T00:00:00Z"),
        valid_until: new Date("2026-04-01T00:00:00Z"),
      },
      {
        center_lat_blurred: -6.20900,
        center_lng_blurred: 106.84600,
        radius_meters: 300,
        intensity: "medium",
        incident_count: 5,
        dominant_type: "stalking",
        time_slot: "night",
        valid_from: new Date("2026-03-01T00:00:00Z"),
        valid_until: new Date("2026-04-01T00:00:00Z"),
      },
      {
        center_lat_blurred: -6.17500,
        center_lng_blurred: 106.86500,
        radius_meters: 400,
        intensity: "low",
        incident_count: 2,
        dominant_type: "verbal_harassment",
        time_slot: "evening",
        valid_from: new Date("2026-03-01T00:00:00Z"),
        valid_until: new Date("2026-04-01T00:00:00Z"),
      },
      {
        center_lat_blurred: -6.19500,
        center_lng_blurred: 106.83900,
        radius_meters: 200,
        intensity: "high",
        incident_count: 10,
        dominant_type: "physical_harassment",
        time_slot: "night",
        valid_from: new Date("2026-03-01T00:00:00Z"),
        valid_until: new Date("2026-04-01T00:00:00Z"),
      },
    ],
  });

  const journey = await prisma.journey.create({
    data: {
      user_id: regularUser.id,
      status: "completed",
      started_at: new Date("2026-03-10T19:00:00Z"),
      ended_at: new Date("2026-03-10T19:35:00Z"),
      origin_lat: -6.20876543,
      origin_lng: 106.84567890,
      destination_lat: -6.17512345,
      destination_lng: 106.86501234,
      safe_arrival_confirmed: true,
    },
  });

  const trustedContacts = await prisma.trustedContact.findMany({
    where: { user_id: regularUser.id },
  });

  if (trustedContacts.length > 0) {
    await prisma.journeyContact.create({
      data: {
        journey_id: journey.id,
        trusted_contact_id: trustedContacts[0].id,
        notified_at: new Date("2026-03-10T19:00:30Z"),
      },
    });
  }

  await prisma.journeyLocationLog.createMany({
    data: [
      {
        journey_id: journey.id,
        latitude: -6.20876543,
        longitude: 106.84567890,
        recorded_at: new Date("2026-03-10T19:00:00Z"),
        is_anomaly_flagged: false,
      },
      {
        journey_id: journey.id,
        latitude: -6.20500000,
        longitude: 106.84800000,
        recorded_at: new Date("2026-03-10T19:10:00Z"),
        is_anomaly_flagged: false,
      },
      {
        journey_id: journey.id,
        latitude: -6.19500000,
        longitude: 106.85500000,
        recorded_at: new Date("2026-03-10T19:20:00Z"),
        is_anomaly_flagged: false,
      },
      {
        journey_id: journey.id,
        latitude: -6.17512345,
        longitude: 106.86501234,
        recorded_at: new Date("2026-03-10T19:35:00Z"),
        is_anomaly_flagged: false,
      },
    ],
  });

  await prisma.notification.createMany({
    data: [
      {
        recipient_user_id: regularUser.id,
        notification_type: "journey_safe_arrival",
        title: "Perjalanan Selesai",
        body: "Anda telah sampai dengan selamat di tujuan. Terima kasih menggunakan Guardia!",
        related_journey_id: journey.id,
        is_sent: true,
        sent_at: new Date("2026-03-10T19:35:30Z"),
      },
      {
        recipient_user_id: regularUser.id,
        notification_type: "report_status_update",
        title: "Status Laporan Diperbarui",
        body: "Laporan insiden Anda telah diverifikasi oleh admin.",
        related_report_id: report1.id,
        is_sent: true,
        sent_at: new Date("2026-03-10T23:01:00Z"),
      },
      {
        recipient_phone: "+6281298765432",
        notification_type: "journey_start",
        title: "Perjalanan Dimulai",
        body: "Siti Nurhaliza memulai perjalanan dan menambahkan Anda sebagai kontak kepercayaan.",
        related_journey_id: journey.id,
        is_sent: true,
        sent_at: new Date("2026-03-10T19:00:30Z"),
      },
    ],
  });

  console.log("Seed completed successfully!");
  console.log(`  Users: 3 (admin, regular, anonymous)`);
  console.log(`  Trusted Contacts: 2`);
  console.log(`  Incident Reports: 3`);
  console.log(`  Report Status Logs: 3`);
  console.log(`  Road Segments: 4`);
  console.log(`  Risk Scores: 7`);
  console.log(`  Heatmap Clusters: 4`);
  console.log(`  Journeys: 1`);
  console.log(`  Journey Location Logs: 4`);
  console.log(`  Journey Contacts: 1`);
  console.log(`  Notifications: 3`);
}

main()
  .catch((e) => {
    console.error("Seed failed:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
