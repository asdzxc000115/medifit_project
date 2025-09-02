package com.medifit.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;

import java.time.LocalDateTime;

/**
 * 진료기록 생성/수정용 DTO
 */
public class CreateMedicalRecordDto {

    @NotNull(message = "환자 ID는 필수입니다.")
    @Positive(message = "환자 ID는 양수여야 합니다.")
    private Long patientId;

    @NotNull(message = "의사 ID는 필수입니다.")
    @Positive(message = "의사 ID는 양수여야 합니다.")
    private Long doctorId;

    @NotBlank(message = "진료과는 필수입니다.")
    private String department;

    private String symptoms;

    @NotBlank(message = "진단명은 필수입니다.")
    private String diagnosis;

    private String treatment;
    private String doctorNotes;

    @NotNull(message = "진료 일시는 필수입니다.")
    private LocalDateTime visitDate;

    @PositiveOrZero(message = "진료비는 0 이상이어야 합니다.")
    private Integer medicalFee;

    private String roomNumber;

    // 기본 생성자
    public CreateMedicalRecordDto() {}

    // Getters and Setters
    public Long getPatientId() {
        return patientId;
    }

    public void setPatientId(Long patientId) {
        this.patientId = patientId;
    }

    public Long getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(Long doctorId) {
        this.doctorId = doctorId;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getSymptoms() {
        return symptoms;
    }

    public void setSymptoms(String symptoms) {
        this.symptoms = symptoms;
    }

    public String getDiagnosis() {
        return diagnosis;
    }

    public void setDiagnosis(String diagnosis) {
        this.diagnosis = diagnosis;
    }

    public String getTreatment() {
        return treatment;
    }

    public void setTreatment(String treatment) {
        this.treatment = treatment;
    }

    public String getDoctorNotes() {
        return doctorNotes;
    }

    public void setDoctorNotes(String doctorNotes) {
        this.doctorNotes = doctorNotes;
    }

    public LocalDateTime getVisitDate() {
        return visitDate;
    }

    public void setVisitDate(LocalDateTime visitDate) {
        this.visitDate = visitDate;
    }

    public Integer getMedicalFee() {
        return medicalFee;
    }

    public void setMedicalFee(Integer medicalFee) {
        this.medicalFee = medicalFee;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    @Override
    public String toString() {
        return "CreateMedicalRecordDto{" +
                "patientId=" + patientId +
                ", doctorId=" + doctorId +
                ", department='" + department + '\'' +
                ", diagnosis='" + diagnosis + '\'' +
                ", visitDate=" + visitDate +
                '}';
    }
}