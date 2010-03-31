class implementation RFcreref;

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
#include "msmacros.h"
#include "EMSasmacros.h"
#include "ECcmd.h"
#include "ECmsg.h"
#include "grmsg.h"
#include "actparam.h"

#include "PWminimum.h"
#include "PWerror.h"

#define ASM_INVALID_SEEDFILE 2

#define GET_FILENAME 1
#define LOCATE_REFERENCE_PLANE 2
#define CREATE_REFERENCE 3

#define DATUM 1
#define SURFACE 2

#define MAX_STRING 2048

extern OMuword OPP_EMSdatpln_class_id;

from GRvg  import GRgetsize, GRgetgeom;
from GRgraphics import GRconstruct,GRdisplay,GRdelete;
from GRreffile import GRgetenvironment,GRgetosnum,GRchgcolor;
from IGEgragad  import	DPinrot;
from EMSdatpln import EMget_pln_info,GRptproject;
from EMSsubbs import EMtangent_normal;

method wakeup( int pos )
{
   me->rf_action = GET_FILENAME;
   ex$message(field = MESSAGE_FIELD,
              msgnumb = EM_M_CreRefFile);
   return (OM_S_SUCCESS);
 
}

method execute(int *response; char *response_data; int pos)
{
    IGRlong  status,rc;
    struct GRevent rfevent;
    IGRint nbytes = sizeof(struct GRevent);
    IGRboolean aflag;
    PWosnum osn;
    PWobjid rfheader; 
    PWresult PWsts;
    struct IGRdisplay rfdisp;

    while(me->rf_action != FALSE) 
    {
       switch(me->rf_action)
       {
           case GET_FILENAME:

           status = co$getevent( msg = &rc,
                                 prompt = "Enter Filename",
                                 event_mask = GRm_STRING|GRm_BACK_UP,
                                 mode = EX_LINE_MODE,
                                 nbytes = &nbytes,
                                 response = response,
                                 response_data = response_data,
                                 event = &rfevent);

           if (rfevent.response == EX_STRING)
           {
               if (strlen(rfevent.event.keyin) == 0)
               {
                  ex$message(field = ERROR_FIELD,
                             msgnumb = EMS_E_NoFileSpecified,
                             time = 2);

                  ex$message(field = ERROR_FIELD,
                             msgnumb = EMS_I_ClearStatusField);

                  me->rf_action = GET_FILENAME;
                  break;
               }
               strcpy(me->filename, rfevent.event.keyin);

               /** Intentional block to set scope for the variables **/
               {
                  char curr_file[2048];
                  char cur_file_name[2048];
                  char *tmpptr;

                  om$os_number_to_name ( osnum = EX_active_OS_num,
                                         osname = cur_file_name);

                  tmpptr = strrchr(cur_file_name,'/');
                  if(tmpptr != NULL)
                  {
                    tmpptr++;
                    strcpy(curr_file, tmpptr);
                  }
                  if (!strcmp(curr_file,me->filename) || 
                     (access(me->filename, 0) == 0))
                  {
                    ex$message(field = ERROR_FIELD,
                               msgnumb = GR_E_FileExists,
                               time = 2);
                    ex$message(field = ERROR_FIELD,
                               msgnumb = EMS_I_ClearStatusField); 

                    me->rf_action = GET_FILENAME;
                    break;
                  } 
               }
               me->rf_action = CREATE_REFERENCE;
           }
           else
             if (*response == CLEAR_STACK || 
                 *response == TERMINATE ||
                 rfevent.response == EX_BACK_UP)
             {
                 me->rf_action = FALSE;
                 goto wrap_up;
             }
             else
               if (*response == EX_CMD_KEY)
               {
                  return(OM_S_SUCCESS);
               }

           break;

           case CREATE_REFERENCE:

           /*
            * This is to make sure there is no active OS before creating
            * b'coz the flow is to be thru' the old code 
            */

           aflag = pwIsActivationOn();
           if (aflag)
           {
               GRspacenum osn;

               /** Get the active OS **/
               osn = pwGetActiveOs();

               /** Change 'save' button to normal color **/
               rfDisplaySaveBtn(FALSE);

               /** Change the cursor to normal **/
               rfRestoreCursor();

               /** Reset all global variables **/
               PWsts = pwDeactivateOS();
           }

           ex$message(field = ERROR_FIELD,
                      msgnumb = GR_I_Processing);

           /*
            * Get the master GRdpb and post it into the new one after
            * the file has been created and attached
            */
           gr$get_active_display(buffer = &rfdisp);

           PWsts = pwCreateReferenceFile(me->filename,
                                          &rfheader,
                                          &osn);

            if (PWsts != PW_K_Success)
            {
              /** Error check and recovery here **/
              ex$message(field = ERROR_FIELD,
                         msgnumb = GR_E_ErrFlAtch,
                         time = 2);
            }
            else
            {
               struct GRid tmp;
 
               tmp.objid = rfheader;
               tmp.osnum = OM_Gw_current_OS;

               ex$message(field = ERROR_FIELD,
                          msgnumb = GR_I_ProcCmplt,
                          time = 2);
               ex$message(field = ERROR_FIELD,
                          msgnumb = EMS_I_ClearStatusField);

               /** Update RFA parameters **/
               UpdateActParams(tmp);

               /** Activate the Save buton **/
               rfDisplaySaveBtn(TRUE);

               /** Activate the cursor **/
               rfDefineCursor();

               /** Update the GRdpb **/
               gr$put_active_display(buffer = &rfdisp);
            }

           *response = TERMINATE;
           me->rf_action = FALSE;
           break;

           default:
           break;
        }
    }; 

wrap_up:
    return(1);
}

end implementation RFcreref;

