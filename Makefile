CXX=nvcc
CXXFLAGS=-O3 -std=c++17 -rdc=true -arch=sm_75
OPTIONAL_CXXFLAGS=-DDEBUG_CUDA #-DNO_FEATURE #-DTUNE
CXXFILES=src/parser.cpp src/gcn.cu src/variable.cu src/module.cu src/timer.cpp src/sparse.cu src/optim.cu src/reduction.cu src/smart_object.cu
HFILES=include/gcn.cuh include/parser.h include/utils.cuh include/variable.cuh include/module.cuh include/timer.h include/sparse.cuh include/optim.cuh include/shared_ptr.cuh

all: gcn-par

gcn-par: src/main.cpp $(CXXFILES) $(HFILES)
	mkdir -p exec
	$(CXX) $(CXXFLAGS) $(OPTIONAL_CXXFLAGS) -o exec/gcn-par $(CXXFILES) src/main.cpp

gcn-par-no-feature: src/main.cpp $(CXXFILES) $(HFILES)
	mkdir -p exec
	$(CXX) $(CXXFLAGS) -DNO_FEATURE -o exec/gcn-par-no-feature $(CXXFILES) src/main.cpp

tuning-cuda: test/tuning_cuda.cpp $(CXXFILES) $(HFILES)
	mkdir -p exec
	$(CXX) $(CXXFLAGS) -DDEBUG_CUDA -DNO_OUTPUT -DTUNE_CUDA -o exec/tuning-cuda $(CXXFILES) test/tuning_cuda.cpp

performance-gpu: test/performance_gpu.cpp $(CXXFILES) $(HFILES)
	mkdir -p exec
	$(CXX) $(CXXFLAGS) -DDEBUG_CUDA -DNO_OUTPUT -DTUNE_CUDA -o exec/performance-gpu $(CXXFILES) test/performance_gpu.cpp

tuning-accuracy: test/tuning_accuracy.cpp $(CXXFILES) $(HFILES)
	mkdir -p exec
	mkdir -p output
	mkdir -p output/plot
	$(CXX) $(CXXFLAGS) -DDEBUG_CUDA -DNO_OUTPUT -DTUNE_ACCURACY -o exec/tuning-accuracy $(CXXFILES) test/tuning_accuracy.cpp

tuning-accuracy-no-feature: test/tuning_accuracy.cpp $(CXXFILES) $(HFILES)
	mkdir -p exec
	mkdir -p output
	mkdir -p output/plot
	$(CXX) $(CXXFLAGS) -DDEBUG_CUDA -DNO_OUTPUT -DTUNE_ACCURACY -DNO_FEATURE -o exec/tuning-accuracy-no-feature $(CXXFILES) test/tuning_accuracy.cpp

tuning-accuracy-second: test/tuning_accuracy.cpp $(CXXFILES) $(HFILES)
	mkdir -p exec
	mkdir -p output
	mkdir -p output/plot
	$(CXX) $(CXXFLAGS) -DDEBUG_CUDA -DNO_OUTPUT -DTUNE_ACCURACY -DSECOND -o exec/tuning-accuracy-second $(CXXFILES) test/tuning_accuracy.cpp
	$(CXX) $(CXXFLAGS) -DDEBUG_CUDA -DNO_OUTPUT -DTUNE_ACCURACY -DSECOND -DNO_FEATURE -o exec/tuning-accuracy-second-no-feature $(CXXFILES) test/tuning_accuracy.cpp
	
clean:
	rm exec/*
