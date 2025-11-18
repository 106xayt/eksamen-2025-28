package com.aialpha.sentiment.metrics;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

@Component
public class SentimentMetrics {

    private final MeterRegistry meterRegistry;

    // Aggregert counter
    private final Counter totalAnalyses;

    // Aggregert timer (uten ekstra tags)
    private final Timer analysisTimer;

    // Gauge – antall selskaper i siste analyse
    private final AtomicInteger companiesLastRun = new AtomicInteger(0);

    // Aggregert distribution summary for confidence
    private final DistributionSummary confidenceDist;

    // Constructor injection of MeterRegistry
    public SentimentMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;

        this.totalAnalyses = Counter.builder("sentiment.analysis.total")
                .description("Total number of sentiment analysis requests")
                .tag("candidate", "28") // tilpass hvis annet kandidatnummer
                .register(meterRegistry);

        this.analysisTimer = Timer.builder("sentiment.analysis.duration")
                .description("Latency of external sentiment/LLM calls (ms)")
                .publishPercentiles(0.5, 0.9, 0.99)
                .tag("candidate", "28")
                .register(meterRegistry);

        // Gauge koblet til companiesLastRun
        io.micrometer.core.instrument.Gauge.builder(
                        "sentiment.analysis.companies.detected",
                        companiesLastRun,
                        AtomicInteger::get)
                .description("Number of companies detected in the last analysis")
                .tag("candidate", "28")
                .register(meterRegistry);

        this.confidenceDist = DistributionSummary.builder("sentiment.analysis.confidence")
                .description("Distribution of confidence scores (0.0–1.0)")
                .baseUnit("ratio")
                .publishPercentiles(0.5, 0.9, 0.99)
                .tag("candidate", "28")
                .register(meterRegistry);
    }

    /**
     * Counter for sentiment analysis requests
     * Denne bruker dynamiske tags for sentiment + company,
     * og oppdaterer også en aggregert counter uten ekstra tags.
     */
    public void recordAnalysis(String sentiment, String company) {
        Counter.builder("sentiment.analysis.total")
                .description("Total number of sentiment analysis requests")
                .tag("candidate", "28")
                .tag("sentiment", safe(sentiment))
                .tag("company", safe(company))
                .register(meterRegistry)
                .increment();

        // aggregert total
        totalAnalyses.increment();
    }

    /**
     * Timer: hvor lang tid et eksternt kall tok (f.eks. Bedrock)
     * @param milliseconds varighet i millisekunder
     * @param company selskap/sammenheng
     * @param model modellnavn (f.eks. nova-micro)
     */
    public void recordDuration(long milliseconds, String company, String model) {
        // per-kall med tags
        Timer.builder("sentiment.analysis.duration")
                .description("Latency of external sentiment/LLM calls (ms)")
                .tag("candidate", "28")
                .tag("company", safe(company))
                .tag("model", safe(model))
                .register(meterRegistry)
                .record(milliseconds, TimeUnit.MILLISECONDS);

        // aggregert timer uten ekstra tags
        analysisTimer.record(milliseconds, TimeUnit.MILLISECONDS);
    }

    /**
     * Gauge: antall selskaper funnet i siste analyse
     */
    public void recordCompaniesDetected(int count) {
        companiesLastRun.set(count);
    }

    /**
     * DistributionSummary: fordeling av confidence-scorer (0.0–1.0)
     */
    public void recordConfidence(double confidence, String sentiment, String company) {
        // per-kall med tags
        DistributionSummary.builder("sentiment.analysis.confidence")
                .description("Confidence per entity")
                .baseUnit("ratio")
                .tag("candidate", "28")
                .tag("sentiment", safe(sentiment))
                .tag("company", safe(company))
                .register(meterRegistry)
                .record(confidence);

        // aggregert summary
        confidenceDist.record(confidence);
    }

    private static String safe(String value) {
        return (value == null || value.isBlank()) ? "unknown" : value;
    }
}
