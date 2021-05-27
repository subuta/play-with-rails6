#!/bin/bash

# For deploy local docker image to ECS.
VERBOSE=false
AWS_PROFILE=""
AWS_REGION="ap-northeast-1"
WORKSPACE="prod"
DOCKER_IMAGE="play-with-rails6_web"
DOCKER_TAG="latest"

# Check requirements
function require() {
    command -v "$1" > /dev/null 2>&1 || {
        echo "Some of the required software is not installed:"
        echo "    please install $1" >&2;
        exit 4;
    }
}

set -o errexit
set -o pipefail
set -u
set -e

# Check for AWS, AWS Command Line Interface and Docker command.
require aws
require docker

# Loop through arguments, two at a time for key and value
while [[ $# -gt 0 ]]
do
    key="$1"

    case $key in
        -p|--profile)
            AWS_PROFILE="$2"
            shift # past argument
            ;;
        -e|--env)
            WORKSPACE="$2"
            shift # past argument
            ;;
        -t|--tag)
            DOCKER_TAG="$2"
            shift # past argument
            ;;
        -i|--image)
            DOCKER_IMAGE="$2"
            shift # past argument
            ;;
        -v|--verbose)
            VERBOSE=true
            ;;
    esac
    shift # past argument or value
done

if [ $VERBOSE == true ]; then
    set -x
fi

printf "[start]ecr-deploy.sh \n\n"

printf "prepare deployment for ECR \n\n"

dockerImage="${DOCKER_IMAGE}_${WORKSPACE}:${DOCKER_TAG}"

echo "====== args [start] ======"
echo "WORKSPACE(env) = '${WORKSPACE}'"
echo "AWS_PROFILE = '${AWS_PROFILE}'"
echo "DOCKER_IMAGE = '${dockerImage}'"
printf "====== args [end] ======\n\n"

# Construct parameter for deployment to ECR.
dockerRegistry=`aws ecr get-authorization-token --profile $AWS_PROFILE --output text --query 'authorizationData[].proxyEndpoint' | sed -E 's/https:\/\/(.*)/\1/'`
dockerLogin=AWS
dockerPassword=`aws ecr get-login-password --profile $AWS_PROFILE`

printf "try docker login to ECR \n\n"

# Login to ECR
echo $dockerPassword | docker login -u $dockerLogin --password-stdin $dockerRegistry

printf "try push image to ECR \n\n"

# Tag local Docker Image
docker tag "${dockerImage}" "${dockerRegistry}/${dockerImage}"

# Push Docker Image To ECR.
docker push "${dockerRegistry}/${dockerImage}"

printf "done push image to ECR \n\n"

printf "[done]ecr-deploy.sh \n\n"