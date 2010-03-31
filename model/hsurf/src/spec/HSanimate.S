class specification HSanimate (1:0) of HSwindow;




instance HSanimate
{
   struct GRevent  my_event;
   IGRchar         filename[200];
   IGRdouble       bound_pts[6];
   IGRint          planes;
   IGRboolean      using_fence;  /* Doubles as indicator of whether buffers */
                                 /* need filling                            */
   IGRint          phong_flag;
   IGRint          x_pixels;
   IGRint          y_pixels;
   IGRint          scale_factor;
   WLuint32        win_no;
   IGRint          x;
   IGRint          y;
   IGRint          do_form;
   IGRint          animate;
   IGRint          delay;
   IGRint          cycle;
   IGRdouble       FrameDelay[2];
   IGRdouble       CycleDelay[2];
   IGRint          WindowErase;
   IGRint          Optimize;     /* Doubles as indicator of display type for */
                                 /* edgeII                                   */
   IGRint          SingleFrame;
   WLuint32        context_no;
   IGRint          get_window;
   IGRint          win_to_use;
   IGRint          ct_to_use;
   IGRint          converted_win;
};


message initialize_instance_data ( long * sts );

message init_form_display ( long * sts );

message load_filename_prompt ( long * sts );

message load_window_prompt ( long * sts );

message load_cmd_name_message ( long * sts );

message get_num_frames ( long * sts );

message wait_for_button ( long * sts );

message process_filename_keyin ( long * sts );

message process_overwrite_keyin ( long * sts );

message process_boundary_keyin ( long * sts );

message save_image ( long * sts );

message establish_window ( long * sts );

message fill_buffers ( long * sts );

message check_data ( long * sts );

message animate ( long * sts );

override form_notification;

message restore_colors ( long * sts );

message process_fence_pt ( IGRint *sts; IGRint which_pt );

override dynamics;

message delete_window ( long * sts );

message save_form_data ( long * sts );

message check_window ( long * sts );

message erase_window ( long * sts );

message check_window_flags ( long * sts );

message check_if_selected ( long * sts );

end specification HSanimate;
