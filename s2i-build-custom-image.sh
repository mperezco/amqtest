#!/bin/sh
set -eu

# Inditex Registry
#OCP_REGISTRY=axdesocp1reg.central.inditex.grp
OCP_REGISTRY=$(minishift openshift registry)

PROJECT=amqtuning

minishift docker-env
# Run this command to configure your shell:
eval $(minishift docker-env)

# Image Group and Name
OCP_IMAGE_GROUP=amqtuning
#OCP_IMAGE_GROUP=openshift
OCP_IMAGE_NAME=amq63-openshift-configmap
OCP_IMAGE_VERSION=0.1.5-ose-1.3-6

# A-MQ Image
AMQ_IMAGE=registry.access.redhat.com/jboss-amq-6/amq63-openshift:1.3-6

PATH=$PATH:/home/aboucham/s2i
export PATH

echo [s2i] Building A-MQ Custom Image
s2i build . $AMQ_IMAGE $OCP_IMAGE_GROUP/$OCP_IMAGE_NAME:$OCP_IMAGE_VERSION

echo [DOCKER] Login docker minishift registry
docker login -u developer -p $(oc whoami -t) $(minishift openshift registry)

echo [DOCKER] Tagging Image
docker tag $OCP_IMAGE_GROUP/$OCP_IMAGE_NAME:$OCP_IMAGE_VERSION $OCP_REGISTRY/$OCP_IMAGE_GROUP/$OCP_IMAGE_NAME:$OCP_IMAGE_VERSION

echo [DOCKER] Pushing into Registry $OCP_REGISTRY
docker push $OCP_REGISTRY/$OCP_IMAGE_GROUP/$OCP_IMAGE_NAME:$OCP_IMAGE_VERSION


#$ docker login -u developer -p <whatever>
#Login successful.
#Using project "myproject".
#$ docker login -u developer -p <whatever> 172.30.1.1:5000/${REGISTRY}/${PROJECT}/${IMAGE_NAME}:{IMAGE_VERSION}
#WARNING! Using --password via the CLI is insecure. Use --password-stdin.
#Login Succeeded
#$ docker tag ${IMAGE_NAME}:{IMAGE_VERSION} 172.30.1.1:5000/${REGISTRY}/${PROJECT}/${IMAGE_NAME}:{IMAGE_VERSION}
#$ docker push 172.30.1.1:5000/${REGISTRY}/${PROJECT}/${IMAGE_NAME}:{IMAGE_VERSION}
#$ oc new-app 172.30.1.1:5000/${REGISTRY}/${PROJECT}/${IMAGE_NAME}:{IMAGE_VERSION}
