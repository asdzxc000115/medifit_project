package com.medifit.enums;

public enum MedicationTime {
    BEFORE_BREAKFAST("아침 식전"),
    AFTER_BREAKFAST("아침 식후"),
    BEFORE_LUNCH("점심 식전"),
    AFTER_LUNCH("점심 식후"),
    BEFORE_DINNER("저녁 식전"),
    AFTER_DINNER("저녁 식후"),
    BEFORE_SLEEP("취침 전"),
    AS_NEEDED("필요시");

    private final String description;

    MedicationTime(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}