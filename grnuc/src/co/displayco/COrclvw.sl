/* Command definition section */

options         "t"
product_name    "$GRNUC"
spec_path       "$GRNUC/spec"
class           COrclvw
super_class     COwindow
start_state     terminate


specification

#include "limits.h"
#include "dpfile.h"
#include "DPedtsv.h"

instance
{
   IGRint                   num_list;
   GRspacenum               osnum;
   variable struct sv_info  save_vw[];
   struct GRid              sv_grid;
   IGRint                   switch1;
}


implementation

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

#define  DEBUG                1

#define  CONTINUE_PROCESSING  0
#define  FORM_EXIT            1


action form_init
{
   IGRint           i;
   IGRlong          total, msg, bytes_returned, which_error;
   GRobjid          mod_id;
   IGRchar          savvw_msg[100];
   struct var_list  var[3];
   struct GRid      *sv_objids = NULL;
   IGRint           sts2;


   *sts = OM_S_SUCCESS;

   /*
    * Get current module environment
    */

   status = ex$get_cur_mod(id = &mod_id, osnum = &me->osnum);
   if (!(1&status))
   {
#ifdef DEBUG
      printf("\n in COrclvw ex$get_cur_mod failed \n");
      om$report_error(sts = status);
#endif
      *sts = status;
      goto fini;
   }

   /*
    * Find total number of saved views
    */

   status = dp$total_num_saved_vw(msg       = &msg, 
                                  osnum     = &me->osnum,
                                  total_num = &total);
   if ( msg == DPVWSNODEF )
   {
      total = 0;
   }
   else if (!(1&status))
   {
#ifdef DEBUG
      printf("\n in COrclvw dp$total_num_saved_vw failed \n");
      om$report_error(sts = status);
#endif
      *sts = status;
      goto fini;
   }

   /*
    * Initialize the num_list in instance data.
    */

   me->num_list = total;

   /*
    * If there are any, then process them
    */

   if (total)
   {
      /*
       * Set the dimension of the save_vw array.
       */

      OM_SET_DIMENSION(me->save_vw, total);

      /*
       * Get the saved views objids
       */

      sv_objids = (struct GRid *) om$malloc(size = ( total *
                                                   sizeof(struct GRid) ) );

      status = dp$get_saved_vw_id(msg         = &msg, 
                                  osnum       = me->osnum,
                                  name        = "*",
                                  numberofids = &total,
                                  found_GRids = sv_objids,
                                  array_size  = total, 
                                  total_num   = &total);
      if (!(1&status))
      {
#ifdef DEBUG
         printf("\n in COrclvw dp$get_saved_vw_id failed \n");
         om$report_error(sts = status);
#endif
         *sts = status;
         goto fini;
      }

      /*
       * Set the maximum number of rows to be the number of saved views.
       */

      FIfld_set_max_num_rows( me->forms[0].form_ptr, 
                              SAVVW_NAME_DESCRIPT,
                              me->num_list);

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

      for (i = 0; i < me->num_list; i++)
      {
         /*
          * Save the objid and osnum for each saved view
          */

         me->save_vw[i].oid.objid = sv_objids[i].objid;
         me->save_vw[i].oid.osnum = sv_objids[i].osnum;

         /*
          * Inquire for the name and description of the saved view
          */

         var[0].var_ptr = me->save_vw[i].name;
         var[1].var_ptr = me->save_vw[i].descript;

         status = dp$inq_set_saved_view (msg         = &msg,
                                         inq0_set1   = 0,
                                         osnum       = me->osnum,
                                         vw_objid    = me->save_vw[i].oid.objid,
                                         which_error = &which_error,
                                         var_list    = var);
         if (!(1&status))
         {
#ifdef DEBUG
            printf("\n in COrclvw dp$inq_set_saved_view failed \n");
            om$report_error(sts = status);
#endif
            *sts = status;
            goto fini;
         }

         /*
          * Set the name field of the multicolumn field
          */

         FIfld_set_text( me->forms[0].form_ptr, 
                         SAVVW_NAME_DESCRIPT,
                         i, 
                         0, 
                         me->save_vw[i].name, 
                         FALSE);

         /*
          * Set the description field of the multicolumn field
          */

         FIfld_set_text(me->forms[0].form_ptr, 
                        SAVVW_NAME_DESCRIPT, 
                        i, 
                        1,
                        me->save_vw[i].descript, 
                        FALSE);

      }  /* end for loop */

      FIfld_set_mode(me->forms[0].form_ptr, 
                     SAVVW_NAME_DESCRIPT, 
                     0, 
                     FI_SINGLE_SELECT);

      FIfld_set_mode(me->forms[0].form_ptr, 
                     SAVVW_NAME_DESCRIPT, 
                     1, 
                     FI_SINGLE_SELECT);
   }  /* end if got saved views  */
   else
   {
      FIg_disable(ME.CEO->forms[0].form_ptr, SAVVW_NAME_DESCRIPT);

      ex$message(msgnumb = GR_E_NoSavVwDfn, buff = savvw_msg);

      FIfld_set_text(me->forms[0].form_ptr, 
                     SAVVW_MESSAGE_FIELD, 
                     0, 
                     0,
                     savvw_msg, FALSE);

   }

   /*
    * If the form isn't displayed, then display it here
    */

   if (! me->forms[0].displayed)
   {
      status = om$send(msg = message CEO.display_form_by_label(SAVE_VIEW_FORM,
                                                                &sts2),
                       senderid = my_id,
                       targetid = my_id);

      *sts = sts2;

      if (! (1&status) )
      {
#ifdef DEBUG
         printf("in COrclvw CEO.display_form_by_label failed \n");
#endif
         *sts = status;
      }
   }

fini:
   if (sv_objids)  om$dealloc(ptr = sv_objids);

}

/*******************************************************/

action form_notification

{
   IGRint           row, pos;
   IGRchar          *text = NULL;
   IGRint           sts2;
   IGRlong          sts;


   switch ( gadget_label )
   {
      case SAVVW_NAME_DESCRIPT:
         row = (IGRint) value;

         if (row >= 0)  /* row was selected */
         {
            /* 
             * Use num_views to save the view to recall
             */
            FIfld_get_active_row(form_ptr, SAVVW_NAME_DESCRIPT, &row, &pos);
            me->num_list = row;
         }
         else  /* error, no valid row selected */
         {
            FIfld_set_text(form_ptr, SAVVW_MESSAGE_FIELD, 0, 0,
                           "Error, invalid selection", FALSE);
         }

         break;

      case CVT_TO_WINDOW:
         /*
          * Convert the save/restore form to a permanant form.
          */

         FIf_cvrt_to_perm_win(form_ptr);
         break;


      case SAVE_EXIT_BTN:
         if (me->num_list >= 0)
         {
            status = om$send( targetid = my_id,
                              msg      = message COrclvw.erase_form(&sts));
              
            if( status != OM_S_SUCCESS)
            {
               goto fini;
            }
            me->switch1 = CONTINUE_PROCESSING;
         }
         else
         {
            FIfld_set_text(form_ptr, SAVVW_MESSAGE_FIELD, 0, 0,
                           "Error, no view selected", FALSE);
         }
         break;

      case EXIT_BTN:
         /*
          * Erase the form
          */
         status = om$send( targetid = my_id,
                           msg      = message COrclvw.erase_form(&sts));

         if( status != OM_S_SUCCESS)
         {
            goto fini;
         }

         me->switch1 = FORM_EXIT;
         break;

      default:
         status = om$send(msg = message CEO.erase_form_by_label(form_label, 1,
                                                                &sts2),
                          senderid = my_id,
                          targetid = my_id);

         if (! (1&status) )
         {
#ifdef DEBUG
            printf("in COrclvw CEO.erase_form_by_label failed \n");
            om$report_error(sts = status);
#endif
            ME.CEO->ret = status;
         }

         break;

   }  /* end switch for gadget_label  */

   fini:
      if (text)  om$dealloc(ptr = text);

}  /* end action form_notification */

/*********************************************************/
 
action idn_wnd
{
   IGRlong     msg;
   IGRint      i;
   GRspacenum  osnum;
   GRobjid     objid;
   IGRlong     num_ids;
   IGRlong     totalnum;


   msg = MSSUCC;
   *sts = OM_S_SUCCESS;

   if ( me->num_list >= 0 )
   {
      /* get current object space number */
      status = ex$get_cur_mod( id = &objid, osnum = &osnum);

      /* need to gett the id of the view to recall */
      status = dp$get_saved_vw_id( msg         = &msg,
                                   osnum       = osnum,
                                   name        = me->save_vw[me->num_list].name,
                                   numberofids = &num_ids,
                                   total_num   = &totalnum,
                                   array_size  = 1,
                                   found_GRids = &me->sv_grid);

      /* 
         if the number of names returned is not equal to one, output error 
         message and quit
      */

      if( totalnum != 1)
      {
         EX_bell();
         if( totalnum < 1)
         {
            ex$message( msgnumb = GR_E_NoSavVwDfn);
         }
         else if (totalnum > 1)
         {
            ex$message( msgnumb = GR_E_AmbNme );
         }

         *sts = SrchFlt;
         goto quit;
      }

      savedvw_recall ( &msg, 
                       DP_UPDATE,
                       me->num_id,
                       me->ggid,
                       &me->sv_grid);
   }
   else
   {
      ex$message ( msgnumb = GR_E_WinNotFnd);

      *sts = SrchFlt; 
      goto quit;
   }		
}

/****************************************/

action erase_form
{
   IGRint           resp;
   struct EX_button response_data;
   IGRlong          size, sts2;
   IGRint           sts3;


   *sts = OM_S_SUCCESS;

   status = om$send(msg = message CEO.erase_form_by_label(SAVE_VIEW_FORM , 
                                                          1,
                                                          &sts3),
                    senderid = my_id,
                    targetid = my_id);

   if (! (1&status) )
   {
#ifdef DEBUG
      printf("in COrclvw CEO.erase_form_by_label failed \n");
      om$report_error(sts = status);
#endif
      ME.CEO->ret = status;
      *sts = 2;
   }

   resp = EX_FORM_FINISHED;
   size = sizeof(struct EX_button);
   sts2 = *sts;
   ex$putque(msg      = &sts2, 
             response = &resp, 
             byte     = &size,
             buffer   = (IGRchar *)&response_data);

   *sts = OM_S_SUCCESS;

}

/************************************/

action	get_state

{
   *sts = (IGRlong)me->switch1;
}

