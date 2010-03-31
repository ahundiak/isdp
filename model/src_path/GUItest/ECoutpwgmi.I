class implementation ECoutpwgm;

#include "bserr.h"
#include "bsparameters.h"

#include "PWapi/memfunc.h"

#define CMD_OUTPUT_POLY		0
#define CMD_OUTPUT_POLY2D	1
#define CMD_OUTPUT_BSPCURVE	2

#define LOCATE_STATE		0
#define FILENAME_STATE		1
#define PROCESS_STATE		2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

extern GRclassid OPP_GRbspline_class_id, OPP_GRcurve_class_id;

%safe
static char outfile_name[GR_MAX_CHAR] = "";
%endsafe

method execute (IGRint *response; IGRchar *response_data; IGRint pos)
{
  IGRchar str[GR_MAX_CHAR], substr[GR_MAX_CHAR];
  IGRshort xform_mattyp;
  IGRlong i, j, numpts, msg_loc, stat_func, stat_OM, event_mask;
  IGRdouble chttol, *dumpars=NULL, dist, distol;
  IGRpoint pt, far_pt;
  IGRvector norm;
  IGRmatrix xform_mat;
  PWpoint2d *pts2d;
  PWpoint *pts, *chtpts=NULL;
  struct PWpoly2d py2d;
  struct PWpoly py;
  struct IGRplane plane;
  struct GRmd_env *env;
  struct GRevent event;
  struct GRid *elem;
  struct IGRbsp_curve *cv=NULL;
  struct IGRline bline;
  enum EMSuser_responses useract;
  FILE *outfile=NULL;

  stat_OM = OM_S_SUCCESS;

  if (ME.super_cmd->mytype == CMD_OUTPUT_POLY)
    UI_message ("Output Polyline");
  else if (ME.super_cmd->mytype == CMD_OUTPUT_POLY2D)
    UI_message ("Output Polyline 2D");
  else if (ME.super_cmd->mytype == CMD_OUTPUT_BSPCURVE)
    UI_message ("Output B-spline Curve");
  else  
    UI_message ("Unknown command");

  do
    {
      switch (ME.super_cmd->state)
      {
        case LOCATE_STATE:
          stat_OM = om$send (msg = message ECelements.do_locate (&msg_loc,
                     &useract, response, response_data, "Curve",
                     NULL, NULL, NULL, NULL, NULL),
                     targetid = my_id);
          EMerr_hndlr (EMSerror (stat_OM & msg_loc), stat_OM, OM_E_ABORT,
           wrapup);

          if (useract == EMSuser_data)
          {
            ME.super_cmd->state = FILENAME_STATE;
          }
          else 
          {
            goto wrapup;
          }
          break;

      case FILENAME_STATE:
        if (!strlen (outfile_name))
          strcpy (substr, "stderr");
        else
          strcpy (substr, outfile_name);
        sprintf (str, "Output Filename [%s]", substr);
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
            if (! (outfile = fopen (event.event.keyin, "w")))
            {
              sprintf (str, "Could not open %s", event.event.keyin);
              UI_status (str);
              break;
            }
            else
            {
              strcpy (outfile_name, event.event.keyin);
              ME.super_cmd->state = PROCESS_STATE;
            }
            break;

          case EX_RJT_MOVEON:
            if (strlen (outfile_name))
            {
              if (! (outfile = fopen (outfile_name, "w")))
              {
                sprintf (str, "Could not open %s", outfile_name);
                UI_status (str);
                break;
              }
              else
              {
                ME.super_cmd->state = PROCESS_STATE;
              }
            }
            else
            {
              outfile = stderr;
              ME.super_cmd->state = PROCESS_STATE;
            }
            break;

          case EX_BACK_UP:
            ME.ECelements->num_elems = 0;
            ME.ECelements->num_events = 0;
            ME.super_cmd->state = LOCATE_STATE;
            break;

          default:
            goto wrapup;
        }
        break;

      case PROCESS_STATE:
        dp$erase_hilite (msg = &msg_loc);
        ME.ECelements->elems_hilit = FALSE;

        UI_status ("");
     
        env = &ME.ECelements->active_md_env;
        elem = &ME.ECelements->elems->located_obj;

        EMgetvggeom (&msg_loc, &env->md_env.matrix_type, env->md_env.matrix,
         elem, &cv, NULL);
        EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, wrapup);

        if (ME.super_cmd->mytype == CMD_OUTPUT_POLY2D ||
            ME.super_cmd->mytype == CMD_OUTPUT_POLY)
        {
          if (ME.super_cmd->mytype == CMD_OUTPUT_POLY2D)
          {
            bline.point1 = pt;
            bline.point2 = far_pt;
            EFboreline (&msg_loc, my_id, &ME.ECelements->locev, &bline);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, wrapup);
            for (i=X; i<=Z; i++)
              norm[i] = far_pt[i] - pt[i];
            BSnorvec (&msg_loc, norm);

            plane.point = pt;
            plane.normal = norm;
            for (i=X; i<=Z; i++)
              far_pt[i] = 0.0;
            MAptpldis (&msg_loc, far_pt, &plane, &dist);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, wrapup);
            BSEXTRACTPAR (&msg_loc, BSTOLLENVEC, distol);
            if (dist <= distol)
              for (i=X; i<=Z; i++)
                pt[i] = 0.0;

            EMtoplnxform (&msg_loc, pt, norm, &env->md_env.matrix_type,
             env->md_env.matrix, &xform_mattyp, &xform_mat, NULL, NULL, NULL);
            EMerr_hndlr (EMSerror (msg_loc), stat_OM, OM_E_ABORT, wrapup);
 
            if (cv->rational)
              MArptsxform (&msg_loc, &cv->num_poles, &cv->rational, 
               cv->weights, xform_mat, cv->poles, cv->poles);
            else
              MAoptsxform (&msg_loc, &cv->num_poles, &xform_mattyp, xform_mat,
               cv->poles, cv->poles);
          }

          if (cv->order == 2)
          {
            pts = (PWpoint *) cv->poles;
            numpts = cv->num_poles;
            if (cv->rational)
              for (i=0; i<numpts; i++)
                for (j=0; j<3; j++)
                  pts[i][j] /= cv->weights[i];
          }
          else
          {
            BSEXTRACTPAR (&msg_loc, BSTOLCHRDHT, chttol);
            BSchtptstcv (cv, &numpts, &chtpts, &dumpars, &msg_loc);
            EMerr_hndlr (msg_loc != BSSUCC, stat_OM, OM_E_ABORT, wrapup);
            pts = chtpts;
          }
    
          if (ME.super_cmd->mytype == CMD_OUTPUT_POLY2D)
          {
            pts2d = (PWpoint2d *) pts;
            pwCnvt3dTo2d (numpts, pts, pts2d);
            py2d.num_pts = numpts;
            py2d.p_pts = pts2d;
            pwPrintPy2d (outfile, 0, &py2d);
          }
          else
          {
            py.num_pts = numpts;
            py.p_pts = pts;
            pwPrintPy (outfile, 0, &py);
          }
        }

        else if (ME.super_cmd->mytype == CMD_OUTPUT_BSPCURVE)
        {
          pwPrintBspCv (outfile, 0, cv);
        }

        om$dealloc (ptr = cv);
        if (chtpts)
          om$dealloc (ptr = chtpts);
        if (dumpars)
          om$dealloc (ptr = dumpars);
        cv = NULL;
        chtpts = NULL;
        dumpars = NULL;
        fclose (outfile);

        ME.ECelements->num_elems = 0;
        ME.ECelements->num_events = 0;
        ME.super_cmd->state = LOCATE_STATE;
        break;

      default:
        stat_OM = OM_E_ABORT;
        goto wrapup;
      }
    }
  while (TRUE);

wrapup:
  if (cv)
    om$dealloc (ptr = cv);
  if (chtpts)
    om$dealloc (ptr = chtpts);
  if (dumpars)
    om$dealloc (ptr = dumpars);

  if (EMSerror (stat_OM))
    *response = TERMINATE;
  return (stat_OM);
}


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
  rtree_classes->p_classes[0] = OPP_GRbspline_class_id;

  elig_classes->w_count = 1;
  elig_classes->w_flags = OM_CLST_subclass;
  elig_classes->p_classes[0] = OPP_GRcurve_class_id;

  nelig_classes->w_count = 0;

  *geomprops = ME.super_cmd->mytype == CMD_OUTPUT_POLY2D ? 
                LC_PLANAR_ONLY : NULL;
  *operation = EC_GEOM_READ;
  *options = NULL;

  *minnum_to_locate = 1;
  *maxnum_to_locate = 1;

  return (stat_OM);
}

end implementation ECoutpwgm;
