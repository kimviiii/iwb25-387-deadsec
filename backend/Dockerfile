# Backend Dockerfile for Ballerina
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy the built JAR file
COPY target/bin/backend.jar ./

# Expose the port your Ballerina app runs on (default 8090)
EXPOSE 8090

# Run the Ballerina JAR
ENTRYPOINT ["java", "-jar", "backend.jar"]
