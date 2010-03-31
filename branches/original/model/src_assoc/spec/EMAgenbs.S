/*
  DESCRIPTION

  This is an instantiable class defining associative free form
  surfaces.


  HISTORY

  Creation : PP : 03/02/91
*/

class specification EMAgenbs (2:0) of EMAsubbs, EMSgenbs;

#include "REgenbs.h"

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

override
  EMconstruct_associative,
  EMget_parent_type,
  EMdim,
  EMdimparam;

#endif

end specification EMAgenbs;
