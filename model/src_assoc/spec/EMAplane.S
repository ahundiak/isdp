/*
  DESCRIPTION

  This is an instantiable class defining associative plane.


  HISTORY

  jhw     3/24/91     creation date
*/

class specification EMAplane (2:0) of EMAsubbs, EMSplane;

#include "REplane.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMconstruct_associative,
  NDmove_to_root,
  EMdim,
  EMdimparam, 
  debug, 
  EMget_info;  

#endif

end specification EMAplane;
