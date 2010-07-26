/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRsortevents
 
     Abstract: This routine sorts and orders the event types for
	      the command object routers.
-----
%SC%

     VALUE = GRsort_events(msg,event_types,num_events,total,ordered_types,order)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     event_types  IGRshort	 array of event subtypes
     num_events   IGRshort	 number of event subtypes
     total	  IGRshort	 total number of possible event subtypes

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful

     ordered_types IGRshort	 array for ordered subtypes
     order	  IGRshort	 array of order indexes
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - order array found
			FALSE - order array not found

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH  04/16/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine sorts the event subtypes from the event_types into the
ordered_types. Then it determines the order of the indexes and places
the ordered indexes into the array order.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "msdef.h"

IGRboolean GRsort_events(msg,event_types,num_events,total,ordered_types,order)

           IGRlong     *msg;		/* return code			*/
	   IGRshort    *event_types;	/* the event types		*/
	   IGRshort    *num_events;	/* number of events		*/
	   IGRshort    *total;		/* total number possible events */
	   IGRshort    *ordered_types;  /* ordered event types		*/
	   IGRshort    *order;		/* output order array		*/

{
  IGRshort i,j;				/* indexes			*/
  IGRshort min_i;			/* index			*/
  IGRshort temp;
  IGRshort min;

  *msg = MSSUCC;

  for(i=0; i < *num_events; ++i)
     {
       ordered_types[i] = event_types[i];
     }

  for(i=0; i < *num_events; ++i)        /* sort the events wrt the	*/
     {                		        /* event types.			*/
       min_i = i;
       min = ordered_types[i];

       for(j=i+1; j < *num_events; ++j)
          {
            if( ordered_types[ j ] < min )
              {
		min_i = j;
		min = ordered_types[j];
              }
          }

       temp = ordered_types[i];
       ordered_types[i] = ordered_types[min_i];
       ordered_types[min_i] = temp;
       
     }

  for(i=0; i < *num_events; ++i)
     {
       for(j=0; j < *num_events; ++j)
          {
	    if( event_types[j] == ordered_types[i] )
	      {
		order[i] = j;
		event_types[j] += *total;

                break;
	      }
          }
     
     }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */

