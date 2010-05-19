/* $Id: VdsExec.C,v 1.1.1.1 2001/01/04 21:09:12 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdris/imp / VdsExec.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VdsExec.C,v $
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
 * Revision 1.3  1996/04/21  23:27:24  pinnacle
 * Replaced: vdris/imp/*.C for:  by v240_int for vds.240
 *
 * Revision 1.2  1996/01/30  21:03:56  pinnacle
 * Replaced: ./vdris/imp/VdsExec.C for:  by azuurhou for vds.240
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
#include	"v_risproto.h"

#define		AS_DEBUG	1
 
extern char     g_environ[];

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
        char            encode[MAXWORD];
        char            temp_str[MAXWORD];
	char		*clh_status;
	int		lngth = 25,
			status;

#if (defined(SUNOS) || defined(OS_SOLARIS) || defined(OS_SCO_UNIX) || defined(OS_HPUX))
        lngth = 26;
#endif
 
	clh_status = (char *)clh_vbyop ( g_environ, key, encode, lngth );
	if(clh_status)
	{
		printf("VdsExtractDecodedString: CLH_VBYOP: Status = <%s>\n",clh_status );
		return FAILURE;
	}
	sprintf( temp_str,"%*.*s", 25, 25, encode);
	status = NFMdecrypt (temp_str,decode);
	if(status != NFM_S_SUCCESS)
	{
		printf("VdsExtractDecodedString: Error NFMdecrypt \n");
		return FAILURE;
	}

	return SUCCESS;
}
/******************************************************************************/
