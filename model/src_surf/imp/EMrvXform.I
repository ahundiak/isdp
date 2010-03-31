/* ###################   APOGEE COMPILED   ################## */
class implementation EMSrevol;

# include "EMS.h"
# include "msdef.h"         /* MS message codes */
# include "ma.h"
# include "emserr.h"
# include "bserr.h"
# include "bsparameters.h"
# include "EMSommacros.h"   /* ems$get_memory   */
# include "EMSssprops.h"
# include "OMmacros.h"      /* OM_BLOCK_MOVE    */
# include "go.h"            /* GRpost_info      */

# define BUFFER_SIZE    400

from EMSparameter import EMparam_xform;

method GRxform(IGRlong *EMmsg; struct GRmd_env *obj_dsenv; 
               IGRshort *mx_type; IGRmatrix mx; GRobjid *newobjid)
/*
Abstract

    This method transforms a surface of revolution.

Arguments

    obj_dsenv - input
        The module environment information.

    mx_type, mx - input
        The matrix (and type) to be applied to the geometry.

    newobjid - output
        The object id after transforming.

History
    NP    08/21/92  Modified for ANSI compliance.
    DLB   05/01/91  Xform any EMSparameter object on parent channel.  This
                    abstract class wont have the parent channel and therefore
                    is a bit dirty but im going for a lean and mean impl.
                    rather than adding an override at all the EMA classes.
    26 Aug 88   SS      Modified notification to the new scheme
    25 Mar 88   AIC     Creation Date.
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
      case EMSbsplineFormat:
        sts = om$send(msg = message EMSsubbs.GRxform(EMmsg, obj_dsenv,
                      mx_type, mx, newobjid), mode = OM_e_wrt_message,
                      targetid = *newobjid);
        if(! (1 & *EMmsg & sts)) goto wrapup;
        break;

      case EMSrevolvedFormat:
        {
          IGRboolean            false = FALSE, is_360, pos_orient_flag;
          IGRboolean            status;
          IGRlong               two = 2;
          extern IGRboolean     MArptsxform();
          IGRdouble             axis[6], start_angle, sweep_angle;
          struct IGRbsp_curve   curve;
          short                 GraphicProperties;

          sts = om$send(msg = message GRgraphics.GRgetprops( EMmsg, &GraphicProperties ),
             targetid = my_id );
          if(! (1 & sts)) goto wrapup;

          if (GraphicProperties & GRIS_ASSOCIATIVE)
          {
            IGRlong msg_loc;
            OM_S_CHANSELECT to_father;
            EMmake_chanselect(NDfather_father, &to_father);
            om$send(msg = message EMSparameter.EMparam_xform(&msg_loc,
                          obj_dsenv, mx_type, mx, newobjid),
                    p_chanselect = &to_father);
          }

          curve.poles = curve.weights = curve.knots = NULL;
          sts = om$send(msg=message EMSrevol.EMgetRevolvedFormat(EMmsg,
                        TRUE, &obj_dsenv->md_env.matrix_type,
                        obj_dsenv->md_env.matrix, &curve, NULL, NULL,
                        NULL, NULL, NULL), targetid = *newobjid);
          if(! (1 & *EMmsg & sts)) goto wrapup;

          /*
           * Get the memory for the curve data.
           */
          ems$get_memory(rc = EMmsg, element_size = sizeof(IGRdouble),
                         num_elements = curve.num_poles *
                                        (curve.rational ? 4:3) +
                                          curve.num_knots,
                         buffer = (IGRchar *)static_doubles_buffer,
                         buffer_size=BUFFER_SIZE,
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
           * Get the curve data
           */
          sts = om$send(msg=message EMSrevol.EMgetRevolvedFormat(EMmsg,
                        FALSE, &obj_dsenv->md_env.matrix_type,
                        obj_dsenv->md_env.matrix, &curve, axis, &is_360,
                        &start_angle, &sweep_angle, &pos_orient_flag),
                        targetid = *newobjid);
          if(! (1 & *EMmsg & sts)) goto wrapup;

          status = MArptsxform(EMmsg, &curve.num_poles, &curve.rational,
                               curve.weights,mx,curve.poles,curve.poles);
          status = MArptsxform(EMmsg, &two, &false, NULL, mx, axis, axis);

          /*
           * Determine the orientation of the normal
           */
          {
            IGRshort    bssts;
            IGRint      rc;
            extern IGRdouble   fabs();
            IGRdouble   determinant, zero_tol;
            IGRpoint    save_pt;

            bssts = BSEXTRACTPAR (&rc, BSTOLCLOSETOZERO, zero_tol);
            determinant=mx[0] * (mx[5] * mx[10] - mx[6] * mx[9]) -
                        mx[1] * (mx[4] * mx[10] - mx[6] * mx[8]) +
                        mx[2] * (mx[4] * mx[9] - mx[5] * mx[8]);
            if(fabs(determinant + 1.0) < zero_tol)
            {
              save_pt[0]=axis[0]; save_pt[1]=axis[1]; save_pt[2]=axis[2];
              axis[0]=axis[3]; axis[1]=axis[4]; axis[2]=axis[5];
              axis[3]=save_pt[0]; axis[4]=save_pt[1]; axis[5]=save_pt[2];
              pos_orient_flag = pos_orient_flag ? FALSE : TRUE;
            }
          }

          /*
           * Store the curve data
           */
          {
            struct GRpost_info  post_info;

            post_info.construct_flag = FALSE;
            sts = om$send(msg=message EMSrevol.EMputRevolvedFormat(EMmsg,
                          obj_dsenv, &post_info, &curve, axis, is_360,
                          start_angle, sweep_angle, pos_orient_flag),
                          targetid = *newobjid);
            if(! (1 & *EMmsg & sts)) goto wrapup;
          }
        }
        break;

      default:
        *EMmsg = EMS_E_InvalidCase;
        goto wrapup;
    }
  }

wrapup:
  if (notify)
    {
    if (!EMSerror (*EMmsg))
      sts = om$send (msg = message EMSsurface.EMpostxform (EMmsg, NULL,
             obj_dsenv, mx_type, mx, OPPmargs, NULL), targetid = my_id);
    EMrestore_postproc();
    }

  EMWRAPUP(*EMmsg, sts, "EMSrevol.GRxform")
  return (OM_S_SUCCESS);
}

end implementation EMSrevol;
