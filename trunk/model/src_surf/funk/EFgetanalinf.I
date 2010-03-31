class implementation EMSsubbs;

/*
 * includes
 */
#include "OMtypes.h"
#include "bserr.h"
#include "bsparameters.h"
#include "emsedgedef.h"
#include "EMSanaltypes.h"
#include "msdef.h"
#include "bstst_plan.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bscrossp.h"
#include "bscvnormal.h"
#include "math.h"

/*
 *   EFget_analytic_info
 * 
 *   Notes: This routine will accept a curve(id or structure) and 
 *          information describing the projection or revolution 
 *          and determine if the resulting surface will be an
 *          analytic 
 *
 *          Will assume that the curve is not a composite curve.
 *          Caller should send each member of the composite to
 *          this routine if desired.
 *
 *          Either curve_id or curve_geom should be passed in.  
 *          If curve_geom is available, send that and the routine
 *          will be faster.  In that case, send NULL for curve_id,
 *          and specifiy const_os.
 *
 *          The option for surfaces of revolution is currently not
 *          supported.  
 * 
 *          Return codes that I set:
 *              EMS_S_Success  -- No problems
 *              EMS_E_Fail     -- Probably an error from a math call
 *              MSINARG        -- If the default case of the new_classid 
 *                                switch is reached.
 *          
 *   History :  
 *       12/21/92  Jack   Creation
 *	 07/06/93  Sudha  Modified for BSprototypes ansification
 * 	 11/16/93  Sanjay Earlier versions were creating planes incorrectly,
 *                        i.e. Planes with parellogram shape should be actually 
 *                        created as planes with imposed boundaries, but the 
 *                        earlier versions were creating them as natural planes. *                        Added code to take care of the above problem. 
 *                        TR # 119311777 ( Fix for EMS 3 )  
 * 
 */
#argsused
void EFget_analytic_info(EMmsg,
                         draft_angle,
                         curve_id,
                         curve_env,
                         curve_geom,
                         curve_type,
                         axis,
                         rev_angle,
                         const_os,
                         new_classid,
                         new_obj,
                         info_bits)
                    
IGRlong         *EMmsg;          /* O - Return code */ 
IGRdouble        draft_angle;    /* I - only used for cones, set to 0.0 if no draft */
struct GRid     *curve_id;       /* I - object to be revolved or projected */
struct GRmd_env *curve_env;      /* I - curve module environment, if curve_id specified */
struct IGRbsp_curve *curve_geom; /* I - curve geometry */
IGRuchar         curve_type;     /* I - curve type, if curve_geom is specified */  
IGRvector        axis;           /* I - (revolve) ? axis of rev : axis of proj */
IGRdouble        rev_angle;      /* I - for revolution, not used for proj */
OMuword          const_os;       /* I - OS where new_obj will be constructed, not used
                                        if curve_id is specified. */
OMuword         *new_classid;    /* O - class of resulting surface(whether constructed
                                        or not.  This will be of the type OPP_classname_class_id. */
OM_S_OBJID      *new_obj;        /* O - (construct) ? newly constructed object : NULL_OBJID
                                        if no analytic type could be found, return NULL_OBJID */
IGRint          *info_bits;      /* I/O - input and output information bits defined in
                                          EMSanaltypes.h */

{

/*
 * function externs
 */
extern  IGRlong     EFget_the_edge_type_for_an_object();

/*
 * other externs
 */
extern  OMuword     OPP_EMScylindr_class_id;
extern  OMuword     OPP_EMSpcylindr_class_id;
extern  OMuword     OPP_EMSelpcyl_class_id;
extern  OMuword     OPP_EMSplane_class_id;
extern  OMuword     OPP_EMScone_class_id;
extern  OMuword     OPP_EMSpcone_class_id;


/*
 * local variables
 */
struct IGRbsp_curve  *curve = NULL;
IGRuchar              loc_curve_type = 0;
IGRlong               status = OM_S_SUCCESS;
IGRlong               bs_msg = 0;
IGRchar              *generic_pointer = NULL;
IGRboolean            curve_is_planar = FALSE;
IGRvector             normal_vector;
IGRboolean            b_status = FALSE;
IGRdouble             vector_length;
IGRvector             cross_product;
IGRvector             unit_vector;
IGRint                found_class=FALSE;
IGRdouble             cross_tol;
OMuword               loc_const_os;


/*
 * initialize 
 */
*EMmsg = EMS_S_Success;
*new_obj = NULL_OBJID;

/*
 * Get the curve definition
 */
if(curve_geom)
{
   /*
    * curve_geom specified
    *   just assign geometry to curve
    */
  curve = curve_geom;
  loc_curve_type = curve_type;
  loc_const_os   = const_os;
}
else
{

   /*
    * curve_id specified
    *   get the object space to construct the surface in
    *   get the curve geometry
    *   assign geometry to curve
    *   determine edge type of curve
    */
   loc_const_os = curve_id->osnum;

   status = om$send(msg = message GRvg.GRgenabsg(
                                       EMmsg,
                                      &curve_env->md_env.matrix_type,
                                       curve_env->md_env.matrix, 
                                      &generic_pointer),
                    senderid = NULL_OBJID,
                    targetid = curve_id->objid,
                    targetos = curve_id->osnum);
      if (! (1 & status & *EMmsg))
        goto wrapup;
      curve = (struct IGRbsp_curve *) generic_pointer;
      status = EFget_the_edge_type_for_an_object(curve_id->objid,
                                                 curve_id->osnum, 
                                                 NULL, 
                                                &loc_curve_type);
      if (! (1 & status & *EMmsg))
        goto wrapup;
}


/*
 * revolution
 *   currently not supported
 */


/*
 * projection
 */

/*
 * check if the curve is planar
 */
BStst_plan(curve->num_poles, 
           curve->poles, 
          (curve->rational ? curve->weights : NULL), 
          &curve_is_planar, 
           normal_vector,
          &bs_msg);
if (bs_msg != BSSUCC)
    goto wrapup;  

if (curve_is_planar)
  *info_bits |= CV_IS_PLANAR;

if(*info_bits & CV_IS_PLANAR)
{
   /*
    * curve is planar
    */

   /*
    * If the cross product of the plane normal vector and the
    * projection vector is zero then we are projecting normal
    * to the plane of the curve
    */
   unit_vector[0] = axis[0];
   unit_vector[1] = axis[1];
   unit_vector[2] = axis[2];

   /*
    * normalize(unitize) the input projection vector (axis)
    */
   b_status = BSnorvec(&bs_msg, 
                        unit_vector);

   if ((!b_status)|| (bs_msg != BSSUCC))
     { 
      *EMmsg = EMS_E_Fail; 
       goto wrapup; 
     }

   /*
    * cross the plane normal vector returned from BStst_plan
    * with the unitized projection vector
    */
   b_status = BScrossp(&bs_msg, 
                        unit_vector, 
                        normal_vector, 
                        cross_product);

   if ((!b_status)|| (bs_msg != BSSUCC))
     { 
      *EMmsg = EMS_E_Fail; 
       goto wrapup; 
     }


   /*
    * get the length of the cross product vector
    */ 
   vector_length = BSlenvec(&bs_msg, cross_product);

   /*
    * get the cross product tolerance
    */
   b_status = BSEXTRACTPAR(&bs_msg, 
                            BSTOLCOLLINVEC, 
                            cross_tol);

   if ((!b_status)|| (bs_msg != BSSUCC))
     { 
      *EMmsg = EMS_E_Fail; 
       goto wrapup; 
     }

   /*
    * if the cross product vector length is less than the
    * cross product tolerance, we are projecting normal to
    * the plane of the curve.
    */
   if(vector_length < cross_tol)
    {
     /*
      * using the edge type of the curve, determine if we
      * will get an analytic type (case statement)
      */
     *info_bits |= ORTHO;      
     found_class = TRUE;
     switch (loc_curve_type)
      {
        case EMcircle:
          if(draft_angle == 0.0)
            *new_classid = OPP_EMScylindr_class_id;
          else
            *new_classid = OPP_EMScone_class_id;
          break;
        case EMellipse:
          if(draft_angle == 0.0)      
            *new_classid = OPP_EMSelpcyl_class_id;
          else
             found_class = FALSE; /* drafting an ellipse will not give an elliptical cone */
          break;
        case EMcircular_arc:
         if( ! curve->phy_closed ) /* Not a closed circular arc */ 
          {
           if(draft_angle == 0.0)
                *new_classid = OPP_EMSpcylindr_class_id;
           else
                *new_classid = OPP_EMSpcone_class_id;
          }                        
	 else  /* If the arc is 360 degree treat it as a circle */
          {
           if(draft_angle == 0.0)
                *new_classid = OPP_EMScylindr_class_id;
           else
                *new_classid = OPP_EMScone_class_id;
          }
            break;
        case EMelliptical_arc:
             found_class = FALSE;
             break;
        case EMlinestring:
        case EMorthogonal_linestring:
        case EMorthogonal_polygon:
        case EMplanar_linestring:
        case EMpolygon:
        case EMintersection_curve:
        case EMfreeform_curve:
             *info_bits |= REPARAM;
              found_class = FALSE;
              break;
        case EMinfinite_line:   /* Should not have gotten this far since */
        case EMlinesegment:     /* we already checked for planarity */
        case EMpoint:
        default:
            *EMmsg = MSINARG;            
            found_class = FALSE;
            goto wrapup;
        } /* switch (edge_type) */
    } /* ortho projection */
   else if(fabs(vector_length - 1.) < cross_tol)
          {
            /*
             * don't construct a surface, just return that the surface
             * would have been planar
             */
            *info_bits |= SF_IS_PLANAR;
          } 

} /* curve is planar */
else
{
  /*
   * otherwise, curve is NOT planar
   * if curve order is 2, num poles is 2, non-rational and draft_angle is zero
   * then will get a plane.
   */

  /* Fix for TR# 119311777 -- sanjay
   * ---------------------
   * Check for draft angle 
   * Check whether the curve is being projected orthogonally if the draft_angle
   * is equal to zero. If yes create the natural planes otherwise create planes
   * with imposed boundaries which will be taken care of by the calling routine 
   */
  
  if((curve->order == 2) && (curve->num_poles == 2) &&
    (!curve->rational) && (draft_angle == 0.0) )
    {
	
      /*
       * Check whether we are projecting the curve along its normal or not
       */
      unit_vector[0] = axis[0];	
      unit_vector[1] = axis[1];	
      unit_vector[2] = axis[2];	

      /*
       * Normalize the input projection vector i.e. axis of projection
       */

      b_status = BSnorvec(  &bs_msg,
                            unit_vector
                         );

      if((!b_status) || (bs_msg != BSSUCC))
      {
          *EMmsg = EMS_E_Fail;
          goto wrapup;
      }
	
      /*
       * Find the cross product of Curve normal vector and normalized 
       * projection vector
       */

      b_status = BScrossp(  &bs_msg,
                            unit_vector,
                            normal_vector,
                            cross_product
                         );

      if((!b_status) || (bs_msg != BSSUCC))
      {
          *EMmsg = EMS_E_Fail;
          goto wrapup;
      }

      /*
       * Get the length of the cross product vector
       */

      vector_length = BSlenvec( &bs_msg,
                                cross_product
                              );
	
      /* 
       * Get the cross product tolerance 
       */

      b_status = BSEXTRACTPAR(  &bs_msg,
                                BSTOLCOLLINVEC,
                                cross_tol
                             ); 	
 
      if((!b_status) || (bs_msg != BSSUCC))
      {
          *EMmsg = EMS_E_Fail;
          goto wrapup;
      }
  
      /*
       * If the cross product vector length is less than the cross product
       * tolerance, then we will get a plane with natural edges otherwise
       * with imposed boundaries. 
       */ 	

      if( (vector_length < cross_tol) || 
          (fabs((vector_length -1.0)) < cross_tol) )	
      {	
          found_class = TRUE;
          *new_classid = OPP_EMSplane_class_id;
          *info_bits |= SF_IS_PLANAR;
      }	 
    } 
  else
      /*
       * don't construct, reparameterize the curve before constructing 
       * the surface.  this can be done by the calling routine.
       */
      *info_bits |= REPARAM;


} /* else curve is not planar */
         

/*
 * if we detected a class change, do a construct
 */
if((found_class) && (!(*info_bits & DONT_CONSTR)))
{
   status = om$construct(classid = *new_classid, 
                         osnum   =  loc_const_os,
                         p_objid =  new_obj);
   if (! (1 & status))
     goto wrapup;
}


wrapup:

return;


}

end implementation EMSsubbs;
