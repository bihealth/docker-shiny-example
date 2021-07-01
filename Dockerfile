FROM ubuntu:xenial

### Use local mirror and update

RUN perl -p -i -e 's/archive.ubuntu.com/debian.charite.de/g' /etc/apt/sources.list && \
    apt-get update

### iRODS icommands

RUN apt-get install -y gnupg2 wget apt-utils apt-transport-https ca-certificates && \
    wget -qO - https://packages.irods.org/irods-signing-key.asc | apt-key add - && \
    echo "deb [arch=amd64] https://packages.irods.org/apt/ xenial main" | tee /etc/apt/sources.list.d/renci-irods.list && \
    apt-get update && \
    apt-get install -y irods-icommands

### R

## Install from CRAN

RUN echo "deb [arch=amd64] https://cloud.r-project.org/bin/linux/ubuntu xenial-cran35/" \
        | tee /etc/apt/sources.list.d/r.list && \
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    apt-get update && \
    apt-get install -y -t xenial-cran35 r-base && \
    apt-get install -y -t xenial-cran35 r-base-dev

## Optionally install high performance linar algebra packages

RUN apt-get install -y -t xenial-cran35 libatlas3-base && \
    apt-get install -y -t xenial-cran35 libopenblas-base

## Setup paths for packages

# RUN echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" \
#         >> /usr/local/lib/R/etc/Rprofile.site \
#     ## Add a library directory (for user-installed packages)
#     && mkdir -p /usr/local/lib/R/site-library \
#     && chown root:staff /usr/local/lib/R/site-library \
#     && chmod g+wx /usr/local/lib/R/site-library \
#     ## Fix library path
#     && echo "R_LIBS_USER='/usr/local/lib/R/site-library'" \
#         >> /usr/local/lib/R/etc/Renviron \
#     && echo "R_LIBS=\${R_LIBS-'/usr/local/lib/R/site-library:/usr/local/lib/R/library:/usr/lib/R/library'}" \
#         >> /usr/local/lib/R/etc/Renviron

## Install packages

RUN apt-get install -y libssl-dev libxml2-dev libbz2-dev liblzma-dev libcurl4-openssl-dev

RUN R -e 'install.packages(c("tidyverse", "shiny", "plotly", "DT", "BiocManager"))' && \
    R -e 'BiocManager::install(c("GenomicFeatures", "BSgenome.Hsapiens.1000genomes.hs37d5", "EnsDb.Hsapiens.v75"))'

### SHINY

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    wget

# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

RUN apt-get install -y git

RUN  mkdir /root/.irods
COPY irods_environment.json /root/.irods/.

COPY . /usr/local/src/app/
WORKDIR /usr/local/src/app

EXPOSE 3838

CMD ["Rscript", "app.R"]

