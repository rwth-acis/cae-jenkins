#!/bin/bash

USER=admin
PASSWORD_FILE=$JENKINS_HOME/secrets/initialAdminPassword
JENKINS_HOST="http://127.0.0.1:8082$JENKINS_PREFIX/"
PASS=""

create_job () {
    JOB_NAME=$1
    CRUMB=$2
    CREATE_JOB_URL=$JENKINS_HOST/createItem?name=$JOB_NAME
    JOB_CONFIG=jobs/$JOB_NAME.xml
    echo "Creating $JOB_NAME"
    curl -X POST -H "$CRUMB" -H "Content-Type:text/xml" -u $USER:$PASS $CREATE_JOB_URL --data-binary @$JOB_CONFIG -o /dev/null
}

check_password_file () {
    while [[ ! -f "$PASSWORD_FILE" ]]; do
        echo "Waiting admin password"
        sleep 5
    done
    PASS=$(cat $PASSWORD_FILE)
}

check_jenkins () {
    while [[ $(curl -s -w "%{http_code}" -u $USER:$PASS $JENKINS_HOST -o /dev/null) != "200" ]]; do
        echo "Waiting for Jenkins"
        sleep 5
    done
    sleep 5
}

get_crumb () {
    CRUMB=$(curl -s -u $USER:$PASS "$JENKINS_HOST/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
}

replace_placeholders () {
    sed -i "s=<cae-deployment-temp-repo>=$TEMP_DEPLOYMENT_REPO=g" jobs/Build-Job.xml
    sed -i "s=<jenkins-job-token>=$JENKINS_JOB_TOKEN=g" jobs/Build-Job.xml    
    sed -i "s=<jenkins-job-token>=$JENKINS_JOB_TOKEN=g" jobs/Docker-Job.xml    
    sed -i "s=<jenkins-job-token>=$JENKINS_JOB_TOKEN=g" jobs/Docker-Job.xml    
    sed -i "s=<cae-deployment-docker-image>=$CAE_DEPLOYMENT_DOCKER_IMAGE=g" jobs/Docker-Job.xml    
}

check_password_file
check_jenkins
replace_placeholders
get_crumb
create_job "Build-Job" $CRUMB
create_job "Docker-Job" $CRUMB
create_job "DEPLOY_FAILURE" $CRUMB
create_job "Helm" $CRUMB
