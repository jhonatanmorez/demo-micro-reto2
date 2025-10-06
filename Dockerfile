FROM eclipse-temurin:17-jre-alpine
ARG JAR_FILE=demo-micro/target/*.jar
COPY ${JAR_FILE} /app.jar
EXPOSE 8082
ENTRYPOINT ["java","-jar","/app.jar"]
