/* $Id: VDCSlAsCp.S,v 1.2 2001/01/11 21:01:17 art Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vds/vdat/cmd/VDCSlAsCp.S
 *
 * Description: This is the specification file for the command, VDCSlAsCp.
 *              The command is used for interfacing with the form,
 *		SelAssyCmp.frm, which allows selection of sets and nodes
 *		from the Assembly Tree.
 *
 *		The command must be invoked again for more than one set
 *		to be selected.
 *
 * Dependencies:        Forms:
 *                      SelAssyCmp.frm, "Select Assembly Components"
 *
 * Revision History:
 *      $Log: VDCSlAsCp.S,v $
 *      Revision 1.2  2001/01/11 21:01:17  art
 *      sp merge
 *
# Revision 1.1  2000/04/10  19:03:32  pinnacle
# ah
#
# Revision 1.2  2000/03/09  16:59:10  pinnacle
# ylong
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/10  20:24:20  pinnacle
# TR179800633
#
# Revision 1.1  1997/12/18  20:53:30  pinnacle
# Assembly Tree: spec file for Select Assembly Component command, new
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 12/16/97  EJM     Created this file.
 * 04/10/98  ah      TR179800633 Add ability to specify 2d view
 *                   Added objOE to hold 2d view but not currently using it
 * 03/09/00  ylong   TR179901080 Add message VDcheckCommands
 ***************************************************************************/

class specification VDCSlAsCp (1:0) of VDS_LOCATE;


#include "FI.h"
#include "VDtypedef.h"

instance VDCSlAsCp
{
      Form form_ptr;
      TGRobj_env objOE;
      
};

message VDCpickedView(int *msg; int flag);
message VDCcheckCommands(int *msg);

override init;
override delete;
override form_notification;

end specification VDCSlAsCp;









