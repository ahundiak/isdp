/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgenbs;

#include "EMS.h"
#include "msdef.h"
#include "maerr.h"
#include "emsgetgeom.h"

method EMsscone(
        struct IGRbsp_curve *curve;             /* Input curve data */
        struct GRlc_info *located_curve;        /* Input curve object */
        IGRpoint cone_point;                    /* Point to go to */
        struct GRvg_construct *construct_list;  /* Construction data */
        IGRlong *msg)                           /* Error return code */
/*
 Notes

        Upon exit the completion code will be one of

        - MSSUCC, if successful
        - MSFAIL, if failed to generate results
        - MSINARG, if no curve was sent in
        - MANOMEMORY, if unable to allocate memory

        If a failure occurs, then the object will commit suicide.

        The input curve is determined by first checking to see if the
        pointer to the curve data structure is not NULL.  If it is not
        then this curve is used, else it is assumed the curve data is
        located in the input curve object.

        The input arguments are further explained in the specification
        file.

 History

        RLW     12/05/86 : The beginning

 Algorithm

        Get the input curve and allocate storage space for the surface.
        Call the math routine to generate the surface.
        Post the definition into the database.
*/

{
 extern  IGRboolean  BScone();
 IGRboolean     status;
 IGRint         sts;
 IGRdouble      v_knots[4];
 struct         IGRbsp_curve *generating_curve;
 struct         IGRbsp_surface surface;

/*
 * Initialize
 */
 *(construct_list->msg) = MSSUCC;
 generating_curve = NULL;
 surface.poles = NULL;
 surface.weights = NULL;
 surface.u_knots = NULL;
 surface.v_knots = NULL;
/*
 * If a curve was passed in then use it.  Else go and get the curve data
 * from the input object.
 */
 if (curve)
  generating_curve = curve;
 else if (located_curve)
  {
   EMS_GET_GEOMETRY(sts, msg, located_curve, TRUE, generating_curve)
    if (!(1 & sts)) goto error_label;
  }
 else
  {
   *msg = MSINARG;
   goto error_label;
  }
/*
 * Allocate the space necessary to store the surface
 */
 surface.poles = (IGRdouble *) malloc(2 * generating_curve->num_poles * 3 *
                                      sizeof(IGRdouble));
  if (!surface.poles)
   {
    *msg = MANOMEMORY;
    goto error_label;
   }
 if (generating_curve->rational)
  {
   surface.weights = (IGRdouble *) malloc(2 * generating_curve->num_poles *
                                          sizeof(IGRdouble));
    if (!surface.weights)
     {
      *msg = MANOMEMORY;
      goto error_label;
     }
  }
 surface.u_knots = (IGRdouble *) malloc(generating_curve->num_knots *
                                        sizeof(IGRdouble));
  if (!surface.u_knots)
   {
    *msg = MANOMEMORY;
    goto error_label;
   }
 surface.v_knots = &v_knots[0];
/*
 * Generate the surface
 */
 status = BScone(msg,
                 generating_curve,
                 cone_point,
                 &surface);
  if (!status)
   {
    *msg = MSFAIL;
    goto error_label;
   }
/*
 * Fill the instance data and such
 */
 construct_list->geometry = (IGRchar *) &surface;
 sts = om$send(mode = OM_e_wrt_object,
               msg = message GRgraphics.GRconstruct(construct_list),
               senderid = my_id,
               targetid = my_id);
  if (!(1 & sts))
   {
    *msg = MSFAIL;
    goto error_label;
   }
/*
 * End of routine
 */
 *msg = MSSUCC;
 if (!curve && located_curve) free(generating_curve);
 if (surface.poles) free(surface.poles);
 if (surface.weights) free(surface.weights);
 if (surface.u_knots) free(surface.u_knots);
 return(OM_S_SUCCESS);
/*
 * On any error delete the surface
 */
error_label:
 sts = om$send(mode = OM_e_wrt_object,
               msg = message Root.delete(1),
               senderid = my_id,
               targetid = my_id);
 if ((!curve && located_curve) && generating_curve) free(generating_curve);
 if (surface.poles) free(surface.poles);
 if (surface.weights) free(surface.weights);
 if (surface.u_knots) free(surface.u_knots);
 return(OM_E_ABORT);
}

end implementation EMSgenbs;
