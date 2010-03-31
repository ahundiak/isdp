/*
  DESCRIPTION

    This is an abstract class that is the super class for all "intelligent"
    geometric parameters - points, lines, planes, etc. - and sets any 
    additional protocols for the same. This excludes 2D variational geometric
    variables.

  HISTORY

    SS  :  03/14/91  :  Creation
*/

class specification EMSparamgm (2:0) of GRbspline, DMsrc, EMSparameter;

message EMconstruct (IGRlong *msg; IGRushort opts;
                     IGRshort *mattyp; IGRmatrix mat;
                     struct EMSgeomdata *geomdata);

message EMgetgeom (IGRlong *msg; IGRushort opts;
                   IGRshort *mattyp; IGRmatrix mat;
                   struct EMSgeomdata *geomdata);

message EMdisplay (IGRlong *msg; IGRushort opts;
                   IGRshort *mattyp; IGRmatrix mat;
                   struct IGRdisplay *disp_attr;
                   enum GRdpmode dpmode;
                   struct GRid *win_or_mod_id);

/*
  DESCRIPTION

    This message is used to obtain the current value of the parameter
    that satisifes all constraints on it. Optionally, the constraints
    can be passed to it (otherwise this object tries to obtain it's
    constraints on it's own). Also, optionally (if args are non-NULL), the
    method will return the constraints that conflict with each other to
    cause the parameter not to be solved. 

    The arguments: cnstrs, solvedgm and/or conflict_cnstrs can be specified as
    NULL.

    Return codes of EMS_S_Success, EMS_E_Fail, EMS_I_Redundant,
    EMS_I_NoSolution or EMS_I_Cycle are returned. The return code of
    EMS_I_Cycle indicates that a dependency cycle has been introduced.
*/

message EMsolve (IGRlong *msg; IGRushort opts;
                 IGRint num_cnstrs; struct GRid *cnstrs;
                 struct GRmd_env *md_env;
                 struct EMSgeomdata *solvedgm;
                 IGRint *num_conflict_cnstr; struct GRid conflict_cnstr[3];
                 IGRint *num_undercnstr; IGRvector undercnstr_vecs[3]);

message EMdisplay_underconstrained (IGRlong *msg; IGRushort opts;
                                    struct GRmd_env *md_env);

message EMlnmindist (IGRlong *msg; IGRushort opts;
                     IGRshort *mattyp; IGRmatrix mat;
                     struct IGRline *line;
                     IGRdouble *mindist);

message EMgeomhandle (IGRlong *msg; IGRushort opts;
                      struct GRmd_env *md_env);

override
/*
 * Return invalid if I am a root element. Otherwise indicate that I
 * am valid for a drop macro placement.
 */
  ACbecome_macro,
/*
 * If the the parent being deleted is the only one parent that I have, ONLY
 * THEN should I let the default handling of this message (which moves me to
 * root) be invoked. Otherwise, the message send acts as a noop.
 */
  NDparent_deleted,
/*
 * Put all its parents into the list that is going to get copied.
 */
  NDselect_copy,
/*
 * Copy myself for graph purposes.
 */
  NDcopy_graph,
/*
 * Give the type as other_generic.
 */
  NDgive_structure,
/*
 * Display myself.
 */
/*
 * Return nothing.
 */
  ACcopy_to_Groot,
/*
 * Return myself.
 */
  ASreturn_go,
/*
 * To change EMSparampt class to EMSparamptn so that the same has the
 * notify channel for connection across object spaces.
 */
  NDmake_source, 
  NDdisplay,
  NDupdate,
  EMparam_delete,
  GRlocate, GRdelete, GRdisplay,
  EMis_externally_constrained;

from GRbspline inherit
  GRptproject, GRlnproject, GRmidpoint, GRendpts, GRkeypoint, GRdetplane;

from DMsrc inherit
  ASreturn_go;

reject
  EMconstruct,
  EMgetgeom,
  EMdisplay,
  EMlnmindist;

end specification EMSparamgm;
