/* $Id: vdpktdef.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / vdpktdef.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdpktdef.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
 * 	I/VDS
 *
 * This file contains constants necessary to add new icons to the
 * pocket menu.
 *
 */

#ifndef vrpktdef_include
#define vrpktdef_include


/*
 * default icon sizes
 */

#define		VD_PKT_S_ICONSIZE	44
#define		VD_PKT_D_ICONSIZE	89	/* two singel + 1 space */

#define		VD_E_GRP_EXIST		0x10	/* pocket menu group exist  */
#define		VD_E_NO_POCKETMENU	0x20	/* no pocketmenu found      */
#define		VD_E_NO_DEF_POCKET	0x40	/* def pocket menu not found*/
#define		VD_E_ERROR		0x80	/* error in encountered     */


/*
 * dummy symbol gadget
 */
#define		VD_PKT_SYMBOL		256

/*
 * This structure contains information about gadgets to add to default pocket
 * menu.
 */
struct VDpktGadgets{
        long    type_cmd ;      /* type of command FI_CMD_KEY or             */
                                /* FI_CMD_STRING.                            */
        char    *cmd ;          /* the command string or ASCII key.          */
        char    *sym_file ;	/* symbol file (size FI_MAX_FILENAME_LENGTH) */
        int     sym_index ;     /* symbol index in symbol file.              */
} ;

/*
 * maximum of pocket gadgets to add.
 */
#define         VDPKT_MAX_GADGETS       30

/*
 * end of VDpktGadgets structure list indicator.
 */
#define		VDPKT_ENDLIST	-1
#define		VDPKT_DUPLICATE	-2

/*
 * default pocket menu name.
 */
#define		VDPKT_POCKET_MENU	"POCKET_MENU"
#endif

