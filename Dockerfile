FROM golang:latest
RUN go get -u github.com/cosmtrek/air
WORKDIR /app/backend

FROM ubuntu:latest
RUN apt-get update && apt-get install -y vim

ENTRYPOINT ["air"]