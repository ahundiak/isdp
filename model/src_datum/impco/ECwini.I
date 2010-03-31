/* ###################   APOGEE COMPILED   ################## */
/*
   History
      pp     ??/??/??     creation date
      dhm    02/04/92     SUN fix - variable declared as int when should have
                          been short.
      dhm    02/04/92     fix for the reference plane origin.
      ra     07/02/92     message system compliance.
      Sudha  06/23/93     modified for BSprototype ansification
      scw    08/15/94     clarified sleep method

*/

class implementation ECwin;

#include <stdio.h>                      /* Needed for print statements */
#include "griodef.h"
#include "igrtypedef.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "igrdef.h"                     /* Has IGRPY */
#include "griodef.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "lcmacros.h"

#include "exmacros.h"                   /* Has ex$putque */
#include "maerr.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "godef.h"
#include "dpdef.h"
#include "EMSdatumdef.h"
#include "EMdtmacros.h" /* For ems$get_datum_plane_mgr..*/
#include "msmacros.h"
#include "ECcmd.h"
#include "ECmsg.h"

%safe
#include <math.h>
%endsafe

#include "bserr.h"
#include "matypemx.h"
#include "maoptsxfo.h"
#include "mainvmx.h"
#include "bsmkvec.h"

# ifndef DEBUG
# define DEBUG 0  /*Set to 1 if want error strings printed.*/
# endif

#define INC 0.95
#define LOCATE_WINDOW 1
#define PROCESS 2

#define MAX_NUM_WIN 32

from EMSdatplnmgr import EMmanage_datum_entry, EMactivate, EMget_info;
from EMSdatpln import EMcreate_resize_handle, EMput_pln_info;
from GRgraphics import GRdisplay;

method super_cmd.sleep(int pos)
{
  IGRlong sts = OM_S_SUCCESS;

  UI_prompt("");
  UI_status("");
  UI_message("");

  return(sts);
}

method execute(int *response; char *response_data; int pos)
{
 IGRlong sts,msg;
 IGRint options,display_flag;
 enum GRdpmode display_mode;
 struct GRid wingrid[MAX_NUM_WIN];
 IGRint total_numwin, numwin,eventmask;

 sts = OM_S_SUCCESS;
 msg = MSSUCC;

 wingrid[0].objid = NULL_OBJID;
 
 ex$message (msgnumb = EM_M_CrtRefPlnfromWindow);

/*
 * Enter infinite loop.
 */
 do
 {
  switch (ME.super_cmd->state)
  {
   case 0:
    ME.super_cmd->state = LOCATE_WINDOW;
   break;

   case LOCATE_WINDOW:
   {
     struct GRevent event;

     ex$message (msgnumb = EMS_P_IdentifyWinforRefPlane);
     eventmask = GRm_DATA | GRm_STRING;

     sts = co$getevent (msg = &msg, event_mask = eventmask,
                     response = response, response_data = response_data,
                     event = &event);
     UI_prompt ("");

     switch (event.response)
     {
       case EX_STRING:
       {
         sts = dp$get_gragad_id (msg = &msg, name = event.event.keyin,
                       total_num = &total_numwin, numberofids = &numwin,
                       found_GRids = wingrid,
                       type_gragad = ALL_GG_CLASSES | ACTIVE_GG);
         if (!(1&sts)) return (OM_E_ABORT);
        
         if (!numwin)        
         {
            ex$message (msgnumb = EMS_S_NotWindowSpecification);
            break;
         }
         me->wingrid.objid = wingrid[0].objid;
         me->wingrid.osnum = wingrid[0].osnum;
         ME.super_cmd->state = PROCESS;
         break;
      }

      case EX_DATA:
       {
        me->wingrid.objid = event.event.button.objid;
        me->wingrid.osnum = event.event.button.osnum;
        numwin = 1;

        /**
            if (IF_NULL_OBJID (wingrid[0].objid))
            Checking for wingrid[0].objid like the above will not let
            users create reference plane from for the first time 
            Fix TR # 119603967
         **/

        if (IF_NULL_OBJID (me->wingrid.objid))
        {
           ex$message ( msgnumb = EMS_S_NotWindowSpecification);
           break;
        } 
         
        ME.super_cmd->state = PROCESS;
       }
       break;

       default:
        return (OM_S_SUCCESS);
      }
      break;
     }

     case PROCESS:
     {
      IGRshort mat_typ, index;
      IGRint i;
      IGRmatrix vw_mat, wv_mat;
      IGRlong error, bytes_ret, num_pts;
      IGRdouble *x_dir, *y_dir;
      IGRdouble origin[3];
      IGRvector diag;
      IGRdouble vw_vol[6],x_size, y_size, active_z;
      OM_S_OBJID mgrid, old_datum;
      OMuword mgros;
      struct var_list list[4];
      struct GRid datpln_GRid;
      struct GRvg_construct const_list;

      list[0].var = WLD_TO_VIEW;
      list[0].var_ptr = (IGRchar *) wv_mat;
      list[0].num_bytes = sizeof(IGRdouble) * 16;
      list[0].bytes_returned = &bytes_ret;

      list[1].var = VW_VOLUME;
      list[1].var_ptr = (IGRchar *)vw_vol;
      list[1].num_bytes = sizeof (IGRdouble) * 6;
      list[1].bytes_returned = &bytes_ret;

      list[2].var = ACT_Z;
      list[2].var_ptr = (IGRchar *)&active_z;
      list[2].num_bytes = sizeof(IGRdouble);
      list[2].bytes_returned = &bytes_ret;


      list[3].var = END_PARAM;
      list[3].var_ptr = NULL;
      list[3].num_bytes = 0;
      list[3].bytes_returned = NULL;
 
      sts = dp$inq_set_gragad(msg = &msg,
                                osnum = me->wingrid.osnum,
                                gragad_objid = me->wingrid.objid,
                                which_error = &error,
                                var_list = list);

      index = 4;
      sts = MAinvmx(&msg, &index, wv_mat, vw_mat);
      vw_vol[2] = vw_vol[5] = 0.0;

      sts = MAtypemx(&msg, vw_mat, &mat_typ);

      /*
       * TR 92N0452  -  reference plane not correctly oriented when the 
       * window is resized.  fix for the origin of the view.  dhm  2/4/92
       */

      for (i=0;i<2;i++)
       origin[i] = (vw_vol[i] + vw_vol[3+i])/2.0;

/*    origin[0] = 0.0;
      origin[1] = 0.0;  */
      origin[2] = active_z;
     
      num_pts = 2;
      sts = MAoptsxform(&msg, &num_pts, &mat_typ, vw_mat, vw_vol, vw_vol);
      
      num_pts = 1;
      sts = MAoptsxform(&msg, &num_pts, &mat_typ, vw_mat, origin, origin);

      const_list.msg = &msg;
      const_list.env_info = &me->md_env;
      const_list.newflag = FALSE;
      const_list.level = ME.ECelement->active_level;
      const_list.properties = GRIS_DISPLAYABLE | GRIS_NEW | GRIS_LOCATABLE;
      const_list.geometry = NULL;
      const_list.display = &ME.ECelement->active_display;
      const_list.class_attr = NULL;
      const_list.name = NULL;

      sts = ems$get_datum_plane_mgr(msg = &msg,
                                   mgrid = &mgrid,
                                   mgros = &mgros);
      if (!(1&sts&msg)) return (OM_E_ABORT);

      sts = om$send (msg = message EMSdatplnmgr.EMget_info(&msg,
                             NULL,NULL,NULL,&old_datum,NULL),
                     targetid = mgrid,
                     targetos = mgros);
      if (!(1&sts&msg)) return (OM_E_ABORT);

      if (old_datum != NULL_OBJID)
      {
/*
 * Erase the active datum plane since the now constructed entity is going
 * to be active.
 */
        display_mode = GRbe;
        sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                       &me->md_env.md_env.matrix_type,
                       me->md_env.md_env.matrix,
                       &display_mode,
                       &me->md_env.md_id),
                   targetid = old_datum,
                   targetos = mgros);
        if (!(1&sts&msg))  return (OM_E_ABORT);
       }

      sts = om$construct(classid = OPP_EMSdatpln_class_id,
                         osnum = const_list.env_info->md_id.osnum,
                         p_objid = &datpln_GRid.objid);
      if (!(1&sts)) return (OM_E_ABORT);
      datpln_GRid.osnum = const_list.env_info->md_id.osnum;

/*
      for (i=0;i<3;i++)
       origin[i] = (vw_vol[i] + vw_vol[3+i])/2.0;
*/

      sts = om$send (msg = message EMSdatpln.EMput_pln_info(&msg,
                           NULL, const_list.env_info,
                           &wv_mat[0],
                           &wv_mat[4],
                           &wv_mat[8],
                           origin,
                           NULL),
                     targetid = datpln_GRid.objid,
                     targetos = datpln_GRid.osnum);
      if (!(1&sts)) return (OM_E_ABORT);

/*
      fprintf (stderr,"xdir %lf %lf %lf \n", wv_mat[0], wv_mat[1],
                        wv_mat[2]);
      fprintf (stderr,"ydir %lf %lf %lf \n", wv_mat[4], wv_mat[5],
                        wv_mat[6]);
      fprintf (stderr,"zdir %lf %lf %lf \n", wv_mat[8], wv_mat[9],
                        wv_mat[10]);
      fprintf (stderr,"origin %lf %lf %lf \n", origin[0], origin[1],
                       origin[2]);
*/

      sts = BSmkvec(&msg, diag,vw_vol, &vw_vol[3]);
      x_dir = wv_mat;
      y_dir = &wv_mat[4];
      x_size = INC*fabs(diag[0]*x_dir[0] + diag[1]*x_dir[1] + diag[2]*x_dir[2]);
      y_size = INC*fabs(diag[0]*y_dir[0] + diag[1]*y_dir[1] + diag[2]*y_dir[2]);
/*
      fprintf (stderr,"xsize, ysize %lf %lf\n",x_size, y_size);
*/

      sts = om$send (msg = message EMSdatpln.EMcreate_resize_handle(&msg,
                           EMS_OPT_DISPLAY_HANDLE, const_list.env_info,
                           &const_list,
                           x_size, y_size,
                           NULL),
                     targetid = datpln_GRid.objid,
                     targetos = datpln_GRid.osnum);
      if (!(1&sts&msg)) return (OM_E_ABORT);


      sts = om$send (msg = message EMSdatplnmgr.EMmanage_datum_entry(&msg,
                          EMS_OPT_ADD,datpln_GRid.objid),
                    targetid = mgrid,
                    targetos = mgros);
      if (!(1&sts&msg)) return (OM_E_ABORT);

      sts = om$send (msg = message EMSdatplnmgr.EMactivate(&msg,
                          NULL, &datpln_GRid.objid, NULL),
                    targetid = mgrid,
                    targetos = mgros);
      if (!(1&sts&msg)) return (OM_E_ABORT);


      if (old_datum != NULL_OBJID)
      {
/*
 * Erase the active datum plane since the now constructed entity is going
 * to be active.
 */
        display_mode = GRbd;
        sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                       &me->md_env.md_env.matrix_type,
                       me->md_env.md_env.matrix,
                       &display_mode,
                       &me->md_env.md_id),
                   targetid = old_datum,
                   targetos = mgros);
        if (!(1&sts&msg))  return (OM_E_ABORT);
       }
      display_mode = GRbd;

      sts = om$send (msg = message GRgraphics.GRdisplay(&msg,
                       &me->md_env.md_env.matrix_type,
                       me->md_env.md_env.matrix,
                       &display_mode,
                       &me->md_env.md_id),
                     targetid = datpln_GRid.objid,
                     targetos = datpln_GRid.osnum);
      if (!(1&sts&msg)) return (OM_E_ABORT);
                      
      ME.super_cmd->state = LOCATE_WINDOW;
      break;
    }
   }
  }
 while (TRUE);
}
end implementation ECwin;

