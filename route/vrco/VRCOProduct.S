/* $Id: VRCOProduct.S,v 1.1.1.1 2001/01/04 21:12:42 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrco/VRCOProduct.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VRCOProduct.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:42  cvs
 *     Initial import to CVS
 *
# Revision 1.2  1999/04/19  09:39:14  pinnacle
# Replaced: vrco/VRCOProduct.S for:  by apazhani for route
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *	12/18/90   ?????	Creation
 *	 Dec-92	   K.B.		Subclassing to VRCmpMgr class.
 *	 Jun-93	   Manyam+ 	Moved "VRIsDisplayed" message from VRCOPiping
 *	12 Nov 93  Manyam  	Moved Added VRSetIdManData, initial_form_notif
 *			  	from VRCOPiping to this class.
 *			  	Moved VRValidateIdChg from VRPReplace to this
 *			  	class.
 *      04/19/99   Alwin        Added the struct VRRwCptDetails in  instance 
 *
 ******************************************************************************/

class specification VRCOProduct (1:0) of VRCmpMgr;

#include "bserr.h"
#include "VRattr_def.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "VRdef.h" 
#include "VRdimdef.h"
#include "VRstructs.h"
#include "VRcompdef.h"
#include "VRpriv_attr.h"
#include "VRparamdef.h"
#include "FI.h"
#include "FEI.h"

#include "godef.h"
#include "go.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "VRco.h"
#include "VRmsg.h"
#include "parametric.h"
#include "ndmacros.h"
#include "nddef.h"
#include "VRsketchdef.h"
#include "VRmacros.h"
#include "VRRwDimen.h"

instance VRCOProduct
{
	IGRlong		lRet;			/* Return Code			*/
	IGRshort	nSysType;		/* Component type		*/
	IGRshort	nInitialCompTopo; 	/* Initial element		*/
	IGRshort	nDanglingIndex;		/* Index on segment 	*/
	IGRshort	RetainIndex;
	IGRint		ActiveMessageField;
	IGRint		ActivePocketMenu;
	IGRint		ReplaceCommand;		/* Replace command activated ?	*/
	IGRchar		szActivePocketMenuName [300];
	IGRdouble	dSplitPoint [3];	/* Spliting Point coord	*/ 
	IGRboolean	bPktInquired;		/* pocket menu activated ? 	*/
        struct GRid     CompId;                 /* Component Id          */
        struct GRid     SegId;
	struct GRid	SavUserParamId;		/* Saved Comp user paramid	*/
	struct GRid	SavMissParamId;		/* Saved Comp user paramid	*/
	struct GRid	SavSysParamId;		/* Saved Comp Sys param id	*/
	struct VRcp_attr	ConProp;	/* Cpt attributes	*/
	Form		FormPtr;		/* status_display or forms [0]	*/
	Form		FormUser;		/* forms [0] or forms [1]	*/
	IGRint		OldCmpTagId;		/* Tagid of the old cmp
						   added for replace in PIPING*/

	struct VRRwCptDetails RwCptData[10];    /* to store tier information */
};

/* local messages */
/* ************** */

/* display user form */
message VRUpdateForm( IGRlong *sts );

/* get info on located object */
message VRGetLocatedObject ( IGRlong *sts );

/* get attribut from a component */
message VRCopyComponentAttr ( IGRlong *sts );

/* Process keyin entered entered by user */
message VRGetOptionCode ( IGRlong *sts; IGRboolean bDispDef );
message VRGetOtherValues ( IGRlong *sts );

/* Call EMS pocket menu back */
message VRDefaultPocketMenu  (IGRlong *ret);

/* Call pocket menu */
message VRChangeActivePocketMenu  (IGRlong *ret);

/* Display messages */
message VRDisplayMessage  (IGRlong *ret);

/* To know what kind of EX_FORM_FINISHED we received */
message VRCopyReturnCode (IGRlong *ret);

/* Methods relative to Param Box */
message VRIsReducerRequired (IGRlong *ret);
message VRForceDiamValues (IGRlong *ret);

/* Methods relative forms */
message VRLoadForm ( IGRlong *sts );
message VRFillForm ( 	IGRlong *sts ; 
			struct GRid *CompId ; 
			struct GRid *FormSysParamId; 
			struct GRmd_env *MdEnv);
message VRRestoreForm ( IGRlong *msg );

/* Computation relative to components life and behaviour */
message VRDeleteComponent (IGRlong *ret);
message VRChangeComponent (IGRlong *ret);
message VRInsertComponent (IGRlong *ret);
message VRRetrieveLocatedContext (IGRlong *ret);
message VRRetrieveOldComponent (IGRlong *ret);
message	VRGetObject ( IGRlong	*ret );
message	VRGetReturnCode (IGRlong *ret);
message	VRComputeOrientationTee ( IGRlong *ret );

message VRCheckTopoCoherency( IGRlong *ret );

/* checks whether the given form is displayed or not */
message	VRIsDisplayed( IGRchar	*form_ptr );

message VRSetIdManData( IGRlong *sts );

message	VRUnLockId( IGRlong *sts );

message VRValidateIdChg ( IGRlong * sts );

message VREvalCorComp ( IGRlong * sts );

/* override messages */
/* ***************** */

override status_disp;
override init;
override wakeup;
override sleep;
override delete;
override dynamics;
override VRGetCompMatrix;
override initial_form_notification;

/* reject messages */
/* *************** */

reject VRFillForm;
reject VRDisplayMessage;

end specification VRCOProduct;

