class specification SKconstraint (2:0) of EMScomposite;

#include "emsdef.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "SKdef.h"
#include "SKinc.h"

instance SKconstraint
  {
  IGRulong props;
  channel {(many_to_one)} to_mgr;
  channel {(many_to_many, rel_ordered)} to_variables;
  channel {(many_to_many, rel_ordered)} to_super_constrs;
  };

message SKgetmgr (IGRlong *msg; GRobjid *mgrid);

message SKgetprops (IGRlong *msg; IGRushort *props);

message SKchgprops (IGRlong *msg; IGRshort action; IGRushort props);

#ifndef BASE_EMS
message SKcreate_geom(IGRlong *EMmsg; unsigned short options;
                      struct GRmd_env *md_env; GRobjid *geom_handle);

message SKinit (IGRlong *msg; IGRushort opts;
                struct GRmd_env *md_env;
                IGRint num_vars; GRobjid *vars;
                IGRushort cnstr_props;
                GRobjid *geom_handle;
                IGRchar *moreinfo);

message SKvalidate (IGRlong *msg; IGRushort opts; 
                    struct GRmd_env *md_env; IGRboolean *is_valid;
                    IGRint *num_conflict_cnstr; GRobjid **conflict_cnstr);

message SKevaluate (IGRlong *msg; IGRushort opts;
                    struct SKsolvevars *tosolvevar;
                    struct SKsolvevars **solvedvars;
                    struct SKsolvevars **nosolution_vars);
/*
  ABSTRACT

    This constraint, when it receives this message, should only have 
    one unknown among the variables that it depends upon. This message then
    evaluates the unknown. The known variables are input as "solvedvars". 
    The unknown variable expected to be solved is passed in through
    "tosolvevar". If this variable cannot be solved (perhaps due to 
    insufficient "solvedvars" data) or is already solved, the method will
    return an informational message. If solved succesfully, the solved-variable
    is appended into the solvedvars list as well as the solved value output
    in the "tosolvevar" structure passed in.

  RETURN VALUE

    The message return code could be one of the following

    EMS_S_Success -
      The constraint was successfully evaluated and it's result is posted
      into the solvedvars.

    EMS_I_Insufficient -
      Insufficient information in the "solvevars" list.

    EMS_I_Redundant -
      The variable to be solved for is already in the list.

    EMS_I_NoSolution -
      This variable has no solution based on given "solvedvars"

    EMS_E_Fail -
      Any failure

  HISTORY

    SS  :  08/18/90  :  Creation
*/

message SKmakejacobian (IGRlong *msg; IGRushort options;
                        struct SKsolvevars *solvedvars, *unsolvedvars;
                        IGRdouble *jacobian_row; IGRdouble *funcval);
/*
  ABSTRACT

    This message generates the row in the Jacobian and also evaluates
    the constraint equation at the current value (taken from the solvepoints
    and/or the unsolvedvars list). By using the option SK_JACOB_ADJACENCY,
    this method can be used to output the adjacency matrix instead of the
    Jacobian, ie, TRUE in the index of all the variables that a given
    equation comprises of.

    This message may be used to return the occurence matrix of variables
    with respect to the constraint. This mode is turned on when the
    option SK_JACOB_ADJACENCY is specified.

    This message may be used to check if the geometries governed by this
    constraint are obeying the constraint within tolerance. The message
    behaves in this mode when the option SK_JACOB_ACCURACY is set. The
    constraint could be governing an angle and/or distance. The tolerances
    used are the ones set in the global variables using SKsettol(). These are
    defaulted to the basis-tol for length and EMS_ZEROANGLE_DEG for angle at
    start-up time. The list containing the current values of the variables
    that are controlled by the constraint is input. If the constraint is
    not within tolerance, the message EMS_I_OutOfBounds is returned.

  RETURN VALUE

    EMS_S_Success        - A Jacobian matrix row was evaluated corresponding
                           to this constraint.
    EMS_E_InvalidCase    - A situation was detected in the state of the
                           system that is invalid. For example, the points
                           for this constraint are not found in the lists
                           supplied.
    EMS_E_Fail           - Other failure to create row.
*/


message SKorder_points (IGRlong *msg; IGRushort options;
                        IGRint num_pts; GRobjid *pt_ids;
                        IGRchar *moreinfo);


message SKdisplay (IGRlong *msg; IGRuint options;
                   IGRshort *matrix_type; IGRmatrix matrix;
                   enum GRdpmode mode);

message SKrecompute_yourself (IGRlong *msg; struct GRmd_env *md_env;
                              IGRshort *mattyp_to_lxyz;
                              IGRdouble *mat_to_lxyz);

message SKgetconstrs (IGRlong *msg; IGRushort opts;
                      struct SKsolvevars *all_vars;
                      IGRint *num_constrs, *num_constrs_mem;
                      struct SKconstrinfo **constrs);

message SKgetpseudovarlist (IGRlong *msg; IGRushort opts;
                            struct SKsolvevars **varlist);


message SKgetmajconstrs (IGRlong *msg; IGRushort opts;
                         IGRint num_in_buff;
                         IGRint *num_major_constrs; GRobjid **major_constrs);

message SKconnect_to_pt(IGRlong *EMmsg;
                        OM_S_OBJID pt_id;
                        IGRushort options;
                        IGRint pt_index, constraint_index);

message SKconnect_to_skmgr(IGRlong *EMmsg;
                           OM_S_OBJID sk_mgr;
                           IGRushort options;
                           IGRint mgr_index, constraint_index);



message SKpass_by_class_type (IGRlong *EMmsg; OM_p_MESSAGE pass_msg; 
                              IGRushort class_types);

message SKintcopy (IGRlong *msg; IGRushort opts;
                  struct GRmd_env *obj_env, *new_mdenv;
                  GRobjid *newobjid; struct EMcp_info *copy_info);

message SKintdelete (IGRlong *msg; IGRushort opts;
                     struct GRmd_env *md_env);


message SKduplicate (IGRlong *msg; IGRushort opts;
                     GRobjid *duplicate_cnstr);

override
  debug,
  GRlocate_owner,
  GRdisplay, GRchgprops, GRdelete, GRcopy,
  GRanalyze_element;

reject
  SKcreate_geom, SKdisplay, SKrecompute_yourself, SKevaluate;

#endif

end specification SKconstraint;
