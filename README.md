# balenaStorage

This repository provides an example on how to automatically mount/unmount external drives when plugged/unplugged using UDev rules on a multicontainer balenaOS deployment.

Note that currently it is not possible to share the mounted device across containers. This is a feature that will be implemented in the future, you can track it's progress on [this](https://github.com/balena-io/balena/issues/1288) GitHub issue. Details on current stopper for this can be found [here](https://www.flowdock.com/app/rulemotion/r-beginners/threads/9WK_A75G4SRyyTDyT7KHexCvFpf).
