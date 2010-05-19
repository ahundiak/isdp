/* $Id: VDCmdRvItem.sl,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdRvItem.sl
 *
 * Description:
 *	COmmand object for "Review Elements with item numbers"
 *	Slic file to produce spec file, state table and command table entry
 *	Implementation files are separate
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdRvItem.sl,v $
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
# Revision 1.10  1996/01/03  20:52:06  pinnacle
# Replaced: vdannot/cmd/VDCmdRvItem.sl for:  by azuurhou for vds.240
#
# Revision 1.9  1995/12/21  00:16:52  pinnacle
# Replaced: vdannot/cmd/VDCmdRvItem.sl for:  by yzhu for vds.240
#
# Revision 1.8  1995/08/22  21:09:04  pinnacle
# Replaced: vdannot/cmd/VDCmdRvItem.sl for:  by yzhu for vds.240
#
# Revision 1.7  1995/08/16  15:36:40  pinnacle
# Replaced: vdannot/cmd/VDCmdRvItem.sl for:  by yzhu for vds.240
#
# Revision 1.6  1995/08/11  02:16:16  pinnacle
# Replaced: vdannot/cmd/VDCmdRvItem.sl for:  by yzhu for vds.240
#
# Revision 1.5  1995/07/26  19:52:10  pinnacle
# Replaced: vdannot/cmd/VDCmdRvItem.sl for:  by yzhu for vds.240
#
# Revision 1.3  1995/06/29  22:10:02  pinnacle
# Replaced: vdannot/cmd/VDCmdRvItem.sl for:  by yzhu for vds.240
#
# Revision 1.2  1994/12/20  17:17:12  pinnacle
# Replaced:  vdannot/cmd/VDCmdRvIt* r#
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
 *	02/11/94	Raju		Creation
 *	12/15/94	R. Manem	Rewriting of command object to
 *					handle new VDitem objects
 *      08/10/95        Y.Zhu           Add actions for saving and geting 
 *                                      form location.
 *	01/03/96	adz		CHange the filter to avoid crash
 *					in playback process.
 * -------------------------------------------------------------------*/


/****************************************************************************
 *			CLASS SPECIFICATION				
 ****************************************************************************/

command_string	VDC_M_RevItem, 0, VDRevItem
class		VDCmdRvItem
super_class	VDS_LOCATE
product_name	"$VDS"
command_table	"vds.cmd"
options		"SiTC"

/* used forms */
form		"VDRevElWtItem",0,0,"-1","-1"

start_state	start


/****************************************************************************
 *			SPECIFICATION AREA	
 ****************************************************************************/
specification

#include  "OMminimum.h"
#include  "OMprimitives.h"
#include  "igetypedef.h"
#include  "igrtypedef.h"
#include  "VDSannot.h"
#include  "VDSFilter.h"
#include  "vdandef.h"

/*
	Below is information for creating the spec file
*/

instance
{
    IGRint		curTblIndex;
    IGRint		highlightOpt;
    IGRint		fitObjOpt;
    IGRint		nbTables;
    struct GRid		windowId;
    IGRdouble           fitRatio;
    IGRint              ballonTog;
    IGRint              curTblInSet;
    IGRint              fit3DObject;
    variable IGRchar		  itemRegExpr[2];	
    variable IGRchar		  curTblName[0];
    variable struct VDitemInfo	  items[0];
    variable struct VDtblInfo     tables[10];
    variable struct VDitemInfoNew objItmNoBln[0];
    variable struct VDtblInfoNew  tableNoBln[10];
    variable struct VD_id_name    tableIdName[0];
    variable struct VDitemInfoNew objItmNoBlnNoSet[0];
    variable struct VDtblInfoNew  tableNoSet[0];
}

/****************************************************************************/
/*      STATE TABLE AREA                                                *****/
/****************************************************************************/

state_table

#include "VDmsg.h"
#include "VDCmdDef.h"
#include "VDSFilter.h"


state start

    display_form        0
    message_key         VD_M_RevItem
    prompt_key          VD_P_DgEntPmFm
    status              " "
    execute 		set_dynamics_in_form( &me->ret, me->forms[0].form_ptr )

    filter              vds_get_event

    on  EX_FORM_FINISHED                                state terminate

at init         do my_init
at delete       do free_instance
at wakeup       do VDupdateHighlight
		do VDset_form_pos
at sleep        do VDsave_form_pos

action 	my_init( long	*sts )					extern

action	sleep( int pos )					extern

action	mouse(	long	*msg;
		char	*form;
		int	x;
		int	y )					extern

action 	form_notification( 	int      form_label;
				int      gadget_label;
				double   value;
				char     *form_ptr )		extern

action	getWindow( long	*sts )					extern

action	VDupdateHighlight( long	*sts )				extern

action	VDupdatePfxList( long *sts )				extern

action	VDupdateItemList( long	*sts )				extern

action  VDget_itemNos_objIds ( IGRlong *msg;
                              struct GRid tblId;
                              IGRint  *nbObj;
                              struct VDitemInfoNew **objIdItm)  extern

action  free_instance(long       *sts )                         extern 
action  VDsave_form_pos(long     *sts )                         extern 
action  VDset_form_pos(long      *sts )                         extern 
