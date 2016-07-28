FROM jupyter/minimal-notebook

MAINTAINER Ben Evans <ben.d.evans@gmail.com>

USER root

# libfreetype6-dev and libxft-dev for matplotlib libav-tools for matplotlib anim
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
            git \
            gcc \
            g++ \
            gfortran \
            libatlas-dev \
            libatlas-base-dev \
            libatlas3-base \
            libopenblas-base \
            liblapack3 \
            liblapack-dev \
            libav-tools \
            libfreetype6-dev \
            libxft-dev && \
    apt-get clean && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --set libblas.so.3 /usr/lib/atlas-base/atlas/libblas.so.3
RUN update-alternatives --set liblapack.so.3 /usr/lib/atlas-base/atlas/liblapack.so.3

### Change locale to en_GB
RUN echo "en_GB.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen
ENV LC_ALL en_GB.UTF-8
ENV LANG en_GB.UTF-8
ENV LANGUAGE en_GB.UTF-8

#USER jovyan
USER $NB_USER

RUN conda config --add channels brian-team
RUN conda update --yes conda
RUN conda install --quiet --yes conda-build

# Install Python 3 packages
RUN conda install --quiet --yes \
    'pip=8.1*' \
    'nose=1.3*' \
    'sphinx=1.4*' \
    'matplotlib=1.5*' \
    'ipython=4.2*' \
    'brian2' \
    'brian2tools' \
    #&& conda remove --quiet --yes --force qt pyqt \
    && conda clean -tipsy
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images

RUN conda install --quiet --yes -c conda-forge 'ipywidgets=5.2*'

# Install Python 2 packages
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
    'pip=8.1*' \
    'nose=1.3*' \
    'sphinx=1.4*' \
    'matplotlib=1.5*' \
    'ipython=4.2*' \
    'brian2' \
    'brian2tools' \
    'pyzmq' \
    #&& conda remove -n python2 --quiet --yes --force qt pyqt \
    && conda clean -tipsy

RUN conda install --quiet --yes -n python2 -c conda-forge 'ipywidgets=5.2*'

# Add shortcuts to distinguish pip for python2 and python3 envs
RUN ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
    ln -s $CONDA_DIR/bin/pip $CONDA_DIR/bin/pip3

RUN conda install --quiet --yes -n python2 ipykernel

USER root

# Install Python 2 kernel spec globally to avoid permission problems
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install

USER $NB_USER

### Copy demonstration notebook and config files to home directory
WORKDIR $HOME
RUN git clone git://github.com/brian-team/brian2.git
RUN mv brian2/tutorials .
RUN mv brian2/examples .
RUN rm -rf brian2
RUN chmod -R +x tutorials
RUN chmod -R +x examples

RUN chown -R $NB_USER:users /home/$NB_USER/work

# Fix matplotlib 1.5.1 font cache warning
RUN rm -rf $HOME/.matplotlib
RUN rm -rf $HOME/.cache/matplotlib
RUN rm -rf $HOME/.cache/fontconfig
#RUN python -c "import matplotlib.pyplot as plt;"
RUN python -c "from brian2 import *"

RUN find . -name '*.ipynb' -exec jupyter trust {} \;
