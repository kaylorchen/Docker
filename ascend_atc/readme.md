# build docker image
```bash
docker buildx build -t atc:latest -f Dockerfile ./
```

# covert onnx to om
```bash
docker run -it -v ${PWD}:/root/ws atc bash
```

```bash
source /usr/local/Ascend/ascend-toolkit/set_env.sh
export LD_LIBRARY_PATH=/usr/local/Ascend/ascend-toolkit/latest/x86_64-linux/devlib/:$LD_LIBRARY_PATH
atc --model=depth_anything_v2_vits.onnx --framework=5 --output=depth_anything_v2_vits --soc_version=Ascend310B4
```