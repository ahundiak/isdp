/*
  DESCRIPTION

  This is a cross section abstract class.


  HISTORY

  RC      08/24/88    Creation Date
*/

class specification EMSxsection (2:0) of GRlistener;

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

#include "OMerrordef.h" 
#include <math.h>
#include "emsmacros_c.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSerrordef.h"
#include "EMSerrnumdef.h"
#include "EMSobjmgr.h"
#include "EMSobjmgrdef.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance EMSxsection
{
  channel {(rel_ordered,many_to_many,initial=1,increment=1)
      GRnotify.notification;} to_model;
};


/*--------------- MESSAGE DECLARATION SECTION ----------------*/

#ifndef BASE_EMS

message EMupdate
(
  IGRlong *EMmsg;
  struct GRmd_env *cs_env;
  struct GRvg_construct *construct_list;
);

message EMperform_xsection_update
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  struct GRmd_env *cs_env;
  struct GRmd_env *mdl_env;
  struct EMSsfs_md_info *sfs_md_info;
  struct EMSxsreg_md_info *reg_md_info;
  struct EMSxs_assoc_info *xs_assoc_info;
  GRrange mdl_range;
  struct GRid *xs_act_st_GRid;
  IGRboolean *is_sf_active;
);

message EMperform_xsection
(
  IGRlong *EMmsg;
  struct GRvg_construct *construct_list;
  struct GRmd_env *cs_env;
  struct GRid *model_GRid;
  struct GRmd_env *model_env;
  struct EMSxs_assoc_info *xs_assoc_info;
);

message EMget_active_inactive_sfs
(
  IGRlong *EMmsg;
  GRobjid **active_sf_ids;
  IGRint *num_active_sfs;
  IGRint *active_sf_arrsz;
  GRobjid **inactive_sf_ids;
  IGRint *num_inactive_sfs;
  IGRint *inactive_sf_arrsz;
);
                           
message EMxsec_int_xform
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  IGRshort *matrix_type;
  IGRmatrix matrix;
  IGRmatrix inv_matrix;
  GRobjid *newobjid;
  IGRboolean xform_thru_notification;
);

message EMget_associated_edges
(
  IGRlong *EMmsg;
  GRobjid **act_eds;
  GRobjid **inact_eds;
  IGRint *num_act_eds;
  IGRint *num_inact_eds;
  IGRint *act_eds_arrsz;
  IGRint *inact_eds_arrsz;
  IGRushort options;
  IGRint tree_depth;
);

message EMchange_class
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
  GRobjid *newobjid;
);

message EMdeact_xsection
(
  IGRlong *EMmsg;
  IGRshort *option;
  struct GRmd_env *md_env;
  GRobjid **display_ids;
  IGRint *display_count;
);

message EMattach_vsgd
(
  IGRlong *EMMsg;
  struct GRid *vd_wn_GRid;
);
        
message EMconnect_edges
(
  IGRlong *EMmsg;
  struct GRmd_env *md_env;
);

reject
  EMchange_class,
  EMget_associated_edges,
  EMxsec_int_xform,
  EMperform_xsection_update,
  EMperform_xsection,
  EMget_active_inactive_sfs,
  EMdeact_xsection,
  EMattach_vsgd,
  EMconnect_edges;

override  
  EMupdate,
  GRnotifylis;

#endif

end specification EMSxsection;
