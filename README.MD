<pre>

###########################################
 SOLUCION ELK
 ___________________________-
 
 Logstash (recupera, transforma y envia logs)
 ElasticSearch (creación de índices, alamacenamiento de información en diferentes estructuras NoSQL)
 Kibana (presentación de datos)
###########################################
Fichero Vagrantfile con aprovisionamiento de wordpress y elk. 

La lectura de estos ficheros muestra la instalación de las diferentes herramientas y los ficheros de configuración básica

##################################################
Comprobación de apis de elasticSearch

curl localhost:9200/_cat/

Visualización de índices de ElasticSearch 
curl -XGET 'localhost:9200/_cat/indices?v'

Creando índice

curl -X PUT 'localhost:9200/filebeat-<version>-<fecha>'
##################################################
En kibana (puerto 5601) acceder a: 
Discover > administración de índices
Crear index pattern
Dashboard - creación de paneles.

</pre>
