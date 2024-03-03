# Stage 1: Build the application
FROM gradle:8.6.0-jdk17-jammy AS builder

WORKDIR /app

# Copy only the Gradle files first to leverage Docker cache
COPY build.gradle .
COPY settings.gradle .

# Copy the source code
COPY src src

# Build the application
USER root
RUN chown -R gradle:gradle /app

USER gradle
RUN gradle clean build -x test --no-daemon

# Stage 2: Run the application
FROM bellsoft/liberica-runtime-container:jre-17-slim-musl

WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /app/build/libs/*.jar app.jar

# Expose the port that the application will run on
EXPOSE 8080

# Command to run the application
CMD ["java", "-jar", "app.jar"]
