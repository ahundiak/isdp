/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */

/*
  HISTORY

    Sudha  07/09/93 	Modified for BSprototypes anisfication
*/

#include "EMS.h"
#include <math.h>
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "EMSmsgdef.h"
#include "bserr.h"
#include "bsdotp.h"

IGRboolean EFlateral_tangents(EMmsg, my_TN, comm_TN, lat_TN)
 
IGRlong *EMmsg;
IGRvector *my_TN, *comm_TN, *lat_TN;

{
 IGRlong          msg;
 IGRint           i;
 IGRdouble        dot_prod[4];
 extern IGRdouble fabs();

 *EMmsg = EMS_S_Success;

 dot_prod[0] = BSdotp(&msg, my_TN[0], comm_TN[0]);
 dot_prod[1] = BSdotp(&msg, my_TN[0], comm_TN[1]);
 dot_prod[2] = BSdotp(&msg, my_TN[1], comm_TN[0]);
 dot_prod[3] = BSdotp(&msg, my_TN[1], comm_TN[1]);

 if ((fabs(dot_prod[0]) >= fabs(dot_prod[1])) &&
     (fabs(dot_prod[0]) >= fabs(dot_prod[2])) &&
     (fabs(dot_prod[0]) >= fabs(dot_prod[3])))
  {
   for (i=0; i<3; i++)
    {
     lat_TN[0][i] = my_TN[1][i];
     lat_TN[1][i] = comm_TN[1][i];
    }
  }

 else
 if ((fabs(dot_prod[1]) >= fabs(dot_prod[0])) &&
     (fabs(dot_prod[1]) >= fabs(dot_prod[2])) &&
     (fabs(dot_prod[1]) >= fabs(dot_prod[3])))
  {
   for (i=0; i<3; i++)
    {
     lat_TN[0][i] = my_TN[1][i];
     lat_TN[1][i] = comm_TN[0][i];
    }
  }

 else
 if ((fabs(dot_prod[2]) >= fabs(dot_prod[0])) &&
     (fabs(dot_prod[2]) >= fabs(dot_prod[1])) &&
     (fabs(dot_prod[2]) >= fabs(dot_prod[3])))
  {
   for (i=0; i<3; i++)
    {
     lat_TN[0][i] = my_TN[0][i];
     lat_TN[1][i] = comm_TN[1][i];
    }
  }

 else
 if ((fabs(dot_prod[3]) >= fabs(dot_prod[0])) &&
     (fabs(dot_prod[3]) >= fabs(dot_prod[1])) &&
     (fabs(dot_prod[3]) >= fabs(dot_prod[2])))
  {
   for (i=0; i<3; i++)
    {
     lat_TN[0][i] = my_TN[0][i];
     lat_TN[1][i] = comm_TN[0][i];
    }
  }
return(TRUE);
} 
