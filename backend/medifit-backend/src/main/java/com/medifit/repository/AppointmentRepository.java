package com.medifit.repository;

import com.medifit.entity.Appointment;
import com.medifit.enums.AppointmentStatus;
import com.medifit.entity.Patient;
import com.medifit.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface AppointmentRepository extends JpaRepository<Appointment, Long> {

    // 🔥 기본 조회 메서드들

    // 환자별 예약 조회
    List<Appointment> findByPatientOrderByAppointmentDateDesc(Patient patient);

    // 환자 ID로 예약 조회
    List<Appointment> findByPatientIdOrderByAppointmentDateDesc(Long patientId);

    // 병원별 예약 조회
    List<Appointment> findByHospitalOrderByAppointmentDateDesc(User hospital);

    // 병원 ID로 예약 조회
    List<Appointment> findByHospitalIdOrderByAppointmentDateDesc(Long hospitalId);

    // 상태별 예약 조회
    List<Appointment> findByStatusOrderByAppointmentDateDesc(AppointmentStatus status);

    // 병원의 특정 상태 예약 조회
    List<Appointment> findByHospitalIdAndStatusOrderByAppointmentDateDesc(Long hospitalId, AppointmentStatus status);

    // 환자의 특정 상태 예약 조회
    List<Appointment> findByPatientIdAndStatusOrderByAppointmentDateDesc(Long patientId, AppointmentStatus status);

    // 🔥 날짜 범위 조회 (기존)

    // 날짜 범위로 예약 조회
    List<Appointment> findByAppointmentDateBetweenOrderByAppointmentDateAsc(
            LocalDateTime startDate, LocalDateTime endDate);

    // 병원의 특정 날짜 예약 조회
    List<Appointment> findByHospitalIdAndAppointmentDateBetweenOrderByAppointmentDateAsc(
            Long hospitalId, LocalDateTime startDate, LocalDateTime endDate);

    // 🔥 새로 추가된 메서드들

    // 상태를 제외한 날짜 범위 조회
    List<Appointment> findByHospitalIdAndAppointmentDateBetweenAndStatusNotOrderByAppointmentDateAsc(
            Long hospitalId, LocalDateTime startDate, LocalDateTime endDate, AppointmentStatus excludeStatus);

    // 환자의 특정 날짜 범위 예약 (상태 제외)
    List<Appointment> findByPatientIdAndAppointmentDateBetweenAndStatusNot(
            Long patientId, LocalDateTime startDate, LocalDateTime endDate, AppointmentStatus excludeStatus);

    // 다가오는 예약 (여러 상태)
    List<Appointment> findByPatientIdAndAppointmentDateAfterAndStatusInOrderByAppointmentDateAsc(
            Long patientId, LocalDateTime afterDate, List<AppointmentStatus> statuses);

    // 특정 날짜 이후 생성된 예약 (환자별)
    List<Appointment> findByPatientIdAndCreatedAtAfterOrderByCreatedAtDesc(Long patientId, LocalDateTime createdAfter);

    // 특정 날짜 이후 생성된 예약 (병원별)
    List<Appointment> findByHospitalIdAndCreatedAtAfterOrderByCreatedAtDesc(Long hospitalId, LocalDateTime createdAfter);

    // 전체 - 특정 날짜 이후 생성된 예약
    List<Appointment> findByCreatedAtAfterOrderByCreatedAtDesc(LocalDateTime createdAfter);

    // 🔥 알림 관련

    // 알림이 필요한 예약 (리마인더)
    List<Appointment> findByAppointmentDateBetweenAndReminderSentFalseAndStatusIn(
            LocalDateTime startDate, LocalDateTime endDate, List<AppointmentStatus> statuses);

    // 🔥 통계 관련

    // 병원별 상태별 개수
    long countByHospitalIdAndStatus(Long hospitalId, AppointmentStatus status);

    // 환자별 상태별 개수
    long countByPatientIdAndStatus(Long patientId, AppointmentStatus status);

    // 날짜 범위 내 개수
    long countByAppointmentDateBetween(LocalDateTime startDate, LocalDateTime endDate);

    // 🔥 검색 기능

    // 통합 검색
    @Query("SELECT a FROM Appointment a WHERE " +
            "LOWER(a.patient.name) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(a.hospital.hospitalName) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(a.department) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(a.symptoms) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
            "LOWER(a.notes) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "ORDER BY a.appointmentDate DESC")
    List<Appointment> searchAppointments(@Param("keyword") String keyword);

    // 🔥 복합 필터링

    // 다중 조건 필터링
    @Query("SELECT a FROM Appointment a WHERE " +
            "(:patientId IS NULL OR a.patient.id = :patientId) AND " +
            "(:hospitalId IS NULL OR a.hospital.id = :hospitalId) AND " +
            "(:status IS NULL OR a.status = :status) AND " +
            "(:department IS NULL OR LOWER(a.department) = LOWER(:department)) AND " +
            "(:startDate IS NULL OR a.appointmentDate >= :startDate) AND " +
            "(:endDate IS NULL OR a.appointmentDate <= :endDate) " +
            "ORDER BY a.appointmentDate DESC")
    List<Appointment> findWithFilters(@Param("patientId") Long patientId,
                                      @Param("hospitalId") Long hospitalId,
                                      @Param("status") AppointmentStatus status,
                                      @Param("department") String department,
                                      @Param("startDate") LocalDateTime startDate,
                                      @Param("endDate") LocalDateTime endDate);

    // 🔥 시간 충돌 체크

    // 시간대 충돌 검사
    @Query("SELECT a FROM Appointment a WHERE a.hospital.id = :hospitalId AND " +
            "a.appointmentDate BETWEEN :startTime AND :endTime AND " +
            "a.status NOT IN ('CANCELLED') " +
            "ORDER BY a.appointmentDate ASC")
    List<Appointment> findConflictingAppointments(@Param("hospitalId") Long hospitalId,
                                                  @Param("startTime") LocalDateTime startTime,
                                                  @Param("endTime") LocalDateTime endTime);

    // 🔥 만료/과거 예약 관리

    // 과거 예약 (특정 상태들)
    List<Appointment> findByAppointmentDateBeforeAndStatusIn(
            LocalDateTime beforeDate, List<AppointmentStatus> statuses);

    // 🔥 환자 전용 - 내 예약 조회

    // 환자의 다가오는 예약 (환자 앱용)
    @Query("SELECT a FROM Appointment a WHERE a.patient.id = :patientId " +
            "AND a.appointmentDate > CURRENT_TIMESTAMP " +
            "AND a.status NOT IN ('CANCELLED') " +
            "ORDER BY a.appointmentDate ASC")
    List<Appointment> findMyUpcomingAppointments(@Param("patientId") Long patientId);

    // 환자의 예약 히스토리 (환자 앱용)
    @Query("SELECT a FROM Appointment a WHERE a.patient.id = :patientId " +
            "AND a.appointmentDate < CURRENT_TIMESTAMP " +
            "ORDER BY a.appointmentDate DESC")
    List<Appointment> findMyAppointmentHistory(@Param("patientId") Long patientId);

    // 환자의 특정 병원 예약들
    @Query("SELECT a FROM Appointment a WHERE a.patient.id = :patientId " +
            "AND a.hospital.id = :hospitalId " +
            "ORDER BY a.appointmentDate DESC")
    List<Appointment> findMyAppointmentsByHospital(@Param("patientId") Long patientId,
                                                   @Param("hospitalId") Long hospitalId);
}