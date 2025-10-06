FROM eclipse-temurin:17-jre-alpine
ARG JAR_FILE=demo-micro/target/*.jar
COPY ${JAR_FILE} /app.jar
ENV PORT=8080
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app.jar","--server.port=${PORT}"]
