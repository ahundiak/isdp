/* $Id: VDXincludes.h,v 1.1.1.1 2001/01/04 21:07:30 cvs Exp $  */

/**************************************************************************
 * I/VDS
 *
 * File:	include/VDXincludes.h
 *
 * Description:
 *		All needed include files are combined in this file.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDXincludes.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:30  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1999/04/19  14:08:00  pinnacle
 * for dynapipe
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *      04/16/99        ylong           created
 *
 ***************************************************************************/

#ifndef	VDXincludes_include
#	define	VDXincludes_include

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>
#include <sys/errno.h>
#include <fcntl.h>
#include <UMS.h>
#include <FI.h>

#include "OMtypes.h"
#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMindex.h"
#include "msdef.h"
#include "ex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "transdef.h"
#include "translate.h"
#include "transerr.h"
#include "transmacros.h"
#include "exsysdep.h"
#include "exmacros.h"

#include "wl.h"
#include "igecolor.h"
#include "igecolordef.h"
#include "igewindef.h"
#include "igewindow.h"
#include "igewinmacros.h"
#include "igecolmacros.h"


#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"

#include "msdef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "growner.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
 
#include "grmacros.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "growner.h"

#include "dpdls.h"		/* BUILTIN_STYLES	*/
#include "dpdef.h"
#include "dpmacros.h"

#include "ACattrib.h"
#include "ACrg_collect.h"

#include "EMSopt.h"		/* define EMS_GETB_COMPAT..	*/
#include "EMSsfparms.h"		/* Surface params		*/


