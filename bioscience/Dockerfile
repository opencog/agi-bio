# docker build -t $USER/agi-bio .

FROM opencog/opencog-deps

# Clone opencog and build it with
RUN git clone --depth 1 https://github.com/opencog/opencog oc
ADD . /home/opencog/oc/bioscience
RUN echo  'ADD_SUBDIRECTORY(bioscience)' >> oc/CMakeLists.txt 
RUN (cd oc; mkdir build; cd build; cmake ..; make -j6)

# Defaults
## cogserver shell ports
EXPOSE 17001 18001

## REST api
EXPOSE 5000

## Default postgresql port
EXPOSE 5432

# Docker defaults
## Start cogserver when container runs
WORKDIR /home/opencog/oc/build
ENTRYPOINT ["/home/opencog/oc/build/opencog/server/cogserver"]
CMD ["-c",  "oc/lib/opencog.conf"]
USER opencog
