/* ###################   APOGEE COMPILED   ################## */

/*

   History

        Sudha   06/02/93        modified to include for BSprototype headers
*/

#include "EMS.h"

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
#include "EMSerrordef.h"
#include "bsparameters.h"
#include "bserr.h"
#include "madetplan.h"
#include "bsdistptpl.h"

IGRlong EFptonface(planepts, pt)
IGRpoint planepts[];  /*input - array of 3 points determining plane*/
IGRpoint pt;         /*input - point to be determined if on plane*/

/*Function returns: EMS_S_Success
                    EMS_I_OnFace
                    EMS_E_Fail
*/

{
 IGRlong   num, msg;
 IGRshort  status;
 struct    IGRplane plane; 
 IGRpoint  plane_point, plane_normal; 
 IGRdouble distance, tolerance; 

 status = BSEXTRACTPAR(&msg, BSTOLLENVEC, tolerance);
 if (!status) return EMS_E_Fail;
 
 plane.point = &plane_point[0];
 plane.normal = &plane_normal[0];
 num = 3;

 status = MAdetplane(&msg, (IGRdouble *)planepts, &num, &tolerance, &plane);
 if (!status) return EMS_E_Fail;

 status = BSdistptpl(&msg, pt, &plane_point[0], &plane_normal[0], 
                     &distance);
 if (!status) return EMS_E_Fail;
 if (distance > tolerance) 
  return EMS_S_Success;
 else
  return EMS_I_OnFace;
}
