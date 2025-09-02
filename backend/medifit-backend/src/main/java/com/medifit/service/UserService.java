package com.medifit.service;

import com.medifit.dto.*;
import com.medifit.entity.User;
import com.medifit.enums.Role;
import com.medifit.enums.UserType;
import com.medifit.repository.UserRepository;
import com.medifit.util.JwtUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    // ✅ [수정됨] final 키워드를 추가하여 불변성을 보장합니다.
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    // ✅ [수정됨] @Autowired 필드 주입 대신 생성자 주입 방식을 사용합니다.
    // 이 방식이 스프링에서 권장하는 가장 안전하고 명확한 방법입니다.
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder, JwtUtil jwtUtil) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
    }


    /**
     * 환자 회원가입 (환자 전용 앱)
     */
    public UserDto registerPatient(PatientRegistrationDto registrationDto) {
        try {
            // 중복 체크
            if (userRepository.existsByUsername(registrationDto.getUsername())) {
                throw new RuntimeException("이미 사용 중인 사용자명입니다.");
            }

            if (userRepository.existsByPhoneNumber(registrationDto.getPhoneNumber())) {
                throw new RuntimeException("이미 등록된 전화번호입니다.");
            }

            // 비밀번호 암호화
            String encodedPassword = passwordEncoder.encode(registrationDto.getPassword());

            // User 엔티티 생성 (환자만)
            User user = new User();
            user.setUsername(registrationDto.getUsername());
            user.setPassword(encodedPassword);
            user.setPatientName(registrationDto.getPatientName());
            user.setPhoneNumber(registrationDto.getPhoneNumber());
            user.setAddress(registrationDto.getAddress());
            user.setBirthDate(registrationDto.getBirthDate());
            user.setBloodType(registrationDto.getBloodType());
            user.setAge(registrationDto.getAge());
            user.setUserType(UserType.PATIENT);
            user.setRole(Role.USER);

            User savedUser = userRepository.save(user);
            logger.info("새 환자 등록 완료: {}", registrationDto.getUsername());

            return convertToDto(savedUser);
        } catch (Exception e) {
            logger.error("환자 등록 실패: {}", registrationDto.getUsername(), e);
            throw e;
        }
    }

    /**
     * 로그인 (환자 전용)
     */
    public LoginResponseDto login(LoginDto loginDto) {
        try {
            User user = userRepository.findByUsername(loginDto.getUsername())
                    .orElseThrow(() -> new RuntimeException("존재하지 않는 사용자입니다."));

            // 환자만 로그인 가능
            if (user.getUserType() != UserType.PATIENT) {
                throw new RuntimeException("환자만 이 앱을 사용할 수 있습니다.");
            }

            if (!passwordEncoder.matches(loginDto.getPassword(), user.getPassword())) {
                throw new RuntimeException("비밀번호가 일치하지 않습니다.");
            }

            if (!user.isActive()) {
                throw new RuntimeException("비활성화된 계정입니다.");
            }

            // JWT 토큰 생성
            String accessToken = jwtUtil.generateToken(user.getUsername(), user.getRole().toString());
            String refreshToken = jwtUtil.generateRefreshToken(user.getUsername());

            LoginResponseDto response = new LoginResponseDto();
            response.setToken(accessToken);
            response.setRefreshToken(refreshToken);
            response.setUser(convertToDto(user));
            response.setFirstLogin(false); // 일반 로그인은 첫 로그인이 아님

            logger.info("환자 로그인 성공: {}", loginDto.getUsername());
            return response;

        } catch (Exception e) {
            logger.error("로그인 실패: {}", loginDto.getUsername(), e);
            throw e;
        }
    }


    /**
     * 사용자명 중복 체크
     */
    public boolean isUsernameAvailable(String username) {
        return !userRepository.existsByUsername(username);
    }

    /**
     * 토큰 갱신
     */
    public TokenDto refreshToken(String refreshToken) {
        try {
            if (!jwtUtil.validateToken(refreshToken)) {
                throw new RuntimeException("유효하지 않은 리프레시 토큰입니다.");
            }

            String username = jwtUtil.getUsernameFromToken(refreshToken);
            User user = userRepository.findByUsername(username)
                    .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

            String newAccessToken = jwtUtil.generateToken(user.getUsername(), user.getRole().toString());
            String newRefreshToken = jwtUtil.generateRefreshToken(user.getUsername());

            TokenDto tokenDto = new TokenDto();
            tokenDto.setAccessToken(newAccessToken);
            tokenDto.setRefreshToken(newRefreshToken);
            tokenDto.setExpiresIn(jwtUtil.getExpirationTime());

            return tokenDto;

        } catch (Exception e) {
            logger.error("토큰 갱신 실패", e);
            throw e;
        }
    }

    /**
     * 로그아웃
     */
    public void logout(String token) {
        logger.info("로그아웃 처리");
    }

    /**
     * 사용자 정보 조회 (환자만)
     */
    public UserDto getUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        if (user.getUserType() != UserType.PATIENT) {
            throw new RuntimeException("환자 정보만 조회할 수 있습니다.");
        }

        return convertToDto(user);
    }

    /**
     * 전체 환자 수 조회
     */
    public long getTotalPatientCount() {
        return userRepository.countByUserType(UserType.PATIENT);
    }

    /**
     * User 엔티티를 UserDto로 변환 (환자 정보만)
     */
    private UserDto convertToDto(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setUserType(user.getUserType().toString());
        dto.setRole(user.getRole().toString());
        dto.setActive(user.isActive());
        dto.setCreatedAt(user.getCreatedAt());
        dto.setUpdatedAt(user.getUpdatedAt());

        // 환자 정보만 설정
        dto.setPatientName(user.getPatientName());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setAddress(user.getAddress());
        dto.setBirthDate(user.getBirthDate());
        dto.setBloodType(user.getBloodType());
        dto.setAge(user.getAge());

        return dto;
    }
}