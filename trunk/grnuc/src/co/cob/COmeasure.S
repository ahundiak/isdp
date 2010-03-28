/*

Name
  class COmeasure

Abstract
  This command object class is used to support a host of angle/distance/area
  measurement commands.  

Notes
  It can be expected that most commands that use the
  messages specified here are driven by the CEO (COB) command object protocols
  and thus state language files are used to drive them ( derived from .t files,
  perhaps in the src/co/sl directory).

History
  02/23/93 : Shelley R. Heard : headers added; COmeasure.sl deleted and 
				replaced by COmeasure.S and COmeasurei.I.

 */

class specification COmeasure (1:0) of COnpt;

instance COmeasure
{
     IGRint                  display_field;
     IGRshort                draw_mode;
     IGRdouble               form_fields[15];
     IGRdouble               cur_fields[9];
     double                  scale_fac;
     IGRchar                 Units[GRIO_MAX_ALIAS_SIZE];
     IGRboolean              push_event_flag;
     IGRboolean              cut_value_flag;
     IGRboolean              app_flag;
     IGRboolean              adv_flag;
     IGRboolean              dat_pt_flag;
     IGRboolean              ref_att_flag;
     IGRboolean              ref_lock_flag;
     IGRboolean              model_flag;
     IGRboolean              disp_flag;
     IGRdouble               distance;
     IGRdouble               cum_dist;
     IGRdouble               prev_dist;
     
     struct    GRmd_env      mod_env;
     
     struct GRIOreadout_spec cur_readout_spec;

     /* set by init/sleep/wakeup; used by form_input (srh) 02/15/89    */
     IGRboolean              SuspendedByImmediate;
};


override init;

override wakeup;

override sleep;

override status_disp;

override form_input;

message store_base_event ( long * sts );

message store_current_event ( long * sts );

message calc_delta_prev_current ( long * sts );

message calc_delta_base_current ( long * sts );

message store_dis_base_current ( long * sts );

message update_cursor_fields ( long * sts );

message update_readout_form ( long * sts );

message update_meas_form ( long * sts );

message calc_complement_angle ( long * sts );

message clear_fields ( long * sts );

message display_point (int *sts; int Index);

message display_line ( long * sts );

message measure ( long * sts );

message COdetail_model ( long * sts );

message measure_by_object ( long * sts );

message measure_two_elements ( long * sts );

message display_a_value (IGRlong   *sts;
                       IGRdouble *Value );

message clear_sum ( long * sts );

message normalize_event ( IGRlong *sts;
                        struct GRevent *event);

message project_accept_on_element ( long * sts );

message display_measurement ( long * sts );

message display_sum ( long * sts );

message is_form_displayed ( long * sts );

message save_current_readout_spec ( long * sts );

message cvt_pt_to_act_coord_sys ( long * sts );

override form_notification;

end specification COmeasure;
