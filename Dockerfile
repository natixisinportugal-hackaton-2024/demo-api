FROM openshift.artifactory.mycloud.intranatixis.com/ubi9/openjdk-21
LABEL maintainer="ld-sepia-devpool@natixis.com"
EXPOSE 8080
COPY target/*.jar app.jar
USER docker
ENTRYPOINT ["java", "-Duser.timezone=Europe/Paris","-jar","app.jar"]