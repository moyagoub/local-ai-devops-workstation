FROM public.ecr.aws/docker/library/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    JENKINS_HOME=/var/jenkins_home \
    JAVA_OPTS="-Djenkins.install.runSetupWizard=true -Djava.awt.headless=true"

RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-21-jre \
    fontconfig \
    fonts-dejavu-core \
    git \
    curl \
    ca-certificates \
    docker.io \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -d "$JENKINS_HOME" -u 1001 -m -s /bin/bash jenkins \
    && mkdir -p /usr/share/jenkins

COPY jenkins.war /usr/share/jenkins/jenkins.war
RUN chown -R jenkins:jenkins /usr/share/jenkins "$JENKINS_HOME"

VOLUME /var/jenkins_home
EXPOSE 8080 50000

USER jenkins
CMD ["java", "-Djava.awt.headless=true", "-jar", "/usr/share/jenkins/jenkins.war"]
