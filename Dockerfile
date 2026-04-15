FROM tomcat:9
COPY target/myapp.war /usr/local/tomcat/webapps/
