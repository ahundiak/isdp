class implementation COlayer;





method init ( int type ; char * str_ptr )
{
  int		  status = OM_S_SUCCESS;

  /*
   *  Set the eligibility flag.
   */

  me->eligibility_enabled = FALSE;

  /*
   * Call the parent's init.
   */

  status = om$send(mode = OM_e_wrt_message,
                   msg = message CEO.init(type, str_ptr),
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
  }

quit:
  return OM_S_SUCCESS;
}

end implementation COlayer;
