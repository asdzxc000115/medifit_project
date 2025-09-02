// backend/medifit-backend/src/main/java/com/medifit/dto/HospitalRegistrationDto.java
package com.medifit.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public class HospitalRegistrationDto {
    @NotBlank(message = "사용자명은 필수입니다.")
    private String username;

    @NotBlank(message = "비밀번호는 필수입니다.")
    private String password;

    @NotBlank(message = "병원명은 필수입니다.")
    private String hospitalName;

    @NotBlank(message = "대표자명은 필수입니다.")
    private String representative;

    @NotBlank(message = "병원 주소는 필수입니다.")
    private String hospitalAddress;

    @Pattern(regexp = "^\\d{3}-?\\d{2}-?\\d{5}$", message = "올바른 사업자등록번호 형식이 아닙니다.")
    private String businessNumber;

    // 기본 생성자
    public HospitalRegistrationDto() {}

    // Getters and Setters
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getHospitalName() {
        return hospitalName;
    }

    public void setHospitalName(String hospitalName) {
        this.hospitalName = hospitalName;
    }

    public String getRepresentative() {
        return representative;
    }

    public void setRepresentative(String representative) {
        this.representative = representative;
    }

    public String getHospitalAddress() {
        return hospitalAddress;
    }

    public void setHospitalAddress(String hospitalAddress) {
        this.hospitalAddress = hospitalAddress;
    }

    public String getBusinessNumber() {
        return businessNumber;
    }

    public void setBusinessNumber(String businessNumber) {
        this.businessNumber = businessNumber;
    }
}