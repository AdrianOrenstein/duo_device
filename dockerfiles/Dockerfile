FROM python:3.11.9

RUN apt-get update && \
    apt-get install -y zbar-tools libzbar-dev  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN pip install \
    pyotp \
    requests \
    pycryptodome \
    pyqrcode \
    opencv-python-headless

CMD ["/bin/bash"]