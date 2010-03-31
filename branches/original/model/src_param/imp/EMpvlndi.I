class implementation EMSparamvl;

#include "EMSasprops.h"

/*

Name
  NDgive_structure, NDgive_value

Abstract

Synopsis

Description
  These functions do the units conversion for the value of the expression
  related to the EMSparamvl object.
  
Return Value

Notes

Index

Keywords
  expression, units
  
History
  06/08/93 : Rajiv Agrawal : created

 */

method NDgive_structure (long *msg; struct  ret_struct *ptr_rst;
		 	 struct GRmd_env *md_env )
{
  IGRushort 		props;
  long 			msg_loc, stat_OM;
  double 		db_value;
  struct GRid 		my_grid;
  
  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  
  ptr_rst->type = double_type;
  db_value = me->value;

  /*
   * Check to see if units conversion needs to be done.
   */
  stat_OM = om$send ( msg = message EMScnstr.EMgetprops (&msg_loc, &props),
                      targetid = my_id );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );
  
  if (props & EMScnstr_convert_units)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &db_value, NULL, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  }
    
  ptr_rst->var.root_pm_st.value = db_value;

ret_end:
  return stat_OM;
}   

method NDgive_value( double *val )
{
  double 		db_value;
  IGRushort 		props;
  long 			msg_loc, stat_OM;
  struct GRid 		my_grid;
  
  db_value = me->value;

  /*
   * Check to see if units conversion needs to be done.
   */
  stat_OM = om$send ( msg = message EMScnstr.EMgetprops (&msg_loc, &props),
                      targetid = my_id );
  EMerr_hndlr ( EMSerror ( stat_OM & msg_loc ), stat_OM, OM_E_ABORT, ret_end );

  if (props & EMScnstr_convert_units)
  {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    EMcnvt_db_dim_units (&msg_loc, &my_grid, &db_value, NULL, TRUE);
    EMerr_hndlr (EMSerror (msg_loc), msg_loc, EMS_E_Fail, ret_end);
  }

  *val = db_value;

ret_end:
  return stat_OM;
}

end implementation EMSparamvl;

