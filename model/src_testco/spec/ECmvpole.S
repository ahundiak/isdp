class specification ECmvpole (1:0) of ECcmd;


/*
Abstract
	This command object modifies an element by moving a selected pole.

Notes
	This command was originally written by siki on 10/04/86.

History
    dhm	    7/6/87      creation date.
    dhm	    1/12/88     converted to 1.1.0.
    dhm     6/1/88      added Jeff J.'s code.
    dhm     6/13/88     added maintain tangency at endpoints if requested.
    dhm     11/14/88    added maintain z view if requested.
    rlw     01/05/89    Fixed command key.
    gupta   12/15/89    Fixed bugs.
    RC      01/16/90    Commented some code. See comments.
    Carlos  02/18/92    Changed product_name and spec_path from $EMS to $MODEL.
    scw     06/10/93    Added initialization of matrix_type (check_for_endpt)
    dhm     10/27/93    Added has_owner instance data and check_ancestry method
    dhm     10/29/93    un-COB'ed it.
*/



instance ECmvpole
{
  IGRpoint      pole;           /* pole to modify */
  IGRboolean	polydis;        /* saved polygon display of object */
  IGRboolean	chg_class_flag; /* flag indicating class changed */
  IGRboolean    tangency_cond;  /* flag indicating tangency endpnt's */
  IGRboolean    zview_cond;     /* flag indicating map to z view */
  IGRboolean    has_owner;      /* flag indicating if object has an owner */
  OMuword       owner_classid;  /* class id of the curve's owner */
  GRobjid       objid;          /* objid of input element */
  struct IGRline  tan_line;     /* tangent line to project new pole onto */
  struct GRid   owner_id;       /* id of the curve's owner */
};


override init;

override delete;

message turn_poly_off ( long * sts );

override dynamics;

message delete_obj (GRobjid *objid; IGRboolean reinitialize);

message check_ancestry ( long * sts );

message change_class (IGRchar *new_class);

message turn_poly_on ( long * sts );

message keypoint_pole ( long * sts );

message check_for_endpoint ( long * sts );

message set_cond (IGRboolean  *value, condition);

message process ( long * sts );

override arg_name_to_value;

end specification ECmvpole;
