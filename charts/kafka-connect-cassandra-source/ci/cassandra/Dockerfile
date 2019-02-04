FROM cassandra:3.0
MAINTAINER Spiros Economakis <spiros@lenses.io>

RUN sed -e 's/authenticator: AllowAllAuthenticator/authenticator: PasswordAuthenticator/' \
        -i /etc/cassandra/cassandra.yaml