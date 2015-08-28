## Usage

The docker host requires the tools: `bash`, `git` and `curl`.

Building the image:

```sh
bash$ chmod +x ./make.sh && ./make.sh
```

To test the image:

```sh
bash$ chmod +x ./test.sh && ./test.sh
```

This is what you should see when running `docker ps`.

```sh
CONTAINER ID  IMAGE           COMMAND             CREATED         STATUS         PORTS                   NAMES
8e62bb273210  asp-net-sample  "dnx /app kestrel"  46 seconds ago  Up 45 seconds  0.0.0.0:8080->5004/tcp  suspicious_hypatia 
```

*TIP: If you want to see the page outside of the docker host when using virtual box, either use a bridged network adapter in the VM's settings or configure the NAT network in Virtualbox's preferents*

**Happy Dockering :)**