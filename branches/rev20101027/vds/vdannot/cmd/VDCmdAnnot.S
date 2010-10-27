/* $Id: VDCmdAnnot.S,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdAnnot.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdAnnot.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
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

class specification VDCmdAnnot (2:0) of COanplace;

#include "growner.h"

#define NUM_STATES 7 
#define NUM_TOKENS 7 

enum possible_states{ INITIAL,
		      WAIT_MAC,
		      WAIT_LEA,
                      WAIT_POSN,
		      WAIT_BK1,
		      WAIT_BRK,
		      WAIT_POS };

enum possible_actions{ NIL,
		       ERR,
		       PRT_LD,
		       STO_LD,
		       STO_NOLD,
		       LOC_MAC,
		       STO_MAC,
		       LOC_LEAF,
		       STO_LEAF,
		       NO_LEAF,
		       CNST_DIM,
		       GET_BRK,
		       ADD_BRK,
		       DELETE,
		       DIS_FOR,
		       PLACE };

enum possible_entries { PARENT,
			POINT, 
			NOENT };
instance VDCmdAnnot 
{
 /* global */
    IGRint 		count_macro;		/* number of element in fence */
    struct GRobj_env	hdr_set;		/* when fence locate    */
    IGRint action;
    IGRint input_required;
    int global_leader;
};

override init_type,
	 execute,
	 LC_selection,
	 LC_preproc,
	 LC_postproc,
	 get_keybrd_input,
         delete_dimension;

end specification VDCmdAnnot;
