FROM tensorflow/tensorflow:2.2.0rc0-gpu-py3-jupyter


RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake git \
         curl vim \
         ca-certificates \
         libjpeg-dev \
         libpng-dev &&\
     rm -rf /var/lib/apt/lists/*

RUN mkdir /root/anaconda
RUN mkdir /tf/data

RUN pip install xgboost


RUN curl -o /root/anaconda/anaconda.sh -O https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh 
 
RUN chmod +x /root/anaconda/anaconda.sh && \ 
     /root/anaconda/anaconda.sh -b -p /root/anaconda/anaconda3 && \ 
     /root/anaconda/anaconda3/bin/conda install numpy pyyaml mkl mkl-include setuptools cmake cffi typing ipython && \ 
     /root/anaconda/anaconda3/bin/conda install cudatoolkit=10.0 && \ 
     /root/anaconda/anaconda3/bin/conda install opencv && \ 
     /root/anaconda/anaconda3/bin/conda clean -ya 
 
ENV PATH /root/anaconda/anaconda3/bin:${PATH} 
 
ARG JUPYTER_PASSWORD

RUN jupyter_sha=$(python -c "from notebook.auth import passwd; print(passwd('${JUPYTER_PASSWORD}'))") && \
     echo "c.NotebookApp.password=u'$jupyter_sha'" >> ~/.jupyter/jupyter_notebook_config.py &&  \
     echo "c.NotebookApp.ip='0.0.0.0'" >> ~/.jupyter/jupyter_notebook_config.py && \
     echo "c.NotebookApp.open_browser=False" >> ~/.jupyter/jupyter_notebook_config.py && \
     echo "c.NotebookApp.terminado_settings = { 'shell_command': ['bash'] }" >> ~/.jupyter/jupyter_notebook_config.py

RUN conda create --name pytorch1.0 python=3.7 anaconda && \
     source activate pytorch1.0 && pip install torch==1.0 && \
     pip install xgboost && \
     pip install ipykernel && python -m ipykernel install --user --name pytorch1.0 --display-name "pytorch1.0"


EXPOSE 7777
ENTRYPOINT jupyter notebook --allow-root --ip=0.0.0.0 --port=7777 --no-browser
