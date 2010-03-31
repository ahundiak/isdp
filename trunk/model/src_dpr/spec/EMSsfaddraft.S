/*
  ABSTRACT


  HISTORY

  Nirmal 02/93    Creation Date
*/

class specification EMSsfaddraft (1:0) of EMSsfregmod;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfaddraft
{
  IGRint num_composites;
  IGRint num_old_commedge_pairs;
  IGRint num_new_commedge_pairs;
};

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMadd_draft
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  IGRint num_draft_surfs;
  IGRint draft_type;
  GRobjid *replace_surfs;
  struct GRid *surfs;
  GRobjid *hinges;
  IGRboolean ang_rev;
  IGRdouble draft_angles;
  struct GRvg_construct *const_list;
);

override
  EMdim,
  EMdimparam,
  EMconstruct_associative,
  EMgetInGeomIds,
  EMgetOutInfo, 
  EMgetInInfo,
  EMputSSI,
  EMactivate,
  EMdeactivate,
  EMsavestatedelete, 
  EMcheckOverlap,
  GRgetobjinfo,
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
  EMgetsolidclass,
  EMgetSSIsize,
  EMgetSSIbuffer,
  EMgetSSI;

#endif

end specification EMSsfaddraft;
