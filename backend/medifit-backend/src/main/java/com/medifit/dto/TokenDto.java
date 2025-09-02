// backend/medifit-backend/src/main/java/com/medifit/dto/TokenDto.java
package com.medifit.dto;

public class TokenDto {
    private String accessToken;
    private String refreshToken;
    private long expiresIn;

    // 기본 생성자
    public TokenDto() {}

    // 생성자
    public TokenDto(String accessToken, String refreshToken, long expiresIn) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
        this.expiresIn = expiresIn;
    }

    // Getters and Setters
    public String getAccessToken() {
        return accessToken;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public long getExpiresIn() {
        return expiresIn;
    }

    public void setExpiresIn(long expiresIn) {
        this.expiresIn = expiresIn;
    }
}