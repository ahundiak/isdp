/* $Id: VSmigrstCmd.S,v 1.1.1.1 2001/01/04 21:10:25 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSmigrstCmd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSmigrstCmd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1997/10/06  11:16:02  pinnacle
# Created: vscmd/VSmigrstCmd.S by svkadamb for struct
#
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *                      suresh          creation
 ***************************************************************************/
/*
	I/STRUCT
*/
class specification VSmigrstCmd (1:0) of VSlocateCmd ;
instance VSmigrstCmd {
	int		num_of_stfns ;
	int		nb_stiff_located;
	int		nb_stiff_fr_name;
} ;

message init_cmd( int *sts );

message store_stiffener( int *sts ) ;

message process_fence( int *sts ) ;

message setFormSettings() ;

message saveFormSettings() ;

override form_notification ;

end specification VSmigrstCmd ;
