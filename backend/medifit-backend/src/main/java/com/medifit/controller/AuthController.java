package com.medifit.controller;

import com.medifit.dto.*;
import com.medifit.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private UserService userService;

    /**
     * 로그인 (환자 전용) - 임시 하드코딩 버전
     */
    @PostMapping("/login")
    public ResponseEntity<ApiResponse<LoginResponseDto>> login(@Valid @RequestBody LoginDto loginDto) {
        try {
            // 임시 하드코딩 로그인 (테스트용)
            if ("patient_hong".equals(loginDto.getUsername()) && "password123".equals(loginDto.getPassword())) {

                LoginResponseDto loginResponse = new LoginResponseDto();
                loginResponse.setToken("dummy-token-12345");
                loginResponse.setRefreshToken("dummy-refresh-token-67890");
                loginResponse.setFirstLogin(false);

                UserDto user = new UserDto();
                user.setUsername("patient_hong");
                user.setPatientName("홍길동");
                user.setAge(35);
                user.setPhoneNumber("010-1234-5678");
                user.setAddress("서울특별시 강남구 테헤란로 123");
                user.setBloodType("A형");
                user.setRole("USER");
                user.setUserType("PATIENT");
                user.setActive(true);

                loginResponse.setUser(user);

                ApiResponse<LoginResponseDto> response = new ApiResponse<>();
                response.setSuccess(true);
                response.setMessage("로그인 성공");
                response.setData(loginResponse);

                return ResponseEntity.ok(response);
            }

            // 추가 테스트 계정
            if ("test123".equals(loginDto.getUsername()) && "test123".equals(loginDto.getPassword())) {

                LoginResponseDto loginResponse = new LoginResponseDto();
                loginResponse.setToken("dummy-token-test123");
                loginResponse.setRefreshToken("dummy-refresh-test123");
                loginResponse.setFirstLogin(false);

                UserDto user = new UserDto();
                user.setUsername("test123");
                user.setPatientName("테스트사용자");
                user.setAge(30);
                user.setPhoneNumber("010-0000-0000");
                user.setAddress("테스트주소");
                user.setBloodType("O형");
                user.setRole("USER");
                user.setUserType("PATIENT");
                user.setActive(true);

                loginResponse.setUser(user);

                ApiResponse<LoginResponseDto> response = new ApiResponse<>();
                response.setSuccess(true);
                response.setMessage("로그인 성공");
                response.setData(loginResponse);

                return ResponseEntity.ok(response);
            }

            // 실제 DB 로그인 시도 (나중에 활성화)
            /*
            try {
                LoginResponseDto loginResponse = userService.login(loginDto);

                ApiResponse<LoginResponseDto> response = new ApiResponse<>();
                response.setSuccess(true);
                response.setMessage("로그인 성공");
                response.setData(loginResponse);

                return ResponseEntity.ok(response);
            } catch (Exception dbException) {
                // DB 로그인 실패 시 아래 코드로 진행
            }
            */

            // 잘못된 로그인 정보
            ApiResponse<LoginResponseDto> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("잘못된 사용자명 또는 비밀번호입니다.");
            return ResponseEntity.badRequest().body(response);

        } catch (Exception e) {
            ApiResponse<LoginResponseDto> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("로그인 처리 중 오류: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 하드코딩 로그인 (임시) - 기존 유지
     */
    @PostMapping("/login-test")
    public ResponseEntity<ApiResponse<LoginResponseDto>> testLogin(@RequestBody LoginDto loginDto) {
        try {
            // 하드코딩된 로그인 - 빠른 테스트용
            if ("patient_hong".equals(loginDto.getUsername()) && "password123".equals(loginDto.getPassword())) {

                LoginResponseDto loginResponse = new LoginResponseDto();
                loginResponse.setToken("dummy-token-12345");
                loginResponse.setRefreshToken("dummy-refresh-token-67890");
                loginResponse.setFirstLogin(false);

                UserDto user = new UserDto();
                user.setUsername("patient_hong");
                user.setPatientName("홍길동");
                user.setAge(35);
                user.setPhoneNumber("010-1234-5678");
                user.setAddress("서울특별시 강남구 테헤란로 123");
                user.setBloodType("A형");
                user.setRole("USER");
                user.setUserType("PATIENT");
                user.setActive(true);

                loginResponse.setUser(user);

                ApiResponse<LoginResponseDto> response = new ApiResponse<>();
                response.setSuccess(true);
                response.setMessage("로그인 성공");
                response.setData(loginResponse);

                return ResponseEntity.ok(response);
            }

            // 다른 테스트 계정들
            if ("test123".equals(loginDto.getUsername()) && "test123".equals(loginDto.getPassword())) {

                LoginResponseDto loginResponse = new LoginResponseDto();
                loginResponse.setToken("dummy-token-test123");
                loginResponse.setRefreshToken("dummy-refresh-test123");
                loginResponse.setFirstLogin(false);

                UserDto user = new UserDto();
                user.setUsername("test123");
                user.setPatientName("테스트사용자");
                user.setAge(30);
                user.setPhoneNumber("010-0000-0000");
                user.setAddress("테스트주소");
                user.setBloodType("O형");
                user.setRole("USER");
                user.setUserType("PATIENT");
                user.setActive(true);

                loginResponse.setUser(user);

                ApiResponse<LoginResponseDto> response = new ApiResponse<>();
                response.setSuccess(true);
                response.setMessage("로그인 성공");
                response.setData(loginResponse);

                return ResponseEntity.ok(response);
            }

            // 잘못된 로그인 정보
            ApiResponse<LoginResponseDto> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("잘못된 사용자명 또는 비밀번호입니다.");
            return ResponseEntity.badRequest().body(response);

        } catch (Exception e) {
            ApiResponse<LoginResponseDto> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("로그인 처리 중 오류: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 환자 회원가입 - 임시 하드코딩 버전
     */
    @PostMapping("/register/patient")
    public ResponseEntity<ApiResponse<UserDto>> registerPatient(@Valid @RequestBody PatientRegistrationDto registrationDto) {
        try {
            // 임시 하드코딩 회원가입 (테스트용)
            // 실제로는 DB에 저장하지 않고 성공 응답만 반환

            UserDto user = new UserDto();
            user.setId(System.currentTimeMillis()); // 임시 ID
            user.setUsername(registrationDto.getUsername());
            user.setPatientName(registrationDto.getPatientName());
            user.setAge(registrationDto.getAge());
            user.setPhoneNumber(registrationDto.getPhoneNumber());
            user.setAddress(registrationDto.getAddress());
            user.setBirthDate(registrationDto.getBirthDate());
            user.setBloodType(registrationDto.getBloodType());
            user.setRole("USER");
            user.setUserType("PATIENT");
            user.setActive(true);

            ApiResponse<UserDto> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("환자 회원가입 성공 (테스트)");
            response.setData(user);

            return ResponseEntity.ok(response);

            // 실제 DB 회원가입 (나중에 활성화)
            /*
            try {
                UserDto user = userService.registerPatient(registrationDto);

                ApiResponse<UserDto> response = new ApiResponse<>();
                response.setSuccess(true);
                response.setMessage("환자 회원가입 성공");
                response.setData(user);

                return ResponseEntity.ok(response);
            } catch (Exception dbException) {
                ApiResponse<UserDto> response = new ApiResponse<>();
                response.setSuccess(false);
                response.setMessage(dbException.getMessage());
                return ResponseEntity.badRequest().body(response);
            }
            */

        } catch (Exception e) {
            ApiResponse<UserDto> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("회원가입 처리 중 오류: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 사용자명 중복 체크 - 임시 하드코딩 버전
     */
    @GetMapping("/check-username/{username}")
    public ResponseEntity<ApiResponse<Boolean>> checkUsername(@PathVariable String username) {
        try {
            // 임시로 patient_hong과 test123만 중복으로 처리
            boolean isAvailable = !"patient_hong".equals(username) && !"test123".equals(username);

            ApiResponse<Boolean> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage(isAvailable ? "사용 가능한 사용자명입니다." : "이미 사용 중인 사용자명입니다.");
            response.setData(isAvailable);

            return ResponseEntity.ok(response);

            // 실제 DB 체크 (나중에 활성화)
            /*
            try {
                boolean isAvailable = userService.isUsernameAvailable(username);

                ApiResponse<Boolean> response = new ApiResponse<>();
                response.setSuccess(true);
                response.setMessage(isAvailable ? "사용 가능한 사용자명입니다." : "이미 사용 중인 사용자명입니다.");
                response.setData(isAvailable);

                return ResponseEntity.ok(response);
            } catch (Exception dbException) {
                ApiResponse<Boolean> response = new ApiResponse<>();
                response.setSuccess(false);
                response.setMessage("사용자명 확인에 실패했습니다.");
                response.setData(false);
                return ResponseEntity.badRequest().body(response);
            }
            */

        } catch (Exception e) {
            ApiResponse<Boolean> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("사용자명 확인 중 오류가 발생했습니다.");
            response.setData(false);
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 토큰 갱신 - 임시 구현
     */
    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<TokenDto>> refreshToken(@RequestBody TokenRefreshDto refreshDto) {
        try {
            // 임시 토큰 갱신
            TokenDto tokenDto = new TokenDto();
            tokenDto.setAccessToken("new-dummy-token-" + System.currentTimeMillis());
            tokenDto.setRefreshToken("new-dummy-refresh-" + System.currentTimeMillis());
            // setTokenType 메서드가 없으므로 제거
            tokenDto.setExpiresIn(3600L);

            ApiResponse<TokenDto> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("토큰 갱신 성공");
            response.setData(tokenDto);

            return ResponseEntity.ok(response);

            // 실제 토큰 갱신 (나중에 활성화)
            /*
            TokenDto tokenDto = userService.refreshToken(refreshDto.getRefreshToken());

            ApiResponse<TokenDto> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("토큰 갱신 성공");
            response.setData(tokenDto);

            return ResponseEntity.ok(response);
            */

        } catch (Exception e) {
            ApiResponse<TokenDto> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("토큰 갱신 실패: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }

    /**
     * 로그아웃 - 임시 구현
     */
    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<String>> logout(@RequestHeader(value = "Authorization", required = false) String token) {
        try {
            // 임시로 항상 성공 반환
            ApiResponse<String> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("로그아웃 성공");
            response.setData("로그아웃되었습니다.");

            return ResponseEntity.ok(response);

            // 실제 로그아웃 (나중에 활성화)
            /*
            userService.logout(token);

            ApiResponse<String> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("로그아웃 성공");
            response.setData("로그아웃되었습니다.");

            return ResponseEntity.ok(response);
            */

        } catch (Exception e) {
            ApiResponse<String> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("로그아웃 실패: " + e.getMessage());
            return ResponseEntity.badRequest().body(response);
        }
    }
}