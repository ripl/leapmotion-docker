# LeapMotion Docker

Docker containerization for developing ROS apps. This image is based on [`ubuntu:22.04`](https://hub.docker.com/_/ubuntu), and with tweaks to enable [`cpk`](https://cpk.readthedocs.io/en/latest/), `ros-noetic-desktop-full` and `mDNS`.

## Build

```bash
cpk decorate -m RIPL ubuntu:22.04 ripl/ubuntu:22.04
git clone --recurse-submodules https://github.com/ripl/leapmotion-docker.git && cd leapmotion-docker/
cpk build
```

## Run

```bash
# start the Leap Motion Controller
cpk run --net host -- --privileged
# start the GUI demo
cpk run -L demo --net host -- --privileged
```

## Development

```bash
# start the Leap Motion Controller
cpk run -fM --net host -- --privileged
# start the container in interactive mode
cpk run -f -n dev -c bash -M -X --net host -- --privileged
# start the container in detached mode
cpk run -f -n dev -c bash -M -X --net host -d -- --privileged
```
