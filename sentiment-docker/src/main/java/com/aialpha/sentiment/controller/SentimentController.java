package com.aialpha.sentiment.controller;

import com.aialpha.sentiment.model.AnalysisRequest;
import com.aialpha.sentiment.model.CompanySentiment;
import com.aialpha.sentiment.model.SentimentResult;
import com.aialpha.sentiment.service.BedrockService;
import com.aialpha.sentiment.service.S3StorageService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class SentimentController {

    private final BedrockService bedrockService;
    private final S3StorageService s3StorageService;

    public SentimentController(BedrockService bedrockService,
                               S3StorageService s3StorageService) {
        this.bedrockService = bedrockService;
        this.s3StorageService = s3StorageService;
    }

    @PostMapping("/analyze")
    public ResponseEntity<SentimentResult> analyzeSentiment(@RequestBody AnalysisRequest request) {
        try {
            // Call Bedrock to analyze sentiment (inkluderer nå all metrikk-logging)
            List<CompanySentiment> companies = bedrockService.analyzeSentiment(request.getText());

            // Create result
            SentimentResult result = new SentimentResult(
                    request.getRequestId(),
                    "AI-Powered (AWS Bedrock + Claude)",
                    bedrockService.getModelId(),
                    companies
            );

            // Store in S3
            s3StorageService.storeResult(result);

            return ResponseEntity.ok(result);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("OK");
    }
}
