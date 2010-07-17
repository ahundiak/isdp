class specification VRActParam (1:0) of VDB_LOCATE;



/************************************************************************

	Author : B DEMARS (ISDC, Paris)
	Date	: 5-NOV-1992

	Specification file for command object
        that display and manage the PIPING, HVAC, RWAY
	active parameters.

	Manyam	04 Oct	93	Override initial_form_notification

************************************************************************/

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "FI.h"
#include "FEI.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "VRattr_def.h"
#include "VRdef.h"



instance VRActParam
{
   IGRboolean			delete_flag;
   IGRint			Product;
   IGRchar			*CommandName;
   struct GRid			SysId,UsrId;

/* instance variables for form control */

   char				*form_name[2];
   int				form_label[2];
   Form				form_ptr[2];

   /*C instance variables for line seq num id management */
   IGRint			PrevLineNum;
   IGRboolean			bLineNumUsed; 

};


override	init, delete;

override initial_form_notification;

message VRSetProduct ( int * sts );	/* Initializes the instance
					   product dependant */

message VRInitAttr ( IGRint mode );	/* Initializes the collection
					   storing the attributes with
					   the active values */

message VRDeleteAttr ( IGRint mode );	/* Deletes the working collection */

message VRInitForm ( IGRint mode );	/* Init main or sub form */

message VRDispForm ( IGRint mode );	/* Display main form with right
					   units or sub form */

message VRUpdSysForm ( );

message VRUpdUsrForm ( );

message VRUnLockId( );


reject VRSetProduct, VRUpdSysForm;

end specification VRActParam;
