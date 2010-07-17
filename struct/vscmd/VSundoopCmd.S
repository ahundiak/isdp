/* $Id: VSundoopCmd.S,v 1.1.1.1 2001/01/04 21:10:28 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSundoopCmd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSundoopCmd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:28  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.3  1997/10/28  09:14:44  pinnacle
# Replaced: vscmd/VSundoopCmd.S for:  by smpathak for struct
#
# Revision 1.2  1997/10/06  06:58:44  pinnacle
# Replaced: vscmd/VSundoopCmd.S for:  by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          modification
 *	10/20/97        S.M.Pathak      modification
 ***************************************************************************/
/*
	I/STRUCT
*/
class specification VSundoopCmd(1:0) of VSpartopCmd ;

message hiliteResult( long *msg ) ;

message hiliteOperators( long *msg );

message getAllOperators( long *msg );

override store_operand;

override operation ;

override locate_action_handler ;

end specification VSundoopCmd ;
