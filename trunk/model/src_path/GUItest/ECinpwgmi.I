class implementation ECinpwgm;

#include <alloca.h>
#include "bserr.h"
#include "bsparameters.h"

#include "PWapi/memfunc.h"

#define CMD_INPUT_POLY		0
#define CMD_INPUT_POLY2D	1
#define CMD_INPUT_BSPCURVE	2
#define CMD_INPUT_POINT		3

#define FILENAME_STATE			0
#define REQUEST_PERSISTENCE_STATE	1
#define PROCESS_STATE			2

extern GRclassid OPP_GRbcsubbc_class_id;

from GRgraphics import GRconstruct, GRdisplay;

%safe
static char _infile_name[GR_MAX_CHAR] = "";
static IGRboolean _persistent=TRUE;
%endsafe

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRboolean read_status;
  IGRchar str[GR_MAX_CHAR], substr[GR_MAX_CHAR];
  IGRlong msg_loc, stat_func, stat_OM, event_mask, count;
  GRobjid const_obj;
  PWpoint *pts, pt;
  struct PWpoly2d py2d;
  struct PWpoly py;
  struct GRmd_env *env;
  struct GRevent event;
  struct IGRbsp_curve cv;
  struct GRvg_construct const_list;
  enum GRdpmode dpmode;
  FILE *infile=NULL;

  stat_OM = OM_S_SUCCESS;
  py2d.p_pts = NULL;
  py.p_pts = NULL;
  cv.poles = NULL;
  cv.knots = NULL;
  cv.weights = NULL;
  cv.bdrys = NULL;

  if (ME.super_cmd->mytype == CMD_INPUT_POLY)
    UI_message ("Input Polyline");
  else if (ME.super_cmd->mytype == CMD_INPUT_POLY2D)
    UI_message ("Input Polyline 2d");
  else if (ME.super_cmd->mytype == CMD_INPUT_BSPCURVE)
    UI_message ("Input B-spline Curve");
  else if (ME.super_cmd->mytype == CMD_INPUT_POINT)
    UI_message ("Input Point");
  else  
    UI_message ("Unknown command");

  do
  {
    switch (ME.super_cmd->state)
    {
      case FILENAME_STATE:
        sprintf (str, "Input Filename [%s]", _infile_name);
        UI_prompt (str);
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
 
        switch (event.response)
        {
          case EX_STRING:
            if (! (ME.ECinpwgm->infile = (char *)
                    fopen (event.event.keyin, "r")))
            {
              sprintf (str, "Could not open %s", event.event.keyin);
              UI_status (str);
              break;
            }
            else
            {
              strcpy (_infile_name, event.event.keyin);
              ME.super_cmd->state = REQUEST_PERSISTENCE_STATE;
            }
            break;

          case EX_RJT_MOVEON:
            if (strlen (_infile_name))
            {
              if (! (ME.ECinpwgm->infile = (char *)
                      fopen (_infile_name, "r")))
              {
                sprintf (str, "Could not open %s", _infile_name);
                UI_status (str);
                break;
              }
              else
              {
                ME.super_cmd->state = REQUEST_PERSISTENCE_STATE;
              }
            }
            else
            {
              UI_status ("No filename specified");
            }
            break;

          default:
            goto wrapup;
        }
        break;

      case REQUEST_PERSISTENCE_STATE:
        UI_status ("");
        if (_persistent)
          strcpy (substr, "[y]/n");
        else
          strcpy (substr, "y/[n]");
        sprintf (str, "Create persistent object(s) %s", substr);
        UI_prompt (str);
        event_mask = GRm_TEXT_VALUE | GRm_RJT_MOVEON | GRm_BACK_UP;
        stat_func = co$getevent (msg = &msg_loc, event_mask = event_mask,
                     response = response, response_data = response_data,
                     event = &event);
        EMerr_hndlr (!stat_func, stat_OM, OM_E_ABORT, wrapup);
        UI_prompt ("");
        if (msg_loc == GRw_no_value)
          event.response = EX_RJT_MOVEON;
  
        switch (event.response)
        {
          case EX_STRING:
            if (toupper(event.event.keyin[0]) == 'Y')
              _persistent = TRUE;
            else
              _persistent = FALSE;

            ME.super_cmd->state = PROCESS_STATE;
            break;

          case EX_RJT_MOVEON:
            ME.super_cmd->state = PROCESS_STATE;
            break;

          case EX_BACK_UP:
            fclose ((FILE *) ME.ECinpwgm->infile);
            ME.super_cmd->state = FILENAME_STATE;
            break;

          default:
            goto wrapup;
        }
        break;
     
      case PROCESS_STATE:
        UI_status ("");
     
        env = &ME.ECelements->active_md_env;
        const_list.msg = &msg_loc;
        const_list.newflag = FALSE;
        const_list.env_info = env;
        const_list.level = ME.ECelements->active_level;
        const_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE | GRIS_NEW;
        const_list.display = &ME.ECelements->active_display;
        const_list.class_attr = NULL;
        const_list.name = NULL;
  
        infile = (FILE *) ME.ECinpwgm->infile;
        count = 0;
        do 
        {
          const_obj = NULL_OBJID;
          read_status = FALSE;

          if (ME.super_cmd->mytype == CMD_INPUT_POLY2D)
          {
            if (read_status = pwReadPy2d (infile, &py2d))
            {
              pts = (PWpoint *) alloca (py2d.num_pts * sizeof (PWpoint));
              pwCnvt2dTo3d (py2d.num_pts, py2d.p_pts, pts);
              om$dealloc (ptr = py2d.p_pts);
              py2d.p_pts = NULL;

              if (_persistent)
              {
                if (! EFplace_line_string (my_id, &const_list, 
                       py2d.num_pts, pts, &const_obj, &msg_loc))
                {
                  UI_status ("Could not construct linestring");
                  sleep (2);
                }
              }
              else
              {
                ECdisplayPointSetByBuffer (&msg_loc, 
                 ME.ECelements->active_display, 
                 ME.ECelements->active_md_env, NULL_OBJID, 
                 py2d.num_pts, pts, TRUE);
              }
            }
          }

          else if (ME.super_cmd->mytype == CMD_INPUT_POLY)
          {
            if (read_status = pwReadPy (infile, &py))
            {
              if (!EFplace_line_string (my_id, &const_list, 
                    py.num_pts, py.p_pts, &const_obj, &msg_loc))
              {
                UI_status ("Could not construct linestring");
                sleep (2);
              }
              else
              {
                ECdisplayPointSetByBuffer (&msg_loc, 
                 ME.ECelements->active_display, 
                 ME.ECelements->active_md_env, NULL_OBJID, 
                 py.num_pts, py.p_pts, TRUE);
              }

              om$dealloc (ptr = py.p_pts);
              py.p_pts = NULL;
            }
          }

          else if (ME.super_cmd->mytype == CMD_INPUT_BSPCURVE)
          {
            if (read_status = pwReadBspCv (infile, &cv))
            {
              if (_persistent)
              {
                const_list.geometry = (IGRchar *) &cv;
                stat_OM = om$construct (classid = OPP_GRbcsubbc_class_id,
                           p_objid = &const_obj, osnum = env->md_id.osnum,
                           msg = message GRgraphics.GRconstruct (&const_list));
                if (EMSerror (stat_OM & msg_loc))
                {
                  UI_status ("Could not construct B-spline curve");
                  sleep (2);
                }
              }
              else
              {
                ECdisplayBsplineBybuffer (&msg_loc, 
                 ME.ECelements->active_display, 
                 ME.ECelements->active_md_env, NULL_OBJID, &cv,
                 GRbd, IGRBC);
              }

              om$dealloc (ptr = cv.poles);
              cv.poles = NULL;
              om$dealloc (ptr = cv.knots);
              cv.knots = NULL;
              if (cv.weights)
              {
                om$dealloc (ptr = cv.weights);
                cv.weights = NULL;
              }
              if (cv.bdrys)
              {
                om$dealloc (ptr = cv.bdrys);
                cv.bdrys = NULL;
              }
            }
          }

          else if (ME.super_cmd->mytype == CMD_INPUT_POINT)
          {
            if (read_status = pwReadPt (infile, pt))
            {
              if (!EFplace_line_string (my_id, &const_list, 
                    1, pt, &const_obj, &msg_loc))
              {
                UI_status ("Could not construct point");
                sleep (2);
              }
              else
              {
                ECdisplayPointSetByBuffer (&msg_loc, 
                 ME.ECelements->active_display, 
                 ME.ECelements->active_md_env, NULL_OBJID, 
                 1, pt, TRUE);
              }
            }
          }

          if (read_status)
          {
            count++;
            sprintf (str, "Processed element - %d", count);
            UI_status (str);
          }

          if (!IF_NULL_OBJID (const_obj))
          {
            dpmode = GRbdhe;
            om$send (msg = message GRgraphics.GRdisplay (&msg_loc, 
             &env->md_env.matrix_type, env->md_env.matrix, &dpmode, 
             &env->md_id), targetid = const_obj, targetos = env->md_id.osnum);
          }
        }
        while (read_status);

        fclose (infile);

        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = FILENAME_STATE;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto wrapup;
      }
    }
  while (TRUE);

wrapup:
  if (py.p_pts)
    om$dealloc (ptr = py.p_pts);
  if (py2d.p_pts)
    om$dealloc (ptr = py2d.p_pts);
  if (cv.poles)
    om$dealloc (ptr = cv.poles);
  if (cv.knots)
    om$dealloc (ptr = cv.knots);
  if (cv.weights)
    om$dealloc (ptr = cv.weights);
  if (cv.bdrys)
    om$dealloc (ptr = cv.bdrys);

  if (EMSerror (stat_OM))
    *response = TERMINATE;
  return (stat_OM);
}

end implementation ECinpwgm;
