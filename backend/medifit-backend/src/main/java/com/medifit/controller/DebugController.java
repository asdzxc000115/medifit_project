package com.medifit.controller;

import com.medifit.entity.User;
import com.medifit.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/debug")
public class DebugController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/test-password")
    public String testPassword() {
        // 1. DB에서 patient_hong 사용자를 직접 찾습니다.
        User user = userRepository.findByUsername("patient_hong")
                .orElse(null);

        if (user == null) {
            return "'patient_hong' 사용자를 DB에서 찾을 수 없습니다.";
        }

        // 2. 앱에서 보냈다고 가정한 'password123'과 DB의 해시를 직접 비교합니다.
        boolean isMatch = passwordEncoder.matches("password123", user.getPassword());

        // 3. 결과를 브라우저에 직접 출력합니다.
        return "'password123' 비밀번호 일치 결과: " + isMatch;
    }

    @GetMapping("/test-username/{username}")
    public String testUsernameExists(@PathVariable String username) {
        // 1. 전달받은 username이 DB에 존재하는지 직접 확인합니다.
        boolean exists = userRepository.existsByUsername(username);

        // 2. 결과를 브라우저에 직접 출력합니다.
        return "'" + username + "' 존재 여부: " + exists;
    }
}