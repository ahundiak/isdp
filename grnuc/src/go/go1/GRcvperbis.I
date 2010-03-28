/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS  NAME:	GRcurve
     METHOD NAME:	GRperbis

     Abstract: This routine finds the perpendicular bisector of a
	      GRcurve classed object.
	
-----
%SC%    

     GRperbis(msg,mat_type,matrix,ref_parms,norm_vc,proj_pt,bisector)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   ------------------------------------
     mat_type	  IGRshort	 matrix type
     matrix	  IGRmatrix	 environment matrix
     ref_parms	  GRparms	 reference parameters
     norm_vc	  IGRvector	 vector to use in linear case
     proj_pt	  IGRpoint	 point to determine endpoint of bis-
				 sector segment
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure

     bisector	  IGRline	 perpendicular bisector
-----
%MD%

     MODULES AND METHODS INVOKED:
     Modules:
	     GRccschoice

     Methods:
	     GRmidpoint
-----
%RL%

     RELATIONS REFERENCED:
-----
%NB%

     NOTES:
	   The input point, proj_pt is used to determine the endpoint of
	  the perpendicular bisector by projecting it onto the perpen-
	  dicular line from the midpoint.

-----
%CH%

     CHANGE HISTORY:
	
	RDH     04/30/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine gets the midpoint of the object and then loads the 
data needed to call the line segment construction router to find the
line perpendicular from the object at the midpoint.

----*/
/*EH*/

class implementation GRcurve;

#include "grimport.h"
#include "msdef.h"
#include "exdef.h"
#include "grrouterpriv.h"
#include "godef.h"
#include "gocmacros.h"

extern    IGRboolean    GRls2pt_rtr();
extern    IGRboolean    GRccschoice();


method GRperbis(IGRlong *msg; IGRshort *mat_type; IGRmatrix matrix;
		struct GRparms *ref_parms; IGRvector norm_vc; IGRpoint 
		proj_pt; struct IGRbsp_curve *bisector)
{
  struct GRrtevent events[2];			/* two events for router      */

  IGRshort i;					/* index		      */
  IGRshort level;				/* number of levels for cpxs  */
  IGRshort num_events;				/* numver of events	      */
  IGRshort ccw;					/* orientation flag	      */

  IGRboolean view;				/* view information flag      */

  IGRlong OMmsg;				/* OM return code	      */



  *msg = MSSUCC;
						/* get the midpoint of object */

  if( 1 & (OMmsg = om$send(mode = OM_e_wrt_object,
                           msg = message GRcurve.GRmidpoint(msg,mat_type,
				matrix,ref_parms,events[1].pt),
                           senderid = my_id,
                           targetid = my_id)) )
    {
      if( 1 & *msg )
        {
	  level = 0;				/* prepare to call GRccschoice*/
	  view = FALSE;
	  ccw  = 1;
	  num_events = 2;

	  events[0].type = GRD_POINT;		/* init first event	      */
	  events[0].subtype = GRREG;
	  events[0].num_id = 0;

	  for(i=0;i<3;++i)
	     {
	       events[0].pt[i] = proj_pt[i];

	       events[0].vc[i] = norm_vc[i];
	     }

	  events[1].objs[0].osnum = OM_Gw_current_OS;/* init second event    */
	  events[1].objs[0].objid = my_id;
	  events[1].objs[0].parms = *ref_parms;
	  events[1].objs[0].mat_type = *mat_type;

	  for(i=0;i<16;++i)
	     {
	       events[1].objs[0].matrix[i] = matrix[i];
	     }

	  events[1].type = GRD_POINT;
	  events[1].subtype = GRPF;
	  events[1].num_id = 1;

	  GRccschoice(msg,&level,events,&num_events,&view,&ccw,GRls2pt_rtr,
		      bisector);
        }
      else
	{
	  OMmsg = OM_E_ABORT;
	}
    }

  

  return( OMmsg );

}/* This has been an R.D.H. production!!! */

end implementation GRcurve;
