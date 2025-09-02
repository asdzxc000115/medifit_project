package com.medifit.controller;

import com.medifit.entity.MedicalRecord;
import com.medifit.service.MedicalRecordService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/medical-records")
@CrossOrigin(origins = "*")
public class MedicalRecordController {

    @Autowired
    private MedicalRecordService medicalRecordService;

    // 🔥 모든 의료기록 조회
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllMedicalRecords(
            @RequestParam(required = false) Long patientId,
            @RequestParam(required = false) String department,
            @RequestParam(required = false) String status) {

        Map<String, Object> response = new HashMap<>();

        try {
            List<MedicalRecord> medicalRecords;

            if (patientId != null) {
                medicalRecords = medicalRecordService.findByPatientId(patientId);
                response.put("message", "환자별 의료기록을 조회했습니다.");
            } else if (department != null) {
                medicalRecords = medicalRecordService.findByDepartment(department);
                response.put("message", "진료과별 의료기록을 조회했습니다.");
            } else {
                medicalRecords = medicalRecordService.getAllMedicalRecords();
                response.put("message", "전체 의료기록을 조회했습니다.");
            }

            response.put("success", true);
            response.put("data", medicalRecords);
            response.put("total", medicalRecords.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "의료기록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 의료기록 상세 조회
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getMedicalRecordById(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<MedicalRecord> medicalRecord = medicalRecordService.findById(id);

            if (medicalRecord.isPresent()) {
                response.put("success", true);
                response.put("message", "의료기록을 조회했습니다.");
                response.put("data", medicalRecord.get());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "해당 ID의 의료기록을 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "의료기록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 의료기록 등록
    @PostMapping
    public ResponseEntity<Map<String, Object>> createMedicalRecord(@RequestBody MedicalRecord medicalRecord) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 필수 필드 검증
            if (medicalRecord.getPatient() == null) {
                response.put("success", false);
                response.put("message", "환자 정보는 필수입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            if (medicalRecord.getDoctor() == null) {
                response.put("success", false);
                response.put("message", "의사 정보는 필수입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            if (medicalRecord.getDiagnosis() == null || medicalRecord.getDiagnosis().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "진단명은 필수 입력 항목입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            MedicalRecord savedRecord = medicalRecordService.save(medicalRecord);

            response.put("success", true);
            response.put("message", "의료기록이 성공적으로 등록되었습니다.");
            response.put("data", savedRecord);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "의료기록 등록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 의료기록 수정
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateMedicalRecord(@PathVariable Long id, @RequestBody MedicalRecord medicalRecord) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<MedicalRecord> existingRecord = medicalRecordService.findById(id);

            if (!existingRecord.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 의료기록을 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            medicalRecord.setId(id);
            MedicalRecord updatedRecord = medicalRecordService.save(medicalRecord);

            response.put("success", true);
            response.put("message", "의료기록이 성공적으로 수정되었습니다.");
            response.put("data", updatedRecord);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "의료기록 수정 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 의료기록 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteMedicalRecord(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<MedicalRecord> medicalRecord = medicalRecordService.findById(id);

            if (!medicalRecord.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 의료기록을 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            medicalRecordService.deleteById(id);

            response.put("success", true);
            response.put("message", "의료기록이 삭제되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "의료기록 삭제 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자별 최근 의료기록 조회
    @GetMapping("/patient/{patientId}/recent")
    public ResponseEntity<Map<String, Object>> getRecentMedicalRecords(
            @PathVariable Long patientId,
            @RequestParam(defaultValue = "10") int limit) {

        Map<String, Object> response = new HashMap<>();

        try {
            List<MedicalRecord> recentRecords = medicalRecordService.findRecentByPatientId(patientId, limit);

            response.put("success", true);
            response.put("message", "환자의 최근 의료기록을 조회했습니다.");
            response.put("data", recentRecords);
            response.put("total", recentRecords.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "최근 의료기록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 진료과별 의료기록 조회
    @GetMapping("/department/{department}")
    public ResponseEntity<Map<String, Object>> getMedicalRecordsByDepartment(@PathVariable String department) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<MedicalRecord> records = medicalRecordService.findByDepartment(department);

            response.put("success", true);
            response.put("message", department + " 의료기록을 조회했습니다.");
            response.put("data", records);
            response.put("total", records.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "진료과별 의료기록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 의료기록 검색 (진단명, 치료내용으로 검색)
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchMedicalRecords(@RequestParam String keyword) {
        Map<String, Object> response = new HashMap<>();

        try {
            List<MedicalRecord> searchResults = medicalRecordService.searchRecords(keyword);

            response.put("success", true);
            response.put("message", "의료기록 검색 결과입니다.");
            response.put("data", searchResults);
            response.put("total", searchResults.size());
            response.put("keyword", keyword);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "의료기록 검색 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자의 진단명별 통계
    @GetMapping("/patient/{patientId}/diagnosis-stats")
    public ResponseEntity<Map<String, Object>> getPatientDiagnosisStats(@PathVariable Long patientId) {
        Map<String, Object> response = new HashMap<>();

        try {
            Map<String, Object> stats = medicalRecordService.getPatientDiagnosisStatistics(patientId);

            response.put("success", true);
            response.put("message", "환자의 진단 통계를 조회했습니다.");
            response.put("data", stats);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "진단 통계 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 의료기록 AI 요약 생성/업데이트
    @PostMapping("/{id}/ai-summary")
    public ResponseEntity<Map<String, Object>> generateAiSummary(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<MedicalRecord> recordOpt = medicalRecordService.findById(id);

            if (!recordOpt.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 의료기록을 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            String aiSummary = medicalRecordService.generateAiSummary(id);

            response.put("success", true);
            response.put("message", "AI 요약이 생성되었습니다.");
            response.put("data", Map.of("aiSummary", aiSummary));

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "AI 요약 생성 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 월별 의료기록 통계
    @GetMapping("/stats/monthly")
    public ResponseEntity<Map<String, Object>> getMonthlyStats(
            @RequestParam(required = false) Long patientId,
            @RequestParam(defaultValue = "12") int months) {

        Map<String, Object> response = new HashMap<>();

        try {
            Map<String, Object> monthlyStats = medicalRecordService.getMonthlyStatistics(patientId, months);

            response.put("success", true);
            response.put("message", "월별 의료기록 통계를 조회했습니다.");
            response.put("data", monthlyStats);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "월별 통계 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 진료비 통계
    @GetMapping("/stats/medical-fees")
    public ResponseEntity<Map<String, Object>> getMedicalFeeStats(
            @RequestParam(required = false) Long patientId) {

        Map<String, Object> response = new HashMap<>();

        try {
            Map<String, Object> feeStats = medicalRecordService.getMedicalFeeStatistics(patientId);

            response.put("success", true);
            response.put("message", "진료비 통계를 조회했습니다.");
            response.put("data", feeStats);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "진료비 통계 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}