// backend/medifit-backend/src/main/java/com/medifit/enums/Role.java (수정)
package com.medifit.enums;

/**
 * 사용자 역할 열거형
 */
public enum Role {
    USER("일반 사용자"),
    PATIENT("환자"),          // 추가
    HOSPITAL("병원 관계자"),
    ADMIN("관리자");

    private final String description;

    Role(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }

    @Override
    public String toString() {
        return description;
    }
}