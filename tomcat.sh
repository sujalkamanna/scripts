#!/bin/bash

# Update packages
sudo apt update -y

# Install Java 21 (OpenJDK)
sudo apt install openjdk-21-jdk -y

# Download Tomcat 11
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.14/bin/apache-tomcat-11.0.14.tar.gz

# Extract
tar -zxvf apache-tomcat-11.0.14.tar.gz

# Add manager-gui and manager-script roles
sudo sed -i '56  a\<role rolename="manager-gui"/>' apache-tomcat-11.0.14/conf/tomcat-users.xml
sudo sed -i '57  a\<role rolename="manager-script"/>' apache-tomcat-11.0.14/conf/tomcat-users.xml

# Add user with roles
sudo sed -i '58  a\<user username="tomcat" password="root123456" roles="manager-gui, manager-script"/>' apache-tomcat-11.0.14/conf/tomcat-users.xml

# Close tomcat-users.xml
sudo sed -i '59  a\</tomcat-users>' apache-tomcat-11.0.14/conf/tomcat-users.xml

# Delete duplicated <tomcat-users> if any
sudo sed -i '56d' apache-tomcat-11.0.14/conf/tomcat-users.xml

# Remove restricted access in manager app
sudo sed -i '21d' apache-tomcat-11.0.14/webapps/manager/META-INF/context.xml
sudo sed -i '22d' apache-tomcat-11.0.14/webapps/manager/META-INF/context.xml

# Start Tomcat
sh apache-tomcat-11.0.14/bin/startup.sh
