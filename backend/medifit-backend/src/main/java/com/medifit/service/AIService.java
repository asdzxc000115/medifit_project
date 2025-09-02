package com.medifit.service;

import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class AIService {

    private static final Logger logger = LoggerFactory.getLogger(AIService.class);

    /**
     * 진료 기록을 AI로 요약
     */
    public String summarizeMedicalRecord(String symptoms, String diagnosis, String treatment, String doctorNotes) {
        try {
            // TODO: ChatGPT API 연동하여 진료 기록 요약 생성

            StringBuilder summary = new StringBuilder();
            summary.append("【AI 진료 요약】\n");

            if (symptoms != null && !symptoms.isEmpty()) {
                summary.append("증상: ").append(symptoms).append("\n");
            }

            if (diagnosis != null && !diagnosis.isEmpty()) {
                summary.append("진단: ").append(diagnosis).append("\n");
            }

            if (treatment != null && !treatment.isEmpty()) {
                summary.append("치료: ").append(treatment).append("\n");
            }

            if (doctorNotes != null && !doctorNotes.isEmpty()) {
                summary.append("의사 소견: ").append(doctorNotes).append("\n");
            }

            summary.append("\n※ AI가 생성한 요약으로, 정확한 내용은 담당 의사에게 확인하시기 바랍니다.");

            logger.info("AI 진료 기록 요약 생성 완료");
            return summary.toString();

        } catch (Exception e) {
            logger.error("AI 진료 기록 요약 생성 실패", e);
            return "AI 요약 생성 중 오류가 발생했습니다.";
        }
    }

    /**
     * 처방전 설명을 AI로 생성
     */
    public String explainPrescription(String medicationName, String dosage, String instructions) {
        try {
            // TODO: ChatGPT API 연동하여 처방전 설명 생성

            StringBuilder explanation = new StringBuilder();
            explanation.append("【AI 처방전 설명】\n");
            explanation.append("약물명: ").append(medicationName).append("\n");
            explanation.append("용량: ").append(dosage).append("\n");

            if (instructions != null && !instructions.isEmpty()) {
                explanation.append("복용 방법: ").append(instructions).append("\n");
            }

            explanation.append("\n※ 상세한 복용법은 약사 또는 담당 의사에게 문의하시기 바랍니다.");

            logger.info("AI 처방전 설명 생성 완료: {}", medicationName);
            return explanation.toString();

        } catch (Exception e) {
            logger.error("AI 처방전 설명 생성 실패: {}", medicationName, e);
            return "처방전 설명 생성 중 오류가 발생했습니다.";
        }
    }

    /**
     * 복약 지도를 AI로 생성
     */
    public String generateMedicationGuidance(String medicationName, String patientAge, String allergies) {
        try {
            // TODO: ChatGPT API 연동하여 복약 지도 생성

            StringBuilder guidance = new StringBuilder();
            guidance.append("【AI 복약 지도】\n");
            guidance.append("약물: ").append(medicationName).append("\n\n");

            guidance.append("주의사항:\n");
            guidance.append("- 정해진 시간에 규칙적으로 복용하세요\n");
            guidance.append("- 충분한 물과 함께 복용하세요\n");

            if (allergies != null && !allergies.isEmpty()) {
                guidance.append("- 알레르기 주의: ").append(allergies).append("\n");
            }

            guidance.append("\n부작용 발생 시 즉시 담당 의사나 약사에게 연락하세요.");

            logger.info("AI 복약 지도 생성 완료: {}", medicationName);
            return guidance.toString();

        } catch (Exception e) {
            logger.error("AI 복약 지도 생성 실패: {}", medicationName, e);
            return "복약 지도 생성 중 오류가 발생했습니다.";
        }
    }

    /**
     * 건강 상담을 AI로 제공
     */
    public String provideHealthConsultation(String symptoms, String patientInfo) {
        try {
            // TODO: ChatGPT API 연동하여 건강 상담 제공

            StringBuilder consultation = new StringBuilder();
            consultation.append("【AI 건강 상담】\n\n");
            consultation.append("증상: ").append(symptoms).append("\n\n");

            consultation.append("일반적인 관리 방법:\n");
            consultation.append("- 충분한 휴식을 취하세요\n");
            consultation.append("- 수분을 충분히 섭취하세요\n");
            consultation.append("- 증상이 지속되면 병원을 방문하세요\n\n");

            consultation.append("⚠️ 중요: 이는 일반적인 정보 제공용이며, 정확한 진단과 치료는 의료진과 상담하시기 바랍니다.");

            logger.info("AI 건강 상담 제공 완료");
            return consultation.toString();

        } catch (Exception e) {
            logger.error("AI 건강 상담 제공 실패", e);
            return "건강 상담 중 오류가 발생했습니다. 의료진과 직접 상담하시기 바랍니다.";
        }
    }
}