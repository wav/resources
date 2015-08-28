FROM microsoft/aspnet:1.0.0-beta6

MAINTAINER noone

ADD Home/samples/1.0.0-beta6/HelloWeb /app

RUN cd /app && dnu restore

EXPOSE 5004

ENTRYPOINT ["dnx", "/app", "kestrel"]