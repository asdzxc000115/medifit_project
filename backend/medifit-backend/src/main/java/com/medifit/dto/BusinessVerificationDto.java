// backend/medifit-backend/src/main/java/com/medifit/dto/BusinessVerificationDto.java
package com.medifit.dto;

public class BusinessVerificationDto {
    private String businessNumber;

    // 기본 생성자
    public BusinessVerificationDto() {}

    // 생성자
    public BusinessVerificationDto(String businessNumber) {
        this.businessNumber = businessNumber;
    }

    // Getter and Setter
    public String getBusinessNumber() {
        return businessNumber;
    }

    public void setBusinessNumber(String businessNumber) {
        this.businessNumber = businessNumber;
    }
}