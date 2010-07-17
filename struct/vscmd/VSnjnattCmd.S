/* $Id: VSnjnattCmd.S,v 1.1.1.1 2001/01/04 21:10:25 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vscmd/VSnjnattCmd.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSnjnattCmd.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:25  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.1  1998/03/13  23:27:44  pinnacle
# New Joints
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/13/98  ah      TR179800680 Modify New Joint - Creation
 ***************************************************************************/
class specification VSnjnattCmd (1:0) of CEO ;

instance VSnjnattCmd {
	char	*ActJnAttr_form,
	/*
	 * Pointer so save the pocket-menu, since we disable it while the
	 * save-restore from is up.
	 */
		*pkt_menu ;
} ;

message does_form_exist( int *sts ) ;

message createForm( int *sts ) ;

message initForm( long *msg ) ;

message displayForm( int * sts ) ;

message deleteForm( int * sts ) ;

message disable_enable_pkt_menu( int di0_en1 ) ;

end specification VSnjnattCmd ;
