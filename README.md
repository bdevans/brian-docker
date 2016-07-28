Usage
=====

The Brian2 docker container may be built with the following command:

`docker build -t brian .`

The image may then be run with the following command:

`docker run -p 8888:8888 -v /host/folder:/home/jovyan/work brian`

This will publish the notebook server on port 8888 and mount a host folder (change `/host/folder` to the folder you want to mount in the container).
On Linux systems, the notebook can then be accessed by opening a browser at:
localhost:8888
On Mac and Windows systems, the container's IP address must first be found:

`docker-machine ip`

TODO
====

1. Automate builds: https://docs.docker.com/docker-hub/github/
    https://docs.docker.com/docker-hub/builds/
2. Add plugin for switching environments via "Change kernel" in notebook
    http://stuartmumford.uk/blog/jupyter-notebook-and-conda.html
    #RUN pip install jupyter_environment_kernels
3. Fix TeX/MathJax for rich display content
