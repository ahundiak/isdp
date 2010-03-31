/* ###################   APOGEE COMPILED   ################## */

class implementation EMSpcone;

# include "EMS.h"
# include "msdef.h"
# include "EMSerrordef.h" /* for EMSerror definitions */
# include "emsedgedef.h" /* for edge type definitions */
# include "gocmacros.h"     /*  GRgetabsg macro */
# include "EMSprop.h"     /* For EMED_DEGENERATE */

method EMget_natedge_info (
    IGRlong                     *EMmsg;
    struct GRmdenv_info         *md_env;
    IGRuchar            *curve_type;
    IGRushort           *edge_props) 

/* *****************************************************************
Description
        The method returns the curve type and the edge properties
        of the natural edges belonging to a partial cone.

        Input
          md_env   : module enviroment information. May be set to NULL, as the
                     method does not use this information
          
        Output
          curve_type : the curve type of the natural edges. An array of size
                     four is expected to be allocated coming in.
          edge_props : the edge properties of the natural edges. An array of
                     size four is expected to be allocated coming in.
          EMmsg      : completion code

Assumptions 
        This assumes that the surface is order 2 in one direction
Notes
        Upon exit the completion code will be one of the following:
         EMS_S_Success  : if successful (should be always successful)

History

        PP : 05/04/88           Fixed a bug wherein the the degenerate bit
                                was not being set right
        PP : 10/13/87           creation

******************************************************************** */

{
 IGRlong status;
 IGRchar *cache_ptr = NULL;
 IGRshort i, lineind0, lineind1, curveind0, curveind1;
 IGRboolean degn1, degn2;
 struct IGRbsp_surface *surf;

 *EMmsg = EMS_S_Success;

  GRgetabsg (&status, &md_env->matrix_type, md_env->matrix,
              &cache_ptr, i);
  EMerr_hndlr (!(1&status),*EMmsg,EMS_E_Fail,wrapup);

  surf = (struct IGRbsp_surface *) cache_ptr;

  if (surf->u_order == 2)
  {
   lineind0 = 1;
   lineind1 = 3;
   curveind0 = 0;
   curveind1 = 2;
  }
  else if (surf->v_order == 2)
  {
   lineind0 = 0;
   lineind1 = 2;
   curveind0 = 1;
   curveind1 = 3;
  }
  else
  {
   *EMmsg = EMS_E_InvalidArg;
   goto wrapup;
  }
  

 EMtestdegn (EMmsg, surf, curveind0, &degn1);
 if (!(1&*EMmsg)) goto wrapup;
  

 EMtestdegn (EMmsg, surf, curveind1, &degn2);
 if (!(1&*EMmsg)) goto wrapup;

 if (curve_type)
 {
  curve_type[lineind0] = EMlinesegment;
  curve_type[lineind1] = EMlinesegment;
  if (degn1)
    curve_type[curveind0] = EMpoint;
  else
   curve_type[curveind0] = EMcircular_arc;
  if (degn2)
    curve_type[curveind1] = EMpoint;
  else
    curve_type[curveind1] = EMcircular_arc;
 }

 if (edge_props)
 {
   for (i=0;i<4;i++)
    edge_props[i] = 0;
 }

   if (degn1) edge_props[curveind0] |= EMED_DEGENERATE;
   if (degn2) edge_props[curveind1] |= EMED_DEGENERATE;

wrapup:
 if (cache_ptr) GRabsg_del(cache_ptr);
 return (OM_S_SUCCESS);

}
end implementation EMSpcone;
