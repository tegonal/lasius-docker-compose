FROM mongo:9.0.2
COPY ./key/* /secrets/
RUN chown 999:999 /secrets/*
RUN chmod 600 /secrets/*
