FROM eclipse-temurin:17-jdk AS build
ARG JDBC_DATABASE_USERNAME
ARG JDBC_DATABASE_PASSWORD
ARG DB_HOST
ARG DB_PORT
ARG DB_DATABASE

WORKDIR /app

# Copy Maven wrapper and config
COPY .mvn .mvn
COPY mvnw pom.xml ./

# Copy source code
COPY src src
COPY apidoc-template apidoc-template
COPY apidoc.json ./

# Build the project (skip tests, use production profile)
RUN chmod +x mvnw
RUN ./mvnw -DskipTests clean package
#RUN ./mvnw flyway:migrate
#RUN . /mvnw -DoutputFile=target/mvn-dependency-list.log -B -DskipTests clean dependency:list install 
#-Pproduction

# Runtime stage
FROM eclipse-temurin:17-jre
ARG JDBC_DATABASE_USERNAME
ARG JDBC_DATABASE_PASSWORD
ARG DB_HOST
ARG DB_PORT
ARG DB_DATABASE

WORKDIR /app
COPY --from=build /app/target/socialbotnet-4.2-jar-with-dependencies.jar ./target/

# CMD ["java", "-jar", "target/socialbotnet-4.2-jar-with-dependencies.jar"]
ENV JDBC_DATABASE_URL="jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_DATABASE?user=$JDBC_DATABASE_USERNAME&password=$JDBC_DATABASE_PASSWORD&sslmode=require"
EXPOSE 30003
ENTRYPOINT ["java", "-jar", "target/socialbotnet-4.2-jar-with-dependencies.jar"]
