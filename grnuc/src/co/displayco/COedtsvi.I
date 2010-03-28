class implementation COedtsv;



#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <FI.h>

#include "dpfile.h"
#include "OMmacros.h"
#include "COBmacros.h"
#include "dp.h"
#include "exmacros.h"

%safe
#include "DPchgname.h"
#include "DPsvinquire.h"
#include "DPgetsavvwid.h"
#include "DPtotnumvw.h"
%endsafe

#define  SAVE_VIEW_FORM       0
#define  SAVE_EXIT_BTN        1
#define  EXIT_BTN             4
#define  CVT_TO_WINDOW        5
#define  SAVVW_MESSAGE_FIELD  10
#define  SAVVW_NAME_DESCRIPT  12
#define  EDIT_DELETE_MODE     15




method form_init ( long * sts )
{
  int		  status = OM_S_SUCCESS;

  IGRint           i;
  IGRlong          total, msg, bytes_returned, which_error;
  GRobjid          mod_id;
  IGRchar          savvw_msg[100];
  struct var_list  var[3];
  struct GRid      *sv_objids = NULL;
  IGRint           sts2;

  *sts = OM_S_SUCCESS;

  /*
   * Initialization
   */

  ME.COedtsv->delete_flag = FALSE;

  /*
   * Get current module environment
   */

  status = ex$get_cur_mod(id = &mod_id, osnum = &ME.COedtsv->osnum);
  if (!(1&status))
  {
#ifdef DEBUG
    printf("\n in COedtsv ex$get_cur_mod failed \n");
    om$report_error(sts = status);
#endif
    *sts = status;
    goto fini;
  }

  /*
   * Find total number of saved views
   */

  status = dp$total_num_saved_vw(msg = &msg, osnum = &ME.COedtsv->osnum,
                                 total_num = &total);
  if ( msg == DPVWSNODEF )
  {
    total = 0;
  }
  else if (!(1&status))
  {
#ifdef DEBUG
    printf("\n in COedtsv dp$total_num_saved_vw failed \n");
    om$report_error(sts = status);
#endif
    *sts = status;
    goto fini;
  }

  /*
   * Initialize the num_list in instance data.
   */

  ME.COedtsv->num_list = total;

  /*
   * If there are any, then process them
   */

  if (total)
  {
    /*
     * Set the dimension of the save_vw array.
     */

    OM_SET_DIMENSION(ME.COedtsv->save_vw, total);

    /*
     * Get the saved views objids
     */

    sv_objids = (struct GRid *) om$malloc(size = ( total *
                                                   sizeof(struct GRid) ) );

    status = dp$get_saved_vw_id(msg = &msg, osnum = ME.COedtsv->osnum,
                                name = "*",
                                numberofids = &total,
                                found_GRids = sv_objids,
                                array_size = total, total_num = &total);
    if (!(1&status))
    {
#ifdef DEBUG
      printf("\n in COedtsv dp$get_saved_vw_id failed \n");
      om$report_error(sts = status);
#endif
      *sts = status;
      goto fini;
    }

    /*
     * Set the maximum number of rows to be the number of saved views.
     */

    FIfld_set_max_num_rows(ME.CEO->forms[0].form_ptr, SAVVW_NAME_DESCRIPT,
                           ME.COedtsv->num_list);

    /*
     * Get the name and description for each saved view and print it out to
     * the form
     */

    var[0].var = SAV_VW_NAME;
    var[0].num_bytes = sizeof(char) * DI_PATH_MAX;
    var[0].bytes_returned = &bytes_returned;

    var[1].var = DESCRIPT;
    var[1].num_bytes = sizeof(char) * DI_PATH_MAX;
    var[1].bytes_returned = &bytes_returned;

    var[2].var = END_PARAM;

    for (i = 0; i < ME.COedtsv->num_list; i++)
    {
      /*
       * Initialize the delete_flag to be FALSE
       */

      ME.COedtsv->save_vw[i].delete_flag = FALSE;

      /*
       * Save the objid and osnum for each saved view
       */

      ME.COedtsv->save_vw[i].oid.objid = sv_objids[i].objid;
      ME.COedtsv->save_vw[i].oid.osnum = sv_objids[i].osnum;

      /*
       * Inquire for the name and description of the saved view
       */

      var[0].var_ptr = ME.COedtsv->save_vw[i].name;
      var[1].var_ptr = ME.COedtsv->save_vw[i].descript;

      status = dp$inq_set_saved_view (msg = &msg,
                                   inq0_set1 = 0,
                                   osnum = ME.COedtsv->osnum,
                                   vw_objid = ME.COedtsv->save_vw[i].oid.objid,
                                   which_error = &which_error,
                                   var_list = var);
      if (!(1&status))
      {
#ifdef DEBUG
        printf("\n in COedtsv dp$inq_set_saved_view failed \n");
        om$report_error(sts = status);
#endif
        *sts = status;
        goto fini;
      }

      /*
       * Set the name field of the multicolumn field
       */

      FIfld_set_text(ME.CEO->forms[0].form_ptr, SAVVW_NAME_DESCRIPT,
                     i, 0, ME.COedtsv->save_vw[i].name, FALSE);

      /*
       * Set the description field of the multicolumn field
       */

      FIfld_set_text(ME.CEO->forms[0].form_ptr, SAVVW_NAME_DESCRIPT, i, 1,
                     ME.COedtsv->save_vw[i].descript, FALSE);

    }  /* end for loop */

  }  /* end if got saved views  */

  else
  {
    FIg_disable(ME.CEO->forms[0].form_ptr, SAVVW_NAME_DESCRIPT);

    FIg_disable(ME.CEO->forms[0].form_ptr, EDIT_DELETE_MODE);

    ex$message(msgnumb = GR_E_NoSavVwDfn, buff = savvw_msg);

    FIfld_set_text(ME.CEO->forms[0].form_ptr, SAVVW_MESSAGE_FIELD, 0, 0,
                   savvw_msg, FALSE);

  }

  /*
   * If the form isn't displayed, then display it here
   */

  if (! ME.CEO->forms[0].displayed)
  {
    status = om$send(msg = message CEO.display_form_by_label(SAVE_VIEW_FORM,
                                                             &sts2),
                     senderid = my_id,
                     targetid = my_id);

    *sts = sts2;

    if (! (1&status) )
    {
#ifdef DEBUG
      printf("in COedtsv CEO.display_form_by_label failed \n");
#endif
      *sts = status;
    }
  }


fini:
  if (sv_objids)  om$dealloc(ptr = sv_objids);

quit:
  return OM_S_SUCCESS;
}

method form_notification ( int form_label ; int gadget_label ; double value ; char * form_ptr )
{
  int		  status = OM_S_SUCCESS;

  IGRint   i, length, flag, pos, row, col, sts, toggle_state;
  IGRlong  bytes_returned, which_error, size, sts2;
  IGRchar  *text = NULL;
  IGRint   resp;
  struct EXlstcol  list;
  struct var_list  var[2];
  struct EX_button response_data;

  switch ( gadget_label )
  {
    case SAVVW_NAME_DESCRIPT:
      row = (IGRint) value;

      /*
       * See if the delete flag is on.
       */

      if (ME.COedtsv->delete_flag)
      {
        /*
         * See which rows were selected for deletion.
         * Delete the row.  Insert a blank row in the place of the deleted
         * row. This is to keep the indices of the save_vw array consistent
         * with the value coming into the form notication routine.
         */

        FIfld_get_active_row(form_ptr, SAVVW_NAME_DESCRIPT, &row, &pos);

        ME.COedtsv->save_vw[row].delete_flag = TRUE;
        FIfld_delete_rows(form_ptr, SAVVW_NAME_DESCRIPT, row, 1);
        FIfld_insert_blank_row(form_ptr, SAVVW_NAME_DESCRIPT, row);

      }
      else if (row >= 0)  /* row was editted */
      {
        FImcf_get_active_col(form_ptr, SAVVW_NAME_DESCRIPT, &col, &pos);

        if (col == 0)  /* save the name to be changed */
        {
          FIfld_get_text_length(form_ptr, SAVVW_NAME_DESCRIPT, row, 0,
                                &length);

          text = (IGRchar *) om$malloc(size = length * sizeof(IGRchar));

          FIfld_get_text(form_ptr, SAVVW_NAME_DESCRIPT, row, 0,
                         length, text, &flag, &pos);

          strcpy(ME.COedtsv->save_vw[row].name, text);

        }
        else if (col == 1)  /* save the description to be changed */
        {
          FIfld_get_text_length(form_ptr, SAVVW_NAME_DESCRIPT, row, 1,
                                &length);

          text = (IGRchar *) om$malloc(size = length * sizeof(IGRchar) );

          FIfld_get_text(form_ptr, SAVVW_NAME_DESCRIPT, row, 1,
                         length, text, &flag, &pos);

          strcpy(ME.COedtsv->save_vw[row].descript, text);
        }

      }
      else  /* error, must be in delete mode to select a row */
      {
        FIfld_set_text(form_ptr, SAVVW_MESSAGE_FIELD, 0, 0,
                       "Must be in delete mode to select a field", FALSE);
      }

      break;


    case EDIT_DELETE_MODE:
      /*
       * Be sure the message field is cleared.
       */

      FIfld_set_text(form_ptr, SAVVW_MESSAGE_FIELD, 0, 0, " ", FALSE);

      /*
       * If the toggle is set to delete mode, then set the flag and change
       * the mode of the field to be multi-select; else set flag and change
       * the mode of the field to be insert and reset the fields
       */

      toggle_state = (IGRint) value;

      if (toggle_state == 1)  /* delete mode */
      {
        ME.COedtsv->delete_flag = TRUE;

        FIfld_set_mode(form_ptr, SAVVW_NAME_DESCRIPT, 0, FI_MULTI_SELECT);
        FIfld_set_mode(form_ptr, SAVVW_NAME_DESCRIPT, 1, FI_MULTI_SELECT);
        FIg_display(form_ptr, SAVVW_NAME_DESCRIPT);

      }
      else if (toggle_state == 0)  /* edit mode */
      {
        ME.COedtsv->delete_flag = FALSE;

        FIfld_set_mode(form_ptr, SAVVW_NAME_DESCRIPT, 0, FI_INSERT);
        FIfld_set_mode(form_ptr, SAVVW_NAME_DESCRIPT, 1, FI_INSERT);
        FIg_display(form_ptr, SAVVW_NAME_DESCRIPT);

      }  /* end else toggle == 0 */
 
      break;


    case CVT_TO_WINDOW:
      /*
       * Convert the save/restore form to a permanant form.
       */

      FIf_cvrt_to_perm_win(form_ptr);
      break;


    case SAVE_EXIT_BTN:
      /*
       * If there were some saved views, then make necessary changes here.
       */

      if (ME.COedtsv->num_list)
      {
        var[0].var = DESCRIPT;
        var[0].num_bytes = sizeof(char) * DI_PATH_MAX;
        var[0].bytes_returned = &bytes_returned;
        var[1].var = END_PARAM;

        for (i = 0; i < ME.COedtsv->num_list; i++)
        {
          /*
           * Change the name and description on all the saved views to what
           * the user keyed in or delete the saved view if flagged.
           */

          if (ME.COedtsv->save_vw[i].delete_flag)
          {
            status = om$send(msg = message Root.delete(1),
                             senderid = my_id,
                             targetid = ME.COedtsv->save_vw[i].oid.objid,
                             targetos = ME.COedtsv->save_vw[i].oid.osnum);
            if (! (1&status) )
            {
#ifdef DEBUG
              printf("in COedtsv IGEsavedvw.delete failed \n");
              om$report_error(sts = status);
#endif
              ME.CEO->ret = status;
              goto fini;
            }

          }
          else  /* Save the changes made to name and description */
          {
            list.oid = ME.COedtsv->save_vw[i].oid.objid;
            strcpy(list.string, ME.COedtsv->save_vw[i].name);

            status = dp$chg_vw_names(msg = &ME.CEO->ret,
                                     osnum = ME.COedtsv->osnum,
                                     chg_list = &list, num_in_list = 1,
                                     type = GRDP_SAVEDVIEWS);
            if (!(1&status))
            {
#ifdef DEBUG
              printf("\n in COedtsv dp$chg_vw_names failed \n");
              om$report_error(sts = status);
#endif
              ME.CEO->ret = status;
              goto fini;
            }

            var[0].var_ptr = ME.COedtsv->save_vw[i].descript;

            status = dp$inq_set_saved_view(msg = &ME.CEO->ret,
                                   inq0_set1 = 1,
                                   osnum = ME.COedtsv->osnum,
                                   vw_objid = ME.COedtsv->save_vw[i].oid.objid,
                                   which_error = &which_error,
                                   var_list = var);
            if (!(1&status))
            {
#ifdef DEBUG
              printf("\n in COedtsv dp$inq_set_saved_view failed \n");
              om$report_error(sts = status);
#endif
              ME.CEO->ret = status;
              goto fini;
            }

          }  /* end else */

        }  /* end for loop */

      }  /* end if num_list */

      /* no break here; so can do the exit and return to COB */


    case EXIT_BTN:
      /*
       * Erase the form
       */

      status = om$send(msg = message CEO.erase_form_by_label(form_label, 1,
                                                             &sts),
                       senderid = my_id,
                       targetid = my_id);
      if (! (1&status) )
      {
#ifdef DEBUG
        printf("in COedtsv CEO.erase_form_by_label failed \n");
        om$report_error(sts = status);
#endif
        ME.CEO->ret = status;
        goto fini;
      }

/*      FIg_set_state_off (ME.CEO->forms[0].form_ptr, EXIT_BTN);*/
/*      FIg_set_state_off (ME.CEO->forms[0].form_ptr, SAVE_EXIT_BTN);*/
      FIg_set_state_off (ME.CEO->forms[0].form_ptr, EDIT_DELETE_MODE);

      resp = EX_FORM_FINISHED;
      size = sizeof(struct EX_button);
      sts2 = sts;
      ex$putque(msg = &sts2, response = &resp, byte = &size,
                buffer = (IGRchar *)&response_data);

      break;


    default:
      status = om$send(msg = message CEO.erase_form_by_label(form_label, 1,
                                                             &sts),
                       senderid = my_id,
                       targetid = my_id);
      if (! (1&status) )
      {
#ifdef DEBUG
        printf("in COedtsv CEO.erase_form_by_label failed \n");
        om$report_error(sts = status);
#endif
        ME.CEO->ret = status;
      }

      break;


  }  /* end switch for gadget_label  */


fini:
  if (text)  om$dealloc(ptr = text);


quit:
  return OM_S_SUCCESS;
}

end implementation COedtsv;
