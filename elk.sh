#!/bin/bash
# Instalar Elasticsearch
sudo wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.17.10-amd64.deb
sudo dpkg -i ./elasticsearch-7.17.10-amd64.deb
      
# Configurar Elasticsearch
sudo sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
sudo sed -i 's/#discovery.seed_hosts: \[\"host1\", \"host2\"\]/discovery.seed_hosts: \[\"localhost\"\]/' /etc/elasticsearch/elasticsearch.yml
echo "discovery.type: single-node" | sudo tee -a /etc/elasticsearch/elasticsearch.yml

sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service

# Instalar Logstash
sudo wget https://artifacts.elastic.co/downloads/logstash/logstash-7.17.10-amd64.deb
sudo dpkg -i ./logstash-7.17.10-amd64.deb


# Configurar Logstash -- en tres ficheros separados ligados a los tres elementos: input - filter - output (creo que queda más claro)
sudo tee /etc/logstash/conf.d/01-input.conf << EOF
input {
  beats {
    port => 5044
    type => "apache"
  }
  file {
    path => "/var/log/syslog"
    type => "syslog"
  }
}

EOF

sudo tee /etc/logstash/conf.d/02-filter.conf << EOF
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGBASE} %{GREEDYDATA:message}" 
      }
  }
  if [type] == "apache" {
    grok {
      match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
  } 
  date {
    match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
  }
}

EOF

sudo tee /etc/logstash/conf.d/03-output.conf << EOF
output {
  if [type] == "apache" {
    elasticsearch {
      hosts => ["localhost:9200"]
      index => "%{[@metadata][beat]}-%{[@metadata][version]}-%{+YYYY.MM.dd}"
    }
  }
  if [type] == "syslog" {
    elasticsearch {
      hosts => ["localhost:9200"]
      index => "syslog-%{+YYYY.MM.dd}"
    }
  }
}

EOF

sudo systemctl enable logstash.service
sudo systemctl start logstash.service

# Instalar Kibana
sudo wget https://artifacts.elastic.co/downloads/kibana/kibana-7.17.10-amd64.deb
sudo dpkg -i ./kibana-7.17.10-amd64.deb

# Configurar Kibana
sudo tee /etc/kibana/kibana.yml << EOF
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
EOF

sudo systemctl enable kibana.service
sudo systemctl start kibana.service
