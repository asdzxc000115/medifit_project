// backend/medifit-backend/src/main/java/com/medifit/dto/KakaoLoginDto.java
package com.medifit.dto;

public class KakaoLoginDto {
    private String kakaoId;
    private String kakaoEmail;
    private String kakaoNickname;
    private String kakaoProfileImage;
    private String userType; // PATIENT 또는 HOSPITAL

    // 기본 생성자
    public KakaoLoginDto() {}

    // Getters and Setters
    public String getKakaoId() {
        return kakaoId;
    }

    public void setKakaoId(String kakaoId) {
        this.kakaoId = kakaoId;
    }

    public String getKakaoEmail() {
        return kakaoEmail;
    }

    public void setKakaoEmail(String kakaoEmail) {
        this.kakaoEmail = kakaoEmail;
    }

    public String getKakaoNickname() {
        return kakaoNickname;
    }

    public void setKakaoNickname(String kakaoNickname) {
        this.kakaoNickname = kakaoNickname;
    }

    public String getKakaoProfileImage() {
        return kakaoProfileImage;
    }

    public void setKakaoProfileImage(String kakaoProfileImage) {
        this.kakaoProfileImage = kakaoProfileImage;
    }

    public String getUserType() {
        return userType;
    }

    public void setUserType(String userType) {
        this.userType = userType;
    }
}