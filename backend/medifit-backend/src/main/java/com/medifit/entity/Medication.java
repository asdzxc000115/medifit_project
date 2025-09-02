package com.medifit.entity;

import com.medifit.enums.MedicationStatus;
import com.medifit.enums.MedicationTime;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.time.LocalDate;

@Entity
@Table(name = "medications")
public class Medication {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "prescription_id")
    private Prescription prescription;

    @Column(nullable = false)
    private String medicationName; // 약품명

    @Column(nullable = false)
    private String dosage; // 용량 (예: 500mg)

    @Column(nullable = false)
    private Integer frequency; // 복용 횟수 (하루 N회)

    @Column(nullable = false)
    private LocalDate startDate; // 복용 시작일

    @Column(nullable = false)
    private LocalDate endDate; // 복용 종료일

    @Enumerated(EnumType.STRING)
    private MedicationTime medicationTime; // 복용 시간 (식전, 식후 등)

    @Enumerated(EnumType.STRING)
    private MedicationStatus status = MedicationStatus.ACTIVE;

    @Column(columnDefinition = "TEXT")
    private String instructions; // 복용 지시사항

    @Column(columnDefinition = "TEXT")
    private String sideEffects; // 부작용 정보

    // 알림 설정
    private Boolean reminderEnabled = true;
    private String reminderTimes; // JSON 형태로 알림 시간 저장

    // 복용 기록
    private Integer totalDoses; // 총 복용 횟수
    private Integer completedDoses = 0; // 완료된 복용 횟수

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    // 기본 생성자
    public Medication() {}

    // 생성자
    public Medication(Patient patient, String medicationName, String dosage,
                      Integer frequency, LocalDate startDate, LocalDate endDate,
                      MedicationTime medicationTime) {
        this.patient = patient;
        this.medicationName = medicationName;
        this.dosage = dosage;
        this.frequency = frequency;
        this.startDate = startDate;
        this.endDate = endDate;
        this.medicationTime = medicationTime;
        this.createdAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    // 복용 진행률 계산
    public double getProgressPercentage() {
        if (totalDoses == null || totalDoses == 0) return 0.0;
        return (double) completedDoses / totalDoses * 100.0;
    }

    // 복용 완료 여부 체크
    public boolean isCompleted() {
        return status == MedicationStatus.COMPLETED ||
                LocalDate.now().isAfter(endDate);
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }

    public Prescription getPrescription() { return prescription; }
    public void setPrescription(Prescription prescription) { this.prescription = prescription; }

    public String getMedicationName() { return medicationName; }
    public void setMedicationName(String medicationName) { this.medicationName = medicationName; }

    public String getDosage() { return dosage; }
    public void setDosage(String dosage) { this.dosage = dosage; }

    public Integer getFrequency() { return frequency; }
    public void setFrequency(Integer frequency) { this.frequency = frequency; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public MedicationTime getMedicationTime() { return medicationTime; }
    public void setMedicationTime(MedicationTime medicationTime) { this.medicationTime = medicationTime; }

    public MedicationStatus getStatus() { return status; }
    public void setStatus(MedicationStatus status) { this.status = status; }

    public String getInstructions() { return instructions; }
    public void setInstructions(String instructions) { this.instructions = instructions; }

    public String getSideEffects() { return sideEffects; }
    public void setSideEffects(String sideEffects) { this.sideEffects = sideEffects; }

    public Boolean getReminderEnabled() { return reminderEnabled; }
    public void setReminderEnabled(Boolean reminderEnabled) { this.reminderEnabled = reminderEnabled; }

    public String getReminderTimes() { return reminderTimes; }
    public void setReminderTimes(String reminderTimes) { this.reminderTimes = reminderTimes; }

    public Integer getTotalDoses() { return totalDoses; }
    public void setTotalDoses(Integer totalDoses) { this.totalDoses = totalDoses; }

    public Integer getCompletedDoses() { return completedDoses; }
    public void setCompletedDoses(Integer completedDoses) { this.completedDoses = completedDoses; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    @Override
    public String toString() {
        return "Medication{" +
                "id=" + id +
                ", medicationName='" + medicationName + '\'' +
                ", dosage='" + dosage + '\'' +
                ", frequency=" + frequency +
                ", status=" + status +
                ", startDate=" + startDate +
                ", endDate=" + endDate +
                '}';
    }
}