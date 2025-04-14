FROM quay.io/keycloak/keycloak:26.1 AS builder

# Enable health and metrics support
ENV KC_DB=postgres
ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true
ENV KC_HTTP_RELATIVE_PATH=/keycloak

WORKDIR /opt/keycloak
# for demonstration purposes only, please make sure to use proper certificates in production instead
#RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:26.1

ENV LASIUS_URL=http://localhost

COPY --from=builder /opt/keycloak/ /opt/keycloak/
ADD keycloak-local-realm.json /opt/keycloak/data/import/lasius-local-realm.json

CMD ["start", "--import-realm", "--optimized"]
