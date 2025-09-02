package com.medifit.repository;

import com.medifit.entity.MedicalRecord;
import com.medifit.entity.Patient;
import com.medifit.enums.RecordStatus;
import com.medifit.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface MedicalRecordRepository extends JpaRepository<MedicalRecord, Long> {

    // 🔥 기본 조회 메서드들 (기존)

    // 환자별 진료기록 조회 (최신순)
    List<MedicalRecord> findByPatientOrderByVisitDateDesc(Patient patient);

    // 환자 ID로 진료기록 조회
    List<MedicalRecord> findByPatientIdOrderByVisitDateDesc(Long patientId);

    // 의사별 진료기록 조회
    List<MedicalRecord> findByDoctorOrderByVisitDateDesc(User doctor);

    // 의사 ID로 진료기록 조회
    List<MedicalRecord> findByDoctorIdOrderByVisitDateDesc(Long doctorId);

    // 상태별 진료기록 조회
    List<MedicalRecord> findByStatusOrderByVisitDateDesc(RecordStatus status);

    // 환자의 특정 상태 진료기록 조회
    List<MedicalRecord> findByPatientIdAndStatusOrderByVisitDateDesc(Long patientId, RecordStatus status);

    // 진료과별 진료기록 조회
    List<MedicalRecord> findByDepartmentOrderByVisitDateDesc(String department);

    // 환자의 진료과별 진료기록 조회
    List<MedicalRecord> findByPatientIdAndDepartmentOrderByVisitDateDesc(Long patientId, String department);

    // 환자별 최근 N개 진료기록 조회
    List<MedicalRecord> findTop10ByPatientIdOrderByVisitDateDesc(Long patientId);

    // 🔥 새로 추가된 메서드들

    // 날짜 범위 조회
    List<MedicalRecord> findByVisitDateBetweenOrderByVisitDateDesc(LocalDateTime startDate, LocalDateTime endDate);

    // 환자의 날짜 범위 조회
    List<MedicalRecord> findByPatientIdAndVisitDateBetweenOrderByVisitDateDesc(
            Long patientId, LocalDateTime startDate, LocalDateTime endDate);

    // 특정 날짜 이후의 진료기록
    List<MedicalRecord> findByVisitDateAfterOrderByVisitDateDesc(LocalDateTime afterDate);

    // 환자의 특정 날짜 이후 진료기록
    List<MedicalRecord> findByPatientIdAndVisitDateAfterOrderByVisitDateDesc(
            Long patientId, LocalDateTime afterDate);

    // 🔥 검색 기능

    // 진단명으로 검색
    List<MedicalRecord> findByDiagnosisContainingIgnoreCaseOrderByVisitDateDesc(String diagnosis);

    // 환자의 진단명 검색
    List<MedicalRecord> findByPatientIdAndDiagnosisContainingIgnoreCaseOrderByVisitDateAsc(
            Long patientId, String diagnosis);

    // 통합 검색 (진단명, 증상, 치료법, 의사 메모 등)
    @Query("SELECT mr FROM MedicalRecord mr WHERE " +
            "LOWER(mr.diagnosis) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(mr.symptoms) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(mr.treatment) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(mr.doctorNotes) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(mr.department) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> searchMedicalRecords(@Param("keyword") String keyword);

    // 🔥 상태별 통계

    // 상태별 개수
    long countByStatus(RecordStatus status);

    // 환자별 상태별 개수
    long countByPatientIdAndStatus(Long patientId, RecordStatus status);

    // 날짜 범위 내 개수
    long countByVisitDateBetween(LocalDateTime startDate, LocalDateTime endDate);

    // 🔥 날짜별 조회

    // 오늘의 진료기록 (간단한 방식)
    @Query(value = "SELECT * FROM medical_records WHERE DATE(visit_date) = CURRENT_DATE ORDER BY visit_date DESC",
            nativeQuery = true)
    List<MedicalRecord> findTodayRecords();

    // 어제의 진료기록
    @Query(value = "SELECT * FROM medical_records WHERE DATE(visit_date) = CURRENT_DATE - 1 ORDER BY visit_date DESC",
            nativeQuery = true)
    List<MedicalRecord> findYesterdayRecords();

    // 이번 주 진료기록 (간단한 날짜 범위)
    @Query("SELECT mr FROM MedicalRecord mr WHERE mr.visitDate >= :startOfWeek AND mr.visitDate < :endOfWeek " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> findThisWeekRecords(@Param("startOfWeek") LocalDateTime startOfWeek,
                                            @Param("endOfWeek") LocalDateTime endOfWeek);

    // 🔥 진료비 관련

    // 환자의 총 진료비
    @Query("SELECT SUM(mr.medicalFee) FROM MedicalRecord mr WHERE mr.patient.id = :patientId " +
            "AND mr.medicalFee IS NOT NULL")
    Optional<Long> getPatientTotalMedicalFee(@Param("patientId") Long patientId);

    // 환자의 평균 진료비
    @Query("SELECT AVG(mr.medicalFee) FROM MedicalRecord mr " +
            "WHERE mr.patient.id = :patientId AND mr.medicalFee IS NOT NULL AND mr.medicalFee > 0")
    Optional<Double> getPatientAverageMedicalFee(@Param("patientId") Long patientId);

    // 진료과별 평균 진료비
    @Query("SELECT mr.department, AVG(mr.medicalFee) FROM MedicalRecord mr " +
            "WHERE mr.medicalFee IS NOT NULL AND mr.medicalFee > 0 " +
            "GROUP BY mr.department ORDER BY AVG(mr.medicalFee) DESC")
    List<Object[]> getDepartmentAverageFees();

    // 월별 평균 진료비
    @Query("SELECT YEAR(mr.visitDate), MONTH(mr.visitDate), AVG(mr.medicalFee) " +
            "FROM MedicalRecord mr WHERE mr.medicalFee IS NOT NULL AND mr.medicalFee > 0 " +
            "AND mr.visitDate >= :startDate " +
            "GROUP BY YEAR(mr.visitDate), MONTH(mr.visitDate) " +
            "ORDER BY YEAR(mr.visitDate) DESC, MONTH(mr.visitDate) DESC")
    List<Object[]> getMonthlyAverageFees(@Param("startDate") LocalDateTime startDate);

    // 🔥 치료 효과 분석

    // 동일 진단의 치료 경과 추적
    @Query("SELECT mr FROM MedicalRecord mr WHERE mr.patient.id = :patientId " +
            "AND LOWER(mr.diagnosis) LIKE LOWER(CONCAT('%', :diagnosis, '%')) " +
            "ORDER BY mr.visitDate ASC")
    List<MedicalRecord> getPatientTreatmentProgress(@Param("patientId") Long patientId,
                                                    @Param("diagnosis") String diagnosis);

    // 치료법별 효과 분석
    @Query("SELECT mr.treatment, mr.status, COUNT(mr) FROM MedicalRecord mr " +
            "WHERE LOWER(mr.diagnosis) LIKE LOWER(CONCAT('%', :diagnosis, '%')) " +
            "AND mr.treatment IS NOT NULL " +
            "GROUP BY mr.treatment, mr.status ORDER BY mr.treatment, mr.status")
    List<Object[]> getTreatmentEffectiveness(@Param("diagnosis") String diagnosis);

    // 🔥 시간 패턴 분석

    // 요일별 방문 패턴
    @Query("SELECT DAYOFWEEK(mr.visitDate), COUNT(mr) FROM MedicalRecord mr " +
            "WHERE mr.visitDate >= :startDate " +
            "GROUP BY DAYOFWEEK(mr.visitDate) ORDER BY DAYOFWEEK(mr.visitDate)")
    List<Object[]> getDayOfWeekPattern(@Param("startDate") LocalDateTime startDate);

    // 시간대별 방문 패턴
    @Query("SELECT HOUR(mr.visitDate), COUNT(mr) FROM MedicalRecord mr " +
            "WHERE mr.visitDate >= :startDate " +
            "GROUP BY HOUR(mr.visitDate) ORDER BY HOUR(mr.visitDate)")
    List<Object[]> getHourlyPattern(@Param("startDate") LocalDateTime startDate);

    // 환자별 방문 간격 분석
    @Query("SELECT mr.visitDate FROM MedicalRecord mr WHERE mr.patient.id = :patientId " +
            "ORDER BY mr.visitDate ASC")
    List<LocalDateTime> getPatientVisitDates(@Param("patientId") Long patientId);

    // 🔥 고급 분석

    // 재방문율 분석 (같은 진단으로 다시 온 환자)
    @Query("SELECT mr.diagnosis, COUNT(DISTINCT mr.patient.id) as patients, COUNT(mr) as visits " +
            "FROM MedicalRecord mr WHERE mr.visitDate >= :startDate " +
            "GROUP BY mr.diagnosis HAVING COUNT(mr) > COUNT(DISTINCT mr.patient.id) " +
            "ORDER BY (COUNT(mr) * 1.0 / COUNT(DISTINCT mr.patient.id)) DESC")
    List<Object[]> getRevisitAnalysis(@Param("startDate") LocalDateTime startDate);

    // 치료 기간 분석
    @Query("SELECT mr.patient.id, mr.diagnosis, MIN(mr.visitDate) as firstVisit, MAX(mr.visitDate) as lastVisit, COUNT(mr) as visitCount " +
            "FROM MedicalRecord mr WHERE mr.visitDate >= :startDate " +
            "GROUP BY mr.patient.id, mr.diagnosis HAVING COUNT(mr) > 1 " +
            "ORDER BY (MAX(mr.visitDate) - MIN(mr.visitDate)) DESC")
    List<Object[]> getTreatmentDurationAnalysis(@Param("startDate") LocalDateTime startDate);

    // 🔥 데이터 품질 확인

    // 필수 필드가 누락된 기록
    @Query("SELECT mr FROM MedicalRecord mr WHERE " +
            "mr.diagnosis IS NULL OR mr.diagnosis = '' OR " +
            "mr.department IS NULL OR mr.department = '' OR " +
            "mr.visitDate IS NULL " +
            "ORDER BY mr.createdAt DESC")
    List<MedicalRecord> findIncompleteRecords();

    // AI 요약이 없는 기록
    List<MedicalRecord> findByAiSummaryIsNullOrderByVisitDateDesc();

    // 진료비가 0원인 기록 (의심 케이스)
    List<MedicalRecord> findByMedicalFeeIsNullOrMedicalFee(Integer medicalFee);

    // 🔥 병원별 분석

    // 병원별 날짜 범위 진료기록 조회
    @Query("SELECT mr FROM MedicalRecord mr WHERE mr.doctor.id = :hospitalId " +
            "AND mr.visitDate BETWEEN :startDate AND :endDate " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> findByHospitalIdAndVisitDateBetween(@Param("hospitalId") Long hospitalId,
                                                            @Param("startDate") LocalDateTime startDate,
                                                            @Param("endDate") LocalDateTime endDate);

    // 병원별 환자 수
    @Query("SELECT COUNT(DISTINCT mr.patient.id) FROM MedicalRecord mr WHERE mr.doctor.id = :hospitalId")
    long countDistinctPatientsByHospital(@Param("hospitalId") Long hospitalId);

    // 🔥 환자 상태 추적

    // 환자의 최근 진료 상태
    @Query("SELECT mr FROM MedicalRecord mr WHERE mr.patient.id = :patientId " +
            "ORDER BY mr.visitDate DESC LIMIT 1")
    Optional<MedicalRecord> findLatestByPatientId(@Param("patientId") Long patientId);

    // 만성 질환 환자 식별 (같은 진단으로 3회 이상 방문)
    @Query("SELECT mr.patient.id, mr.diagnosis, COUNT(mr) as visitCount " +
            "FROM MedicalRecord mr GROUP BY mr.patient.id, mr.diagnosis " +
            "HAVING COUNT(mr) >= 3 ORDER BY COUNT(mr) DESC")
    List<Object[]> findChronicPatients();

    // 🔥 응급 상황 분석

    // 응급실 방문 기록
    @Query("SELECT mr FROM MedicalRecord mr WHERE LOWER(mr.department) LIKE '%응급%' " +
            "OR LOWER(mr.roomNumber) LIKE '%응급%' " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> findEmergencyRecords();

    // 야간 진료 기록
    @Query("SELECT mr FROM MedicalRecord mr WHERE HOUR(mr.visitDate) >= 18 OR HOUR(mr.visitDate) <= 8 " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> findAfterHoursRecords();

    // 🔥 의료진 성과 분석

    // 의사별 환자 만족도 (재방문율 기반) - hospitalName 사용
    @Query("SELECT d.id, " +
            "COALESCE(d.hospitalName, d.username) as doctorName, " +
            "COUNT(DISTINCT mr.patient.id) as uniquePatients, " +
            "COUNT(mr) as totalVisits, " +
            "(COUNT(mr) * 1.0 / COUNT(DISTINCT mr.patient.id)) as revisitRate " +
            "FROM MedicalRecord mr JOIN mr.doctor d " +
            "WHERE mr.visitDate >= :startDate " +
            "GROUP BY d.id, d.hospitalName, d.username " +
            "HAVING COUNT(DISTINCT mr.patient.id) >= 10 " +
            "ORDER BY revisitRate DESC")
    List<Object[]> getDoctorRevisitRates(@Param("startDate") LocalDateTime startDate);

    // 의사별 치료 효과 (완료 상태 비율) - hospitalName 사용
    @Query("SELECT d.id, " +
            "COALESCE(d.hospitalName, d.username) as doctorName, " +
            "SUM(CASE WHEN mr.status = 'COMPLETED' THEN 1 ELSE 0 END) as completed, " +
            "COUNT(mr) as total, " +
            "(SUM(CASE WHEN mr.status = 'COMPLETED' THEN 1 ELSE 0 END) * 1.0 / COUNT(mr)) as completionRate " +
            "FROM MedicalRecord mr JOIN mr.doctor d " +
            "WHERE mr.visitDate >= :startDate " +
            "GROUP BY d.id, d.hospitalName, d.username " +
            "HAVING COUNT(mr) >= 10 " +
            "ORDER BY completionRate DESC")
    List<Object[]> getDoctorCompletionRates(@Param("startDate") LocalDateTime startDate);

    // 🔥 환자 전용 - 내 의료기록

    // 내 의료기록 조회 (환자 앱용)
    @Query("SELECT mr FROM MedicalRecord mr WHERE mr.patient.id = :patientId " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> findMyMedicalRecords(@Param("patientId") Long patientId);

    // 내 최근 진료기록
    @Query("SELECT mr FROM MedicalRecord mr WHERE mr.patient.id = :patientId " +
            "ORDER BY mr.visitDate DESC LIMIT 5")
    List<MedicalRecord> findMyRecentRecords(@Param("patientId") Long patientId);

    // 내 특정 진단 이력
    @Query("SELECT mr FROM MedicalRecord mr WHERE mr.patient.id = :patientId " +
            "AND LOWER(mr.diagnosis) LIKE LOWER(CONCAT('%', :diagnosis, '%')) " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> findMyRecordsByDiagnosis(@Param("patientId") Long patientId,
                                                 @Param("diagnosis") String diagnosis);

    // 내 진료비 총합
    @Query("SELECT SUM(mr.medicalFee) FROM MedicalRecord mr WHERE mr.patient.id = :patientId " +
            "AND mr.medicalFee IS NOT NULL")
    Optional<Long> getMyTotalMedicalFee(@Param("patientId") Long patientId);

    // 🔥 환자별 활성도 추적

    // 특정 기간 동안 활성 환자 수
    @Query("SELECT COUNT(DISTINCT mr.patient.id) FROM MedicalRecord mr " +
            "WHERE mr.visitDate >= :startDate")
    long countDistinctPatientByVisitDateAfter(@Param("startDate") LocalDateTime startDate);

    // 🔥 서비스에서 사용하는 누락된 메서드들

    // 복합 필터링 (진단명과 치료법 동시 검색)
    @Query("SELECT mr FROM MedicalRecord mr WHERE " +
            "(:patientId IS NULL OR mr.patient.id = :patientId) AND " +
            "(:department IS NULL OR LOWER(mr.department) = LOWER(:department)) AND " +
            "(:diagnosis IS NULL OR LOWER(mr.diagnosis) LIKE LOWER(CONCAT('%', :diagnosis, '%'))) AND " +
            "(:startDate IS NULL OR mr.visitDate >= :startDate) AND " +
            "(:endDate IS NULL OR mr.visitDate <= :endDate) " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> findWithFilters(@Param("patientId") Long patientId,
                                        @Param("department") String department,
                                        @Param("diagnosis") String diagnosis,
                                        @Param("startDate") LocalDateTime startDate,
                                        @Param("endDate") LocalDateTime endDate);

    // 진단명과 치료법으로 동시 검색
    @Query("SELECT mr FROM MedicalRecord mr WHERE " +
            "LOWER(mr.diagnosis) LIKE LOWER(CONCAT('%', :diagnosis, '%')) AND " +
            "LOWER(mr.treatment) LIKE LOWER(CONCAT('%', :treatment, '%')) " +
            "ORDER BY mr.visitDate DESC")
    List<MedicalRecord> findByDiagnosisContainingIgnoreCaseAndTreatmentContainingIgnoreCaseOrderByVisitDateDesc(
            @Param("diagnosis") String diagnosis, @Param("treatment") String treatment);
}