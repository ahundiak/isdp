/* ###################   APOGEE COMPILED   ################## */
class implementation EMSelpsoid;

#include "EMS.h"
#include "msdef.h"
#include "bserr.h"

method EMelpsd(
        struct EMesellpsd1 *method_1;           /* If by center, axis, rad */
        struct EMesellpsd2 *method_2;           /* If by foucus, axis length */
        struct GRvg_construct *construct_list;  /* Construction data */
        IGRlong *msg)                           /* Error return code */
/*
 Notes

        Upon exit the completion code will be one of

        - MSSUCC, if successful
        - MSFAIL, if failed to generate results
        - MSINARG, if no placement method was specified

        If a failure occurs, then the object will commit suicide.

        Only 1 method my be specified for constuction.  The first method
        is by center, semi-axis vector, and radius of revolution.  The second 
        method is by 2 focii and the length of the major axis.

        The input arguments are further explained in the specification
        file.

 History

        RLW     12/05/86 : The beginning

 Algorithm

        Call the math routine to generate the surface.
        Post the definition into the database.
*/

{
 extern void    BSellpsd1();
 extern void    BSellpsd2();
 IGRlong        sts;
 struct         IGRbsp_surface surface;
 IGRdouble      poles[7][12][3], u_knots[10], v_knots[15], weights[7][12];
/*
 * Initialize
 */
 *(construct_list->msg) = MSSUCC;
 surface.poles = &poles[0][0][0];
 surface.weights = &weights[0][0];
 surface.u_knots = &u_knots[0];
 surface.v_knots = &v_knots[0];
/*
 * Generate the surface according to which method data was passed in
 */
 if (method_1)
  {
   BSellpsd1(method_1->center, 
             method_1->semi_axis, 
             method_1->radius,
             &surface,
             msg);
   if (*msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto error_label;
    }
  }
 else if (method_2)
  {
   BSellpsd2(method_2->focus0,
             method_2->focus1,
             method_2->major_axis_length,
             &surface,
             msg);
   if (*msg != BSSUCC)
    {
     *msg = MSFAIL;
     goto error_label;
    }
  }
 else
  {
   *msg = MSINARG;
   goto error_label;
  }
/*
 * Fill the instance data and such
 */
 surface.pos_orient = 0;
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
 return(OM_S_SUCCESS);
/*
 * On any error delete the surface
 */
error_label:
 sts = om$send(mode = OM_e_wrt_object,
               msg = message Root.delete(1),
               senderid = my_id,
               targetid = my_id);
 return(OM_E_ABORT);
}

end implementation EMSelpsoid;
