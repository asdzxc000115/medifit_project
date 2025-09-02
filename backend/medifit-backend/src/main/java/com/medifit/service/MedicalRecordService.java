package com.medifit.service;

import com.medifit.entity.MedicalRecord;
import com.medifit.entity.Patient;
import com.medifit.entity.User;
import com.medifit.enums.RecordStatus;
import com.medifit.repository.MedicalRecordRepository;
import com.medifit.repository.PatientRepository;
import com.medifit.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class MedicalRecordService {

    @Autowired
    private MedicalRecordRepository medicalRecordRepository;

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private UserRepository userRepository;

    // 🔥 기본 CRUD 메서드들

    public List<MedicalRecord> getAllMedicalRecords() {
        return medicalRecordRepository.findAll();
    }

    public Optional<MedicalRecord> findById(Long id) {
        return medicalRecordRepository.findById(id);
    }

    public List<MedicalRecord> findByPatientId(Long patientId) {
        return medicalRecordRepository.findByPatientIdOrderByVisitDateDesc(patientId);
    }

    public List<MedicalRecord> findByDepartment(String department) {
        return medicalRecordRepository.findByDepartmentOrderByVisitDateDesc(department);
    }

    public MedicalRecord save(MedicalRecord medicalRecord) {
        if (medicalRecord.getId() != null) {
            medicalRecord.setUpdatedAt(LocalDateTime.now());
        }
        return medicalRecordRepository.save(medicalRecord);
    }

    public void deleteById(Long id) {
        medicalRecordRepository.deleteById(id);
    }

    // 🔥 환자별 최근 의료기록

    public List<MedicalRecord> findRecentByPatientId(Long patientId, int limit) {
        return medicalRecordRepository.findTop10ByPatientIdOrderByVisitDateDesc(patientId)
                .stream()
                .limit(limit)
                .collect(Collectors.toList());
    }

    public Optional<MedicalRecord> findLatestByPatientId(Long patientId) {
        List<MedicalRecord> records = findRecentByPatientId(patientId, 1);
        return records.isEmpty() ? Optional.empty() : Optional.of(records.get(0));
    }

    // 🔥 의료기록 검색

    public List<MedicalRecord> searchRecords(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new ArrayList<>();
        }
        return medicalRecordRepository.searchMedicalRecords(keyword.trim());
    }

    public List<MedicalRecord> findByDiagnosis(String diagnosis) {
        return medicalRecordRepository.findByDiagnosisContainingIgnoreCaseOrderByVisitDateDesc(diagnosis);
    }

    public List<MedicalRecord> findByDateRange(LocalDateTime startDate, LocalDateTime endDate, Long patientId) {
        if (patientId != null) {
            return medicalRecordRepository.findByPatientIdAndVisitDateBetweenOrderByVisitDateDesc(patientId, startDate, endDate);
        } else {
            return medicalRecordRepository.findByVisitDateBetweenOrderByVisitDateDesc(startDate, endDate);
        }
    }

    // 🔥 진단 및 치료 통계

    public Map<String, Object> getPatientDiagnosisStatistics(Long patientId) {
        List<MedicalRecord> records = findByPatientId(patientId);

        Map<String, Object> stats = new HashMap<>();

        // 진단명별 빈도
        Map<String, Long> diagnosisFrequency = records.stream()
                .filter(record -> record.getDiagnosis() != null && !record.getDiagnosis().trim().isEmpty())
                .collect(Collectors.groupingBy(
                        record -> record.getDiagnosis().toLowerCase().trim(),
                        Collectors.counting()
                ));
        stats.put("diagnosisFrequency", diagnosisFrequency);

        // 진료과별 방문 빈도
        Map<String, Long> departmentFrequency = records.stream()
                .filter(record -> record.getDepartment() != null)
                .collect(Collectors.groupingBy(MedicalRecord::getDepartment, Collectors.counting()));
        stats.put("departmentFrequency", departmentFrequency);

        // 최근 1년간 방문 패턴
        LocalDateTime oneYearAgo = LocalDateTime.now().minusYears(1);
        List<MedicalRecord> recentRecords = records.stream()
                .filter(record -> record.getVisitDate().isAfter(oneYearAgo))
                .collect(Collectors.toList());

        Map<String, Long> monthlyVisits = recentRecords.stream()
                .collect(Collectors.groupingBy(
                        record -> record.getVisitDate().format(DateTimeFormatter.ofPattern("yyyy-MM")),
                        Collectors.counting()
                ));
        stats.put("monthlyVisitPattern", monthlyVisits);

        // 총 통계
        stats.put("totalRecords", records.size());
        stats.put("uniqueDiagnoses", diagnosisFrequency.size());
        stats.put("visitedDepartments", departmentFrequency.size());

        // 가장 자주 받은 진단
        String mostCommonDiagnosis = diagnosisFrequency.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("없음");
        stats.put("mostCommonDiagnosis", mostCommonDiagnosis);

        return stats;
    }

    // 🔥 AI 요약 생성

    public String generateAiSummary(Long recordId) {
        Optional<MedicalRecord> recordOpt = findById(recordId);
        if (recordOpt.isPresent()) {
            MedicalRecord record = recordOpt.get();

            // 실제로는 OpenAI API 호출하지만, 여기서는 규칙 기반 요약 생성
            StringBuilder summary = new StringBuilder();
            summary.append("📋 진료 요약\n");
            summary.append("• 진료과: ").append(record.getDepartment()).append("\n");
            summary.append("• 진단명: ").append(record.getDiagnosis()).append("\n");

            if (record.getSymptoms() != null && !record.getSymptoms().trim().isEmpty()) {
                summary.append("• 주요 증상: ").append(record.getSymptoms()).append("\n");
            }

            if (record.getTreatment() != null && !record.getTreatment().trim().isEmpty()) {
                summary.append("• 치료 방법: ").append(record.getTreatment()).append("\n");
            }

            summary.append("• 진료비: ").append(record.getMedicalFee() != null ? record.getMedicalFee() + "원" : "미기재").append("\n");
            summary.append("• 진료일: ").append(record.getVisitDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));

            // AI 요약 저장
            record.setAiSummary(summary.toString());
            save(record);

            return summary.toString();
        }

        throw new RuntimeException("의료기록을 찾을 수 없습니다.");
    }

    // 🔥 월별 통계

    public Map<String, Object> getMonthlyStatistics(Long patientId, int months) {
        LocalDateTime startDate = LocalDateTime.now().minusMonths(months);
        List<MedicalRecord> records;

        if (patientId != null) {
            records = medicalRecordRepository.findByPatientIdAndVisitDateAfterOrderByVisitDateDesc(patientId, startDate);
        } else {
            records = medicalRecordRepository.findByVisitDateAfterOrderByVisitDateDesc(startDate);
        }

        Map<String, Object> stats = new HashMap<>();

        // 월별 진료 횟수
        Map<String, Long> monthlyCount = records.stream()
                .collect(Collectors.groupingBy(
                        record -> record.getVisitDate().format(DateTimeFormatter.ofPattern("yyyy-MM")),
                        Collectors.counting()
                ));
        stats.put("monthlyRecords", monthlyCount);

        // 월별 평균 진료비
        Map<String, Double> monthlyAvgFee = records.stream()
                .filter(record -> record.getMedicalFee() != null && record.getMedicalFee() > 0)
                .collect(Collectors.groupingBy(
                        record -> record.getVisitDate().format(DateTimeFormatter.ofPattern("yyyy-MM")),
                        Collectors.averagingDouble(MedicalRecord::getMedicalFee)
                ));
        stats.put("monthlyAverageFee", monthlyAvgFee);

        // 진료과별 분포
        Map<String, Long> departmentDistribution = records.stream()
                .collect(Collectors.groupingBy(MedicalRecord::getDepartment, Collectors.counting()));
        stats.put("departmentDistribution", departmentDistribution);

        return stats;
    }

    // 🔥 진료비 통계

    public Map<String, Object> getMedicalFeeStatistics(Long patientId) {
        List<MedicalRecord> records = patientId != null ?
                findByPatientId(patientId) : getAllMedicalRecords();

        List<Integer> fees = records.stream()
                .filter(record -> record.getMedicalFee() != null && record.getMedicalFee() > 0)
                .map(MedicalRecord::getMedicalFee)
                .collect(Collectors.toList());

        Map<String, Object> feeStats = new HashMap<>();

        if (!fees.isEmpty()) {
            int totalFee = fees.stream().mapToInt(Integer::intValue).sum();
            double averageFee = fees.stream().mapToInt(Integer::intValue).average().orElse(0.0);
            int minFee = fees.stream().mapToInt(Integer::intValue).min().orElse(0);
            int maxFee = fees.stream().mapToInt(Integer::intValue).max().orElse(0);

            feeStats.put("totalFee", totalFee);
            feeStats.put("averageFee", Math.round(averageFee));
            feeStats.put("minFee", minFee);
            feeStats.put("maxFee", maxFee);
            feeStats.put("recordCount", fees.size());

            // 진료비 구간별 분포
            Map<String, Long> feeRanges = new HashMap<>();
            feeRanges.put("0-50000", fees.stream().filter(fee -> fee <= 50000).count());
            feeRanges.put("50001-100000", fees.stream().filter(fee -> fee > 50000 && fee <= 100000).count());
            feeRanges.put("100001-200000", fees.stream().filter(fee -> fee > 100000 && fee <= 200000).count());
            feeRanges.put("200001+", fees.stream().filter(fee -> fee > 200000).count());

            feeStats.put("feeRangeDistribution", feeRanges);
        } else {
            feeStats.put("totalFee", 0);
            feeStats.put("averageFee", 0);
            feeStats.put("recordCount", 0);
            feeStats.put("message", "진료비 정보가 없습니다.");
        }

        return feeStats;
    }

    // 🔥 진료 패턴 분석

    public Map<String, Object> getPatientCarePattern(Long patientId) {
        List<MedicalRecord> records = findByPatientId(patientId);

        if (records.isEmpty()) {
            return Map.of("message", "진료 기록이 없습니다.");
        }

        Map<String, Object> pattern = new HashMap<>();

        // 방문 간격 분석
        List<Long> visitIntervals = new ArrayList<>();
        for (int i = 1; i < records.size(); i++) {
            LocalDateTime prev = records.get(i).getVisitDate();
            LocalDateTime current = records.get(i-1).getVisitDate();
            long daysBetween = java.time.Duration.between(prev, current).toDays();
            visitIntervals.add(daysBetween);
        }

        if (!visitIntervals.isEmpty()) {
            double averageInterval = visitIntervals.stream().mapToLong(Long::longValue).average().orElse(0.0);
            pattern.put("averageVisitInterval", Math.round(averageInterval));
        }

        // 계절별 방문 패턴
        Map<String, Long> seasonalPattern = records.stream()
                .collect(Collectors.groupingBy(
                        record -> getSeason(record.getVisitDate().getMonthValue()),
                        Collectors.counting()
                ));
        pattern.put("seasonalVisitPattern", seasonalPattern);

        // 요일별 방문 패턴
        Map<String, Long> dayOfWeekPattern = records.stream()
                .collect(Collectors.groupingBy(
                        record -> record.getVisitDate().getDayOfWeek().toString(),
                        Collectors.counting()
                ));
        pattern.put("dayOfWeekPattern", dayOfWeekPattern);

        // 시간대별 방문 패턴
        Map<String, Long> timeOfDayPattern = records.stream()
                .collect(Collectors.groupingBy(
                        record -> getTimeOfDay(record.getVisitDate().getHour()),
                        Collectors.counting()
                ));
        pattern.put("timeOfDayPattern", timeOfDayPattern);

        return pattern;
    }

    private String getSeason(int month) {
        if (month >= 3 && month <= 5) return "봄";
        if (month >= 6 && month <= 8) return "여름";
        if (month >= 9 && month <= 11) return "가을";
        return "겨울";
    }

    private String getTimeOfDay(int hour) {
        if (hour >= 6 && hour < 12) return "오전";
        if (hour >= 12 && hour < 18) return "오후";
        if (hour >= 18 && hour < 22) return "저녁";
        return "야간";
    }

    // 🔥 복합 검색 및 필터링

    public List<MedicalRecord> findWithFilters(Long patientId, String department,
                                               String diagnosis, LocalDateTime startDate,
                                               LocalDateTime endDate) {
        return medicalRecordRepository.findWithFilters(patientId, department, diagnosis, startDate, endDate);
    }

    // 🔥 의료기록 검증

    public List<String> validateMedicalRecord(MedicalRecord record) {
        List<String> errors = new ArrayList<>();

        if (record.getPatient() == null) {
            errors.add("환자 정보가 필요합니다.");
        }

        if (record.getDoctor() == null) {
            errors.add("의사 정보가 필요합니다.");
        }

        if (record.getDiagnosis() == null || record.getDiagnosis().trim().isEmpty()) {
            errors.add("진단명은 필수 항목입니다.");
        }

        if (record.getDepartment() == null || record.getDepartment().trim().isEmpty()) {
            errors.add("진료과는 필수 항목입니다.");
        }

        if (record.getVisitDate() == null) {
            errors.add("진료일시는 필수 항목입니다.");
        } else if (record.getVisitDate().isAfter(LocalDateTime.now())) {
            errors.add("진료일시는 현재 시간보다 이후일 수 없습니다.");
        }

        if (record.getMedicalFee() != null && record.getMedicalFee() < 0) {
            errors.add("진료비는 0원 이상이어야 합니다.");
        }

        return errors;
    }

    // 🔥 치료 경과 추적

    public Map<String, Object> getPatientProgressTracking(Long patientId, String diagnosis) {
        List<MedicalRecord> relatedRecords = medicalRecordRepository
                .findByPatientIdAndDiagnosisContainingIgnoreCaseOrderByVisitDateAsc(patientId, diagnosis);

        Map<String, Object> progress = new HashMap<>();
        progress.put("totalVisits", relatedRecords.size());

        if (!relatedRecords.isEmpty()) {
            progress.put("firstVisit", relatedRecords.get(0).getVisitDate());
            progress.put("lastVisit", relatedRecords.get(relatedRecords.size() - 1).getVisitDate());

            // 치료 기간 계산
            long treatmentDays = java.time.Duration.between(
                    relatedRecords.get(0).getVisitDate(),
                    relatedRecords.get(relatedRecords.size() - 1).getVisitDate()
            ).toDays();
            progress.put("treatmentDurationDays", treatmentDays);

            // 치료비 총합
            int totalCost = relatedRecords.stream()
                    .filter(record -> record.getMedicalFee() != null)
                    .mapToInt(MedicalRecord::getMedicalFee)
                    .sum();
            progress.put("totalTreatmentCost", totalCost);

            // 치료 진행 상태
            MedicalRecord lastRecord = relatedRecords.get(relatedRecords.size() - 1);
            progress.put("currentStatus", lastRecord.getStatus());
            progress.put("latestTreatment", lastRecord.getTreatment());
        }

        return progress;
    }

    // 🔥 의료진별 통계

    public Map<String, Object> getDoctorStatistics(Long doctorId) {
        List<MedicalRecord> records = medicalRecordRepository.findByDoctorIdOrderByVisitDateDesc(doctorId);

        Map<String, Object> stats = new HashMap<>();
        stats.put("totalRecords", records.size());

        // 월별 진료 건수
        Map<String, Long> monthlyRecords = records.stream()
                .collect(Collectors.groupingBy(
                        record -> record.getVisitDate().format(DateTimeFormatter.ofPattern("yyyy-MM")),
                        Collectors.counting()
                ));
        stats.put("monthlyRecords", monthlyRecords);

        // 진료과별 건수
        Map<String, Long> departmentRecords = records.stream()
                .collect(Collectors.groupingBy(MedicalRecord::getDepartment, Collectors.counting()));
        stats.put("departmentRecords", departmentRecords);

        // 평균 진료비
        double averageFee = records.stream()
                .filter(record -> record.getMedicalFee() != null)
                .mapToInt(MedicalRecord::getMedicalFee)
                .average()
                .orElse(0.0);
        stats.put("averageMedicalFee", Math.round(averageFee));

        // 가장 흔한 진단
        Map<String, Long> diagnosisFrequency = records.stream()
                .filter(record -> record.getDiagnosis() != null)
                .collect(Collectors.groupingBy(MedicalRecord::getDiagnosis, Collectors.counting()));

        String mostCommonDiagnosis = diagnosisFrequency.entrySet().stream()
                .max(Map.Entry.comparingByValue())
                .map(Map.Entry::getKey)
                .orElse("없음");
        stats.put("mostCommonDiagnosis", mostCommonDiagnosis);

        return stats;
    }

    // 🔥 대시보드 통계

    public Map<String, Object> getDashboardStatistics() {
        Map<String, Object> dashboard = new HashMap<>();

        // 전체 통계
        long totalRecords = medicalRecordRepository.count();
        dashboard.put("totalRecords", totalRecords);

        // 오늘 진료 건수
        LocalDateTime startOfDay = LocalDateTime.now().toLocalDate().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusSeconds(1);
        long todayRecords = medicalRecordRepository.countByVisitDateBetween(startOfDay, endOfDay);
        dashboard.put("todayRecords", todayRecords);

        // 이번 주 진료 건수
        LocalDateTime startOfWeek = LocalDateTime.now().toLocalDate().atStartOfDay()
                .minusDays(LocalDateTime.now().getDayOfWeek().getValue() - 1);
        LocalDateTime endOfWeek = startOfWeek.plusDays(7);
        long weeklyRecords = medicalRecordRepository.countByVisitDateBetween(startOfWeek, endOfWeek);
        dashboard.put("weeklyRecords", weeklyRecords);

        // 이번 달 진료 건수
        LocalDateTime startOfMonth = LocalDateTime.now().toLocalDate().withDayOfMonth(1).atStartOfDay();
        LocalDateTime endOfMonth = startOfMonth.plusMonths(1).minusSeconds(1);
        long monthlyRecords = medicalRecordRepository.countByVisitDateBetween(startOfMonth, endOfMonth);
        dashboard.put("monthlyRecords", monthlyRecords);

        // 활성 환자 수 (최근 3개월 내 방문)
        LocalDateTime threeMonthsAgo = LocalDateTime.now().minusMonths(3);
        long activePatients = medicalRecordRepository.countDistinctPatientByVisitDateAfter(threeMonthsAgo);
        dashboard.put("activePatients", activePatients);

        return dashboard;
    }

    // 🔥 데이터 내보내기

    public List<Map<String, Object>> exportPatientRecords(Long patientId, LocalDateTime startDate, LocalDateTime endDate) {
        List<MedicalRecord> records = findByDateRange(startDate, endDate, patientId);

        return records.stream().map(record -> {
            Map<String, Object> exportData = new HashMap<>();
            exportData.put("visitDate", record.getVisitDate().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")));
            exportData.put("patientName", record.getPatient().getName());
            exportData.put("department", record.getDepartment());
            exportData.put("doctorName", record.getDoctor().getHospitalName() != null ?
                    record.getDoctor().getHospitalName() : record.getDoctor().getUsername());
            exportData.put("diagnosis", record.getDiagnosis());
            exportData.put("symptoms", record.getSymptoms());
            exportData.put("treatment", record.getTreatment());
            exportData.put("medicalFee", record.getMedicalFee());
            exportData.put("roomNumber", record.getRoomNumber());
            exportData.put("status", record.getStatus().getDescription());
            return exportData;
        }).collect(Collectors.toList());
    }

    // 🔥 중복 기록 감지

    public List<MedicalRecord> findPotentialDuplicates(Long patientId) {
        List<MedicalRecord> allRecords = findByPatientId(patientId);
        List<MedicalRecord> duplicates = new ArrayList<>();

        for (int i = 0; i < allRecords.size(); i++) {
            for (int j = i + 1; j < allRecords.size(); j++) {
                MedicalRecord record1 = allRecords.get(i);
                MedicalRecord record2 = allRecords.get(j);

                // 같은 날, 같은 진료과, 같은 진단인 경우 중복 의심
                if (record1.getVisitDate().toLocalDate().equals(record2.getVisitDate().toLocalDate()) &&
                        record1.getDepartment().equals(record2.getDepartment()) &&
                        record1.getDiagnosis().equalsIgnoreCase(record2.getDiagnosis())) {

                    if (!duplicates.contains(record1)) duplicates.add(record1);
                    if (!duplicates.contains(record2)) duplicates.add(record2);
                }
            }
        }

        return duplicates;
    }

    // 🔥 치료 효과 분석

    public Map<String, Object> analyzeTreatmentEffectiveness(String diagnosis, String treatment) {
        List<MedicalRecord> treatmentRecords = medicalRecordRepository
                .findByDiagnosisContainingIgnoreCaseAndTreatmentContainingIgnoreCaseOrderByVisitDateDesc(diagnosis, treatment);

        Map<String, Object> analysis = new HashMap<>();
        analysis.put("totalCases", treatmentRecords.size());

        if (!treatmentRecords.isEmpty()) {
            // 환자별 그룹핑
            Map<Long, List<MedicalRecord>> patientGroups = treatmentRecords.stream()
                    .collect(Collectors.groupingBy(record -> record.getPatient().getId()));

            int improvedCases = 0;
            int totalTrackedCases = 0;

            for (List<MedicalRecord> patientRecords : patientGroups.values()) {
                if (patientRecords.size() > 1) {
                    // 시간순 정렬
                    patientRecords.sort(Comparator.comparing(MedicalRecord::getVisitDate));

                    // 마지막 기록이 완료 상태이면 호전된 것으로 간주
                    MedicalRecord lastRecord = patientRecords.get(patientRecords.size() - 1);
                    if (lastRecord.getStatus() == RecordStatus.COMPLETED) {
                        improvedCases++;
                    }
                    totalTrackedCases++;
                }
            }

            double successRate = totalTrackedCases > 0 ?
                    (double) improvedCases / totalTrackedCases * 100 : 0;

            analysis.put("trackedCases", totalTrackedCases);
            analysis.put("improvedCases", improvedCases);
            analysis.put("successRate", Math.round(successRate * 100.0) / 100.0);

            // 평균 치료 기간
            List<Long> treatmentDurations = new ArrayList<>();
            for (List<MedicalRecord> patientRecords : patientGroups.values()) {
                if (patientRecords.size() > 1) {
                    long duration = java.time.Duration.between(
                            patientRecords.get(0).getVisitDate(),
                            patientRecords.get(patientRecords.size() - 1).getVisitDate()
                    ).toDays();
                    treatmentDurations.add(duration);
                }
            }

            double averageDuration = treatmentDurations.stream()
                    .mapToLong(Long::longValue)
                    .average()
                    .orElse(0.0);
            analysis.put("averageTreatmentDays", Math.round(averageDuration));
        }

        return analysis;
    }

    // 🔥 환자 상태 변화 추적

    public List<Map<String, Object>> getPatientStatusTimeline(Long patientId) {
        List<MedicalRecord> records = findByPatientId(patientId);

        return records.stream().map(record -> {
            Map<String, Object> timelineItem = new HashMap<>();
            timelineItem.put("date", record.getVisitDate());
            timelineItem.put("department", record.getDepartment());
            timelineItem.put("diagnosis", record.getDiagnosis());
            timelineItem.put("treatment", record.getTreatment());
            timelineItem.put("status", record.getStatus().getDescription());
            timelineItem.put("medicalFee", record.getMedicalFee());
            timelineItem.put("doctorName", record.getDoctor().getHospitalName() != null ?
                    record.getDoctor().getHospitalName() : record.getDoctor().getUsername());

            // AI 요약이 있으면 포함
            if (record.getAiSummary() != null && !record.getAiSummary().trim().isEmpty()) {
                timelineItem.put("aiSummary", record.getAiSummary());
            }

            return timelineItem;
        }).collect(Collectors.toList());
    }
}