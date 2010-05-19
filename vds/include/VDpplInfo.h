/* $Id: VDpplInfo.h,v 1.1 2001/01/10 16:04:17 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/VDpplInfo.h
 *
 * Description:	store and retrieve info about PPL information
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VDpplInfo.h,v $
 *      Revision 1.1  2001/01/10 16:04:17  art
 *      sp merge
 *
 * Revision 1.3  2000/09/25  19:59:04  pinnacle
 * Replaced: vds/include/VDpplInfo.h for:  by jvhanson for Service Pack
 *
 * Revision 1.2  2000/09/25  15:12:28  pinnacle
 * Replaced: vds/include/VDpplInfo.h for:  by jvhanson for Service Pack
 *
 * Revision 1.1  2000/09/25  14:43:02  pinnacle
 * Created: vds/include/VDpplInfo.h by jvhanson for Service Pack
 *
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 09/18/00  ah      Creation
 * 01/10/01  ah      sp merge
 ***************************************************************************/
/* -------------------------------------------------------------------
 * This is include file which defined the variables for the information
 * process of the PPL commands.
 *
 */

#include "cieveryone.h"
#include "OMminimum.h"
#include "cimacros.h"

#define   VD_PPL 1
#include "VDtypedef.h"
#include "VDppl1.h"

/* ---------------------------------------------------------------
 * These two variables will be set with the object being processed
 */
 
struct VDpplInfo {
	GRname  title;
	GRname  product;
	GRname	version;
	GRname	desc_short;
	IGRint	desc_count;	/* maximnum 10 */
	GRname	*desc[10];

} ;

struct	VDpplInfo 	PPL_INFO;

/* ---------------------------------------------------------------
 * Initialization of the variable before usage
 */ 
VDpplInitInfo( info )
 struct VDpplInfo *info;
{
IGRint	i;

	strcpy( info->title, "PPL command" );
	strcpy( info->product, "ISDP I/VDS" );
	strcpy(	info->version, "02.06.01.14" );
	strcpy(	info->desc_short, "" );

	info->desc_count	= 0 ;	/* maximnum 10 */

	for(i=0;i<10;i=i+1){
		info->desc[i]="" ;
	}
}


VDpplGetInfo(macroName, info )
 IGRchar *macroName ; 
 struct VDpplInfo *info;
{
	long		sts, msg, pplRet; 
	GRname		pplName, pplFunc ;
	struct GRid	pplID;


	/* initialization */
	pplName[0] = '\0';
	strcpy( pplFunc, "ppl_info" );
	pplID.objid = NULL_OBJID ;

	/* Get the name of the PPL program */
	strcpy( pplName, macroName );

	/* Load the PPL */
	sts = vdppl$Load(	name	= pplName,
				pplID	= &pplID );
	if (pplID.objid == NULL_OBJID) {
		printf("Could not load PPL '%s', sts = %d\n",pplName, sts);
		goto wrapup;
	}

	/* Run the PPL program */
	sts = vdppl$Run(	pplID	= &pplID,
				name	= pplFunc,
				ret	= &pplRet);
	if (!(sts & pplRet & 1)){
		printf("This PPL doesn't support the information function '%s-%s'\n", pplName, pplFunc );
		goto wrapup;
	}

	/* Get the information */
	 
	sts = vdppl$GetData(	pplID	= &pplID,
				name	= "PPL_INFO",
				size	= sizeof(struct VDpplInfo),
				data	= (char*) info );	
wrapup:

	/* Delete the object */
	if (pplID.objid != NULL_OBJID)	
		msg = vdppl$Delete(	pplID	= &pplID);

	return sts;

}


