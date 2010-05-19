/* $Id: VdsLoad.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VdsLoad.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsLoad.C,v $
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
 * Revision 1.4  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.3  1996/03/18  20:38:08  pinnacle
 * Replaced: vdris/imp/VdsLoad.C for:  by hverstee for vds.240
 *
 * Revision 1.2  1995/12/20  19:46:00  pinnacle
 * Replaced: vdris/imp/VdsLoad.C for:  by jwfrosch for vds.240
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
 *	12/20/95	  HF		Added VDdebug.h & __<fnc. calls>
 *					(Intel Solaris database problem)
 *					Also added test to ensure proper
 *					functioning of clh_vbyop() :
 *
 *			#if (defined(SUNOS) || defined(OS_SOLARIS) || \
 *		 	defined(OS_SCO_UNIX) || defined(OS_HPUX))
 *		        	lngth = 26;
 *			#endif
 *	04/19/96   tlb		Add prototypes
 *
 * -------------------------------------------------------------------*/

#include	<stdio.h>
#include	<string.h>
#include	<ctype.h>

#include	"VDSris_def.h"
#include	"VDSris_siz.h"
#include	"VDSload.h"
#include	"VDSserver.h"
#include	"NFMerrordef.h"
#include	"PDUuser.h"
#include	"PDUerror.h"
#include	"VDdebug.h"
#include	"v_risproto.h"

//#define		VD_DEBUG	1
#define		AS_DEBUG	1
 
extern	char	VDSenvir_name[];

/******************************************************************************/
/*                                                                            */
/* Author : Marc Fournier (ISDC)                                              */
/* Date   : 26-Nov-1991                                                       */
/*                                                                            */
/******************************************************************************/

/******************************************************************************/
int VdsExtractDecodedString ( key, decode)

	char	key[];
	char	decode[];

/*.VdsExtractDecodedString*/
{
        char            encode  [MAXWORD];
        char            temp_str[MAXWORD];
	char		*clh_status = NULL;
	int		status = 0;
	long            lngth  = 25;

  __enterFunction ( name = "VdsExtractDecodedString" );

#if (defined(SUNOS) || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) || defined(OS_HPUX))
        lngth = 26;
#endif

  __printf ( "lngth = %d, VDSenvir_name = <%s>, key = <%s>, decode = <%s>", `lngth, VDSenvir_name, key, decode` );

	/*
	 * if( ! *VDSenvir_name )
	 */
        if ( VDSverify_login() != PDM_S_SUCCESS )
	{
/*
		printf("VdsExtractDecodedString: No connection to data base\n");
*/

  __exitFunction ( name = "VdsExtractDecodedString" );

		return (status = FAILURE) ;
	}
	encode[0] = '\0';

  __printf ( ">>>>> clh_vbyop: VDSenvir_name = <%s>", VDSenvir_name );

	clh_status = (char *)clh_vbyop ( VDSenvir_name, key, encode, lngth);

	if(clh_status)
	{
  __printf ( "<<<<< clh_vbyop: clh_status = <%s>, encode = <%s>", `clh_status, encode` );

		printf("VdsExtractDecodedString: CLH_VBYOP: Status = <%s>\n",clh_status );

  __exitFunction ( name = "VdsExtractDecodedString" );

		return FAILURE;
	}

  __printf ( "<<<<< clh_vbyop: strlen(encode) = %d, encode = <%s>", `strlen(encode), encode` );
	  
	  
	sprintf( temp_str,"%*.*s", 25, 25, encode);
//	sprintf( temp_str,"%*.*s", strlen(encode), strlen(encode), encode);

  __printf ( ">>>>> NFMdecrypt: temp_str = <%s>", temp_str );

	status = NFMdecrypt (temp_str, decode);

  __printf ( "<<<<< NFMdecrypt: temp_str = <%s>, decode = <%s>", `temp_str, decode` );
  __printf ( "<<<<< NFMdecrypt: status = %d, NFM_S_SUCCESS = %d, MAXWORD = %d", `status, NFM_S_SUCCESS, MAXWORD` );

	if(status != NFM_S_SUCCESS)
	{
		printf("VdsExtractDecodedString: Error NFMdecrypt \n");
		return FAILURE;
	}

  __exitFunction ( name = "VdsExtractDecodedString" );

	return SUCCESS;
}
