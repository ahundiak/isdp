/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

#include "EMS.h"

extern OMuword OPP_EMSblinear_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMSelpcyl_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMScomposite_class_id;
extern OMuword OPP_EMSprjcompsf_class_id;

extern void EFget_analytic_info();
extern OM_S_OBJID current_creator;

# include "msdef.h"
# include "maerr.h"
# include "bs.h"
# include "bserr.h"
# include "bsparameters.h"
# include "igrtypedef.h"
# include "igetypedef.h"
# include "gr.h"
# include "growner.h"
# include "OMerrordef.h"
# include "emsedgedef.h"
# include "OMmacros.h"
# include "EMSsweep.h"
# include "EMSssprops.h"
# include "EMSsfdef.h"
# include "EMSproject.h"
# include "EMSanaltypes.h"
# include "v_geommacros.h"

#include "bsarclnparc.h"
#include "bslenvec.h"

from EMSswcompsf import EMsweep_composite_curve;

# define TRUE    1
# define FALSE   0
# define NULL    0
# define STATIC_NUMBER_OF_POLES 50

method EMplace_surface_of_projection(
  struct GRvg_construct *construct_list;
  struct GRid *curve_id;
  struct GRmd_env *curve_module_info;
  struct IGRbsp_curve *curve_structure;
  IGRuchar curve_type;
  IGRpoint point1, point2;
  IGRboolean pos_orient_flag;
  OM_S_OBJID *new_objid)
/*
Abstract

  This method constructs a surface of projection given a curve -
  ( Single or Composite ) and two points defining the projection 
  vector.  Only Single curve may be specified either as a curve
  object or a curve structure. Composite curve is to be specified 
  by an "object"  If a curve structure is input then the curve
  type must also be specified (see emsedgedef.h).

  If the method detects that the surface can be represented by
  a special type of surface, e.g. cylinder, plane, etc.. it will
  construct an object of that class and return it's object id.

  In case of a composite curve, a composite surface is formed.

Return Values

  construct_list->msg    MSSUCC - successfull
                         MSFAIL - if failure
                         MANOMEMORY - if no memory could be allocated
                         MSINARG - if the projection vector and the curve
                             is totally parallel or partially parallel
                         GRSNOINVTRAN - if input matrix is not invertible
                         GRSDGNEXCEED - if range exceeds design limits

  new_objid              object id of the resulting surface, in case of
                         a composite curve, it is the id of EMSprjcompsf
                         class object.

Notes

  This object will delete itself if an error occurs.
  The object won't delete the composite surface, the composite surface
   would delete itself.
  The curve being projected is reparameterized before projection.  This
  implies that the input curve buffer will be modified.
  The method will return the id of a composite surface object belonging
  to EMSprjcompsf class in argument new_objid, if a composite curve is
  to be projected.
 
History
    09/15/93 : NP       If the surface of projection is NOT a composite, make 
                        sure that it will have a natural boundary before it 
                        leaves here. (For composite surface of projection, 
                        "EMSswcompsf.EMsweep_composite_curve" takes care of 
                        creating natural boundaries). 
    07/07/93 : Sudha    Modified for BSprototypes ansification
    31 Dec 92: Jack     Modified to call EFget_analytic_info().
    19 Aug 92: NP	Modified for ANSI compliance. Missing typecasts.
    Nov 27,90: Inasu:   If the circular arc is closed (ie 360 deg ) projected
			surface class is taken as EMScylindr.
    02/02/89    rlw     Code which determined the sign of the magnitude
                        for ortho projections was using the wrong tolerance.
                        Repaired the same.  Also added a check to make sure 
                        projection vector is not degenerate when projecting 
                        a planar curve.
    02 May 88   AIC     Set GRgraphics planarity properties bit.
    10 Mar 88   AIC     Modified to store in the projected format.
    02/05/88    rlw     I believe that since there was no partial
                        elliptical cylinder in EMS 1.1 Allen removed
                        the reference. In doing so he forgot to disenable
                        the class conversion in such a case.  This was
                        causing failures and random results.
    01/11/88    sam     Modified such that the curve being revolved could
                        be a compsite curve.
    29 Oct 87   AIC     Modified for EMS version 1.1 class structure

    17-Oct-87   SM      Changed due to argument change in
                        'EFget_edge_type..'.
    09/21/87    rlw     Modified such that the curve being projected is
                        reparameterized before being projected.
    05/29/87    rlw     I forget the * sizeof(IGRdouble) part in the
                        malloc for the surface u knots.
    05/27/87    rlw     Rewritten - renamed method from EMplace_sf_proj
                        such that people calling the original would find
                        out that the argument list has changed
    09/30/86    lst     The beginning
*/
{
  IGRchar       *generic_pointer = NULL ;
  IGRuchar 	edge_type;
  IGRboolean    class_change, reparameterize,
                ortho = FALSE,
                surface_is_planar = FALSE,
		use_grdelete_and_not_rootdelete = FALSE;

  OMuword       new_classid;
  IGRlong       sts;
  IGRlong       loc_msg;
  IGRvector     projection_vector, normal_vector;
  struct        IGRbsp_curve *curve = NULL ;
  extern   IGRdouble     fabs();
  IGRint        info_bits=0;
  OM_S_OBJID    loc_objid = NULL_OBJID, save_creator;

  /*
   * Initialize
   */
  *(construct_list->msg) = MSSUCC;
  class_change = FALSE;
  reparameterize = FALSE;
  ortho = FALSE;
  *new_objid = my_id;
  save_creator = current_creator;
  current_creator = NULL_OBJID;

  /*
   * Get the curve definition
   */
  if(curve_structure) /* Is a curve buffer: single surve */
  {
    curve = curve_structure;
    edge_type = curve_type;
  }
  else if(curve_id) /* Not buffer: Composite or Single object */
  {
    OMuword classid;
    sts = om$get_classid(objid = curve_id->objid,
                         osnum = curve_id->osnum, p_classid = &classid);
    if (! (1 & sts)) { *(construct_list->msg) = MSFAIL; goto wrapup; }

    sts = om$is_ancestry_valid(subclassid = classid,
                               superclassid = OPP_EMScomposite_class_id);
     
    if(sts == OM_S_SUCCESS) /* Is a Composite curve object */
    {
      struct GRlc_info lc_info;
      struct EMSsweep sweep_parms;
         
      OM_BLOCK_MOVE(curve_id,&(lc_info.located_obj),sizeof(struct GRid));
      OM_BLOCK_MOVE(curve_module_info, &(lc_info.module_info),
                    sizeof(struct GRmd_env));
      sweep_parms.type = EMProject;
      sweep_parms.data.prj_data.point1=(IGRpoint *)point1;/* ANSI compliance */
      sweep_parms.data.prj_data.point2=(IGRpoint *)point2;/* ANSI compliance */

      sts = om$construct(classid = OPP_EMSprjcompsf_class_id,
                         osnum = curve_id->osnum, p_objid = new_objid,
                         msg=message EMSswcompsf.EMsweep_composite_curve
                         (construct_list,&lc_info,&sweep_parms,&my_id));
      if (! (1 & sts)) { *(construct_list->msg) = MSFAIL; goto ret_sts; }
      return(OM_S_SUCCESS); /* Exit if task is over */
    }/* Is a  Composite curve object */
    else /* Not a Composite curve object: (Single curve object) */
    {
      IGRlong      EFget_the_edge_type_for_an_object();
/*
      sts = om$send(msg = message GRvg.GRgenabsg(construct_list->msg,
                    &curve_module_info->md_env.matrix_type,
                    curve_module_info->md_env.matrix, &generic_pointer),
                    targetid =curve_id->objid,targetos = curve_id->osnum);
*/
	sts = vd_$get_geometry(grobjEnv =  curve_module_info,
	                       grobjId = curve_id,
	                       msg = construct_list->msg,
	                       geometry = &generic_pointer) ;
	               
      if (! (1 & sts)) { *(construct_list->msg) = MSFAIL; goto wrapup; }
      curve = (struct IGRbsp_curve *) generic_pointer;
      sts = EFget_the_edge_type_for_an_object(curve_id->objid,
            curve_id->osnum, NULL, &edge_type);
      if (! (1 & sts)) { *(construct_list->msg) = MSFAIL; goto wrapup; }
    } /* Not a Composite curve object: (Single curve object) */
  } /* Not a single curve buffer: Is an Object (Composite or Single) */
  else /* No input: neither single curve buffer nor GRid */
  {
    *(construct_list->msg) = MSFAIL;
    goto wrapup;
  }

  /*
   * Calculate the projection vector for future use
   */
  projection_vector[0] = point2[0] - point1[0];
  projection_vector[1] = point2[1] - point1[1];
  projection_vector[2] = point2[2] - point1[2];




  /*
   * Let's try and found out if any analytic surface will be 
   * created by projecting the input curve.
   */
  info_bits = 0;  /* no input bits set */
  
  EFget_analytic_info(construct_list->msg,  /* EMmsg */
                      0.0,                  /* draft_angle */
                      NULL,                 /* curve_id */
                      NULL,                 /* curve_env */
                      curve,                /* curve_geom */
                      edge_type,            /* curve_type */
                      projection_vector,    /* axis */
                      0.0,                  /* rev_angle */
                      OM_Gw_current_OS,     /* const_os */
                     &new_classid,          /* new_classid */
                     &loc_objid,            /* new_obj */
                     &info_bits);           /* info_bits */

  /*
   * if an analytic surface was constructed
   */
  if(loc_objid != NULL_OBJID)
    *new_objid = loc_objid;

  if(info_bits & REPARAM)
    reparameterize = TRUE;
    
  if(info_bits & ORTHO)
    ortho = TRUE;                          

  if(info_bits & SF_IS_PLANAR)
    surface_is_planar = TRUE;


  if (reparameterize && (curve->num_poles > curve->order))
  {
    BSarclnparc(&loc_msg, curve);
    if (loc_msg != BSSUCC) {*(construct_list->msg) = MSFAIL;goto wrapup;}
    curve->non_uniform = TRUE;          /* Math forgets to do this */
  }

  /*
   * Store the geometry
   */
  {
    struct GRpost_info          info;
    IGRuchar            format;
    union EMSprojectionFormat   projection_data;

#if ORTHO_IS_STILL_SUPPORTED
    if(ortho)
    {
      IGRdouble mag, x_dot, y_dot, z_dot, dot;

      format = EMSIS_PJ_ORTHO;
      mag = BSlenvec(&loc_msg, projection_vector);

      /*
       * If projection_vector and normal_vector are opposite
       * in direction, reverse mag.
       */

      x_dot = (projection_vector[0] / mag) * normal_vector[0];
      y_dot = (projection_vector[1] / mag) * normal_vector[1];
      z_dot = (projection_vector[2] / mag) * normal_vector[2];
      dot = x_dot + y_dot + z_dot;
      if (dot < 0) mag *= -1.;

      projection_data.ortho_format.magnitude = mag;
    }
    else
#endif
    {
      format = EMSIS_PJ_VECTOR;
      projection_data.vector_format.projection[0]=projection_vector[0];
      projection_data.vector_format.projection[1]=projection_vector[1];
      projection_data.vector_format.projection[2]=projection_vector[2];
    }

    info.construct_flag = TRUE;
    sts = om$send(msg = message EMSproject.EMputProjectedFormat
                  (construct_list->msg, construct_list->env_info, &info,
                   pos_orient_flag, curve, format, &projection_data),
                  targetid = *new_objid);
    if(! (1 & *(construct_list->msg) & sts)) goto wrapup;
    
    use_grdelete_and_not_rootdelete = TRUE;
  }

  /*
   * Fill in the non-geometric instance data and update the Rtree
   */
  construct_list->geometry = NULL;
  if(surface_is_planar) construct_list->properties |= GRIS_PLANAR;
  else construct_list->properties &= ~GRIS_PLANAR;
  sts = om$send(msg = message GRgraphics.GRconstruct(construct_list),
                targetid = *new_objid);
  if (! (1 & sts)) goto wrapup;

  /* make sure that the non-composite surface of projection will have a 
   * natural boundary. (NP 9/15/93).
   */
  
  sts = om$send (msg = message EMSsurface.EMmk_nat_bdry
                                       (construct_list->msg,
                                        &(construct_list->env_info->md_env),
                                        NULL),
                            targetid = *new_objid);
  if (! (1 & sts)) { *(construct_list->msg) = MSFAIL; goto wrapup; }


wrapup:

	if( generic_pointer ) {free( generic_pointer )  ;generic_pointer=NULL;}
/* if(*new_objid != my_id) ie: surface class got refined and this refined
    surface has a new objectid, hence delete the old object ( my_id)
*/
  if(*new_objid != my_id)
  {
   sts = om$send(msg = message Root.delete(1), targetid = my_id);
  }

/* If failure occured GRdelete OR Root.delete *new_objid (It could be
    the refined surface object (diff objectid) OR old surface (my_id))
*/
  if(!(1&*(construct_list->msg)))
  {
   if(use_grdelete_and_not_rootdelete)
   {
    sts =om$send(msg = message GRvg.GRdelete(&loc_msg, curve_module_info),
		 targetid = *new_objid);
   }
   else
   {
    sts =om$send(msg = message Root.delete(1),
		 targetid = *new_objid);
   }
  }

/*

  if ((! (1 & *(construct_list->msg))) || class_change)
  {
    sts = om$send(msg = message Root.delete(1), targetid = my_id);
    if ((! (1 & *(construct_list->msg))) && (*new_objid != my_id))
    {
      sts = om$send(msg = message Root.delete(1), targetid = *new_objid);
    }
  }

*/

/* If error occured in projection of a composite curve , it would come
    here. The composite surface has deleted itself (with its children)
    and also the surface which was about to become its child
*/

ret_sts:

  current_creator = save_creator; /*reset cureator id */

  if(1 & *(construct_list->msg))
    return(OM_S_SUCCESS);
  else
    return(OM_E_ABORT);
 }

end implementation EMSproject;
