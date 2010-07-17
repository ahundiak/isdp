/* $Id: VSplEdAtCmd.S,v 1.1.1.1 2001/01/04 21:10:26 cvs Exp $ */
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/spec/VSplEdAtCmd.S
 *
 * Description:
 *      This class created to allow the placement and modification of edge 
 *	attribute macros.
 *
 * Dependencies:
 *      Form, struct/config/english/forms/VSedgeAttr.frm
 *
 * Commands:
 *	Place  Edge Attributes, VSPlEdAt
 *	Modify Edge Attributes, VSMoEdAt
 *
 * Revision History:
 *	$Log: VSplEdAtCmd.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:26  cvs
 *	Initial import to CVS
 *	
# Revision 1.2  1999/04/23  18:33:58  pinnacle
# CR_179900195
#
 *
 * History:
 *      MM/DD/YY        AUTHOR  DESCRIPTION
 *      10/07/97        ejm     CR179700200: Need ability to place a contin-
 *                              uously changing bevel on plate edge.
 *
 *				Added messages, SetPlate, AddPlate, DeletePlate;
 *				Added plate list instance data (ptl).
 *	04/23/99	ejm	CR_179900195: removed array hardcoded value of
 *				20 and set it to ATT_NB_ATT.
 ***************************************************************************/


class specification VSplEdAtCmd(0:0) of VSpartopCmd ;


#include "vsedgeattr.h"  /* ATT_NB_ATT */


instance VSplEdAtCmd {
 struct GRobj_env edge_attr;
        int	process_step;
        double	list_att[ATT_NB_ATT];
        double	old_list_att[ATT_NB_ATT];
        char    *list_att_txt[ATT_NB_ATT];
        char    *old_list_att_txt[ATT_NB_ATT];
        char	word[150],word1[150];
 struct GRid    old_box;
        int     cur_edge;
	int     edge_count;
 struct GRid    ptl[10];           /* Temporary working list of parents */
 variable struct GRid edge_list[1];
};

message  dis_en_able_gadgets( long * ret );

message  erase_hilite( long * ret );

message  form_pos( long * ret );

message  init_instance( long * ret );

message  free_spec_data( long * ret );

message  chg_process_step( long * ret );

message  assign_action_handler( long * ret );

message  DispArrowGadgets( long * ret );

message  control_edge( long * ret );

message  modify_mac( long * ret );

message  save_all( long * ret );

message  VSplEdAtCmdributes( long * ret );

message  VSgetChldMac( 		struct GRid     parentId;
				char            *macName;
				struct GRid     *macrosOcId;
				IGRint          numMaxMacros;
				IGRint          *numMacros );

message  VSsetSymbNameDisp (    IGRlong         *msg;
                                IGRchar         *name;
                                IGRchar         *matchKey;
                                struct GRid     *matchId;
                                struct GRid     tar_geom;
				enum   GRdpmode *dpmode  );

message  SetPlate   ( long * ret );

message  DeletePlate( int  * ret );

message  AddPlate   ( long * ret );

override form_notification;

end specification VSplEdAtCmd ;
