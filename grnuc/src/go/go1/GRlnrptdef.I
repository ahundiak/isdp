/******************************************************************************
*
* Description:
*
*    This method returns the needed information to construct linear
*    subforms for the review element command.
*
* Overrides:
*    GRreport_defaults at GRgraphics.
*
*
* Abstract
*     
*     This method returns the needed subform information for linear geometries.
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
*    mark ferguson	04/13/90    creation date.
*
******************************************************************************/


class implementation GRlinear;

#include "grimport.h"
#include "godef.h"
#include "msdef.h"
#include "revieweledef.h"
/*#include "report.h"*/

extern GRreport_output();

method GRreport_defaults( IGRlong *msg; IGRchar *form;
                          IGRint *label; IGRint *list_size;
                          struct GRreport_processor *processor )
{
  struct IGRpolyline polyline;	     /* Polyline structure */
  IGRchar	     classname[GRNAME_SIZE];  /* Class name */
  GRclassid	     classid;	     /* Object class id */
  IGRint	     action = 0;     /* Get only number of points for polyline*/
  IGRlong	     status;	     

  *msg = MSSUCC;


  if (form) strcpy(form, "GRLinearGeom"); /* Use the Linear Geometry subform */

  if (label)            	     /* Determine geometry symbol for form */
  {
     status = om$get_classid(objid = my_id,
			     p_classid = &classid);

     if (status & 1)
     {
       if (om$is_ancestry_valid(subclassid = classid,
				superclassname = "GRinfline") 
	   == OM_S_SUCCESS)
       {
	 *label = LINEAR_GEOM_SF_BOTH_INFLINE;
       }
       else if (om$is_ancestry_valid(subclassid = classid,
                                superclassname = "GRlineseg") 
		== OM_S_SUCCESS)
       {
	 *label = LINEAR_GEOM_SF_LINESEG;
       }
       else if (om$is_ancestry_valid(subclassid = classid,
                                superclassname = "GRorthlnst") 
		== OM_S_SUCCESS) 
       {
	 *label = LINEAR_GEOM_SF_ORLNSTR;
       }
       else if (om$is_ancestry_valid(subclassid = classid,
                                superclassname = "GRorthpoly") 
		== OM_S_SUCCESS)
       {
	 *label = LINEAR_GEOM_SF_ORTHPG;
       }
       else if (om$is_ancestry_valid(subclassid = classid,
                                superclassname = "GRpllnstr") 
		== OM_S_SUCCESS)
       {
	 *label = LINEAR_GEOM_SF_PLLNSTR;
       }
       else if (om$is_ancestry_valid(subclassid = classid,
                                superclassname = "GRpolygon") 
		== OM_S_SUCCESS)
       {
	 *label = LINEAR_GEOM_SF_POLYGON;
       }
       else if (om$is_ancestry_valid(subclassid = classid,
                                superclassname = "GRpoint") 
		== OM_S_SUCCESS) 
       {
	 *label = LINEAR_GEOM_SF_POINT;
       }
       else if (om$is_ancestry_valid(subclassid = classid,
                                superclassname = "GRlinestr") 
		== OM_S_SUCCESS)
       {
	 *label = LINEAR_GEOM_SF_LINESTR;
       }
/*       else if (om$is_ancestry_valid(subclassid = classid,
                                superclassid = OPP_GRfence_class_id) 
		== OM_S_SUCCESS)
       {
	 *label = LINEAR_GEOM_SF_FENCE;
       }*/
       else
       {
	 *msg = MSFAIL;
	 status = OM_I_INVANCESTRY;
	 *label = -1;			    /* Don't return a title symbol */
	 goto wrapup;
       }
     }
  }   

  if (list_size)
  {					    /* Get the number of points */ 
    status = om$send (msg =  message GRlinear.GRgetpolyline
  				    (msg,
				     NULL,
				     NULL,
				     &action,
				     &polyline),
		      targetid = my_id);
  
    if (!(status & 1))
    {			     /* Return minimal number of fillable gadgets */ 	
      *list_size = GRLINEAR_FORM_FIXED_SIZE;  
      goto wrapup;
    }
		
			      /* Determine number of fillable gadgets on form */
    *list_size = polyline.num_points + GRLINEAR_FORM_FIXED_SIZE;
  }

  if (processor)                     /* Determine default report function */
    processor->report_function = GRreport_output;

wrapup:
  return(status);

}
end implementation GRlinear;
