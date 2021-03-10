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
check_if_exists "$URL_JENKINS" URL_JENKINS
check_if_exists "$DEPLOYMENT_URL" DEPLOYMENT_URL
check_if_exists "$JENKINS_PREFIX" JENKINS_PREFIX
check_if_exists "$HOST_IP" HOST_IP

check_if_exists "$DOCKER_HUB_LOGIN" DOCKER_HUB_LOGIN
check_if_exists "$DOCKER_HUB_PASSWORD" DOCKER_HUB_PASSWORD
check_if_exists "$LAS2PEER_REGISTRY_URL" LAS2PEER_REGISTRY_URL
check_if_exists "$CLUSTER_HELM_URL" CLUSTER_HELM_URL
check_if_exists "$CLUSTER_REPO_URL" CLUSTER_REPO_URL
check_if_exists "$CAE_HELM_CHART_TEMPLATE" CAE_HELM_CHART_TEMPLATE

if [ "$ENV_VARIABLE_NOT_SET" = true ] ; then
    echo "Missing environment variables, exiting..."
    exit 1
fi


##### Nginx ####
cp /var/cae/nginx.conf /etc/nginx/conf.d/default.conf
sed -i "s=<host_ip>=$HOST_IP=g" /etc/nginx/conf.d/default.conf
sed -i "s=<widget_http_port>=$WIDGET_HTTP_PORT=g" /etc/nginx/conf.d/default.conf
sed -i "s=<microservice_webconnector_port>=$MICROSERVICE_WEBCONNECTOR_PORT=g" /etc/nginx/conf.d/default.conf
/etc/init.d/nginx start

./setup-jenkins.sh &

export JAVA_OPTS="-Dhudson.security.csrf.DefaultCrumbIssuer.EXCLUDE_SESSION_ID=true $JAVA_OPTS"
/usr/local/bin/jenkins.sh --prefix=$JENKINS_PREFIX
