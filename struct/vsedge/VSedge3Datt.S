/* $Id: VSedge3Datt.S,v 1.1.1.1 2001/01/04 21:10:35 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsedge/VSedge3Datt
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSedge3Datt.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:35  cvs
 *      Initial import to CVS
 *
# Revision 1.2  1999/05/18  19:15:26  pinnacle
# TR_179900603
#
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1997/10/31  14:33:46  pinnacle
# Update include list
#
 *
 * History:
 *      MM/DD/YY        AUTHOR	DESCRIPTION
 *      10/31/97        ah      added header
 *      05/17/99        ejm     Added ACcheckin_candidate, ACgive_structure,
 *				  ACget_db_info overrides
 ***************************************************************************/

class specification VSedge3Datt(0:0) of VSfeature;

override ACconstruct_feet;

override VSgetObjDef;

override VDgetParameters;

override VDreviewParameters;

override ACcheckin_candidate;	/* eliminate posting error message         */

override ACgive_structure;	/* allow Rev Attr cmd values to be printed */

override ACget_db_info;		/* for future posting of edge attributes   */

end specification VSedge3Datt ;
