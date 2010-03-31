/*
  DESCRIPTION

  This class provides for
  a) common functionality with regards to implementation of 
     associativity of graphics elements in EMS.
  b) common message declarations for supporting associativity.


 HISTORY

 Removed EMreport, EMreport_defaults and EMupdate PP     : 03/25/93
 Added (and rejected) EMassoc_autodimparam	: Carlos : 06/10/92
 Added (and rejected) EMassoc_dimparam		: Carlos : 06/10/92
 Moved autodim messages to EMSdim class 	: jhw : 08/14/91
 EMreport messages not rejected         	: srh : 08/12/91
 Added EMautodim, EMdim, and EMdimparam 	: jhw : 06/02/91
 Added EMreport messages                	: srh : 05/21/91
 Override for ASreturn_go               	: jhw : 04/10/91
 Seperated the type from vla            	: PP  : 03/19/91
 Creation                               	: PP  : 03/02/91
*/

class specification EMSassoc (2:0) of EMSpointerA, GRvg, NDnodein;

#include "DIdef.h"
#include "DItypedef.h"
#include "parametric.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSasnucdef.h"
#include "EMSasnuc.h"
#include "EMSasopts.h"
#include "EMSasdef.h"
#include "EMSas.h"
#include "EMSasprops.h"
#include "EMSmsgdef.h"
#include "EMSmsgnumdef.h"
#include "report.h"
#include "REassoc.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSassoc
{
  variable IGRchar info[]; 
  unsigned char type;      
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMput_info
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRuint type;
  IGRuint info_size;
  IGRchar *info;
);

message EMget_info
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRuint *type;
  IGRuint *info_size;
  IGRchar **info;
);

message EMinit_associative
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRint num_parents;
  struct EMSobject_info *list;
  IGRint type;
  IGRuint size;
  IGRchar *recomp_data;
  struct GRvg_construct *construct_list;
);

message EMconstruct_associative
(
  IGRlong *EMmsg;
  IGRushort options;
  GRobjid old_objid;
  IGRint num_parents;
  IGRchar *parent_info;
  IGRint type;
  IGRchar *recomp_info;
  struct GRvg_construct *construct_list;
);

message EMinit_associative_function
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRint num_parents;
  struct EMSobject_info *parent_info;
  IGRchar *function_name;
  IGRuint size;
  IGRchar *recomp_info;
  struct GRvg_construct *construct_list;
  GRobjid *new_objid;
);

message EMget_parent_info
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRuint num_parents;
  IGRchar *parent_info;
  IGRuint *root_type;
  union EMSparent_info *roots;
);

message EMget_parent_type
(
  IGRlong *EMmsg;
  IGRint primitive_type;
  IGRuint root_count;
  IGRuint *root_type;
);

message EMastore
(
  IGRlong *EMmsg;
  IGRushort options;
  struct GRmd_env *md_env;
  GRobjid new_objid;
);

message EMget_construction_info
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
);

message EMdrop_associativity
(
  IGRlong *EMmsg;
  IGRuint options;
  struct GRmd_env *md_env;
  OM_S_OBJID *newobjid;
);

message EMcompute_postprocess
(
);

message EMgetparam
(
  IGRlong *msg;
  IGRushort opts;
  struct EMSparams *params;
);

message EMdisplay_geomparam
(
  IGRlong *msg;
  IGRushort opts;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRushort param_types;
  struct GRid *disp_id;
);

message EMlocate_geomparam
(
  IGRlong *msg;
  IGRushort opts;
  IGRshort *mattyp;
  IGRmatrix mat;
  IGRushort param_types;
  struct IGRline *boreline;
  IGRint num_in_buff;
  GRobjid *buff;
  IGRint *num_geomparms;
  GRobjid **geomparms;
);

message EMexternal_constraint_changed
(
  IGRlong *EMmsg;
  IGRushort options;
);

message EMmake_source
(
  IGRlong *EMmsg;
  IGRushort options;
  IGRint num_parents;
  struct EMSobject_info *parents;
  struct GRid *src_parents;
);

message EMautodim
(
  IGRlong * msg;
  struct GRmd_env * mod_env;
);

message EMdeautodim
(
  IGRlong * msg;
  struct GRmd_env * mod_env;
);

message EMprocess_function_call
(
  IGRlong *EMmsg;
  IGRint cnt_type;
  IGRint count;
  struct GRid *list;
  OM_S_OBJID *new_leafid;
  struct GRmd_env *md_env;
  IGRchar *info_ptr;
  IGRint info_size;
  struct GRvg_construct *construct_list;
);

message EMpack_paraminfo
(
  IGRlong *msg;
  IGRushort opts;
  struct EMSassoc_params *param_info;
  IGRint *obj_type;
  IGRchar **obj_info;
  IGRint *obj_info_size;
  IGRint *num_parents;
  struct GRid **parents;
  struct GRid **asparents;
  struct GRmd_env **md_envs;
  OM_p_MESSAGE target_messg;
  enum OM_e_wrt_flag target_messg_wrt_flag;
);

message EMassoc_autodimparam
(
  IGRlong *msg;
  IGRushort opts;
  IGRshort *mattyp;
  IGRmatrix mat;
  GRobjid paramobj;
  struct IGRplane *dim_plane;
  IGRdouble *dim_plane_xaxis;
  struct EMSgeomdata *dim_geom;
  IGRint *dim_type;
);

message EMassoc_dimparam
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  IGRushort options;
  IGRint type;
  IGRchar *info;
  IGRint num_parents;
  struct GRid *parents;
  IGRint index;
  struct IGRplane *dim_plane;
  IGRdouble *dim_plane_xaxis;
  struct EMSgeomdata *dim_geom;
  IGRint *dim_type;
);

reject
  EMautodim, 
  EMdeautodim,
  NDpossible_parent, 
  EMgetparam,
  EMget_parent_type,
  EMconstruct_associative,
  EMassoc_autodimparam,
  EMassoc_dimparam;

override 
  GRxform,    
  GRdelete,   
  NDupdate,
  NDdisplay, 
  NDgive_structure,
  NDmove_to_root,
  NDmake_source,
  ACbecome_macro,
  NDdelete,
  NDget_state,
  NDchg_state,
  ACcopy_to_Groot,
  NDcopy_graph,
  NDchange_connect,
  NDattach_to_cs,
  NDdetach_from_cs,
  ASreturn_go;

#endif

end specification EMSassoc;
