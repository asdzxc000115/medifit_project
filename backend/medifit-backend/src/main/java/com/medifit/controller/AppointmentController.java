package com.medifit.controller;

import com.medifit.entity.Appointment;
import com.medifit.service.AppointmentService;
import com.medifit.enums.AppointmentStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/appointments")
@CrossOrigin(origins = "*")
public class AppointmentController {

    @Autowired
    private AppointmentService appointmentService;

    // 🔥 모든 예약 조회
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllAppointments(
            @RequestParam(required = false) Long patientId,
            @RequestParam(required = false) Long hospitalId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String department) {

        Map<String, Object> response = new HashMap<>();

        try {
            List<Appointment> appointments;

            if (patientId != null) {
                appointments = appointmentService.findByPatientId(patientId);
                response.put("message", "환자별 예약 내역을 조회했습니다.");
            } else if (hospitalId != null) {
                appointments = appointmentService.findByHospitalId(hospitalId);
                response.put("message", "병원별 예약 내역을 조회했습니다.");
            } else if (status != null) {
                AppointmentStatus appointmentStatus = AppointmentStatus.valueOf(status.toUpperCase());
                appointments = appointmentService.findByStatus(appointmentStatus);
                response.put("message", status + " 상태의 예약을 조회했습니다.");
            } else {
                appointments = appointmentService.getAllAppointments();
                response.put("message", "전체 예약 내역을 조회했습니다.");
            }

            response.put("success", true);
            response.put("data", appointments);
            response.put("total", appointments.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 예약 상세 조회
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getAppointmentById(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Appointment> appointment = appointmentService.findById(id);

            if (appointment.isPresent()) {
                response.put("success", true);
                response.put("message", "예약 정보를 조회했습니다.");
                response.put("data", appointment.get());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "해당 ID의 예약을 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 예약 생성
    @PostMapping
    public ResponseEntity<Map<String, Object>> createAppointment(@RequestBody Appointment appointment) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 필수 필드 검증
            if (appointment.getPatient() == null) {
                response.put("success", false);
                response.put("message", "환자 정보는 필수입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            if (appointment.getHospital() == null) {
                response.put("success", false);
                response.put("message", "병원 정보는 필수입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            if (appointment.getAppointmentDate() == null) {
                response.put("success", false);
                response.put("message", "예약 일시는 필수입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            // 과거 날짜 예약 방지
            if (appointment.getAppointmentDate().isBefore(LocalDateTime.now())) {
                response.put("success", false);
                response.put("message", "과거 날짜로는 예약할 수 없습니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            // 예약 시간 중복 체크
            if (appointmentService.isTimeSlotAvailable(appointment.getHospital().getId(),
                    appointment.getAppointmentDate(), appointment.getEstimatedDuration())) {
                response.put("success", false);
                response.put("message", "해당 시간대에 이미 예약이 있습니다.");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
            }

            Appointment savedAppointment = appointmentService.save(appointment);

            response.put("success", true);
            response.put("message", "예약이 성공적으로 생성되었습니다.");
            response.put("data", savedAppointment);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 생성 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 예약 수정
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateAppointment(@PathVariable Long id, @RequestBody Appointment appointment) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Appointment> existingAppointment = appointmentService.findById(id);

            if (!existingAppointment.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 예약을 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            appointment.setId(id);
            Appointment updatedAppointment = appointmentService.save(appointment);

            response.put("success", true);
            response.put("message", "예약이 성공적으로 수정되었습니다.");
            response.put("data", updatedAppointment);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 수정 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 예약 취소
    @PatchMapping("/{id}/cancel")
    public ResponseEntity<Map<String, Object>> cancelAppointment(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Appointment> appointmentOpt = appointmentService.findById(id);

            if (!appointmentOpt.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 예약을 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            Appointment cancelledAppointment = appointmentService.cancelAppointment(id);

            response.put("success", true);
            response.put("message", "예약이 취소되었습니다.");
            response.put("data", cancelledAppointment);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 취소 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 예약 완료 처리
    @PatchMapping("/{id}/complete")
    public ResponseEntity<Map<String, Object>> completeAppointment(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Appointment completedAppointment = appointmentService.completeAppointment(id);

            response.put("success", true);
            response.put("message", "예약이 완료 처리되었습니다.");
            response.put("data", completedAppointment);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 완료 처리 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자의 다가오는 예약 조회
    @GetMapping("/patient/{patientId}/upcoming")
    public ResponseEntity<Map<String, Object>> getUpcomingAppointments(@PathVariable Long patientId) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<Appointment> upcomingAppointments = appointmentService.findUpcomingAppointments(patientId);

            response.put("success", true);
            response.put("message", "다가오는 예약을 조회했습니다.");
            response.put("data", upcomingAppointments);
            response.put("total", upcomingAppointments.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 날짜별 예약 조회
    @GetMapping("/date")
    public ResponseEntity<Map<String, Object>> getAppointmentsByDate(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate,
            @RequestParam(required = false) Long hospitalId) {

        Map<String, Object> response = new HashMap<>();

        try {
            List<Appointment> appointments = appointmentService.findByDateRange(startDate, endDate, hospitalId);

            response.put("success", true);
            response.put("message", "날짜별 예약을 조회했습니다.");
            response.put("data", appointments);
            response.put("total", appointments.size());
            response.put("startDate", startDate);
            response.put("endDate", endDate);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "날짜별 예약 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 예약 가능 시간 조회
    @GetMapping("/available-times")
    public ResponseEntity<Map<String, Object>> getAvailableTimes(
            @RequestParam Long hospitalId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) String date) {

        Map<String, Object> response = new HashMap<>();

        try {
            List<String> availableTimes = appointmentService.getAvailableTimeSlots(hospitalId, date);

            response.put("success", true);
            response.put("message", "예약 가능 시간을 조회했습니다.");
            response.put("data", availableTimes);
            response.put("date", date);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 가능 시간 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 예약 통계 (월별)
    @GetMapping("/stats/monthly")
    public ResponseEntity<Map<String, Object>> getMonthlyAppointmentStats(
            @RequestParam(required = false) Long patientId,
            @RequestParam(required = false) Long hospitalId) {

        Map<String, Object> response = new HashMap<>();

        try {
            Map<String, Object> stats = appointmentService.getMonthlyStatistics(patientId, hospitalId);

            response.put("success", true);
            response.put("message", "월별 예약 통계를 조회했습니다.");
            response.put("data", stats);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 통계 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}