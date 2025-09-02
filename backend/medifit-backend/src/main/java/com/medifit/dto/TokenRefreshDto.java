// backend/medifit-backend/src/main/java/com/medifit/dto/TokenRefreshDto.java
package com.medifit.dto;

public class TokenRefreshDto {
    private String refreshToken;

    // 기본 생성자
    public TokenRefreshDto() {}

    // 생성자
    public TokenRefreshDto(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    // Getter and Setter
    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }
}