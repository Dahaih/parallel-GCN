#include "../include/GetPot"
#include "../include/gcn.cuh"
#include "../include/optim.cuh"
#include "../include/parser.h"

#include <iostream>
#include <string>

int main(int argc, char **argv) {

// setbuf(stdout, NULL);
//  Print device informations
#ifndef NO_OUTPUT
  print_gpu_info();
#endif

  if (argc < 2) {
    std::cerr
        << "Give one input file name as argument [cora pubmed citeseer reddit]"
        << std::endl;
    return EXIT_FAILURE;
  }

  std::string input_name(argv[1]);

  // Read parameters at runtime from "parameters.txt" using GetPot
  GCNParams params;
  AdamParams adam_params;
  GetPot command_line(argc, argv);

#ifdef NO_OUTPUT
  const std::string file_name = command_line("file", "./parameters.txt");
#else
  const std::string name =
      "./specific_parameters/parameters_" + input_name + ".txt";
  const std::string file_name = command_line("file", name.c_str());
#endif

  GetPot datafile(file_name.c_str());

// Parse parameters
#ifdef NO_OUTPUT
  parse_parameters(datafile, params, adam_params, false);
#else
  parse_parameters(datafile, params, adam_params, true);
#endif

  // Parse data
  GCNData data;
  Parser parser(&params, &data, input_name);
  if (!parser.parse()) {
    std::cerr << "Cannot read input: " << input_name << std::endl;
    exit(EXIT_FAILURE);
  }

// print parsed parameters
#ifndef NO_OUTPUT
  params.print_info();
#endif

  // GCN object creation
  GCN gcn(&params, &adam_params, &data);

  // run the algorithm
  gcn.run();

  Variable::dev_rand_states.~dev_shared_ptr();

  return EXIT_SUCCESS;
}