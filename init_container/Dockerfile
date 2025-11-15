FROM alpine:3.17

RUN apk --no-cache add curl bash

WORKDIR /app

COPY entrypoint_main.sh /app/entrypoint_main.sh
COPY entrypoint_security_analytics.sh /app/entrypoint_security_analytics.sh

RUN chmod +x /app/entrypoint_main.sh
RUN chmod +x /app/entrypoint_security_analytics.sh

ENTRYPOINT ["/app/entrypoint_main.sh"]