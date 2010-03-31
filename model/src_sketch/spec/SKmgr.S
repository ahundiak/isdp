class specification SKmgr (2:0) of EMSassoc, dim_plan, GRowner;

#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "SKdef.h"
#include "SKinc.h"

instance SKmgr
{
  unsigned short props;

  IGRpoint origin;
  IGRvector normal, x_axis;

  variable struct SKvarinfo oldvars[];

  channel {(one_to_many, rel_ordered)} to_vars;
  channel {(one_to_many, rel_ordered)} to_constrs;
};

message SKget_xymat ( long *EMmsg;unsigned int options;
                      short *in_matrix_type; IGRmatrix in_matrix;
                     short *xy_mattyp; IGRmatrix xy_mat );
message SKgetornt ( long *msg; double *origpt; IGRvector xaxis, zaxis );
override
  GRdetplane;
#ifndef BASE_EMS


message SKinit ( long *msg; unsigned short opts; unsigned short props;
                 double *origin; IGRvector xaxis, normal );

message SKcompute ( long *msg; unsigned short opts; struct GRmd_env *md_env;
                    struct SKsolvevars **nosolution_vars, **undersolved_vars, 
                                       **oversolved_vars;
                    GRobjid *degenid );
/*
  DESCRIPTION

    This method solves the system of contraints known to this manager
    and updates it's components (including variables, geometry and the
    geometric handles to the constraints). In case there was no solution 
    to the current system, the variables which could not be determined
    are returned. Also those variables that are found to be underconstrained
    or overconstrained (the latter with the corresponding overconstraining
    constraint). Further, this method validates the topology of the sketch
    in that any vertex that changes from convex <-> concave and/or if
    there are any self-intersections in the curve geometry owned by the
    manager, these will be returned. All the output is optional (indicated
    by NULL or non-NULL arguments).

  RETURN VALUE

    The message return code will be one of the following:

    EMS_S_Success
     All went well. 

    EMS_I_Redundant
     There is an overconstraint in the system and the overconstraint is
     being returned in the output argument (if passed as non-NULL).

    EMS_I_UnderConstrained
     Variable(s) are underconstrained in the system and these are being
     returned in the output argument (if passed as non-NULL). The system
     has been solved assuming these underconstrained variables as fixed.

    EMS_E_InvalidCase
     A contradictory situation exists in the system.

    EMS_E_Fail
     Some failure

  HISTORY

    SS, RC  :  05/10/90  :  Creation Date
*/


message SKanalyze ( long *msg; unsigned short opts;
                    struct SKsolvevars *solvedvars;
                    struct SKsolvevars **undersolved_vars, **oversolved_vars;
                    struct SKsolvepath *solvepath );
/*
  DESCRIPTION

    This method is intended as the computor of the solution-path. The sequence
    in which the constraints must be solved to obtain the solution for
    the unknowns. Besides this, the method also determines the variables
    that are underconstrained and those variables that are overconstrained.
    In the latter case, it is more important to look at the constraints
    (fields within the structure returning the variable) that are thus
    redundant. Ground variables may be passed in to this method, and the method
    will treat these variables as known quantities.

  RETURN VALUE

    The message return code will be one of the following:

    EMS_S_Success
     All went well. The solution path is returned sucessfully.

    EMS_I_Redundant
     There is an overconstraint in the system and the overconstraint is
     being returned in the output argument (if passed as non-NULL).

    EMS_I_UnderConstrained
     Variable(s) are underconstrained in the system and these are being
     returned in the output argument (if passed as non-NULL). The solution
     path returned by assuming the underconstrained variables as grounds.

    EMS_E_InvalidCase
     A contradictory situation exists in the system.

    EMS_E_Fail
     Some failure

  HISTORY

    SS  :  08/14/90  :  Creation
*/


message SKvar_update ( long *msg; unsigned short opts; struct SKsolvevars *solvedvars );
/*
  DESCRIPTION 
   
    This function is used to update the variables of the system

  HISTORY

    SS  :  08/13/90  :  Creation
*/

message SKconstr_update ( long *msg; unsigned short opts; struct SKsolvevars *chg_vars;
                          struct GRmd_env *mod_env );
/*
  DESCRIPTION 
   
    This function is used to update the constraint geometry handles of the
    system.  Optionally, a list of the variables that
    have changed may be passed in. This method then updates only those
    geom-elements that have been affected.

  HISTORY

    SS  :  08/13/90  :  Creation
*/


message SKgeom_update ( long *msg; unsigned short opts; struct SKsolvevars *chg_vars;
                        struct GRmd_env *mod_env );
/*
  DESCRIPTION

    This function is used to perform the update of the geometry elements
    that comprise the system. Optionally, a list of the variables that
    have changed may be passed in. This method then updates only those
    geom-elements that have been affected.

  HISTORY

    SS  :  08/13/90  :  Creation
*/

message SKmergemgr ( long *msg; unsigned short opts; struct GRmd_env *md_env;
                     GRobjid other_mgr );
/*
  DESCRIPTION

    This method is used to merge the contents of this manager with another
    one being passed in. The oriented plane (including the x-axis) of
    the other manager must match with the oriented plane of this manager.
    If such is not the case the merge will not proceed and this invocation
    would have been a noop. Return code indicates that the managers were
    incompatible. After a successful merge the other manager is deleted.

  HISTORY

    SS  :  05/25/91  : Creation
*/


message SKputornt ( long *msg; double *origpt; IGRvector xaxis, zaxis );


/*
  DESCRIPTION

    The above two messages are used to put and get the orientation of the
    sketch plane. This information is used to transform to 2D.
*/


message SKchkcycle ( long *msg; unsigned short opts; struct GRid *conflict_parent );


message SKsaveolddim ( long *msg; unsigned short opts; double oldval; GRobjid dimobj );

message SKsavestate ( long *msg; unsigned short opts; struct SKsolvevars *newvars );

message SKundo ( long *msg; unsigned short opts; struct GRmd_env *md_env );

message SKundo_dimval ( long *msg; unsigned short opts );

message SKgetvarconstrs ( long *msg; unsigned short opts;
                          struct SKsolvevars **varlist; int *num_constrs; 
                          struct SKconstrinfo **constrs );

message SKdisplay_underconstrained ( long *msg; unsigned short opts; struct GRmd_env *md_env );

message SKmgrprops ( long *msg; short actdef;
                     unsigned short inprops;
                     unsigned short *outprops );

message SKgetxyrange ( long *msg; double xyrange [2] [2] );

message SKtransform_pt ( long *EMmsg; unsigned int options;
                         short *mattyp; IGRmatrix matrix;
                         int num_pts;double *pts; double *xypts );

message SKintcopy ( long *msg; unsigned short options; struct GRmd_env *obj_env;
                    struct GRmd_env *new_mdenv; GRobjid *newobjid;
                    struct EMcp_info *copy_info );


message SKconnect_to_ptvar ( long *EMmsg; OM_S_OBJID ptvar_id;
                             unsigned short options; int pt_index, mgr_index );

message SKreturn_yourself ( long *EMmsg; OM_S_OBJID *skobjid );


override
  debug,
  GRdisplay, GRdelete, GRgetobjinfo, GRaddwrng, GRremwrng,
  GRchgcolor, GRchgweight, GRchgstyle, GRchglevel,
  GRchgdp, GRgetsymb, GRputsymb, GRchgprops,
  GRcopy, GRdisyourself, GRlocate_owner, GRremove_components,
  GRxform,
  GRclip,
/*
 * This override sets the manager to be out of date so that the same
 * can be recomputed.
 */
  NDchange_connect,
/*
 * This override will puts the dimensions (graphic handles) and
 * geometry into the list that is going to get copied.
 */
  NDselect_copy,
/*
 * This override will indicate that manager can only participate in
 * a drop macro for now.
 */
  ACbecome_macro,
/*
 * This override will copy the manager lock,stock and barrel except
 * dimensional handles. Also it makes all internal channel connections 
 * too.
 */
  NDcopy_graph,
/*
 * This override connects the new datum plane entity to the copy of the
 * manager and rigidly connects the new dimensional handles to the
 * explicit constraints.
 */
  NDconnect_graph,
/*
 * Return failure
 */
  NDcopy_to_root,
/*
 * Return the type to be other_generic
 */ 
  NDgive_structure,
/*
 * Copy the profile/s non-associatively.
 */
  ACcopy_to_Groot,
/*
 * Just to be safe, do not do anthing. This message should never be
 * sent to me.
 */
  NDcopy,
/*
 * Return myself as the graphic object.
 */
   ASreturn_go,
/*
 * Become stupid if my parents get deleted.
 */
  NDmove_to_root,
  NDdisplay, NDget_objects, NDmake_source, NDupdate;

reject GRkeypoint;

/*
 *  Override GRanalyze_element - added on 01/30/95 by  Sudha
 */
override  GRanalyze_element;

#endif

end specification SKmgr;
