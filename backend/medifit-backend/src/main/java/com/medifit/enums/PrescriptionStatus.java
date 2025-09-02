package com.medifit.enums;

public enum PrescriptionStatus {
    PRESCRIBED("처방됨"),
    DISPENSED("조제됨"),
    COMPLETED("완료됨"),
    CANCELLED("취소됨");

    private final String description;

    PrescriptionStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}