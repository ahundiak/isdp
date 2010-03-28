/******************************************************************************
*
* Description:
*
*    This method returns the needed information to construct the elliptical arc
*    geometry subform for the review element command.
*
* Overrides:
*    GRreport_defaults at GRgraphics.
*
*
* Abstract
*     
*     This method returns the needed subform information for elliptical arc
*      geometry.
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
*  and list size.  NULL is returned for any arguments which do not
*  have a default.
*
* History:
*
*    msm	04/30/91    creation date.
*
******************************************************************************/


class implementation GRellarc;

#include "grimport.h"
#include "msdef.h"
#include "revieweledef.h"

#define ELL_ARC_ARC_SYMBOL 31

extern GRreport_output();


method GRreport_defaults( IGRlong *msg; IGRchar *form; IGRint  *label;
                          IGRint  *list_size; 
                          struct GRreport_processor *processor )
{
  IGRint 	status;

  *msg = MSSUCC;
				     /* Use the Elliptical Arc Geometry form */
  if (form) strcpy(form, "GREllArcGeom");

  if (label) *label = ELL_ARC_ARC_SYMBOL;   /* Elliptical arc geometry */

 				     /* Determine number of items to report */
  if (list_size) *list_size = GRELLARC_FORM_FIXED_SIZE;

  if (processor)                     /* Determine default report function */
    processor->report_function = GRreport_output;

  return(1);
}
end implementation GRellarc;

