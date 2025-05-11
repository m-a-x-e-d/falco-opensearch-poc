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


echo "Loading Falco Sigma Mapping"

curl -s -k -u $OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD \
     -XPOST "https://opensearch-node:9200/_plugins/_security_analytics/mappings" -H 'Content-Type: application/json' -d'
{
  "index_name": "falco-*",
   "rule_topic": "linux",
   "partial": true,
    "mappings": {
      "properties": {
        "timestamp": {
          "type": "alias",
          "path": "@timestamp"
        },
        "system": {
          "properties": {
            "auth": {
              "properties": {
                "user": {
                  "type": "alias",
                  "path": "USER"
                }
              }
            }
          }
        },
        "process": {
          "properties": {
            "working_directory": {
              "type": "alias",
              "path": "CurrentDirectory"
            },
            "real_user": {
              "properties": {
                "id": {
                  "type": "alias",
                  "path": "LogonId"
                }
              }
            },
            "parent": {
              "properties": {
                "executable": {
                  "type": "alias",
                  "path": "ParentImage"
                }
              }
            },
            "exe": {
              "type": "alias",
              "path": "Image"
            },
            "command_line": {
              "type": "alias",
              "path": "CommandLine"
            }
          }
        }
      }
    }

}'

echo "Loading Linux Sigma Detector"

curl -s -k -u $OPENSEARCH_USERNAME:$OPENSEARCH_PASSWORD \
     -X POST "https://opensearch-node:9200/_plugins/_security_analytics/detectors" -H 'Content-Type: application/json' -d'
{
    "name": "Linux Audit Detector",
    "detector_type": "linux",
    "enabled": true,
    "schedule": {
      "period": {
        "interval": 1,
        "unit": "MINUTES"
      }
    },
    "inputs": [
      {
        "detector_input": {
          "description": "",
          "indices": [
            "falco-*"
          ],
          "custom_rules": [],
          "pre_packaged_rules": [
            {
              "id": "e7bd1cfa-b446-4c88-8afb-403bcd79e3fa"
            },
            {
              "id": "4c519226-f0cd-4471-bd2f-6fbb2bb68a79"
            },
            {
              "id": "32e62bc7-3de0-4bb1-90af-532978fe42c0"
            },
            {
              "id": "c4042d54-110d-45dd-a0e1-05c47822c937"
            },
            {
              "id": "4e2f5868-08d4-413d-899f-dc2f1508627b"
            },
            {
              "id": "fa4aaed5-4fe0-498d-bbc0-08e3346387ba"
            }
          ]
        }
      }
    ],
    "threat_intel_enabled": false,
    "triggers": [
      {
        "id": "xHmKwJYBBgBzbKQmiXPT",
        "name": "Linux Trigger",
        "severity": "1",
        "types": [
          "linux"
        ],
        "ids": [],
        "sev_levels": [],
        "tags": [],
        "actions": [
          {
            "id": "",
            "name": "Triggered alert condition:  {{ctx.trigger.name}} - Severity: {{ctx.trigger.severity}} - Threat detector: {{ctx.detector.name}}",
            "destination_id": "",
            "message_template": {
              "source": "- Triggered alert condition: {{ctx.trigger.name}}\n - Severity: {{ctx.trigger.severity}}\n - Threat detector: {{ctx.detector.name}}\n - Description: {{ctx.detector.description}}\n - Detector data sources: {{ctx.detector.datasources}}",
              "lang": "mustache"
            },
            "throttle_enabled": false,
            "subject_template": {
              "source": "Triggered alert condition:  {{ctx.trigger.name}} - Severity: {{ctx.trigger.severity}} - Threat detector: {{ctx.detector.name}}",
              "lang": "mustache"
            },
            "throttle": {
              "value": 10,
              "unit": "MINUTES"
            }
          }
        ],
        "detection_types": [
          "rules"
        ]
      }
    ]
}'
