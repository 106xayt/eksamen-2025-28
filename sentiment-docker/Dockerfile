# ---------- build stage (Maven + Java 21) ----------
FROM maven:3.9.9-eclipse-temurin-21 AS build
WORKDIR /workspace

# Leverage layer cache for deps
COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline

# Build the app
COPY src ./src
RUN mvn -q -DskipTests package

# ---------- runtime stage (Amazon Corretto 21 Alpine) ----------
FROM amazoncorretto:21-alpine
WORKDIR /app

# non-root user
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

# copy fat jar from the build stage
# (picks the only JAR in /workspace/target)
COPY --from=build /workspace/target/*.jar /app/app.jar

# app port
EXPOSE 8080

# optional JVM tuning
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0"

# run the jar
ENTRYPOINT ["sh","-c","java $JAVA_OPTS -jar /app/app.jar"]
