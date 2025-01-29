FROM mongo:5.0.31
COPY ./key/* /secrets/
RUN chown 999:999 /secrets/*
RUN chmod 600 /secrets/*
