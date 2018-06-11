# Introduction
This repository includes projects and templates created as base to deploy
Red Hat JBoss A-MQ for OpenShift brokers into Red Hat OpenShift Containers Platform.

* [A-MQ Custom Image](./): Project to build and create a new custom A-MQ 6.3 images. It modifies,
  from original Red Hat xPaaS image, launch script in order to not substitute values in
  activemq-xml, via openshift-activemq.xml. This file (and others configuration files)
  should be provided by you.
* [OpenShift A-MQ 6.3 Template](../amq63-templates): Template to deploy HA Messaging Services storing
  configuration in an Openshift ConfigMap. It contains:
      1. Service account 'amq-service-account'
      2. A 'view' role for this service account
      3. Two Openshift services: one for MQTT port and another one for Openwire A-MQ native port.
        Note that your activemq.xml needs to have this Transport Connectors enabled
      4. Two Openshift Deploymentconfigs: One is the A-MQ 6.3 broker and the second is the
        A-MQ 6.3 messages drainer.
* [ConfigMap files](../amq63-templastes/configmap): Example files for configuring A-MQ. Main file is 'activemq.xml'

# Global References

* [Red Hat JBoss A-MQ for OpenShift](https://access.redhat.com/documentation/en-us/red_hat_jboss_a-mq/6.3/html/red_hat_jboss_a-mq_for_openshift/)
* [OpenShift 3.5 release Notes](https://docs.openshift.com/container-platform/3.5/release_notes/index.html)
