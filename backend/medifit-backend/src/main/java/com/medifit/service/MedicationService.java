package com.medifit.service;

import com.medifit.entity.Medication;
import com.medifit.entity.Patient;
import com.medifit.enums.MedicationStatus;
import com.medifit.repository.MedicationRepository;
import com.medifit.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class MedicationService {

    @Autowired
    private MedicationRepository medicationRepository;

    @Autowired
    private PatientRepository patientRepository;

    // 🔥 모든 복약 정보 조회
    public List<Medication> getAllMedications() {
        return medicationRepository.findAll();
    }

    // 🔥 ID로 복약 정보 조회
    public Optional<Medication> findById(Long id) {
        return medicationRepository.findById(id);
    }

    // 🔥 환자별 활성 복약 조회
    public List<Medication> findActiveByPatientId(Long patientId) {
        return medicationRepository.findByPatientIdAndStatusOrderByStartDateDesc(patientId, MedicationStatus.ACTIVE);
    }

    // 🔥 환자별 복약 조회
    public List<Medication> findByPatientId(Long patientId) {
        return medicationRepository.findByPatientIdOrderByCreatedAtDesc(patientId);
    }

    // 🔥 상태별 복약 조회
    public List<Medication> findByStatus(MedicationStatus status) {
        return medicationRepository.findByStatusOrderByCreatedAtDesc(status);
    }

    // 🔥 복약 정보 저장
    public Medication save(Medication medication) {
        // 총 복용 횟수 자동 계산
        if (medication.getStartDate() != null && medication.getEndDate() != null && medication.getFrequency() != null) {
            long days = ChronoUnit.DAYS.between(medication.getStartDate(), medication.getEndDate()) + 1;
            medication.setTotalDoses((int) (days * medication.getFrequency()));
        }

        // 수정 시간 업데이트
        if (medication.getId() != null) {
            medication.setUpdatedAt(LocalDateTime.now());
        }

        return medicationRepository.save(medication);
    }

    // 🔥 복약 정보 삭제
    public void deleteById(Long id) {
        medicationRepository.deleteById(id);
    }

    // 🔥 오늘 복용할 약물 조회
    public List<Medication> findTodayMedications(Long patientId) {
        LocalDate today = LocalDate.now();
        return medicationRepository.findByPatientIdAndStartDateLessThanEqualAndEndDateGreaterThanEqualAndStatus(
                patientId, today, today, MedicationStatus.ACTIVE);
    }

    // 🔥 복약 완료 처리
    public Medication recordMedicationTaken(Long medicationId) {
        Optional<Medication> medicationOpt = findById(medicationId);
        if (medicationOpt.isPresent()) {
            Medication medication = medicationOpt.get();
            medication.setCompletedDoses(medication.getCompletedDoses() + 1);

            // 복용 완료 여부 체크
            if (medication.getCompletedDoses() >= medication.getTotalDoses() || LocalDate.now().isAfter(medication.getEndDate())) {
                medication.setStatus(MedicationStatus.COMPLETED);
            }

            return save(medication);
        }
        throw new RuntimeException("복약 정보를 찾을 수 없습니다.");
    }

    // 🔥 복약 상태 변경
    public Medication changeStatus(Long medicationId, MedicationStatus newStatus) {
        Optional<Medication> medicationOpt = findById(medicationId);
        if (medicationOpt.isPresent()) {
            Medication medication = medicationOpt.get();
            medication.setStatus(newStatus);
            return save(medication);
        }
        throw new RuntimeException("복약 정보를 찾을 수 없습니다.");
    }

    // 🔥 알림 토글
    public Medication toggleReminder(Long medicationId, Boolean enabled) {
        Optional<Medication> medicationOpt = findById(medicationId);
        if (medicationOpt.isPresent()) {
            Medication medication = medicationOpt.get();
            medication.setReminderEnabled(enabled);
            return save(medication);
        }
        throw new RuntimeException("복약 정보를 찾을 수 없습니다.");
    }

    // 🔥 환자의 복약 진행률
    public Map<String, Object> getPatientMedicationProgress(Long patientId) {
        List<Medication> medications = findByPatientId(patientId);

        Map<String, Object> progress = new HashMap<>();
        progress.put("totalMedications", medications.size());
        progress.put("activeMedications", medications.stream().filter(m -> m.getStatus() == MedicationStatus.ACTIVE).count());
        progress.put("completedMedications", medications.stream().filter(m -> m.getStatus() == MedicationStatus.COMPLETED).count());
        progress.put("pausedMedications", medications.stream().filter(m -> m.getStatus() == MedicationStatus.PAUSED).count());

        // 평균 진행률 계산
        double averageProgress = medications.stream()
                .mapToDouble(Medication::getProgressPercentage)
                .average()
                .orElse(0.0);
        progress.put("averageProgress", Math.round(averageProgress * 100.0) / 100.0);

        return progress;
    }

    // 🔥 월별 복약 통계
    public Map<String, Object> getMonthlyStatistics(Long patientId) {
        LocalDateTime startDate = LocalDateTime.now().minusMonths(12);
        List<Medication> medications = medicationRepository.findByPatientIdAndCreatedAtAfterOrderByCreatedAtDesc(patientId, startDate);

        Map<String, Object> stats = new HashMap<>();

        // 월별 신규 복약 수
        Map<String, Long> monthlyCount = medications.stream()
                .collect(Collectors.groupingBy(
                        m -> m.getCreatedAt().getYear() + "-" + String.format("%02d", m.getCreatedAt().getMonthValue()),
                        Collectors.counting()
                ));
        stats.put("monthlyNewMedications", monthlyCount);

        // 상태별 통계
        Map<MedicationStatus, Long> statusStats = medications.stream()
                .collect(Collectors.groupingBy(Medication::getStatus, Collectors.counting()));
        stats.put("statusStatistics", statusStats);

        // 복용률 통계
        double totalCompletionRate = medications.stream()
                .mapToDouble(Medication::getProgressPercentage)
                .average()
                .orElse(0.0);
        stats.put("averageCompletionRate", Math.round(totalCompletionRate * 100.0) / 100.0);

        return stats;
    }

    // 🔥 복약 달력
    public Map<String, Object> getMedicationCalendar(Long patientId, int year, int month) {
        LocalDate startDate = LocalDate.of(year, month, 1);
        LocalDate endDate = startDate.plusMonths(1).minusDays(1);

        List<Medication> medications = medicationRepository.findByPatientIdAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
                patientId, endDate, startDate);

        Map<String, Object> calendar = new HashMap<>();
        Map<String, List<String>> dailyMedications = new HashMap<>();

        // 각 날짜별 복용해야 할 약물 목록 생성
        for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
            final LocalDate currentDate = date;
            List<String> todayMeds = medications.stream()
                    .filter(m -> !m.getStartDate().isAfter(currentDate) && !m.getEndDate().isBefore(currentDate))
                    .map(Medication::getMedicationName)
                    .collect(Collectors.toList());

            if (!todayMeds.isEmpty()) {
                dailyMedications.put(date.toString(), todayMeds);
            }
        }

        calendar.put("year", year);
        calendar.put("month", month);
        calendar.put("dailyMedications", dailyMedications);
        calendar.put("totalMedications", medications.size());

        return calendar;
    }

    // 🔥 부작용 보고
    public Medication reportSideEffects(Long medicationId, String sideEffects) {
        Optional<Medication> medicationOpt = findById(medicationId);
        if (medicationOpt.isPresent()) {
            Medication medication = medicationOpt.get();
            medication.setSideEffects(sideEffects);
            medication.setUpdatedAt(LocalDateTime.now());
            return save(medication);
        }
        throw new RuntimeException("복약 정보를 찾을 수 없습니다.");
    }

    // 🔥 복약 통계 (전체)
    public long getTotalMedicationCount() {
        return medicationRepository.count();
    }

    // 🔥 활성 복약 수
    public long getActiveMedicationCount() {
        return medicationRepository.countByStatus(MedicationStatus.ACTIVE);
    }

    // 🔥 약품명으로 검색
    public List<Medication> searchByMedicationName(String medicationName) {
        return medicationRepository.findByMedicationNameContainingIgnoreCaseOrderByCreatedAtDesc(medicationName);
    }

    // 🔥 복용 기간으로 조회
    public List<Medication> findByDateRange(Long patientId, LocalDate startDate, LocalDate endDate) {
        return medicationRepository.findByPatientIdAndStartDateBetweenOrderByStartDateDesc(patientId, startDate, endDate);
    }
}