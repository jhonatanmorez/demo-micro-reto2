# Etapa 1: Build con Maven
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY demo-micro/pom.xml .
COPY demo-micro/src ./src
RUN mvn clean package spring-boot:repackage -DskipTests

# Etapa 2: Runtime minimal
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
