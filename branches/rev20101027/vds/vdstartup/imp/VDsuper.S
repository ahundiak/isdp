/* $Id: VDsuper.S,v 1.1.1.1 2001/01/04 21:09:23 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vdstartup/imp / VDsuper.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDsuper.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:23  cvs
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
# Revision 1.2  1995/08/10  18:29:52  pinnacle
# Replaced: vdstartup/imp/VDsuper.S for:  by azuurhou for vds.240
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
 *      08/10/95	Ravi		Overide Wake_up of globalclass
 * -------------------------------------------------------------------*/

/*
    ABSTRACT

    This super object is created at initialiation time.
*/
  
 
     

    
class specification VDsuper (0:1) of global_class;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"
#include "exdef.h"
#include "ex.h"
#include "DIdef.h"

instance VDsuper 
{
 /* no instance needed */
};

override   wake_up, 
      	   sleep ;	

end specification VDsuper;
 

