package com.medifit.controller;

import com.medifit.entity.Patient;
import com.medifit.service.PatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/patients")
@CrossOrigin(origins = "*")
public class PatientController {

    @Autowired
    private PatientService patientService;

    // 🔥 환자 목록 조회 (검색 기능 포함)
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllPatients(
            @RequestParam(required = false) String search,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {

        Map<String, Object> response = new HashMap<>();

        try {
            List<Patient> patients;

            if (search != null && !search.trim().isEmpty()) {
                patients = patientService.searchPatients(search.trim());
                response.put("message", "검색 결과입니다.");
            } else {
                patients = patientService.getAllPatients();
                response.put("message", "전체 환자 목록입니다.");
            }

            response.put("success", true);
            response.put("data", patients);
            response.put("total", patients.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "환자 목록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자 상세 조회
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getPatientById(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Patient> patient = patientService.findById(id);

            if (patient.isPresent()) {
                response.put("success", true);
                response.put("message", "환자 정보를 조회했습니다.");
                response.put("data", patient.get());
                return ResponseEntity.ok(response);
            } else {
                response.put("success", false);
                response.put("message", "해당 ID의 환자를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "환자 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자 등록 (회원가입)
    @PostMapping
    public ResponseEntity<Map<String, Object>> createPatient(@RequestBody Patient patient) {
        Map<String, Object> response = new HashMap<>();

        try {
            // 입력 데이터 검증
            if (patient.getName() == null || patient.getName().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "환자 이름은 필수 입력 항목입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            if (patient.getPhoneNumber() == null || patient.getPhoneNumber().trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "전화번호는 필수 입력 항목입니다.");
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(response);
            }

            // 전화번호 중복 체크
            if (patientService.existsByPhoneNumber(patient.getPhoneNumber())) {
                response.put("success", false);
                response.put("message", "이미 등록된 전화번호입니다.");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(response);
            }

            Patient savedPatient = patientService.save(patient);

            response.put("success", true);
            response.put("message", "환자가 성공적으로 등록되었습니다.");
            response.put("data", savedPatient);

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "환자 등록 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자 정보 수정
    @PutMapping("/{id}")
    public ResponseEntity<Map<String, Object>> updatePatient(@PathVariable Long id, @RequestBody Patient patient) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Patient> existingPatient = patientService.findById(id);

            if (!existingPatient.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 환자를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            patient.setId(id); // ID 설정
            Patient updatedPatient = patientService.save(patient);

            response.put("success", true);
            response.put("message", "환자 정보가 성공적으로 수정되었습니다.");
            response.put("data", updatedPatient);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "환자 정보 수정 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자 삭제 (실제로는 비활성화)
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deletePatient(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Patient> patient = patientService.findById(id);

            if (!patient.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 환자를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            patientService.deleteById(id);

            response.put("success", true);
            response.put("message", "환자 정보가 삭제되었습니다.");

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "환자 삭제 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자별 의료기록 조회
    @GetMapping("/{id}/medical-records")
    public ResponseEntity<Map<String, Object>> getPatientMedicalRecords(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Patient> patient = patientService.findById(id);

            if (!patient.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 환자를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            response.put("success", true);
            response.put("message", "환자의 의료기록을 조회했습니다.");
            response.put("data", patient.get().getMedicalRecords());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "의료기록 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자별 예약 내역 조회
    @GetMapping("/{id}/appointments")
    public ResponseEntity<Map<String, Object>> getPatientAppointments(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Patient> patient = patientService.findById(id);

            if (!patient.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 환자를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            response.put("success", true);
            response.put("message", "환자의 예약 내역을 조회했습니다.");
            response.put("data", patient.get().getAppointments());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "예약 내역 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자별 처방전 조회
    @GetMapping("/{id}/prescriptions")
    public ResponseEntity<Map<String, Object>> getPatientPrescriptions(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Patient> patient = patientService.findById(id);

            if (!patient.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 환자를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            response.put("success", true);
            response.put("message", "환자의 처방전을 조회했습니다.");
            response.put("data", patient.get().getPrescriptions());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "처방전 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    // 🔥 환자 통계 정보 (대시보드용)
    @GetMapping("/{id}/dashboard")
    public ResponseEntity<Map<String, Object>> getPatientDashboard(@PathVariable Long id) {
        Map<String, Object> response = new HashMap<>();

        try {
            Optional<Patient> patientOpt = patientService.findById(id);

            if (!patientOpt.isPresent()) {
                response.put("success", false);
                response.put("message", "해당 ID의 환자를 찾을 수 없습니다.");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
            }

            Patient patient = patientOpt.get();
            Map<String, Object> dashboard = new HashMap<>();

            // 기본 통계
            dashboard.put("totalMedicalRecords", patient.getMedicalRecords() != null ? patient.getMedicalRecords().size() : 0);
            dashboard.put("totalAppointments", patient.getAppointments() != null ? patient.getAppointments().size() : 0);
            dashboard.put("totalPrescriptions", patient.getPrescriptions() != null ? patient.getPrescriptions().size() : 0);

            // 최근 방문일
            if (patient.getMedicalRecords() != null && !patient.getMedicalRecords().isEmpty()) {
                dashboard.put("lastVisitDate", patient.getMedicalRecords().get(0).getVisitDate());
            } else {
                dashboard.put("lastVisitDate", null);
            }

            response.put("success", true);
            response.put("message", "환자 대시보드 정보를 조회했습니다.");
            response.put("data", dashboard);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "대시보드 조회 중 오류가 발생했습니다: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}