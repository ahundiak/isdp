class implementation SKgmhndlpt;

/*
   HISTORY

	Sudha  :  07/02/93  :  Modified for BSprototypes ansification
*/

#include "OMmacros.h"
#include "bsconic.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "emserr.h"
#include "EMSmsgdef.h"
#include "ECmsg.h"
#include "msdef.h"
#include "msmacros.h"
#include "SKdef.h"
#include <alloca.h>
#include "maoptsxfo.h"
#include "macr3ptco.h"
#include "bserr.h"
#include "bsbx2.h"

#define XMIN 0
#define XMAX 3

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method GRgetobjinfo (long *msg; struct GRobj_info *info)
{
  *msg = EMS_S_Success;
  ex$message ( buff = info->type, msgnumb = EMS_S_ConstrainHandle );
  return (OM_S_SUCCESS);
}

method SKinit (long *msg; unsigned short opts;
               int type;
               int num_prim_pts; IGRpoint *prim_pts;
               int num_sec_pts; IGRpoint *sec_pts)
{
  long stat_OM;
  double *dptr;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  ME.SKgmhndlpt->type = type;

  if (num_prim_pts)
    {
    if (om$dimension_of (varray = ME.SKgmhndlpt->prim_pts) < num_prim_pts)
      {
      stat_OM = om$vla_set_dimension (varray = ME.SKgmhndlpt->prim_pts,
                 size = num_prim_pts);
      EMomerr_exit (stat_OM, ret_end);
      }
    dptr = (double *) ME.SKgmhndlpt->prim_pts;
    OM_BLOCK_MOVE (prim_pts, dptr, num_prim_pts * sizeof (IGRpoint));

    ME.SKgmhndlpt->num_prim_pts = num_prim_pts;
    }
  else
    ME.SKgmhndlpt->num_prim_pts = 0;

  if (num_sec_pts)
    {
    if (om$dimension_of (varray = ME.SKgmhndlpt->sec_pts) < num_sec_pts)
      {
      stat_OM = om$vla_set_dimension (varray = ME.SKgmhndlpt->sec_pts,
                 size = num_sec_pts);
      EMomerr_exit (stat_OM, ret_end);
      }
    dptr = (double *) ME.SKgmhndlpt->sec_pts;
    OM_BLOCK_MOVE (sec_pts, dptr, num_sec_pts * sizeof (IGRpoint));

    ME.SKgmhndlpt->num_sec_pts = num_sec_pts;
    }
  else
    ME.SKgmhndlpt->num_sec_pts = 0;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgmhndlpt.SKcreate");
  return (stat_OM);
}


method SKgetinst (long *msg;
                  int *type;
                  int *num_prim_pts; double **prim_pts;
                  int *num_sec_pts; double **sec_pts)
{
  int num;
  long stat_OM;
  double *dptr;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  if (type)
    *type = ME.SKgmhndlpt->type;

  num = ME.SKgmhndlpt->num_prim_pts;
  if (num_prim_pts)
    *num_prim_pts = num;
  if (prim_pts)
    {
    if (!*prim_pts)
      {
      *prim_pts = (double *) om$malloc (size = num * sizeof (IGRpoint));
      EMerr_hndlr (!*prim_pts, *msg, EMS_E_NoDynamicMemory, ret_end);
      }
    dptr = *prim_pts;
    OM_BLOCK_MOVE (ME.SKgmhndlpt->prim_pts, dptr, num * sizeof (IGRpoint));
    }

  num = ME.SKgmhndlpt->num_sec_pts;
  if (num_sec_pts)
    *num_sec_pts = num;
  if (sec_pts)
    {
    if (!*sec_pts)
      {
      *sec_pts = (double *) om$malloc (size = num * sizeof (IGRpoint));
      EMerr_hndlr (!*sec_pts, *msg, EMS_E_NoDynamicMemory, ret_end);
      }
    dptr = *sec_pts;
    OM_BLOCK_MOVE (ME.SKgmhndlpt->sec_pts, dptr, num * sizeof (IGRpoint));
    }

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgmhndlpt.SKgetinst");
  return (stat_OM);
}


method GRdisyourself (long *msg;
                      short *mattyp; IGRmatrix mat;
                      enum GRdpmode *dpmode;
                      struct IGRaltdisplay *alt_symb;
                      struct DP_information *sp_info;
                      OM_p_KEY_DESC key)
{
  IGRboolean fit_mode;
  IGRuchar loc_style;
  char loc_weight;
  int i, type;
  int disp_flags;
  long one=1, stat_OM, msg_loc, num_prim_pts, num_sec_pts;
  double cirwts[BSCIRCLE_NUM_POLES_MAX], cirkts[BSCIRCLE_NUM_KNOTS_MAX];
  IGRpoint *sec_pts, *prim_pts, grpt;
  IGRpoint cirpls[BSCIRCLE_NUM_POLES_MAX];
  GRrange gmrng;
  struct IGRpolyline py;
  struct IGRbsp_curve cv;
  struct DPele_header ele_header;
  struct IGRdisplay dis_attr;
  struct IGResbc esbc;
  enum GRdpmode loc_dpmode;

  *msg = MSSUCC;
  stat_OM = OM_S_SUCCESS;

  loc_dpmode = *dpmode;
  if ((ME.GRgraphics->properties & GRIS_DISPLAYABLE ||
       loc_dpmode == GRhdo || loc_dpmode == GRhhdo || loc_dpmode == GRheo ||
       loc_dpmode == GRbdheo || loc_dpmode == GRbeheo) &&
      DPlevel_on (ME.GRgraphics->level, sp_info))
    {
    if (alt_symb)
      {
      dis_attr.color = (alt_symb->color ?
                        *alt_symb->color : ME.GRvg->display_attr.color);
      dis_attr.weight = (alt_symb->weight ?
                        *alt_symb->weight : ME.GRvg->display_attr.weight);
      dis_attr.style = (alt_symb->style ?
                        *alt_symb->style : ME.GRvg->display_attr.style);
      }
    else 
      dis_attr = ME.GRvg->display_attr;

    if (num_prim_pts = ME.SKgmhndlpt->num_prim_pts)
      {
      prim_pts = (IGRpoint *) alloca ( num_prim_pts * sizeof ( IGRpoint ) );
      memcpy (prim_pts, ME.SKgmhndlpt->prim_pts,
       num_prim_pts * sizeof (IGRpoint));
      }

    if (num_sec_pts = ME.SKgmhndlpt->num_sec_pts)
      {
      sec_pts = (IGRpoint *) alloca ( num_sec_pts * sizeof ( IGRpoint ) );
      memcpy (sec_pts, ME.SKgmhndlpt->sec_pts,
       num_sec_pts * sizeof (IGRpoint));
      }
    memcpy (grpt, ME.GR3dpoint->point, sizeof (IGRpoint));

    if (*mattyp != MAIDMX)
      {
      if (num_prim_pts)
        MAoptsxform (&msg_loc, &num_prim_pts, mattyp, mat, (IGRdouble *)prim_pts, (IGRdouble *)prim_pts);
      if (num_sec_pts)
        MAoptsxform (&msg_loc, &num_sec_pts, mattyp, mat, (IGRdouble *)sec_pts, (IGRdouble *)sec_pts);
      MAoptsxform (&msg_loc, &one, mattyp, mat, grpt, grpt);
      }

    disp_flags = ME.GRgraphics->properties & GRFILLED_DISPLAY ? 
                  DPPOLY_FILL : NULL;
    fit_mode = DPis_fit (sp_info);

    type = ME.SKgmhndlpt->type;
    switch (type)
      {
      case SK_CNSTR_COLLINEAR:
      case SK_CNSTR_HORIZVERT:
      case SK_CNSTR_PARALLEL:
      case SK_CNSTR_NORMAL:
      case SK_CNSTR_GROUND:
      case SK_CNSTR_COINCIDENT:
      case SK_CNSTR_EQUALLEN:
        if (num_sec_pts)
          {
          py.num_points = num_sec_pts;
          py.points = (double *) sec_pts;

          BSbx2 (&msg_loc, &num_sec_pts, sec_pts, NULL,
           &gmrng[XMIN], &gmrng[XMAX]);

          dis_attr.weight += 2;
          dp$build_dis_buffer (buffer = &ele_header, type = IGRPS,
           display_att = &dis_attr, range = gmrng, tag = my_id,
           geometry = fit_mode ? NULL : &py);

          dp$dispelem (msg = &msg_loc, buffer = &ele_header, mode = *dpmode, 
           dp_info = sp_info);
          dis_attr.weight -= 2;

          loc_style = dis_attr.style;
          loc_weight = dis_attr.weight;
          dis_attr.style = 2;
          dis_attr.weight = 0;
          dp$build_dis_buffer (buffer = &ele_header, type = IGRPY,
           display_att = &dis_attr, range = gmrng, tag = my_id,
           geometry = fit_mode ? NULL : &py);

          dp$dispelem (msg = &msg_loc, buffer = &ele_header, mode = *dpmode, 
           dp_info = sp_info);
          dis_attr.style = loc_style;
          dis_attr.weight = loc_weight;
          }

        if (type == SK_CNSTR_NORMAL || type == SK_CNSTR_GROUND ||
             type == SK_CNSTR_EQUALLEN || type == SK_CNSTR_COINCIDENT)
          {
          py.num_points = num_prim_pts;
          py.points = (double *) prim_pts;

          BSbx2 (&msg_loc, &num_prim_pts, prim_pts, NULL,
           &gmrng[XMIN], &gmrng[XMAX]);

          dp$build_dis_buffer (buffer = &ele_header, type = IGRPY,
           display_att = &dis_attr, range = gmrng, tag = my_id,
           geometry = fit_mode ? NULL : &py);

          dp$dispelem (msg = &msg_loc, buffer = &ele_header, mode = *dpmode, 
           dp_info = sp_info);
          }
        else
          {
          BSbx2 (&msg_loc, &num_prim_pts, prim_pts, NULL,
           &gmrng[XMIN], &gmrng[XMAX]);

          py.num_points = 2;
          for (i=0; i<4; i+=2)
            {
            py.points = prim_pts[i];
            dp$build_dis_buffer (buffer = &ele_header, type = IGRPY,
             display_att = &dis_attr, range = gmrng, tag = my_id,
             geometry = fit_mode ? NULL : &py);

            dp$dispelem (msg = &msg_loc, buffer = &ele_header, mode = *dpmode, 
             dp_info = sp_info);
            }
          }
        if (type == SK_CNSTR_EQUALLEN)
          {
          py.num_points = 1;
          py.points = (double *) grpt;

          BSbx2 (&msg_loc, &py.num_points, (IGRpoint *)py.points, NULL,
           &gmrng[XMIN], &gmrng[XMAX]);

          dis_attr.weight += 2;
          dp$build_dis_buffer (buffer = &ele_header, type = IGRPS,
           display_att = &dis_attr, range = gmrng, tag = my_id,
           geometry = fit_mode ? NULL : &py);

          dp$dispelem (msg = &msg_loc, buffer = &ele_header, mode = *dpmode, 
           dp_info = sp_info);
          dis_attr.weight -= 2;
          }
        break;

      case SK_CNSTR_PTONELEM:
        py.num_points = 1;
        py.points = (double *) prim_pts;

        BSbx2 (&msg_loc, &py.num_points, (IGRpoint *)py.points, NULL,
         &gmrng[XMIN], &gmrng[XMAX]);

        dis_attr.weight += 2;
        dp$build_dis_buffer (buffer = &ele_header, type = IGRPS,
         display_att = &dis_attr, range = gmrng, tag = my_id,
         geometry = fit_mode ? NULL : &py);

        dp$dispelem (msg = &msg_loc, buffer = &ele_header, mode = *dpmode, 
         dp_info = sp_info);
        dis_attr.weight -= 2;
        break;

      case SK_CNSTR_TANGENT:
        if (num_prim_pts == 3)
          {
          cv.poles = (double *) cirpls;
          cv.knots = (double *) cirkts;
          cv.weights = (double *) cirwts;
          MAcr3ptconstr (&msg_loc, (IGRdouble *)prim_pts, &cv);
          if (!EMSerror (msg_loc))
            {
            BSbx2 (&msg_loc, &cv.num_poles, (IGRpoint *)cv.poles, cv.weights,
             &gmrng[XMIN], &gmrng[XMAX]);

            esbc.is_polydis = FALSE;
            esbc.is_curvedis = TRUE;
            dp$build_dis_buffer (buffer = &ele_header, type = IGRBC, tag = my_id,
             display_att = &dis_attr, ele_spec_att = &esbc, range = gmrng,
             geometry = fit_mode ? NULL : &cv);

            dp$dispelem (msg = &msg_loc, buffer = &ele_header, mode = *dpmode, 
             dp_info = sp_info);
            }
          }
        py.num_points = 1;
        py.points = (double *) grpt;

        BSbx2 (&msg_loc, &py.num_points, (IGRpoint *)py.points, NULL,
         &gmrng[XMIN], &gmrng[XMAX]);

        dis_attr.weight += 2;
        dp$build_dis_buffer (buffer = &ele_header, type = IGRPS,
         display_att = &dis_attr, range = gmrng, tag = my_id,
         geometry = fit_mode ? NULL : &py);

        dp$dispelem (msg = &msg_loc, buffer = &ele_header, mode = *dpmode, 
         dp_info = sp_info);
        dis_attr.weight -= 2;
        break;

      default:
        stat_OM = om$send (msg = message SKgmhndlpt.GRdisyourself (msg,
                   mattyp, mat, dpmode, alt_symb, sp_info, key),
                   mode = OM_e_wrt_parent, targetid = my_id);
        break;
      }
    }

  return (stat_OM);
}

end implementation SKgmhndlpt;

