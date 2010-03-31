
/* ********

Description

   Header to define a struct for end conditions of a blend curve.
   Sufficient large numbers are defined to garanty enough allocation
   if f.e. BSalloccv is used.
   

History :  created 09/15/93  - GEB                            **** */


struct EMSblend_cv_end_condition
{
   struct IGRbsp_curve  *curve;          /*  The curve on which the blending
                                             end condition exists.          */
   IGRdouble            blend_pt_par;    /*  The parameter on 'curve' at
                                             which the blend point exists.  */
   IGRint               direction;       /*  1: In the direction of
                                                parametrization of 'curve'.
                                            -1: In the opposite direction.  */
   IGRint               tangent_flag;    /*  0: No tangent value specified.
                                             1: Value relative to distance
                                                of blend points.           
                                             2: Value relative to derivative
                                                of curve at blend point 
                                             -1,-2 output cases             */
   IGRdouble            tangent_value;   /*  Tangent value as specified by
                                             'tangent_value'. When 'tangent_
                                             flag is 0, 'tangent value is 
                                             returned.                      */
   IGRint               curvature;       /*  0: No curvature condition.     */
                                         /*  1: Curvature condition.        */

};

