package com.medifit.controller;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/test")
@CrossOrigin(origins = "*")
public class TestController {

    @GetMapping("/hello")
    public String hello() {
        return "MediFit Backend가 정상적으로 작동중입니다! 🎉";
    }

    @GetMapping("/health")
    public String health() {
        return "✅ 서버 상태: 정상";
    }

    @PostMapping("/echo")
    public String echo(@RequestBody String message) {
        return "Echo: " + message;
    }
}