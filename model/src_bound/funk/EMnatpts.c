/* ###################   APOGEE COMPILED   ################## */
#include "EMS.h"
/* 
Notes
	This function returns the end points for a natural edge, in UV
	space. The location of the natural edge passed to this function
	determines which end points are to be returned.

Assumption
	The location for natural edges is as follows - 

		     ____1____(1,1)
		     |       |
                     |       |
                   0 |       |2
                     |       |
                     ---------
                   (0,0) 3
History
	SM	03/03/87	Creation date
*/


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

/* end of igr.h replacement */
#include "EMSbnddef.h"
#include "emserr.h"
#include "EMSerrordef.h"

void EMnatpoints(EMmsg,location,points)
	IGRlong *EMmsg;
	IGRshort location;
	IGRdouble *points;
{
  *EMmsg = EMS_S_Success;

  if(location==0)
   {
	points[0] = points[1] = points[2] = 0;
	points[3] = 1.0;
   }
  else if(location==1)
   {
	points[0] = 0;
	points[1] = points[2] = points[3] = 1.0;
   }
  else if(location==2)
   {
	points[0] = points[1] = points[2] = 1.0;
	points[3] = 0;
    }
  else if(location==3)
   {
	points[0] = 1.0;
	points[1] = points[2] = points[3] = 0;
   }
  else *EMmsg = EMS_E_InvalidCase;
}

