/*
  DESCRIPTION

  Class that defines objects that are composites and are produced by
  sweeping a profile.


  HISTORY

  Unknown
*/

class specification EMSswcompsf (1:0) of EMScompsurf;

#include "EMSsweep.h"
#include "REswcompsf.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

override
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMsweep_composite_curve
(
  struct GRvg_construct *construct_list;
  struct GRlc_info *curve_info;
  struct EMSsweep *sweep_parms;
  OM_S_OBJID *recycle1st_objid;
);

override
  EMpack_paraminfo, 
  EMconstruct_associative, 
  EMdim, 
  EMdimparam;

#endif

end specification EMSswcompsf;
