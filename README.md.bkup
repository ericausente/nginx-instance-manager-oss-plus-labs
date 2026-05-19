
# NIM-with-nginx-agent-in-a-container

## Method 1: Using the make command
Reference: https://docs.nginx.com/nginx-management-suite/nginx-agent/nginx-agent-in-container/


make is a build automation tool that is commonly used in software development to automate the building of executable programs and libraries from source code. 
It uses a Makefile, which is a script that defines how to build the program or library, and the dependencies between the different components.
In the context of building NGINX Agent container images, the Makefile contains rules that define how to build the NGINX Agent binary, the Debian and RPM packages, and the container images. 

By using make to build the NGINX Agent and container images, you can automate the build process and ensure that all the necessary dependencies are installed and configured correctly. 
The Makefile also makes it easy to customize the build process by allowing you to specify environment variables that control the build options, such as the version of the operating system or the location of the NGINX Plus license files.

Make sure to install go in your machine (in my case, it's in MAC, so I utilized brew): 

```
% brew install go
Running `brew update --auto-update`...
==> Auto-updated Homebrew!
Updated 2 taps (homebrew/core and homebrew/cask).
==> New Formulae
jet                                      nerdfix                                  ssocr
==> New Casks
1kc-razer                                                     music-remote
asix-ax88179                                                  music-widget
bose-updater                                                  obsbot-webcam
caldigit-docking-utility                                      opal
caldigit-thunderbolt-charging                                 pallotron-yubiswitch
concept2-utility                                              pololu-avr-programmer-v2
creative                                                      saleae-logic
genesys-cloud                                                 samsung-portable-ssd-t7
konica-minolta-bizhub-c759-c658-c368-c287-c3851-driver        shureplus-motiv
logitune                                                      volta
music-miniplayer                                              zsa-wally

You have 9 outdated formulae installed. 
```


Clone the NGINX Agent Github repository:
```
$ git clone https://github.com/nginx/agent.git
```

Navigate to the repository's root directory:
```
cd agent 
```

You need to obtain an NGINX Plus license in the form of .crt and .key files, and copy them to the [PATH_TO_NGINX_AGENT_SRC_ROOT]/build directory. Let's assume the license files are named nginx-repo.crt and nginx-repo.key.
```
mkdir build
```

Copy the NGINX Plus license files to the build directory:
```
cp [PATH_TO_LICENSE_CRT] build/nginx-repo.crt 
cp [PATH_TO_LICENSE_KEY] build/nginx-repo.key 
```
Replace [PATH_TO_LICENSE_CRT] and [PATH_TO_LICENSE_KEY] with the paths to your NGINX Plus license files.


Run the make image command:
```
# OS_RELEASE=ubuntu OS_VERSION=20.04 make image 


Building image with docker
#1 [internal] load build definition from Dockerfile
#1 sha256:5058e0f7923ee9058687bf1a8f20e36b34ff5a27275a2bac7321b6c7e07bd3ec
#1 transferring dockerfile: 3.11kB done
#1 DONE 0.0s![image](https://github.com/ericausente/NIM-with-nginx-agent-in-a-container/assets/17806308/e7ad47ca-f79f-4459-a99f-c8c7e7f1ded7)
... 

#15 exporting to image
#15 sha256:e8c613e07b0b7ff33893b694f7759a10d42e180f2b4dc349fb57dc6b71dcab00
#15 exporting layers
#15 exporting layers 1.0s done
#15 writing image sha256:c81417412821fa72d5d0f6141d69db418ec29997ccffce572f36ab5d332786fa done
#15 naming to docker.io/library/agent_ubuntu_22.04 done
#15 DONE 1.0s
![image](https://github.com/ericausente/NIM-with-nginx-agent-in-a-container/assets/17806308/00960dc4-1f39-4a40-84ce-08afc6a91abd)

```
This command will use the NGINX Plus license files in the build directory and build an NGINX Agent bundled with NGINX Plus image for Ubuntu 20.04. The resulting image will be tagged as nginx/nginx-agent:latest.
Note that we used the OS_RELEASE and OS_VERSION environment variables to specify the version of Ubuntu to use as the base image.

Once the build is complete, you can verify that the image was created by running the docker images command:
```
docker images 

% docker image ls
REPOSITORY                             TAG       IMAGE ID       CREATED          SIZE
agent_ubuntu_22.04                     latest    c81417412821   10 minutes ago   243MB    --------------------->>> 

```
This command will list all the Docker images on your system, including the NGINX Agent bundled with NGINX Plus image you just built.


You can now tag the image with your Docker Hub username and the desired tag name:
```
docker tag agent_ubuntu_22.04 ausente/agent_ubuntu_22.04:v1.0 
```
Replace ausente with your Docker Hub username, and v1.0 with the desired tag name.


Push the tagged image to Docker Hub:
```
docker push ausente/agent_ubuntu_22.04:v1.0 
```
This command will push the tagged image to your Docker Hub repository.

Once the push is complete, you can verify that the image was uploaded to Docker Hub by running the following command:
```
docker image ls 
```
This command will list all the Docker images on your system, including the image you just pushed to Docker Hub.

Sample output: 
```
 % docker push ausente/agent_ubuntu_22.04:v1.0 
The push refers to repository [docker.io/ausente/agent_ubuntu_22.04]
24fdea701aab: Pushed 
e3dc0a64927a: Pushed 
72376ff2c0d7: Pushed 
d5389ae35eaa: Pushed 
a028d4206d36: Pushed 
aa087c5ddd64: Pushed 
d31ec2a0a2e0: Pushed 
5f70bf18a086: Pushed 
b8a36d10656a: Mounted from library/ubuntu 
v1.0: digest: sha256:c7b54f7507f8b5afd0b56c3dea2042c3021ad8a8dcc97b56bff15f94a2d9c94a size: 2188

e.ausente@C02DR4L1MD6M agent % docker image ls
REPOSITORY                             TAG       IMAGE ID       CREATED          SIZE
ausente/agent_ubuntu_22.04             v1.0      c81417412821   17 minutes ago   243MB
agent_ubuntu_22.04                     latest    c81417412821   17 minutes ago   243MB
ausente/nginx-plus-with-agent          2.7.0     8bccb12882d0   22 hours ago     189MB
```

## Method 1: Using the manual docker build command

FYI Inside the MakeFile, there's a snippet on the command used to build the container image for N+ (Explore it)
```
image: ## Build agent container image for NGINX Plus, need nginx-repo.crt and nginx-repo.key in build directory
        @echo Building image with $(CONTAINER_CLITOOL); \
        $(CONTAINER_BUILDENV) $(CONTAINER_CLITOOL) build -t ${IMAGE_TAG} . \
                --no-cache -f ./scripts/docker/nginx-plus/${OS_RELEASE}/Dockerfile \
                --secret id=nginx-crt,src=build/nginx-repo.crt \
                --secret id=nginx-key,src=build/nginx-repo.key \
                --build-arg BASE_IMAGE=${BASE_IMAGE} \
                --build-arg PACKAGES_REPO=${PACKAGES_REPO} \
                --build-arg OS_RELEASE=${OS_RELEASE} \
                --build-arg OS_VERSION=${OS_VERSION} \
                --build-arg CONTAINER_REGISTRY=${CONTAINER_REGISTRY}
```

Here's my docker build command: 
```
docker build . -t nginx-agent-manual --no-cache -f scripts/docker/nginx-plus/ubuntu/Dockerfile --secret id=nginx-crt,src=build/nginx-repo.crt --secret id=nginx-key,src=build/nginx-repo.key --build-arg BASE_IMAGE=ubuntu --build-arg PACKAGES_REPO=pkgs.nginx.com
```

```
e.ausente@C02DR4L1MD6M agent % docker image ls
REPOSITORY                             TAG       IMAGE ID       CREATED         SIZE
nginx-agent-manual                     latest    cfd512742621   5 minutes ago   243MB
```
Notice I did not any more specify the NMS host IP address, port and instance group name via "-t nginx-agent --build-arg CONTROL_PLANE_IP ."   
https://docs.nginx.com/nginx-management-suite/nginx-agent/nginx-agent-in-container/

as we will be passing these NGINX Agent Environment Variables instead in the deployment file:
```
agent % cat dep1.yaml 
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: nginx-agent
  name: nginx-agent
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-agent
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx-agent
    spec:
      containers:
      - name: nginx-agent
        image: ausente/agent_ubuntu_22.04:v1.0
        args:
        - --server-host=XXXXXXXXXXXXXXXXXXXXXXXX-1464760227.ap-southeast-1.elb.amazonaws.com    ------------------------------->>>>  
        - --server-grpcport=443                                                                 ------------------------------->>>> 
        - --tls-enable                                                                          ------------------------------->>>> 
        - --tls-skip-verify                                                                     ------------------------------->>>> 
        ports:
        - name: web
          containerPort: 80
          protocol: TCP
        - name: secure
          containerPort: 443
          protocol: TCP
        - name: agent
          containerPort: 8081
          protocol: TCP
        env:
        - name: HOST
          value: a517ecbadab6e47fcacfa211128bcb9f-1464760227.ap-southeast-1.elb.amazonaws.com
        - name: GRPC_PORT
          value: "443"
```
