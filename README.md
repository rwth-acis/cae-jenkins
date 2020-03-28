# CAE Jenkins

[![Docker image][docker-build-image]][docker-repo]

CAE Jenkins is Jenkins which is customized for the CAE. This instance is used by CAE to deploy created applications. Docker image can be found in [here][docker-repo].

Customization includes installing necessary Jenkins plugins, creating build and deployment jobs. Basically, job xml's under `jobs` folder is uploaded to Jenkins instance after instance start to run. Setup logic can be found in `setup-jenkins.sh` script.

Jenkins instance has two jobs which are named as BuildJob and DockerJob after instance is started. BuildJob is fetching last version of the temporary deployment repo, building microservice and creating artifacts of microservice and frontend parts.
DockerJob is pulling [CAE Deployment Docker image][cae-deployment-docker-repo] and running it with necessary arguments. More informatoin about CAE Deployment can be found in its [Github repo][cae-deployment-github-repo].

Also, container contains Nginx instance to add reverse proxy to application which is deployed using CAE Deployment Docker container.

## Usage
Docker image can be built with following command:
```
$ cd cae-jenkins
$ docker build -t rwthacis/cae-jenkins .
```

Docker container can be run with following command:
```
# Jenkins will run on port 8082 locally in Docker container however host port mapping can be changed.
# Pass necessary environment variables which is specified in the following section with '-e' flag during initialization.
$ docker run -p 8082:8082 -e <env1>=<val1> rwthacis/cae-jenkins
```

After container and Jenkins instance is started to run, Jenkins instance can be accessed through `http://127.0.0.1:8082`. When accessed first time, admin password is required to complete initialization. Admin password can be found with following commands:
```
$ CAE_JENKINS_CONTAINER_ID=$(docker ps | grep rwthacis/cae-jenkins | cut -d' ' -f1)
$ JENKINS_ADMIN_PASSWORD=$(docker exec -it $CAE_JENKINS_CONTAINER_ID cat /var/jenkins_home/secrets/initialAdminPassword)
```

Also, if some CAE created application is deployed through CAE-Jenkins instance, it can be accessed via `http://127.0.0.1:8082/deploy`.

**Attention**: [CAE Code Generation Service][cae-code-generation-service] is triggering build job of Jenkins. In order to that, Jenkins instance need to be made anonymously readable. In order to that, login to Jenkins as admin using initialAdminPassword. After, enable `Allow anonymous read access` under following path: `Manage Jenkins` > `Configure Global Security` > `Authorization` 

Following environment variables are needed to be passed to container during initialization:
* `JENKINS_URL`: Url address of currently running container
* `DEPLOYMENT_URL`: Url address of application which will be deployed by CAE Jenkins. Since CAE Jenkins instance and deployment container which is started by CAE Jenkins instance will run on same server, they will have same root url adddress. However, they can have different relative path if they are behind reverse proxy. Therefore, two separate environment variable is used.
* `HOST_IP`: IP of host machine which CAE Jenkins Docker container is running. It is used to add reverse proxy to deployed application.

Following environment variables have default values however they can be changed during initialization:
* `JENKINS_JOB_TOKEN`: Token which is used to trigger Jenkins job during deployment. It can be generated randomly. It should be in UUID format.
* `TEMP_DEPLOYMENT_REPO`: Git repo address to store project temporary during deployment
* `CAE_DEPLOYMENT_DOCKER_IMAGE`: Docker image which is used during deployment
* `MICROSERVICE_WEBCONNECTOR_PORT`: WebConnector port of las2peer backend service of deployed application
* `MICROSERVICE_PORT`: Port of las2peer backend service of deployed application
* `JENKINS_PREFIX`: Path prefix to all paths of Jenkins. Let's say Jenkins is running on `127.0.0.1:8080` and login page of Jenkins is accessed with `127.0.0.1:8080/login` address. If `/jenkins` value is provided as `jenkins_prefix`, login page will be accessed with `127.0.0.1:8080/jenkins/login` from now on.

**Note**: Example Kubernetes configuration which CAE Jenkins Docker image is used can be found in the [main CAE repo][cae-main-repo].

 
[docker-build-image]: https://img.shields.io/docker/cloud/build/rwthacis/cae-jenkins
[docker-repo]: https://hub.docker.com/r/rwthacis/cae-jenkins
[cae-deployment-docker-repo]: https://hub.docker.com/r/rwthacis/cae-deployment
[cae-deployment-github-repo]: https://github.com/rwth-acis/cae-deployment
[cae-main-repo]: https://github.com/rwth-acis/CAE/
[cae-code-generation-service]: https://github.com/rwth-acis/CAE-Code-Generation-Service
