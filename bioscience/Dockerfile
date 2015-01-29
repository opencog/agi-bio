# docker build -t $USER/agi-bio .

FROM opencog/opencog-deps

# Clone opencog and build it with
RUN git clone --depth 1 https://github.com/opencog/opencog oc
ADD . /home/opencog/oc/bioscience
RUN echo  'ADD_SUBDIRECTORY(bioscience)' >> oc/CMakeLists.txt
ADD opencog.conf /home/opencog/oc/lib/
RUN (cd oc; mkdir build; cd build; cmake ..; make -j6)

# Docker defaults
WORKDIR /home/opencog/oc/build
USER opencog

## Start cogserver when container runs
CMD opencog/server/cogserver
