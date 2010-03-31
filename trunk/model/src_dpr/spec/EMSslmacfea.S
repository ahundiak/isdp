/*
  ABSTRACT

  This is a class which represents solid macro feature objects of 
  local modification.

  HISTORY

  BL  06/21/90	Creation Date.
  BL  06/29/90	Added inherit GRloadform, GRgetsfsize.
  Tapadia 04/10/91 Added override EMconstruct_associative
  Tapadia 05/01/91 Added options for associative/non-associative placement.
  msm 06/10/91    Removed GRloadform from the inheritance list and insted added
                  GRreport, GRreport_defaults, GRupdate_gadgets.
  Tapadia 07/25/91 Don't override EMconstruct_associative. Changed the method
  	    	EMmake_pocket to EMmake_pocket_fea because of changes in 
		pocket construction.
*/

class specification EMSslmacfea (1:0) of EMSslmacro, EMSsfmacfea;

#ifndef EMSfeadef_include
#include  "EMSfeadef.h"  
#endif

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMmake_pocket_fea
(
  IGRlong *EMmsg;
  IGRint part_type;
  struct GRevent *pock_depth;
  IGRboolean drafted;
  struct GRevent *draft_angle;
  IGRboolean round_edge;
  struct GRevent *round_radius;
  struct GRvg_construct *const_list;
  struct GRid *solid_id;
  struct GRlc_info *surfs_info;
  IGRushort gen_opts;
);

from EMSslmacro inherit 
  GRreport, 
  GRreport_defaults, 
  GRupdate_gadgets;

#endif

end specification EMSslmacfea;


