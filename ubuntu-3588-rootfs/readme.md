docker builder build -t ubuntu-3588-rootfs:latest -f Dockerfile --platform=arm64 .

docker run -it -v host_path:container_path -p 2222:22 ubuntu-3588-rootfs:latest bash