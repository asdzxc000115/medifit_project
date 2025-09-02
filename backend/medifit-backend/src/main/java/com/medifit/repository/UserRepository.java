package com.medifit.repository;

import com.medifit.entity.User;
import com.medifit.enums.UserType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    // 기본 조회 메서드들
    Optional<User> findByUsername(String username);
    Optional<User> findByKakaoId(String kakaoId);
    List<User> findByUserType(UserType userType);
    List<User> findByUserTypeOrderByCreatedAtDesc(UserType userType);

    // 중복 체크 메서드들
    boolean existsByUsername(String username);
    boolean existsByPhoneNumber(String phoneNumber);
    boolean existsByBusinessNumber(String businessNumber);
    boolean existsByHospitalName(String hospitalName);

    // 통계 메서드들
    long countByUserType(UserType userType);

    // 환자 검색 메서드들 (User 엔티티의 실제 필드 사용)
    @Query("SELECT u FROM User u WHERE u.userType = 'PATIENT' AND " +
            "(LOWER(u.patientName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(u.address) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "u.phoneNumber LIKE CONCAT('%', :keyword, '%')) " +
            "ORDER BY u.createdAt DESC")
    List<User> searchPatients(@Param("keyword") String keyword);

    // 혈액형별 환자 검색
    List<User> findByUserTypeAndBloodType(UserType userType, String bloodType);

    // 나이 범위별 환자 검색
    @Query("SELECT u FROM User u WHERE u.userType = 'PATIENT' AND " +
            "u.age BETWEEN :minAge AND :maxAge " +
            "ORDER BY u.age ASC")
    List<User> findPatientsByAgeRange(@Param("minAge") int minAge, @Param("maxAge") int maxAge);

    // 환자 이름으로 검색 (환자 전용 앱용)
    @Query("SELECT u FROM User u WHERE u.userType = 'PATIENT' AND " +
            "LOWER(u.patientName) LIKE LOWER(CONCAT('%', :name, '%')) " +
            "ORDER BY u.patientName ASC")
    List<User> findPatientsByName(@Param("name") String name);

    // 활성 환자 조회
    @Query("SELECT u FROM User u WHERE u.userType = 'PATIENT' AND u.active = true " +
            "ORDER BY u.createdAt DESC")
    List<User> findActivePatients();

    // 최근 가입한 환자들
    @Query("SELECT u FROM User u WHERE u.userType = 'PATIENT' " +
            "ORDER BY u.createdAt DESC LIMIT 10")
    List<User> findRecentPatients();
}