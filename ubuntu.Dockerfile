# This Dockerfile creates an enviroment / dependancies needed to run the 
# cubit_docker package.

# You will need to have you license file saved as license.lic in the same folder
# as this Dockerfile when building

# To build this Dockerfile into a docker image:
# docker build -t cubit_docker .

# To run the resulting Docker image:
# docker run -it cubit_docker


FROM ubuntu:20.04

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    CC=/usr/bin/mpicc CXX=/usr/bin/mpicxx \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y

RUN apt-get install -y libgl1-mesa-glx \
                       libgl1-mesa-dev \
                       libglu1-mesa-dev \
                       freeglut3-dev \
                       libosmesa6 \
                       libosmesa6-dev \
                       libgles2-mesa-dev \
                       curl \
                       wget && \
                       apt-get clean


# install cubit dependencies
RUN apt-get install -y libx11-6 
RUN apt-get install -y libxt6 
RUN apt-get install -y libgl1
RUN apt-get install -y libglu1-mesa
RUN apt-get install -y libgl1-mesa-glx
RUN apt-get install -y libxcb-icccm4 
RUN apt-get install -y libxcb-image0 
RUN apt-get install -y libxcb-keysyms1 
RUN apt-get install -y libxcb-render-util0 
RUN apt-get install -y libxkbcommon-x11-0 
RUN apt-get install -y libxcb-randr0 
RUN apt-get install -y libxcb-xinerama0

# download and set python to python 3.8 (latest version supported by cubit)
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update

RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8 
ENV LC_ALL=C.UTF-8
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install python 3.8
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_4.10.3-Linux-x86_64.sh
RUN mkdir /root/.conda
RUN bash Miniconda3-py38_4.10.3-Linux-x86_64.sh -b 

RUN conda --version



# download cubit
RUN wget -O coreform-cubit-2021.5.deb https://f002.backblazeb2.com/file/cubit-downloads/Coreform-Cubit/Releases/Linux/Coreform-Cubit-2021.5%2B15962_5043ef39-Lin64.deb

# install cubit
RUN dpkg -i coreform-cubit-2021.5.deb


# makes a python file and trys to import cubit
RUN printf 'import sys\nsys.path.append("/opt/Coreform-Cubit-2021.5/bin/")\nimport cubit\ncubit.init([])\n' >> test_cubit_import.py


# writes a non commercial license file
# RUN printf 'Fri May 28 2021' >> /opt/Coreform-Cubit-2021.5/bin/licenses/cubit-learn.lic
RUN mkdir -p /root/.config/Coreform/licenses
RUN printf 'Fri May 28 2021' >> /root/.config/Coreform/licenses/cubit-learn.lic



RUN wget https://github.com/svalinn/Cubit-plugin/releases/download/0.2.1/svalinn-plugin_ubuntu-20.04_cubit_2021.5.tgz
RUN tar -xzvf svalinn-plugin_ubuntu-20.04_cubit_2021.5.tgz -C /opt/Coreform-Cubit-2021.5

# copies over cad files and test script
COPY stp_to_h5m_cubit_script.py .
COPY stp_files stp_files/

ENV CUBIT_VERBOSE=5

# runs test script
RUN python stp_to_h5m_cubit_script.py
