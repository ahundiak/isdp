/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   COsdcreate

Description
   This method implements the create symbol definition command.
                

History
   mrm 05/14/86 : Creation Date
   HGW 07/03/86 : Finished coding and tested
   HGW 08/05/86 : Changed termonology
   mrm 10/01/86 : OM 4.0 conversion
   HGW 12/15/86 : Convert to graphics sets.
   HGW 12/15/87 : Changes for version 1.1
   SCW 07/07/92 : ANSI conversion
\*/

#define LOCATE            0
#define GET_NAME          1
#define GET_ORIGIN        2
#define RESTART           3

class implementation COsdcreate;

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "grgsmacros.h"
#include "exmacros.h"
#include "griomacros.h"
#include "grerr.h"
#include "codef.h"
#include "dpmacros.h"

from IGEgragad    import DPinrot;
from GRgraphics   import GRconstruct, GRdelete;

extern IGRint      GRcp_sd_to_asl();
extern IGRint      GRparse();

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
IGRboolean  exit;
IGRshort    matrix_type;
IGRlong     msg;
IGRlong     om_msg;
IGRlong     status;
IGRlong     size;
IGRint      i;
IGRint      count;
IGRint      one;
IGRint      error;
IGRpoint    origin;
IGRpoint    t_origin;
IGRmatrix   symbol_matrix;
struct      GRevent       locate_event;
struct      IGRsymboldef  geometry;
struct      GRid          sdh_id;
struct      GRid          located_id;
struct      GRmd_env      located_env;
OM_S_CHANSELECT           gs_chansel; /*remove when chan$addr is here*/

   /* 
    *  Check if the init method was successful.
    */

   if (me->init_success & 1)
   {
      exit = FALSE;
   }else 
   {
      if (me->init_success == 2)
      {
         ex$message(msgnumb = GR_F_NoActCelLibDfn);
      }else if (me->init_success == 4)
      {
         ex$message(msgnumb = GR_F_FlRdOnly);
      }else
      {
         ex$message(msgnumb = GR_E_ErrEncCmdTrm);
      }
      *response = TERMINATE;
      exit = TRUE;
   }

    /* set up channel selector */
    gs_chansel.type = OM_e_addr;
    gs_chansel.u_sel.addr = &me->to_gs_channel;
    error = FALSE;

    while (!exit)
    {
        switch (me->state)
        {
            case LOCATE:

                /*
                 *  call locate filter to locate an object &
                 *  add it to the save set
                 */

                status = gr$gslocate (msg = &msg,
                            event1 = &me->event,
                            event2 = &me->event,
                            locate_event = &locate_event,
                            mask1 = GRm_DATA | GRm_OBJID | GRm_RESTART | 
                                    GRm_RJT_MOVEON,
                            mask2 = GRm_DATA | GRm_OBJID | GRm_RESTART,
                            display_flag = ALL_WINDOWS | ELEM_HILIGHT |
                                           NO_PROJ_ACCEPT_POINT,
                            locate_key = GR_P_IdEleMvOn,
                            acc_key = GR_P_AccNxtEle,
                            relocate_key =  GR_E_EleNotFnd,
                            attributes = &me->attr,
                            stack = &me->locate_stack,
                            num_inputs = 1,
                            locate_state = &me->locate_state,
                            input1_mask = GRm_DATA | GRm_OBJID | 
                                          GRm_RESTART | GRm_RJT_MOVEON,
                            input1_key = GR_P_AccNxtMvOn,
                            p_chanselect = &gs_chansel);

                if ((!status))
                {
                    error = TRUE;
                    me->state = RESTART;
                }else if ( (msg & 1) &&
                          ( (me->event.response == EX_DATA)  ||
                            (me->event.response == EX_OBJID)))
                {
                    /*
                     *  Element was select by data button or
                     *  by string.
                     */

                    me->ele_located = TRUE;

                    /*
                     *  Erase the highlight plane
                     */

                    om_msg = dp$erase_hilite (msg = &msg,
                             objid = me->ModuleInfo.md_id.objid,
                             osnum = me->ModuleInfo.md_id.osnum);

                    if (COERROR (om_msg & msg))
                    {
                        me->state = RESTART;
                        error = TRUE;
                        break;
                    }

                    /*
                     *  Push accept event onto software queue to use 
                     *  as the next locate point.
                     */

                    size = sizeof(struct GRevent) - (sizeof(IGRlong) * 2);
                    om_msg = ex$putque ( msg = &msg, 
                                         response = response, 
                                         byte = &size, 
                                         buffer = (IGRchar *)&me->event.event );
                }
                else if (me->event.response == EX_RJT_MOVEON)
                {
                    /*
                     *  A MOVE_ON was entered, does the graphics sets
                     *  own any objects.
                     */
                  
                    om_msg = gr$gsinqcount ( msg = &msg, 
                             p_chanselect = &gs_chansel);

                    if (om_msg & msg & 1)
                    {
                        if (count)
                        {
                            /*
                             *  MOVE_ON to getting the name.
                             */

                            me->state = GET_NAME;
                            UI_status ("");
                        }else
                        {
                            /*
                             *  If no objects on saveset then
                             *  Restart the command.
                             */

                            ex$message(msgnumb = GR_E_CelEleNotDfn);
                            me->state = RESTART;
                        }
                    }else
                    {
                       me->state = RESTART;
                       error = TRUE;
                    }
                }
                else if (me->event.response == EX_RESTART)
                {
                   me->state = RESTART; /* restart the command */
                }
                else if (me->event.response == GR_UNKNOWN_TYPE)
                {
                    exit = TRUE; /* unrecognized input -- return control */
                }
                break;

            case GET_NAME:
               co$getevent(msg = &msg, 
                  event_mask = GRm_STRING | GRm_RESTART | GRm_BACK_UP,
                  msgnum = GR_P_KyCelNmeDes, response = response, 
                  response_data = response_data, event = &me->event);

                switch (me->event.response)
                {
                    case STRING:

                        /*
                         *  parse input for name description
                         */

                        status = GRparse (&msg,
                                 me->event.event.keyin,
                                 me->namdesc.name_symbol,
                                 &me->name_length,
                                 me->namdesc.desc_symbol,
                                 &me->desc_length);

                        if (!status)
                        {
                            ex$message(msgnumb = GR_E_InvNmeDes);
                            break;
                        }

                        /*
                         *  send message to the module in active symbol
                         *  library to search for the symbol definition
                         *  using the keyin name
                         */

                        om_msg = gr$symsd_locate_in_asl ( msg = &msg,
                                 sd_name = me->namdesc.name_symbol,
                                 sl_env = &located_env, 
                                 sd_id = &located_id);

                        if (COERROR (om_msg))
                        {
                           me->state = RESTART;
                           error = TRUE;
                        }else 
                        {
                           if (msg & 1)
                           {  
                              ex$message(msgnumb = GR_E_DupNme);
                           }
                           else
                           {
                              me->state = GET_ORIGIN;
                              UI_status ( "" );
                           }
                        }
                        break;

                    case EX_RESTART:
                        me->state = RESTART;
                        break;

                    case EX_BACK_UP:
                        me->state = LOCATE;
                        break;

                    case GR_UNKNOWN_TYPE:

                        exit = TRUE;
                        break;
                }
                break;

            case GET_ORIGIN:

               co$getevent(msg = &msg, 
                  event_mask = GRm_DATA | GRm_RESTART | GRm_BACK_UP,
                  msgnum = GR_P_EntCelOrg, response = response, 
                  response_data = response_data, event = &me->event);

                switch (me->event.response)
                {
                    case DATA:

                        /*
                         *  get world to view rotation matrix 
                         */
    
                        om_msg = om$send(
                                 msg = message IGEgragad.DPinrot 
                                 (&msg, symbol_matrix), senderid = my_id,
                                 targetid = me->event.event.button.objid,
                                 targetos = me->event.event.button.osnum);

                        if (COERROR (om_msg & msg))
                        {
                            me->state = RESTART;
                            error = TRUE;
                            break;
                        }

                        /*
                         *  add the origin to the symbol creation matrix
                         */

                        one = 1;
                        origin[0] = me->event.event.button.x;
                        origin[1] = me->event.event.button.y;
                        origin[2] = me->event.event.button.z;

                        MAtypemx(&msg, symbol_matrix, &matrix_type);
                        MAoptsxform (&msg, &one, &matrix_type,
                           symbol_matrix, origin, t_origin);

                        symbol_matrix[3] -= t_origin[0];
                        symbol_matrix[7] -= t_origin[1];
                        symbol_matrix[11] -= t_origin[2];

                        /*
                         *  Create the symbol definition header.
                         */

                        sdh_id.osnum = me->asl_env.md_id.osnum;

                        om_msg = om$construct ( osnum = 
                                 me->asl_env.md_id.osnum,
                                 classname = me->sdh_classname,
                                 p_objid = &sdh_id.objid);

                        for (i=0; i < 3; ++i)
                        {
                           geometry.diag_pt1[i] = 0;
                           geometry.diag_pt2[i] = 0;
                        }

                        me->const_list.class_attr = (IGRchar *)&me->namdesc;
                        me->const_list.env_info = &me->asl_env;
                        me->const_list.geometry = (IGRchar *)&geometry;
                        me->const_list.msg = &msg;

                        status = om$send(
                                 msg = message GRgraphics.GRconstruct
                                 (&me->const_list),
                                 targetid = sdh_id.objid,
                                 targetos = sdh_id.osnum);

                        if (COERROR (status & msg))
                        {
                           status = om$send(
                                    msg = message GRgraphics.GRdelete(&msg,
                                    &me->asl_env),
                                    targetid = sdh_id.objid,
                                    targetos = sdh_id.osnum);
                            me->state = RESTART;
                            error = TRUE;
                            break;
                        }

                        /*
                         *  send message to copy the save set components 
                         *  from active module space into the active symbol
                         *  library space
                         */

                        om_msg = GRcp_sd_to_asl (&msg, symbol_matrix, 
                                 &me->asl_env, &sdh_id, my_id,
                                 OM_Gw_current_OS, &gs_chansel);

                        if (COERROR (om_msg & msg))
                        {
                           if (msg == GR_E_SDNOTUNIQUE)
                           {
                              ex$message(msgnumb = GR_E_IllNstCmdRst);
                           }else
                           {
                              error = TRUE;
                           }

                           status = om$send(
                                    msg = message GRgraphics.GRdelete(&msg,
                                    &me->asl_env),
                                    targetid = sdh_id.objid,
                                    targetos = sdh_id.osnum);

                           me->state = RESTART;
                           break;
                        }

                        /*
                         *  Empty the graphics set.  The graphics set
                         *  will cause ISO connections to the copied
                         *  objects.  Thus the ISO should be deleted
                         *  before the OS is filed.
                         */

                        om_msg = gr$gsempty(msg = &msg, 
                                 p_chanselect = &gs_chansel);

                        gr$symsave_asl (msg = &msg);
                                          
                        ex$message(msgnumb = GR_I_CelAddLib);
                        me->state = RESTART;

                        break;

                    case EX_RESTART:
                        me->state = RESTART;
                        break;

                    case EX_BACK_UP:
                        me->state = GET_NAME;

                    case GR_UNKNOWN_TYPE:
                        exit = TRUE;
                        break;
                }
                break;

            case RESTART:

               /*
                *  Empty the graphics set.
                */

               om_msg = gr$gsempty(msg = &msg, p_chanselect = &gs_chansel);

                if ( (! (om_msg & msg & 1)) || error)
                {
                    error = FALSE;
                    ex$message(msgnumb = GR_E_ErrEncCmdRst);
                }

                /* 
                 *  Clear all entries on the stack.
                 */

                me->locate_stack.num_entries = 0;
                me->ele_located = FALSE;
                me->state = LOCATE;
                break;

        } /* end switch (me->state) */
    } /* end while (!exit) */

   return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             init                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *string_ptr)
{
IGRlong     om_msg;     /* OM return code                            */
IGRlong     msg;        /* function return code                      */
IGRlong     size;       /* # of bytes sent to dpb call               */
IGRlong     ret_size;   /* # of bytes returned by dpb call           */
OM_S_CHANSELECT gs_chansel;

   me->ele_located = FALSE;
   me->attr.properties =   LC_LC_ONLY |
                           LC_RW |
                           LC_DP_ONLY |
                           IGN_MOD_BIT |
                           IGN_PLANAR_BIT;

   me->attr.owner_action = LC_READ | LC_NO_REF_HEADER | LC_REF_OBJECTS;

   strcpy (me->attr.classes, "GRgraphics");

   /*
    *  Set up construct arguments
    */

   me->const_list.newflag = NULL;
   me->const_list.geometry = NULL;
   me->const_list.display = NULL;
   me->const_list.class_attr = NULL;
   me->const_list.name = NULL;
   me->const_list.properties = GRIS_NEW | GRIS_LOCATABLE | 
                               GRIS_DISPLAYABLE;

   gs_chansel.type = OM_e_name;
   gs_chansel.u_sel.name = "to_gs_channel";

   /*
    *  Construct a reusable graphics set.
    */

   me->init_success = FALSE;

   size = sizeof (struct GRmd_env);
   if (gr$get_module_env (msg = &om_msg, sizbuf = &size, 
       buffer = &me->ModuleInfo, nret = &ret_size))
   {
      om_msg = gr$gsinit ( msg = &msg, flag = 1, 
               p_chanselect = &gs_chansel, 
               osnum = me->ModuleInfo.md_id.osnum);

      if (om_msg & msg & 1)
      {
         me->init_success = TRUE;
      }
   }
   return ( OM_S_SUCCESS );
} /* end init method */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup (IGRint pos)
{
IGRlong     om_msg;     /* OM return code                            */
IGRlong     msg;        /* function return code                      */
IGRlong     size;       /* # of bytes sent to dpb call               */
IGRlong     ret_size;   /* # of bytes returned by dpb call           */

   if (!me->init_success)
   {
      return (OM_S_SUCCESS);
   }

   /*
    *  retrieve variables from the dpb -- database type, 
    *  dataset information, module id, active level, 
    *  asl environment
    */

   om_msg = gr$symget_asl_env (msg = &msg, asl_env = &me->asl_env);

   if (msg == GR_I_SL_READ_ONLY)
   {
      me->init_success = 4;
   }else if (! (om_msg & msg & 1))
   {
      /* 
       *  Set init success to return a failure if an active symbol
       *  library is not defined.
       */

      me->init_success = 2;               
   }else
   {
      size = sizeof (me->dbtype);
      if (gr$get_database_type (msg = &msg, sizbuf = &size,
          buffer = me->dbtype, nret = &ret_size))
      {
         size = sizeof (me->const_list.level);
         if (gr$get_active_level (msg = &msg, sizbuf = &size, 
              buffer = &me->const_list.level, nret = &ret_size))
         {
            /*
             *  get symbol def header classname for the 
             *  construct (in execute)
             */

            if (me->dbtype[0] == '3' && me->dbtype[1] == 'd')
            {
               strcpy (me->sdh_classname, "GRsmdfhdr");
            }else
            {
               sprintf (me->sdh_classname, "GR%ssmdfhdr", me->dbtype);
            }
            me->init_success = TRUE;
         }
      }
   }

   UI_status ("");
   ex$message(msgnumb = GRC_M_CrtCel);      /* message: create cell */
   return (OM_S_SUCCESS);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             delete                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method delete (int flag)
{
IGRlong  om_msg;     /* OM return code */
IGRlong  ret_msg;
OM_S_CHANSELECT gs_chansel;

   /* set up the channel selector */
   gs_chansel.type = OM_e_addr;
   gs_chansel.u_sel.addr = &me->to_gs_channel;

   /*
    *  Delete the graphics set.  Then delete yourself.
    */

   om_msg = gr$gsdissolve (msg = &ret_msg, p_chanselect = &gs_chansel);

   om_msg = om$send(mode = OM_e_wrt_message,
                    msg = message COroot.delete ( NULL),
                    senderid = my_id,
                    targetid = my_id);

   return ( OM_S_SUCCESS );
}

end implementation COsdcreate;
