package com.medifit.entity;

import com.medifit.enums.RecordStatus;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "medical_records")
public class MedicalRecord {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "doctor_id", nullable = false)
    private User doctor; // 담당 의사

    @Column(nullable = false)
    private String department; // 진료과목 (내과, 외과 등)

    @Column(columnDefinition = "TEXT")
    private String symptoms; // 증상

    @Column(columnDefinition = "TEXT", nullable = false)
    private String diagnosis; // 진단명

    @Column(columnDefinition = "TEXT")
    private String treatment; // 치료내용

    @Column(columnDefinition = "TEXT")
    private String doctorNotes; // 의사 메모

    @Column(columnDefinition = "TEXT")
    private String aiSummary; // AI 요약 (GPT로 생성)

    @Enumerated(EnumType.STRING)
    private RecordStatus status = RecordStatus.ACTIVE;

    @Column(nullable = false)
    private LocalDateTime visitDate; // 진료일시

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    // 진료비 관련
    private Integer medicalFee; // 진료비

    @Column(length = 50)
    private String roomNumber; // 진료실 번호 (예: 302호)

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "appointment_id")
    private Appointment appointment;

    // 기본 생성자
    public MedicalRecord() {}

    // 생성자
    public MedicalRecord(Patient patient, User doctor, String department,
                         String symptoms, String diagnosis, String treatment,
                         LocalDateTime visitDate) {
        this.patient = patient;
        this.doctor = doctor;
        this.department = department;
        this.symptoms = symptoms;
        this.diagnosis = diagnosis;
        this.treatment = treatment;
        this.visitDate = visitDate;
        this.createdAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }

    public User getDoctor() { return doctor; }
    public void setDoctor(User doctor) { this.doctor = doctor; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public String getDiagnosis() { return diagnosis; }
    public void setDiagnosis(String diagnosis) { this.diagnosis = diagnosis; }

    public String getTreatment() { return treatment; }
    public void setTreatment(String treatment) { this.treatment = treatment; }

    public String getDoctorNotes() { return doctorNotes; }
    public void setDoctorNotes(String doctorNotes) { this.doctorNotes = doctorNotes; }

    public String getAiSummary() { return aiSummary; }
    public void setAiSummary(String aiSummary) { this.aiSummary = aiSummary; }

    public RecordStatus getStatus() { return status; }
    public void setStatus(RecordStatus status) { this.status = status; }

    public LocalDateTime getVisitDate() { return visitDate; }
    public void setVisitDate(LocalDateTime visitDate) { this.visitDate = visitDate; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public Integer getMedicalFee() { return medicalFee; }
    public void setMedicalFee(Integer medicalFee) { this.medicalFee = medicalFee; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public Appointment getAppointment() { return appointment; }
    public void setAppointment(Appointment appointment) { this.appointment = appointment; }

    @Override
    public String toString() {
        return "MedicalRecord{" +
                "id=" + id +
                ", patientName='" + (patient != null ? patient.getName() : "N/A") + '\'' +
                ", department='" + department + '\'' +
                ", diagnosis='" + diagnosis + '\'' +
                ", visitDate=" + visitDate +
                ", status=" + status +
                '}';
    }
}