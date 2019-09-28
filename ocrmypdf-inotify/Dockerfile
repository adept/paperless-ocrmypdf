FROM jbarlow83/ocrmypdf:latest
RUN apt-get install -y inotify-tools tesseract-ocr-rus tesseract-ocr-ukr
RUN mkdir -p /watcher/
WORKDIR /watcher
VOLUME /in /work /out /archive
COPY ./main.sh /watcher/main.sh
ENTRYPOINT ["/bin/bash","/watcher/main.sh"]
