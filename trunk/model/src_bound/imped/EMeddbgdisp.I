/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

/*
   History

      Sudha 06/04/93          modified to include BSprototype header files
*/

#include "EMS.h"
#include "igrdef.h"
#include "emserr.h"
#include "emsdef.h"
#include "EMSifmacros.h"
#include "maptsxfor.h"

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

method EMdebug_display (IGRlong *msg; struct GRmd_env *mdenv; 
                        struct IGRdisplay *display_attr;
                        enum GRdpmode display_mode)
{
  IGRboolean stat_func;
  IGRint i, j;
  IGRlong msg_loc, stat_OM;
  IGRdouble *points;
  struct IGRpolyline *poly;
  struct IGRbsp_curve *incurve;
  struct EMSaltdataselect mygeom;
  IGRlong ECdisplayPointSetByBuffer0();
  
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  mygeom.datatype = EMSdata_null;
  mygeom.data.poly.points = NULL;
  mygeom.data.curve.poles = NULL;
  mygeom.data.curve.knots = NULL;
  mygeom.data.curve.weights = NULL;
  points = NULL;

  stat_OM = om$send (msg = message EMSedge.EMgetgeom (&msg_loc,
             0, MAXINT, FALSE, NULL, &mygeom), targetid = my_id);
  EMomerr_exit (stat_OM, ret_end);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_EdgeError, ret_end);

  switch (mygeom.datatype)
    {
    case EMSdata_poly2d:
      poly = &mygeom.data.poly;
      points = (IGRdouble *) om$malloc (size =
                poly->num_points * 3 * sizeof (IGRdouble));
      EMerr_hndlr (!points, *msg, EMS_E_NoDynamicMemory, ret_end);
    
      for (i=0, j=0; i<poly->num_points*3; i+=3, j+=2)  
        {
        points[i] = poly->points[j];
        points[i+1] = poly->points[j+1];
        points[i+2] = 0.0;
        }
    
      stat_func = MAptsxform (&msg_loc, &poly->num_points,
                   mdenv->md_env.matrix, points, points);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      ECdisplayPointSetByBuffer0 (&msg_loc, *display_attr, *mdenv, my_id,
       poly->num_points, points, display_mode, IGRPY);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

      break;

    case EMSdata_curve3d:

      incurve = &mygeom.data.curve;
      if (incurve->rational)
      {
        for (i=0; i < incurve->num_poles ; i++)
        {
         incurve->poles[3*i] /= incurve->weights[i];
         incurve->poles[3*i+1] /= incurve->weights[i]; 
         incurve->poles[3*i+2] /= incurve->weights[i];
        }
      }

      stat_func = MAptsxform (&msg_loc, &incurve->num_poles,
                   mdenv->md_env.matrix, incurve->poles, incurve->poles);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      
      if (incurve->rational)
      {
       for (i=0; i < incurve->num_poles ; i++)
       {
         incurve->poles[3*i] *= incurve->weights[i];
         incurve->poles[3*i+1] *= incurve->weights[i];
         incurve->poles[3*i+2] *= incurve->weights[i];
       }
      }
/**********************************************************************
      ECdisplayBsplineBybuffer (&msg_loc, *display_attr, *mdenv, my_id,
      incurve, display_mode, IGRBC);
**********************************************************************/
      ems$displayBsplineBybuffer (msg = &msg_loc,
                                   incurve = incurve,
                                   senderid = my_id,
                                   display_attr = *display_attr,
                                   mdenv = *mdenv,
                                   mode = display_mode,
                                   type = IGRBC);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
      break;
    default:
      *msg = EMS_E_EdgeError;
    }

ret_end:
  if (mygeom.datatype == EMSdata_poly2d)
    {
    if (mygeom.data.poly.points)
      om$dealloc (ptr = mygeom.data.poly.points);
    }
  else if (mygeom.datatype == EMSdata_curve3d)
    {
    if (mygeom.data.curve.poles)
      om$dealloc (ptr = mygeom.data.curve.poles);
    if (mygeom.data.curve.knots)
      om$dealloc (ptr = mygeom.data.curve.knots);
    if (mygeom.data.curve.weights)
      om$dealloc (ptr = mygeom.data.curve.weights);
    }

  EMWRAPUP (*msg, stat_OM, "EMSedge.EMdebug_display");
  return (stat_OM);
}

end implementation EMSedge;
