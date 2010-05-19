/* $Id: */

/*************************************************************************
 * I/VDS
 *
 * File:        vdequip/buf/VDPEqBuffer.S
 *
 * Description:
 *
 * Dependencies:
 *
 * History:
 *
 *	10/31/95    MSM		Creation
 *
 *************************************************************************/

class specification VDPEqBuffer (0:1) of VDPRoot;

#include <stdio.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "OMprimitives.h"

#include "VDPEqpBuf.h"

instance VDPEqBuffer
{
    /* Preloaded Equipment List */
    variable struct VDPpre_ld_eqp	VDPpreLdEqp[0];
};

/*+me
   Public Message VDPsetEquipList

   Abstract
        This method queries the PME server and stores the Placement List in the
   design file.

   Algorithm

   Arguments
   Type         Name            I/O     Description

   Notes/Remarks

   Status/return Code
        status == OM_S_SUCCESS
        status == OM_E_xxx
-me*/

message VDPsetEquipList( IGRlong *msg );

/*+me
   Public Message VDPgetEquipList

   Abstract
        This method retrieves the List to be displayed in the Place Equipment 
   form.

   Algorithm

   Arguments
   Type         Name            I/O     Description

   Notes/Remarks

   Status/return Code
        status == OM_S_SUCCESS
        status == OM_E_xxx
-me*/

message VDPgetEquipList( IGRlong *msg; IGRint *nbEqps; struct VDPpre_ld_eqp **EqpList );

/*+me
   Public Message VDPrsrvEquipment

   Abstract
        Once placed in the design file, this method reserves the Equipment.

   Algorithm

   Arguments
   Type         Name            I/O     Description

   Notes/Remarks

   Status/return Code
        status == OM_S_SUCCESS
        status == OM_E_xxx
-me*/

message VDPrsrvEquipment( IGRlong *msg; IGRchar *PMobid );

/*+me
   Public Message VDPIsEqpmntReserved( IGRlong *msg; IGRint  row_nb; IGRint flag );

   Abstract
        Verifies if the equipment is reserved or not

   Algorithm

   Arguments
   Type         Name            I/O     Description

   Notes/Remarks

   Status/return Code
        status == OM_S_SUCCESS
        status == OM_E_xxx
-me*/
message VDPIsEqpmntReserved( IGRlong *msg; IGRint row_nb; IGRint flag );

end specification VDPEqBuffer;
