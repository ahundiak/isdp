
/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:	vrtools / VRIdManage.C
 *
 * Description:
 *
 *	Stubs for all ID related functions at VDS level.
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	
 *	12/08/94	Manyam		Creation
 * -------------------------------------------------------------------*/

/* The defines to be in a include file used by the caller */

#include	<stdio.h>

#include        "exmacros.h"
#include        "OMerrordef.h"

#include        "ms.h"
#include        "msdef.h"
#include        "msmacros.h"
#include	"VDDbDef.h"
#include 	"VDSutil.h"

#ifndef	MANAGE_IDS

/************************************************************************/
/*									*/
/*	int VRGetListOfIDs( PrjNumber,SystemName,CompCategory, IdList ) */
/*	char	*PrjNumber;		(I)  Project Number		*/
/*	char	*SystemName;		(I)  System name of Network	*/
/*	char	*CompCategory;		(I)  Category for ID mgmnt	*/
/* 	char	*IdList[VDS_LIST_OF_IDS];(I)  Proposed list of ID's	*/
/*									*/
/************************************************************************/

int	VDGetListOfIDs( SystemName, CompCategory, IdList )
char	*SystemName;
int	CompCategory;			/* Category may be a short */
int	IdList[];
{

	return	1;	/* success	*/
}


/*D
	This function is called when a particular ID is used by any component.
	This makes it unusable by any other component. This is used for comp-
	onents, equipments and also Line sequence numbers.

	System Name 			char[13];
	CompCategory			integer;
	UsedID				integer;
*/


int VDLockSelectedID ( SystemName, CompCategory, UsedID )
char	*SystemName;
int	CompCategory;			/* Category may be a short */
int	UsedID;
{
	return 1;	/* successful	*/
}

/*D
	This function is called when a particular ID is modified or a component
	is deleted. A history of modifications is maintained in the database 
	done for any component. 

	System Name 			char[13];
	CompCategory			integer;
	OldID				integer;
	NewID				integer;
*/

int	VDModifyID( SystemName, CompCategory, OldId, NewId )
char	*SystemName;
int	CompCategory;
int	OldId;
int	NewId;			/* If Deleted then NewId is -1 */
{
	return 1;	/* successful	*/
}

/*D
	This function is called to verify if an ID is already used by another
	component/Line. 

	System Name 			char[13];
	CompCategory			integer;
	ID				integer;
	Return Codes: 	VDS_ID_IS_USED;
			VDS_ID_ISNOT_USED;
*/

int VDVerifyIfIDisUsed( SystemName, CompCategory, ID )
char	*SystemName;
int	CompCategory;			/* Category may be a short */
int	ID;
{
	return VDS_ID_ISNOT_USED;	
}

/*D
	This function returns the new ID of a component/Equipment if the
	original is modified. This should be called only if it references
	an original. NewID is returned.

	System Name 			char[13];
	CompCategory			integer;
	OldID				integer;
	NewID				integer;
*/


int	VDGetNewID( SystemName, CompCategory, OldId, NewId )
char	*SystemName;
int	CompCategory;
int	OldId;
int	*NewId;			/* If Deleted then NewId is -1 */
{
	return VDS_ID_NOT_MODIFIED; /* Id has not been modified */
}

/*D
	This function releases an ID if it is not used. Care should be taken
	to use this. This should not be called if the component has been
	approved or it is not the original.
*/

int VDUnLockID ( SystemName, CompCategory, UsedID )
char	*SystemName;
int	CompCategory;
int	UsedID;
{
	return 1;	/* success	*/
}

IGRint VRdbGetCompCat( msg, application, comp_code, 
					comp_cat, comp_behvr, err_ptr )

      IGRlong     *msg;        /*  Message                           (O) */
      IGRshort    application; /*  PIPING only                       (I) */
      IGRchar     *comp_code;  /*  AABBCC code		             (I) */
      IGRint	  *comp_cat;   /*  Comp Category		     (O) */
      IGRint	  *comp_behvr; /*  Comp Behavior		     (O) */
      IGRchar     *err_ptr;    /*  Error message buffer              (O) */
{
	if ( comp_behvr != NULL )
		*comp_behvr = 0;	/* NO ID Management	*/

	return	OM_S_SUCCESS;
}

#endif
