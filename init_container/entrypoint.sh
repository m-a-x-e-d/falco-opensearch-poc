#!/bin/bash

echo "Waiting for OpenSearch Dashboards to be ready..."
until curl -s -o /dev/null -w "%{http_code}" -u $OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD "$DASHBOARDS_HOST/api/status" | grep -q "200"; do
  echo "Dashboards not ready yet. Retrying in 5 seconds..."
  sleep 5
done

echo "Dashboards is ready. Loading saved objects..."

echo "Loading Index Mapping (falco_indexmapping.ndjson)..."
curl -s -u $OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD \
     -H "osd-xsrf: true" \
     -X POST "$DASHBOARDS_HOST/api/saved_objects/_import?overwrite=true" \
     -F "file=@/app/saved_objects/falco_indexmapping.ndjson"

echo "Index Mapping loaded."

echo "Loading Dashboard (falco_dashboard.ndjson)..."
curl -s -u $OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD \
     -H "osd-xsrf: true" \
     -X POST "$DASHBOARDS_HOST/api/saved_objects/_import?overwrite=true" \
     -F "file=@/app/saved_objects/falco_dashboard.ndjson"

echo "Dashboard loaded successfully."
