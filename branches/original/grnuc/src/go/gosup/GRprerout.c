/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRprerout
 
     Abstract: This routine serves as a utility to the routers by 
	      loading the needed data structure and checking for
	      the validity of the number of objects and/or values
	      for each event.
-----
%SC%

     VALUE = IGRboolean GRprerout(msg, events, num_events, max_id, 
				  max_val)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     events	  GRevent	 array of pointers to GRevents
     num_events	  IGRshort	 number of events
     max_id	  IGRshort	 the maximum number of objects
			   	 associated with each event
     max_val	  IGRshort	 the maximum number of values 
				 associated with each event

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSINVARG - invalid number of
				 objects or values associated with 
				 one of the events

     rtevents     RTevent	 array of RTevents

     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - mission accomplished, congratulations.
                        FALSE- invalid input

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  02/04/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine serves as a utility to the routers by loading the 
common router data structure and checking the validity of the number
of objects and/or values associated with each event.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "grrouterpriv.h"
#include "ex.h"
#include "grio.h"

IGRboolean GRprerout(msg,events,num_events,max_id,max_val,rtevents)

	   IGRlong           *msg;		/* return code		     */
	   struct GRevent    *events[];		/* events		     */
	   IGRshort          *num_events;	/* number of events	     */
	   IGRshort          *max_id;		/* max objects per event     */
	   IGRshort          *max_val;		/* max values per event	     */
	   struct GRrtevent  *rtevents;		/* router events	     */

{

  IGRshort i,j,k;				/* indexes		     */


  *msg = MSSUCC;

  for( i=0; i < *num_events; ++i)
     {
       if( events[i]->response == DATA )	/* is this a data point?     */
         {
           rtevents[i].type = GRD_POINT;	/* type of point	     */
       						/* subtype of point	     */

	   if( events[i]->subtype > GRPF )
	     {
	       rtevents[i].subtype = GRREG;
	     }
	   else
	     {
               rtevents[i].subtype = events[i]->subtype;
	     }
	       					/* load the point	     */

	   rtevents[i].pt[0] = events[i]->event.button.x;
	   rtevents[i].pt[1] = events[i]->event.button.y;
	   rtevents[i].pt[2] = events[i]->event.button.z;

						/* load the view information */

	   rtevents[i].viewid.objid = events[i]->event.button.objid;
	   rtevents[i].viewid.osnum = events[i]->event.button.osnum;

						/* see if point is regular   */

	   if( rtevents[i].subtype != GRREG )
	     {					/* no, get rest of data	     */

	       rtevents[i].num_id = events[i]->num_id;

	       if( rtevents[i].num_id <= *max_id )
	         {
						/* get the objects and data  */
		   for(j = 0; j < rtevents[i].num_id; ++j)
		      {
		        rtevents[i].objs[j].osnum =
				events[i]->located_object[j].located_obj.osnum;
			rtevents[i].objs[j].objid =
				events[i]->located_object[j].located_obj.objid;
			rtevents[i].objs[j].parms =
				events[i]->located_object[j].geom_parms;
			rtevents[i].objs[j].mat_type =
		                events[i]->located_object[j].module_info.md_env.matrix_type;
			
			for(k=0;k<16;++k)
			   {
			     rtevents[i].objs[j].matrix[k] =
				events[i]->located_object[j].module_info.md_env.matrix[k];
			   }
		      }

		   rtevents[i].num_val = events[i]->num_val;
			
		   if( rtevents[i].num_val <= *max_val )
		     {
						/* get all values	     */
                       for( j=0; j < rtevents[i].num_val; ++j )
		          {
		            rtevents[i].val[j] = events[i]->values[j];
		          }
		     }
		   else
		     {
		       *msg = MSINARG;		/* too many values	     */
		     }
		 }
	       else
	         {
	           *msg = MSINARG;		/* too many objects	     */
	         }
	     }
	   else
	     {
	       rtevents[i].num_id  = 0;
	       rtevents[i].num_val = 0;
	     }
         }
       else
         {
	   if( events[i]->response == VALUE ) 	/* data type is a value	     */
	     {
	       rtevents[i].type = GRD_VALUE;	/* set the type to value     */

	       rtevents[i].num_id = 0;		/* set number of objects to 0*/
	       rtevents[i].num_val = 1;		/* set number of values to 1 */

	       rtevents[i].val[0] = events[i]->event.value;
	     }
	   else
	     {
	       *msg = MSINARG;

	       break;
	     }
	 }
     }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */
