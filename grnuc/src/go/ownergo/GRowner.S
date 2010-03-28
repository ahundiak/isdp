/*
  DESCRIPTION

  This class of owner geometries consists of entities which
  relate other graphic objects.  This class implies that the
  subclasses share a common channel which relates the owner
  object to one or more other graphics objects.  This class
  provides a default interpretation for all messages. 

  The owner class has the following properties:
    -  contains no geometry
    -  contains no symbology or level
    -  not a member of the rtree
    -  can be a member of the btree
    -  can be nested as long as an acyclic graph is formed

  The subclases of the owner class has the following properties:
    -  can contain geometry
    -  can be a member of the rtree
    -  can be a member of the btree
    -  can be nested as long as an acyclic graph is formed


  NOTES

  This class provides a default of rigid ownership for its
  components. This class provides a default of allowing only
  non-geometrical  modifications to its components.

 
  HISTORY
 
  hgw     08/31/87    design and coding
  mrm     04/16/91    add overrides for GRptprocess and GRlnprocess
  scw     05/08/92    ANSI conversion
*/

class specification GRowner (1:0) of GRvg, GRcmpowner;

#include "growner.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

override 
  GRvg;


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

message GRget_owner_properties
(
  IGRlong *msg;
  IGRshort *properties;
);

message GRget_channel_type
(
  IGRlong *msg;
  IGRint *type;
  IGRint *conn_type;
);

message GRget_context
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRmd_env *cmp_mod_env;
);

message GRget_matrix
(
  IGRlong *msg;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRshort *cmp_matrix_type;
  IGRmatrix cmp_matrix;
);

message GRchg_owner_properties
(
  IGRlong *msg;
  IGRint action;
  IGRshort *mask;
);

override
   GRgethprops,      
   GRgeomprops,      
   GRgetsymb,
   GRgetprops,           
   GRgetrang;

reject
  GRget_owner_properties,
  GRchg_owner_properties;

#ifndef BASE_EMS

message GRget_number_components
(
  IGRlong *msg;
  IGRint *count;
);

message GRget_components
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRid objects[];
  IGRint number_objects;
  IGRint *count;
  IGRint from_obj;
  IGRint to_obj;
);

message GRprismrel_owner
(
  IGRlong *msg;
  IGRshort *mx_type;
  IGRmatrix matrix;
  IGRlong *prism_rel;
  struct GRid *component_id;
  IGRlong *component_rel;
  IGRshort *type_prism;
  IGRchar *prism;
  IGRlong *relationship;
);

message GRget_locate_properties
(
  IGRlong *msg;
  IGRint *properties;
);

message GRdrop
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
);

message GRremove_components
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  IGRint *num_objects;
  struct GRobj_env objects[];
);

message GRadd_components
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  IGRint *num_objects;
  struct GRobj_env objects[];
  IGRint own_index[];
  IGRint go_index[];
);

message GRdelete_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
);

message GRcopy_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRmd_env *target_env;
  GRobjid *owner_id;
);

message GRxform_owner
(
  IGRlong *msg;
  struct GRmd_env *md_env;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  GRobjid *newobjid;
  IGRint *cont;
);

message GRpost_clip_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRmd_env *target_env;
  IGRchar *prism;
  struct GRid *inside_id;
  struct GRid *outside_id;
  struct GRid *overlap_id;
  IGRlong *clip_flag;
);

message GRreplace
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRmd_env *lib_env;
  struct GRid *def_id;
  struct GRid *new_id;
);

message GRis_component_removeable
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
  struct GRid *comp_id;
  IGRint *flag;
);

message GRadd_to_active_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
);

message GRset_active_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
);

message GRclear_active_owner
(
  IGRlong *msg;
  struct GRmd_env *mod_env;
);

message GRget_siblings
(
  IGRlong *msg;
  IGRushort opts;
  IGRint *num_siblings;
  struct GRid **siblings;
  IGRint num_buff;
  struct GRid *buff;
);

message GRpass_messg
(
  IGRlong *msg;
  IGRushort opts;
  OM_E_WRT_FLAG wrt_flag;
  OM_p_MESSAGE messg;
  struct GRmdenv_info *my_mdenv_info;
  OM_p_CLASSLIST yes_classes;
  OM_p_CLASSLIST no_classes;
  IGRboolean (*eligfunc)();
  IGRchar *eligfunc_args;
  IGRint depth;
);

reject 
  GRidchanged,              
  GRlocaldp,                
  GRdetplane,               
  GRset_active_owner,       
  GRclear_active_owner,     
  GRreplace,
  GRcoplanar,               
  GRcpforundo,              
  GRundocp,                 
  GRinplane;                

override
   GRchghprops,      
   GRchgcolor,       
   GRchgdp,          
   GRchglevel,       
   GRchgstyle,       
   GRchgweight,      
   GRputsymb,        
   unknown,              
   GRxform,              
   GRcopy,               
   GRdelete,             
   GRapprojpt,           
   GRptproject,          
   GRlnproject,          
   GRdisyourself,        
   GRplotyourself,       
   GRremwrng,            
   GRaddwrng,            
   GRchgprops,           
   GRformatele,          
   GRptprocess,          
   GRlnprocess,          
   GRkeypoint,           
   GRprojpt,             
   GRptdis,              
   GRownaddwrng,         
   GRownremwrng,         
   GRclip,               
   GRcomponent_idchanged,
   GRprismrel,           
   GRlocate,             
   GRlocate_processing,  
   GRlocate_owner;

#endif

end specification GRowner;
