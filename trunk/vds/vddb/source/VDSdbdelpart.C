/* $Id: VDSdbdelpart.C,v 1.2 2001/02/15 00:29:07 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbdelpart.C
 *
 * Description:
 * This function to delete parts from the database 	
 * Special treatment for Struct. Delete the occurences in the
 * catalog mat_and_fam.				   	
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbdelpart.C,v $
 *	Revision 1.2  2001/02/15 00:29:07  ramarao
 *	Removed v_dbgmacros.h include file.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.7  1996/05/29  00:51:34  pinnacle
 * Replaced: vddb/source/VDSdbdelpart.C for:  by sljenks for vds.240
 *
 * Revision 1.6  1996/05/29  00:10:14  pinnacle
 * Replaced: vddb/source/VDSdbdelpart.C for:  by sljenks for vds.240
 *
 * Revision 1.5  1996/05/23  23:57:20  pinnacle
 * Replaced: vddb/source/*delpart.C for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1996/05/20  04:27:00  pinnacle
 * Replaced: vddb/source/VDSdbdelpart.C for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1996/05/20  03:26:02  pinnacle
 * Replaced: vddb/source/VDSdbdelpart.C for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:20  pinnacle
 * Replaced: vddb/source/*.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/18/96   tlb		Add prototypes
 *	05/09/96   tlb		Fx prototype name 
 *				Use new error routines
 *				Return true status, not just SUCCESS
 *	05/22/96   tlb		Fix error checking for RisDelete 
 *	05/28/96   slj		Removed call to VDSris_get_count as it
 *				is done in vds$RisDelete.
 * -------------------------------------------------------------------*/

#include 	<stdio.h>
#include 	<string.h>
#include 	"VDSdberrdef.h"
#include 	"VDSris_def.h"
#include 	"vdbmacros.h"
#include 	"VDmem.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

int VDSDeleteParts( 	char	*catalog_name,			/* I */
			char	*n_itemname,			/* I */
			char	*n_itemrev,			/* I */
			char	*product			/* I */
			)
{
	char	where[200];
        int	status ;
        int     num_records = 0;

	VDSdebug( "ENTER: VDSDeleteParts\n" );

	/* all parts and revisions */
	if( !strcmp(n_itemname,"all") && !strcmp(n_itemrev,"all") )
		where[0]='\0';

	/* all parts and some revisions */
	else if( !strcmp(n_itemname,"all") && strcmp(n_itemrev,"all") )
	   sprintf(where,"n_itemrev='%s'", n_itemrev );

	/* some parts and all revisions */
	else if( strcmp(n_itemname,"all") && !strcmp(n_itemrev,"all") ) 
	   sprintf(where,"n_itemname='%s'", n_itemname );

	/* some parts and some revisions */
	else
	   sprintf(where,"n_itemname='%s' and n_itemrev='%s'",
		n_itemname,n_itemrev );


	VDSprintUsrMsg("\tDeleting part <%s> revision <%s> from catalog <%s>\n",
		n_itemname, n_itemrev, catalog_name );

	status = vdb$RisDelete ( table_name   =    catalog_name,
                                 where        =    where);
        if( status != SUCCESS ) {
	  VDSprintErr ( "\t", "cannot delete part\n");
	  status = VDS_E_FAILURE;	
	  goto wrapup;
	  }

	/* Struct parts - if deleting all parts */
	if(!strcmp(n_itemname,"all") && !strcmp(n_itemrev,"all") 
		&& !strcmp(product,"struct")) {
	   VDSprintUsrMsg("\tDeleting part <%s> revision <%s> from <mat_and_fam>\n",
		n_itemname, n_itemrev, catalog_name );
	   sprintf(where,"n_itemname='%s'",catalog_name );
	   status = vdb$RisDelete ( table_name   =    "mat_and_fam", 
                                    where        =     where ); 
           if( status != SUCCESS ) {
	  	VDSprintErr ( "\t", 
		   "cannot delete structural part from mat_and_fam catalog\n");
	   	status = VDS_E_FAILURE;	
	  	goto wrapup;
	    	}
	   } 
	status = VDS_S_SUCCESS;
wrapup:
	VDSdebug( "EXIT: VDSDeleteParts\n" );
	return status;
}
