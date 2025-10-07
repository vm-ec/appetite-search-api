# Build stage: Use OpenJDK 21 base image and install Maven manually
FROM eclipse-temurin:21-jdk AS build

# Install Maven
RUN apt-get update && \
    apt-get install -y maven && \
    apt-get clean

WORKDIR /

# Copy pom.xml and download dependencies first (for caching)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of the application source
COPY src ./src

# Package the app (skip tests for faster build)
RUN mvn clean package -DskipTests

# Runtime stage: Use slim JRE image
FROM eclipse-temurin:21-jre

WORKDIR /

# Copy the built JAR from the build stage
COPY --from=build /target/*.jar appetite-check-api.jar

# Expose port if needed
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "appetite-check-api.jar"]