/******************************************************************************
*
* Description:
*
*    This method returns the needed information to polyhedron
*    geometry subform for the review element command.
*
* Overrides:
*    GRreport_defaults at GRgraphics.
*
*
* Abstract
*     
*     This method returns the needed subform information for polyhedron.
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
*     msm     06/03/91      creation data
*
******************************************************************************/


class implementation EMSpolyhdrn;

#include "grimport.h"
#include "msdef.h"
#include "revieweledef.h"
#include "MDreveledef.h"

extern GRreport_output();


method GRreport_defaults(IGRlong *msg; IGRchar *form; IGRint *label;
                         IGRint *list_size; 
                         struct GRreport_processor *processor )
{
  IGRlong status;
  IGRint num_vertices;

  *msg = MSSUCC;
		     /* Use the Polyhedron Geometry subform */
  if (form) strcpy(form, "MDpolyhedra");

  if (label) *label = SYM_ON_FORM;   /* Geometry symbol */
				     /* Determine number of items to report */
  if (list_size) {
     status = om$send (msg = message EMSsolid.EMcount_vertices (msg,
                         &num_vertices),
                   targetid = my_id);
     if ( ! (1 & status & *msg)) 
         return (OM_E_ABORT); 
     if ((num_vertices > 8) || (num_vertices > MAX_NO_VERTICES))
        {
           *msg = EMS_E_InvalidArg;
           return (OM_E_ABORT);
        }
     *list_size = POLYHEDRA_GEOM_SF_NUM_ITEMS + num_vertices;
  }
  if (processor) 		     /* Determine default report function */
    processor->report_function = GRreport_output;

  return(1);
}
end implementation EMSpolyhdrn;
