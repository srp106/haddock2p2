FROM edraizen/cns:latest
# install necessary dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get update && \
    apt-get install -y wget python-dev csh gfortran rar build-essential gawk flex libreadline-gplv2-dev libncurses5-dev

WORKDIR /opt

RUN wget --no-check-certificate https://spin.niddk.nih.gov/bax/software/PALES/pales.linux.tar.Z
RUN zcat pales.linux.tar.Z | tar xvf -
RUN rm pales.linux.tar.Z

RUN wget --no-check-certificate http://acrmwww.biochem.ucl.ac.uk/software/profit/235216/ProFitV3.1.tar.gz
RUN tar -xzf ProFitV3.1.tar.gz
RUN rm ProFitV3.1.tar.gz
ENV PROFIT="/opt/ProFitV3.1/profit"
ENV DATADIR="/opt/ProFitV3.1"
ENV HELPDIR="/opt/ProFitV3.1/"

RUN mkdir /opt/naccess
WORKDIR /opt/naccess
RUN wget --no-check-certificate http://www.bioinf.manchester.ac.uk/naccess/download/naccess.rar.gz
RUN gunzip naccess.rar.gz
RUN rar e -p"nac97" naccess.rar
RUN rm naccess.rar
RUN csh install.scr
ENV NACCESS="/opt/naccess/naccess"

WORKDIR /opt
RUN wget --no-check-certificate http://www.ibs.fr//download/links/25bed8c47101430652ff2c53/TENSORV2_PC9.tar
RUN tar -xf TENSORV2_PC9.tar
RUN rm TENSORV2_PC9.tar
RUN chmod +x /opt/TENSORV2_PC9/tensor2
ENV TENSOR="/opt/TENSORV2_PC9/tensor2"

RUN mkdir /opt/haddock2.2
COPY haddock2.2 /opt/haddock2.2
RUN ls -la

WORKDIR /opt/haddock2.2
RUN ls -la
RUN make

RUN cp /opt/haddock2.2/cns1.3/* /opt/cns_solve_1.3
RUN cp /opt/haddock2.2/cns1.3/* /opt/cns_solve_1.3/intel-x86_64bit-linux/source

WORKDIR /opt/cns_solve_1.3/

RUN sed -i "s/-ffast-math//g" /opt/cns_solve_1.3/instlib/machine/supported/intel-x86_64bit-linux/Makefile.header.2.gfortran
RUN sed -i "s/-ffast-math//g" ./instlib/machine/supported/linux/Makefile.header.2.gfortran
RUN sed -i "s/-ffast-math//g" ./instlib/machine/supported/linux/Makefile.header.5.gfortran_mp
RUN sed -i "s/-ffast-math//g" ./instlib/machine/supported/intel-x86_64bit-linux/Makefile.header.7.gfortran_mp
RUN sed -i "s/-ffast-math//g" ./instlib/machine/supported/intel-x86_64bit-linux/Makefile.header.2.gfortran

RUN . /opt/cns_solve_1.3/.cns_solve_env_sh

WORKDIR /opt/cns_solve_1.3/
RUN make install compiler=gfortran

COPY wrapper.sh /opt/haddock2.2

#Data dir already exists in cns
#RUN mkdir /data
WORKDIR /data

ENTRYPOINT ["sh", "/opt/haddock2.2/wrapper.sh"]
