package com.medifit.entity;

import com.medifit.enums.PrescriptionStatus;
import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.List;

@Entity
@Table(name = "prescriptions")
public class Prescription {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "doctor_id", nullable = false)
    private User doctor;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "medical_record_id")
    private MedicalRecord medicalRecord;

    @OneToMany(mappedBy = "prescription", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<Medication> medications;

    @Column(nullable = false)
    private LocalDateTime prescribedDate;

    @Column(columnDefinition = "TEXT")
    private String instructions; // 복용 지시사항

    @Column(columnDefinition = "TEXT")
    private String pharmacyNotes; // 약국 메모

    @Enumerated(EnumType.STRING)
    private PrescriptionStatus status = PrescriptionStatus.PRESCRIBED;

    @Column(nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    private LocalDateTime updatedAt;

    // 처방전 번호
    @Column(unique = true)
    private String prescriptionNumber;

    // 기본 생성자
    public Prescription() {}

    // 생성자
    public Prescription(Patient patient, User doctor, MedicalRecord medicalRecord,
                        LocalDateTime prescribedDate, String instructions) {
        this.patient = patient;
        this.doctor = doctor;
        this.medicalRecord = medicalRecord;
        this.prescribedDate = prescribedDate;
        this.instructions = instructions;
        this.createdAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

    // 처방전 번호 자동 생성
    @PrePersist
    public void generatePrescriptionNumber() {
        if (prescriptionNumber == null) {
            prescriptionNumber = "RX" + System.currentTimeMillis();
        }
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Patient getPatient() { return patient; }
    public void setPatient(Patient patient) { this.patient = patient; }

    public User getDoctor() { return doctor; }
    public void setDoctor(User doctor) { this.doctor = doctor; }

    public MedicalRecord getMedicalRecord() { return medicalRecord; }
    public void setMedicalRecord(MedicalRecord medicalRecord) { this.medicalRecord = medicalRecord; }

    public List<Medication> getMedications() { return medications; }
    public void setMedications(List<Medication> medications) { this.medications = medications; }

    public LocalDateTime getPrescribedDate() { return prescribedDate; }
    public void setPrescribedDate(LocalDateTime prescribedDate) { this.prescribedDate = prescribedDate; }

    public String getInstructions() { return instructions; }
    public void setInstructions(String instructions) { this.instructions = instructions; }

    public String getPharmacyNotes() { return pharmacyNotes; }
    public void setPharmacyNotes(String pharmacyNotes) { this.pharmacyNotes = pharmacyNotes; }

    public PrescriptionStatus getStatus() { return status; }
    public void setStatus(PrescriptionStatus status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getPrescriptionNumber() { return prescriptionNumber; }
    public void setPrescriptionNumber(String prescriptionNumber) { this.prescriptionNumber = prescriptionNumber; }

    @Override
    public String toString() {
        return "Prescription{" +
                "id=" + id +
                ", prescriptionNumber='" + prescriptionNumber + '\'' +
                ", patientName='" + (patient != null ? patient.getName() : "N/A") + '\'' +
                ", prescribedDate=" + prescribedDate +
                ", status=" + status +
                '}';
    }
}