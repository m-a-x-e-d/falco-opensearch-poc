#!/bin/bash
echo "======================================================================"
echo
echo "Waiting for OpenSearch node at $OPENSEARCH_HOST to be ready..."

until curl -s -k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
        "$OPENSEARCH_HOST/_cluster/health" \
        | grep -q '"status"' ; do
    echo "OpenSearch not ready yet. Retrying in 5 seconds..."
    sleep 5
done

echo "OpenSearch node is ready."
echo "======================================================================"
echo

echo "Checking if index template 'falco-template' exists..."

template_exists=$(curl -s -k -o /dev/null -w "%{http_code}" \
  -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
  "$OPENSEARCH_HOST/_index_template/falco-template")

if [ "$template_exists" == "200" ]; then
    echo "Index template 'falco-template' already exists. Skipping template creation."
else
    echo "Index template 'falco-template' does NOT exist. Creating it..."

    curl -s -k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
         -X POST "$OPENSEARCH_HOST/_index_template/falco-template" \
         -H "Content-Type: application/json" \
         -d @/app/saved_objects/falco_indextemplate.json
    echo
    echo "Index template 'falco-template' created."
fi
echo "======================================================================"
echo

echo "Checking if index template 'auditbeat-template' exists..."

template_exists=$(curl -s -k -o /dev/null -w "%{http_code}" \
  -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
  "$OPENSEARCH_HOST/_index_template/auditbeat-template")

if [ "$template_exists" == "200" ]; then
    echo "Index template 'auditbeat-template' already exists. Skipping template creation."
else
    echo "Index template 'auditbeat-template' does NOT exist. Creating it..."

    curl -s -k -u "$OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD" \
         -X POST "$OPENSEARCH_HOST/_index_template/auditbeat-template" \
         -H "Content-Type: application/json" \
         -d @/app/saved_objects/auditbeat_indextemplate.json
    echo
    echo "Index template 'auditbeat-template' created."
fi

echo "======================================================================"
echo
echo "Waiting for OpenSearch Dashboards to be ready..."
until curl -s -o /dev/null -w "%{http_code}" -u $OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD "$DASHBOARDS_HOST/api/status" | grep -q "200"; do
  echo "Dashboards not ready yet. Retrying in 5 seconds..."
  sleep 5
done

echo "Dashboards is ready. Loading saved objects..."
echo

echo "Loading Dashboard (falco_dashboard.ndjson)..."
curl -s -u $OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD \
     -H "osd-xsrf: true" \
     -X POST "$DASHBOARDS_HOST/api/saved_objects/_import?overwrite=true" \
     -F "file=@/app/saved_objects/falco_dashboard.ndjson"
echo
echo "Dashboard loaded successfully."
echo "======================================================================"
echo


echo "Loading Indexpattern (auditbeat_indexpattern.ndjson)..."
curl -s -u $OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD \
     -H "osd-xsrf: true" \
     -X POST "$DASHBOARDS_HOST/api/saved_objects/_import?overwrite=true" \
     -F "file=@/app/saved_objects/auditbeat_indexpattern.ndjson"
echo
echo "Indexpattern loaded successfully."
echo "======================================================================"
echo

echo "Initialization completed successfully."
exit 0
