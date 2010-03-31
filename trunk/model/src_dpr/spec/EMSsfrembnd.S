/*
  DESCRIPITON

  DPR class for 'delete surface boundary' state.

 
  HISTORY

  AMD : August, 1991 : Creation
*/

class specification EMSsfrembnd (1:0) of EMSsfregmod;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfrembnd
{
 IGRint    num_composites;
 IGRint    num_edges;
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMremove_boundaries
(
  IGRlong *msg;
  IGRshort mattyp[];
  IGRmatrix matrix;
  struct GRvg_construct construct_list;
  struct GRid active_GRid;
  IGRint num_loops;
  GRobjid *loops;
);

message EMfixSSI
(
  IGRlong *EMmsg;
  union EMSssi_table *rmt;
  struct GRmd_env *env;
);

override
  EMconstruct_associative, 
  EMgetInGeomIds,
  EMgetOutInfo,
  EMgetInInfo,	
  EMputSSI, 
  EMactivate,
  EMdeactivate,
  EMsavestatedelete,
  EMcheckOverlap, 
  EMintcopy, 
  GRxform, 
  GRchgcolor,
  GRputsymb,
  GRchghprops,
  GRchgdp,
  GRchglevel,
  GRchgstyle, 
  GRchgweight, 
  EMgetSurfsOfPrim,
  GRremwrng,
  GRaddwrng,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMgetSSI,
  EMresetSSI;

#endif

end specification EMSsfrembnd;                  
