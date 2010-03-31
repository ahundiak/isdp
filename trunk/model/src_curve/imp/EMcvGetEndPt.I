/* ###################   APOGEE COMPILED   ################## */
class implementation GRcurve;

#include "EMS.h"
#include <stdio.h>
#include "msdef.h"

/* igr.h replacement */

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* # include "grdef.h" */
#include "emserr.h"
#include "bserr.h"
#include "bsdistptpts.h"
#include "bsdistptli.h"

/*
void EMgetendpnt(  msg, 
		   event,
		   bore_event,
		   ModuleInfo,
		   connect_tol,
		   my_id,
		   start_pnt,
		   stop_pnt,
		   end_of_interest)

Abstract
	This utility function gets the end points of a curve object and
	determines the end point closest to the boreline

Arguments
		
	msg		error return code
	event		contains the object whose end points are desired 
	bore_event	contains the borelocate point and window info
	ModuleInfo	Module info of the module
	connect_tol	tolerance to determine if the curve is closed
	my_id		needed to send message
	start_pnt	start point of the curve
	stop_pnt	end point of the curve
	end_of_interest 0 if the start point is closer to boreline
			1 if the stop point is closer to the boreline
			<0 if curve is closed

History
	gk	02/12/87	the glorious birthday
    dhm 01/15/88    changed end_of_interest to be an IGRint
    Sudha  06/16/93     Modified for BSprototype ansification
*/

void EMgetendpnt(  msg, 
		   event,
		   bore_event,
		   ModuleInfo,
		   connect_tol,
		   my_id,
		   start_pnt,
		   stop_pnt,
		   end_of_interest)
		
IGRlong			*msg;
struct GRevent		*event;
struct GRevent  	*bore_event;
struct GRmd_env 	*ModuleInfo;
IGRdouble	 	 connect_tol;
OM_S_OBJID	 	 my_id;
IGRpoint	 	 start_pnt;
IGRpoint	 	 stop_pnt;
IGRint			*end_of_interest;

{
  IGRlong		loc_msg, status;
  struct IGRline 	line_struct;
  IGRpoint	 	line_pnt1, line_pnt2;
  IGRdouble		start_dist, stop_dist;
 extern  IGRboolean  CObrln();
  IGRboolean		logstat;


  status = om$send(msg = message GRcurve.GRendpts(&loc_msg,
		   		  &ModuleInfo->md_env.matrix_type,
		    		   ModuleInfo->md_env.matrix,
				   start_pnt, stop_pnt),
		   targetid = event->located_object[0].located_obj.objid,
		   targetos = event->located_object[0].located_obj.osnum);

  EMomerr_hndlr(status, wrapup, "EMgetendpnt.GRendpnts");
  EMerr_hndlr(EMis_error(loc_msg), *msg, loc_msg, wrapup);

/* Is the object closed? */

  if( BSdistptpts(&loc_msg, start_pnt, stop_pnt) < (connect_tol*connect_tol) )
   {
     *end_of_interest = -1;
     *msg = MSSUCC;
     return;
   }

/* Get the boreline */

  line_struct.point1 = (IGRdouble *)&line_pnt1[0];
  line_struct.point2 = (IGRdouble *)&line_pnt2[0];

  logstat = CObrln(&loc_msg, &my_id, bore_event, &line_struct);

  if( !logstat )
   {
     fprintf(stderr, "EMgetendpnt: bore line generation error = %d",loc_msg);
     status = OM_E_ABORT;
     *msg = MSFAIL;
     goto wrapup;
   }
  else
     *msg = MSSUCC;


/* Compute distance between bore line and end points */

  logstat = BSdistptli(&loc_msg, start_pnt, line_pnt1, line_pnt2, &start_dist);
  logstat = BSdistptli(&loc_msg, stop_pnt,  line_pnt1, line_pnt2, &stop_dist);

  if( start_dist <= stop_dist )
	*end_of_interest = 0;
  else
	*end_of_interest = 1;

wrapup:
  return;
}

end implementation GRcurve;

