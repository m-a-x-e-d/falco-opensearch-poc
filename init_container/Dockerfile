FROM alpine:3.17

RUN apk --no-cache add curl bash

WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh


#COPY saved_objects/falco_dashboard.ndjson /app/saved_objects/falco_dashboard.ndjson
#COPY saved_objects/falco_indexmapping.ndjson /app/saved_objects/falco_indexmapping.ndjson


RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]