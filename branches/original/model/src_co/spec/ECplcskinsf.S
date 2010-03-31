/* ###################   APOGEE COMPILED   ################## */
class specification ECplcskinsf (1:0) of ECconstruct;

instance ECplcskinsf
 {
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

  IGRlong	num_tansf;
  struct	GRlc_info supporting_curve[4];
  struct	GRlc_info tangent_surfaces[4];

  IGRboolean	absolute_orientation;
  IGRboolean	surface_is_open;
  IGRboolean	no_height_scaling;
  IGRchar	orientation_law[MAX_CHAR];
  IGRchar	shape_law[MAX_CHAR];
 };
 
message do_form (IGRlong *msg; IGRint form_label; IGRint gadget_label;
                 IGRdouble value);

override execute, display_constructions, update_status_form, status_disp,
         is_associative;

end specification ECplcskinsf;

