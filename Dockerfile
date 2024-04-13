FROM quay.io/keycloak/keycloak:23.0.7

COPY docker-entrypoint.sh /opt/tools

ENTRYPOINT [ "/opt/tools/docker-entrypoint.sh" ]
CMD ["-b", "0.0.0.0"]

