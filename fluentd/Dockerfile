FROM fluent/fluentd:v1.15-1
USER root
RUN gem install fluent-plugin-opensearch
COPY fluent.conf /fluentd/etc/fluent.conf