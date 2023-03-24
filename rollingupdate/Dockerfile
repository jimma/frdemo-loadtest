FROM registry.redhat.io/jboss-eap-7/eap74-openjdk11-openshift-rhel8:latest
COPY --chown=jboss:root ROOT.war $JBOSS_HOME/standalone/deployments
RUN chmod -R ug+rwX $JBOSS_HOME