FROM mongo:8.0.8
COPY ./key/* /secrets/
RUN chown 999:999 /secrets/*
RUN chmod 600 /secrets/*
