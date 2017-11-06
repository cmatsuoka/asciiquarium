FROM ubuntu:16.04
RUN apt-get update && apt-get install -y libcurses-perl
RUN cpan
RUN apt-get install -y make
RUN cpan Term::Animation
ADD asciiquarium /usr/bin/asciiquarium
CMD /usr/bin/asciiquarium
