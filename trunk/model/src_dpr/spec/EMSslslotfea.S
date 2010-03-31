/*
  ABSTRACT

  This is a class which represents solid boolean feature objects.


  HISTORY

  Tapadia  08/20/91	Creation Date.
*/

class specification EMSslslotfea (1:0) of EMSslboolean, EMSsfboolfea;

#ifndef EMSfeadef_include
#include  "EMSfeadef.h"	
#endif

/*------------------ INSTANCE DATA SECTION -------------------*/

override  
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMmake_slot
(
  IGRlong *EMmsg;
  IGRushort *depth_type;
  IGRboolean dir_rev;
  struct GRid *new_prof_id;
  IGRboolean is_closed;
  struct GRlc_info *surf_info;
  struct GRvg_construct *construct_list;
  struct EMSslot *slot;
  struct GRid *active_GRid;
);

from EMSsurface inherit 
  GRgetobjinfo;

from EMSslboolean inherit 
  GRreport,
  GRreport_defaults, 
  GRupdate_gadgets;

override 
  EMconstruct_associative, 
  EMgetInGeomIds,
  EMdeactivate,
  EMdim,
  EMdimparam,
  EMpattern_copy,
  EMgive_noncount_based_key,
  EMgive_count_based_key;

#endif

end specification EMSslslotfea;
