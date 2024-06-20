#!/bin/bash
# Publish the application for Linux ARM64
# Run this script inside the Docker container
cd NativeAot

# Get the kernel and CPU
KERNEL=$(uname -s)
CPU=$(uname -m)
# Convert to lowercase
KERNEL=$(echo $KERNEL | tr '[:upper:]' '[:lower:]')
CPU=$(echo $CPU | tr '[:upper:]' '[:lower:]')

dotnet publish -c Release -o ../tmp/publish/$KERNEL-$CPU 
