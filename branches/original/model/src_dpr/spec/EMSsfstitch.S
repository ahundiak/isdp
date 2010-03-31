/*
  ABSTRACT

  This class represents the stitch state in the DPR tree. It can be
  a result of compositing any number of surfaces together in one
  operation. It can own a composite surface, another dpr object or a single
  surface by itself.


  HISTORY

  SM	06-Oct-88	Creation.
  mrm     03/22/91        override EMconstruct_associative
  mrm     03/26/91        override EMgetInGeomIds
*/

class specification EMSsfstitch (1:0) of EMSsfdpr;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfstitch
{
 IGRushort		num_edges_out;
 variable IGRushort	num_edges_in[1];
};

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMmake_comp
(
  IGRlong *EMmsg;
  IGRint num_comps;
  GRobjid *comps;
  struct GRmd_env *mod_info;
  struct EMSstitch_saveinfo *save_info;
  struct EMSstitch_info *in_pairs;
  IGRint in_num_pairs;
  struct EMSstitch_geominfo *geom;
  IGRushort makecs_options;
);

override 
  EMconnectTopology,
  EMgetInInfo,
  EMgetOutInfo,
  EMgetmodinfo,
  EMcheckOverlap,
  EMtoggleKDFlag,
  EMgetUnevalIds,
  EMputSSI, 
  EMactivate, 
  EMdeactivate, 
  EMsavestatedelete, 
  EMintcopy, 
  EMgetsolidclass, 
  EMconstruct_associative,
  EMgetInGeomIds,
  EMgetSSIsize, 
  EMgetSSIbuffer, 
  EMgetSSI,
  debug;

#endif

end specification EMSsfstitch;
