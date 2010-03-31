/* 
  DESCRIPTION

  This DPR class si for objects that perform the unite-surface op.


  HISTORY

   11/11/91 : AMD:  Creation

*/

class specification EMSsfunitesf (1:0) of EMSsfregmod;


/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfunitesf
{
 IGRint         num_edges;
 IGRint         num_composites;
};

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMmerge_coincident_surfs
(
  IGRlong *msg;
  struct GRvg_construct construct_list;
  IGRushort options;
  struct GRid active_GRid;
  IGRint num_surfs;
  GRobjid *surfs;
  GRobjid *newplane;
  GRobjid *display_ids[];
  IGRint *display_count;
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
  GRaddwrng,
  GRremwrng,
  EMgetSurfsOfPrim,
  EMgetsolidclass,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMgetSSI,
  EMresetSSI;

#endif

end specification EMSsfunitesf;
