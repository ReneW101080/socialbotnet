FROM eclipse-temurin:17-jdk AS build

WORKDIR /app

# Copy Maven wrapper and config
COPY .mvn .mvn
COPY mvnw pom.xml ./

# Copy source code
COPY src src
COPY apidoc-template apidoc-template
COPY apidoc.json ./

# Build the project (skip tests, use production profile)
RUN chmod +x mvnw && ./mvnw -DoutputFile=target/mvn-dependency-list.log -B -DskipTests clean dependency:list install -Pproduction

# Runtime stage
FROM eclipse-temurin:17-jre

WORKDIR /app
COPY --from=build /app/target/socialbotnet-4.2-jar-with-dependencies.jar ./target/

CMD ["java", "-jar", "target/socialbotnet-4.2-jar-with-dependencies.jar"]

