/* $Id: VDCmdRepFnc.I,v 1.1.1.1 2001/01/04 21:09:07 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdrep/cmd / VDCmdRepFnc.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdRepFnc.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:07  cvs
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
# Revision 1.2  1995/07/24  19:23:28  pinnacle
# Replaced: vdrep/cmd/VDCmdRepFnc.I for:  by hverstee for vds.240
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

class implementation VDCmdRep;

#define AS_DEBUG 1
#include "AS_status.h"
#include "AS_debug.h"

int VRstrip_space( in_string, out_string )
 char * in_string;
 char * out_string;
{
  int i,j;
  int length_in;
  
  i=0; j=0;
  length_in = strlen( in_string );
  while ( i < length_in || in_string[i] != '\0' )
  {
  	if ( in_string[i] != ' ' ) {
	     out_string[j] = in_string[i];
	     j++;
	}
	i++;
  }
	
  out_string[j] = 0;
	
  return 1;
}
end implementation VDCmdRep;

