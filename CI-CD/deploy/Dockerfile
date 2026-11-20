# Imagen de producción (Java 8 / Spring Boot 2.2.1)
# docker build -f CI-CD/deploy/Dockerfile -t actuator-demo:local .

# ---------------------------------------------------------------------------
# Etapa 1: BUILD
# ---------------------------------------------------------------------------
FROM bellsoft/liberica-runtime-container:jdk-8-slim-musl AS builder

WORKDIR /build

# Wrapper Maven
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

COPY src/ src/

# Empaquetado
RUN ./mvnw -B -e clean package -DskipTests
RUN ls -l target/*.jar


# ---------------------------------------------------------------------------
# Etapa 2: RUNTIME
# ---------------------------------------------------------------------------
FROM bellsoft/liberica-runtime-container:jre-8-slim-musl AS runtime

# Etiquetas OCI
LABEL org.opencontainers.image.title="actuator-demo" \
      org.opencontainers.image.description="Spring Boot Actuator demo" \
      org.opencontainers.image.vendor="callicoder / AlanVieyra333" \
      org.opencontainers.image.authors="alan.vieyra376@gmail.com" \
      org.opencontainers.image.source="https://github.com/AlanVieyra333/spring-boot-actuator-demo"

# Usuario de servicio sin privilegios
ARG APP_USER=app
ARG APP_UID=10001
ARG APP_GID=10001
RUN addgroup -g "${APP_GID}" "${APP_USER}" \
    && adduser -u "${APP_UID}" -G "${APP_USER}" -D -h /app "${APP_USER}" \
    && mkdir -p /app \
    && chown -R "${APP_UID}:${APP_GID}" /app

WORKDIR /app

# Copiar unicamente el artefacto
COPY --from=builder --chown=${APP_UID}:${APP_GID} /build/target/*.jar /app/app.jar
RUN chmod 0444 /app/app.jar

USER ${APP_UID}:${APP_GID}

# Puerto por defecto de la aplicación
EXPOSE 8080

# Manejo de memoria de la JVM
ENV JAVA_TOOL_OPTIONS="-XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError -Dfile.encoding=UTF-8"

# Healthcheck /actuator/health
# ActuatorSecurityConfig.java: EndpointRequest.toAnyEndpoint().permitAll()
HEALTHCHECK --start-period=45s --interval=30s --timeout=5s --retries=3 \
    CMD wget --spider -q http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
