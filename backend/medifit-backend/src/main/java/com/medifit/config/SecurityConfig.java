package com.medifit.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                // CORS 설정
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))

                // CSRF 비활성화 (REST API이므로)
                .csrf(csrf -> csrf.disable())

                // H2 콘솔을 위한 설정
                .headers(headers -> headers.disable())

                // 세션 사용하지 않음
                .sessionManagement(session -> session
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )

                // 권한 설정 - 개발 중에는 모든 요청 허용
                .authorizeHttpRequests(authz -> authz
                                // 인증 관련 엔드포인트 - 명시적으로 허용
                                .requestMatchers(
                                        "/api/auth/**",                  // auth 관련 모든 요청
                                        "/api/auth/login",
                                        "/api/auth/login-test",
                                        "/api/auth/register/patient",
                                        "/api/auth/register/hospital",
                                        "/api/auth/check-username/**",
                                        "/api/auth/refresh",
                                        "/api/auth/logout"
                                ).permitAll()

                                // 기존 user 엔드포인트
                                .requestMatchers(
                                        "/api/users/register",
                                        "/api/users/login",
                                        "/api/users/verify-business",
                                        "/api/users/**"
                                ).permitAll()

                                // 테스트 및 디버그 엔드포인트
                                .requestMatchers(
                                        "/api/test/**",
                                        "/api/debug/**"
                                ).permitAll()

                                // H2 콘솔
                                .requestMatchers("/h2-console/**").permitAll()

                                // 개발 중: 모든 API 요청 허용
                                .requestMatchers("/api/**").permitAll()

                                // 그 외 모든 요청도 허용 (개발 중)
                                .anyRequest().permitAll()

                        // 운영 환경에서는 아래와 같이 설정
                        // .anyRequest().authenticated()
                );

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // 모든 origin 허용 (개발용)
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));

        // 모든 HTTP 메서드 허용
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));

        // 모든 헤더 허용
        configuration.setAllowedHeaders(Arrays.asList("*"));

        // 인증 정보 포함 허용
        configuration.setAllowCredentials(true);

        // preflight 요청 캐시 시간
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}