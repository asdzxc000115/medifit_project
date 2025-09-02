package com.medifit.service;

import com.medifit.entity.Appointment;
import com.medifit.entity.Medication;
import com.medifit.entity.Patient;
import com.medifit.enums.MedicationStatus;
import com.medifit.enums.MedicationTime;
import com.medifit.repository.AppointmentRepository;
import com.medifit.repository.MedicationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
public class NotificationService {

    private static final Logger logger = LoggerFactory.getLogger(NotificationService.class);

    @Autowired
    private AppointmentRepository appointmentRepository;

    @Autowired
    private MedicationRepository medicationRepository;

    /**
     * 복약 알림 전송 (매시간 정각에 실행)
     */
    @Scheduled(cron = "0 0 * * * *") // 매시간 정각
    public void sendScheduledMedicationReminders() {
        LocalTime currentTime = LocalTime.now();

        try {
            // 현재 시간을 MedicationTime으로 변환
            MedicationTime medicationTime = convertToMedicationTime(currentTime);
            List<Medication> medications = medicationRepository.findMedicationsByTime(medicationTime);

            for (Medication medication : medications) {
                sendMedicationNotification(medication);
            }

            logger.info("복약 알림 전송 완료 - 대상 약물: {}개", medications.size());
        } catch (Exception e) {
            logger.error("복약 알림 전송 중 오류 발생", e);
        }
    }

    /**
     * 특정 시간대 복약 알림 전송 (Controller에서 호출용)
     */
    public void sendMedicationReminders(String timeSlot) {
        try {
            LocalTime targetTime = LocalTime.parse(timeSlot);
            MedicationTime medicationTime = convertToMedicationTime(targetTime);

            List<Medication> medications = medicationRepository.findMedicationsByTime(medicationTime);

            for (Medication medication : medications) {
                sendMedicationNotification(medication);
            }

            logger.info("복약 알림 전송 완료 - 시간대: {}, 대상 약물: {}개", timeSlot, medications.size());
        } catch (Exception e) {
            logger.error("복약 알림 전송 중 오류 발생 - 시간대: {}", timeSlot, e);
        }
    }

    /**
     * 진료 예약 알림 전송 (매일 오전 9시)
     */
    @Scheduled(cron = "0 0 9 * * *") // 매일 오전 9시
    public void sendAppointmentReminders() {
        LocalDateTime tomorrow = LocalDateTime.now().plusDays(1);
        LocalDateTime startOfTomorrow = tomorrow.toLocalDate().atStartOfDay();
        LocalDateTime endOfTomorrow = startOfTomorrow.plusDays(1).minusSeconds(1);

        try {
            // 내일 예약된 진료 조회
            List<Appointment> appointments = appointmentRepository
                    .findByAppointmentDateBetweenOrderByAppointmentDateAsc(startOfTomorrow, endOfTomorrow);

            for (Appointment appointment : appointments) {
                if (!appointment.getReminderSent()) {
                    sendAppointmentNotification(appointment);
                    appointment.setReminderSent(true);
                    appointment.setReminderSentAt(LocalDateTime.now());
                    appointmentRepository.save(appointment);
                }
            }

            logger.info("진료 예약 알림 전송 완료 - 대상 예약: {}개", appointments.size());
        } catch (Exception e) {
            logger.error("진료 예약 알림 전송 중 오류 발생", e);
        }
    }

    /**
     * 만료된 약물 상태 업데이트 (매일 자정에 실행)
     */
    @Scheduled(cron = "0 0 0 * * *") // 매일 자정
    public void updateExpiredMedications() {
        try {
            // 활성 상태인 모든 약물을 조회하여 각각의 만료일 체크
            List<Medication> activeMedications = medicationRepository.findByStatusOrderByCreatedAtDesc(MedicationStatus.ACTIVE);

            LocalDateTime now = LocalDateTime.now();
            int updatedCount = 0;

            for (Medication medication : activeMedications) {
                // 약물 종료일이 지났는지 확인
                LocalDateTime expiryDate = medication.getEndDate().atStartOfDay();

                if (now.isAfter(expiryDate)) {
                    // 약물 상태를 'COMPLETED'로 변경
                    medication.setStatus(MedicationStatus.COMPLETED);
                    medication.setUpdatedAt(LocalDateTime.now());
                    medicationRepository.save(medication);
                    updatedCount++;

                    logger.info("만료된 약물 상태 업데이트: {} - {} ({}일간 복용)",
                            medication.getId(),
                            medication.getMedicationName(),
                            java.time.temporal.ChronoUnit.DAYS.between(medication.getStartDate(), medication.getEndDate())
                    );
                }
            }

            logger.info("만료된 약물 상태 업데이트 완료 - 대상 약물: {}개", updatedCount);
        } catch (Exception e) {
            logger.error("만료된 약물 상태 업데이트 중 오류 발생", e);
        }
    }

    /**
     * LocalTime을 MedicationTime으로 변환하는 유틸리티 메서드
     */
    private MedicationTime convertToMedicationTime(LocalTime time) {
        int hour = time.getHour();

        if (hour >= 6 && hour < 9) {
            return MedicationTime.BEFORE_BREAKFAST;
        } else if (hour >= 9 && hour < 12) {
            return MedicationTime.AFTER_BREAKFAST;
        } else if (hour >= 12 && hour < 13) {
            return MedicationTime.BEFORE_LUNCH;
        } else if (hour >= 13 && hour < 18) {
            return MedicationTime.AFTER_LUNCH;
        } else if (hour >= 18 && hour < 19) {
            return MedicationTime.BEFORE_DINNER;
        } else if (hour >= 19 && hour < 22) {
            return MedicationTime.AFTER_DINNER;
        } else {
            return MedicationTime.BEFORE_SLEEP;
        }
    }

    /**
     * 복약 알림 전송
     */
    private void sendMedicationNotification(Medication medication) {
        try {
            Patient patient = medication.getPatient();

            String message = String.format(
                    "[복약 알림] %s님, %s 복용 시간입니다. 용량: %s, 복용법: %s",
                    patient.getName(),
                    medication.getMedicationName(),
                    medication.getDosage(),
                    medication.getInstructions() != null ? medication.getInstructions() : "의사 지시대로 복용"
            );

            // 실제 알림 전송 로직 (이메일, SMS, 푸시 등)
            // 여기서는 로그로만 처리
            logger.info("복약 알림: {}", message);

        } catch (Exception e) {
            logger.error("복약 알림 전송 실패: {}", medication.getId(), e);
        }
    }

    /**
     * 진료 예약 알림 전송
     */
    private void sendAppointmentNotification(Appointment appointment) {
        try {
            Patient patient = appointment.getPatient();

            String message = String.format(
                    "[진료 예약 알림] %s님, 내일 %s에 %s 진료 예약이 있습니다. 병원: %s, 진료과: %s",
                    patient.getName(),
                    appointment.getAppointmentDate().toLocalTime(),
                    appointment.getAppointmentDate().toLocalDate(),
                    appointment.getHospital().getHospitalName() != null ?
                            appointment.getHospital().getHospitalName() : "병원",
                    appointment.getDepartment()
            );

            // 실제 알림 전송 로직 (이메일, SMS, 푸시 등)
            // 여기서는 로그로만 처리
            logger.info("진료 예약 알림: {}", message);

        } catch (Exception e) {
            logger.error("진료 예약 알림 전송 실패: {}", appointment.getId(), e);
        }
    }

    /**
     * 예약 확인 알림 전송
     */
    public void sendAppointmentConfirmation(Long appointmentId) {
        try {
            Appointment appointment = appointmentRepository.findById(appointmentId)
                    .orElseThrow(() -> new RuntimeException("예약을 찾을 수 없습니다."));

            Patient patient = appointment.getPatient();

            String message = String.format(
                    "[예약 확인] %s님, %s %s에 %s 진료 예약이 확정되었습니다.",
                    patient.getName(),
                    appointment.getAppointmentDate().toLocalDate(),
                    appointment.getAppointmentDate().toLocalTime(),
                    appointment.getDepartment()
            );

            // 실제 알림 전송 로직
            logger.info("예약 확인 알림: {}", message);

        } catch (Exception e) {
            logger.error("예약 확인 알림 전송 실패: {}", appointmentId, e);
        }
    }

    /**
     * 예약 취소 알림 전송
     */
    public void sendAppointmentCancellation(Long appointmentId) {
        try {
            Appointment appointment = appointmentRepository.findById(appointmentId)
                    .orElseThrow(() -> new RuntimeException("예약을 찾을 수 없습니다."));

            Patient patient = appointment.getPatient();

            String message = String.format(
                    "[예약 취소] %s님, %s %s %s 진료 예약이 취소되었습니다.",
                    patient.getName(),
                    appointment.getAppointmentDate().toLocalDate(),
                    appointment.getAppointmentDate().toLocalTime(),
                    appointment.getDepartment()
            );

            // 실제 알림 전송 로직
            logger.info("예약 취소 알림: {}", message);

        } catch (Exception e) {
            logger.error("예약 취소 알림 전송 실패: {}", appointmentId, e);
        }
    }

    /**
     * 처방전 알림 전송
     */
    public void sendPrescriptionNotification(Long prescriptionId) {
        try {
            // 처방전 조회 및 알림 전송 로직
            String message = String.format("[처방전 알림] 새로운 처방전이 발급되었습니다. ID: %s", prescriptionId);

            logger.info("처방전 알림: {}", message);

        } catch (Exception e) {
            logger.error("처방전 알림 전송 실패: {}", prescriptionId, e);
        }
    }

    /**
     * 일반 알림 전송
     */
    public void sendGeneralNotification(String recipient, String title, String message) {
        try {
            String fullMessage = String.format("[%s] %s", title, message);

            // 실제 알림 전송 로직
            logger.info("일반 알림 - 수신자: {}, 메시지: {}", recipient, fullMessage);

        } catch (Exception e) {
            logger.error("일반 알림 전송 실패 - 수신자: {}", recipient, e);
        }
    }
}