/*
  Warnings:

  - You are about to alter the column `center_lng_blurred` on the `heatmap_clusters` table. The data in that column could be lost. The data in that column will be cast from `Decimal(7,5)` to `Decimal(8,5)`.
  - You are about to alter the column `longitude_blurred` on the `incident_reports` table. The data in that column could be lost. The data in that column will be cast from `Decimal(7,5)` to `Decimal(8,5)`.

*/
-- AlterTable
ALTER TABLE `heatmap_clusters` MODIFY `center_lng_blurred` DECIMAL(8, 5) NOT NULL;

-- AlterTable
ALTER TABLE `incident_reports` MODIFY `longitude_blurred` DECIMAL(8, 5) NOT NULL;
