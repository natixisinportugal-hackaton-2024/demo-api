FROM bzn-docker-jaas.artifactory.mycloud.intranatixis.com/tools/maven3/apache-maven-3.8.4-jdk-21.0.2:1.5 as builder
USER 0
WORKDIR /app
COPY pom.xml .
COPY src src
RUN mvn package -DskipTests
RUN java -Djarmode=layertools -jar target/*.jar extract

FROM openshift.artifactory.mycloud.intrabpce.fr/ubi8/openjdk-21:1.20
WORKDIR /app
COPY --from=builder app/dependencies/ ./
COPY --from=builder app/spring-boot-loader/ ./
COPY --from=builder app/snapshot-dependencies/ ./
COPY --from=builder app/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]

EXPOSE 8080
