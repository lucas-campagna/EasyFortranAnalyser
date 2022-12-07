FROM centos:7

RUN yum update -y && \
    yum groupinstall -y 'Development Tools' && \
    yum install -y \
    openssl-devel \
    libuuid-devel \
    libseccomp-devel \
    wget \
    squashfs-tools \
    poppler-utils

ENV VERSION=1.13
ENV OS=linux
ENV ARCH=amd64
RUN wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && \
    tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && \
    rm go$VERSION.$OS-$ARCH.tar.gz

ENV GOPATH=${HOME}/go
ENV PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin

RUN echo $PATH
RUN go get -u github.com/golang/dep/cmd/dep

ENV VERSION=v3.5.3
RUN mkdir -p $GOPATH/src/github.com/sylabs && \
    cd ${GOPATH}/src/github.com/sylabs && \
    git clone https://github.com/sylabs/singularity.git
RUN cd $GOPATH/src/github.com/sylabs/singularity && \
    git fetch && \
    git checkout $VERSION
RUN cd $GOPATH/src/github.com/sylabs/singularity && ./mconfig 
RUN cd $GOPATH/src/github.com/sylabs/singularity && make -C ./builddir
RUN cd $GOPATH/src/github.com/sylabs/singularity && make -C ./builddir install

WORKDIR /home/qas_eval

RUN singularity pull qas_eval.sif library://denis.eiras/monan/qas_eval:dev
RUN git clone https://github.com/monanadmin/monan.git

# comente a linha abaixo para rodar os exemplos
COPY ./run_eval.sh /home/qas_eval/monan/tools/qas_eval/run_eval.sh

CMD ./monan/tools/qas_eval/run_eval.sh