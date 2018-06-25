# Spring Boot Actuator: Health Check, Auditing, Metrics Gathering and Monitoring 

## Tutorials 

1. [Spring Boot Actuator: Health check, Auditing, Metrics gathering and Monitoring](https://www.callicoder.com/spring-boot-actuator/)
2. [Spring Boot Actuator metrics monitoring with Prometheus and Grafana](https://www.callicoder.com/spring-boot-actuator-metrics-monitoring-dashboard-prometheus-grafana/)

## Steps to Setup

**1. Clone the application**

```bash
git clone https://github.com/callicoder/spring-boot-actuator-demo.git
```

**2. Build and run the app using maven**

```bash
mvn package
java -jar target/actuator-demo-0.0.1-SNAPSHOT.jar
```

Alternatively, you can run the app directly without packaging like this -

```bash
mvn spring-boot:run
```

The app will start running at <http://localhost:8080>.

## Explore Actuator Endpoints

All the actuator endpoints will be available at <http://localhost:8080/actuator>.

Some of the actuator endpoints are protected with Spring Security's HTTP Basic Authentication. You can use the username `actuator` and password `actuator` for http basic authentication.