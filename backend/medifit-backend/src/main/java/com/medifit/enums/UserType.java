package com.medifit.enums;

public enum UserType {
    PATIENT("환자");

    private final String description;

    UserType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}