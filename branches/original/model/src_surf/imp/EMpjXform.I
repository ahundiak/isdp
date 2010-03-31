/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

# include "EMS.h"
# include "msdef.h"         /* MS message codes */
# include "ma.h"
# include "emserr.h"
# include "bserr.h"
# include "bsparameters.h"
# include "EMSssprops.h"
# include "EMSsfdef.h"
# include "EMSproject.h"
# include "EMSommacros.h"   /* ems$get_memory   */
# include "OMmacros.h"      /* OM_BLOCK_MOVE    */
# include "godef.h"

# define TRUE 1
# define FALSE 0

# define BUFFER_SIZE    400

from EMSparameter import EMparam_xform;

method GRxform(IGRlong *EMmsg; struct GRmd_env *obj_dsenv; 
               IGRshort *mx_type; IGRmatrix mx; GRobjid *newobjid)
/*
Abstract

    This method transforms a surface of projection.

Arguments

    obj_dsenv - input
        The module environment information.

    mx_type, mx - input
        The matrix (and type) to be applied to the geometry.

    newobjid - output
        The object id after transforming.

History
    NP    08/19/92  Modified for ANSI compliance. Added typecasts to the
		    ems$get_memory macro.
    DLB   05/01/91  Xform any EMSparameter object on parent channel.  This
                    abstract class wont have the parent channel and therefore
                    is a bit dirty but im going for a lean and mean impl.
                    rather than adding an override at all the EMA classes.
    26 Aug 88   SS      Modified notification to the new scheme
    01 Jun 88   AIC     EMgetBaseCurve and EMgetProjection were
                        merged into EMgetProjection.
    10 Mar 88   AIC     Creation Date.
*/
{
  IGRboolean notify;
  IGRlong   sts = OM_S_SUCCESS;
  IGRdouble static_doubles_buffer[BUFFER_SIZE], *doubles_buffer;

  /*
   * Initialize.
   */
  *EMmsg = MSSUCC;
  *newobjid = my_id;
  doubles_buffer = static_doubles_buffer;
  notify = EMcheck_inhibit_postproc();

  if(*mx_type ISNT MAIDMX)
  {
    extern int EFmatrixClassification();
    int mx_class;
    unsigned char GoodSSProps;

    /*
     * Prepare for transfromation. The transformation may cause the class
     * or the data format of the surface to be changed.
     */
    mx_class = EFmatrixClassification(mx);
    sts = om$send(msg = message EMSsubbs.EMmodifiedClass(EMmsg, mx_class,
                  newobjid), targetid = my_id);
    if(! (1 & sts)) goto wrapup;

    /*
     * The class may have changed, we can no longer use me (or ME).
     */
    sts = om$send(msg = message EMSsubbs.EMget_props ( EMmsg, &GoodSSProps ),
       targetid = my_id );
    if(! (1 & sts)) goto wrapup;

    switch(GoodSSProps & EMSformat)
    {
      unsigned char               format;
      union EMSprojectionFormat   projection_data;
      struct IGRbsp_curve         curve;

      case EMSbsplineFormat:
        /*
         * Invoke the general method.
         */
        sts = om$send(msg = message EMSsubbs.GRxform(EMmsg, obj_dsenv,
                      mx_type, mx, newobjid), mode = OM_e_wrt_message,
                      targetid = *newobjid);
        if(! (1 & *EMmsg & sts)) goto wrapup;
        break;

      case EMSprojectedFormat:
      {
        short GraphicProperties;

        sts = om$send(msg = message GRgraphics.GRgetprops( EMmsg, &GraphicProperties ),
           targetid = my_id );
        if(! (1 & sts)) goto wrapup;

        if (GraphicProperties & GRIS_ASSOCIATIVE)
        {
          IGRlong msg_loc;
          OM_S_CHANSELECT to_father;
          EMmake_chanselect(NDfather_father, &to_father);
          om$send(msg = message EMSparameter.EMparam_xform(&msg_loc, obj_dsenv,
                        mx_type, mx, newobjid),
                  p_chanselect = &to_father);
        }

        /*
         * Get the curve header info
         */
        curve.poles = curve.weights = curve.knots = NULL;
        sts = om$send(msg = message EMSproject.EMgetProjection(EMmsg,
                      &obj_dsenv->md_env.matrix_type,
                      obj_dsenv->md_env.matrix, TRUE, NULL, NULL, &curve),
                      targetid = *newobjid);
        if(! (1 & *EMmsg & sts)) goto wrapup;

        /*
         * Get the memory for the curve data.
         * (Make sure to correctly typecast for ANSI. NP 8/19/92)
         */
        ems$get_memory(rc = EMmsg, element_size = (IGRint)sizeof(IGRdouble),
                       num_elements = (IGRint) ((curve.num_poles *
                                      (curve.rational?4:3) + curve.num_knots)),
                       buffer = (IGRchar *)static_doubles_buffer,
                       buffer_size= (IGRint)BUFFER_SIZE,
                       ptr = (IGRchar **)&doubles_buffer);

        /*
         * Partition the doubles buffer
         */
        curve.poles = doubles_buffer;
        curve.weights = curve.rational ?
                        doubles_buffer + curve.num_poles * 3 : NULL;
        curve.knots = doubles_buffer +
                      curve.num_poles * (curve.rational ? 4 : 3);

        /*
         * Get the projection and curve data.
         */
        sts = om$send(msg = message EMSproject.EMgetProjection(EMmsg,
                      &obj_dsenv->md_env.matrix_type,
                      obj_dsenv->md_env.matrix, FALSE, &format,
                      &projection_data, &curve), targetid = *newobjid);
        if(! (1 & *EMmsg & sts)) goto wrapup;

        /*
         * Transform the projection
         */
        EFxformProjection(EMmsg, mx_type, mx, &format,
                          &projection_data, &curve);
        if(! (1 & *EMmsg)) goto wrapup;

        /*
         * Store the new geometry.
         */
        {
          IGRboolean            pos_orient_flag;
          struct GRpost_info    info;
          IGRshort              bssts;
          IGRint                rc;
          extern IGRdouble      fabs();
          IGRdouble determinant, zero_tol;

          info.construct_flag = FALSE;
          pos_orient_flag = GoodSSProps & EMSIS_NRML_REVERSED ?
                            FALSE : TRUE;

          /*
           * If the transformation is a reflection, reverse the
           * orientation.
           */
          bssts = BSEXTRACTPAR (&rc, BSTOLCLOSETOZERO, zero_tol);
          determinant=mx[0] * (mx[5] * mx[10] - mx[6] * mx[9]) -
                      mx[1] * (mx[4] * mx[10] - mx[6] * mx[8]) +
                      mx[2] * (mx[4] * mx[9] - mx[5] * mx[8]);
          if(fabs(determinant + 1.0) < zero_tol)
            pos_orient_flag = pos_orient_flag ? FALSE : TRUE;

          sts = om$send(msg = message EMSproject.EMputProjectedFormat
                        (EMmsg, obj_dsenv, &info, pos_orient_flag,
                         &curve, format, &projection_data),
                        targetid = *newobjid);
          if(! (1 & *EMmsg & sts)) goto wrapup;
        }
        break;
      }
      
      default:
        *EMmsg = EMS_E_InvalidCase;
        goto wrapup;

    } /* switch (format) */

  } /* if mx_type ISNT MAIDMX */

wrapup:
  if (notify)
    {
    if (!EMSerror (*EMmsg))
      sts = om$send (msg = message EMSsurface.EMpostxform (EMmsg, NULL,
             obj_dsenv, mx_type, mx, OPPmargs, NULL), targetid = my_id);
    EMrestore_postproc();
    }

  if(doubles_buffer && doubles_buffer ISNT static_doubles_buffer)
    om$dealloc(ptr = doubles_buffer);
  EMWRAPUP(*EMmsg, sts, "EMSproject.GRxform")
  return (OM_S_SUCCESS);
}

end implementation EMSproject;
