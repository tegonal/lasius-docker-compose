FROM mongo:7.0.16
COPY key/* /secrets/
RUN chown 999:999 /secrets/*
RUN chmod 600 /secrets/*
