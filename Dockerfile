FROM quay.io/keycloak/keycloak:23.0.7 AS builder

COPY docker-entrypoint.sh /opt/tools

ENTRYPOINT [ "/opt/tools/docker-entrypoint.sh" ]

# Enable health and metrics support
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

FROM quay.io/keycloak/keycloak:23.0.7
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh", "start"]
