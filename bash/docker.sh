docker::ip() {
  echo $DOCKER_HOST | grep -Eo '[0-9]{2,3}\.[0-9]{2,3}\.[0-9]{2,3}\.[0-9]{2,3}'
}