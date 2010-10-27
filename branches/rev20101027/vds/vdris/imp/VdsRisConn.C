/* $Id: VdsRisConn.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VdsRisConn.c
 *
 * Description:
 *	This connects to a ris server that the user specifies.  	 
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsRisConn.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:12  cvs
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
 * Revision 1.3  1996/04/22  13:40:54  pinnacle
 * Replaced: vdris/imp/VdsRisConn.C for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.1  1995/12/20  19:48:26  pinnacle
 * Created: vdris/imp/VdsRisConn.C by jwfrosch for vds.240
 *
 * Revision 1.4  1995/10/26  14:21:46  pinnacle
 * Replaced: vdris/imp/VdsRisConn.c for:  by tdumbach for vds.240
 *
 * Revision 1.3  1995/09/27  14:30:26  pinnacle
 * Replaced: vdris/imp/VdsRisConn.c for:  by sundar for vds.240
 *
 * Revision 1.2  1995/09/26  18:49:46  pinnacle
 * Replaced: vdris/imp/VdsRisConn.c for:  by sundar for vds.240
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
 *	08/12/92	Mallik	Creation
 *	12/20/95	HF	Added VDdebug.h & __<fnc. calls>
 *					(Intel Solaris database problem)
 *					Also added test to ensure proper
 *					functioning of clh_vbyop() :
 *	04/10/96   tlb		Use VDS memory allocation checking
 *				Add prototypes
 *				VdsRisConnect - add 1 to strlen 
 *	04/22/96   tlb		Unset ris.h constants
 *				
 *
 * -------------------------------------------------------------------*/

#include 	<stdio.h>
#include	<string.h>
#include 	<ctype.h>

#include        "ris.h"		/* replaces sql.h for RIS 4.0 */

/* Redefine ris.h constants in VDSris_def.h  */
#undef NUMERIC
#undef DECIMAL
#undef SMALLINT
#undef REAL
#undef DOUBLE

#include	"NFMerrordef.h"
#include	"VDSris_def.h"

#include	"VDdebug.h"
#include	"VDmem.h"
#include	"v_risproto.h"

//#define		VD_DEBUG	1

extern char *RIS_ENV;


/*------------------------------------------------------------------*/
int	VdsRisConnect( env_name)

char	*env_name;
{
	FILE		*fopen();
	char		string[1024];
	static char	*RISTMPDIR="/usr/tmp";
	int		status;
	char		nfm_usr[100], d_nfm_usr[100];
	char		nfm_pwd[100], d_nfm_pwd[100];
	char		usr_ptcl[100], d_usr_ptcl[100];
	char		temp_str[100];
	char		address[100];
	char		*clh_status;
	schema_file_parms	parms;
	long            lngth  = 25;

  __enterFunction ( name = "VdsRisConnect" );
 	
#if (defined(SUNOS) || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) || defined(OS_HPUX))
        lngth = 26;
#endif

        if(RIS_ENV != (char *)0 && strcmp(RIS_ENV,"")) 
		_FREE (RIS_ENV);
	sprintf(string,"RIS_PARAMETERS=%s/%s",RISTMPDIR,"parameters");
	if((RIS_ENV = _MALLOC(1+strlen(string),  char)) == (char *)0)
	{
		printf("VdsRisConnect: Malloc failed for RIS_ENV \n");
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}
	strcpy(RIS_ENV,string);

	if((status = putenv(RIS_ENV)) != 0)
	{
		printf("VdsRisConnect: Failed to putenv<%s> status<%d>\n",string,status);
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}

	/* Initialize the parameters Variable */
	parms.protocol = 'M';
	strcpy(parms.address,"");
	strcpy(parms.username,"");
	strcpy(parms.password,"");
	strcpy(parms.filename,"risschema");

	clh_status = (char *)clh_vbyop ( env_name, "NETPROP17", nfm_usr, lngth);
	if (clh_status)
	{
		printf("CLH_VBYOP: Username status = <%s>\n",clh_status );
		VdsReset_ris_env();
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}
	sprintf( temp_str, "%*.*s", 25, 25, nfm_usr);
	status = NFMdecrypt ( temp_str, d_nfm_usr);
	if(status != NFM_S_SUCCESS)
	{
		printf("Error Decrypt: NFM USER \n");
		VdsReset_ris_env();
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}
	clh_status = (char *)clh_vbyop ( env_name, "NETPROP18", nfm_pwd, lngth);
	if (clh_status)
	{
		printf("CLH_VBYOP: Password status = <%s>\n",clh_status );
		VdsReset_ris_env();
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}
	sprintf( temp_str, "%*.*s", 25, 25, nfm_pwd);
	status = NFMdecrypt ( temp_str, d_nfm_pwd);
	if(status != NFM_S_SUCCESS)
	{
		printf("Error Decrypt: NFM PASSWD \n");
		VdsReset_ris_env();
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}
	clh_status = (char *)clh_vbyop ( env_name, "NETPROP16", usr_ptcl, lngth);
	if (clh_status)
	{
		printf("CLH_VBYOP: Protocol status = <%s>\n",clh_status );
		VdsReset_ris_env();
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}
	sprintf( temp_str, "%*.*s", 25, 25, usr_ptcl);
	status = NFMdecrypt ( temp_str, d_usr_ptcl);
	if(status != NFM_S_SUCCESS)
	{
		printf("Error Decrypt: NFM PROTOCOL \n");
		VdsReset_ris_env();
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}

	strcpy(address, env_name);
	strcpy(parms.username, d_nfm_usr);
	strcpy(parms.password, d_nfm_pwd);
	strcpy(parms.address, address);

	switch(d_usr_ptcl[0])
	{
		case 'd':
		case 'D':  parms.protocol='D';
			   break;
		case 't': 
		case 'T':  parms.protocol='X';
			   break;
		case 'x': 
		case 'X':  parms.protocol='X';
			   break;
		default:
			   printf("Bad Protocol Value<%s> \n",d_usr_ptcl);
  __exit_error_Function ( name = "VdsRisConnect" );
			   return(0);
	}

	RISlocate_schema_file(&parms);
	if(SQLCODE != RIS_SUCCESS)
	{
		printf("RISlocate Schema file failed status: <%d>\n",status);
		VdsReset_ris_env();
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}
	if ( VdsRisAttach() != SUCCESS)
	{
  __exit_error_Function ( name = "VdsRisConnect" );
		return(0);
	}

  __exitFunction ( name = "VdsRisConnect" );

	return(1);
}

int VdsReset_ris_env()
{

	int	size, status;

	size=96;

	if(RIS_ENV == (char *)0 || !strcmp(RIS_ENV,""))
	{
		/* RIS_PARAMETERS not set */
		return 1;
	}
	else 
		_FREE(RIS_ENV);

	if((RIS_ENV = _MALLOC(size, char)) == (char *)0)
	{
		printf("Malloc failed for RIS_ENV \n");
		return(0);
	}
	strcpy(RIS_ENV,"RIS_PARAMETERS=/usr/ip32/ris/parameters");
	if((status=putenv(RIS_ENV)) != 0)
	{
		printf("Failed to define environment variable %s status <%d>\n",
			RIS_ENV,status );
		return(0);
	}

	return 1;
}
