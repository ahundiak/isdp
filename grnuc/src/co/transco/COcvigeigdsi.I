/*
Name
        COigeigds - Convert EMS object space to IGDS

Description
        This command object allows the user to convert the active object space
        to IGDS.

History
        Created in the hoary early days.  Culprits probably include gfs, sjb,
        kmo, mas, rej, and others who won't admit it.

        mrm     02/13/92    added logic regarding drawing view conversion,
                            changed GRgetevent to co$getevent
        dhm     10/01/92    incorporated fix for 11921613 from RCS revision
                            201.3.
*/

class implementation COcvigeigds;

#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "godef.h"
#include "igrdp.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "ex.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "lcdef.h"
#include "grdpbmacros.h"
#include "msmacros.h"
#include "grmessage.h"
#include "exdef.h"

#define NUMBER_STATES	7
#define NUMBER_TOKENS	5

extern void GUinit_map();
extern void GUigemapigds();
extern OMuword OPP_GRdrawview_class_id;

enum states {	GET_FILE_NAME, 
                GET_USER_CONFIRM,
		GET_VIEW_SELECTION, 
		GET_SEED_FILE_NAME, 
		GET_MAP_FILE_NAME,
		GET_CONVERSION_WINDOW,
                PROCESS_FILE	   };
		

/*
  window to be referenced during conversion of drawing view objects
*/
%safe
static struct GRid GRconversion_window = {0, 0};
%endsafe

/*---------------------------------------------------------------------------*/
/*                     COcvigeigds init method                               */
/*---------------------------------------------------------------------------*/

method init(int type; char *string_ptr)
{
    me->select_view_num = 0;
    me->state = GET_FILE_NAME;
    gr$get_module_env(buffer = &ME.COroot->ModuleInfo);
    gr$get_database_type(buffer = ME.COconst->DatabaseType);
    GRconversion_window.objid = NULL_OBJID;
    return(OM_S_SUCCESS);
}


/*---------------------------------------------------------------------------*/
/*                      COcvigeigds wakeup method                            */
/*---------------------------------------------------------------------------*/

method wakeup(int pos)
{
    ex$message(msgnumb = GRC_M_CnvtoIGDS);
    return(OM_S_SUCCESS);
}


/*---------------------------------------------------------------------------*/
/*                      COcvigeigds execute method                           */
/*---------------------------------------------------------------------------*/


method execute(int *response; char *response_data; int pos)
{
    IGRchar		seed_file_name[128], map_file_name[128];
    IGRboolean		map_set;
    IGRboolean		exit;
    IGRint		IGDS_seed_file;
    IGRint              IGDS_file;
    IGRlong             sts = 0;        /* return status           	*/
    IGRlong             msg;      	/* msg returned from methods	*/ 
    IGRdouble		trans_limits[6];
    struct GRevent	event;   	/* event returned from getevent	*/

    /*
     *  Set up limits of translation.
     */

    trans_limits[0] = GRDGNLIMITS_MIN_D;
    trans_limits[1] = GRDGNLIMITS_MIN_D;
    trans_limits[2] = GRDGNLIMITS_MIN_D;
    trans_limits[3] = GRDGNLIMITS_MAX_D;
    trans_limits[4] = GRDGNLIMITS_MAX_D;
    trans_limits[5] = GRDGNLIMITS_MAX_D;

    map_set = FALSE;
    exit = FALSE;

    while (!exit)
    {
   	switch (me->state)
	{
          case GET_FILE_NAME:

            co$getevent(msg = &msg,
                        event_mask = GRm_TEXT_VALUE,
                        msgnum = GR_P_EntNmeIGDSflCrt,
                        response = response,
                        response_data = response_data,
                        event = &event);

            if (event.response == STRING)
            {
                strcpy(me->file_name, event.event.keyin);

                /*
                 * If the file exists, confirm overwriting the file or not.
                 */

                IGDS_file = open(me->file_name, GUWRITE_ONLY);

                if (IGDS_file != -1)  /* file exists */
                {
                  close(IGDS_file);
                  me->state = GET_USER_CONFIRM;
                }
                else
                {
                  /*
                   *  Set flags.
                   */

                  sts = TRUE;
                  me->state = GET_VIEW_SELECTION;
                }
            }
            else
            {
                exit = TRUE;
            }
            break;
	
          case GET_USER_CONFIRM:

            co$getevent(msg = &msg,
                        event_mask = GRm_TEXT_VALUE,
                        msgnum = GR_P_FlExOv,
                        response = response,
                        response_data = response_data,
                        event = &event);

            if (event.response == STRING)
            {
              if ( !(strcmp(event.event.keyin, "y")) ||
                   !(strcmp(event.event.keyin, "Y")) )
              {
                sts = TRUE;
                me->state = GET_VIEW_SELECTION;
              }
              else if ( !(strcmp(event.event.keyin, "n")) ||
                        !(strcmp(event.event.keyin, "N")) )
              {
                me->state = GET_FILE_NAME;
              }

            }
            else
            {
              exit = TRUE;
            }
            break;

          case GET_VIEW_SELECTION:
	
            /*
             *  Get the view setup for the IGDS file from
             *  the user.
             */

            me->view_setup[me->select_view_num].objid = NULL;

            ex$message(msgnumb = GR_P_SelWinIGDSVw,
                       type = "%d",
                       var = me->select_view_num + 1);

            co$getevent(msg = &msg,
                        event_mask = GRm_DATA | GRm_RESET,
                        response = response,
                        response_data = response_data,
                        event = &event);

            if (event.response == DATA || event.response == RESET)
            {
                if (event.response == DATA)
                {
                    me->view_setup[me->select_view_num].osnum = 
                        event.event.button.osnum;
                    me->view_setup[me->select_view_num].objid =
                        event.event.button.objid;
                }
                me->select_view_num++;
                if (me->select_view_num >= 8)
                {
                    me->state = GET_SEED_FILE_NAME;
                }
            }
            else
            {
                exit = TRUE;
            }
            break;

          case GET_SEED_FILE_NAME:
	
            co$getevent(msg = &msg,
                        event_mask = GRm_TEXT_VALUE | GRm_RESET | GRm_BACK_UP,
                        msgnum = GR_P_EntIGDSSdflNme,
                        response = response,
                        response_data = response_data,
                        event = &event);

            if (event.response == EX_BACK_UP)
            {
                me->state = GET_MAP_FILE_NAME;
            }
            else if (event.response == STRING)
            {
                if (event.event.keyin[0])
                {
                    /* Test to see if the file exists */
                    IGDS_seed_file = open(event.event.keyin, GUREAD_ONLY);
                    if (IGDS_seed_file == -1)
                    {
                        ex$message(msgnumb = GR_E_CantOpnIGDSSdfl);
                        me->state = GET_SEED_FILE_NAME;
                    }
                    else
                    { 
                        close(IGDS_seed_file);
                        strcpy(seed_file_name, event.event.keyin);
                        me->state = GET_CONVERSION_WINDOW;
                    }
                }
                else
                {
                    seed_file_name[0] = NULL;
                    me->state = GET_CONVERSION_WINDOW;
                }
            }
            else if (event.response == RESET)
            {
                seed_file_name[0] = NULL;
                me->state = GET_CONVERSION_WINDOW;
            }
            else
            {
                exit = TRUE;
            }

            break;	 

          case GET_MAP_FILE_NAME:
	
            co$getevent(msg = &msg,
                        event_mask = GRm_TEXT_VALUE | GRm_RESET,
                        msgnum = GR_P_EntMapflNme,
                        response = response,
                        response_data = response_data,
                        event = &event);

            if (event.response == STRING)
            {
                strcpy(map_file_name, event.event.keyin);
                GUinit_map(&msg, map_file_name);
                if (msg == GUMAPNOTFOUND)
                {
                    ex$message(msgnumb = GR_E_CantOpnMapfl);
                    me->state = GET_MAP_FILE_NAME;
                }
                else
                {
                    map_set = TRUE;
                    me->state = GET_SEED_FILE_NAME;
                }
            }
            else if (event.response == RESET)
            {
                map_file_name[0] = NULL;
                GUinit_map(&msg, map_file_name);
                map_set = TRUE;
                me->state = GET_SEED_FILE_NAME;
            }
            else
            {
                exit = TRUE;
            }

            break;	 

          case GET_CONVERSION_WINDOW:
            /*
                Check whether there are any drawing views (or subclasses) in
                the master object space.  Ed calls this cheating; I prefer to
                call it an efficient shortcut.
            */
            if (OM_GA_OSDs[ME.COroot->ModuleInfo.md_id.osnum]->
                OSCO_list[OPP_GRdrawview_class_id])
            {
                /*
                    Now check on how many windows are active; there's no need
                    to prompt if there is only one.

                */
                IGRint i, j;

                sts = dp$get_gragad_id (msg = &msg,
                                        mod_GRid = &ME.COroot->ModuleInfo,
                                        name = "*",
                                        array_size = 1,
                                        total_num = &i,
                                        numberofids = &j,
                                        found_GRids = &GRconversion_window,
                                        type_gragad = IGE_GG | ACTIVE_GG);

                if ((sts & msg & 1) && (i == 1))
                {
                    me->state = PROCESS_FILE;
                }
                else
                {
                    /* prompt the user to identify a window */

                    co$getevent(msg = &msg,
                                event_mask = GRm_DATA | GRm_TEXT_VALUE |
                                             GRm_RESET | GRm_BACK_UP,
                                msgnum = GR_P_IdRefWinForDrawConv,
                                response = response,
                                response_data = response_data,
                                event = &event);

                    if (event.response == EX_DATA)
                    {
                        GRconversion_window.objid = event.event.button.objid;
                        GRconversion_window.osnum = event.event.button.osnum;
                        me->state = PROCESS_FILE;
                    }
                    else if (event.response == EX_STRING)
                    {
                        i = 0;
                        dp$get_gragad_id(msg = &msg,
                                         name = event.event.keyin,
                                         array_size = 1,
                                         numberofids = &i,
                                         found_GRids = &GRconversion_window);

                        if (i)
                            me->state = PROCESS_FILE;
                        else
                            ex$message(msgnumb = GR_E_WinNotFound);
                    }
                }
            }
            else
            {
                me->state = PROCESS_FILE;
            }
            break;

          case PROCESS_FILE:
	
            ex$message (msgnumb = GR_I_CnvProg);

            if (!map_set)       /* See if layer-to-level mapping */
            {                   /* has been set up yet. If not,do*/
                map_file_name[0] = NULL;
                GUinit_map(&msg, map_file_name);
            }

            sts = GUcreate_IGDSfile(&msg, me->file_name, 
                                    ME.COconst->DatabaseType,
                                    &(ME.COroot->ModuleInfo), &my_id,
                                    seed_file_name, me->view_setup,
                                    trans_limits);

            GRconversion_window.objid = NULL_OBJID;

            if (!(sts & 1))
            {
                if(msg == GUNOSEEDFILE)
                {
                    ex$message (msgnumb = GR_E_CantOpnIGDSSdfl);
                    me->state = GET_SEED_FILE_NAME;
                }
                else if (msg == GUNOFILE)
                {
                    ex$message (msgnumb = GR_E_IGDSflNoCrt);
                    me->state = GET_FILE_NAME;
                }
                else if (msg == GUELEMENT_OVERFLOW)
                {
                    ex$message (msgnumb = GR_E_IntOvfOccEleSkp);
                    exit = TRUE;
                    *response = TERMINATE;
                }
                else if (msg == GUVIEW_OVERFLOW)
                {
                    ex$message (msgnumb = GR_E_IntOvfOccVwSkp);
                    exit = TRUE;
                    *response = TERMINATE;
                }

                goto wrap_up;
            }
            else
            {
                ex$message (msgnumb = GR_I_CnvCmpl);
                exit = TRUE;
                *response = TERMINATE;
            }
            break;
	}                       /* end switch */
    } /*  end while  */

  wrap_up:
    return(OM_S_SUCCESS);

}               /* end execute method */

/*---------------------------------------------------------------------------*/
/*                      COcvigeigds sleep method                             */
/*---------------------------------------------------------------------------*/

method sleep(int pos)
{
    return(OM_S_SUCCESS);
}

/*
Name
        GRget_conversion_window

Description
        This function will store the window to be referenced when converting
        drawing view contents (reference file objects).  The information
        should eventually be added to the GRformatele argument list.

History
        mrm     02/13/92    creation
*/

IGRint GRget_conversion_window(win)
struct GRid *win;
{
    if ((GRconversion_window.objid == NULL_OBJID) ||
        (GRconversion_window.objid == 0))
        return(FALSE);
    else
    {
        *win = GRconversion_window;
        return(TRUE);
    }
}

end implementation COcvigeigds;
