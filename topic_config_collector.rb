require "kafka"
require "dotenv"

Dotenv.load

class TopicConfigCollector < PrometheusExporter::Server::TypeCollector
  def initialize
    @retention = PrometheusExporter::Metric::Gauge.new("kafka_topic_retention", "Kafka topic retention (ms)")
  end

  def type
    "config"
  end

  def collect(obj)
    if obj["retention"].is_a?(Integer)
      @retention.observe(obj["retention"])
    end
  end

  def metrics
    subscribe
    [@retention]
  end


  private

  def subscribe
    kafka.topics.each do |topic|
      retention = kafka.describe_topic(topic, ["retention.ms"])["retention.ms"]
      @retention.observe(retention.to_i, topic: topic)
    end
  end

  def kafka
    Kafka.new(ENV["KAFKA_BROKER_URLS"].split(","))
  end
end
