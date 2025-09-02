package com.medifit.enums;

public enum AppointmentStatus {
    SCHEDULED("예약됨"),
    CONFIRMED("확정됨"),
    IN_PROGRESS("진료 중"),
    COMPLETED("완료됨"),
    CANCELLED("취소됨"),
    NO_SHOW("미방문");

    private final String description;

    AppointmentStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}