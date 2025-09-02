package com.medifit.entity;

import com.medifit.enums.AppointmentStatus;
import com.medifit.enums.AppointmentType;
import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "appointments")
public class Appointment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "hospital_id", nullable = false)
    private User hospital;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "doctor_id")
    private User doctor;

    @Column(nullable = false)
    private LocalDateTime appointmentDate; // 예약 일시

    @Column(nullable = false)
    private String department; // 진료과 (내과, 외과 등)

    @Enumerated(EnumType.STRING)
    private AppointmentStatus status = AppointmentStatus.SCHEDULED;

    @Enumerated(EnumType.STRING)
    private AppointmentType appointmentType = AppointmentType.CONSULTATION;

    @Column(columnDefinition = "TEXT")
    private String notes; // 예약 메모

    @Column(columnDefinition = "TEXT")
    private String symptoms; // 사전 증상 기록

    // 예약 관련 정보
    @Column(length = 50)
    private String roomNumber; // 진료실 번호

    private Integer estimatedDuration; // 예상 진료 시간 (분)

    // 알림 관련
    private Boolean reminderSent = false; // 알림 전송 여부

    private LocalDateTime reminderSentAt; // 알림 전송 시간

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    // 연결된 진료기록
    @OneToOne(mappedBy = "appointment", cascade = CascadeType.ALL)
    private MedicalRecord medicalRecord;

    // 기본 생성자
    public Appointment() {}

    // 생성자
    public Appointment(Patient patient, User hospital, LocalDateTime appointmentDate,
                       String department, String notes) {
        this.patient = patient;
        this.hospital = hospital;
        this.appointmentDate = appointmentDate;
        this.department = department;
        this.notes = notes;
        this.createdAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    // 예약 완료 처리
    public void completeAppointment() {
        this.status = AppointmentStatus.COMPLETED;
        this.updatedAt = LocalDateTime.now();
    }

    // 예약 취소 처리
    public void cancelAppointment() {
        this.status = AppointmentStatus.CANCELLED;
        this.updatedAt = LocalDateTime.now();
    }

    // 알림 전송 처리
    public void markReminderSent() {
        this.reminderSent = true;
        this.reminderSentAt = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }

    public User getHospital() { return hospital; }
    public void setHospital(User hospital) { this.hospital = hospital; }

    public User getDoctor() { return doctor; }
    public void setDoctor(User doctor) { this.doctor = doctor; }

    public LocalDateTime getAppointmentDate() { return appointmentDate; }
    public void setAppointmentDate(LocalDateTime appointmentDate) { this.appointmentDate = appointmentDate; }

    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }

    public AppointmentStatus getStatus() { return status; }
    public void setStatus(AppointmentStatus status) { this.status = status; }

    public AppointmentType getAppointmentType() { return appointmentType; }
    public void setAppointmentType(AppointmentType appointmentType) { this.appointmentType = appointmentType; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }

    public String getRoomNumber() { return roomNumber; }
    public void setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public Integer getEstimatedDuration() { return estimatedDuration; }
    public void setEstimatedDuration(Integer estimatedDuration) { this.estimatedDuration = estimatedDuration; }

    public Boolean getReminderSent() { return reminderSent; }
    public void setReminderSent(Boolean reminderSent) { this.reminderSent = reminderSent; }

    public LocalDateTime getReminderSentAt() { return reminderSentAt; }
    public void setReminderSentAt(LocalDateTime reminderSentAt) { this.reminderSentAt = reminderSentAt; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public MedicalRecord getMedicalRecord() { return medicalRecord; }
    public void setMedicalRecord(MedicalRecord medicalRecord) { this.medicalRecord = medicalRecord; }

    @Override
    public String toString() {
        return "Appointment{" +
                "id=" + id +
                ", patientName='" + (patient != null ? patient.getName() : "N/A") + '\'' +
                ", appointmentDate=" + appointmentDate +
                ", department='" + department + '\'' +
                ", status=" + status +
                ", roomNumber='" + roomNumber + '\'' +
                '}';
    }
}