/******************************************************************************
*
* Description:
*
*    This method returns the needed information to partial cylinder
*    geometry subform for the review element command.
*
* Overrides:
*    GRreport_defaults at GRgraphics.
*
*
* Abstract
*     
*     This method returns the needed subform information for partial cylinder.
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
*     msm     05/31/91      creation data
*
******************************************************************************/


class implementation EMSpcylindr;

#include "grimport.h"
#include "msdef.h"
#include "revieweledef.h"
#include "MDreveledef.h"

#define  PARTLCYL_SYMBOL    98

extern GRreport_output();


method GRreport_defaults(IGRlong *msg; IGRchar *form; IGRint *label;
                         IGRint *list_size; 
                         struct GRreport_processor *processor )
{
  *msg = MSSUCC;
		     /* Use the Partial Cone and Cylinder Geometry subform */
  if (form) strcpy(form, "MDpartconcyl");

  if (label) *label = PARTLCYL_SYMBOL;   /* Geometry symbol */
				     /* Determine number of items to report */
  if (list_size) *list_size = PARTLCYL_GEOM_SF_NUM_ITEMS;

  if (processor) 		     /* Determine default report function */
    processor->report_function = GRreport_output;

  return(1);
}
end implementation EMSpcylindr;

