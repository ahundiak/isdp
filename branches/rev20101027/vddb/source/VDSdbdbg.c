/* $Id: VDSdbdbg.c,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdbdbg.c
 *
 * Description:
 *  	Debug, error message , and usr message functions 
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbdbg.c,v $
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
 * Revision 1.4  1996/05/20  03:54:48  pinnacle
 * Replaced: vddb/source/VDSdbdbg.c for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/04/22  15:13:42  pinnacle
 * Replaced: vddb/source/VDSdbdbg.c for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:49:32  pinnacle
 * Replaced: vddb/source/VDSdbdbg.c for:  by v240_int for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/12/96     tlb	Declare VDS_DEBUG_FILE here now
 *				Add prototypes
 *	04/22/96     tlb	Fix log comment problem 
 *	04/30/96     tlb	Add NFM prototypes, other error functions
 *				Move VDSdebug to vdmisc/VDdbgFile
 *				Add new debugging functions
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>
#include 	"UMS.h"
#include 	"ERR.h"
#include	"MEMstruct.h"
#include	"NFMstruct.h"
#include	"DEBUG.h"
#include	"NFMapi.h"
#include 	"NFMerrordef.h"
#include	"NFMUproto.h"
#include 	"VDBload.h"
#include 	"VDDbDef.h"
#include	"VDSdbmsg.h"
#include	"VDSdberrdef.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"

#define	ERRTYPE( t, s ) case t: errStr = s ; break ;

/*--------------------------------------------------------------------------*/	
/* return VDS error string
 */
char *
VDBgetErrStr (int err )
{ 
   static char buf[100];
   char	*errStr ;

   switch( err ) {
   ERRTYPE( VDS_E_BUILD_ARRAY	, "cannot build buffer" );
   ERRTYPE( VDS_E_BUILD_BUFFER_ARRAY, "cannot build buffer array" );
   ERRTYPE( VDS_E_OPEN_BUFFER	, "cannot open buffer" );
   ERRTYPE( VDS_E_CLOSE_BUFFER	, "cannot close buffer" );
   ERRTYPE( VDS_E_COPY_BUFFER	, "cannot copy buffer" );
   ERRTYPE( VDS_E_INVALID_BUFFER_FORMAT	, "invalid buffer format" );
   ERRTYPE( VDS_E_BUFFER_FORMAT	, "invalid buffer format" );
   ERRTYPE( VDS_E_WRITE_FORMAT	, "cannot write column name and data type" );
   ERRTYPE( VDS_E_WRITE_COLUMN	, "cannot write into column" );
   ERRTYPE( VDS_E_WRITE_BUFFER	, "cannot write into buffer" );
   ERRTYPE( VDS_E_PART_EXISTS	, "part already exists" );
   ERRTYPE( VDS_E_CATALOG_EXISTS, "catalog already exists" );
   ERRTYPE( VDS_E_GET_CATALOG_NAME,"ccannot get catalog name" );
   ERRTYPE( VDS_E_CREAT_TABLE	, "cannot create table" );
   ERRTYPE( VDS_E_QUE_LOC_ATT	, "cannot get list of catalog attributes" );
   ERRTYPE( VDS_E_QUE_ITEM_ATT	, "cannot get attributes for item" );
   ERRTYPE( VDS_E_CREATE_APP	, "cannot create application" );
   ERRTYPE( VDS_E_GET_CAT_TEMP	, "cannot get list of attributes, data and values from catalog" );
   ERRTYPE( VDS_E_SQL_STMT	, "SQL statement syntax error" );
   ERRTYPE( VDS_E_SQL_QUERY	, "SQL statement syntax error" );
   ERRTYPE( VDS_E_BAD_NODE	, "invalid Server" );
   ERRTYPE( VDS_E_BAD_PROTOCOL	, "could not connect using current protocol" );
   ERRTYPE( VDS_E_BAD_USER	, "invalid user name" );
   ERRTYPE( VDS_E_BAD_ENV	, "invalid Environment Name" );
   ERRTYPE( VDS_E_CLH		, "clearing House entry incorrect" );
   ERRTYPE( VDS_E_USER_PASSWD	, "invalid password" );
   ERRTYPE( VDS_E_CONVERT_DATATYPE, "cannot convert data type to PDM rules" );

   ERRTYPE( VDS_E_FAILURE, 	"operation failed" );
   ERRTYPE( VDS_S_SUCCESS, 	"successful completion" );

   default: 		
		sprintf (buf, "unknown VDS error: 0x%x", err);
		errStr = buf;
		; break;
  }
  return errStr;
}

/*---------------------------------------------------------------------*/
int	VDSset_debug_on()
{
	int 	toggles[NFM_DEBUG_SUBSYSTEMS];
	char	files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

	VDS_DEBUG_FILE[0] = '\0';

	toggles[6] = 1; 		/* NETS ( server side ) ON */
	toggles[8] = toggles[9] = 1;	/* NFM & SQL debug ON 	   */
	toggles[11] = toggles[14] = 1;	/* MEMS & ERRS debug ON	   */

	sprintf ( files[6], "%s","/usr/tmp/net.dbg");
	sprintf ( files[8], "%s","/usr/tmp/nfm.dbg");
	sprintf ( files[9], "%s","/usr/tmp/nfm.dbg");
	sprintf ( files[11], "%s","/usr/tmp/mem.dbg");
	sprintf ( files[14], "%s","/usr/tmp/err.dbg");

	NFMall_debug (toggles, files );


	return VDS_S_SUCCESS;
}

/*-------------------------------------------------------------------*/
/* Prints VDS error message to screen and logfile
 *	prints name of failed function in logfile
 */
void VDSprintVdsErr ( 	char * 	prefix,
			char	*func,		/* VDS function name */
			int 	status )
{ 
	VDSprintErr (prefix, "%s failed: %s\n", func, VDBgetErrStr(status) ); 
}

/*-------------------------------------------------------------------*/
/* Prints SQL error message to screen and logfile
 *	prints name of failed function in logfile
 */
void VDSprintSqlErr ( 	char * prefix,
			char  * msg,
			char *	sql,		/* MEM function name*/
			int 	status)
{ 
	VDSprintErr (prefix, "%s: %s\n", msg, VDSgetSqlErrStr(status) ); 
	VDSdebug ("\tSQL statement failed: \n\t%s\n", sql);
	ERRreset_struct();
}

/*-------------------------------------------------------------------*/
/* Prints MEM subsystem error message to screen and logfile
 *	prints name of failed function in logfile
 */
void VDSprintMemErr ( 	char * prefix,
			char *	func,		/* MEM function name*/
			int 	MEMstatus,
			int 	VDSstatus )
{ 
	VDSprintErr (prefix, "%s failed: %s \n", func, 
						VDSgetMemErrStr(MEMstatus));
	VDSprintErr (prefix, "%s\n", VDBgetErrStr(VDSstatus)); 
	ERRreset_struct();
}

/*-------------------------------------------------------------------*/
/* Prints NFM subsystem error message to screen and logfile
 *	prints name of failed function in logfile
 */
void VDSprintNfmErr ( 	char * prefix,
			char *	func,		/* MEM function name*/
			int 	status)
{ 
   	char		buf[UMS_MAX_BUFLEN];
	long	num;
	int	sys;

	/* Try to get NFM error message */
	if ( ERRget_specific_message(NFM, buf) != ERR_S_SUCCESS)
			sprintf (buf, "status = 0x%x", status);
	
	VDSprintErr (prefix, "%s failed: %s\n", func, buf);

	/* Check if underlying system failed */
	ERRget_number (&num, &sys);
	if (sys != NFM ) {
		if ( ERRget_specific_message(sys, buf) != ERR_S_SUCCESS)
			VDSprintErr (prefix, "In %s: %s\n", func, buf);
		}
	ERRreset_struct();
}
