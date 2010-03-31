/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;

#include "EMS.h"
%safe
#include <math.h>               /* tan */
%endsafe
#include "msdef.h"
#include "maerr.h"
#include "bserr.h"
#include "emsgetgeom.h"

extern OMuword  OPP_EMSproject_class_id;


#argsused
method EMdrafted_surface(
     IGRlong                 *EMmsg;
     struct IGRbsp_curve     *curve;
     struct GRlc_info        *located_curve;
     struct IGRbsp_curve     *draft_cv;
     IGRvector               draft_vec;
     IGRdouble               draft_ang;
     IGRboolean              right_side;			
     IGRboolean              fillet;
     IGRuchar                curve_type;
     IGRboolean              pos_orient_flag;
     GRobjid                 *new_obj;
     struct GRvg_construct   *construct_list)

/*
 Notes

    Upon exit the completion code will be one of

	EMS_S_Success           if all goes well
        EMS_E_InvalidArg        if bad arguments
        EMS_I_BSerror           if offset (math) fails
	EMS_E_SurfaceError      if EMruled_surface fails

 History

   RV   12/31/87           Creation.
   RC   03/22/88           Modified the arguments and code such
                           two curve buffers can be passed in.
                           Also, to change the class if surface
                           of projection can be constructed.
   RC  02/06/89            Always create a ruled surface even though
                           the draft angle is 0. The draft angle
                           being 0 does not mean that the offset 
                           curve is translation of original curve.
                           It might have been trimmed due the
                           offset of its adjoining curves by a 
                           different angle.
   SM	13-Feb-89	   Fixed a bug because of which return code was not
			   being set correctly in case a failure occured
			   in EFdraftcv() and caller was always returned
			   a success code.   
   PP   10/26/89           Fixed a memory fault occuring  with 0 draft
                           angle and curve object being passed in instead of
                           curve buffer. output_cv was not defined and hence
                           the memory fault. See comments. 
   NP	08/18/92	   Modified for ANSI complinace by casting "end_pts"
			   as "IGRpoint *" in message "EMruled_surface".
  Jack  01/11/93           Removed code that was commented out for calling
                           EMplace_surface_of_projection.  It's been 4 years,
                           I don't think we'll go back to doing it that way.
                           Also, moved implementation from EMSgenbs to EMSsubbs
                           to aid in analytic surface creation.

 Algorithm

*/

{

IGRint     OM_stat;
IGRint     rc, num_draft_cvs, table;
IGRdouble  end_pts[6];
struct IGRbsp_curve  *input_cv = NULL, *output_cv = NULL;
extern IGRboolean     BSfreecv();
extern void           BScveval();
extern void           EFdraftcv();

  OM_stat = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

/*
 * Get the geometry of the curve if not sent in
 */

 if (curve)
 {
   input_cv = curve;
 }
 else if (located_curve)
 {
   EMS_GET_GEOMETRY(rc, EMmsg, located_curve, TRUE, input_cv)
   EMerr_hndlr (!(1&rc), *EMmsg, EMS_E_Fail, error_label);  
 }
 else
 {
   *EMmsg = EMS_E_InvalidArg;
   goto error_label;
 }

 if (!draft_cv)
 {

/*
 * For zero draft angle with no draft_cv the same was memory faulting
 * since output_cv was not defined. We ought to call EFdraftcv which
 * returns the output curve projected by the appropriate distance.
 * pp (10/26/89)
 */

     EFdraftcv( EMmsg, 1, &input_cv, right_side, draft_vec, TRUE,
                 &draft_ang, NULL, input_cv->phy_closed, fillet,
                &num_draft_cvs, &output_cv, &table);
     if (*EMmsg == EMS_I_InvalidArg || *EMmsg == EMS_I_BSerror)
	 goto error_label;
     EMerr_hndlr(!(1&*EMmsg) || !num_draft_cvs,*EMmsg,EMS_E_Fail, 
		error_label);
 }
 else
   output_cv = draft_cv;

 /*
  * Construct the appropriate surface.
  */

    BScveval (input_cv, 0., 0, end_pts, &rc);
    EMerr_hndlr (rc != BSSUCC,*EMmsg,EMS_E_BSerror,error_label);
    
    BScveval (output_cv, 0., 0, &end_pts[3], &rc);
    EMerr_hndlr (rc != BSSUCC,*EMmsg,EMS_E_BSerror,error_label);
    
    OM_stat = om$send (msg = message EMSsubbs.EMruled_surface (
                         input_cv, NULL, output_cv, NULL, 0,
                         NULL, NULL, (IGRpoint *)end_pts, pos_orient_flag, 
                         NULL, NULL, FALSE, FALSE,
                         construct_list, EMmsg),
                       targetid = my_id);
    EMerr_hndlr(!(1&OM_stat&*EMmsg),*EMmsg,EMS_E_SurfaceError,error_label);


error_label:

EMWRAPUP (*EMmsg, OM_stat, "In EMSsubbs.EMdrafted_surface");

/*
 * On any error delete the surface
 */

if (!(1& *EMmsg & OM_stat) || *EMmsg == EMS_I_BSerror ||
			      *EMmsg == EMS_I_InvalidArg)
{
    OM_stat = om$send(mode = OM_e_wrt_object,
               msg = message Root.delete(1),
               senderid = my_id,
               targetid = my_id);

} /* if (!(1& *EMmsg & OM_stat)) */

if ((!curve && located_curve) && input_cv) free(input_cv);
if (!draft_cv && output_cv)  BSfreecv (&rc, output_cv);
return (OM_stat);

}

end implementation EMSsubbs;
