## Overview

This project creates a PoC for security monitoring environment.

## Prerequisites

- Docker and Docker Compose
- Linux host (for Falco monitoring functionality)

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/m-a-x-e-d/falco-opensearch-poc.git
   cd falco-opensearch-poc
   ```

2. Create a `.env` file with the following variables:
   ```
   OPENSEARCH_PASSWORD=your_secure_password
   OPENSEARCH_HOST=https://opensearch-node:9200
   HOSTNAME=your_host_name
   ```

3. Start the environment:
   ```bash
   docker-compose up -d
   ```

4. Access OpenSearch Dashboards:
   ```
   http://localhost:5601
   ```
   Default credentials (if not changed in environment):
   - Username: `admin`
   - Password: value of `OPENSEARCH_PASSWORD` in your `.env` file

## Architecture

The solution consists of the following components:

- **Falco**: Monitors system calls on the host, detecting security events based on pre-defined rules (there is only one rule, as the goal is to use Sigma rules within OpenSearch in the future)
- **Fluentd**: Receives Falco events via Docker logging driver and forwards them to OpenSearch
- **OpenSearch**: Stores and indexes security event data
- **OpenSearch Dashboards**: Provides visualization and analysis capabilities
- **Init Container**: One-time setup container that creates necessary indices and dashboards

## Configuration

### Falco

Falco is configured via two main files:
- `./falco/falco.yaml`: General Falco configuration
- `./falco/falco_rules.yaml`: Detection rules

You can customize detection rules by modifying the `falco_rules.yaml` file.

### Fluentd

Fluentd configuration is in `./fluentd/fluent.conf`. It's set up to:
1. Receive Falco events via the Docker logging driver
2. Format and forward events to OpenSearch

### OpenSearch

The OpenSearch instance runs with a single node for simplicity. For production use, consider configuring a multi-node cluster.

Security features are enabled with basic authentication. The default admin password is set via the `OPENSEARCH_PASSWORD` environment variable.

### Dashboards & Index Patterns

Pre-configured dashboards and index patterns for both Falco events and Linux audit logs are automatically created by the init container on startup.


## Extending
- Work on Sigma Rules in OpenSearch to show current OpenSearch limitations