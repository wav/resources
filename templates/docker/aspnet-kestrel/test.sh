containerId=`docker run -d -p 8080:5004 asp-net-sample`

if [[ "$containerId" == "" ]]; then
    echo Container did not start >&2 && exit 1
fi

ipAddress=`docker inspect -f "{{ .NetworkSettings.IPAddress }}" $containerId`

state=`docker inspect -f "{{ .State.Running }}" $containerId`

sleep 5

echo STATE=$state for $ipAddress $containerId

[[ "$state" != 'true' ]] && \
(
    echo Container is not running, cannot query it >&2
    docker logs $containerId
) && exit 1

# the port has been mapped to localhost also because of the PUBLISH instruction `-p 8080:5004` used in `docker run`.

echo -------------------
echo GET $ipAddress:5004
echo -------------------

curl $ipAddress:5004

echo -------------------
echo GET localhost:8080
echo -------------------

curl localhost:8080