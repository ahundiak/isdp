/* ###################   APOGEE COMPILED   ################## */
/*
 Description
        
 This method extracts one or more constant parameter curves of
 a surface and optionally clips these curve to the surface's
 boundaries, if any.

 Arguments

 mattyp             Module environment matrix type.
 mat                Matrix to convert to world coordinates
                    from the environment of this object.
 const_args         Non-geometric data for construction.
 trim_to_boundaries Flag indicating whether or not the the extracted
                    curves are to be trimmed to the surface's boundaries.
 numparms           Number of parameters being passed in, at
                    which the isoparametric curves are to
                    extracted. (# of parms, below).
 parms[]            The array of parameters.
 in_udir            Whether the constant parameter(s) apply
                    in the U-direction (TRUE) or in the
                    V-direction (FALSE).
 msg                Return code.
                     - MSSUCC if all was well.
                     - MSINARG if invalid arguments
                     - MANOMEMORY if memory allocation failed.   
                     - MSFAIL on any other error.
 number_of_curves   The number of curves that were constructed.
 curves             The object id's of the constructed curves.
        
 History

 SS  : 09/30/86 : Design date.
 rlw : 11/19/87 : Changed to construct curve in object space
                  specified in construct list.
 rlw : 02/24/88 : Modified to output more intelligent class curves.
 rlw : 06/03/88 : Modified classification scheme for curves.  Since
                  Allen has added srf of rev cylinders, cones, etc.
                  this logic is broken.  Also Siki needed a function
                  for model space counterparts.
 rlw : 11/23/88 : Added additional argument to support trimming the
                  iso curves to the existing loopset.  This also requires
                  that the method allocate space for the curve ids since
                  the number required cannot, in general, be known ahead
                  of time.  Modified method name due to above mentioned
                  changes.
 rlw : 02/16/88 : Modified trim options to specify boundary as area.
 DLB : 10/23/91 : Call BSconstprcv with short options not long options.
		  SUN problem.
 NP  : 08/25/92 : Modified for ANSI compliance. Added typecasts, changed var. types.
 */

class implementation EMSsubbs;

extern OMuword OPP_GR3dcirarc_class_id;
extern OMuword OPP_GR3dcircle_class_id;
extern OMuword OPP_GR3dellarc_class_id;
extern OMuword OPP_GR3dellipse_class_id;
extern OMuword OPP_GR3dlineseg_class_id;
extern OMuword OPP_GR3dlinestr_class_id;
extern OMuword OPP_GRbcsubbc_class_id;

extern OMuword OPP_EMScone_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMStorus_class_id;
extern OMuword OPP_EMSsphere_class_id;
extern OMuword OPP_EMSelpcone_class_id;
extern OMuword OPP_EMSelpcyl_class_id;
extern OMuword OPP_EMSelpsoid_class_id;
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMSrevol_class_id;

#include "EMS.h"
#include "gocmacros.h"		/* GRgetabsg macro  */
#include "msdef.h"		/* MSSUCC */
#include "maerr.h"		/* MANOMEMORY */
#include "bserr.h"		/* BSSUCC */
#include "EMSmsgdef.h"		/* EMS error return codes */
#include "EMSprop.h"		/* EMLS_NATURAL */
#include "emsinterdef.h"	/* Trim options */

from EMSloopset import EMget_props, EMlsparttrim;

method EMisoparcvs(
 IGRlong	*msg; 
 IGRshort	*mattyp; 
 IGRmatrix	mat;
 struct		GRvg_construct *const_args; 
 IGRboolean	trim_to_boundaries;
 IGRint		numparms;
 IGRdouble	parms[]; 
 IGRboolean	in_udir;
 IGRlong	*number_of_curves;
 GRobjid	**curves)
{
 IGRlong		i;
 GRclassid		classid, clipped_classid;
 OM_S_CHANSELECT	to_my_loopset;
 IGRdouble		low, hig;
 struct			IGRbsp_curve *isocrv[2];
 struct			IGRbsp_surface *srf;
 struct			EMSpartolbasis partolbasis;
/*
 * Initialize
 */
 *msg = MSSUCC;
 isocrv[0] = NULL;
 isocrv[1] = NULL;
 *number_of_curves = 0;
 *curves = NULL;
/*
 * Get the abstract geometry
 * buffer.
 */
 GRgetabsg(
   msg,
   mattyp,
   mat,
   (IGRchar **)&srf,
   i);
  if (! (1 & *msg)) goto wrapup;
/*
 * Try and make an intelligent decision about
 * which class to create for the iso curve(s).
 */
 {
  OMuword	u_direction_classid, v_direction_classid, surface_classid;
  IGRlong	sts, EFclassify_iso_curve();

  sts = om$get_classid(
    object = me,
    p_classid = &surface_classid);
   if (! (1 & sts))
    {
     *msg = MSFAIL;
     goto wrapup;
    }
  sts = EFclassify_iso_curve(
    surface_classid,
    srf,
    &u_direction_classid,	/* Constant u - varying v */
    &v_direction_classid,	/* Constant v - varying u */
    msg);
   if (! (1 & *msg)) goto wrapup;
  if (in_udir)
   classid = u_direction_classid;
  else
   classid = v_direction_classid;
 }
/*
 * Determine if trimming is required
 */
 if (trim_to_boundaries)
  {
   IGRushort 		loopset_properties;
   IGRlong		EMmsg, sts;

   to_my_loopset.type = OM_e_addr;
   to_my_loopset.u_sel.addr = &me->to_loopset; 
   loopset_properties = EMLS_NATURAL;
   sts = om$send(
     msg = message EMSloopset.EMget_props(
      &EMmsg,
      &loopset_properties),
     p_chanselect = &to_my_loopset);
    if (! (1 & sts))
     {
      *msg = MSFAIL;
      goto wrapup;
     }
   if (loopset_properties & EMLS_NATURAL)
    trim_to_boundaries = FALSE;
/*
 * If we are going to trim then we need to
 * set up some stuff for the trimming.
 */
   else
    {
     extern	void BSsfkttol2();
     IGRlong	loc_msg;

     BSsfkttol2(
       srf->u_order,
       srf->v_order,
       srf->u_knots,
       srf->v_knots,
       srf->u_num_poles,
       srf->v_num_poles,
       srf->poles,
       srf->weights,
       &partolbasis.tol,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     partolbasis.is_valid = TRUE;
     partolbasis.in_world = TRUE;
     partolbasis.mattyp = mattyp;
     partolbasis.mat = (IGRdouble *) mat;
     if (classid == OPP_GR3dcircle_class_id)
      clipped_classid = OPP_GR3dcirarc_class_id;
     else if (classid == OPP_GR3dellipse_class_id)
      clipped_classid = OPP_GR3dellarc_class_id;
     else
      clipped_classid = classid;
     if (in_udir)
      {
       low = srf->v_knots[srf->v_order - 1];
       hig = srf->v_knots[srf->v_num_poles];
      }
     else
      {
       low = srf->u_knots[srf->u_order - 1];
       hig = srf->u_knots[srf->u_num_poles];
      }
    } /* if (loopset_properties & EMLS_NATURAL) */
  } /* if (trim_to_boundaries) */
/*
 * Allocate space for the
 * isocurves. This space shared by
 * all isocurves to be created.
 */
 {
  extern	void BSalloccv();
  IGRshort	order;
  IGRlong	num_poles, loc_msg;

  num_poles = (in_udir ? srf->v_num_poles : srf->u_num_poles);
  order = (in_udir ? srf->v_order : srf->u_order);
  for (i = 0; i < (trim_to_boundaries ? 2 : 1); i++)
   {
    BSalloccv(
      order, 
      num_poles, 
      srf->rational, 
      NULL, 
      &isocrv[i], 
      &loc_msg);
     if (loc_msg != BSSUCC)
      {
       *msg = MANOMEMORY;
       goto wrapup;
      }
   } /* for (i = 0; i < (trim_to_boundaries ? 2 : 1); i++) */
 }
/*
 * Loop around and output all the isoparametric curves
 */
 for (i = 0; i < numparms; i++)
  {
   IGRlong	EMmsg;
/*
 * Regenerate the abstract buffer as IGE distroys it 
 * after constructing an object
 */
   GRgetabsg(
     msg,
     mattyp,
     mat,
     (IGRchar **)&srf,
     i);
    if (! (1 & *msg)) goto wrapup;
/*
 * Extract the constant parameter curve
 */
   {
    extern		IGRboolean BSconstprcv();
    IGRboolean		tst_planar, status;
    IGRshort 		option;  /*Changed to short - DLB 10/23/91*/
    IGRlong		loc_msg;

    option = (in_udir ? 1 : 2);
    tst_planar = TRUE;
    status = BSconstprcv(
      &loc_msg, 
      srf, 
      &option, 
      &parms[i], 
      &tst_planar, 
      isocrv[0]);
     if (loc_msg != BSSUCC)
      {
       *msg = MSFAIL;
       goto wrapup;
      }
    if ((isocrv[0]->order == 2) && 
        isocrv[0]->rational)
     {
      extern		IGRboolean BSunwght_p();

      status = BSunwght_p(	/* Linestring post does not handle weights */
        &loc_msg,
        isocrv[0]->poles,
        isocrv[0]->weights,
        &isocrv[0]->num_poles,
        isocrv[0]->poles);
       if (loc_msg != BSSUCC)
        {
         *msg = MSFAIL;
         goto wrapup;
        }
     } /* if ((isocrv[0]->order == 2) && isocrv[0]->rational) */
   }
/*
 * Clip time
 */
   if (trim_to_boundaries)
    {
     extern	void EMpypoint_free();
     IGRushort  trim_options;
     IGRlong	sts;
     IGRint 	num_bdrys;
     BSpair	iso_edge[2];
     struct	EMSdataselect input_geometry;
     struct	EMSpypoint *bdrys;
     struct	IGRpolyline polyline;

     input_geometry.datatype = EMSdata_poly2d;
     input_geometry.data.poly = &polyline;
     polyline.num_points = 2;
     polyline.points = (IGRdouble *)iso_edge;
     if (in_udir)
      {
       iso_edge[0][0] = parms[i];
       iso_edge[0][1] = low;
       iso_edge[1][0] = parms[i];
       iso_edge[1][1] = hig;
      } /* if (in_udir) */
     else
      {
       iso_edge[0][0] = low;
       iso_edge[0][1] = parms[i];
       iso_edge[1][0] = hig;
       iso_edge[1][1] = parms[i];
      } /* ELSE FOR if (in_udir) */
     bdrys = NULL;
     trim_options = EMS_INTER_BDRYISAREA;
     sts = om$send(
       msg = message EMSloopset.EMlsparttrim(
        &EMmsg,
        &input_geometry,
        &partolbasis,
        trim_options,
        &num_bdrys,
        &bdrys,
        NULL),			/* Don't need edge info. on trim points */
       p_chanselect = &to_my_loopset);
      if ((! (1 & sts)) ||
          (! (1 & EMmsg)))
       {
        *msg = MSFAIL;
        goto wrapup;
       }
/*
 * If the curve was trimmed w.r.t the loopset then
 * extract out the appropriate poritions of the iso curve.
 * Note that 0 to 1 parameterization is not assumed.
 */
     if (EMmsg == EMS_I_IntersectTrim)
      {
       extern		IGRboolean BSpartofcv();
       GRobjid		object_id;
       IGRboolean	status;
       IGRlong		j, loc_msg, sts;
       IGRdouble	u_start, u_end;
       struct		EMSpypoint *bdrys_ptr;

       bdrys_ptr = bdrys;
       isocrv[0]->phy_closed = FALSE;	/* Must be open if trimmed */
       const_args->geometry = (IGRchar *)isocrv[1];
       for (j = 0; j < num_bdrys; j++)
        {
         u_start = bdrys_ptr->param;
         bdrys_ptr = bdrys_ptr->next;
         u_end = bdrys_ptr->param;
         bdrys_ptr = bdrys_ptr->next;
         u_start = low + (hig - low) * u_start;
         if (u_start < low)		/* Round off? */
          u_start = low;
         else if (u_start > hig)
          u_start = hig;
         u_end = low + (hig - low) * u_end;
         if (u_end < low)		/* Round off? */
          u_end = low;
         else if (u_end > hig)
          u_end = hig;
         status = BSpartofcv(
           &loc_msg, 
           isocrv[0], 
           u_start,
           u_start,		/* Middle parameter */
           u_end, 
           isocrv[1]);
          if (loc_msg != BSSUCC)
           {
            *msg = MSFAIL;
            goto wrapup;
           }
         sts = om$construct(
           osnum = const_args->env_info->md_id.osnum,
           classid = clipped_classid,
           msg = message GRgraphics.GRconstruct(
            const_args),
            p_objid = &object_id);
          if (! (1 & sts))
           {
            *msg = MSFAIL;
            goto wrapup;
           }
         if (*curves)
          *curves = (GRobjid *) realloc(
           *curves,
           (*number_of_curves + 1) * sizeof(GRobjid));
         else
          *curves = (GRobjid *) malloc(sizeof(GRobjid));
         if (! *curves)
          {
           *msg = MANOMEMORY;
           goto wrapup;
          }
         (*curves)[*number_of_curves] = object_id;
         (*number_of_curves)++;
        } /* for (j = 0; j < num_bdrys; j++) */
      } /* if (EMmsg == EMS_I_IntersectTrim) */
     EMpypoint_free(
      bdrys,
      NULL);
    } /* if (trim_to_boundaries) */
   else
    EMmsg = EMS_I_InAreaTrim;
/*
 * The curve was not clipped
 */
   if (EMmsg == EMS_I_InAreaTrim)
    {
     IGRlong	sts;
     GRobjid	object_id;

     const_args->geometry = (IGRchar *)isocrv[0];
     sts = om$construct(
       osnum = const_args->env_info->md_id.osnum,
       classid = classid,
       msg = message GRgraphics.GRconstruct(
        const_args),
        p_objid = &object_id);
      if (! (1 & sts))
       {
        *msg = MSFAIL;
        goto wrapup;
       }
     if (*curves)
      *curves = (GRobjid *) realloc(
       *curves,
       (*number_of_curves + 1) * sizeof(GRobjid));
     else
      *curves = (GRobjid *) malloc(sizeof(GRobjid));
     if (! *curves)
      {
       *msg = MANOMEMORY;
       goto wrapup;
      }
     (*curves)[*number_of_curves] = object_id;
     (*number_of_curves)++;
    } /* if (EMmsg == EMS_I_InAreaTrim) */
  } /* for (i = 0; i < numparms; i++) */
/*
 * eof
 */
wrapup:
 {
  for (i = 0; i < 2; i++)
   {
    if (isocrv[i])
     {
      extern		IGRboolean BSfreecv();
      IGRboolean	status;
      IGRlong		loc_msg;

      status = BSfreecv(
       &loc_msg,
       isocrv[i]);
     }
   } /* for (i = 0; i < 2; i++) */
 }
 const_args->geometry = NULL;
 if (! (1 & *msg))
  return(OM_E_ABORT);
 else
  return(OM_S_SUCCESS);
}

/*
 Description

 Given a surface data structure and it's class id this function
 will return the class id's of the u and v isoparametric curves.

 rlw : 06/03/88 : Took this stuff from extract iso curve method,
                  modified it, and put it in this function.

 */

IGRlong EFclassify_iso_curve(
 surface_classid,
 surface,
 u_direction_classid,		/* Constant u - varying v */
 v_direction_classid,		/* Constant v - varying u */
 msg)

OMuword		surface_classid;
struct		IGRbsp_surface *surface;
OMuword		*u_direction_classid;
OMuword		*v_direction_classid;
IGRlong		*msg;

{
/*
 * Initialize
 */
 *msg = MSSUCC;
/*
 * Get the linear stuff classified
 */
 if (surface->u_order == 2)
  {
   if (surface->u_num_poles == 2)
    *v_direction_classid = OPP_GR3dlineseg_class_id;
   else
    *v_direction_classid = OPP_GR3dlinestr_class_id;
  }
 else
  *v_direction_classid = OPP_GRbcsubbc_class_id;
 if (surface->v_order == 2)
  {
   if (surface->v_num_poles == 2)
    *u_direction_classid = OPP_GR3dlineseg_class_id;
   else
    *u_direction_classid = OPP_GR3dlinestr_class_id;
  }
 else
  *u_direction_classid = OPP_GRbcsubbc_class_id;
/*
 * Projection or revolution
 */
 if ((surface_classid == OPP_EMScone_class_id) ||
     (surface_classid == OPP_EMScylindr_class_id))
  {
   if (surface->u_order == 2)		/* Revolution? */
    *u_direction_classid = OPP_GR3dcircle_class_id;
   else
    *v_direction_classid = OPP_GR3dcircle_class_id;
  }
 else if ((surface_classid == OPP_EMSpcone_class_id) ||
          (surface_classid == OPP_EMSpcylindr_class_id))
  {
   if (surface->u_order == 2)		/* Revolution? */
    *u_direction_classid = OPP_GR3dcirarc_class_id;
   else
    *v_direction_classid = OPP_GR3dcirarc_class_id;
  }
 else if ((surface_classid == OPP_EMStorus_class_id) ||
          (surface_classid == OPP_EMSsphere_class_id))
  {
   *v_direction_classid = OPP_GR3dcircle_class_id;
   *u_direction_classid = OPP_GR3dcircle_class_id;
  }
 else if ((surface_classid == OPP_EMSelpcone_class_id) ||
          (surface_classid == OPP_EMSelpcyl_class_id))
  {
   *v_direction_classid = OPP_GR3dellipse_class_id;
  }
 else if (surface_classid == OPP_EMSelpsoid_class_id)
  {
   *v_direction_classid = OPP_GR3dellipse_class_id;
   *u_direction_classid = OPP_GR3dellipse_class_id;
  }
 else if (surface_classid == OPP_EMSrevol_class_id)
  {
   if (surface->v_phy_closed)
    *u_direction_classid = OPP_GR3dcircle_class_id;
   else
    *u_direction_classid = OPP_GR3dcirarc_class_id;
  }
/*
 * eof
 */
wrapup:
 if (! (1 & *msg))
  return(FALSE);
 else
  return(TRUE);
}

end implementation EMSsubbs;

