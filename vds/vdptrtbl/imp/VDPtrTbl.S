/* I/VDS
 *
 * File:        vdptrtbl/imp/VDPtrTbl.S
 *
 * Description: Class for managing transactions
 *
 *
 * Dependencies:
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      09/95           Mallik           Creation
 */
class specification VDPtrTbl (1:0) of VDPRoot;

/*+ca
 Class VDPtrTbl

 Superclass
	VDPRoot

   Abstract
	This class is responsible for maintaining the list of all the objects
	that have been created,modified or deleted during a design session.
	This list is deleted after posting.

   Design Reference

   Messages
	VDPinit		Public		Initilisation

   Notes/Remarks

-ca*/

#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "msdef.h"

#include "VDPtrTbl.h"

instance VDPtrTbl
{
   /* List of all the objects that are affected during a design session */
   variable struct VDPtrObjList		transObj[0];
};

/*+me
   Public Message VDPinit

   Abstract
	Initialisation

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPinit( IGRlong *msg );


/*+me
   Public Message VDPpostPMEdata

   Abstract
	This method posts the objects from the VDS design file and the
   data.

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPpostPMEdata( IGRlong *msg; IGRboolean *allPosted );


/*+me
   Public Message VDPAddtoTrTable

   Abstract
	This method adds an entry to the table. 

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPAddtoTrTable ( IGRlong *msg; struct VDPtrObjList  trRow);

/* Print the instance Data */

message VDPprintTransTable( IGRlong *msg );

/*+me
   Public Message VDPBatchpostPMEdata

   Abstract
	This method posts the objects in to ascii file  from the VDS design 
        file and the data.

   Algorithm

   Arguments
   Type		Name		I/O	Description

   Notes/Remarks

   Status/return Code
	status == OM_S_SUCCESS
	status == OM_E_xxx
-me*/

message VDPBatchpostPMEdata( IGRlong *msg; IGRchar *FileName );

/*+me

   Public Message VDPtrtblcopy
 
   Abstract
         This method returns copy of Transaction list. 


-me*/

message VDPtrtblcopy( IGRlong *msg; GRobjid *newobjid );

end specification VDPtrTbl;
