package com.medifit.enums;

public enum AppointmentType {
    CONSULTATION("일반 진료"),
    FOLLOW_UP("재진"),
    CHECK_UP("건강검진"),
    EMERGENCY("응급"),
    VACCINATION("예방접종"),
    SURGERY("수술"),
    THERAPY("치료");

    private final String description;

    AppointmentType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}