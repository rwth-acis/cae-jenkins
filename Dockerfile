FROM jenkins/jenkins:2.275

ENV JENKINS_JOB_TOKEN 1475f18c-561d-4c6b-8ffa-4d3ed65d96ea
ENV TEMP_DEPLOYMENT_REPO https://github.com/CAE-Community-Application-Editor/CAE-Deployment-Temp
ENV CAE_DEPLOYMENT_DOCKER_IMAGE registry.tech4comp.dbis.rwth-aachen.de/rwthacis/cae-deployment:master
ENV MICROSERVICE_WEBCONNECTOR_PORT 8088
ENV WIDGET_HTTP_PORT 8087
ENV MICROSERVICE_PORT 8086
ENV JENKINS_PREFIX /

USER root
RUN apt-get update && \
	apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common nginx && \
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" && \
	apt-get update && \
	apt-get install -y docker-ce ant

WORKDIR /var/jenkins_home
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY setup_java_14.groovy /var/jenkins_home/init.groovy.d/setup_java_14.groovy

WORKDIR /var/cae
COPY jobs ./jobs
COPY docker-entrypoint.sh .
COPY setup-jenkins.sh .
COPY nginx.conf .

ENTRYPOINT []
CMD ["./docker-entrypoint.sh"]
