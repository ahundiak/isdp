/*
Description   

The following methods will return the information from the
first component.

Notes

I have taken Gray's logic and mauled it because it does not work
properly for our composites.  This is because the state tree can
take away all the children of a composite and yet leave the composite
in the state tree.  In order to correct this situation I have modified
the logic to search until a valid component is found.  The search is
bottom up.

History

10/15/87 : gw  : Design and Creation date
02/15/89 : rlw : Mauled Gray's code
*/

class implementation EMScomposite;

#include "EMScc.h"

#include "gocmacros.h"
#include "grerr.h"
#include "msdef.h"

method GRgethprops(
 IGRlong *msg; 
 IGRuint *props)
{
 IGRlong           sts, i;
 IGRuint	   number_of_children;
 OM_S_CHANSELECT   children;
/*
 * Initialize
 */
 *msg = MSFAIL;
/*
 * Build the required channel selector
 */
 children.type = OM_e_name;
 children.u_sel.name = "GRcmpowner.to_components";
 sts = om$get_channel_count(
   object = me,
   p_chanselect = &children,
   count = &number_of_children);
  if (! (1 & sts)) goto wrapup;
/*
 * Loop over all my children until one of them answers
 * properly or all are exhausted.
 */
 for (i = 0; i < number_of_children; i++)
  {
   *msg = MSFAIL;
   sts = om$send(
     msg = message GRgraphics.GRgethprops(
      msg, 
      props),
     p_chanselect = &children,
     from = i,
     to = i);
    if ((1 & sts) && (1 & *msg)) return(sts);
  } /* for (i = 0; i < number_of_children; i++) */
/*
 * eof
 */
wrapup:
 if (1 & *msg) *msg = MSFAIL;
 if (1 & sts) sts = OM_E_ABORT;
 return(sts);
}

method GRgeomprops(
 IGRlong *msg; 
 IGRshort *matrix_type; 
 IGRmatrix matrix; 
 struct GRprops *properties)
{
 IGRshort          local_mx_type;
 IGRlong           sts, i;
 IGRuint	   number_of_children;
 IGRmatrix         local_matrix;
 OM_S_CHANSELECT   children;
/*
 * Initialize
 */
 *msg = MSFAIL;
/*
 * Build the required channel selector
 */
 children.type = OM_e_name;
 children.u_sel.name = "GRcmpowner.to_components";
 sts = om$get_channel_count(
   object = me,
   p_chanselect = &children,
   count = &number_of_children);
  if (! (1 & sts)) goto wrapup;
 /*
  *  Get the component matrix.
  */
 sts = om$send(
   msg = message GRowner.GRget_matrix(
    msg, 
    matrix_type,
    matrix, 
    &local_mx_type, 
    local_matrix), 
   targetid = my_id);
  if (! (1 & sts)) goto wrapup;
/*
 * Loop over all my children until one of them answers
 * properly or all are exhausted.
 */
 for (i = 0; i < number_of_children; i++)
  {
   *msg = MSFAIL;
   sts = om$send(
     msg = message GRvg.GRgeomprops(
      msg, 
      &local_mx_type, 
      local_matrix, 
      properties), 
     p_chanselect = &children, 
     from = i,
     to = i);
    if ((1 & sts) && (1 & *msg)) return(sts);
  } /* for (i = 0; i < number_of_children; i++) */
/*
 * eof
 */
wrapup:
 if (1 & *msg) *msg = MSFAIL;
 if (1 & sts) sts = OM_E_ABORT;
 return(sts);
}

method GRgetsymb(
 IGRlong *msg; 
 struct GRsymbology *symb)
{
 IGRlong           sts, i;
 IGRuint	   number_of_children;
 OM_S_CHANSELECT   children;
/*
 * Initialize
 */
 *msg = MSFAIL;
/*
 * Build the required channel selector
 */
 children.type = OM_e_name;
 children.u_sel.name = "GRcmpowner.to_components";
 sts = om$get_channel_count(
   object = me,
   p_chanselect = &children,
   count = &number_of_children);
  if (! (1 & sts)) goto wrapup;
/*
 * Loop over all my children until one of them answers
 * properly or all are exhausted.
 */
 for (i = 0; i < number_of_children; i++)
  {
   *msg = MSFAIL;
   sts = om$send(
     msg = message GRvg.GRgetsymb(
      msg, 
      symb),
     p_chanselect = &children, 
     from = i,
     to = i);
    if ((1 & sts) && (1 & *msg)) return(sts);
  } /* for (i = 0; i < number_of_children; i++) */
/*
 * eof
 */
wrapup:
 if (1 & *msg) *msg = MSFAIL;
 if (1 & sts) sts = OM_E_ABORT;
 return(sts);
}

end implementation EMScomposite;
