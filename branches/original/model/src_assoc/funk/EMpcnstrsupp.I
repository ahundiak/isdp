class implementation EMScnstr;

#include <string.h>
#include "OMmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "gotextdef.h"
#include "cotxmacros.h"
#include "DIdef.h"
#include "dimdef.h"
#include "dimdload.h"
#include "dim.h"
#include "dimmacros.h"
#include "bserr.h"
#include "EMSasopts.h"
#include "matrnmx.h"
#include "mamulmx.h"
#include "mainvmx.h"
#include "bsplanar2.h"
#include "bsnorvec.h"

#define X 0
#define Y 1
#define Z 2

#define TEXT_HEIGHT_FACTOR 1.1

#define PLANAR_CODE 3

from EMSparamgm import EMgetgeom;

extern GRclassid OPP_EMSsubbs_class_id, OPP_GRcurve_class_id;

/*

Name
  EMcnstrtext

Abstract

Synopsis

Description
    This function places constraint-text handles using defaults. The
    text can be simply displayed or it may be placed as an object.
    In the latter case (non-NULL textid argument), no display is performed.

    The text is placed in a row vertically below the origin in a "row"
    whose number is indicated by row_index.

Return Value

Notes

Index

Keywords
  3D constraint, text

History
  06/24/91 : Siki : created
  06/01/93 : Sudha : modified to handle BSprototypes
  07/28/93 : Rajiv Agrawal : reversed the z-axis (TR11924895).  added std header.

 */

void EMcnstrtext (msg, opts, md_env, text,
                  origin, zaxis, xaxis, row_index,
                  textid)
IGRlong 	*msg;
IGRushort 	opts;
struct GRmd_env *md_env;
IGRchar 	*text;
IGRpoint 	origin;
IGRvector 	zaxis, xaxis;
IGRint 		row_index;
struct GRid 	*textid;
{
  IGRshort 		level, lenstr, four=4;
  IGRint 		dum, moredum, tsymbsz=sizeof (struct GRdpb_text_symb);
  IGRlong		stat_OM, msg_loc;
  IGRdouble 		*rot_mat;
  IGRpoint 		loc_origin;
  IGRmatrix 		inv_mat, store_mat1, store_mat2;
  struct IGRdisplay 	text_display;
  struct GRdpb_text_symb text_symb;
  struct DMenv_param 	dm_env_param;
  void 			SKgetmat();

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  stat_OM = dm$get_dim_param (type = DM_ENV_PARAM, p_data = &dm_env_param);
  EMerr_hndlr (EMSerror (stat_OM), *msg, EMS_E_Fail, ret_end);

  stat_OM = gr$get_text_symb (msg = &msg_loc,
		             sizbuf = &tsymbsz,
		             buffer = &text_symb, nret = &dum);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

  text_symb.Active_font = dm_env_param.text_font;
  text_symb.Active_height = dm_env_param.txt_heig;
  text_symb.Active_width = dm_env_param.txt_widt;

  dum = sizeof (struct IGRdisplay);
  gr$get_active_display (msg = &msg_loc, sizbuf = &dum,
                         buffer = &text_display, nret = &moredum);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
  text_display.color++;
  text_display.weight++;

  dum = sizeof (IGRshort);
  gr$get_active_level (msg = &msg_loc, sizbuf = &dum,
                       buffer = &level, nret = &moredum);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  /*
   * Reverse the direction of z-axis so that the constraint text is visible
   * from the front.  (Rajiv 7/28/93)
   */
  zaxis [0] = -zaxis [0];
  zaxis [1] = -zaxis [1];
  zaxis [2] = -zaxis [2];
  
  SKgetmat (&msg_loc, NULL, zaxis, xaxis, NULL, store_mat1);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

  if (md_env->md_env.matrix_type != MAIDMX)
  {
    MAinvmx (&msg_loc, &four, md_env->md_env.matrix, inv_mat);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    MAmulmx (&msg_loc, &four, &four, &four, store_mat1, inv_mat,
     store_mat2);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

    rot_mat = store_mat2;
  }
  else
    rot_mat = store_mat1;

  OM_BLOCK_MOVE (origin, loc_origin, sizeof (IGRpoint));
  loc_origin[Y] -= (text_symb.Active_height * TEXT_HEIGHT_FACTOR) * row_index;

  lenstr = strlen (text);
  stat_OM = co$place_text (msg = &msg_loc, 
                           text_string = text, text_length = &lenstr, 
                           origin = loc_origin, rot_matrix = rot_mat,
                           ActiveDisplay = &text_display,
                           ActiveLevel = level,
                           ActiveAngle = 0.0,
                           ModuleInfo = md_env,
                           TextSymb = &text_symb,
                           flags = opts & EMScnstr_display ? GRTX_DISPLAY : NULL,
                           classname = "EMScnstrtxt",
                           buffer = textid);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

ret_end:
  EMWRAPUP (*msg, stat_OM, "EMcnstrtext");
  return;
}


/*

Name
  EMgetdrivgeom

Abstract

Synopsis

Description
    This function returns a specified geometry from the parent/child side
    of the relation.

Return Value

Notes

Index

Keywords
  3D constraints
  
History
  06/24/92 : Siki : creation
  07/28/93 : Rajiv Agrawal : added std. doc header
  10/18/93 : GMK  : TR # 119300049   
 */

IGRlong EMgetdrivgeom (msg, opts, mattyp, mat, nodeid, parent_geom, geomtype,
                       geom)
IGRlong *msg;
IGRushort opts;
IGRshort *mattyp;
IGRmatrix mat;
struct GRid *nodeid;
IGRboolean parent_geom;
IGRint geomtype;
struct EMSgeomdata *geom;
{
  IGRboolean stat_func, found;
  IGRchar *vggeom;
  IGRshort geommattyp, four=4;
  IGRint i, j, count, ndchktype, planar_code;
  IGRlong msg_loc, stat_OM;
  IGRdouble *dptr, *refmat;
  IGRvector plane_vec;
  IGRmatrix geommat;
  GRclassid objclass;
  struct GRmd_env md_env;
  struct ret_struct ret_struct;
  struct GRid geomid;
  struct IGRbsp_surface *srf;
  struct EMSgeomdata gmdata;
  enum EMSdatatype dattyp;
  OM_S_CHANSELECT chan_to_geom;

  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  vggeom = NULL;

  geom->geomtype = GEOMDATA_NULL;

  if ((md_env.md_env.matrix_type = *mattyp) != MAIDMX)
    OM_BLOCK_MOVE (mat, md_env.md_env.matrix, sizeof (IGRmatrix));
  stat_func = ex$get_modid (mod_osnum = OM_Gw_current_OS, 
               mod_id = &md_env.md_id.objid);
  EMerr_hndlr (EMSerror (stat_func), stat_func, FALSE, ret_end);
  md_env.md_id.osnum = OM_Gw_current_OS;

  if (parent_geom)
    EMmake_chanselect (NDfather_father, &chan_to_geom);
  else
    EMmake_chanselect (NDchildren_children, &chan_to_geom);

  count = 0;
  om$get_channel_count (objid = nodeid->objid, osnum = nodeid->osnum,
   p_chanselect = &chan_to_geom, count = (OMuint *) &count);

  found = FALSE;
  if (geomtype)
  {
    if (geomtype == GEOMDATA_POINT)
      ndchktype = point_generic;
    else if (geomtype == GEOMDATA_VECTOR || geomtype == GEOMDATA_LINE)
      ndchktype = line_generic;
    else if (geomtype == GEOMDATA_PLANE || geomtype == GEOMDATA_COORD)
      ndchktype = ref_generic;
    else
      ndchktype = NULL;
  }
  else
    ndchktype = point_generic | line_generic | ref_generic;

  found = FALSE;
  for (i=0; i<count; i++)
  {
    msg_loc = EMS_E_Fail;
    ret_struct.type = NULL;
    if (opts & EMSsolve_minimum &&
        geomtype == GEOMDATA_VECTOR)
    {
      /*
       * If the option to return minimal geometry is set, then in some specific
       * cases, special things can be done. Currently only vectors are
       * acceptable through this call.
       */

      gmdata.geomtype = GEOMDATA_NULL;
      om$send (msg = message EMSparamgm.EMgetgeom (&msg_loc, NULL,
       mattyp, mat, &gmdata), p_chanselect = &chan_to_geom, from = i, to = i,
       senderid = nodeid->objid);

      if (gmdata.geomtype == GEOMDATA_VECTOR)
        {
        dptr = ret_struct.var.line_st.p0;
        for (j=X; j<=Z; j++)
          dptr[j] = 0.0;
        dptr = ret_struct.var.line_st.p1;
        OM_BLOCK_MOVE (gmdata.vector, dptr, sizeof (IGRvector));
        ret_struct.type = line_generic;
      }
    }
    else
    {
      /*
       * Try to obtain geometry via the ND-protocol. Only, points,
       * lines and plane (ref-sys/plane-matrix) types are acceptable
       * through this call.
       */

      om$send (msg = message NDnode.NDgive_structure (&msg_loc, &ret_struct,
       &md_env), p_chanselect = &chan_to_geom, from = i, to = i,
       senderid = nodeid->objid);
    }

    if (!EMSerror (msg_loc) &&
        ret_struct.type & ndchktype)
    {
      if (ret_struct.type & point_generic)
      {
        geom->geomtype = GEOMDATA_POINT;
        OM_BLOCK_MOVE (ret_struct.var.point_st.pt, geom->point,
         sizeof (IGRpoint));
      }
      else if (ret_struct.type & line_generic)
      {
        if (geomtype == GEOMDATA_VECTOR)
        {
          geom->geomtype = geomtype;
          for (i=0; i<3; i++)
            geom->vector[i] = ret_struct.var.line_st.p1[i] -
                               ret_struct.var.line_st.p0[i];
          BSnorvec (&msg_loc, geom->vector);
        }
        else
        {
          geom->geomtype = GEOMDATA_LINE;
          dptr = geom->line.igr_line.point1 = geom->line.line_pt1;
          OM_BLOCK_MOVE (ret_struct.var.line_st.p0, dptr, sizeof (IGRpoint));
          dptr = geom->line.igr_line.point2 = geom->line.line_pt2;
          OM_BLOCK_MOVE (ret_struct.var.line_st.p1, dptr, sizeof (IGRpoint));
        }
      }
      else
      {
        refmat = ret_struct.var.ref_st.t;
        MAtrnmx (&msg_loc, &four, refmat, refmat);

        dptr = geom->plane.igr_plane.point = geom->plane.plane_pt;
        dptr[X] = refmat[XORIG_PLANEMAT_INX];
        dptr[Y] = refmat[YORIG_PLANEMAT_INX];
        dptr[Z] = refmat[ZORIG_PLANEMAT_INX];
        dptr = geom->plane.igr_plane.normal = geom->plane.plane_vec;
        OM_BLOCK_MOVE (&refmat[ZAXIS_PLANEMAT_INX], dptr,
         sizeof (IGRvector));
  
        if (geomtype == GEOMDATA_COORD)
        {
          geom->geomtype = geomtype;
          OM_BLOCK_MOVE (&refmat[XAXIS_PLANEMAT_INX], geom->vector,
           sizeof (IGRvector));
        }
        else
          geom->geomtype = GEOMDATA_PLANE;
      }
      found = TRUE;
    }
    else
    {
      geomid.objid = NULL_OBJID;
      geommattyp = *mattyp;
      OM_BLOCK_MOVE (mat, geommat, sizeof (IGRmatrix));
      om$send (msg = message NDnode.ASreturn_go (&geomid, &geommattyp,
       geommat), p_chanselect = &chan_to_geom, from = i, to = i,
       senderid = nodeid->objid);

      om$get_classid (objid = geomid.objid, osnum = geomid.osnum,
       p_classid = &objclass);
      if (!IF_NULL_OBJID (geomid.objid) &&
          (om$is_ancestry_valid (subclassid = objclass, 
            superclassid = OPP_EMSsubbs_class_id) == OM_S_SUCCESS ||
           om$is_ancestry_valid (subclassid = objclass, 
            superclassid = OPP_GRcurve_class_id) == OM_S_SUCCESS))
      {
        EMgetvggeom (&msg_loc, &geommattyp, geommat, &geomid, &vggeom,
         &dattyp);
        EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

        if (dattyp == EMSdata_curve3d &&
            (!geomtype || geomtype == GEOMDATA_CURVE))
        {
          geom->geomtype = GEOMDATA_CURVE;
          geom->curve = (struct IGRbsp_curve *) vggeom;
          vggeom = NULL;
          found = TRUE;
        }
        else if (dattyp == EMSdata_surface &&
                 (!geomtype || geomtype == GEOMDATA_SURFACE))
        {
          srf = (struct IGRbsp_surface *) vggeom;
          if (srf->planar && !geomtype)
          {
            BSplanar2 (srf->u_num_poles * srf->v_num_poles,
             (IGRpoint *)srf->poles, srf->weights, &planar_code, plane_vec, &msg_loc);
            EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
            if (planar_code == PLANAR_CODE)
            {
              geom->geomtype = GEOMDATA_PLANE;
              dptr = geom->plane.igr_plane.point = geom->plane.plane_pt;
              if (srf->rational)
                for (i=X; i<=Z; i++)
                  dptr[i] = srf->poles[i] / srf->weights[0];
              else
                OM_BLOCK_MOVE (srf->poles, dptr, sizeof (IGRpoint));
              dptr = geom->plane.igr_plane.normal = geom->plane.plane_vec;
              OM_BLOCK_MOVE (plane_vec, dptr, sizeof (IGRvector));
              found = TRUE;
            }
          }

          if (!found)
          {
            geom->geomtype = GEOMDATA_SURFACE;
            geom->surface = (struct IGRbsp_surface *) vggeom;
            vggeom = NULL;
            found = TRUE;
          }
        }
        /*
         * TR # 119300049 -- commented to go for forloop if it fails here-GMK
         * else
         *  {EMerr_hndlr (TRUE, *msg, EMS_E_InvalidCase, ret_end);} 
         */
      }
    }

    if (found)
      break;
  }
  EMerr_hndlr (!found, *msg, EMS_I_NotFound, ret_end);

ret_end:
  if (vggeom)
    om$dealloc (ptr = vggeom);

  EMWRAPUP (*msg, stat_OM, "EMgetdrivgeom");
  return (stat_OM);
}

end implementation EMScnstr;

