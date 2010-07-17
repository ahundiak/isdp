/* $Id: VCSelCable.S,v 1.1.1.1 2001/01/04 21:12:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/ROUTE
 *
 * File:        vccmdutil/VCSelCable.S
 *
 * Description:
 *
 *  Specification file for select Cable command. Invoked through
 * 	pocket menu.
 *
 * Dependencies:
 *
 * Revision History:
 *     $Log: VCSelCable.S,v $
 *     Revision 1.1.1.1  2001/01/04 21:12:31  cvs
 *     Initial import to CVS
 *
# Revision 1.1  2000/03/10  23:08:30  pinnacle
# Added for CR179800048
#
 *
 * History:
 *      MM/DD/YY        AUTHOR      DESCRIPTION
 *
 *      03/09/2000		Alwin		Creation 
 *
 * -------------------------------------------------------------------*/

class specification VCSelCable (0:0) of VDS_LOCATE;

instance VCSelCable
{
};

message VCinit( long *sts ); /* To prevent the command being run on its own */

message VCGetCables( long *sts ); /* all the cables objects connected to the
									located objects */

end specification VCSelCable;
