ARG FROM_IMAGE_NAME=nvcr.io/nvidia/tensorflow:19.04-py3
FROM ${FROM_IMAGE_NAME}
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN pip install sklearn pandas

RUN apt-get update && apt-get install -y openssh-server git
RUN mkdir /var/run/sshd
RUN echo 'root:testdocker' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN mkdir /gpt-2
WORKDIR /gpt-2
COPY . .
RUN pip3 install -r requirements.txt

EXPOSE 22 8888
CMD ["bash", "-c", "/usr/sbin/sshd && jupyter notebook --ip 0.0.0.0 --no-browser --allow-root"]