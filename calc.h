#ifndef CALC_H
#define CALC_H

enum Num_Type { INT_TYPE, FLOAT_TYPE };

union num_value {
  int ival;
  double fval;
};

struct value {
  enum Num_Type type;
  union num_value val;
};

#endif
