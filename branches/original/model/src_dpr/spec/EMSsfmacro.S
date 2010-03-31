/*
  DESCRIPTION

  Class that defines macro-DPRs


  HISTORY

  Probably PP, long time ago
*/

class specification EMSsfmacro (1:0) of EMSsfdpr;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSsfmacro
{
 IGRuchar num_states;
};

override GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMcreate_yourself
(
  IGRlong *EMmsg;
  OM_S_OBJID dpr_id;
  IGRint num_states;
  struct GRmd_env *md_env;
);

message EMaddnode_to_macro
(
  IGRlong *EMmsg;
  struct GRid *node;
  struct GRmd_env *md_env;
);

message EMdelete_macro_node
(
  IGRlong *EMmsg;
  struct GRid *feature;
  struct GRmd_env *md_env;
);

override 
  GRgetobjinfo,
  EMconstruct_associative,
  EMundo,
  EMgetsolidclass,
  EMcheckOverlap,
  EMcanRecompute,
  EMislm,
  EMgettreepath,
  EMactivate,
  EMdeactivate,
  GRdelete;

#endif

end specification EMSsfmacro;
