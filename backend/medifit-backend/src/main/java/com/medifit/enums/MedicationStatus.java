package com.medifit.enums;

public enum MedicationStatus {
    ACTIVE("복용 중"),
    PAUSED("일시 중단"),
    COMPLETED("복용 완료"),
    DISCONTINUED("복용 중단");

    private final String description;

    MedicationStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}