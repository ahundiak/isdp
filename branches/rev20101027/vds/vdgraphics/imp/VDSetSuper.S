/* $Id: VDSetSuper.S,v 1.1.1.1 2001/01/04 21:08:50 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdgraphics/imp / VDSetSuper.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDSetSuper.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:50  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
    ABSTRACT

    This super object is created at initialiation time.
*/

    
class specification VDSetSuper (0:1) of VDsuper;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "DIdef.h"

instance VDSetSuper 
{
 /* no instance needed */
};

override  sleep;	

end specification VDSetSuper;
 

