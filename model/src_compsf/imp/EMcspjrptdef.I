/******************************************************************************
*
* Description:
*
*    This method returns the needed information to construct the surface of
*    projection geometry subform for the review element command.
*
* Overrides:
*    GRreport_defaults at GRgraphics.
*
*
* Abstract
*     
*     This method returns the needed subform information for surface of 
*     projection geometry.
*
*
* Method: GRreport_defaults
*
*  (O) IGRlong		 *msg		 Error Message
*  (O) IGRchar		 *form		 Name of the default form
*  (O) IGRint		 *label		 Title label to display (geometry type)
*  (O) IGRint		 *list_size	 Number of gadgets to fill in on form
*  (O) struct GRreport_processor *processor   Report information
*
* Description:
*
*  This method returns the report defaults including form name, title label,
*  list size, and the default report function in the GRreport_processor 
*  function.  NULL is returned for any arguments which do not
*  have a default.
*
* History:
*
*     msm     05/14/91      creation data
*     amd     02/26/92      modified to take care of single surfaces
******************************************************************************/


class implementation EMSprjcompsf;

#include "grimport.h"
#include "msdef.h"
#include "revieweledef.h"
#include "MDreveledef.h"

#define  COMPSF_PROJECTION_SYMBOL   72

extern GRreport_output();


method GRreport_defaults(IGRlong *msg; IGRchar *form; IGRint *label;
                         IGRint *list_size; 
                         struct GRreport_processor *processor )
{
  OM_S_CHANSELECT to_comps;
  IGRlong status;
  IGRint num_components;

  *msg = MSSUCC;
  status = OM_S_SUCCESS;
 
  status = EMmake_chanselect (GRcmpowner_to_components, &to_comps);

  num_components = 0;

  status = om$send(msg = message GRowner.GRget_number_components
                    (msg, &num_components),
                targetid = my_id);
  EMomerr_hndlr ( status, wrapup, "GRget_number_components");

  if(num_components==1)
   {
    status = om$send(msg = OPPmargs, p_chanselect = &to_comps);
    EMomerr_hndlr ( status, wrapup, "GRreport_defaults");   
    goto wrapup;
   }

  /* Use the Comp Curve Geometry subform */

  if (form) strcpy(form, "MDcompsfrvpr");

  if (label) *label = COMPSF_PROJECTION_SYMBOL;   /* Geometry symbol */
				     /* Determine number of items to report */
  if (list_size) *list_size = COMPSFPJ_GEOM_SF_NUM_ITEMS;

  if (processor) 		     /* Determine default report function */
    processor->report_function = GRreport_output;

wrapup:

  return(1);
}
end implementation EMSprjcompsf;

