/* $Id: VDSdblog.C,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpdm/source / VDSdblog.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdblog.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:58  cvs
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
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

                                /**********************************************/
                                /*                                            */
                                /*      VDSdblog.C                            */
                                /*                                            */
                                /**********************************************/
/* modification : This file was changed from .c to a .C,due to the 
 * inclusion of macros from vdbmacros.h, because .c causes compilation problems
 * also the .m had to be changed to update .C
 */

#include 	<stdio.h>
#include	<sys/utsname.h>
#include 	<NFMmach_id.h>
#include 	<MEMerrordef.h>
#include 	<MEMstruct.h>
#include 	<NFMerrordef.h>
#include 	"VDSdbmsg.h"
#include 	"VDSdbstr.h"
#include	"VDSdberrdef.h"
#include	"vdbmacros.h"

#include	"SQLerrordef.h"

#define         MAX_SERVER      64
#define         APPLICATION     "PDM"
#define         PDMNFMVERSION   "2.1.0"


/*----------------------------------------------------------------------------*/

int VDSlogin ( usr, passwd, env/*, user_id*/ )

char	*usr;
char	*passwd;
char	*env;
/*int	*user_id; */
{
	char	nfmenv[40];
	int	VDSstatus;

	nfmenv[0] = 0;
	sprintf( nfmenv,"nfme_%s", env);
	VDSstatus = NFMlog_in ( usr, passwd, nfmenv, "PDM" );
	if ( VDSstatus != NFM_S_SUCCESS )
	{
	   switch (VDSstatus)
	   {
	        case ( NFM_E_BAD_NODE ):
			printf("Invalid Server\n");
			return (VDSstatus);
		case ( NFM_E_BAD_PROTOCOL ):
			printf("Could not connect using current protocol\n");
			return (VDSstatus);
		case ( NFM_E_BAD_USER ):
			printf("Invalid user name\n");
			return (VDSstatus);
		case ( NFM_E_BAD_ENV ):
			printf("Invalid Environment Name\n");
			return (VDSstatus);
		case ( NFM_E_CLH ):
			printf("Clearing House entry incorrect \n");
			printf("Check /usr/lib/nodes/heard/nfms_<server> & nfme_<environment>\n");
			printf("Check for entries in /etc/hosts for nfme_<env>\n");
			return (VDSstatus);
		case ( NFM_E_USER_PASSWD ):
			printf("Invalid passwd \n");
			return (VDSstatus);
		case( NFM_E_SQL_QUERY )   :
			printf("Could not open underlying DBMS\n");
			printf("1. If informix online, check whether tbinit process is running\n")
;
			printf("2. If oracle, check whether dbwr,lgwr,smon,pmon,arch processes is running\n");
			printf("3. Check whether /usr/ip32/ris/risschema file exists\n");
			printf("4. Check for correct TCP address and XNS entries in /usr/ip32/ ris/risschema for nfme_<environment> and nfms_<server>\n");
			return(VDSstatus);
		case( NFM_E_SQL_STMT )   :
			printf("Could not open underlying DBMS\n");
			printf("1. If informix online, check whether tbinit process is running\n")
;
			printf("2. If oracle, check whether dbwr,lgwr,smon,pmon,arch processes is running\n");
			printf("3. Check whether /usr/ip32/ris/risschema file exists\n");
			printf("4. Check for correct TCP address and XNS entries in /usr/ip32/ ris/risschema for nfme_<environment> and nfms_<server>\n");
			return(VDSstatus);
		default :
			printf("1. Check whether /usr/ip32/ris/risschema file exists\n");
			printf("2. Check for correct TCP address and XNS entries in /usr/ip32/ ris/risschema for nfme_<environment> and nfms_<server>\n");
			printf("3. Check for entries in /etc/hosts for nfme_<env>\n");
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
	VDSstatus = VDSverify_pdm_init();
	if ( VDSstatus != VDS_S_SUCCESS )
	{
	    NFMlogoff();
	    printf (" Invalid initialisation. Check nfmsyscat table.\n");
	    return ( VDS_E_FAILURE );
	}
*/
	return ( VDS_S_SUCCESS );
}

int VDSget_user_id( user, uid)
char	*user;
int	*uid;
{

	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];
	/*char	passwd[20]; 
	char	**columns;
	int	*coltype;
	MEMptr	bufr = NULL; */

      	sprintf(query,"%s '%s'",
     	"SELECT n_userno FROM nfmusers WHERE n_username = ",user ); 
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
     /*	"SELECT * FROM nfmusers WHERE n_username = ",user ); 
	VDSstatus = VDSsql_query1(query, &cols, &rows, &result, &columns, &coltype );
    */
	if (VDSstatus != 1)
		return VDS_E_FAILURE;
	if(rows >= 1)
	{
		sscanf(result[0],"%d",uid);
	}

/*
	VDSstatus = SQLquery ( query, &bufr, 512 );
	if ( VDSstatus != SQL_S_SUCCESS )
	{ 
	  printf(" SQL QUERY FAILED \n");
	  return FAILURE;
	}
	VDSstatus = MEMbuild_array(bufr);
	result = (char **) bufr->data_ptr;
	*uid = atoi(result[0]); MEMclose (&bufr);

*/
	vdb$RisFreeBuffer (  buffer   =    result,
                             size     =    rows * cols); 
	return VDS_S_SUCCESS;
}

int VDSget_table_no( n_tablename, n_tabletype, n_tableno )
char	*n_tablename;
char	*n_tabletype;
int	*n_tableno;
{

	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];

      	sprintf(query,"%s '%s' %s '%s'",
      	"SELECT n_tableno FROM nfmtables WHERE n_tablename = ", n_tablename,
	"AND n_tabletype = ", n_tabletype );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1)
		return VDS_E_FAILURE;
	if(rows >= 1)
	{
		sscanf(result[0],"%d",n_tableno);
	}

	vdb$RisFreeBuffer (  buffer     =      result,
                             size       =      rows * cols);
	return VDS_S_SUCCESS;
}

int VDSget_catno( n_catalogname, n_catalogno )
char	*n_catalogname;
int	*n_catalogno;
{

	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];

      	sprintf(query,"%s '%s'",
      	"SELECT n_catalogno FROM nfmcatalogs WHERE n_catalogname = ", n_catalogname );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1)
		return VDS_E_FAILURE;
	if(rows >= 1)
	{
		sscanf(result[0],"%d",n_catalogno);
	}

	vdb$RisFreeBuffer ( buffer  =      result,
                            size    =      rows * cols);
	return VDS_S_SUCCESS;
}

int VDSverify_pdm_init()
{
	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];

      	sprintf( query,"%s '%s' %s '%s'",
      	"SELECT n_rowno FROM nfmsyscat WHERE n_description = ", PDMNFMVERSION, "AND n_infotype = ", APPLICATION );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1)
		return VDS_E_FAILURE;
	if ( rows >= 1 )
	{
	   vdb$RisFreeBuffer ( buffer   =   result,
                               size     =   rows * cols);
	   return VDS_S_SUCCESS;
	} 
	else 
	   return VDS_E_FAILURE;
}

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
      	"SELECT n_itemname, n_itemrev FROM ",catalog, "WHERE n_itemname = ", partnum, "AND n_itemrev = ", revision );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1)
		return VDS_E_FAILURE;
	if ( rows >= 1 )
	{
	   vdb$RisFreeBuffer ( buffer  =    result,
                               size    =    rows * cols);
	   return VDS_S_SUCCESS;
	} 
	else 
	   return VDS_E_FAILURE;
}

int VDSverify_catalog( catalog )
char	*catalog;
{
	int	VDSstatus;
	int	cols, rows;
	char	**result;
	char	query[200];

      	sprintf( query,"%s '%s'",
      	"SELECT n_catalogname FROM nfmcatalogs where n_catalogname =",catalog  );
	VDSstatus = VDSsql_query(query, &cols, &rows, &result );
	if (VDSstatus != 1)
		return VDS_E_FAILURE;
	if ( rows >= 1 )
	{
	   vdb$RisFreeBuffer (  buffer  =   result,
                                size    =   rows * cols);
	   return VDS_E_CATALOG_EXISTS;
	} 
	else 
	   return VDS_E_CATALOG_NOT_FOUND;
}



