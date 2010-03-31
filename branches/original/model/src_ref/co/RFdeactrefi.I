class implementation RFdeactref;

#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdef.h"
#include "lcdef.h"
#include "lc.h"
#include "lcmacros.h"
#include "exmacros.h"
#include "madef.h"
#include "msdef.h"
#include "griomacros.h"
#include "refdef.h"
#include "ref.h"
#include "refmacros.h"
#include "referr.h"
#include "grerr.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "msdef.h"
#include "msmacros.h"
#include "ECcmd.h"
#include "actparam.h"
#include "execmsg.h"

#include "PWminimum.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include <grimport.h>
#include <DIprims.h>


/** Friend classes **/
from GRgraphics import GRdisplay;
from GRreffile import GRchgcolor, GRchgrfprops;

void rfResetReferenceFiles();

method execute(int *response; char *response_data; int pos)
{
   PWresult PWsts;
   IGRint status;
   IGRboolean aflag, go_on = FALSE;
   struct GRid rfhead;
   GRspacenum osn;
   unsigned short color;
   int entry_num, prompt_status;
   char osname[OM_K_MAXOSNAME_LEN];
   IGRchar pwd[DI_PATH_MAX];

   ex$message(field = MESSAGE_FIELD,
              msgnumb = EM_M_DeaAsmPart);

   aflag = pwIsActivationOn();
   if (aflag)
   {
      osn = pwGetActiveOs();
      pwGetActiveRefHeader(&rfhead);

      status = ex$is_invis ( mod_osnum = osn,index = &entry_num);
      if (status)
      {
         om$os_number_to_name (osnum = osn, osname = osname);
         do
         {
           prompt_status = ex$create_prompt(message_no = EX_P_Save,
                                            right_prompt =EX_P_No,
                                            left_prompt =EX_P_Yes,
                                            string = osname,
                                            response = response,
                                            response_data=response_data);
           if(*response == D_RESET || *response == RESET)
           {
              response_data[0] = '\0';
              *response = TERMINATE;
              goto wrap_up;
           }
           else if ( *response == STRING)
           {
             if (prompt_status == EX_LEFT_MATCH )
             {
               ex$save_module(index = entry_num);
               *response = TERMINATE;
               go_on = TRUE;
             }
             else
                 if (prompt_status == EX_RIGHT_MATCH)
                 {
                    GRspacenum osnum = EX_active_OS_num;
                    di$give_pathname ( osnum =  osnum,
                                       pathname = pwd);
                    strcat(pwd,":usr");
                    di$cd(dirname = pwd);
                    go_on = TRUE;
                    *response = TERMINATE;
                 }
                 else
                   if (*response == EX_CMD_KEY)
                   {
                      goto wrap_up;
                   }
           }
        }
        while(*response == RESET);
     }
     else
     {
       *response = TERMINATE;
       goto wrap_up;
     }

     if (go_on == TRUE)
     {
        rfResetReferenceFiles(rfhead);
     }
   }
   else
   {
      *response = TERMINATE;
      goto wrap_up;
   }

wrap_up:
 return(1);
}

void rfResetReferenceFiles(struct GRid rfhead)
{
   struct IGRdisplay rfdisp;
   IGRlong msg;
   IGRmatrix matrix;
   short mtx_type;
   struct GRid cur_mod;
   enum GRdpmode mode;
   struct GRid *ref_ids = NULL;
   char **ref_names = NULL;
   int num_ref,ii;
   IGRulong props = GROVERRIDE_SYMBOLOGY;
   IGRshort flag = 0;
   IGRint status;
   GRspacenum osn;

   status = ex$get_cur_mod(id = &cur_mod.objid,
                                osnum = &cur_mod.osnum );
   mtx_type = MAIDMX;
   MAidmx ( &msg, matrix );

   gr$review_ref_files(msg = &msg,
                       output_file = NULL,
                       ref_names = &ref_names,
                       ref_grids = &ref_ids,
                       num_found = &num_ref);

   for (ii=0;ii<num_ref;ii++)
   {
      if (ref_ids[ii].objid == rfhead.objid)
      {
         /** Change 'save' button to normal color **/
         rfDisplaySaveBtn(FALSE);

         /** Change the cursor to normal **/
         rfRestoreCursor();

         /** Reset all global variables **/
         pwDeactivateReferenceFile(ref_names[ii], &osn);

      }

      status = om$send(msg = message GRreffile.GRchgrfprops(&msg,
                                                           &flag,
                                                           &props),
                            senderid = NULL_OBJID,
                            targetid = ref_ids[ii].objid,
                            targetos = ref_ids[ii].osnum);

      mode = GRbd;
      om$send(msg = message GRgraphics.GRdisplay(&msg,&mtx_type,
                        matrix , &mode,
                        &cur_mod ),
              senderid = NULL_OBJID,
              targetid = ref_ids[ii].objid,
              targetos = ref_ids[ii].osnum);
    }

    /* Commented below- Let the datum plane of master be in its original state,
     * as it was before activation - bbkr TR#119700567  
     */
    /* This is deactivation. Reset the active datum plane too. 
    {
      struct GRid null_id;
      null_id.objid = NULL_OBJID;
      null_id.osnum = OM_Gw_current_OS;

      ActivateRefDatum(null_id);
    }
   */

    if (ref_ids) free(ref_ids);
    if (ref_names) 
    {
      for(ii=0;ii<num_ref;ii++)
      {
        if (ref_names[ii])
           free(ref_names[ii]);
      }
      free(ref_names);
    }

    /** Get the old sumbology and update the form **/
    gr$get_active_display(buffer = &rfdisp);
    gr$put_active_display(buffer = &rfdisp);
    gr$get_active_layer(buffer = &rfdisp);
    gr$put_active_layer(buffer = &rfdisp);
}

end implementation RFdeactref;
