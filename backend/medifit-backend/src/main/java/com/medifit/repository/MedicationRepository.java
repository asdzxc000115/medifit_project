package com.medifit.repository;

import com.medifit.entity.Medication;
import com.medifit.entity.Patient;
import com.medifit.enums.MedicationStatus;
import com.medifit.enums.MedicationTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface MedicationRepository extends JpaRepository<Medication, Long> {

    // 🔥 기본 조회 메서드들

    // 환자별 복약 조회 (최신순)
    List<Medication> findByPatientOrderByCreatedAtDesc(Patient patient);

    // 환자 ID로 복약 조회
    List<Medication> findByPatientIdOrderByCreatedAtDesc(Long patientId);

    // 상태별 복약 조회
    List<Medication> findByStatusOrderByCreatedAtDesc(MedicationStatus status);

    // 환자별 특정 상태 복약 조회
    List<Medication> findByPatientIdAndStatusOrderByStartDateDesc(Long patientId, MedicationStatus status);

    // 🔥 복약 상태 관리

    // 활성 복약 조회
    List<Medication> findByPatientIdAndStatusOrderByCreatedAtDesc(Long patientId, MedicationStatus status);

    // 복약 상태별 개수
    long countByStatus(MedicationStatus status);

    // 환자별 상태별 개수
    long countByPatientIdAndStatus(Long patientId, MedicationStatus status);

    // 🔥 날짜 기반 조회

    // 특정 날짜에 복용해야 할 약물
    List<Medication> findByPatientIdAndStartDateLessThanEqualAndEndDateGreaterThanEqualAndStatus(
            Long patientId, LocalDate date1, LocalDate date2, MedicationStatus status);

    // 특정 기간 내 시작된 복약
    List<Medication> findByPatientIdAndStartDateBetweenOrderByStartDateDesc(
            Long patientId, LocalDate startDate, LocalDate endDate);

    // 특정 기간 내 생성된 복약
    List<Medication> findByPatientIdAndCreatedAtAfterOrderByCreatedAtDesc(
            Long patientId, LocalDateTime createdAfter);

    // 만료된 복약 조회
    List<Medication> findByEndDateBeforeAndStatusOrderByEndDateDesc(LocalDate date, MedicationStatus status);

    // 🔥 복약 일정 관리

    // 특정 기간의 복약 조회 (달력용)
    List<Medication> findByPatientIdAndStartDateLessThanEqualAndEndDateGreaterThanEqual(
            Long patientId, LocalDate endDate, LocalDate startDate);

    // 오늘 복용해야 할 약물
    @Query("SELECT m FROM Medication m WHERE m.patient.id = :patientId AND " +
            "m.startDate <= CURRENT_DATE AND m.endDate >= CURRENT_DATE AND " +
            "m.status = 'ACTIVE' ORDER BY m.medicationTime, m.createdAt")
    List<Medication> findTodayActiveMedications(@Param("patientId") Long patientId);

    // 🔥 검색 기능

    // 약품명으로 검색
    List<Medication> findByMedicationNameContainingIgnoreCaseOrderByCreatedAtDesc(String medicationName);

    // 환자의 약품명 검색
    List<Medication> findByPatientIdAndMedicationNameContainingIgnoreCaseOrderByCreatedAtDesc(
            Long patientId, String medicationName);

    // 복합 검색
    @Query("SELECT m FROM Medication m WHERE m.patient.id = :patientId AND " +
            "(LOWER(m.medicationName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(m.instructions) LIKE LOWER(CONCAT('%', :keyword, '%'))) " +
            "ORDER BY m.createdAt DESC")
    List<Medication> searchMedications(@Param("patientId") Long patientId, @Param("keyword") String keyword);

    // 🔥 복약 시간별 조회

    // 특정 복용 시간의 약물
    List<Medication> findByPatientIdAndMedicationTimeAndStatusOrderByCreatedAtDesc(
            Long patientId, MedicationTime medicationTime, MedicationStatus status);

    // 알림이 활성화된 약물
    List<Medication> findByPatientIdAndReminderEnabledTrueAndStatusOrderByMedicationTime(
            Long patientId, MedicationStatus status);

    // 🔥 통계용 쿼리

    // 환자별 월별 복약 통계
    @Query("SELECT YEAR(m.createdAt), MONTH(m.createdAt), COUNT(m) FROM Medication m " +
            "WHERE m.patient.id = :patientId AND m.createdAt >= :startDate " +
            "GROUP BY YEAR(m.createdAt), MONTH(m.createdAt) " +
            "ORDER BY YEAR(m.createdAt) DESC, MONTH(m.createdAt) DESC")
    List<Object[]> getMonthlyMedicationStats(@Param("patientId") Long patientId,
                                             @Param("startDate") LocalDateTime startDate);

    // 상태별 통계
    @Query("SELECT m.status, COUNT(m) FROM Medication m WHERE m.patient.id = :patientId " +
            "GROUP BY m.status ORDER BY COUNT(m) DESC")
    List<Object[]> getStatusStatistics(@Param("patientId") Long patientId);

    // 복용 시간별 통계
    @Query("SELECT m.medicationTime, COUNT(m) FROM Medication m WHERE m.patient.id = :patientId " +
            "AND m.status = 'ACTIVE' GROUP BY m.medicationTime ORDER BY m.medicationTime")
    List<Object[]> getMedicationTimeStatistics(@Param("patientId") Long patientId);

    // 🔥 고급 조회

    // 곧 만료될 약물 (7일 이내)
    @Query("SELECT m FROM Medication m WHERE m.patient.id = :patientId AND " +
            "m.endDate BETWEEN CURRENT_DATE AND :endDate AND m.status = 'ACTIVE' " +
            "ORDER BY m.endDate ASC")
    List<Medication> findExpiringMedications(@Param("patientId") Long patientId,
                                             @Param("endDate") LocalDate endDate);

    // 장기 복용 약물 (30일 이상) - Native Query 사용
    @Query(value = "SELECT * FROM medications WHERE patient_id = :patientId AND " +
            "DATEDIFF(end_date, start_date) >= 30 AND status IN ('ACTIVE', 'COMPLETED') " +
            "ORDER BY DATEDIFF(end_date, start_date) DESC",
            nativeQuery = true)
    List<Medication> findLongTermMedications(@Param("patientId") Long patientId);

    // 복용률이 낮은 약물
    @Query("SELECT m FROM Medication m WHERE m.patient.id = :patientId AND " +
            "m.totalDoses > 0 AND (CAST(m.completedDoses AS double) / m.totalDoses) < 0.8 " +
            "AND m.status = 'ACTIVE' ORDER BY (CAST(m.completedDoses AS double) / m.totalDoses) ASC")
    List<Medication> findLowComplianceMedications(@Param("patientId") Long patientId);

    // 부작용이 보고된 약물
    List<Medication> findByPatientIdAndSideEffectsIsNotNullOrderByUpdatedAtDesc(Long patientId);

    // 🔥 처방전 연관 조회

    // 처방전별 약물
    List<Medication> findByPrescriptionIdOrderByCreatedAtDesc(Long prescriptionId);

    // 처방전이 없는 일반의약품
    List<Medication> findByPatientIdAndPrescriptionIsNullOrderByCreatedAtDesc(Long patientId);

    // 🔥 알림 관련

    // 알림이 필요한 약물 (오늘 복용, 알림 활성화)
    @Query("SELECT m FROM Medication m WHERE " +
            "m.startDate <= CURRENT_DATE AND m.endDate >= CURRENT_DATE AND " +
            "m.status = 'ACTIVE' AND m.reminderEnabled = true " +
            "ORDER BY m.medicationTime, m.patient.id")
    List<Medication> findMedicationsNeedingReminder();

    // 특정 시간대 알림 약물
    @Query("SELECT m FROM Medication m WHERE m.patient.id = :patientId AND " +
            "m.medicationTime = :medicationTime AND m.status = 'ACTIVE' AND " +
            "m.reminderEnabled = true AND m.startDate <= CURRENT_DATE AND " +
            "m.endDate >= CURRENT_DATE")
    List<Medication> findMedicationsForTimeReminder(@Param("patientId") Long patientId,
                                                    @Param("medicationTime") MedicationTime medicationTime);

    // NotificationService에서 필요한 메서드 추가
    @Query("SELECT m FROM Medication m WHERE " +
            "m.status = 'ACTIVE' AND m.reminderEnabled = true AND " +
            "m.startDate <= CURRENT_DATE AND m.endDate >= CURRENT_DATE AND " +
            "m.medicationTime = :medicationTime " +
            "ORDER BY m.patient.id")
    List<Medication> findMedicationsByTime(@Param("medicationTime") MedicationTime medicationTime);

    // 🔥 환자 전용 - 내 복약 관리

    // 내 활성 복약 조회 (환자 앱용)
    @Query("SELECT m FROM Medication m WHERE m.patient.id = :patientId AND m.status = 'ACTIVE' " +
            "ORDER BY m.medicationTime, m.startDate DESC")
    List<Medication> findMyActiveMedications(@Param("patientId") Long patientId);

    // 내 복약 이력
    @Query("SELECT m FROM Medication m WHERE m.patient.id = :patientId " +
            "ORDER BY m.createdAt DESC")
    List<Medication> findMyMedicationHistory(@Param("patientId") Long patientId);

    // 내 오늘 복용 약물
    @Query("SELECT m FROM Medication m WHERE m.patient.id = :patientId AND " +
            "m.startDate <= CURRENT_DATE AND m.endDate >= CURRENT_DATE AND " +
            "m.status = 'ACTIVE' ORDER BY m.medicationTime")
    List<Medication> findMyTodayMedications(@Param("patientId") Long patientId);
}