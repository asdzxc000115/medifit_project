package com.medifit.service;

import com.medifit.entity.Appointment;
import com.medifit.entity.Patient;
import com.medifit.entity.User;
import com.medifit.enums.AppointmentStatus;
import com.medifit.repository.AppointmentRepository;
import com.medifit.repository.PatientRepository;
import com.medifit.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class AppointmentService {

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private UserRepository userRepository;

    // 🔥 기본 CRUD 메서드들

    public List<Appointment> getAllAppointments() {
        return appointmentRepository.findAll();
    }

    public Optional<Appointment> findById(Long id) {
        return appointmentRepository.findById(id);
    }

    public List<Appointment> findByPatientId(Long patientId) {
        return appointmentRepository.findByPatientIdOrderByAppointmentDateDesc(patientId);
    }

    public List<Appointment> findByHospitalId(Long hospitalId) {
        return appointmentRepository.findByHospitalIdOrderByAppointmentDateDesc(hospitalId);
    }

    public List<Appointment> findByStatus(AppointmentStatus status) {
        return appointmentRepository.findByStatusOrderByAppointmentDateDesc(status);
    }

    public Appointment save(Appointment appointment) {
        if (appointment.getId() != null) {
            appointment.setUpdatedAt(LocalDateTime.now());
        }
        return appointmentRepository.save(appointment);
    }

    public void deleteById(Long id) {
        appointmentRepository.deleteById(id);
    }

    // 🔥 예약 시간 검증

    public boolean isTimeSlotAvailable(Long hospitalId, LocalDateTime appointmentDate, Integer duration) {
        if (duration == null) duration = 30; // 기본 30분

        LocalDateTime endTime = appointmentDate.plusMinutes(duration);

        // 해당 병원의 같은 시간대 예약 확인
        List<Appointment> conflictingAppointments = appointmentRepository
                .findByHospitalIdAndAppointmentDateBetweenOrderByAppointmentDateAsc(
                        hospitalId, appointmentDate.minusMinutes(duration), endTime);

        return conflictingAppointments.isEmpty();
    }

    // 🔥 예약 상태 관리

    public Appointment cancelAppointment(Long appointmentId) {
        Optional<Appointment> appointmentOpt = findById(appointmentId);
        if (appointmentOpt.isPresent()) {
            Appointment appointment = appointmentOpt.get();
            appointment.setStatus(AppointmentStatus.CANCELLED);
            appointment.setUpdatedAt(LocalDateTime.now());
            return save(appointment);
        }
        throw new RuntimeException("예약을 찾을 수 없습니다.");
    }

    public Appointment completeAppointment(Long appointmentId) {
        Optional<Appointment> appointmentOpt = findById(appointmentId);
        if (appointmentOpt.isPresent()) {
            Appointment appointment = appointmentOpt.get();
            appointment.setStatus(AppointmentStatus.COMPLETED);
            appointment.setUpdatedAt(LocalDateTime.now());
            return save(appointment);
        }
        throw new RuntimeException("예약을 찾을 수 없습니다.");
    }

    public Appointment confirmAppointment(Long appointmentId) {
        Optional<Appointment> appointmentOpt = findById(appointmentId);
        if (appointmentOpt.isPresent()) {
            Appointment appointment = appointmentOpt.get();
            appointment.setStatus(AppointmentStatus.CONFIRMED);
            appointment.setUpdatedAt(LocalDateTime.now());
            return save(appointment);
        }
        throw new RuntimeException("예약을 찾을 수 없습니다.");
    }

    // 🔥 다가오는 예약 조회

    public List<Appointment> findUpcomingAppointments(Long patientId) {
        LocalDateTime now = LocalDateTime.now();
        return appointmentRepository.findByPatientIdAndAppointmentDateAfterAndStatusInOrderByAppointmentDateAsc(
                patientId, now, Arrays.asList(AppointmentStatus.SCHEDULED, AppointmentStatus.CONFIRMED));
    }

    public List<Appointment> findTodayAppointments(Long hospitalId) {
        LocalDateTime startOfDay = LocalDate.now().atStartOfDay();
        LocalDateTime endOfDay = startOfDay.plusDays(1).minusSeconds(1);
        return appointmentRepository.findByHospitalIdAndAppointmentDateBetweenOrderByAppointmentDateAsc(
                hospitalId, startOfDay, endOfDay);
    }

    // 🔥 날짜별 예약 조회

    public List<Appointment> findByDateRange(LocalDateTime startDate, LocalDateTime endDate, Long hospitalId) {
        if (hospitalId != null) {
            return appointmentRepository.findByHospitalIdAndAppointmentDateBetweenOrderByAppointmentDateAsc(
                    hospitalId, startDate, endDate);
        } else {
            return appointmentRepository.findByAppointmentDateBetweenOrderByAppointmentDateAsc(startDate, endDate);
        }
    }

    // 🔥 예약 가능 시간 조회

    public List<String> getAvailableTimeSlots(Long hospitalId, String dateString) {
        try {
            LocalDate date = LocalDate.parse(dateString);

            // 기본 운영시간 설정 (9:00 - 18:00, 30분 단위)
            List<LocalTime> workingHours = generateTimeSlots(
                    LocalTime.of(9, 0),
                    LocalTime.of(18, 0),
                    30);

            // 해당 날짜의 기존 예약 조회
            LocalDateTime startOfDay = date.atStartOfDay();
            LocalDateTime endOfDay = startOfDay.plusDays(1).minusSeconds(1);

            List<Appointment> existingAppointments = appointmentRepository
                    .findByHospitalIdAndAppointmentDateBetweenAndStatusNotOrderByAppointmentDateAsc(
                            hospitalId, startOfDay, endOfDay, AppointmentStatus.CANCELLED);

            Set<LocalTime> bookedTimes = existingAppointments.stream()
                    .map(appointment -> appointment.getAppointmentDate().toLocalTime())
                    .collect(Collectors.toSet());

            // 사용 가능한 시간대 필터링
            return workingHours.stream()
                    .filter(time -> !bookedTimes.contains(time))
                    .map(time -> time.format(DateTimeFormatter.ofPattern("HH:mm")))
                    .collect(Collectors.toList());

        } catch (Exception e) {
            return new ArrayList<>();
        }
    }

    private List<LocalTime> generateTimeSlots(LocalTime start, LocalTime end, int intervalMinutes) {
        List<LocalTime> slots = new ArrayList<>();
        LocalTime current = start;

        while (current.isBefore(end)) {
            slots.add(current);
            current = current.plusMinutes(intervalMinutes);
        }

        return slots;
    }

    // 🔥 통계 및 리포트

    public Map<String, Object> getMonthlyStatistics(Long patientId, Long hospitalId) {
        LocalDateTime startDate = LocalDateTime.now().minusMonths(12);
        List<Appointment> appointments;

        if (patientId != null) {
            appointments = appointmentRepository.findByPatientIdAndCreatedAtAfterOrderByCreatedAtDesc(patientId, startDate);
        } else if (hospitalId != null) {
            appointments = appointmentRepository.findByHospitalIdAndCreatedAtAfterOrderByCreatedAtDesc(hospitalId, startDate);
        } else {
            appointments = appointmentRepository.findByCreatedAtAfterOrderByCreatedAtDesc(startDate);
        }

        Map<String, Object> stats = new HashMap<>();

        // 월별 예약 수 통계
        Map<String, Long> monthlyCount = appointments.stream()
                .collect(Collectors.groupingBy(
                        appointment -> appointment.getCreatedAt().getYear() + "-" +
                                String.format("%02d", appointment.getCreatedAt().getMonthValue()),
                        Collectors.counting()
                ));
        stats.put("monthlyAppointments", monthlyCount);

        // 상태별 통계
        Map<AppointmentStatus, Long> statusStats = appointments.stream()
                .collect(Collectors.groupingBy(Appointment::getStatus, Collectors.counting()));
        stats.put("statusStatistics", statusStats);

        // 진료과별 통계
        Map<String, Long> departmentStats = appointments.stream()
                .collect(Collectors.groupingBy(Appointment::getDepartment, Collectors.counting()));
        stats.put("departmentStatistics", departmentStats);

        // 예약 대 완료 비율
        long totalAppointments = appointments.size();
        long completedAppointments = appointments.stream()
                .mapToLong(a -> a.getStatus() == AppointmentStatus.COMPLETED ? 1 : 0)
                .sum();

        double completionRate = totalAppointments > 0 ?
                (double) completedAppointments / totalAppointments * 100 : 0;
        stats.put("completionRate", Math.round(completionRate * 100.0) / 100.0);

        return stats;
    }

    public Map<String, Object> getDashboardStatistics(Long hospitalId) {
        Map<String, Object> dashboard = new HashMap<>();

        // 오늘 예약 수
        long todayAppointments = findTodayAppointments(hospitalId).size();
        dashboard.put("todayAppointments", todayAppointments);

        // 이번 주 예약 수
        LocalDateTime startOfWeek = LocalDate.now().atStartOfDay().minusDays(LocalDate.now().getDayOfWeek().getValue() - 1);
        LocalDateTime endOfWeek = startOfWeek.plusDays(7);
        long weeklyAppointments = findByDateRange(startOfWeek, endOfWeek, hospitalId).size();
        dashboard.put("weeklyAppointments", weeklyAppointments);

        // 대기 중인 예약
        long pendingAppointments = appointmentRepository.countByHospitalIdAndStatus(hospitalId, AppointmentStatus.SCHEDULED);
        dashboard.put("pendingAppointments", pendingAppointments);

        // 취소율 (지난 30일)
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minusDays(30);
        List<Appointment> recentAppointments = appointmentRepository.findByHospitalIdAndCreatedAtAfterOrderByCreatedAtDesc(hospitalId, thirtyDaysAgo);

        long totalRecent = recentAppointments.size();
        long cancelledRecent = recentAppointments.stream()
                .mapToLong(a -> a.getStatus() == AppointmentStatus.CANCELLED ? 1 : 0)
                .sum();

        double cancellationRate = totalRecent > 0 ? (double) cancelledRecent / totalRecent * 100 : 0;
        dashboard.put("cancellationRate", Math.round(cancellationRate * 100.0) / 100.0);

        return dashboard;
    }

    // 🔥 예약 검증 및 비즈니스 로직

    public boolean canScheduleAppointment(Long patientId, LocalDateTime appointmentDate) {
        // 환자의 같은 날 예약 확인
        LocalDate appointmentDay = appointmentDate.toLocalDate();
        List<Appointment> sameDayAppointments = appointmentRepository
                .findByPatientIdAndAppointmentDateBetweenAndStatusNot(
                        patientId,
                        appointmentDay.atStartOfDay(),
                        appointmentDay.atTime(23, 59, 59),
                        AppointmentStatus.CANCELLED);

        return sameDayAppointments.isEmpty();
    }

    public boolean isWorkingHours(LocalDateTime appointmentDate) {
        LocalTime time = appointmentDate.toLocalTime();
        return time.isAfter(LocalTime.of(8, 59)) && time.isBefore(LocalTime.of(18, 1));
    }

    // 🔥 알림 및 리마인더

    public List<Appointment> getAppointmentsNeedingReminder() {
        LocalDateTime tomorrow = LocalDateTime.now().plusDays(1);
        LocalDateTime dayAfterTomorrow = tomorrow.plusDays(1);

        return appointmentRepository.findByAppointmentDateBetweenAndReminderSentFalseAndStatusIn(
                tomorrow.toLocalDate().atStartOfDay(),
                dayAfterTomorrow.toLocalDate().atStartOfDay(),
                Arrays.asList(AppointmentStatus.SCHEDULED, AppointmentStatus.CONFIRMED));
    }

    public void markReminderSent(Long appointmentId) {
        Optional<Appointment> appointmentOpt = findById(appointmentId);
        if (appointmentOpt.isPresent()) {
            Appointment appointment = appointmentOpt.get();
            appointment.setReminderSent(true);
            appointment.setReminderSentAt(LocalDateTime.now());
            save(appointment);
        }
    }

    // 🔥 예약 검색 및 필터링

    public List<Appointment> searchAppointments(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return new ArrayList<>();
        }

        return appointmentRepository.searchAppointments(keyword.trim());
    }

    public List<Appointment> findByMultipleFilters(Long patientId, Long hospitalId,
                                                   AppointmentStatus status, String department,
                                                   LocalDateTime startDate, LocalDateTime endDate) {
        return appointmentRepository.findWithFilters(patientId, hospitalId, status, department, startDate, endDate);
    }

    // 🔥 예약 패턴 분석

    public Map<String, Object> getAppointmentPatterns(Long hospitalId) {
        LocalDateTime threeMonthsAgo = LocalDateTime.now().minusMonths(3);
        List<Appointment> appointments = appointmentRepository.findByHospitalIdAndCreatedAtAfterOrderByCreatedAtDesc(hospitalId, threeMonthsAgo);

        Map<String, Object> patterns = new HashMap<>();

        // 요일별 예약 패턴
        Map<String, Long> dayOfWeekPattern = appointments.stream()
                .collect(Collectors.groupingBy(
                        appointment -> appointment.getAppointmentDate().getDayOfWeek().toString(),
                        Collectors.counting()
                ));
        patterns.put("dayOfWeekPattern", dayOfWeekPattern);

        // 시간대별 예약 패턴
        Map<String, Long> hourlyPattern = appointments.stream()
                .collect(Collectors.groupingBy(
                        appointment -> String.valueOf(appointment.getAppointmentDate().getHour()),
                        Collectors.counting()
                ));
        patterns.put("hourlyPattern", hourlyPattern);

        // 평균 예약 간격
        List<Appointment> patientAppointments = appointments.stream()
                .filter(a -> a.getPatient() != null)
                .sorted(Comparator.comparing(Appointment::getAppointmentDate))
                .collect(Collectors.toList());

        if (patientAppointments.size() > 1) {
            long totalDays = 0;
            int intervals = 0;

            for (int i = 1; i < patientAppointments.size(); i++) {
                LocalDateTime prev = patientAppointments.get(i-1).getAppointmentDate();
                LocalDateTime current = patientAppointments.get(i).getAppointmentDate();
                totalDays += java.time.Duration.between(prev, current).toDays();
                intervals++;
            }

            double averageInterval = intervals > 0 ? (double) totalDays / intervals : 0;
            patterns.put("averageAppointmentInterval", Math.round(averageInterval * 100.0) / 100.0);
        }

        return patterns;
    }

    // 🔥 예약 유효성 검사

    public List<String> validateAppointment(Appointment appointment) {
        List<String> errors = new ArrayList<>();

        if (appointment.getPatient() == null) {
            errors.add("환자 정보가 필요합니다.");
        }

        if (appointment.getHospital() == null) {
            errors.add("병원 정보가 필요합니다.");
        }

        if (appointment.getAppointmentDate() == null) {
            errors.add("예약 일시가 필요합니다.");
        } else {
            if (appointment.getAppointmentDate().isBefore(LocalDateTime.now())) {
                errors.add("과거 날짜로는 예약할 수 없습니다.");
            }

            if (!isWorkingHours(appointment.getAppointmentDate())) {
                errors.add("운영 시간 내에만 예약 가능합니다.");
            }
        }

        if (appointment.getDepartment() == null || appointment.getDepartment().trim().isEmpty()) {
            errors.add("진료과를 선택해주세요.");
        }

        return errors;
    }

    // 🔥 대량 작업

    public int cancelExpiredAppointments() {
        LocalDateTime cutoffTime = LocalDateTime.now().minusDays(1);
        List<Appointment> expiredAppointments = appointmentRepository
                .findByAppointmentDateBeforeAndStatusIn(
                        cutoffTime,
                        Arrays.asList(AppointmentStatus.SCHEDULED, AppointmentStatus.CONFIRMED));

        expiredAppointments.forEach(appointment -> {
            appointment.setStatus(AppointmentStatus.CANCELLED);
            appointment.setUpdatedAt(LocalDateTime.now());
        });

        appointmentRepository.saveAll(expiredAppointments);
        return expiredAppointments.size();
    }

    // 🔥 환자 예약 이력

    public Map<String, Object> getPatientAppointmentHistory(Long patientId) {
        List<Appointment> allAppointments = findByPatientId(patientId);

        Map<String, Object> history = new HashMap<>();
        history.put("totalAppointments", allAppointments.size());

        Map<AppointmentStatus, Long> statusBreakdown = allAppointments.stream()
                .collect(Collectors.groupingBy(Appointment::getStatus, Collectors.counting()));
        history.put("statusBreakdown", statusBreakdown);

        // 최근 예약
        Optional<Appointment> lastAppointment = allAppointments.stream()
                .filter(a -> a.getStatus() == AppointmentStatus.COMPLETED)
                .max(Comparator.comparing(Appointment::getAppointmentDate));
        history.put("lastCompletedAppointment", lastAppointment.orElse(null));

        // 다음 예약
        Optional<Appointment> nextAppointment = allAppointments.stream()
                .filter(a -> a.getAppointmentDate().isAfter(LocalDateTime.now()))
                .filter(a -> a.getStatus() != AppointmentStatus.CANCELLED)
                .min(Comparator.comparing(Appointment::getAppointmentDate));
        history.put("nextAppointment", nextAppointment.orElse(null));

        return history;
    }
}