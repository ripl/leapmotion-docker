# LeapMotion Docker

Docker containerization for developing ROS apps. This image is based on [`ubuntu:22.04`](https://hub.docker.com/_/ubuntu), and with tweaks to enable [`cpk`](https://cpk.readthedocs.io/en/latest/), `ros-noetic-desktop-full` and `mDNS`.

## Build

```bash
cpk decorate -m RIPL ubuntu:22.04 ripl/ubuntu:22.04
git clone https://github.com/ripl/leapmotion-docker.git && cd leapmotion-docker/
cpk build
```

## Run

```bash
cpk run -X --net host -- --privileged
cpk run -c bash -X --net host -- --privileged
```
