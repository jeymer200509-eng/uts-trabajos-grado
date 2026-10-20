# =====================================================================
# DOCKERFILE - SISTEMA DE TRABAJOS DE GRADO UTS
# Apache Tomcat 9 + Eclipse Temurin JRE 11
# Compatible con Railway, Render, Koyeb, Fly.io y VPS
# =====================================================================
FROM tomcat:9.0-jre11-temurin

# Eliminar aplicaciones predeterminadas de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiar aplicación completa directamente a la raíz (ROOT)
COPY . /usr/local/tomcat/webapps/ROOT/

# Limpiar archivos temporales dentro del contenedor
RUN rm -f /usr/local/tomcat/webapps/ROOT/ROOT.war \
    && rm -f /usr/local/tomcat/webapps/ROOT/Dockerfile \
    && rm -f /usr/local/tomcat/webapps/ROOT/docker-compose.yml

# Habilitar reemplazo de variables de entorno en Tomcat y codificación UTF-8
ENV CATALINA_OPTS="-Dorg.apache.tomcat.util.digester.PROPERTY_SOURCE=org.apache.tomcat.util.digester.EnvironmentPropertySource -Dfile.encoding=UTF-8"

# Exponer el puerto estándar
EXPOSE 8080

# Iniciar Tomcat en primer plano
CMD ["catalina.sh", "run"]
