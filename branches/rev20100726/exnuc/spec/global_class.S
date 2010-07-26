class specification global_class (1:0) of Root;

instance global_class
{
  channel {(many_to_one)} mod;
};

#ifndef BASE_EMS
message wake_up();

message super_construct();

message sleep(int type_sleep);/* type_sleep = 1 temp sleep, wake up will follow
 */
                              /* type_sleep = 0 real sleep  */

message place(OM_p_CHANSELECT chan );
#endif

end specification global_class;
