#!/bin/bash

#### Check environment variables ####
ENV_VARIABLE_NOT_SET=false
check_if_exists () {
    if [[ -z "$1" ]]; then
        echo "$2 env variable is not set"
        ENV_VARIABLE_NOT_SET=true
    fi
}

check_if_exists "$JENKINS_JOB_TOKEN" JENKINS_JOB_TOKEN
check_if_exists "$TEMP_DEPLOYMENT_REPO" TEMP_DEPLOYMENT_REPO
check_if_exists "$CAE_DEPLOYMENT_DOCKER_IMAGE" CAE_DEPLOYMENT_DOCKER_IMAGE
check_if_exists "$MICROSERVICE_WEBCONNECTOR_PORT" MICROSERVICE_WEBCONNECTOR_PORT
check_if_exists "$WIDGET_HTTP_PORT" WIDGET_HTTP_PORT
check_if_exists "$MICROSERVICE_PORT" MICROSERVICE_PORT
check_if_exists "$JENKINS_URL" JENKINS_URL
check_if_exists "$DEPLOYMENT_URL" DEPLOYMENT_URL

if [ "$ENV_VARIABLE_NOT_SET" = true ] ; then
    echo "Missing environment variables, exiting..."
    exit 1
fi

./setup-jenkins.sh &

export JAVA_OPTS="-Dhudson.security.csrf.DefaultCrumbIssuer.EXCLUDE_SESSION_ID=true $JAVA_OPTS"
/usr/local/bin/jenkins.sh
