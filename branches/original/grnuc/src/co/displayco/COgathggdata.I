/* #######################    APOGEE COMPILED   ######################## */
class implementation COvwchar;


#include <FI.h>
#include "exdef.h"
#include "exmacros.h"
#include "exfi.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "lydef.h"
#include "viewdef.h"
#include "msdef.h"
#include "grmessage.h"

%safe
#include "DPsetinq.h"
#include "GRicvtalfn.h"
%endsafe


method gather_gg_data()
{
  IGRlong   msg;
  IGRint    msg2;
  IGRint    fm_ind, status = OM_S_SUCCESS;
  IGRchar   *form_ptr, *str_ptr[5], buff1[EXFI_STRLEN], buff2[EXFI_STRLEN],
            buff3[EXFI_STRLEN];
  IGRshort  num_alias = 1;
  IGRshort  field_size = sizeof(IGRchar) * EXFI_STRLEN;
  IGRlong   return_bytes;
  IGRlong   error;
  IGRdouble temp_double, temp;
  struct var_list   gad_list[12];


  /* Set toggle projection to FALSE */

  me->toggle_proj = FALSE;

  /* Store window event */

  me->win_response  = me->event1.response;
  me->win_nbytes    = me->event1.nbytes;
  me->win_resp_data = me->response_data;

  /*
   * Get the form pointer.
   */

  status = om$send(msg = message CEO.get_form_ptr(VIEW_FORM, &form_ptr,
                         &fm_ind, &msg2),
                   senderid = my_id,
                   targetid = my_id);
  if ( !(1&status) )
  {
    om$report_error(sts = status);
    goto fini;
  }

  /* 
   * Get the graphic gadget information.
   */

  gad_list[0].var = GRAGAD_NAME;
  gad_list[0].var_ptr = (IGRchar *)me->name;
  gad_list[0].num_bytes = sizeof(IGRchar) * DI_PATH_MAX;
  gad_list[0].bytes_returned = &return_bytes;

  gad_list[1].var = GRAGAD_FLAGS;
  gad_list[1].var_ptr = (IGRchar *)&me->flags;
  gad_list[1].num_bytes = sizeof(IGRint); 
  gad_list[1].bytes_returned = &return_bytes;

  gad_list[2].var = GRID_PER_REF_X;
  gad_list[2].var_ptr = (IGRchar *)&me->num_grid_x;
  gad_list[2].num_bytes = sizeof(IGRlong); 
  gad_list[2].bytes_returned = &return_bytes;

  gad_list[3].var = GRID_PER_REF_Y;
  gad_list[3].var_ptr = (IGRchar *)&me->num_grid_y;
  gad_list[3].num_bytes = sizeof(IGRlong); 
  gad_list[3].bytes_returned = &return_bytes;

  gad_list[4].var = VW_VOLUME;
  gad_list[4].var_ptr = (IGRchar *)me->vw_vol;
  gad_list[4].num_bytes = sizeof(IGRdouble)*6; 
  gad_list[4].bytes_returned = &return_bytes;

  gad_list[5].var = WLD_TO_VIEW;
  gad_list[5].var_ptr = (IGRchar *)me->wld_to_view;
  gad_list[5].num_bytes = sizeof(IGRdouble)*16; 
  gad_list[5].bytes_returned = &return_bytes;

  gad_list[6].var = UOR_PER_REF_X;
  gad_list[6].var_ptr = (IGRchar *)&me->dis_grid[0];
  gad_list[6].num_bytes = sizeof(IGRdouble); 
  gad_list[6].bytes_returned = &return_bytes;

  gad_list[7].var = UOR_PER_REF_Y;
  gad_list[7].var_ptr = (IGRchar *)&me->dis_grid[1];
  gad_list[7].num_bytes = sizeof(IGRdouble); 
  gad_list[7].bytes_returned = &return_bytes;

  gad_list[8].var = WLD_ACT_Z;
  gad_list[8].var_ptr = (IGRchar *)&me->wld_act_z;
  gad_list[8].num_bytes = sizeof(IGRdouble); 
  gad_list[8].bytes_returned = &return_bytes;

  gad_list[9].var = WLD_DISPLAY_DEPTHS;
  gad_list[9].var_ptr = (IGRchar *)me->wld_dis_dep;
  gad_list[9].num_bytes = sizeof(IGRdouble)*2; 
  gad_list[9].bytes_returned = &return_bytes;

  gad_list[10].var = CONSTRUCT_PL_ORG;
  gad_list[10].var_ptr = (IGRchar *)me->const_org;
  gad_list[10].num_bytes = sizeof(IGRdouble)*3; 
  gad_list[10].bytes_returned = &return_bytes;

  gad_list[11].var = END_PARAM;

  status = dp$inq_set_gragad(msg = &msg, which_error = &error, 
                             var_list = gad_list,
                             gragad_objid = me->source_id.objid,
                             osnum =  me->source_id.osnum);
  if ( !(status & 1))
  {
    om$report_error(sts = status);
    goto fini;
  }

  /* Set the name field on the form */

  FIfld_set_text(form_ptr, VW_NAME, 0, 0, me->name, FALSE);

  /* Set the active z field on the form */

  status = co$cvt_imp_to_alias(msg = &msg,
                               unit_type = "UOM_DISTANCE",
                               osnum = me->source_id.osnum,
                               working_units = &me->wld_act_z,
                               num_alias = &num_alias,
                               num_conversions = 1,
                               field_size = &field_size,
                               cvt_list = (IGRchar **)buff1);

  FIfld_set_text(form_ptr, ACT_Z, 0, 0, buff1, FALSE);

  /* Set the display depth on the form */

  /* If perspective flip the back and the front clipping planes */
  /* Seet TR# 119220051                                         */

  if ( me->flags &  IS_PERSP )
  {
     temp = me->wld_dis_dep[0];
     me->wld_dis_dep[0] =  me->wld_dis_dep[1];
     me->wld_dis_dep[1] =  temp;
  }
  str_ptr[0] = buff1;
  str_ptr[1] = buff2;	

  status = co$cvt_imp_to_alias(msg = &msg,
                               unit_type = "UOM_DISTANCE",
                               osnum = me->source_id.osnum,
                               working_units = me->wld_dis_dep,
                               num_alias = &num_alias,
                               num_conversions = 2,
                               field_size = &field_size,
                               cvt_list = str_ptr);

  FIfld_set_text(form_ptr, B_CLIP, 0, 0, buff1, FALSE);
  FIfld_set_text(form_ptr, F_CLIP, 0, 0, buff2, FALSE);

  /* Set the construction plane fields */

  if ((!(me->flags & CONST_PL_DEF)) || (me->flags & IS_PERSP))
  {
    FIg_set_state_off(form_ptr, CONST_PL_OF);

    FIfld_set_mode(form_ptr, CONST_PL_X, 0, FI_REVIEW);
    FIfld_set_mode(form_ptr, CONST_PL_Y, 0, FI_REVIEW);
    FIfld_set_mode(form_ptr, CONST_PL_Z, 0, FI_REVIEW);

  }
  else
  {
    if (me->flags & CONST_PLANE_ON)
    {
      FIg_set_state_on(form_ptr, CONST_PL_OF);
    }
    else
    {
      FIg_set_state_off(form_ptr, CONST_PL_OF);

    }

    str_ptr[0] = buff1;
    str_ptr[1] = buff2;
    str_ptr[2] = buff3;

    status = co$cvt_imp_to_alias(msg = &msg,
                                 unit_type = "UOM_DISTANCE",
                                 osnum = me->source_id.osnum,
                                 working_units = me->const_org,
                                 num_alias = &num_alias,
                                 num_conversions = 3,
                                 field_size = &field_size,
                                 cvt_list = str_ptr);

    FIfld_set_mode(form_ptr, CONST_PL_X, 0, FI_INSERT);
    FIfld_set_mode(form_ptr, CONST_PL_Y, 0, FI_INSERT);
    FIfld_set_mode(form_ptr, CONST_PL_Z, 0, FI_INSERT);

    FIfld_set_text(form_ptr, CONST_PL_X, 0, 0, buff1, FALSE);
    FIfld_set_text(form_ptr, CONST_PL_Y, 0, 0, buff2, FALSE);
    FIfld_set_text(form_ptr, CONST_PL_Z, 0, 0, buff3, FALSE);

  }

  /* Set the toggles on the form */

  if (me->flags & IS_PERSP)
  {
    FIg_set_state_on(form_ptr, PROJECTION);
  }
  else
  {
    FIg_set_state_off(form_ptr, PROJECTION);
  }

  if (me->flags & DP_DELAY)
  {
    FIg_set_state_on(form_ptr, DELAY_OF);
  }
  else
  {
    FIg_set_state_off(form_ptr, DELAY_OF);
  }

  /* This is backwards of what it would seem to be */

  if (me->flags & GRID_ON)
  {
    FIg_set_state_off(form_ptr, GRID_OF);
  }
  else
  {
    FIg_set_state_on(form_ptr, GRID_OF);
  } 

  /* Ground plane added for I/DESIGN - S.P. Rogers  30 July 1992 */
  /* This toggle only exists on the I/DESIGN version of the form */
  if (me->flags & DP_GROUND_PLANE)
  {
    FIg_set_state_on(form_ptr, GROUND_PLANE);
  }
  else
  {
    FIg_set_state_off(form_ptr, GROUND_PLANE);
  } 

  if (me->flags & GRID_LOCK)
  {
    FIg_set_state_on(form_ptr, GRID_LK);
  }
  else
  {
    FIg_set_state_off(form_ptr, GRID_LK);
  }

  /* Set the grid distance fields */

  str_ptr[0] = buff1;
  str_ptr[1] = buff2;

  status = co$cvt_imp_to_alias(msg = &msg,
                               unit_type = "UOM_DISTANCE",
                               osnum = me->source_id.osnum,
                               working_units = me->dis_grid,
                               num_alias = &num_alias,
                               num_conversions = 2,
                               field_size = &field_size,
                               cvt_list = str_ptr);

  FIfld_set_text(form_ptr, GRID_X_DIS, 0, 0, buff1, FALSE);
  FIfld_set_text(form_ptr, GRID_Y_DIS, 0, 0, buff2, FALSE);

  /* Set the number of grid dots fields */

  temp_double = (IGRdouble) me->num_grid_x;
  FIfld_set_value(form_ptr, GRID_X_NUM, 0, 0, temp_double, FALSE);
  temp_double = (IGRdouble) me->num_grid_y;
  FIfld_set_value(form_ptr, GRID_Y_NUM, 0, 0, temp_double, FALSE);


/*  if (me->lyform_created)
  {
    status = om$send(msg = message COvwly.form_init(&msg),
                      targetid = my_id);
    if ( ! (status & 1) )
    {
      printf ( "problem in init_stuff\n" );
      om$report_error ( sts = status );
    }
*/


fini:
  return(status);

}
 
end implementation COvwchar;
