/* ###################   APOGEE COMPILED   ################## */
class specification ECplcskin (1:0) of ECconstruct;

instance ECplcskin
 {
  IGRlong       skinning_case;
  IGRlong       violation_msg_key;
  IGRlong       num_trace;
  IGRlong	previous_trace_count;
  variable	struct GRlc_info trcobj[2];
  IGRboolean	traces_are_closed;
  IGRlong       num_cross;
  IGRlong	previous_cross_count;
  variable	struct GRlc_info crsobj[20];
  IGRboolean	crosses_are_closed;
  IGRboolean    create_composite;
  IGRboolean    smooth;
  IGRboolean    tan_constrnt;
  IGRboolean    chk_perm_form;
  IGRint        active_form;
  Form          case_form, op_form1, op_form2, subform;

  IGRlong	num_tansf;
  struct	GRlc_info supporting_curve[4];
  struct	GRlc_info tangent_surfaces[4];

  IGRboolean	auto_orientation;
  IGRboolean	absolute_orientation;
  IGRboolean	surface_is_open;
  IGRboolean	no_height_scaling;
  IGRchar	orientation_law[MAX_CHAR];
  IGRchar	shape_law[MAX_CHAR];
 };
 
message option_invalidation();

message select_case (IGRint form_action;
                     int *response; char *response_data);

message create_form (int form_label;
                     char *form_name; Form *form);

message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value; Form fp);

override execute, display_constructions, update_status_form, status_disp,
         is_associative, init, sleep;

end specification ECplcskin;

