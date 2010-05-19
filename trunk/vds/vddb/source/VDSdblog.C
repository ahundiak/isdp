/* $Id: VDSdblog.C,v 1.1.1.1 2001/01/04 21:08:13 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddb/source / VDSdblog.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdblog.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:13  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/07/16  18:59:56  pinnacle
 * Fix for CR# 179422209
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.6  1996/05/20  05:04:18  pinnacle
 * Replaced: vddb/source/VDSdblog.C for:  by v240_int for vds.240
 *
 * Revision 1.5  1996/04/22  14:13:56  pinnacle
 * Replaced: vddb/source/VDSdblog.C for:  by v240_int for vds.240
 *
 * Revision 1.4  1996/03/01  10:21:58  pinnacle
 * Replaced: vddb/source/VDSload.C for:  by msbraju for vds.240
 *
 * Revision 1.3  1996/02/20  12:02:28  pinnacle
 * Replaced: vddb/source/VDSmenuops.C for:  by msbraju for vds.240
 *
 * Revision 1.2  1996/01/30  21:04:22  pinnacle
 * Replaced: ./vddb/source/VDSdblog.C for:  by azuurhou for vds.240
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	04/19/96   tlb		Add prototypes
 *				Rename VDSdbstr.h constants
 *	04/30/96   tlb		Spelling in user message
 *				Add NFM prototypes
 *				Call FreeRisBuffer if select fails
 *				From VDSload.C: 
 *				  VDBinitialize_login_strs, VDBstore_login_strs
 *      07/14/97   ap           Added a parameter to VDBinitialize_login_strs
 *                              and VDBstore_login_strs to read/write the 
 *                              user preference for warnings before delete
 *                              operations (eg. table delete, catalog delete...)
 *
 * -------------------------------------------------------------------*/

#include 	<stdio.h>
#include 	<string.h>
#include	<sys/utsname.h>
#include 	"NFMmach_id.h"
#include	"MEMstruct.h"
#include 	"MEMproto.h"
#include 	"NFMerrordef.h"
#include	"NFMstruct.h"
#include	"DEBUG.h"
#include	"NFMapi.h"
#include	"NFMUproto.h"
#include 	"VDSdbmsg.h"
#include 	"VDSdbstr.h"
#include	"VDSdberrdef.h"
#include	"vdbmacros.h"

#include	"SQLerrordef.h"
#include        "VDBload.h"
#include	"v_risproto.h"
#include	"v_dbloadprot.h"


#define         MAX_SERVER      64
#define         APPLICATION     "PDM"
#define         PDMNFMVERSION   "2.2.0"


/*----------------------------------------------------------------------------*/

int VDSlogin ( usr, passwd, env/*, user_id*/ )

char	*usr;
char	*passwd;
char	*env;
/*int	*user_id; */
{
	char	nfmenv[40];
	int	VDSstatus;
/*	int	user_no;   Not used  MSM 070493  */

	nfmenv[0] = 0;

	sprintf( nfmenv,"pdme_%s", env);

	VDSstatus = NFMlog_in ( usr, passwd, nfmenv, "PDM" );
	if ( VDSstatus != NFM_S_SUCCESS )
	{
	   switch (VDSstatus)
	   {
	        case ( NFM_E_BAD_NODE ):
			fprintf( stdout, "Invalid Server\n" );
			VDSstatus = VDS_E_BAD_NODE;
			VDB_GET_RETURN;
			return (VDSstatus);
		case ( NFM_E_BAD_PROTOCOL ):
			fprintf( stdout, "Could not connect using current protocol\n" );
			VDSstatus = VDS_E_BAD_PROTOCOL;
			VDB_GET_RETURN;
			return (VDSstatus);
		case ( NFM_E_BAD_USER ):
			fprintf( stdout, "Invalid user name\n" );
			VDSstatus = VDS_E_BAD_USER;
			VDB_GET_RETURN;
			return (VDSstatus);
		case ( NFM_E_BAD_ENV ):
			fprintf( stdout, "Invalid Environment Name\n" );
			VDSstatus = VDS_E_BAD_ENV;
			VDB_GET_RETURN;
			return (VDSstatus);
		case ( NFM_E_CLH ):
			fprintf( stdout, "Clearing House entry incorrect\n" );
			fprintf( stdout, "Check /usr/lib/nodes/heard/pdme_<environment>\n" );
			fprintf( stdout, "Check for entries in /etc/hosts for pdme_<env>\n" );
			VDSstatus = VDS_E_CLH;
			VDB_GET_RETURN;
			return (VDSstatus);
		case ( NFM_E_USER_PASSWD ):
			fprintf( stdout, "Invalid password\n" );
			VDSstatus = VDS_E_USER_PASSWD;
			VDB_GET_RETURN;
			return (VDSstatus);
		case( NFM_E_SQL_QUERY )   :
			fprintf( stdout, "Could not open underlying DBMS\n" );
			fprintf( stdout, "1. If informix online, check whether tbinit process is running\n" )
;
			fprintf( stdout, "2. If oracle, check whether dbwr,lgwr,smon,pmon,arch processes is running\n" );
			fprintf( stdout, "3. Check whether /usr/ip32/ris/risschema file exists\n" );
			fprintf( stdout, "4. Check for correct TCP address and XNS entries in /usr/ip32/ ris/risschema for nfme_<environment> and nfms_<server>\n" );
			VDSstatus = VDS_E_SQL_QUERY;
			VDB_GET_RETURN;
			return(VDSstatus);
		case( NFM_E_SQL_STMT )   :
			fprintf( stdout, "Could not open underlying DBMS\n" );
			fprintf( stdout, "1. If informix online, check whether tbinit process is running\n" );
			fprintf( stdout, "2. If oracle, check whether dbwr,lgwr,smon,pmon,arch processes is running\n" );
			fprintf( stdout, "3. Check whether /usr/ip32/ris/risschema file exists\n" );
			fprintf( stdout, "4. Check for correct TCP address and XNS entries in /usr/ip32/ ris/risschema for nfme_<environment> and nfms_<server>\n" );
			VDSstatus = VDS_E_SQL_STMT;
			VDB_GET_RETURN;
			return(VDSstatus);
		default :
			fprintf( stdout, "1. Check whether /usr/ip32/ris/risschema file exists\n" );
			fprintf( stdout, "2. Check for correct TCP address and XNS entries in /usr/ip32/ ris/risschema for nfme_<environment> and nfms_<server>\n" );
			fprintf( stdout, "3. Check for entries in /etc/hosts for nfme_<env>\n" );
			VDB_GET_RETURN;
			return (VDSstatus);
	    }
	}
#ifdef DEBUG
	printf(" VDSstatus = %x\n", VDSstatus );
#endif
/*
	VDSstatus = VDSget_user_id ( usr, &user_no);
	printf("User id = %d , user_no = %d\n", *user_id, user_no );
	if ( VDSstatus != SUCCESS )
	{
	    NFMlogoff();
	    printf (" Invalid user in NFMUSERS table \n");
	    return ( NFM_E_BAD_USER );
	}
	*user_id = user_no;
*/
	VDSstatus = VDSverify_pdm_init();
	if ( VDSstatus != VDS_S_SUCCESS )
	{
	    NFMlogoff();
	    fprintf ( stdout, "Invalid initialisation. Check nfmsyscat table.\n" );
	    return ( VDS_E_FAILURE );
	}
	return ( VDS_S_SUCCESS );
}

/*------------------------------------------------------------------*/
int VDSget_user_id( user, uid)
char	*user;
int	*uid;
{

	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];
	/*char	passwd[20]; */
	int	status = VDS_S_SUCCESS;

      	sprintf(query,"%s '%s'", 
		"SELECT n_userno FROM nfmusers WHERE n_username = ",user );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1) {
		status = VDS_E_FAILURE;
		goto wrapup;
		}
	if(rows >= 1) {
		sscanf(result[0],"%d",uid);
		}

wrapup:
	vdb$RisFreeBuffer (  buffer    =     result,
                             size      =     rows * cols);
	return status;
}

/*------------------------------------------------------------------*/
int VDSget_table_no( n_tablename, n_tabletype, n_tableno )
char	*n_tablename;
char	*n_tabletype;
int	*n_tableno;
{

	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];
	int	status = VDS_S_SUCCESS;

      	sprintf(query,"%s '%s' %s '%s'",
      		"SELECT n_tableno FROM nfmtables WHERE n_tablename = ", 
		n_tablename, "AND n_tabletype = ", n_tabletype );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1) {
		status = VDS_E_FAILURE;
		goto wrapup;
		}
	if(rows >= 1) {
		sscanf(result[0],"%d",n_tableno);
		}

wrapup:
	vdb$RisFreeBuffer ( buffer     =       result,
                            size       =       rows * cols);
	return status;
}

/*------------------------------------------------------------------*/
int VDSget_catno( n_catalogname, n_catalogno )
char	*n_catalogname;
int	*n_catalogno;
{

	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];
	int	status = VDS_S_SUCCESS;

      	sprintf(query,"%s '%s'",
      		"SELECT n_catalogno FROM nfmcatalogs WHERE n_catalogname = ", 
		n_catalogname );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1) {
		status =  VDS_E_FAILURE;
		goto wrapup;
		}
	if(rows >= 1) {
		sscanf(result[0],"%d",n_catalogno);
		}

wrapup:
	vdb$RisFreeBuffer (  buffer       =       result,
                             size         =       rows * cols);
	return status;
}

/*------------------------------------------------------------------*/
int VDSverify_pdm_init()
{
	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];
	int	status = VDS_S_SUCCESS;

/*
        "SELECT n_rowno FROM nfmsyscat WHERE n_description = ", PDMNFMVERSION, "AND n_infotype = ", APPLICATION );
removing as PDM does not necessarily need to be the exact version 6 Jun 1993*/


      	sprintf( query,"%s '%s' ",
        	"SELECT n_rowno FROM nfmsyscat WHERE n_infotype = ", 
		APPLICATION );

	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1)  {
		status =  VDS_E_FAILURE;
		goto wrapup;
		}

wrapup:
	   vdb$RisFreeBuffer ( buffer        =        result,
                               size          =        rows * cols);
	   return status;
}

/*------------------------------------------------------------------*/
int VDSverify_part( catalog, partnum, revision)
char	*catalog;
char	*partnum;
char	*revision;
{
	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];

      	sprintf( query,"%s %s %s '%s' %s '%s'",
      		"SELECT n_itemname, n_itemrev FROM ",catalog, 
		"WHERE n_itemname = ", partnum, "AND n_itemrev = ", revision );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1)
		return VDS_E_FAILURE;
	if ( rows >= 1 )
	{
	   vdb$RisFreeBuffer (   buffer        =       result,
                                 size          =       rows * cols);
	   return VDS_S_SUCCESS;
	}
	else
	   return VDS_E_FAILURE;
}

/*------------------------------------------------------------------*/
int VDSverify_catalog( catalog )
char	*catalog;
{
	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];

      	sprintf( query,"%s '%s'",
      		"SELECT n_catalogname FROM nfmcatalogs where n_catalogname =",
		catalog  );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1)
		return VDS_E_FAILURE;
	if ( rows >= 1 )
	{
	   vdb$RisFreeBuffer (  buffer       =       result,
                                size         =       rows * cols);
	   return VDS_E_CATALOG_EXISTS;
	}
	else
	   return VDS_E_CATALOG_NOT_FOUND;
}

/*-------------------------------------------------------------------*/

/*
 Desc :  Reads usrname, envname, debug, warning from a temp file which would
         have been written  next time VDSloaddata is invoked.
*/
void VDBinitialize_login_strs(
  char  usrname[16],
  char  usrpasswd[16],
  char  envname[16],
  char  debug[16],
  char  warning[16]
)
{
  FILE	*loginp = NULL;
  int	slen;

   strcpy( usrname, "nfmadmin" );
   usrpasswd[0] = '\0';
   envname[0] = '\0';
   strcpy( debug, "n" );
   strcpy( warning, "y" );

   loginp = (FILE *) fopen("/usr/tmp/loaddata.login", "r");
   if ( loginp != NULL )
   {
	fgets( usrname, 16, loginp );
	slen = strlen ( usrname );
	usrname[slen-1] = '\0';

	fgets( envname, 16, loginp );
	slen = strlen ( envname );
	envname[slen-1] = '\0';

	fgets( debug, 16, loginp );
	debug[1] = '\0';
	if ( debug[0] == '\n' ) debug[0] = '\0';

	fgets( warning, 16, loginp );
	warning[1] = '\0';
	if ( warning[0] == '\n' ) warning[0] = '\0';

	fclose( loginp );
   }

   return;
}

/*-------------------------------------------------------------------*/
/*
 Desc :  writes usrname, envname, debug, warning to a temp file which will 
         be read next time VDSloaddata is invoked.
*/
void  VDBstore_login_strs(
  char  usrname[16],
  char  envname[16],
  char  debug[16],
  char  warning[16]
)
{
 FILE  *loginp;

   loginp = (FILE *) fopen( "/usr/tmp/loaddata.login", "w" );
   if ( loginp != NULL )
   {
	fprintf( loginp, "%s\n%s\n%c\n%c\n",
                       usrname, envname, debug[0], warning[0] );
	fclose( loginp );
   }

   return ;
}
