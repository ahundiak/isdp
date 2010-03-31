/*
  ABSTRACT

  This class represents solids that are defined by a single surface
  (simple or special composite) and its caps, if any.


  HISTORY
  10 Jun 1991 msm Override GRreport, GRreport_defaults, GRupdate_gadgets.
                  Removed override GRloadform and GRgetsfsize.
  02 Feb 1989 PP  Overrode GRloadform and GRgetsfsize
  15 Jul 1988 jBk Removed EMmk_w_natural_sides_twixt_2sf message.
  18 May 1988 jBk Added EMmk_w_natural_sides_twixt_2sf message.
  14 Oct 1987 AIC Creation Date.
*/

class specification EMSsfsolid (1:0) of EMSsolid;

#include "REsfsolid.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMcap_thyself
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  GRobjid *surface_id;
);

message EMconstruct_solid_by_capping_surface
(
  IGRlong *EMmsg;
  struct EMSdataselect *data;
  struct GRmd_env *env;
  IGRboolean use_surfid;
  IGRboolean *solid_oriented;
  OMuword *surf_class_id;
  struct GRvg_construct *construct_list;
);

override
  EMoffset,
  EMget_params,
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets,
  EMconstruct_associative,
  EMdim,
  EMdimparam,
  GRgetobjinfo,
  EMgive_noncount_based_key,
  EMgive_count_based_key,
  EMorient_yourself;

#endif

end specification EMSsfsolid;
