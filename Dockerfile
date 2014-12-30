#phyloGenerator 2.0 docker file
#Will Pearse - 2014-12-29

#Headers
FROM debian:wheezy
MAINTAINER Will Pearse <will.pearse@gmail.com>

#Setup dependencies (inc. Ruby and R)
RUN echo "deb http://cran.rstudio.com/bin/linux/debian wheezy-cran3/" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y --force-yes ruby zip make gcc g++ mpich2 r-base
RUN gem install bio
RUN Rscript -e "install.packages('ape', repos='http://cran.us.r-project.org')"

#RAxML
RUN cd
ADD https://github.com/stamatak/standard-RAxML/archive/master.zip master.zip
RUN unzip master.zip
RUN cd standard-RAxML-master && make -f Makefile.AVX.gcc

#ExaML
ADD https://github.com/stamatak/ExaML/archive/master.zip master.zip
RUN unzip master.zip
RUN cd ExaML-master/examl && make -f Makefile.AVX.gcc
RUN cd ExaML-master/parser && make -f Makefile.SSE3.gcc
RUN cp /ExaML-master/examl/examl-AVX /examl

#ExaBayes
RUN cd
ADD http://sco.h-its.org/exelixis/material/exabayes/1.4.1/exabayes-1.4.1-linux-openmpi-avx.zip exabayes-1.4.1-linux-openmpi-avx.zip
RUN unzip exabayes-1.4.1-linux-openmpi-avx.zip

#MAFFT
RUN apt-get install -y mafft

#phyloGenerator
RUN mkdir phyloGenerator && mkdir phyloGenerator/demo && mkdir phyloGenerator/lib
ADD demo/ /phyloGenerator/demo
ADD lib/ /phyloGenerator/lib
ADD pG_2.rb /phyloGenerator/

#Make everything executable
RUN cp /standard-RAxML-master/raxmlHPC-AVX /bin/raxml
RUN cp /ExaML-master/examl/examl-AVX /bin/examl
RUN cp /ExaML-master/parser/parse-examl /bin/parse-examl
RUN cp /exabayes-1.4.1/bin/bin/yggdrasil /bin/
