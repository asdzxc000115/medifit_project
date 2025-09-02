package com.medifit.service;

import com.medifit.entity.Patient;
import com.medifit.repository.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class PatientService {

    @Autowired
    private PatientRepository patientRepository;

    // 🔥 모든 환자 조회
    public List<Patient> getAllPatients() {
        return patientRepository.findAllByOrderByCreatedAtDesc();
    }

    // 🔥 ID로 환자 조회
    public Optional<Patient> findById(Long id) {
        return patientRepository.findById(id);
    }

    // 🔥 환자 저장 (등록/수정)
    public Patient save(Patient patient) {
        // 환자번호 자동 생성 (신규 환자일 경우)
        if (patient.getId() == null && (patient.getPatientNumber() == null || patient.getPatientNumber().isEmpty())) {
            patient.setPatientNumber(generatePatientNumber());
        }

        // 수정 시간 업데이트
        if (patient.getId() != null) {
            patient.setUpdatedAt(LocalDateTime.now());
        }

        return patientRepository.save(patient);
    }

    // 🔥 환자 삭제
    public void deleteById(Long id) {
        patientRepository.deleteById(id);
    }

    // 🔥 환자 검색 (이름, 전화번호, 주소로 검색)
    public List<Patient> searchPatients(String keyword) {
        return patientRepository.searchPatients(keyword);
    }

    // 🔥 전화번호 중복 체크
    public boolean existsByPhoneNumber(String phoneNumber) {
        return patientRepository.existsByPhoneNumber(phoneNumber);
    }

    // 🔥 환자번호로 조회
    public Optional<Patient> findByPatientNumber(String patientNumber) {
        return patientRepository.findByPatientNumber(patientNumber);
    }

    // 🔥 혈액형별 환자 조회
    public List<Patient> findByBloodType(String bloodType) {
        return patientRepository.findByBloodTypeOrderByCreatedAtDesc(bloodType);
    }

    // 🔥 나이 범위별 환자 조회
    public List<Patient> findPatientsByAgeRange(int minAge, int maxAge) {
        return patientRepository.findPatientsByAgeRange(minAge, maxAge);
    }

    // 🔥 최근 가입한 환자들 조회
    public List<Patient> findRecentPatients(int limit) {
        return patientRepository.findTop10ByOrderByCreatedAtDesc();
    }

    // 🔥 병원별 환자 조회
    public List<Patient> findByHospitalId(Long hospitalId) {
        return patientRepository.findByHospitalIdOrderByCreatedAtDesc(hospitalId);
    }

    // 🔥 환자 통계
    public long getTotalPatientCount() {
        return patientRepository.count();
    }

    public long getTodayRegisteredCount() {
        LocalDateTime startOfDay = LocalDateTime.now().withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfDay = startOfDay.plusDays(1);
        return patientRepository.countByCreatedAtBetween(startOfDay, endOfDay);
    }

    // 🔥 환자번호 자동 생성 (예: 2025-001)
    private String generatePatientNumber() {
        String year = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy"));
        long count = patientRepository.count() + 1;
        return year + "-" + String.format("%03d", count);
    }

    // 🔥 환자의 최근 의료기록 조회
    public List<Object> getRecentMedicalRecords(Long patientId, int limit) {
        // 실제로는 MedicalRecordService를 호출해야 하지만,
        // 여기서는 환자 엔티티의 관계를 통해 조회
        Optional<Patient> patient = findById(patientId);
        if (patient.isPresent() && patient.get().getMedicalRecords() != null) {
            return patient.get().getMedicalRecords().stream()
                    .limit(limit)
                    .map(record -> record)
                    .collect(java.util.stream.Collectors.toList());
        }
        return java.util.Collections.emptyList();
    }

    // 🔥 환자의 다음 예약 조회
    public Optional<Object> getNextAppointment(Long patientId) {
        Optional<Patient> patient = findById(patientId);
        if (patient.isPresent() && patient.get().getAppointments() != null) {
            return patient.get().getAppointments().stream()
                    .filter(appointment -> appointment.getAppointmentDate().isAfter(LocalDateTime.now()))
                    .min((a1, a2) -> a1.getAppointmentDate().compareTo(a2.getAppointmentDate()))
                    .map(appointment -> appointment);
        }
        return Optional.empty();
    }

    // 🔥 환자 정보 유효성 검사
    public boolean isValidPatient(Patient patient) {
        if (patient == null) return false;
        if (patient.getName() == null || patient.getName().trim().isEmpty()) return false;
        if (patient.getPhoneNumber() == null || patient.getPhoneNumber().trim().isEmpty()) return false;
        if (patient.getBirthDate() == null) return false;

        // 전화번호 형식 검사 (010-1234-5678 또는 01012345678)
        String phonePattern = "^010-?\\d{4}-?\\d{4}$";
        if (!patient.getPhoneNumber().matches(phonePattern)) return false;

        return true;
    }

    // 🔥 환자 나이 계산
    public int calculateAge(Patient patient) {
        if (patient.getBirthDate() == null) return 0;
        return LocalDateTime.now().getYear() - patient.getBirthDate().getYear();
    }
}