/*

This function will process the output from the surface-surface intersection
(the inters link-list), such that all xyz linestring data is replaced by
a cubic curve.

The input inters list is changed to contain the cubic xyz data, in place
of the original linestring data.

The uv data is not changed in any way. THERE WILL BE A MISMATCH BETWEEN THE
UV AND XYZ DATA TYPES (uv-linestring/xyz cubic curve) after this
processing.

HISTORY:

Recently:  SM	Creation.
08/27/92:  NP	Modified for ANSI compliance.
01/11/93:  WBC  Replaced the call to BSmdistptsf with a call to BSprptarrsf.
07/06/93:Sudha  Modified for BSprototypes ansification

*/

class implementation EMSsurface;

#include "EMS.h"
#include <string.h>
#include "OMmacros.h"
#include "dp.h"
#include "EMSopt.h"
#include "EMSprop.h"
#include "EMSbnddef.h"
#include "EMSbnd.h"
#include "emsdef.h"
#include "emsinterdef.h"
#include "emsinter.h"
#include "emssfintdef.h"
#include "emssfint.h"
#include "bserr.h"
#include "bsparameters.h"
#include "bsgeom_cvsf.h"
#include "bssfsfocvs.h"
#include "bststcvfarc.h"
#include "bssfptseval.h"
#include "bsprptarrsf.h"
#include "bsfreecv.h"
#include "bsdta_rducv.h"
#include "bsmdistptsf.h"
#include "bsrmdblpts.h"

#define WBC_USE_NEW_MATH 1

extern OMuword OPP_GR3dlinestr_class_id, OPP_GRbcsubbc_class_id,
               OPP_GAbcsubbc_class_id, OPP_GR3dcirarc_class_id,
               OPP_GA3dcirarc_class_id, OPP_GR3dcircle_class_id,
               OPP_GA3dcircle_class_id, OPP_EMSassoc_class_id,
               OPP_EMSlinedge_class_id, OPP_GA3dlinestr_class_id,
               OPP_GR3dlineseg_class_id, OPP_GA3dlineseg_class_id;

from EMSedge import EMgetpygeom, EMget_props, EMstroke_iso_edge;

#argsused

EMsfsfoutcv(IGRlong               *EMmsg,
            struct EMSinters      *inters,
            IGRushort              world_opts,
            struct GRvg_construct *const_args)
{
  IGRlong 		 sts = OM_S_SUCCESS, rc;
  struct EMSinters	*this_inters = NULL;
  struct EMSintobj	*this_intobj = NULL;
  struct EMSdataselect	*this_xyzdata = NULL, *ot_xyzdata = NULL, *this_uv1data = NULL, *this_uv2data = NULL;
  struct IGRbsp_curve	*this_xyzcurve = NULL, ***cvs = NULL, *mergecvbuffs = NULL, *mergedcv = NULL, *reducedcv = NULL, arc;
  struct GRid		*this_obj = NULL, *sf2_grid, *sf1_grid;
  struct IGRpolyline	 cvpoly, *this_uv1poly = NULL, *this_uv2poly = NULL, uv1poly, uv2poly;
  struct GRmd_env	*cvenv;
  struct EMSpartolbasis  partol1, partol2;
  struct BSgeom_bsp_surf geom_surface[2];
  IGRint		 i, j, num_cv_grps = 0, *num_cvs_per_grp = NULL, mergecvbuffsize = 0, num_pts;
  struct IGRbsp_surface *sf1, *sf2;
  IGRvector              left_tangent, right_tangent;
  IGRushort		 edprops = NULL;
  IGRboolean		 uvs_compatible = TRUE, is_arc, xyzcv_assoc, reduce_curve_data = FALSE, all_on_surf;
  IGRpoint               arcpoles[10], arc_center;
  IGRdouble              arcknots[10], arcweights[10], arc_rad, dist_tol;
  extern OMuint          OM_Gf_verbose_warning;
  extern void EFinit_geom_surface() ;

  *EMmsg = EMS_S_Success;

  cvpoly.num_points  = 0;
  cvpoly.points      = NULL;

  uv1poly.num_points = 0;
  uv1poly.points     = NULL;

  uv2poly.num_points = 0;
  uv2poly.points     = NULL;

  if(const_args && const_args->env_info)
    cvenv = const_args->env_info;

  arc.poles = (IGRdouble *) arcpoles;
  arc.knots = (IGRdouble *) arcknots;
  arc.weights = (IGRdouble *) arcweights;

#if WBC_USE_NEW_MATH
  geom_surface[0].sfgen_cv = NULL;
  geom_surface[1].sfgen_cv = NULL;
  num_pts = 1;
  BSEXTRACTPAR( &rc, BSTOLLENVEC, dist_tol );
#endif

  this_inters = inters;
  while(this_inters)
  {
    sf1 = (struct IGRbsp_surface *) this_inters->more_info;
    if(!sf1) goto skip_inters;
    sf1_grid = &this_inters->this_obj;

    sts = EFsspbtol_by_geom(EMmsg, sf1, &partol1.tol);
    if(!(1&*EMmsg&sts)) goto wrapup;
    partol1.is_valid = TRUE;

    this_intobj = this_inters->cvs;
    while(this_intobj)
    {
      xyzcv_assoc = FALSE;

      if(!this_intobj->other_intobj_node) goto skip_intobj;
      sf2 = (struct IGRbsp_surface *)
        this_intobj->other_intobj_node->this_obj_node->more_info;
      if(!sf2) goto skip_intobj;
      sf2_grid = &this_intobj->other_intobj_node->this_obj_node->this_obj;

      sts = EFsspbtol_by_geom(EMmsg, sf2, &partol2.tol);
      if(!(1&*EMmsg&sts)) goto wrapup;
      partol2.is_valid = TRUE;

      this_xyzdata = &this_intobj->this_xyzintobj;
      ot_xyzdata = &this_intobj->other_intobj_node->this_xyzintobj;

      this_uv1data = &this_intobj->this_uvintobj;
      if( (this_uv1data->datatype != EMSdata_object) &&
          (this_uv1data->datatype != EMSdata_poly2d)) goto skip_intobj;

      this_uv2data = &this_intobj->other_intobj_node->this_uvintobj;
      if( (this_uv2data->datatype != EMSdata_object) &&
          (this_uv2data->datatype != EMSdata_poly2d)) goto skip_intobj;

      switch(this_xyzdata->datatype)
      {
        case EMSdata_curve3d:
          if( (this_xyzdata->data.curve->order != 2) ||
              (this_xyzdata->data.curve->num_poles <= 2)) goto skip_intobj;
          break;

        case EMSdata_object:
        {
          int val0 = 0;
          this_obj = this_xyzdata->data.object;

          if( val0 = (om$is_objid_valid ( osnum = this_obj->osnum, objid = this_obj->objid ) == OM_S_SUCCESS) )
          {
            if( ! EFisAncestryValid(EMmsg, this_obj->objid, this_obj->osnum, OPP_GR3dlinestr_class_id, TRUE) )
            {
              goto skip_intobj;
            }
          }

          if(EFisAncestryValid(EMmsg, this_obj->objid, this_obj->osnum,
                               OPP_EMSassoc_class_id, TRUE)) xyzcv_assoc = TRUE;
          break;
        }
        case EMSdata_poly3d:
          if(this_xyzdata->data.poly->num_points <= 2) goto skip_intobj;
          break;

        default:
          goto skip_intobj;

      } /* switch(this_xyzdata->datatype) */

      uvs_compatible = TRUE;
      this_uv1poly = this_uv2poly = NULL;

      switch(this_uv1data->datatype)
      {
        case EMSdata_poly2d:
          this_uv1poly = this_uv1data->data.poly;
          break;

        case EMSdata_object:
        {
          this_obj = this_uv1data->data.object;
          if(uv1poly.points) om$dealloc(ptr = uv1poly.points);
          uv1poly.points = NULL;
          uv1poly.num_points = 0;

          if(!EFisAncestryValid(EMmsg, this_obj->objid, this_obj->osnum,
                                OPP_EMSlinedge_class_id, TRUE))
          {
            uvs_compatible = FALSE;
            edprops = NULL;
          }
          else
          {
            sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops),
                          senderid = NULL_OBJID,
                          targetid = this_obj->objid, targetos = this_obj->osnum);
            if(!(1&*EMmsg&sts)) goto wrapup;
          }

          if(edprops & EMED_ISO)
          {
            sts = om$send(msg = message EMSedge.EMstroke_iso_edge(EMmsg, NULL,
                                                                  NULL, NULL, sf1, FALSE, &partol1, this_obj->objid, &uv1poly,
                                                                  FALSE), senderid = NULL_OBJID,
                          targetid = this_obj->objid, targetos = this_obj->osnum);
            if(!(1&*EMmsg&sts)) goto wrapup;
            uvs_compatible = FALSE;
          }
          else
          {
            sts = om$send(msg = message EMSedge.EMgetpygeom(EMmsg, 0, MAXINT,
                                                            FALSE, NULL, &uv1poly, &partol1, NULL), senderid = NULL_OBJID,
                          targetid = this_obj->objid, targetos = this_obj->osnum);
            if(!(1&*EMmsg&sts)) goto wrapup;
          }
          this_uv1poly = &uv1poly;
        }
        break;

        default:
          goto skip_intobj;

      } /* switch(this_uv1data->datatype) */

      if(!this_uv1poly) goto skip_intobj;

      if(uvs_compatible)
      {
        switch(this_uv2data->datatype)
        {
          case EMSdata_poly2d:
            this_uv2poly = this_uv2data->data.poly;
            break;

          case EMSdata_object:
          {
            this_obj = this_uv2data->data.object;
            if(uv2poly.points) om$dealloc(ptr = uv2poly.points);
            uv2poly.points = NULL;
            uv2poly.num_points = 0;

            if(!EFisAncestryValid(EMmsg, this_obj->objid, this_obj->osnum,
                                  OPP_EMSlinedge_class_id, TRUE))
            {
              uvs_compatible = FALSE;
              edprops = NULL;
            }
            else
            {
              sts = om$send(msg = message EMSedge.EMget_props(EMmsg, &edprops),
                            senderid = NULL_OBJID,
                            targetid = this_obj->objid, targetos = this_obj->osnum);
              if(!(1&*EMmsg&sts)) goto wrapup;
              if(edprops & EMED_ISO) uvs_compatible = FALSE;
            }

            if(uvs_compatible)
            {
              sts = om$send(msg = message EMSedge.EMgetpygeom(EMmsg, 0, MAXINT,
                                                              FALSE, NULL, &uv2poly, &partol2, NULL),
                            senderid = NULL_OBJID,
                            targetid = this_obj->objid, targetos = this_obj->osnum);
              if(!(1&*EMmsg&sts)) goto wrapup;
              this_uv2poly = &uv2poly;
            }
          }
          break;

          default:
          {
            uvs_compatible = FALSE;
            break;
          }

        } /* switch(this_uv2data->datatype) */

      } /* if(uvs_compatible) */

      EFinit_geom_surface(EMmsg, sf1, sf1_grid->objid, sf1_grid->osnum,
                          &geom_surface[0]);
      if(!(1&*EMmsg)) goto wrapup;
      EFinit_geom_surface(EMmsg, sf2, sf2_grid->objid, sf2_grid->osnum,
                          &geom_surface[1]);
      if(!(1&*EMmsg)) goto wrapup;

      /* Generate the xyz data by evaluating the appropriate uv data. I am
         not using the xyz data from the inters list because the math function
         requires same number of points for both surfaces and the xyz data.
         If one of the uvs is a non order 2, then stroking it (to get points)
         does not guarantee the same number of points criterion. The only way
         to ensure that, is to evaluate the stroked points.

         If there are different number of points in the two uv spaces, use
         uv1->xyz->uv2 to ensure same number of points.
      */

      /* Generate xyz points. Re-use memory from previous loop.
       */
      if(cvpoly.num_points < this_uv1poly->num_points)
      {
        if(!cvpoly.points)
          cvpoly.points = (IGRdouble *) om$malloc(size = this_uv1poly->num_points * sizeof(IGRpoint));
        else
          cvpoly.points = (IGRdouble *) om$realloc(ptr=(IGRchar *)(cvpoly.points),
                                                   size = this_uv1poly->num_points * sizeof(IGRpoint));
      }
      EMerr_hndlr(!cvpoly.points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
      cvpoly.num_points = this_uv1poly->num_points;

      BSsfptseval(sf1, this_uv1poly->num_points, this_uv1poly->points,
                  cvpoly.points, &rc);

      EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

      /* Generate uv2 points if required.
       */
      if(!this_uv2poly) uvs_compatible = FALSE;
      else if(this_uv1poly->num_points != this_uv2poly->num_points)
        uvs_compatible = FALSE;

      if(!uvs_compatible)
      {
        IGRdouble base[3];
#if !WBC_USE_NEW_MATH
        IGRdouble dist;
#endif

        if(uv2poly.num_points < this_uv1poly->num_points)
        {
          if(!uv2poly.points)
            uv2poly.points = (IGRdouble *) om$malloc(size =
                                                     this_uv1poly->num_points * 2 * sizeof(IGRdouble));
          else
            uv2poly.points = (IGRdouble *) om$realloc(
              ptr  = (IGRchar *)(uv2poly.points),
              size = this_uv1poly->num_points * 2 *
              sizeof(IGRdouble));
        }
        EMerr_hndlr(!uv2poly.points, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
        uv2poly.num_points = this_uv1poly->num_points;

        for(i=0; i<this_uv1poly->num_points; i++)
        {
#if WBC_USE_NEW_MATH
          BSprptarrsf(&geom_surface[1], dist_tol, 2, 2, &num_pts,
                      &cvpoly.points[i*3], &uv2poly.points[i*2],
                      base, &all_on_surf, NULL, &rc);
          EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
#else
          (void) BSmdistptsf(&rc, sf2, &cvpoly.points[i*3],
                             &uv2poly.points[i*2], &uv2poly.points[i*2 + 1], base, &dist);
          EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
#endif
        }

        this_uv2poly = &uv2poly;

      } /* if(!uvs_compatible) */

      /* We now have consistent xyz, uv1 and uv2 data.
       */
      for(i=0; i<num_cv_grps; i++)
      {
        if(num_cvs_per_grp)
        {
          for(j=0; j<num_cvs_per_grp[i]; j++)
            if(cvs && cvs[i][j]) BSfreecv(&rc, cvs[i][j]);

          if(cvs && cvs[i]) om$dealloc(ptr = cvs[i]);
          cvs[i] = NULL;
          om$dealloc(ptr = num_cvs_per_grp);
          num_cvs_per_grp = NULL;
        }
      }
      if(cvs) om$dealloc(ptr = cvs);
      cvs = NULL;
      num_cv_grps = 0;

      {
        IGRpoint *junkptr1;

        junkptr1 = (IGRpoint *) cvpoly.points;
/*********
           (void) BSsfsfoutcv(sf1, sf2, 1, &cvpoly.num_points, &junkptr1,
                  &this_uv1poly->points, &this_uv2poly->points, &num_cv_grps,
                  &num_cvs_per_grp, &cvs, &rc);
*********/
        //HF: 03/23/2001 - Added for TR# MP4842 +++++
        //For whatever reason, the parameter-values are messed up
        for(i=0; i< cvpoly.num_points; i++)
        {
          IGRdouble base[3];
          IGRdouble dist;
          (void) BSmdistptsf(&rc, sf2, &cvpoly.points[i*3],
                             &uv2poly.points[i*2], &uv2poly.points[i*2 + 1], base, &dist);
          EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
        }
        //HF: 03/23/2001 - Added for TR# MP4842 -----
        (void) BSsfsfocvs(&geom_surface[0], &geom_surface[1], 1,
                          (IGRint *)&cvpoly.num_points, &junkptr1,
                          (BSpair **)&this_uv1poly->points, (BSpair **)&this_uv2poly->points, &num_cv_grps,
                          &num_cvs_per_grp, &cvs, &rc);

        EMerr_hndlr(rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

        /* We should get back only 1 group. This group may contain multiple
           curves.
        */
        EMerr_hndlr(num_cv_grps!=1, *EMmsg, EMS_E_BSerror, wrapup);
        EMerr_hndlr(!num_cvs_per_grp[0], *EMmsg, EMS_E_BSerror, wrapup);
      }

      /* In case of multiple curves in a group, merge the curves so as to output
         only one curve in the inters list.
      */
      if(mergedcv) BSfreecv(&rc, mergedcv);
      mergedcv = NULL;
      if(reducedcv) BSfreecv(&rc, reducedcv);
      reducedcv = NULL;

      if(num_cvs_per_grp[0] > 1)
      {
        /* Following is required because of data type inconsistency
           between BSsfsfoutcv and EFmerge_curves. I wish to call EFmerge_curves
           so as to keep all mergings in one central place.
        */
        if(mergecvbuffsize < num_cvs_per_grp[0])
        {
          if(!mergecvbuffs)
            mergecvbuffs = (struct IGRbsp_curve *) om$malloc(size =
                                                             num_cvs_per_grp[0] * sizeof(struct IGRbsp_curve));
          else
            mergecvbuffs = (struct IGRbsp_curve *) om$realloc(
              ptr  = (IGRchar *)mergecvbuffs,
              size = num_cvs_per_grp[0] * sizeof(struct IGRbsp_curve));
          EMerr_hndlr(!mergecvbuffs, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
          mergecvbuffsize = num_cvs_per_grp[0];
        }

        for(i=0; i<num_cvs_per_grp[0]; i++)
          mergecvbuffs[i] = cvs[0][i][0];

        sts = EFmerge_curves(num_cvs_per_grp[0], NULL, mergecvbuffs, NULL_OBJID,
                             &mergedcv, FALSE, EMmsg);
        if(!(1&*EMmsg&sts)) goto wrapup;
        EMerr_hndlr(!mergedcv, *EMmsg, EMS_E_Fail, wrapup);

      } /* if(num_cvs_per_grp[0] > 1) */

      else
      {
        mergedcv = cvs[0][0];
        cvs[0][0] = NULL;
      }

      /* Reduce the data of the fitted curve. The BSsfsfoutcv creates a curve
         which has more poles (as much as twice) than the number of points
         in the original linestring.
      */
      if(reduce_curve_data)
      {
        BSdta_rducv(mergedcv, 1, 1, left_tangent, right_tangent,
                    0, NULL, NULL, NULL, NULL, NULL,
                    NULL, &reducedcv, &rc);
        if(rc != BSSUCC)
        {
          reducedcv = mergedcv;
          mergedcv = NULL;
        }
      }
      else
      {
        reducedcv = mergedcv;
        mergedcv = NULL;
      }

      /* Replace the xyz data in this node of the inters list with the newly
         generated curve.
      */
      if(this_xyzdata->datatype == EMSdata_curve3d)
      {
        this_xyzcurve = this_xyzdata->data.curve;

        if(this_xyzcurve->num_poles < reducedcv->num_poles)
          this_xyzcurve->poles = (IGRdouble *) om$realloc(
            ptr  = (IGRchar *)(this_xyzcurve->poles),
            size = reducedcv->num_poles * sizeof(IGRpoint));

        if(this_xyzcurve->num_knots < reducedcv->num_knots)
          this_xyzcurve->knots = (IGRdouble *) om$realloc(
            ptr  = (IGRchar *)(this_xyzcurve->knots),
            size = reducedcv->num_knots * sizeof(IGRdouble));
        EMerr_hndlr(!this_xyzcurve->poles || !this_xyzcurve->knots, *EMmsg,
                    EMS_E_NoDynamicMemory, wrapup);

        OM_BLOCK_MOVE(reducedcv->poles, this_xyzcurve->poles,
                      reducedcv->num_poles * sizeof(IGRpoint));
        OM_BLOCK_MOVE(reducedcv->knots, this_xyzcurve->knots,
                      reducedcv->num_knots * sizeof(IGRdouble));

        this_xyzcurve->order = reducedcv->order;
        this_xyzcurve->periodic = reducedcv->periodic;
        this_xyzcurve->non_uniform = reducedcv->non_uniform;
        this_xyzcurve->num_poles = reducedcv->num_poles;
        this_xyzcurve->num_knots = reducedcv->num_knots;
        this_xyzcurve->planar = reducedcv->planar;
        this_xyzcurve->phy_closed = reducedcv->phy_closed;
        this_xyzcurve->num_boundaries = 0;
        this_xyzcurve->bdrys = NULL;

        if(reducedcv->rational && reducedcv->weights)
        {
          if(!this_xyzcurve->weights ||
             (this_xyzcurve->num_poles < reducedcv->num_poles))
          {
            if(!this_xyzcurve->weights)
              this_xyzcurve->weights = (IGRdouble *) om$malloc(size =
                                                               reducedcv->num_poles * sizeof(IGRdouble));
            else
              this_xyzcurve->weights = (IGRdouble *) om$realloc(size =
                                                                reducedcv->num_poles * sizeof(IGRdouble),
                                                                ptr = (IGRchar *)(this_xyzcurve->weights));
            EMerr_hndlr(!this_xyzcurve->weights, *EMmsg, EMS_E_NoDynamicMemory,
                        wrapup);
          }
          OM_BLOCK_MOVE(reducedcv->weights, this_xyzcurve->weights,
                        reducedcv->num_poles * sizeof(IGRdouble));
          this_xyzcurve->rational = reducedcv->rational;
        }
        else
        {
          if(this_xyzcurve->weights) om$dealloc(ptr = this_xyzcurve->weights);
          this_xyzcurve->weights = NULL;
          this_xyzcurve->rational = FALSE;
        }
      }
      else if(this_xyzdata->datatype == EMSdata_object)
      {
        OMuword constclass;

        this_obj = (struct GRid *) om$malloc(size = sizeof(struct GRid));
        EMerr_hndlr(!this_obj, *EMmsg, EMS_E_NoDynamicMemory, wrapup);
        this_obj->osnum = cvenv->md_id.osnum;

        /* Came here only if the existing curve was linear. Need to replace
           it with a general curve (GRbcsubbc). However, check if the
           resulting curve is an arc/partial arc as a special case. Do not
           error out all the way if problem in BStstcvfarc.
        */
        is_arc = FALSE;
        if(reducedcv->order != 2)
          BStstcvfarc(reducedcv, &is_arc, arc_center, &arc_rad, &arc, &rc);

        if(is_arc)
        {
          const_args->geometry = (IGRchar *) &arc;
          if(is_arc == 2)
            constclass = xyzcv_assoc ? OPP_GA3dcircle_class_id
              : OPP_GR3dcircle_class_id;
          else
            constclass = xyzcv_assoc ? OPP_GA3dcirarc_class_id
              : OPP_GR3dcirarc_class_id;
        }
        else
        {
          const_args->geometry = (IGRchar *) reducedcv;
          if((reducedcv->order == 2) && !reducedcv->rational)
          {
            if(reducedcv->num_poles > 2)
              constclass = xyzcv_assoc ? OPP_GA3dlinestr_class_id
                : OPP_GR3dlinestr_class_id;
            else
              constclass = xyzcv_assoc ? OPP_GA3dlineseg_class_id
                : OPP_GR3dlineseg_class_id;

          }
          else
            constclass = xyzcv_assoc ? OPP_GAbcsubbc_class_id
              : OPP_GRbcsubbc_class_id;
        }

        sts = om$construct(osnum = this_obj->osnum, p_objid = &this_obj->objid,
                           classid = constclass,
                           msg = message GRgraphics.GRconstruct(const_args));
        const_args->geometry = NULL;
        if(!(1&*EMmsg&sts)) goto wrapup;

        /* Delete the existing object. During recompute the constructed object
           is not yet posted in the Rtree when this function is called. The
           result gets posted AFTER recompute is done. Mark the object as
           not being in the Rtree so that GRdelete called while freeing the
           dataselect does not fail. This condition is indicated by the module
           id being NULL_OBJID in the construct list. It is assumed that the
           construct list for the replacement curve and the original linestring
           is the SAME.
           SM 09/30/92.
        */
        if(const_args->env_info &&
           (const_args->env_info->md_id.objid == NULL_OBJID))
        {
          IGRshort action = 1, props = GRNOT_IN_RTREE;

          sts = om$send(msg = message GRgraphics.GRchgprops(EMmsg, &action,
                                                            &props), targetid = this_xyzdata->data.object->objid,
                        targetos = this_xyzdata->data.object->osnum,
                        senderid = NULL_OBJID);
        }
        EMdataselect_data_free(EMmsg, this_xyzdata, 1);
        if(!(1&*EMmsg)) goto wrapup;

        this_xyzdata->datatype = EMSdata_object;
        this_xyzdata->data.object = this_obj;
        ot_xyzdata->datatype = EMSdata_object;
        ot_xyzdata->data.object = this_obj;
        this_obj = NULL;
      }
      else if(this_xyzdata->datatype == EMSdata_poly3d)
      {
        this_xyzcurve = (struct IGRbsp_curve *) om$malloc(size =
                                                          sizeof(struct IGRbsp_curve));
        EMerr_hndlr(!this_xyzcurve, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

        *this_xyzcurve = *reducedcv;
        this_xyzcurve->poles = NULL;
        this_xyzcurve->knots = NULL;
        this_xyzcurve->weights = NULL;

        this_xyzcurve->poles = (IGRdouble *) om$malloc(size =
                                                       reducedcv->num_poles * sizeof(IGRpoint));
        this_xyzcurve->knots = (IGRdouble *) om$malloc(size =
                                                       reducedcv->num_knots * sizeof(IGRdouble));
        EMerr_hndlr(!this_xyzcurve->poles || !this_xyzcurve->knots, *EMmsg,
                    EMS_E_NoDynamicMemory, wrapup);
        OM_BLOCK_MOVE(reducedcv->poles, this_xyzcurve->poles,
                      reducedcv->num_poles * sizeof(IGRpoint));
        OM_BLOCK_MOVE(reducedcv->knots, this_xyzcurve->knots,
                      reducedcv->num_knots * sizeof(IGRdouble));

        if(reducedcv->rational && reducedcv->weights)
        {
          this_xyzcurve->weights = (IGRdouble *) om$malloc(size =
                                                           reducedcv->num_poles * sizeof(IGRdouble));
          EMerr_hndlr(!this_xyzcurve->weights, *EMmsg, EMS_E_NoDynamicMemory,
                      wrapup);
          OM_BLOCK_MOVE(reducedcv->weights, this_xyzcurve->weights,
                        reducedcv->num_poles * sizeof(IGRdouble));
        }

        EMdataselect_data_free(EMmsg, this_xyzdata, 1);
        if(!(1&*EMmsg)) goto wrapup;

        this_xyzdata->datatype = EMSdata_curve3d;
        this_xyzdata->data.curve = this_xyzcurve;
        ot_xyzdata->datatype = EMSdata_curve3d;
        ot_xyzdata->data.curve = this_xyzcurve;
        this_xyzcurve = NULL;

      } /* else if(this_xyzdata->datatype == EMSdata_poly3d) */

skip_intobj:
      this_intobj = this_intobj->next;

    } /* while(this_intobj) */

skip_inters:
    this_inters = this_inters->next;

  } /* while(this_inters) */

wrapup:
  if(cvpoly.points)  om$dealloc(ptr = cvpoly.points);
  if(uv1poly.points) om$dealloc(ptr = uv1poly.points);
  if(uv2poly.points) om$dealloc(ptr = uv2poly.points);
  if(mergecvbuffs)   om$dealloc(ptr = mergecvbuffs);
  if(mergedcv)  BSfreecv(&rc, mergedcv);
  if(reducedcv) BSfreecv(&rc, reducedcv);

  for(i=0; i<num_cv_grps; i++)
  {
    if(num_cvs_per_grp)
    {
      for(j=0; j<num_cvs_per_grp[i]; j++)
        if(cvs && cvs[i][j]) BSfreecv(&rc, cvs[i][j]);
      if(cvs && cvs[i]) om$dealloc(ptr = cvs[i]);
      cvs[i] = NULL;
      om$dealloc(ptr = num_cvs_per_grp);
      num_cvs_per_grp = NULL;
    }
  }
  if(cvs) om$dealloc(ptr = cvs);
  cvs = NULL;
  num_cv_grps = 0;

#if WBC_USE_NEW_MATH
  if (geom_surface[0].sfgen_cv)
    BSfreecv(&rc, geom_surface[0].sfgen_cv);
  if (geom_surface[1].sfgen_cv)
    BSfreecv(&rc, geom_surface[1].sfgen_cv);
#endif

/* Intentaionally not returning any errors. In case of problems, the original
   intersection can still be output, which is no worse than the absence of
   this function. Printing out the error code for informational purpose.
*/
  EMWRAPUP(*EMmsg, sts, "EMsfsfoutcv");
  if(!(1&*EMmsg&sts))
  {
    *EMmsg = EMS_I_Fail;
    sts = OM_S_SUCCESS;
  }

  return(sts);
}

end implementation EMSsurface;
