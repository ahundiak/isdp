/* #######################    APOGEE COMPILED   ######################## */
/* Command definition section */

options         "t"
product_name    "$GRNUC"
spec_path       "$GRNUC/spec"
class           COactly
super_class     COlayer
start_state     terminate

/* Specification section .. code for .S file */

specification

#include "gr.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "godef.h"



implementation

#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <FI.h>

#include "OMminimum.h"
#include "coimport.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "lydef.h"
#include "grmessage.h"

/* prototype files */
#include "GRdpbfunc.h"

#define  OCC_TEXT  19
#define  OCC_ROLL_TEXT  26
#define  LY_SEARCH_TEXT 24

from DPlvldir import translate_level_to_number;

action form_init
{
  IGRint       msg;
  IGRint       fm_ind;
  IGRchar      *form_ptr;
  IGRdouble    act_layer;

  *sts = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  /*
   * Get the form pointer.
   */

  status = om$send(msg = message CEO.get_form_ptr(GRLAYERS_FORM, &form_ptr,
                         &fm_ind, (int *)&msg),
                   senderid = my_id,
                   targetid = my_id);
  if ( !(1&status) )
  {
      om$report_error(sts = status);
      *sts = status;
      goto quit;
  }

  /*
   * Set the active layer field.
   */

  gr$get_active_layer(buffer = (IGRchar *)&me->active_layer);

  act_layer = (IGRdouble)me->active_layer;
  FIfld_set_value(form_ptr, ACT_LAYER, 0, 0, act_layer, FALSE);

  /*
   * Turn off unnecessary fields and set field to review only.
   */

  FIg_erase(form_ptr, OCC_TEXT);
  FIg_erase(form_ptr, OCC_ROLL_TEXT);
  FIg_erase(form_ptr, OCCUPIED_ROLL);
  FIg_erase(form_ptr, SEARCH_BUTTON);
  FIg_erase(form_ptr, LY_SEARCH_TEXT);
  FIg_erase(form_ptr, DELETE_BUTTON);

  FIfld_set_mode(form_ptr, LAYER_FIELD, 0, FI_SINGLE_SELECT);
  FIfld_set_mode(form_ptr, LAYER_FIELD, 1, FI_SINGLE_SELECT);
  FIfld_set_mode(form_ptr, LAYER_FIELD, 2, FI_SINGLE_SELECT);

  /*
   * Call the parent's form_init.
   */

  status = om$send(mode = OM_e_wrt_message,
                   msg = message COlayer.form_init( (IGRlong *)sts),
                   targetid = my_id);
  if ( !(1&status) )
  {
       om$report_error(sts = status);
  }

}


action form_notification /* ( int form_label; int gadget_label; double value;
                          char *form_ptr ); */
{
  IGRint    row, pos, toggle_state, tmp_int;
  IGRlong   msg;
  IGRint    msg1;
  IGRshort  level;
  IGRdouble tmp_dbl;
  IGRchar   msg_buff[100];

  /*
   * Clear the message field.
   */

  FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, "", FALSE);

  switch(gadget_label)
  {
    case LAYER_FIELD:
        FIfld_get_active_row(form_ptr, LAYER_FIELD, &row, &pos);

        if (me->group_flag == L_Off_Flag)
        {
            tmp_int = atoi(me->ind_ly[row].number);
            me->active_layer = (IGRshort) tmp_int;

            tmp_dbl = (IGRdouble) tmp_int;
            FIfld_set_value(form_ptr, ACT_LAYER, 0, 0, tmp_dbl, FALSE);
        }
        else if (me->group[row].num_lys == 1)
        {
            status = om$send(msg = message DPlvldir.translate_level_to_number
                              (&msg1, me->group[row].number,
                               &me->group[row].num_lys, &level),
                             senderid = my_id,
                             targetid = me->lvl_oid,
                             targetos = me->lvl_osnum);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto quit;
            }

            me->active_layer = level;

            tmp_dbl = (IGRdouble) level;
            FIfld_set_value(form_ptr, ACT_LAYER, 0, 0, tmp_dbl, FALSE);
        }
        else
        {
            ex$message(msgnumb =  GR_E_OneLyCanBeActLy,
                       buff = msg_buff);
            FIfld_set_text(form_ptr, LY_MESSAGE_FIELD, 0, 0, msg_buff, FALSE);
        }
        break;


    case MODE_TOGGLE:
        /*
         * Erase the field gadget.
         */

        FIg_erase(form_ptr, LAYER_FIELD);

        /*
         * Clear the rows.
         */

        FIfld_delete_rows(form_ptr, LAYER_FIELD, 0, me->total_num_names);

        toggle_state = (IGRint) value;

        if (toggle_state == 1)  /* value mode */
        {
            me->group_flag = L_Off_Flag;

            status = om$send(msg = message COlayer.display_layer_field(&msg,
                                         IND_LY, NULL, MAX_LVLDEF, form_ptr),
                             senderid = my_id,
                             targetid = my_id);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto quit;
            }

            me->total_num_names = MAX_LVLDEF;
        }
        else if (toggle_state == 0)  /* name mode */
        {
            me->group_flag = L_On_Flag;

            status = om$send(msg = message COlayer.display_layer_field(&msg, 
                                      GROUP, NULL, me->num_in_group, form_ptr),
                             senderid = my_id,
                             targetid = my_id);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto quit;
            }

            me->total_num_names = me->num_in_group;
        }
        break;


    case EXIT_SAVE:
        /*
         * Erase the form before updating the dpb so that the adp form will be
         * updated.    dhm   10/24/91
         */

        status = om$send(msg = message CEO.erase_form_by_label(form_label, 1,
                                                               &msg1),
                         senderid = my_id,
                         targetid = my_id);
        if (! (1&status) )
        {
            om$report_error(sts = status);
            goto quit;
        }

        gr$put_active_layer(buffer = (IGRchar *)&me->active_layer);
        gadget_label = EXIT_BUTTON;

      /* no break */

    default:
         status = om$send(mode = OM_e_wrt_message,
                          msg = message COlayer.form_notification(form_label,
                                 gadget_label, value, form_ptr),
                          targetid = my_id);
         if ( !(1&status) )
         {
             om$report_error(sts = status);
         }
         break;

  }  /* end switch label */

}
