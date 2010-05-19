/* ###################   APOGEE COMPILED   ################## */
class implementation EMSrevol;

# include "OMmacros.h"      /* OM_BLOCK_MOVE            */
# include "EMSssprops.h"    /* EMSIS...                 */
# include "EMSrevol.h"      /* EMSrevolvedSurfaceHeader */

method EMgetRevolvedFormat(IGRlong *EMmsg; IGRboolean cv_header_only;
                            IGRshort *mx_type; IGRmatrix mx;
                            struct IGRbsp_curve *curve;
                            IGRdouble *axis; IGRboolean *is_360;
                            IGRdouble *start_angle, *sweep_angle;
                            IGRboolean *pos_orient_flag)
/*
Abstract

    This method is used to get the revolution data from the instance
    data.

Arguments

    cv_header_only - input
        If this is true, only the curve header information is returned.

    mx_type, mx - input
        The matrix and type from local to world coordinates.

    curve - output
        The curve to be revolved.

    is_360 - output
        True if the revolution is 360 degrees.

    axis - output
        Array of two points defining the axis of revolution.

    start_angle, sweep_angle - output
        Start and sweep angles. Only returned if is_360 is false.

    pos_orient_flag - output
        Is the surface positive oriented?

History

    21 Oct 91   AIC     Check for revolved format.
    09/26/91    DLB     Reference curve struct only if !NULL.
                        Crashes on SUN.
    25 Mar 88   AIC     Creation Date.
*/
{
 extern  IGRboolean  MArptsxform();
  IGRboolean                        status;
  IGRlong                           sts = OM_S_SUCCESS;
  struct EMSrevolvedSurfaceHeader   *instance_data;
  unsigned char                     props;

  /*
   * Initialize
   */
  *EMmsg = EMS_S_Success;

  if((me^^EMSsubbs.ss_props & EMSformat) != EMSrevolvedFormat)
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }

//  if( mx      == NULL ) printf(" mx      : NULL POINTER\n");
//  if( mx_type == NULL ) printf(" mx_type : NULL POINTER\n");

  if( mx == NULL || mx_type == NULL ){ 
//	printf(" Leave EMgetRevolvedFormat \n");
	*EMmsg = EMS_E_InvalidArg;
	goto wrapup;
  }

  instance_data = (struct EMSrevolvedSurfaceHeader *)
                  me^^EMSsubbs.packed_data;
  props = instance_data->rv_props;

  /*
   * Get the curve header information
   */
  if(curve)
  {
    curve->periodic = props & EMSIS_RV_PERIODIC ? TRUE : FALSE;
    curve->non_uniform = props & EMSIS_RV_NONUNIFORM ? TRUE : FALSE;
    curve->rational = props & EMSIS_RV_RATIONAL ? TRUE : FALSE;
    curve->planar = props & EMSIS_RV_PLANAR ? TRUE : FALSE;
    curve->phy_closed = props & EMSIS_RV_PHYCLOSED ? TRUE : FALSE;
    curve->order = instance_data->order;
    curve->num_poles = instance_data->num_poles;
    curve->num_knots = curve->order + curve->num_poles;
    curve->num_boundaries = 0;
    curve->bdrys = NULL;
  }

  if(! cv_header_only)
  {
    IGRdouble   *double_ptr;

    double_ptr = instance_data->double_data;
    if(curve)
    {
      /*
       * Get the poles
       */
      OM_BLOCK_MOVE(double_ptr, curve->poles,
                    curve->num_poles * sizeof(IGRpoint));
    }
    double_ptr += 3 * instance_data->num_poles;

    if(props & EMSIS_RV_RATIONAL)
    {
      if(curve)
      {
        /*
         * Get the weights
         */
        OM_BLOCK_MOVE(double_ptr, curve->weights,
                      curve->num_poles * sizeof(IGRdouble));
        double_ptr += curve->num_poles;  /*Moved inside if - DLB*/
      }
    }

    /*
     * Take the poles to world coordinates
     */
    if(curve && (*mx_type ISNT MAIDMX))
    {
      status = MArptsxform(EMmsg, &curve->num_poles, &curve->rational,
                           curve->weights,mx,curve->poles,curve->poles);
      if(!(status && (1&*EMmsg))){ *EMmsg = EMS_E_Fail; goto wrapup; }
      *EMmsg = EMS_S_Success;
    }

    if(curve)
    {
      /*
       * Get the knots
       */
      if(curve->non_uniform || curve->periodic)
      {
        OM_BLOCK_MOVE(double_ptr, curve->knots,
                      curve->num_knots * sizeof(IGRdouble));
      }
      else EFknotVector(curve->order, curve->num_poles, curve->knots);

      if(props & (EMSIS_RV_PERIODIC | EMSIS_RV_NONUNIFORM))
        double_ptr += curve->num_knots;  /*Moved inside if - DLB*/
    }

    /*
     * Get the axis and other revolution information
     */
    if(axis)
    {
      if(*mx_type IS MAIDMX)
      {
        OM_BLOCK_MOVE(double_ptr, axis, 2 * sizeof(IGRpoint));
      }
      else
      {
        IGRboolean  false = FALSE;
        IGRint      two = 2;

        status = MArptsxform(EMmsg, &two, &false, NULL, mx, double_ptr,
                             axis);
        if(!(status && (1&*EMmsg))){ *EMmsg = EMS_E_Fail; goto wrapup; }

        *EMmsg = EMS_S_Success;
      }
    }
    double_ptr += 6;

    if(is_360)
    {
      *is_360 = props & EMSIS_RV_360 ? TRUE : FALSE;
      if(*is_360)
      {
        if(start_angle) *start_angle = 0.;
        if(sweep_angle) *sweep_angle = 360.;
      }
      else
      {
        if(start_angle) *start_angle = *double_ptr ++;
        if(sweep_angle) *sweep_angle = *double_ptr;
      }
    }
    else
    {
      if(start_angle) *start_angle = *double_ptr ++;
      if(sweep_angle) *sweep_angle = *double_ptr;
    }

    /*
     * Get the pos_orient_flag
     */
    if(pos_orient_flag)
    {
      *pos_orient_flag = me^^EMSsubbs.ss_props & EMSIS_NRML_REVERSED ?
                         FALSE : TRUE;
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, sts, "EMSrevol.EMgetRevolvedFormat")
  return(sts);
}

end implementation EMSrevol;
