# docker build -t $USER/agi-bio .

FROM opencog/opencog-deps

# Clone opencog and build it with
RUN git clone --depth 1 https://github.com/opencog/opencog oc
ADD . /home/opencog/oc/bioscience
RUN echo  'ADD_SUBDIRECTORY(bioscience)' >> oc/CMakeLists.txt
ADD opencog.conf /home/opencog/oc/lib/
RUN (cd oc; mkdir build; cd build; cmake ..; make -j6)

# Docker defaults
## Start cogserver when container runs
WORKDIR /home/opencog/oc/build
ENTRYPOINT ["/home/opencog/oc/build/opencog/server/cogserver"]
CMD ["-c",  "oc/lib/opencog.conf"]
USER opencog
