-- 1. 사용자(환자) 테이블 (키, 몸무게, 혈액형, 생일 등 포함)
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  name VARCHAR(50) NOT NULL,
  gender ENUM('M', 'F', 'O') DEFAULT 'O',
  birth DATE,                        -- 생일
  phone VARCHAR(20),
  height DECIMAL(5,2),               -- 키 (cm)
  weight DECIMAL(5,2),               -- 몸무게 (kg)
  blood_type VARCHAR(3),             -- 혈액형 (예: A, B, AB, O)
  allergy TEXT,                      -- 알레르기 정보 (콤마 구분)
  chronic_disease TEXT,              -- 만성질환 정보 (콤마 구분)
  emergency_contact_name VARCHAR(50),
  emergency_contact_phone VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. 건강 기록 테이블 (예: 혈압, 혈당 등)
CREATE TABLE health_records (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  record_type VARCHAR(50) NOT NULL, -- 예: 'blood_pressure', 'blood_sugar'
  value VARCHAR(100) NOT NULL,
  measured_at DATETIME NOT NULL,
  memo VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. AI 채팅 기록 테이블
CREATE TABLE ai_chat_logs (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  message TEXT NOT NULL,
  is_user BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 4. 예약/상담 기록 테이블
CREATE TABLE reservations (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  reservation_type VARCHAR(50), -- 예: 'doctor', 'nutritionist'
  reserved_at DATETIME NOT NULL,
  status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
  memo VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 5. 복약 관리 테이블
CREATE TABLE medications (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  medicine_name VARCHAR(100) NOT NULL,
  dosage VARCHAR(50),
  frequency VARCHAR(50),
  start_date DATE,
  end_date DATE,
  memo VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 6. 병원 테이블 (기본 병원 정보)
CREATE TABLE hospitals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  address VARCHAR(255),
  phone VARCHAR(30),
  latitude DOUBLE,
  longitude DOUBLE,
  type VARCHAR(50), -- 예: '종합병원', '의원', '약국' 등
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. 즐겨찾기 병원 테이블 (유저별 즐겨찾기)
CREATE TABLE favorite_hospitals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  hospital_id INT NOT NULL,
  memo VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  UNIQUE KEY unique_favorite (user_id, hospital_id)
);

-- =========================
-- 더미 데이터 삽입
-- =========================

-- 병원 5개
INSERT INTO hospitals (name, address, phone, latitude, longitude, type) VALUES
('서울대학교병원', '서울 종로구 대학로 101', '02-2072-2114', 37.579617, 126.997819, '종합병원'),
('삼성서울병원', '서울 강남구 일원로 81', '02-3410-2114', 37.488981, 127.085749, '종합병원'),
('세브란스병원', '서울 서대문구 연세로 50', '1599-1004', 37.563617, 126.962367, '종합병원'),
('강북삼성병원', '서울 종로구 새문안로 29', '02-2001-2001', 37.567817, 126.966484, '종합병원'),
('서울아산병원', '서울 송파구 올림픽로 43길 88', '1688-7575', 37.526016, 127.107664, '종합병원');

-- 예시 사용자 1명
INSERT INTO users (
  email, password, name, gender, birth, phone, height, weight, blood_type,
  allergy, chronic_disease, emergency_contact_name, emergency_contact_phone
) VALUES (
  'testuser@email.com',
  '$2b$10$abcdefghijklmnopqrstuv', -- bcrypt 해시 예시
  '홍길동',
  'M',
  '1990-01-01',
  '010-1234-5678',
  175.5,
  68.2,
  'A',
  '계란, 우유',
  '고혈압, 당뇨',
  '김철수',
  '010-8765-4321'
);

-- 예약 더미 데이터 (user_id=1)
INSERT INTO reservations (user_id, reservation_type, reserved_at, status, memo) VALUES
(1, 'doctor', '2025-09-10 10:00:00', 'confirmed', '정기 건강검진 예약'),
(1, 'nutritionist', '2025-09-15 14:00:00', 'pending', '영양 상담 예약');

-- 진료기록 더미 데이터 (user_id=1)
INSERT INTO health_records (user_id, record_type, value, measured_at, memo) VALUES
(1, 'blood_pressure', '120/80', '2025-09-01 09:00:00', '정상 혈압'),
(1, 'blood_sugar', '95', '2025-09-01 09:00:00', '공복 혈당 정상'),
(1, 'weight', '68.2', '2025-09-01 09:00:00', '체중 측정');

-- 복약관리 더미 데이터 (user_id=1)
INSERT INTO medications (user_id, medicine_name, dosage, frequency, start_date, end_date, memo) VALUES
(1, '아모디핀정 5mg', '1정', '하루 1회', '2025-09-01', '2025-09-30', '고혈압 약'),
(1, '글루코파지정 500mg', '1정', '하루 2회', '2025-09-01', '2025-09-30', '당뇨병 약');