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

# Copy the rest of the source code
COPY src ./src

# Build the application and skip tests (optional)
RUN mvn clean package -DskipTests

# Runtime stage: Use a slim JRE image
FROM eclipse-temurin:21-jre

WORKDIR /

# Copy the built JAR to the runtime container
COPY --from=build /app/target/search-api.jar /search-api.jar

# Expose the port your app runs on
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "appetite-check-api.jar"]
