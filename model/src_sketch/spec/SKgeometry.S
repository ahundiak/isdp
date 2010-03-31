/*
  DESCRIPTION

    This is an abstract class for all of the geometrical elements
    used in skecthing.
*/

class specification SKgeometry (2:0) of NDnodein, GRcurve;

#include "ems_m_inc.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "SKdef.h"
#include "SKinc.h"

instance SKgeometry
{
  channel {(rel_ordered, many_to_many, initial=2, increment=1)} to_defpts;
};


#ifndef BASE_EMS
message SKgetmgr (IGRlong *EMmsg; GRobjid *sk_mgr_id);

message SKcreate_ptvars (IGRlong *msg; IGRushort opts;
                         IGRshort *mattyp; IGRmatrix mat;
                         IGRshort *to_xy_mattyp; IGRdouble *to_xy_mat;
                         GRobjid *skmgr;
                         IGRint *num_ptvars; GRobjid **ptvars);

message SKcreate_self_constraints (IGRlong *msg; IGRushort opts;
                                   struct GRmd_env *md_env;
                                   IGRint *num_cnstrs; GRobjid **cnstrs);


message SKcreate_constraint_points(IGRlong *EMmsg; IGRushort options;
                                   IGRshort *matrix_type;
                                   IGRmatrix matrix;
                                   OM_S_OBJID skmgr, *first, *last;
                                   IGRint *element_no;
                                   IGRint total_count);

message SKrecompute_yourself (IGRlong  *msg; struct GRmd_env *md_env;
                              IGRshort *toxyz_mattyp; IGRdouble *toxyz_mat);

message SKcheck_degeneracy (IGRlong *msg; IGRushort options; struct GRmd_env *md_env;
                            struct SKsolvevars *solvedvars;
                            GRobjid *degenerate);

message SKintcopy (IGRlong *msg; IGRushort options;
                   struct GRmd_env *obj_env;
                   struct GRmd_env *new_mdenv;
                   GRobjid         *newobjid;
                   struct EMcp_info *copy_info);


message SKconnect_to_pt (IGRlong *msg; IGRushort opts;
                         GRobjid ptobj; 
                         IGRint ptinx, myinx);
override
  /*
   * Do not do anything. Just return success.
   */
  NDcopy_graph,
/*
 * Do not allow any connections to me since I am being driven by the
 * manager. This is just a precaution and should never happen.
 */
  NDconnect_graph,
  NDconnect,
  NDdisconnect,
  NDchange_connect,
  /*
   * Indicate that this is suitable for a drop macro
   */
  ACbecome_macro,
 /*
  * Copy myself with non-associatively if I am a template.
  */
  ACcopy_to_Groot,
 /*
  * Do not do anthing. This is only a precaution. This message should
  * never hit any object of this class.
  */
  NDcopy,
 /*
  * Copy non-associatively.
  */
  NDcopy_to_root,
/*
 * Override to get the normal information from the manager object.
 * if he exists.
 */
  GRdetplane,
  NDdisplay, NDget_objects, NDupdate, NDmake_source,
  NDgive_structure,
  ASreturn_go,
  GRcopy, GRdelete, GRlocate, GRgetobjinfo,
  /* we want to return a source object (mainly for dim to connect to us) */
  GRmksource,
  debug;

reject
  SKrecompute_yourself;

#endif

end specification SKgeometry;
