/*
  ABSTRACT

  This is a constructed class which represents a boolean operation
  on surfaces or composite surfaces.

  HISTORY

  05/09/89 DLB :  Removed GRgetrang override.
  03/03/89 DLB :  Added EMget_put_cht message.
  29 Nov 1988 jBk Added EMdelDisjAreas message.
  11/22/88 RC  :  Added override EMget_mdsfs_info.
  11/20/88 DLB :  Added EMgetSurfsOfPrim override.
  09/08/88 DLB :  Removed override of EMsfsfint.  Surface save size operations
                  now store the plane in the ids vla.
  11 May 1988 Sm  Overide EMsfsfint. For surface save side operation the
                  plane is connected (at index 1) only for reexecute. So 
                  subsequent intersections should ignore this plane.
  13 Apr 1988 jBk Changed name of EMdisjoint to EMdisjointBoolean.
                  Modified arguments of EMdisjointBoolean and
                  EMget_operation_type messages.
                  Updated and added descriptions.
                  Added EMjoiningBoolean message, which will
                  perform the duties of former EMboolean message.
                  Added capabilities and an option to EMboolean
                  message.  Now can perform disjoint booleans. 
                  Optionally, can attempt appropriate disjoint
                  boolean when no intersections are found in an
                  attempted joining boolean.
                  Added EMdisjointActivate and EMdisjointDeactivate
                  message.  Changed EMactivate and EMdeactivate to
                  EMjoiningActivate and EMjoiningDeactivate. 
                  Overrides of EMactivate and EMdeactivate now
                  simply select between the two varieties.
                  Added EMattachNullSymbol and EMremoveNullSymbol
                  messages.
  19 Feb 1988 SS  Change arguments to EMboolean.
  03 Feb 1987 RC  Override GRaddwrng.
  04 Dec 1987 jBk Added EMdisjoint message.
  09/22/1987 DLB : 1.1.0 class conversion.
  10 Jun 1987 RC  Overrode EMintcopy.
  13 May 1987 jBk Added EMget_operation_type message.
  05 Apr 1987 AIC Modified ancestry.
  09 Mar 1987 AIC Creation date.
*/

class specification EMSsfboolean (1:0) of EMSsfregmod;

# include "emsbool.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfboolean
{
  IGRdouble         cht;             
  IGRushort num_composites;   
  IGRuchar  operation;       
};

override GRvg;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMredobooltree
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRushort options;
  IGRint depth;
  GRobjid *my_new_id;
  FILE *outfile;
);

message EMgettreedepth
(
  IGRlong *msg;
  IGRint relnum;
  IGRint *depth;
);

message EMjoiningBoolean
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix matrix;
  GRobjid element;
  IGRint num_elements_in_set;
  GRobjid set[];
  struct GRvg_construct *const_args;
  enum EMSbooltype bool_type;
  IGRushort options;
  IGRchar status_str[];
  GRobjid intgrp[];
  GRobjid auxgrp[];
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMboolean
(
  IGRlong *msg;
  IGRshort *mattyp;
  IGRmatrix matrix;
  GRobjid element;
  IGRint num_elements_in_set;
  GRobjid set[];
  struct GRvg_construct *const_args;
  enum EMSbooltype bool_type;
  IGRushort options;
  IGRchar status_str[];
  GRobjid intgrp[];
  GRobjid auxgrp[];
  GRobjid *display_ids[];
  IGRint *display_count;
);

message EMdisjointBoolean
(
  IGRlong *EMmsg;
  enum EMSbooltype bool_type;
  IGRushort options;
  struct GRvg_construct construct_list[1];
  GRobjid element;
  IGRint num_elements_in_set;
  GRobjid set[];
);

message EMjoiningActivate
(
  IGRlong *EMmsg;
  IGRshort *option;
  struct GRmd_env *env_info;
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMdisjointActivate
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRshort option;
  IGRboolean emptySet;
  IGRboolean firstOnly;
  IGRboolean allButFirst;
  IGRboolean lastOnly;
);

message EMjoiningDeactivate
(
  IGRlong *EMmsg;
  IGRshort *option;
  struct GRmd_env *env_info;
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMdisjointDeactivate
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
  IGRshort option;
  IGRboolean emptySet;
  IGRboolean firstOnly;
  IGRboolean allButFirst;
  IGRboolean lastOnly;
);

message EMattachNullSymbol
(
  IGRlong *EMmsg;
  struct GRvg_construct construct_list[1];
);

message EMremoveNullSymbol
(
  IGRlong *EMmsg;
  struct GRmd_env *env;
);

message EMget_operation_type
(
  IGRlong *EMmsg;
  enum EMSbooltype *request;
  enum EMSbooltype *exactOperation;
  enum EMSbooltype *generalOperation;
  IGRboolean *reverseOrientation;
  IGRboolean *emptySet;
  IGRboolean *disjointSurfaces;
  IGRboolean *firstOnly;
  IGRboolean *allButFirst;
  IGRboolean *lastOnly;
  IGRboolean *removedSolids;
  IGRlong *msgNumber;
);

message EMboolinit
(
  IGRlong *msg;
  GRobjid solid1;
  IGRint num_solids;
  GRobjid *solid2;
  union EMSssi_table *rmtbuff;
  struct GRvg_construct *const_args;
  enum EMSbooltype bool_type;
);

message EMfix_SSI
(
  IGRlong *EMmsg;
  union EMSssi_table *rmt;
  struct GRmd_env *env;
);

message EMdelDisjAreas
(
  IGRlong *rc;
  struct GRvg_construct *list;
  struct EMStreeHeap *p_areas;
  OM_S_OBJID surface;
);

message EMget_put_cht
(
  IGRlong *EMmsg;
  IGRboolean true_if_put;
  IGRdouble *cht;
);

 
reject 
    EMadd;  

override
  GRprint,
  GRread,
  EMchksliver,   
  GRgetobjinfo,  
  EMoffset,
  EMconstruct_associative,
  EMmatch,
  EMtoggleOrient,
  EMnodeBrokeApart,
  EMgetModRange,
  EMgetInGeomIds,
  EMgetmodinfo,
  EMgetOutInfo,
  EMconnectTopology,
  EMcanRecompute,
  EMgetCompIndex,
  EMputCompIndex,
  EMattemptBreakup,
  EMresetSSI,
  EMtoggleKDFlag,
  EMgetUnevalIds,
  EMcheckOverlap,
  EMgetInInfo,
  EMremoveOpnd,
  EMgetSurfsOfPrim,
  EMislm,
  EMgetsolidclass,
  GRchgcolor,
  GRputsymb,
  GRchghprops,
  GRchgdp,
  GRchglevel,
  GRchgstyle,
  GRchgweight,
  EMputRI,
  EMrecompinfodelete,
  GRaddwrng,
  GRremwrng,
  EMintcopy,
  GRxform,
  EMgetactiveid,
  EMsavestatedelete,
  EMreexecute,
  EMputSSI,
  EMactivate,
  EMdeactivate,
  EMget_mdsfs_info,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMgetSSI,
  EMgetRI;

#endif

end specification EMSsfboolean;
