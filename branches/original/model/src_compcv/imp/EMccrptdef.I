/******************************************************************************
*
* Description:
*
*    This method returns the needed information to construct the composite 
*    curve geometry subform for the review element command.
*
* Overrides:
*    GRreport_defaults at GRgraphics.
*
*
* Abstract
*     
*     This method returns the needed subform information for composite curve
*     geometry.
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
*     msm     05/13/91      creation data
*
******************************************************************************/


class implementation GRcompcurve;

#include "grimport.h"
#include "msdef.h"
#include "revieweledef.h"
#include "MDreveledef.h"

extern GRreport_output();


method GRreport_defaults(IGRlong *msg; IGRchar *form; IGRint *label;
                         IGRint *list_size; 
                         struct GRreport_processor *processor )
{
  *msg = MSSUCC;
				     /* Use the Comp Curve Geometry subform */
  if (form) strcpy(form, "GRcompcv");

  if (label) *label = SYM_ON_FORM;   /* Geometry symbol is already displayed */
				     /* Determine number of items to report */
  if (list_size) *list_size = COMPCV_GEOM_SF_NUM_ITEMS;

  if (processor) 		     /* Determine default report function */
    processor->report_function = GRreport_output;

  return(1);
}
end implementation GRcompcurve;

