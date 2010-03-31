


/********

Description

   Header to define a struct for end conditions of a blend surface.
   Sufficient large numbers are defined to garanty enough allocation
   if f.e. BSallocsf is used.
   

History :  created 11/15/93  - GEB                                      *****/

struct EMSblend_sf_end_condition
{
   struct IGRbsp_surface  *surface;     /*  The surface on which the blending
                                            end condition exists.           */

   IGRint               boundary_flag;  /*  0: The curve where the blend
                                               starts/ends is a B-spline
                                               curve.
                                            1: v=vmin boundary
                                            2: u=umin boundary
                                            3: v=vmax boundary
                                            4: u=umax boundary              */

   struct IGRbsp_curve  *curve;         /*  If (boundary_flag == 0)
                                            the boundery curve, at which the
                                            belnd starts/ends.              */

   IGRdouble         blend_pt_par[2];   /*  Start and end parameter of the 
                                            boundary curve (may be iso curve 
                                            the surface).                   */

   IGRdouble            pariso;         /*  the iso-parameter if
                                            boundary_flag == 1,2,3,4 
                                            may differ from 0 or 1 :
                                            blend at iso-curves             */

   IGRint               direction;      /*  >=0: direction pointing away from
                                                 surface shows to blend surface
                                            else opposite direction          */

   IGRint               tangent_flag[3]; /* Tangent values are specified at
                                            start, middle, end of the curve
                                            where the blend starts/ends:
                                            [0] : at start
                                            [1] : at middle
                                            [2] : at end
                                            
                                            <=0: No tangent value specified.
                                            1: Value relative to the surface
                                               derivative at curve where blend
                                               starts (in blend direction). 
                                            2: Value is a factor, by which
                                               the length determined by the
                                               program is multiplied.
                                            -n: output cases 
                                                the value is related to the
                                                surface derivative, it is
                                                constant if approx_flag == 0
                                                a mean value otherwise      */


   IGRdouble            tangent_value[3]; /* Tangent value as specified by
                                             'tangent_flag'. If 'tangent_
                                             flag is 0, 'tangent value is 
                                             returned.                      */

   IGRint               curvature_flag; /*  0: No curvature condition.    
                                            1: Curvature condition. 
                                            2: Curvature condition, factor
                                               for additional term specified
                                               (DDG = (tangent_value**2)*DDF
                                                    + curvature_value*DF)    */
   IGRdouble            curvature_value; /*  curvature value as specified by
                                             'curvature_flag'                */
   IGRint               approx_flag;     /* 0: exact
                                            1: approximative                 */
   IGRdouble            approx_fact;     /* if (approx_flag > 0)
                                            a factor between 0.0 and 1.0 
                                            0.0 corresponds to the exact     */
};
 
