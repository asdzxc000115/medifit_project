package com.medifit.enums;

public enum RecordStatus {
    ACTIVE("활성"),
    COMPLETED("완료"),
    CANCELLED("취소"),
    DRAFT("임시저장");

    private final String description;

    RecordStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}