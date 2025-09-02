// backend/medifit-backend/src/main/java/com/medifit/dto/LoginResponseDto.java
package com.medifit.dto;

public class LoginResponseDto {
    private String token;
    private String refreshToken;
    private UserDto user;
    private boolean firstLogin;

    // 기본 생성자
    public LoginResponseDto() {}

    // 생성자
    public LoginResponseDto(String token, String refreshToken, UserDto user, boolean firstLogin) {
        this.token = token;
        this.refreshToken = refreshToken;
        this.user = user;
        this.firstLogin = firstLogin;
    }

    // Getters and Setters
    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public String getRefreshToken() {
        return refreshToken;
    }

    public void setRefreshToken(String refreshToken) {
        this.refreshToken = refreshToken;
    }

    public UserDto getUser() {
        return user;
    }

    public void setUser(UserDto user) {
        this.user = user;
    }

    public boolean isFirstLogin() {
        return firstLogin;
    }

    public void setFirstLogin(boolean firstLogin) {
        this.firstLogin = firstLogin;
    }
}