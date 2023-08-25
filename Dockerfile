FROM alpine:latest
RUN apk add --no-cache perl-utils perl-curses make
RUN cpan && \
  cpan Term::Animation
COPY asciiquarium /usr/bin/asciiquarium
CMD ["perl","/usr/bin/asciiquarium"]
