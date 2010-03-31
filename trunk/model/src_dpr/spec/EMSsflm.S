/*
  ABSTRACT

  This is an abstract class for DPR classes that locally modify
  surface state trees.


  HISTORY

  DLB  9/22/87   Creation for 1.1.0 class conversion.
*/

class specification EMSsflm (1:0) of EMSsfdpr;

#include "EMSopt.h"
#include "EMSprop.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMislmintree;

#endif

end specification EMSsflm;
