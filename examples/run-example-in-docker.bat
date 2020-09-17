@ECHO OFF
docker run -it --rm --name test -v %CD%:/usr/src/myapp -w /usr/src/myapp/examples ruby:2.5 ruby straighten.rb "source.pgm" "dest.pgm"
