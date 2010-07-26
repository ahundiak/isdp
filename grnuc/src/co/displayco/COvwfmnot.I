class implementation COvwchar;


#include        <FI.h>
#include 	"exdef.h"
#include	"exmacros.h"
#include        "exfi.h"
#include	"dpdef.h"
#include 	"dp.h"
#include	"dpmacros.h"
#include	"lydef.h"
#include 	"viewdef.h"
#include	"msdef.h"
#include 	"grmessage.h"
#include 	"griodef.h"
#include        "grdpbdef.h"
#include        "grdpbmacros.h"

%safe
/* prototype files */
#include        "COexpreval.h"
#include        "COepp.h"
#include        "DPsetinq.h"
#include	"GRdpbfunc.h"
#include	"GRicvtalfn.h"
%endsafe

short  saved_act_layer;


method form_notification( int form_label; int gadget_label; double value;
                          char *form_ptr )
{

  IGRlong          msg, bytes_returned, which_error;
  IGRint           status, toggle_state, fm_ind;
  IGRint           length, flag, pos, index;
  IGRshort         num_alias;
  IGRshort         field_size, act_layer;
  IGRdouble        temp_double, *value_ptr = NULL;
  IGRchar          *text = NULL, char_buf[EXFI_STRLEN], *ly_form_ptr;
  struct var_list  var_list[2];
  IGRlong          size;
  IGRint           response;
  IGRchar          command_key[30];
  IGRint           exit_response;
  IGRint           msg1;
  IGRlong          num_bytes;

  status = OM_S_SUCCESS;
  num_alias = 1;
  index = 0;

  switch(form_label)
  {
    case VIEW_FORM:

   	switch(gadget_label)
   	{

         case VW_NAME:
            FIfld_get_text_length(form_ptr, VW_NAME, 0, 0, &length);

            text = (IGRchar *) om$malloc(size = length * sizeof(IGRchar) );

            FIfld_get_text(form_ptr, VW_NAME, 0, 0, length, text, &flag, &pos);

            strcpy(me->name, text);

            break;


         case ACT_Z:
         case F_CLIP:
         case B_CLIP:
         case CONST_PL_X:
         case CONST_PL_Y:
         case CONST_PL_Z:
         case GRID_X_DIS:
         case GRID_Y_DIS:
            switch(gadget_label)
            {
             case ACT_Z:
                value_ptr = &me->wld_act_z;
                break;

             case F_CLIP:
                value_ptr = &me->wld_dis_dep[1];
                break;

             case B_CLIP:
                value_ptr = &me->wld_dis_dep[0];
                break;

             case CONST_PL_X:
                value_ptr = &me->const_org[0];
                break;

             case CONST_PL_Y:
                value_ptr = &me->const_org[1];
                break;

             case CONST_PL_Z:
                value_ptr = &me->const_org[2];
                break;

             case GRID_X_DIS:
                value_ptr = &me->dis_grid[0];
                break;

             case GRID_Y_DIS:
                value_ptr = &me->dis_grid[1];
                break;

            }  /* end switch */

            /*
             * Get the text that the user keyed in.
             */

            FIfld_get_text_length(form_ptr, gadget_label, 0, 0, &length);

            text = (IGRchar *) om$malloc(size = length * sizeof(IGRchar) );

            FIfld_get_text(form_ptr, gadget_label, 0, 0, length, text, &flag,
                           &pos);

            /*
             * Convert what the user keyed in to a double.
             */

            co$epp(msg = &msg,
                   string = text,
                   sizebuf = EXFI_STRLEN,
                   buffer = char_buf);

            co$expreval(msg = &msg,
                        expression = char_buf,
                        unit_type = "UOM_DISTANCE",
                        result = &temp_double);

            if (!(msg & 1))
            {
               /*
                * Output error message to the form.
                */

                ex$message(msgnumb = GR_E_InvInp,
                           buff = char_buf);

                FIfld_set_text(form_ptr, ERROR_FIELD, 0, 0, char_buf, FALSE);

               /*
                * Put the previous value back to the form if the conversion to
                * a double failed.
                */

                field_size = length * sizeof(IGRchar);
                status = co$cvt_imp_to_alias(msg = &msg,
                                 unit_type = GRIO_DISTANCE,
                                 osnum = me->source_id.osnum,
                                 working_units = value_ptr,
                                 num_alias = &num_alias,
                                 num_conversions = 1,
                                 field_size = &field_size,
                                 cvt_list = (char **)text);

                FIfld_set_text(form_ptr, gadget_label, 0, 0, text, FALSE);

            }
            else
            {
                *value_ptr = temp_double;
            }

            break;

	    
         case CONST_PL_OF:
            toggle_state = (int) value;

            if (toggle_state == 1)
            {
               if((me->flags & IS_PERSP) || (!(me->flags & CONST_PL_DEF)))
               {
                  FIg_set_state_off(form_ptr, CONST_PL_OF);

                  ex$message (msgnumb = GR_E_CnsPlNotDnf,
                              buff = char_buf);

                  FIfld_set_text(form_ptr, ERROR_FIELD, 0, 0, char_buf, 
                                  FALSE);
               }
               else
               {
                  me->flags |= CONST_PLANE_ON;
                  me->flags |= VALID_ALT_INV;
               }
            }
            else
            {
               me->flags &= ~CONST_PLANE_ON;
               me->flags &= ~VALID_ALT_INV;
            }

            break;


         case PROJECTION:
/*
            toggle_state = (int) value;

            if (toggle_state == 1)
            {
                me->flags |= IS_PERSP;
            }
            else
            {
                me->flags &= ~IS_PERSP;
            }
*/

	    me->toggle_proj = ((me->flags & IS_PERSP) && (value == 0)) 
                               || (!(me->flags & IS_PERSP) && (value == 1));

            break;


         case DELAY_OF:
            toggle_state = (int) value;

            if (toggle_state == 1)
            {
                me->flags |= DP_DELAY;
            }
            else
            {
                me->flags &= ~DP_DELAY;
            }

            break;


         case GRID_OF:
            toggle_state = (int) value;

            if (toggle_state == 0)
            {
                me->flags |= GRID_ON;
            }
            else
            {
                me->flags &= ~GRID_ON;
            }

            break;

	 /* Ground plane added for I/DESIGN - S.P. Rogers  30 July 1992  */
	 /* This toggle only appears on the I/DESIGN version of the form */
         case GROUND_PLANE:
	    me->flags ^= DP_GROUND_PLANE;
            break;


         case GRID_LK:
            toggle_state = (int) value;

            if (toggle_state == 1)
            {
                me->flags |= GRID_LOCK;
            }
            else
            {
                me->flags &= ~GRID_LOCK;
            }

            break;

         case GRID_X_NUM:
            FIfld_get_value(form_ptr, GRID_X_NUM, 0, 0, &temp_double,
                            &flag, &pos);
            me->num_grid_x = (int) temp_double;
            break;


         case GRID_Y_NUM:
            FIfld_get_value(form_ptr, GRID_Y_NUM, 0, 0, &temp_double,
                            &flag, &pos);
            me->num_grid_y = (int) temp_double;
            break;


     /*
      *  The form will be sent two form input messages whenever this button
      *  is hit.  If it is the first time the button is hit the EXFI_SUBFORM 
      *  will be sent.  This is sent after an init_form is sent to the subform 
      *  and before a display form is sent to the subform.
      */
         case LAYERS:
            FIg_set_state_off(form_ptr, LAYERS);

              /*
               * Going to use this later to check to see if active layer 
               * changed.     dhm   10/24/91
               */

            gr$get_active_layer(buffer = (IGRchar *)&saved_act_layer);

             /*
              * Get the layers on/off mask.
              */

            var_list[0].var = LEVELS;
            var_list[0].var_ptr = (IGRchar *)me->elig_mask;
            var_list[0].num_bytes = sizeof(IGRlong) * 32;
            var_list[0].bytes_returned = &bytes_returned;
            var_list[1].var = END_PARAM;

            status = dp$inq_set_gragad(msg = &msg,
                                       osnum = me->source_id.osnum,
                                       gragad_objid = me->source_id.objid,
                                       which_error = &which_error,
                                       var_list = var_list);
            if ( ! (status & 1) )
            {
#ifdef DEBUG
                printf ( "problem in init_stuff\n" );
                om$report_error ( sts = status );
#endif
            }

              /*
               * Get the form pointer for the GRLayers form.
               */

            status = om$send(msg = message CEO.get_form_ptr(GRLAYERS_FORM,
                                   &ly_form_ptr, &fm_ind, &msg1),
                             senderid = my_id,
                             targetid = my_id);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto fini;
            }

              /*
               * Set the text field for layer display field.
               */

            FIg_display(ly_form_ptr, DISPLAY_TEXT);
            FIg_display(ly_form_ptr, DISPLAY_TEXT_ROLL);

              /*
               * Set the eligibility flag and call parent's form_init.
               */

            me->eligibility_enabled = TRUE;
            status = om$send(msg = message COedtly.form_init(&msg),
                             targetid = my_id);
            if ( !(1&status) )
            {
                om$report_error(sts = status);
                goto fini;
            }

            break;



/************** This case is not implemented yet ********************

         case VW_VOL_DEF:

            status = om$send (msg = message COvwvol.init_form_v(),
                              targetid = my_id);
	
            if ( ! (status & 1) )
            {
#ifdef DEBUG
                printf ( "problem in init_form\n" );
                om$report_error ( sts = status );
#endif
            }
            break;
***********************************************************************/

         case FI_ACCEPT:
         case FI_CANCEL:

            status = om$send(msg = message CEO.erase_form_by_label(form_label,
                                                            1, &msg1),
                             senderid = my_id,
                             targetid = my_id);
            if (! (1&status) )
            {
                om$report_error(sts = status);
                goto fini;
            }
 
              /*
               * If the active layer changed, then update dpb again
               * so that the adp form will get updated.  dhm    10/24/91
               */

            gr$get_active_layer(buffer = (IGRchar *)&act_layer);

            if ( saved_act_layer != act_layer )
            {
                gr$put_active_layer(buffer = (IGRchar *)&act_layer);
            }

            if (gadget_label == FI_ACCEPT)
            {
                if (me->toggle_proj)
                {
                    exit_response = TERMINATE;

                    ex$putque( msg = &msg,
                               response = &exit_response );

                    ex$putque( msg = &msg,
                               response = &me->win_response,
                               byte =    &num_bytes,
                               buffer =  me->win_resp_data );

                    me->win_nbytes = num_bytes;

                    if (me->flags & IS_PERSP)
                       strcpy (command_key, "GRCPsPrTPl");
                    else
                       strcpy (command_key, "GRCPlPrTPs");

                    size = strlen( command_key ) + 1;
                    response = EX_CMD_KEY;

                    ex$putque( msg = &msg,
                               response = &response,
                               byte = &size,
                               buffer = command_key );

	        }

                status = om$send (msg = message COvwchar.proc_chgs(),
                                  targetid = my_id);
                if ( ! (status & 1) )
                {
#ifdef DEBUG
                    printf ( "problem in send to proc_chgs\n" );
                    om$report_error ( sts = status );
#endif
                }
            }

            break;


         default:
            break;

         } /* end switch on gadget_label */

         break;


/****************  Don't have this form in the system yet

    case VW_VOL_FORM:

	status = om$send (msg = message COvwvol.form_input(form_label,value),
                        targetid = my_id,
			mode = OM_e_wrt_message);
	if (!(status & 1))
	{
#ifdef DEBUG
		printf(" error on send to parent form_input");
#endif
	}

	if ((gadget_label == FI_ACCEPT) || (gadget_label == FI_CANCEL))
	{
	   toggle_list[0].label = VW_VOL_DEF;
           toggle_list[0].type = EXFI_STATE;
           toggle_list[0].value.state = FALSE;

    	   status = om$send (msg = message FIform.put_by_value (&msg, 1,
			toggle_list),
			targetid = me->forms[VIEW_FORM].oid);

	   if (!(status & 1))
	   {
#ifdef DEBUG
		printf(" error on send to FIform put_by_value\n");
#endif
	   }

	}

        break;
*************************************************/


    case GRLAYERS_FORM:
        switch (gadget_label)
        {
           case EXIT_SAVE:
               /* 
                * Save the on/off status of each layer.
                */

               var_list[0].var = LEVELS;
               var_list[0].var_ptr = (IGRchar *)me->elig_mask;
               var_list[0].num_bytes = sizeof(IGRlong) * 32;
               var_list[0].bytes_returned = &bytes_returned;
               var_list[1].var = END_PARAM;

               status = dp$inq_set_gragad(msg = &msg,
                                          inq0_set1 = 1,
                                          osnum = me->source_id.osnum,
                                          gragad_objid = me->source_id.objid,
                                          which_error = &which_error,
                                          var_list = var_list); 
               if (!(status & 1))
               {
                    om$report_error(sts = status);
                    goto fini;
               }

                  /* no break */

           default:
               status = om$send(msg = message COedtly.form_notification
                                    (form_label, gadget_label, value, form_ptr),
                                targetid = my_id,
                                mode = OM_e_wrt_message);
               if (!(status & 1))
               {
                   om$report_error(sts = status);
                   goto fini;
               }

           break;

        }  /* end switch on gadget_label */

    break;

  } /* close for switch on type of form */

fini:
  if (text)  om$dealloc(ptr = text);

  return(status);

}

end implementation COvwchar;
