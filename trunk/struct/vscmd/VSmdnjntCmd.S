/* $Id: VSmdnjntCmd.S,v 1.1.1.1 2001/01/04 21:10:23 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSmdnjntCmd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmdnjntCmd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:23  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1998/03/12  22:12:06  pinnacle
# Modify New Joint
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/12/98  suresh  creation
 ***************************************************************************/

class specification VSmdnjntCmd (1:0) of VSpartopCmd ;

#include "growner.h"
#include "vsdef.h"
#include "vs.h"
#include "vspart.h"
#include "vsattr.h"
#include "vsoptdef.h"
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"

instance VSmdnjntCmd {
	VSjointAttr	jAttr ;
	struct GRid	newUAid ;
} ;

message fillForm( long *msg ) ;

override form_notification ;

end specification VSmdnjntCmd ;
