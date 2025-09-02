package com.medifit.controller;

import com.medifit.dto.ApiResponse;
import com.medifit.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    /**
     * 복약 알림 수동 전송
     */
    @PostMapping("/medication/send")
    public ResponseEntity<ApiResponse<Void>> sendMedicationReminders(
            @RequestParam String timeSlot) {

        try {
            notificationService.sendMedicationReminders(timeSlot);

            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage(timeSlot + " 복약 알림이 성공적으로 전송되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("복약 알림 전송에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 병원 공지사항 알림 전송
     */
    @PostMapping("/hospital/notice")
    public ResponseEntity<ApiResponse<Void>> sendHospitalNotice(
            @RequestBody Map<String, Object> noticeData) {

        try {
            String title = (String) noticeData.get("title");
            String content = (String) noticeData.get("content");
            List<Long> patientIds = (List<Long>) noticeData.get("patientIds");

            if (title == null || content == null || patientIds == null || patientIds.isEmpty()) {
                ApiResponse<Void> response = new ApiResponse<>();
                response.setSuccess(false);
                response.setMessage("제목, 내용, 대상 환자 목록이 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }

            // 실제 구현에서는 PatientService를 통해 환자 정보를 조회
            // List<Patient> patients = patientService.getPatientsByIds(patientIds);
            // notificationService.sendHospitalNotice(patients, title, content);

            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("병원 공지사항이 성공적으로 전송되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("공지사항 전송에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 개별 환자 응급 알림 전송
     */
    @PostMapping("/emergency/{patientId}")
    public ResponseEntity<ApiResponse<Void>> sendEmergencyAlert(
            @PathVariable Long patientId,
            @RequestBody Map<String, String> alertData) {

        try {
            String alertMessage = alertData.get("message");

            if (alertMessage == null || alertMessage.trim().isEmpty()) {
                ApiResponse<Void> response = new ApiResponse<>();
                response.setSuccess(false);
                response.setMessage("응급 알림 메시지가 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }

            // 실제 구현에서는 PatientService를 통해 환자 정보를 조회
            // Patient patient = patientService.getPatient(patientId);
            // notificationService.sendEmergencyAlert(patient, alertMessage);

            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("응급 알림이 성공적으로 전송되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("응급 알림 전송에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 건강 체크 알림 전송 (정기 검진 안내)
     */
    @PostMapping("/health-check/{patientId}")
    public ResponseEntity<ApiResponse<Void>> sendHealthCheckReminder(
            @PathVariable Long patientId,
            @RequestBody Map<String, String> reminderData) {

        try {
            String lastVisitDate = reminderData.get("lastVisitDate");

            if (lastVisitDate == null || lastVisitDate.trim().isEmpty()) {
                ApiResponse<Void> response = new ApiResponse<>();
                response.setSuccess(false);
                response.setMessage("마지막 방문 날짜 정보가 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }

            // 실제 구현에서는 PatientService를 통해 환자 정보를 조회
            // Patient patient = patientService.getPatient(patientId);
            // notificationService.sendHealthCheckReminder(patient, lastVisitDate);

            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("건강 체크 알림이 성공적으로 전송되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("건강 체크 알림 전송에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 알림 설정 조회
     */
    @GetMapping("/settings/{patientId}")
    public ResponseEntity<ApiResponse<Map<String, Boolean>>> getNotificationSettings(
            @PathVariable Long patientId) {

        try {
            // 실제 구현에서는 환자의 알림 설정을 조회
            Map<String, Boolean> settings = Map.of(
                    "smsEnabled", true,
                    "pushEnabled", true,
                    "voiceEnabled", true,
                    "alarmTalkEnabled", true,
                    "emailEnabled", false
            );

            ApiResponse<Map<String, Boolean>> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("알림 설정 조회 성공");
            response.setData(settings);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Map<String, Boolean>> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("알림 설정 조회에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 알림 설정 업데이트
     */
    @PutMapping("/settings/{patientId}")
    public ResponseEntity<ApiResponse<Void>> updateNotificationSettings(
            @PathVariable Long patientId,
            @RequestBody Map<String, Boolean> settings) {

        try {
            // 실제 구현에서는 환자의 알림 설정을 업데이트
            // patientService.updateNotificationSettings(patientId, settings);

            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("알림 설정이 성공적으로 업데이트되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("알림 설정 업데이트에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 알림 전송 이력 조회
     */
    @GetMapping("/history/{patientId}")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getNotificationHistory(
            @PathVariable Long patientId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {

        try {
            // 실제 구현에서는 알림 전송 이력을 조회
            List<Map<String, Object>> history = List.of(
                    Map.of(
                            "id", 1L,
                            "type", "MEDICATION_REMINDER",
                            "message", "타이레놀 복용 시간입니다.",
                            "sentAt", "2025-08-20T09:00:00",
                            "status", "SUCCESS"
                    ),
                    Map.of(
                            "id", 2L,
                            "type", "APPOINTMENT_REMINDER",
                            "message", "내일 진료 예약이 있습니다.",
                            "sentAt", "2025-08-19T19:00:00",
                            "status", "SUCCESS"
                    )
            );

            ApiResponse<List<Map<String, Object>>> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("알림 이력 조회 성공");
            response.setData(history);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<List<Map<String, Object>>> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("알림 이력 조회에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 알림 테스트 전송
     */
    @PostMapping("/test/{patientId}")
    public ResponseEntity<ApiResponse<Void>> sendTestNotification(
            @PathVariable Long patientId,
            @RequestParam String type) {

        try {
            String testMessage = switch (type.toUpperCase()) {
                case "SMS" -> "MediFit 테스트 SMS입니다.";
                case "PUSH" -> "MediFit 테스트 푸시 알림입니다.";
                case "VOICE" -> "MediFit 테스트 음성 전화입니다.";
                case "ALARMTALK" -> "MediFit 테스트 알림톡입니다.";
                default -> "MediFit 테스트 알림입니다.";
            };

            // 실제 구현에서는 해당 타입의 알림을 전송
            // notificationService.sendTestNotification(patientId, type, testMessage);

            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("테스트 " + type + " 알림이 성공적으로 전송되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Void> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("테스트 알림 전송에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 알림 통계 조회
     */
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getNotificationStats(
            @RequestParam(required = false) Long hospitalId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {

        try {
            // 실제 구현에서는 알림 통계를 조회
            Map<String, Object> stats = Map.of(
                    "totalSent", 1500,
                    "successRate", 98.5,
                    "byType", Map.of(
                            "SMS", 800,
                            "PUSH", 400,
                            "VOICE", 200,
                            "ALARMTALK", 100
                    ),
                    "byStatus", Map.of(
                            "SUCCESS", 1477,
                            "FAILED", 23
                    )
            );

            ApiResponse<Map<String, Object>> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("알림 통계 조회 성공");
            response.setData(stats);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Map<String, Object>> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("알림 통계 조회에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 복약 알림 스케줄러 상태 조회
     */
    @GetMapping("/scheduler/status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getSchedulerStatus() {

        try {
            // 실제 구현에서는 스케줄러 상태를 조회
            Map<String, Object> status = Map.of(
                    "isRunning", true,
                    "lastExecuted", "2025-08-20T09:00:00",
                    "nextExecution", "2025-08-20T13:00:00",
                    "scheduledTasks", List.of(
                            Map.of("time", "09:00", "type", "아침", "enabled", true),
                            Map.of("time", "13:00", "type", "점심", "enabled", true),
                            Map.of("time", "19:00", "type", "저녁", "enabled", true),
                            Map.of("time", "22:00", "type", "밤", "enabled", true)
                    )
            );

            ApiResponse<Map<String, Object>> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("스케줄러 상태 조회 성공");
            response.setData(status);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Map<String, Object>> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("스케줄러 상태 조회에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }
}