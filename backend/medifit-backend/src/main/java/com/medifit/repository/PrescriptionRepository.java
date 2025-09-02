package com.medifit.repository;

import com.medifit.entity.Patient;
import com.medifit.entity.Prescription;
import com.medifit.enums.PrescriptionStatus;
import com.medifit.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface PrescriptionRepository extends JpaRepository<Prescription, Long> {

    // 처방전 번호로 조회
    Optional<Prescription> findByPrescriptionNumber(String prescriptionNumber);

    // 환자별 처방전 조회 (최신순)
    List<Prescription> findByPatientOrderByPrescribedDateDesc(Patient patient);

    // 환자 ID로 처방전 조회
    List<Prescription> findByPatientIdOrderByPrescribedDateDesc(Long patientId);

    // 의사별 처방전 조회
    List<Prescription> findByDoctorOrderByPrescribedDateDesc(User doctor);

    // 의사 ID로 처방전 조회
    List<Prescription> findByDoctorIdOrderByPrescribedDateDesc(Long doctorId);

    // 상태별 처방전 조회
    List<Prescription> findByStatusOrderByPrescribedDateDesc(PrescriptionStatus status);

    // 환자의 특정 상태 처방전 조회
    List<Prescription> findByPatientIdAndStatusOrderByPrescribedDateDesc(
            Long patientId, PrescriptionStatus status);

    // 의사의 특정 상태 처방전 조회
    List<Prescription> findByDoctorIdAndStatusOrderByPrescribedDateDesc(
            Long doctorId, PrescriptionStatus status);

    // 날짜 범위로 처방전 조회
    List<Prescription> findByPrescribedDateBetweenOrderByPrescribedDateDesc(
            LocalDateTime startDate, LocalDateTime endDate);

    // 환자의 특정 기간 처방전 조회
    List<Prescription> findByPatientIdAndPrescribedDateBetweenOrderByPrescribedDateDesc(
            Long patientId, LocalDateTime startDate, LocalDateTime endDate);

    // 의사의 특정 기간 처방전 조회
    List<Prescription> findByDoctorIdAndPrescribedDateBetweenOrderByPrescribedDateDesc(
            Long doctorId, LocalDateTime startDate, LocalDateTime endDate);

    // 환자의 최근 처방전 조회
    Optional<Prescription> findFirstByPatientIdOrderByPrescribedDateDesc(Long patientId);

    // 환자의 최근 N개 처방전 조회
    List<Prescription> findTop5ByPatientIdOrderByPrescribedDateDesc(Long patientId);

    // 환자의 활성 처방전 조회 (현재 복용 중) - 이미 위에 정의되어 있으므로 제거

    // 진료기록과 연관된 처방전 조회
    Optional<Prescription> findByMedicalRecordId(Long medicalRecordId);

    // 약국 메모가 있는 처방전 조회
    List<Prescription> findByPharmacyNotesIsNotNullOrderByPrescribedDateDesc();

    // 특정 약국 메모로 검색
    @Query("SELECT p FROM Prescription p WHERE p.pharmacyNotes LIKE %:keyword% " +
            "ORDER BY p.prescribedDate DESC")
    List<Prescription> findByPharmacyNotesContaining(@Param("keyword") String keyword);

    // 지시사항으로 검색
    @Query("SELECT p FROM Prescription p WHERE p.instructions LIKE %:keyword% " +
            "ORDER BY p.prescribedDate DESC")
    List<Prescription> findByInstructionsContaining(@Param("keyword") String keyword);

    // 병원의 오늘 처방전 조회
    @Query("SELECT p FROM Prescription p WHERE p.doctor.id = :hospitalId " +
            "AND DATE(p.prescribedDate) = DATE(:today) " +
            "ORDER BY p.prescribedDate DESC")
    List<Prescription> findTodayPrescriptionsByHospital(
            @Param("hospitalId") Long hospitalId,
            @Param("today") LocalDateTime today);

    // 조제 대기 중인 처방전 조회
    List<Prescription> findByStatusOrderByPrescribedDateAsc(PrescriptionStatus status);

    // 완료되지 않은 오래된 처방전 조회 (알림용)
    @Query("SELECT p FROM Prescription p WHERE p.status = 'PRESCRIBED' " +
            "AND p.prescribedDate < :cutoffDate " +
            "ORDER BY p.prescribedDate ASC")
    List<Prescription> findOverduePrescriptions(@Param("cutoffDate") LocalDateTime cutoffDate);

    // 환자의 미완료 처방전 조회
    @Query("SELECT p FROM Prescription p WHERE p.patient.id = :patientId " +
            "AND p.status IN ('PRESCRIBED', 'DISPENSED') " +
            "ORDER BY p.prescribedDate DESC")
    List<Prescription> findIncompletePrescriptionsByPatient(@Param("patientId") Long patientId);

    // 처방전 통계 - 의사별 처방 건수
    Long countByDoctorId(Long doctorId);

    // 환자별 총 처방전 수
    Long countByPatientId(Long patientId);

    // 월별 처방전 통계
    @Query("SELECT COUNT(p) FROM Prescription p WHERE p.doctor.id = :doctorId " +
            "AND YEAR(p.prescribedDate) = :year AND MONTH(p.prescribedDate) = :month")
    Long countMonthlyPrescriptionsByDoctor(
            @Param("doctorId") Long doctorId,
            @Param("year") int year,
            @Param("month") int month);

    // 상태별 처방전 통계
    @Query("SELECT p.status, COUNT(p) FROM Prescription p " +
            "WHERE p.doctor.id = :doctorId " +
            "AND p.prescribedDate BETWEEN :startDate AND :endDate " +
            "GROUP BY p.status")
    List<Object[]> getPrescriptionStatsByStatus(
            @Param("doctorId") Long doctorId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    // 병원의 일별 처방전 통계
    @Query("SELECT DATE(p.prescribedDate), COUNT(p) FROM Prescription p " +
            "WHERE p.doctor.id = :hospitalId " +
            "AND p.prescribedDate BETWEEN :startDate AND :endDate " +
            "GROUP BY DATE(p.prescribedDate) " +
            "ORDER BY DATE(p.prescribedDate)")
    List<Object[]> getDailyPrescriptionStats(
            @Param("hospitalId") Long hospitalId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    // 환자의 처방전 준수율 계산
    @Query("SELECT COUNT(p) FROM Prescription p WHERE p.patient.id = :patientId " +
            "AND p.status = 'COMPLETED'")
    Long countCompletedPrescriptionsByPatient(@Param("patientId") Long patientId);

    @Query("SELECT COUNT(p) FROM Prescription p WHERE p.patient.id = :patientId " +
            "AND p.status IN ('COMPLETED', 'CANCELLED')")
    Long countFinishedPrescriptionsByPatient(@Param("patientId") Long patientId);

    // 특정 약물이 포함된 처방전 검색
    @Query("SELECT DISTINCT p FROM Prescription p JOIN p.medications m " +
            "WHERE m.medicationName LIKE %:medicationName% " +
            "ORDER BY p.prescribedDate DESC")
    List<Prescription> findByMedicationNameContaining(@Param("medicationName") String medicationName);

    // 환자의 특정 약물 처방 이력 조회
    @Query("SELECT DISTINCT p FROM Prescription p JOIN p.medications m " +
            "WHERE p.patient.id = :patientId " +
            "AND m.medicationName LIKE %:medicationName% " +
            "ORDER BY p.prescribedDate DESC")
    List<Prescription> findByPatientIdAndMedicationName(
            @Param("patientId") Long patientId,
            @Param("medicationName") String medicationName);

    // 병원의 특정 약물 처방 통계
    @Query("SELECT m.medicationName, COUNT(DISTINCT p) FROM Prescription p " +
            "JOIN p.medications m WHERE p.doctor.id = :hospitalId " +
            "AND p.prescribedDate BETWEEN :startDate AND :endDate " +
            "GROUP BY m.medicationName ORDER BY COUNT(DISTINCT p) DESC")
    List<Object[]> getMedicationPrescriptionStats(
            @Param("hospitalId") Long hospitalId,
            @Param("startDate") LocalDateTime startDate,
            @Param("endDate") LocalDateTime endDate);

    // 복합 검색 (환자명, 처방전번호, 약물명)
    @Query("SELECT DISTINCT p FROM Prescription p LEFT JOIN p.medications m " +
            "WHERE (:keyword IS NULL OR " +
            "p.patient.name LIKE %:keyword% OR " +
            "p.prescriptionNumber LIKE %:keyword% OR " +
            "m.medicationName LIKE %:keyword%) " +
            "AND p.doctor.id = :hospitalId " +
            "ORDER BY p.prescribedDate DESC")
    List<Prescription> searchPrescriptions(
            @Param("hospitalId") Long hospitalId,
            @Param("keyword") String keyword);
}