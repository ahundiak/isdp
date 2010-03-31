/* ###################   APOGEE COMPILED   ################## */
class implementation ECwinornt;

/*
  HISTORY

	Sudha	07/01/93	Modified for BSprototypes ansification
*/

#include "EMS.h"
#include "msdef.h"
#include "bserr.h"
#include "bsparameters.h"
#include "ECmsg.h"
#include "ECcmd.h"
#include "ma.h"
#include "maptplpro.h"
#include "bsnorvec.h"
#include "bsmdistptsf.h"
#include "bsmdistptcv.h"
#include "bscvarrevnt.h"
#include "bscrossp.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

#define LOCATE_ELEMENT      0
#define XAXIS_PT1           1
#define XAXIS_PT2           2
#define LOCATE_WINDOW	    3
#define PROCESS	            4

#define X 0
#define Y 1
#define Z 2

#define MAX_NUM_WIN 32

extern GRclassid OPP_GRvg_class_id;
extern GRclassid OPP_GRcurve_class_id, OPP_EMSsubbs_class_id;

from GRgraphics import GRgetrang, GRdisplay;
from GRvg import GRdetplane;

method get_locate_criteria (IGRlong *msg; IGRint maxnum_classes;
                            OM_S_CLASSLIST *rtree_classes, *elig_classes,
                            *nelig_classes; IGRushort *geomprops;
                            IGRshort *operation; IGRushort *options;
                            IGRint *minnum_to_locate, *maxnum_to_locate)
{
  IGRlong stat_OM;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  rtree_classes->w_count = 1;
  rtree_classes->w_flags = OM_CLST_subclass;
  rtree_classes->p_classes[0] = OPP_GRvg_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  elig_classes->p_classes[0] = OPP_GRvg_class_id;

  nelig_classes->w_count = 0;

  *geomprops = NULL;
  *operation = EC_GEOM_READ;
  *options = EC_LOC_PROJACCPT | EC_LOC_NOFLEXGROUPS | EC_LOC_PLANEDEF;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

ret_end:
  return (stat_OM);
}

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean stat_func, in_world, planar_ele;
  IGRchar *str;
  IGRshort four=4, i, numcvpars, dum_k;
  IGRint one=1, total_numwin, numwin;
  IGRlong msg_loc, stat_OM, eventmask, addmask;
  IGRdouble *cvpars, *dumcvintpars, sfu, sfv, dumdist, *zvec, *xvec;
  IGRpoint pt, pts3[3];
  IGRvector vec1, vec2;
  GRrange range;
  GRclassid objclass;
  struct GRid wingrid[MAX_NUM_WIN];
  struct GRevent event;
  struct GRmd_env *env, *ele_env;
  struct var_list list_var[2];
  struct IGRbsp_surface *srf;
  struct IGRbsp_curve *crv;
  struct GRid eleid;
  struct IGRplane plane;
  enum GRdpmode dpmode;
  enum EMSuser_responses useract;
  char elemtype[10];
  extern void EMavgsfnorm(), EFdraw_vector_on_screen();
  extern IGRlong EMgetabsg(), EMsetwinornt();

  stat_OM = OM_S_SUCCESS;

  cvpars = NULL;
  dumcvintpars = NULL;

  env = &ME.ECelements->active_md_env;

  ex$message ( msgnumb = EM_M_SetWindowOrientationByElement);

  do
    {
    switch (ME.super_cmd->state)
      {
      case LOCATE_ELEMENT:
        ex$message (msgnumb = EMS_P_Element, buff = elemtype);
        stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                   &useract, response, response_data, elemtype, NULL,
                   NULL, NULL, NULL, NULL), targetid = my_id);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        if (useract == EMSuser_data)
          {
          eleid = ME.ECelements->elems[0].located_obj;
          om$get_classid (objid = eleid.objid, osnum = eleid.osnum,
           p_classid = &objclass);

          stat_OM = om$is_ancestry_valid (subclassid = objclass,
                     superclassid = OPP_GRcurve_class_id);
          if (stat_OM == OM_S_SUCCESS)
            {
	    typedef IGRpoint  dummy[3];

            stat_OM = EMgetabsg (&msg_loc, &env->md_env.matrix_type,
                       env->md_env.matrix, eleid.osnum, eleid.objid, &crv);
            EMomerr_exit (stat_OM, ret_end);

            BSmdistptcv (crv, &ME.ECelements->accev.event.button.x,
             &dum_k, &numcvpars, &cvpars, &dumdist, &dumcvintpars, &msg_loc);
            EMerr_hndlr (msg_loc != BSSUCC || !numcvpars, stat_OM, OM_E_ABORT,
             ret_end);

            BScvarrevnt (crv, &cvpars[0], 1, 1.0, NULL, (dummy *) pts3, &msg_loc);
            EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);

            OM_BLOCK_MOVE (pts3[0], ME.ECwinornt->origpt, sizeof (IGRpoint));
            for (i=0; i<3; i++)
              {
              vec1[i] = pts3[1][i] - pts3[0][i];
              vec2[i] = pts3[2][i] - pts3[0][i];
              }
            zvec = ME.ECwinornt->zvec;
            BScrossp (&msg_loc, vec1, vec2, zvec);

            if (crv->planar)
              planar_ele = TRUE;
            else
              planar_ele = FALSE;

            if (planar_ele)
              OM_BLOCK_MOVE (ME.ECwinornt->origpt, ME.ECwinornt->xaxis_pt1,
               sizeof (IGRpoint));
            }
          else
            {
            stat_OM = EMgetabsg (&msg_loc, &env->md_env.matrix_type,
                       env->md_env.matrix, eleid.osnum, eleid.objid, &srf);
            EMomerr_exit (stat_OM, ret_end);

            BSmdistptsf (&msg_loc, srf, &ME.ECelements->accev.event.button.x,
             &sfu, &sfv, ME.ECwinornt->origpt, &dumdist);
            EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, ret_end);

            zvec = ME.ECwinornt->zvec;
            EMavgsfnorm (&msg_loc, srf, sfu, sfv, ME.ECwinornt->origpt, zvec);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            if (srf->planar)
              planar_ele = TRUE;
            else
              planar_ele = FALSE;

            if (planar_ele)
              OM_BLOCK_MOVE (ME.ECwinornt->origpt, ME.ECwinornt->xaxis_pt1,
               sizeof (IGRpoint));

            if (srf->pos_orient)
              {
              zvec[X] = -zvec[X];
              zvec[Y] = -zvec[Y];
              zvec[Z] = -zvec[Z];
              }
            }
          ME.ECwinornt->planar_ele = planar_ele;
 
          if (planar_ele)
            ME.super_cmd->state = XAXIS_PT2;
          else
            ME.super_cmd->state = XAXIS_PT1;
          }
        else 
          goto ret_end;
        break;

      case XAXIS_PT1:
        eleid = ME.ECelements->elems[0].located_obj;
        in_world = TRUE;
        stat_OM = om$send (msg = message GRgraphics.GRgetrang (&msg_loc,
                   &env->md_env.matrix_type, env->md_env.matrix, &in_world,
                   range), targetid = eleid.objid, targetos = eleid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        ME.ECelements->active_display.color++;
        EFdraw_vector_on_screen (my_id, &ME.ECelements->active_display, env,
         GRbd, FALSE, ME.ECwinornt->origpt, ME.ECwinornt->zvec, range,
         &msg_loc);
        ME.ECelements->active_display.color--;
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

        if (ME.ECwinornt->planar_ele)
        {
          addmask = NULL;
          ex$message ( msgnumb = EMS_P_InputFirstPointOfXaxis);
        }
        else
        {
          addmask = GRm_RJT_MOVEON;
          ex$message ( msgnumb = EMS_P_AcceptViewDirWithPoint1);
        }

        eventmask = GRm_DATA | GRm_BACK_UP | addmask;
        stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            EFdraw_vector_on_screen (my_id, &ME.ECelements->active_display,
             env, GRbehe, FALSE, ME.ECwinornt->origpt, ME.ECwinornt->zvec, 
             range, &msg_loc);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            zvec = ME.ECwinornt->zvec;
            zvec[X] = -zvec[X];
            zvec[Y] = -zvec[Y];
            zvec[Z] = -zvec[Z];
            break;

          case EX_BACK_UP:
            ME.ECelements->num_elems = 0;
            ME.ECelements->num_events = 0;
            dp$erase_hilite (msg = &msg_loc);
            ME.super_cmd->state = LOCATE_ELEMENT;
            break;

          case EX_DATA:
            OM_BLOCK_MOVE (&event.event.button.x, ME.ECwinornt->xaxis_pt1,
             sizeof (IGRpoint));
            ME.super_cmd->state = XAXIS_PT2;
            break;

          default:
            goto ret_end;
          }
        break;

      case XAXIS_PT2:
        eleid = ME.ECelements->elems[0].located_obj;
        in_world = TRUE;
        stat_OM = om$send (msg = message GRgraphics.GRgetrang (&msg_loc,
                   &env->md_env.matrix_type, env->md_env.matrix, &in_world,
                   range), targetid = eleid.objid, targetos = eleid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        ME.ECelements->active_display.color++;
        EFdraw_vector_on_screen (my_id, &ME.ECelements->active_display, env,
         GRbd, FALSE, ME.ECwinornt->origpt, ME.ECwinornt->zvec, range,
         &msg_loc);
        ME.ECelements->active_display.color--;
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

        if (ME.ECwinornt->planar_ele)
        {
          addmask = GRm_RJT_MOVEON;
          ex$message ( msgnumb = EMS_P_AcceptViewDirWithPoint2);
        }
        else
        {
          addmask = NULL;
          ex$message ( msgnumb = EMS_P_InputSecondPointOfXaxis);
        }

        EFrblineseg (ME.ECwinornt->origpt, &ME.ECelements->active_display);

        eventmask = GRm_DATA | GRm_BACK_UP | addmask;
        stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;

        switch (event.response)
          {
          case EX_RJT_MOVEON:
            EFdraw_vector_on_screen (my_id, &ME.ECelements->active_display,
             env, GRbehe, FALSE, ME.ECwinornt->origpt, ME.ECwinornt->zvec,
             range, &msg_loc);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            zvec = ME.ECwinornt->zvec;
            zvec[X] = -zvec[X];
            zvec[Y] = -zvec[Y];
            zvec[Z] = -zvec[Z];
            break;

          case EX_BACK_UP:
            EFdraw_vector_on_screen (my_id, &ME.ECelements->active_display,
             env, GRbehe, FALSE, ME.ECwinornt->origpt, ME.ECwinornt->zvec,
             range, &msg_loc);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            ME.super_cmd->state = XAXIS_PT1;
            break;

          case EX_DATA:
            plane.point = ME.ECwinornt->origpt;
            plane.normal = ME.ECwinornt->zvec;
            MAptplproj (&msg_loc, (IGRpoint *)&event.event.button.x, &plane, 
             ME.ECwinornt->xaxis_pt2);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

            xvec = ME.ECwinornt->xvec;
            for (i=0; i<3; i++)
              xvec[i] = ME.ECwinornt->xaxis_pt2[i] -
                         ME.ECwinornt->xaxis_pt1[i];
            BSnorvec (&msg_loc, xvec);
            if (msg_loc != BSSUCC)
            {
              ex$message ( msgnumb = EMS_S_SecondXaxisPointNotDistinct);
              break;
            }

            ME.super_cmd->state = LOCATE_WINDOW;
            break;

          default:
            goto ret_end;
          }
        break;

      case LOCATE_WINDOW:
        ex$message ( msgnumb = EMS_P_IdentifyWindowToReorient);
        eventmask = GRm_DATA | GRm_STRING | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = eventmask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, ret_end);
        UI_prompt ("");

        switch (event.response)
          {
          case EX_DATA:
            wingrid[0].objid = event.event.button.objid;
            wingrid[0].osnum = event.event.button.osnum;
            numwin = 1;
            if (IF_NULL_OBJID (wingrid[0].objid))
            {
              ex$message ( msgnumb = EMS_S_NotWindowSpecification);
              break;
            }
            ME.super_cmd->state = PROCESS;
            break;

          case EX_STRING:
            str = event.event.keyin;
            stat_OM = dp$get_gragad_id (msg = &msg_loc, name = str,
                       total_num = &total_numwin, numberofids = &numwin,
                       found_GRids = wingrid,
                       type_gragad = ALL_GG_CLASSES | ACTIVE_GG);
            EMomerr_exit (stat_OM, ret_end);
            if (!numwin)        
            {
              ex$message ( msgnumb = EMS_S_NotWindowSpecification);
              break;
            }
            ME.super_cmd->state = PROCESS;
            break;

          case EX_BACK_UP:
            ME.super_cmd->state = XAXIS_PT2;
            break;

          default:
            goto ret_end;
          }
        break;

      case PROCESS:
        eleid = ME.ECelements->elems[0].located_obj;
        in_world = TRUE;
        stat_OM = om$send (msg = message GRgraphics.GRgetrang (&msg_loc,
                   &env->md_env.matrix_type, env->md_env.matrix, &in_world,
                   range), targetid = eleid.objid, targetos = eleid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        EFdraw_vector_on_screen (my_id, &ME.ECelements->active_display, env,
         GRbehe, FALSE, ME.ECwinornt->origpt, ME.ECwinornt->zvec, range,
         &msg_loc);
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, ret_end);

        stat_OM = EMsetwinornt (&msg_loc, numwin, wingrid,
                   ME.ECwinornt->origpt,
                   ME.ECwinornt->xvec, ME.ECwinornt->zvec,
                   &ME.ECelements->elems[0]);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);

        ele_env = &ME.ECelements->elems[0].module_info;
        eleid = ME.ECelements->elems[0].located_obj;
        dpmode = GRhhd;
        stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
                   &ele_env->md_env.matrix_type, ele_env->md_env.matrix,
                   &dpmode, &env->md_id),
                   targetid = eleid.objid, targetos = eleid.osnum);
        EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
         ret_end);
                   
        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = LOCATE_ELEMENT;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto ret_end;
      }
    }
  while (TRUE);

ret_end:
  if (EMSerror (stat_OM))
  {
    ex$message ( msgnumb = EMS_S_ErrorInCommand);
    *response = TERMINATE;
  }
  return (stat_OM);
}

end implementation ECwinornt;
