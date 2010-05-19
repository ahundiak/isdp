/* $Id: VDSdbdbg.c,v 1.1.1.1 2001/01/04 21:08:58 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdpdm/source / VDSdbdbg.c
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSdbdbg.c,v $
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
                                /*      VDSdbdbg.c                            */
                                /*                                            */
                                /**********************************************/
#include	<stdio.h>
#include	<DEBUG.h>
#include	"VDSdbmsg.h"
#include	"VDSdberrdef.h"

extern 	char	VDS_DEBUG_FILE[];
extern  int	VDSdebug_on;

/*----------------------------------------------------------------------------*/

int good ( sts)

   int	sts;		/* routine return code to test			      */

{
   if ( sts != VDS_S_SUCCESS)
     {
      printf ("%s%d\n", VDS_S5, sts);
      return (0);
     }
   else
      return (1);
}

int	VDSset_debug_on()
{
	int 	toggles[NFM_DEBUG_SUBSYSTEMS];
	char	files[NFM_DEBUG_SUBSYSTEMS][NFM_DEBUG_FILE_SIZE];

	VDS_DEBUG_FILE[0] = '\0';

	toggles[6] = 1;  		/* NETS ( server side ) ON */
	toggles[8] = toggles[9] = 1;	/* NFM & SQL debug ON 	   */
	toggles[11] = toggles[14] = 1;	/* MEMS & ERRS debug ON	   */

	sprintf ( VDS_DEBUG_FILE,"%s","/usr/tmp/vds.dbg");
	sprintf ( files[6], "%s","/usr/tmp/net.dbg");
	sprintf ( files[8], "%s","/usr/tmp/nfm.dbg");
	sprintf ( files[9], "%s","/usr/tmp/nfm.dbg");
	sprintf ( files[11], "%s","/usr/tmp/mem.dbg");
	sprintf ( files[14], "%s","/usr/tmp/err.dbg");

	NFMall_debug (toggles, files );

	return VDS_S_SUCCESS;
}

int   VDSdebug(s)
char	s[300];
{
	FILE	*outfile, *fopen();

	if ( VDSdebug_on)
	{
		if (( strcmp (VDS_DEBUG_FILE,"")) != 0)
		{
			if (( outfile = fopen (VDS_DEBUG_FILE, "a")) == NULL)
			    return ( VDS_E_OPEN_FILE );
			fputs (s, outfile);
			fclose (outfile);
		}
	}
	return VDS_S_SUCCESS;
}
