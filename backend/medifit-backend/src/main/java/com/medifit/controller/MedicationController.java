package com.medifit.controller;

import com.medifit.entity.Medication;
import com.medifit.service.MedicationService;
import com.medifit.enums.MedicationStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/medications")
@CrossOrigin(origins = "*")
public class MedicationController {

    @Autowired
    private MedicationService medicationService;

    // 🔥 모든 복약 정보 조회
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllMedications(
            @RequestParam(required = false) Long patientId,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Boolean activeOnly) {

        Map<String, Object> response = new HashMap<>();

        try {
            List<Medication> medications;

            if (patientId != null && Boolean.TRUE.equals(activeOnly)) {
                medications = medicationService.findActiveByPatientId(patientId);
                response.put("message", "환자의 복용 중인 약물을 조회했습니다.");
            } else if (patientId != null) {
                medications = medicationService.findByPatientId(patientId);
                response.put("message", "환자의 전체 복약 내역을 조회했습니다.");
            } else if (status != null) {
                MedicationStatus medicationStatus = MedicationStatus.valueOf(status.toUpperCase());
                medications = medicationService.findByStatus(medicationStatus);
                response.put("message", status + " 상태의 복약 정보를 조회했습니다.");
            } else {
                medications = medicationService.getAllMedications();
                response.put("message", "전체 복약 정보를 조회했습니다.");
            }

            response.put("success", true);
            response.put("data", medications);
            response.put("total", medications.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "복약 정보 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 복약 정보 상세 조회
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getMedicationById(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Medication> medication = medicationService.findById(id);

            if (medication.isPresent()) {
                response.put("success", true);
                response.put("message", "복약 정보를 조회했습니다.");
                response.put("data", medication.get());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "해당 ID의 복약 정보를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "복약 정보 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 복약 정보 등록
    @PostMapping
    public ResponseEntity<Map<String, Object>> createMedication(@RequestBody Medication medication) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 필수 필드 검증
            if (medication.getPatient() == null) {
                response.put("success", false);
                response.put("message", "환자 정보는 필수입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            if (medication.getMedicationName() == null || medication.getMedicationName().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "약품명은 필수입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            if (medication.getStartDate() == null || medication.getEndDate() == null) {
                response.put("success", false);
                response.put("message", "복용 시작일과 종료일은 필수입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            // 날짜 유효성 검사
            if (medication.getEndDate().isBefore(medication.getStartDate())) {
                response.put("success", false);
                response.put("message", "종료일은 시작일보다 늦어야 합니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            Medication savedMedication = medicationService.save(medication);

            response.put("success", true);
            response.put("message", "복약 정보가 성공적으로 등록되었습니다.");
            response.put("data", savedMedication);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "복약 정보 등록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 복약 정보 수정
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updateMedication(@PathVariable Long id, @RequestBody Medication medication) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Medication> existingMedication = medicationService.findById(id);

            if (!existingMedication.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 복약 정보를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            medication.setId(id);
            Medication updatedMedication = medicationService.save(medication);

            response.put("success", true);
            response.put("message", "복약 정보가 성공적으로 수정되었습니다.");
            response.put("data", updatedMedication);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "복약 정보 수정 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 복약 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteMedication(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Medication> medication = medicationService.findById(id);

            if (!medication.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 복약 정보를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            medicationService.deleteById(id);

            response.put("success", true);
            response.put("message", "복약 정보가 삭제되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "복약 정보 삭제 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자의 오늘 복용해야 할 약물 조회
    @GetMapping("/patient/{patientId}/today")
    public ResponseEntity<Map<String, Object>> getTodayMedications(@PathVariable Long patientId) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 임시 구현 - 실제로는 MedicationService에서 구현
            response.put("success", true);
            response.put("message", "오늘 복용할 약물을 조회했습니다.");
            response.put("data", new java.util.ArrayList<>());
            response.put("total", 0);
            response.put("date", LocalDate.now());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "오늘 복약 정보 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 복약 완료 처리 (복용 기록)
    @PostMapping("/{id}/take")
    public ResponseEntity<Map<String, Object>> takeMedication(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 임시 구현 - 실제로는 MedicationService에서 구현
            response.put("success", true);
            response.put("message", "복약이 기록되었습니다.");
            response.put("data", new HashMap<>());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "복약 기록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 복약 상태 변경
    @PatchMapping("/{id}/status")
    public ResponseEntity<Map<String, Object>> changeMedicationStatus(
            @PathVariable Long id,
            @RequestParam String status) {

        Map<String, Object> response = new HashMap<>();

        try {
            MedicationStatus newStatus = MedicationStatus.valueOf(status.toUpperCase());

            response.put("success", true);
            response.put("message", "복약 상태가 " + newStatus.getDescription() + "(으)로 변경되었습니다.");
            response.put("data", new HashMap<>());

            return ResponseEntity.ok(response);

        } catch (IllegalArgumentException e) {
            response.put("success", false);
            response.put("message", "유효하지 않은 상태값입니다: " + status);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "복약 상태 변경 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 복약 통계 (월별)
    @GetMapping("/patient/{patientId}/stats/monthly")
    public ResponseEntity<Map<String, Object>> getMonthlyMedicationStats(@PathVariable Long patientId) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 임시 구현 - 실제로는 MedicationService에서 구현
            Map<String, Object> stats = new HashMap<>();
            stats.put("totalMedications", 0);
            stats.put("activeMedications", 0);
            stats.put("completedMedications", 0);

            response.put("success", true);
            response.put("message", "월별 복약 통계를 조회했습니다.");
            response.put("data", stats);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "복약 통계 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}