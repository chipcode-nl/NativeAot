# NativeAot

This project contains the source code and build scripts for the NativeAot test application.

# Prerequisites
Install dotnet SDK using the script.

```
. ./dotnet-sdk-9.0.100.install.sh
```

# Build the Native AOT application

```
./publish.sh
```

# Run the Native AOT application

```
tmp/publish/NativeAot
```

# Compile in Docker Container

You can compile the application in a docker container. Run the Docker Decktop App en run the docker container.

```
./run-docker.sh
```

After this you can follow the same procedure as on the Mac.