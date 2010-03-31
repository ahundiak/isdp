/* ###################   APOGEE COMPILED   ################## */
class specification ECplcsknsf (1:0) of ECconstruct;

instance ECplcsknsf
 {
  IGRlong       num_trace;
  struct        GRlc_info trcobj[2];
  IGRlong       num_cross;
  variable	struct GRlc_info crsobj[20];
  IGRlong	previous_trace_count;
  IGRlong	previous_cross_count;
  IGRboolean    scaling, on_site;
  IGRpoint      trace_end_point[2];
  IGRdouble     view_matrix[3][3];
  IGRpoint      ref_pnts[2];
  IGRpoint      vector_points[3];
 };
 
override wakeup, execute, sleep, display_constructions;

end specification ECplcsknsf;

