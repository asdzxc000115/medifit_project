package com.medifit.repository;

import com.medifit.entity.Patient;
import com.medifit.enums.BloodType;
import com.medifit.enums.Gender;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PatientRepository extends JpaRepository<Patient, Long> {

    // 🔥 기본 조회 메서드들

    // 모든 환자 최신순 조회
    List<Patient> findAllByOrderByCreatedAtDesc();

    // 환자번호로 조회
    Optional<Patient> findByPatientNumber(String patientNumber);

    // 전화번호로 조회
    Optional<Patient> findByPhoneNumber(String phoneNumber);

    // 전화번호 중복 체크
    boolean existsByPhoneNumber(String phoneNumber);

    // 이름으로 조회
    List<Patient> findByNameContainingIgnoreCaseOrderByCreatedAtDesc(String name);

    // 🔥 환자 검색 기능

    // 통합 검색 (이름, 전화번호, 주소로 검색)
    @Query("SELECT p FROM Patient p WHERE " +
            "LOWER(p.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "p.phoneNumber LIKE CONCAT('%', :keyword, '%') OR " +
            "LOWER(p.address) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "p.patientNumber LIKE CONCAT('%', :keyword, '%') " +
            "ORDER BY p.createdAt DESC")
    List<Patient> searchPatients(@Param("keyword") String keyword);

    // 혈액형별 환자 조회
    List<Patient> findByBloodTypeOrderByCreatedAtDesc(BloodType bloodType);

    // 문자열로 혈액형 조회 (호환성)
    @Query("SELECT p FROM Patient p WHERE CAST(p.bloodType AS string) = :bloodType ORDER BY p.createdAt DESC")
    List<Patient> findByBloodTypeOrderByCreatedAtDesc(@Param("bloodType") String bloodType);

    // 성별로 환자 조회
    List<Patient> findByGenderOrderByCreatedAtDesc(Gender gender);

    // 나이 범위별 환자 조회 (생년월일 기준)
    @Query("SELECT p FROM Patient p WHERE " +
            "YEAR(CURRENT_DATE) - YEAR(p.birthDate) BETWEEN :minAge AND :maxAge " +
            "ORDER BY p.birthDate DESC")
    List<Patient> findPatientsByAgeRange(@Param("minAge") int minAge, @Param("maxAge") int maxAge);

    // 🔥 병원별 조회

    // 병원별 환자 조회
    List<Patient> findByHospitalIdOrderByCreatedAtDesc(Long hospitalId);

    // 병원과 성별로 환자 조회
    List<Patient> findByHospitalIdAndGenderOrderByCreatedAtDesc(Long hospitalId, Gender gender);

    // 🔥 날짜별 조회

    // 특정 기간에 등록된 환자 조회
    List<Patient> findByCreatedAtBetweenOrderByCreatedAtDesc(LocalDateTime startDate, LocalDateTime endDate);

    // 오늘 등록된 환자 수 조회
    long countByCreatedAtBetween(LocalDateTime startOfDay, LocalDateTime endOfDay);

    // 특정 날짜에 등록된 환자 조회
    @Query("SELECT p FROM Patient p WHERE DATE(p.createdAt) = :date ORDER BY p.createdAt DESC")
    List<Patient> findByCreatedAtDate(@Param("date") LocalDate date);

    // 🔥 제한된 수량 조회

    // 최근 등록된 환자들 (상위 N명)
    List<Patient> findTop10ByOrderByCreatedAtDesc();

    // 특정 병원의 최근 환자들
    List<Patient> findTop10ByHospitalIdOrderByCreatedAtDesc(Long hospitalId);

    // 🔥 알레르기별 조회

    // 특정 알레르기가 있는 환자 조회
    @Query("SELECT p FROM Patient p WHERE p.allergies IS NOT NULL AND " +
            "LOWER(p.allergies) LIKE LOWER(CONCAT('%', :allergy, '%')) " +
            "ORDER BY p.createdAt DESC")
    List<Patient> findByAllergiesContaining(@Param("allergy") String allergy);

    // 알레르기가 없는 환자 조회
    @Query("SELECT p FROM Patient p WHERE p.allergies IS NULL OR p.allergies = '' OR " +
            "LOWER(p.allergies) = '없음' ORDER BY p.createdAt DESC")
    List<Patient> findPatientsWithoutAllergies();

    // 🔥 의료기록별 조회

    // 특정 진단명을 받은 환자 조회 (의료기록을 통해)
    @Query("SELECT DISTINCT p FROM Patient p JOIN p.medicalRecords mr WHERE " +
            "LOWER(mr.diagnosis) LIKE LOWER(CONCAT('%', :diagnosis, '%')) " +
            "ORDER BY p.createdAt DESC")
    List<Patient> findPatientsByDiagnosis(@Param("diagnosis") String diagnosis);

    // 특정 기간 동안 방문한 환자 조회
    @Query("SELECT DISTINCT p FROM Patient p JOIN p.medicalRecords mr WHERE " +
            "mr.visitDate BETWEEN :startDate AND :endDate " +
            "ORDER BY mr.visitDate DESC")
    List<Patient> findPatientsVisitedBetween(@Param("startDate") LocalDateTime startDate,
                                             @Param("endDate") LocalDateTime endDate);

    // 🔥 통계용 쿼리

    // 성별 통계
    @Query("SELECT p.gender, COUNT(p) FROM Patient p GROUP BY p.gender")
    List<Object[]> getPatientCountByGender();

    // 연령대별 통계 (10세 단위)
    @Query("SELECT FLOOR((YEAR(CURRENT_DATE) - YEAR(p.birthDate)) / 10) * 10 AS ageGroup, COUNT(p) " +
            "FROM Patient p GROUP BY FLOOR((YEAR(CURRENT_DATE) - YEAR(p.birthDate)) / 10) " +
            "ORDER BY ageGroup")
    List<Object[]> getPatientCountByAgeGroup();

    // 혈액형별 통계
    @Query("SELECT p.bloodType, COUNT(p) FROM Patient p GROUP BY p.bloodType ORDER BY COUNT(p) DESC")
    List<Object[]> getPatientCountByBloodType();

    // 월별 신규 환자 통계 (최근 12개월)
    @Query("SELECT YEAR(p.createdAt), MONTH(p.createdAt), COUNT(p) FROM Patient p " +
            "WHERE p.createdAt >= :startDate " +
            "GROUP BY YEAR(p.createdAt), MONTH(p.createdAt) " +
            "ORDER BY YEAR(p.createdAt) DESC, MONTH(p.createdAt) DESC")
    List<Object[]> getMonthlyPatientRegistrationStats(@Param("startDate") LocalDateTime startDate);

    // 🔥 고급 검색 기능

    // 복합 조건 검색
    @Query("SELECT p FROM Patient p WHERE " +
            "(:name IS NULL OR LOWER(p.name) LIKE LOWER(CONCAT('%', :name, '%'))) AND " +
            "(:phoneNumber IS NULL OR p.phoneNumber LIKE CONCAT('%', :phoneNumber, '%')) AND " +
            "(:bloodType IS NULL OR CAST(p.bloodType AS string) = :bloodType) AND " +
            "(:gender IS NULL OR p.gender = :gender) AND " +
            "(:hospitalId IS NULL OR p.hospital.id = :hospitalId) " +
            "ORDER BY p.createdAt DESC")
    List<Patient> findPatientsWithFilters(@Param("name") String name,
                                          @Param("phoneNumber") String phoneNumber,
                                          @Param("bloodType") String bloodType,
                                          @Param("gender") Gender gender,
                                          @Param("hospitalId") Long hospitalId);
}