/*
  ABSTRACT

  This class represents free form composite surfaces.


  HISTORY

  12 Jun 1991 jhw Added EMdim and EMdimparam.
  03 Mar 1991 jhw Added EMconstruct_associative.
  15 Jul 1988 jBk Changed EMmk_w_natural_sides_twixt_2sf message to
                  be named EMmkWNatSidesTw2S.
                  Removed argument numParts from EMmkWNatSidesTw2S.
                  Changed declaration and meaning of argument parts
                  of EMmkWNatSidesTw2S.
  19 May 1988 jBk Modified description of message added 28-Jan.
  17 May 1988 jBk Modified description of message added 28-Jan.
  12 May 1988 jBk Modified description of message added 28-Jan.
  28 Jan 1988 jBk Added EMmk_w_natural_sides_twixt_2sf message.
  15 Oct 1987 AIC Creation Date
*/

class specification EMSgencompsf (2:0) of EMScompsurf;

#include "REgencompsf.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMmake_comp
(
  IGRlong *EMmsg;
  IGRint num_comps;
  GRobjid *comps;
  struct GRmd_env *mod_info;
);

message EMproject_with_draft
(
  IGRlong *EMmsg;
  GRobjid crv_id;
  IGRboolean is_uniform;
  IGRdouble *ang_dis;
  IGRvector draft_vec;
  IGRboolean fillet;
  IGRboolean right_side;
  IGRint *off_code;
  struct GRvg_construct *const_list;
);

message EMmkWNatSidesTw2S
(
  IGRlong rc[1];
  GRobjid surf1;
  GRobjid surf2;
  struct GRvg_construct constructList[1];
  GRobjid parts[1];
);

override 
  EMconstruct_associative,
  EMdim,
  EMdimparam,
  NDattach_to_track_pt,
  NDdetach_from_track_pt;

#endif

end specification EMSgencompsf;
