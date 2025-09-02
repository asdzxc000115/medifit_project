package com.medifit.controller;

import com.medifit.dto.ApiResponse;
import com.medifit.dto.UserDto;
import com.medifit.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 환자 통계 조회
     */
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<Object>> getPatientStats() {
        try {
            // 환자 수 조회
            long patientCount = userService.getTotalPatientCount();

            Map<String, Object> data = new HashMap<>();
            data.put("patientCount", patientCount);
            data.put("message", patientCount > 0 ?
                    patientCount + "명의 환자가 등록되어 있습니다." :
                    "등록된 환자가 없습니다.");

            ApiResponse<Object> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("환자 통계 조회 성공");
            response.setData(data);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Object> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("환자 통계 조회에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(500).body(response);
        }
    }

    /**
     * 환자 정보 조회
     */
    @GetMapping("/{userId}")
    public ResponseEntity<ApiResponse<UserDto>> getUser(@PathVariable Long userId) {
        try {
            UserDto userData = userService.getUser(userId);

            ApiResponse<UserDto> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage("환자 정보 조회 성공");
            response.setData(userData);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<UserDto> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("환자 정보 조회에 실패했습니다: " + e.getMessage());

            return ResponseEntity.status(404).body(response);
        }
    }

    /**
     * 사용자명 중복 체크
     */
    @GetMapping("/check-username/{username}")
    public ResponseEntity<ApiResponse<Boolean>> checkUsername(@PathVariable String username) {
        try {
            boolean isAvailable = userService.isUsernameAvailable(username);

            ApiResponse<Boolean> response = new ApiResponse<>();
            response.setSuccess(true);
            response.setMessage(isAvailable ? "사용 가능한 사용자명입니다." : "이미 사용 중인 사용자명입니다.");
            response.setData(isAvailable);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            ApiResponse<Boolean> response = new ApiResponse<>();
            response.setSuccess(false);
            response.setMessage("사용자명 확인에 실패했습니다: " + e.getMessage());
            response.setData(false);

            return ResponseEntity.status(500).body(response);
        }
    }
}