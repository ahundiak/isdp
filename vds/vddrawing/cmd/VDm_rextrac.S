/* $Id: VDm_rextrac.S,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/cmd / VDm_rextrac.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_rextrac.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
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

class specification VDm_rextrac (0:1) of VDm_drawing;

#include "growner.h"

instance VDm_rextrac
{
 GRspacenum added_ref[100];
 int n_added_ref;
 variable struct GRid mismatched[100];
 int n_mismatched;
 variable struct GRid broken[100];
 int n_broken;
};

override 

  init,
  wakeup,
  execute,
  delete;

message realloc_mis(int nb_mis);
message realloc_broken(int nb_broken);
#if 0
message reextract();
#endif


end specification VDm_rextrac;
