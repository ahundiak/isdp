/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This function gets the geometry of a curve or surface object using
 various options.  The reasoning behind putting this in a function is
 to consolidate the functionality into one place and to reduce the
 number of places where the code uses heavily nested structures.

 Arguments
 
 lc_info                The located curve or surface object.
 is_a_curve             Is the object a curve or surface?
 is_directed            If it's a curve then should I look at the polygon_inx
                        to determine whether to reverse the curve?
 separate_mallocs       Do you plan on calling realloc with this geometry?
 resultant_geometry     The geometry
 msg                    Error return code - one of MSSUCC, MANOMEMORY,
                        MSFAIL

 History

jBk 06 Jul 1989 Made certain returned message codes are checked
                properly in order to prevent a false return of
                okay message codes by this function.

 rlw : 12/05/86 : Created an include file named "emsgetgeom.h"
 rlw : 11/18/87 : Put the contents of the include file, plus more, into
                  this function
 rlw : 02/28/89 : Modified to add conditional compilation statements
                  for the I/DRAW product.
 Sudha   06/02/93        modified to include for BSprototype headers
 */

class implementation GRvg;

# ifndef DEBUG
# define DEBUG 0
# endif

%safe
#include <math.h>
%endsafe

#include "EMS.h"
#include "EMSlogic.h"
#include "ems_m_inc.h"
#include "bssf_copy.h"
#include "bsrev_cv.h"
#include "bscv_copy.h"
#include "bsallocsf.h"
#include "bsalloccv.h"

IGRlong EMget_the_geometry(
 lc_info,
 is_a_curve,
 is_directed,
 separate_mallocs,
 my_stupid_id,
 resultant_geometry,
 msg)

struct          GRlc_info *lc_info;
IGRboolean      is_a_curve;
IGRboolean      is_directed;
IGRboolean      separate_mallocs;
OM_S_OBJID      my_stupid_id;
IGRchar         **resultant_geometry;
IGRlong         *msg;

{ 
 IGRchar        *generic_pointer;
 IGRlong        num_bytes;
 IGRint         sts; 
 struct         GRid *id;
 struct         GRmdenv_info *mdenv_info;
/*
 * Initialize
 */
 generic_pointer = NULL;
 *resultant_geometry = NULL;
 id = &lc_info->located_obj;
 mdenv_info = &lc_info->module_info.md_env;

/*
 * Compute the number of bytes required
 */
 sts = om$send(
   msg = message GRvg.GRgetsize(
    msg, 
    &mdenv_info->matrix_type,
    mdenv_info->matrix,
    &num_bytes), 
   senderid = my_stupid_id, 
   targetid = id->objid, 
   targetos = id->osnum); 
  if (!(1 & sts & *msg))
   goto wrapup;
/*
 * Malloc the required memory
 */
 generic_pointer = (IGRchar *) malloc(num_bytes);
  if (!generic_pointer)
   {
    *msg = MANOMEMORY; 
    goto wrapup;
   }
/*
 * Get the geometry
 */
 sts = om$send(
   msg = message GRvg.GRgetgeom(
    msg, 
    &mdenv_info->matrix_type,
    mdenv_info->matrix,
    generic_pointer),
   senderid = my_stupid_id, 
   targetid = id->objid, 
   targetos = id->osnum); 
  if (!(1 & sts & *msg))
   goto wrapup;
/*
 * Branch based on the type of 
 * geometry required.
 */
 if (is_a_curve)
  {
   if (is_directed &&
       lc_info->geom_parms.polygon_inx)
    {
     IGRboolean         status;
     IGRlong            loc_msg;

     status = BSrev_cv(         /* Never fails */
      &loc_msg,
      (struct IGRbsp_curve *)generic_pointer);
    }
   if (separate_mallocs)
    {
     IGRboolean         status;
     IGRlong            loc_msg;
     struct             IGRbsp_curve *curve;

     curve = (struct IGRbsp_curve *) generic_pointer;
     curve->num_boundaries = 0;
     BSalloccv(
       curve->order,
       curve->num_poles,
       curve->rational,
       curve->num_boundaries,
       (struct IGRbsp_curve **)resultant_geometry,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *msg = MANOMEMORY;
        *resultant_geometry = NULL;
        goto wrapup;
       }
     status = BScv_copy(                /* Never fails */
      &loc_msg,
      curve,
      (struct IGRbsp_curve *) *resultant_geometry);
    } /* if (separate_mallocs) */
   else
    {
     *resultant_geometry = generic_pointer;
     generic_pointer = NULL;
    }
  } /* if (is_a_curve) */
#ifndef IDRAW
 else
  {
   if (separate_mallocs)
    {
     IGRboolean         status;
     IGRlong            loc_msg;
     struct             IGRbsp_surface *surface;

     surface = (struct IGRbsp_surface *) generic_pointer;
     surface->num_boundaries = 0;
     BSallocsf(
       surface->u_order,
       surface->v_order,
       surface->u_num_poles,
       surface->v_num_poles,
       surface->rational,
       surface->num_boundaries,
       (struct IGRbsp_surface **)resultant_geometry,
       &loc_msg);
      if (loc_msg != BSSUCC)
       {
        *msg = MANOMEMORY;
        *resultant_geometry = NULL;
        goto wrapup;
       }
     status = BSsf_copy(                /* Never fails */
      &loc_msg,
      surface,
      (struct IGRbsp_surface *) *resultant_geometry);
    } /* if (separate_mallocs) */
   else
    {
     *resultant_geometry = generic_pointer;
     generic_pointer = NULL;
    }
  } /* ELSE FOR if (is_a_curve) */
#endif
/*
 * eof
 */
wrapup:
 if (generic_pointer)
  free(generic_pointer);

 if (EMSokay (*msg) AND EMSokay (sts))
 {
  *msg = MSSUCC;
  return TRUE;
 }
 else
 {
  if (EMSokay (*msg)) *msg = MSFAIL;
  return FALSE;
 }
}

end implementation GRvg;
