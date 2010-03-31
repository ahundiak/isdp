/******************************************************************************
*
* Description:
*
*    This method returns the needed information to construct the surface
*    geometry subform for the review element command.
*
* Overrides:
*    GRreport_defaults at GRgraphics.
*
*
* Abstract
*     
*     This method returns the needed subform information for surface 
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
*     msm     06/07/91      creation data
*
******************************************************************************/


class implementation EMSsubbs;

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
				     /* Use the Surface Geometry subform */
  if (form) strcpy(form, "MDsurface");

  if (label) *label = SYM_ON_FORM; /*symbol already on the form.*/

				     /* Determine number of items to report */
  if (list_size) *list_size = SURF_GEOM_SF_NUM_ITEMS;

  if (processor) 		     /* Determine default report function */
    processor->report_function = GRreport_output;

  return(1);
}
end implementation EMSsubbs;
