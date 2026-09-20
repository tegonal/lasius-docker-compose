FROM mongo:8.3.11
COPY key/* /secrets/
RUN chown 999:999 /secrets/*
RUN chmod 600 /secrets/*
