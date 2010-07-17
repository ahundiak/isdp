
/* $Id: VCCmdPJ.S,v 1.1.1.1 2001/01/04 21:12:27 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vccmd/VCCmdPJ.S
 *
 * Description:
 *
 *  Specification file for Place Cable commands
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCCmdPJ.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:27  cvs
 *     Initial import to CVS
 *
# Revision 1.1  1999/01/19  09:49:28  pinnacle
# Created: vccmd/VCCmdPJ.S by aharihar for route
#
 *
 * History:
 *      MM/DD/YY        AUTHOR        DESCRIPTION
 *
 *      09/16/98          Alwin	      Creation
 *
 * -------------------------------------------------------------------*/

class specification VCCmdPJ (0:0) of VCCmdCAT;

#include "vc_define.h"
#include "VCstructs2.h"

instance VCCmdPJ
{
  IGRchar	bDblSidedTerminal;

  IGRchar	*form_ptr;

  IGRchar	EquipmentTag[VC_MAX_CCODE]; /* to store the Equipment's Tag */

  IGRint	nMaxNoPos;
  IGRshort	nNumConEnt;
  IGRshort	nMaxCon;
  IGRshort	nNumConTab;

  /* Jumper information which will be stored in the Terminals object */
  IGRint	nNbJumper; /* As such this can't stored in the instance, b'cas
			   we don't one defined to store this. So we will put
			   this in Terminal Collectors. So that we can use this
			   for indexing and to have a count of it. */
  struct VCJumpConn JumperConn[500];
  struct VCJumpData JumperData[20];

  /* Terminal Information */
  struct VClayout *PosTab;
  struct GRid   ModelId;
};

override init;
override wakeup;
override sleep;
override form_notification;

message VCFstart();

message VCCleanup( IGRlong *sts );

/* This method stores the object id obtained from the "me->event1" structure
 * and retrieves all the required data to populate the form.
 */
message VCGetObject( IGRlong *sts );

/* This method is just for displaying the data in the form */
message VCDispForm( IGRlong *sts );

/* This will get the Maximum number of terminals positions which a Jumper 
 * can be connected to.
 */
message VCGetJumpMaxPos( IGRlong *sts; IGRchar *szCompCode );

end specification VCCmdPJ;

