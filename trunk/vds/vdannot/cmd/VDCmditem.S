/* $Id: VDCmditem.S,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdannot/cmd/VDCmditem.S
 *
 * Description:		Place Item Number Command
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmditem.S,v $
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
# Revision 1.7  1996/01/10  18:36:14  pinnacle
# Replaced: vdannot/cmd/VDCmditem.S for:  by jwfrosch for vds.240
#
# Revision 1.6  1995/08/04  22:34:04  pinnacle
# Replaced: vdannot/cmd/VDCmditem.S for:  by jwfrosch for vds.240
#
# Revision 1.5  1995/08/04  16:24:56  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.[IS] for:  by jwfrosch for vds.240
#
# Revision 1.4  1995/07/25  22:49:18  pinnacle
# Replaced: vdannot/cmd/* for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/07/13  15:18:04  pinnacle
# Replaced: vdannot/cmd/VDCmditem* for:  by jwfrosch for vds.240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *      01/06/95    cvr		New VDitem created for prefix, hence CO changed
 *
 *	06/15/95    tlb		Revise instance variables.
 *
 *	01/10/96     HF		Added #defines for the NEW VDPlItem FORM
 *************************************************************************/

class specification VDCmditem (2:0) of VDCmdAnnot;

#include "VDCmdAutxt.h"
#include "vdandef.h"
#include "VDSannot.h"

/* These #defines should best be moved to "VDSannot.h"	*/

# define	GAD_GROUP	31
# define	GAD_TABLE	51
# define	GAD_ROW_LST	53

# define	GAD_TGL_TXT1	60
# define	GAD_TGL_TXT2	62
# define	GAD_TGL_TXT3	64

# define	GAD_TOGGLE_1	61
# define	GAD_TOGGLE_2	63
# define	GAD_TOGGLE_3	65

# define	DIM_ENV_FORM	41
# define	MOD_DIM_ANNOT	42
# define	FRM_TXT_LDRL	43

# define	FI_MSG_FLD_9	( FI_MSG_FIELD - 1 )

/* Gadgets / Groups defined in FORM : "VDPlItemAut"	*/

# define	SBF_POS_GROUP	12
# define	SBF_LDR_GROUP	13

# define	VD_FIXED_TBL	81

/* Some #defines for gadgets in the NEW VDPlItem FORM */

# define	VD_STCK_GRP	 99
# define	VD_STAC_GRP	100
# define	VD_STAC_TGL	121
# define	VD_STAC_DST	 29

# define	VD_TEXT_GRP	101
# define	VD_TEXT_TGL	111

instance VDCmditem
{
  int				obj_list_tgl;		/* state of GAD_TOGGLE_1		*/
  int				locat_all_tgl;		/* state of GAD_TOGGLE_2		*/
  IGRboolean			obj_not_in_table;	/* True: not in any Table, else FALSE	*/

  struct GRid			MgrId;			/* GRid of VDitemMgr			*/
  struct VDTblId_Name		table_info;		/* GRobj_env & Names of Selected BOM Table*/
  struct GRobj_env		active_row;		/* GRobj_env of selected row		*/
  struct GRobj_env		save_located;		/* GRobj_env of located object		*/

  int				nb_Tbl_Info;		/* Total # of selectable Tables		*/
  variable struct VDTblId_Name	Tbl_Info[0];		/* GRobj_env & Names of Tables		*/

  int				tot_nb_rows;		/* Total # of rows in selected table	*/
  variable struct GRobj_env	row_id[0];		/* GRobj_env of rows in selected table	*/

  int				tot_posble_rows;	/* # of possible UNCONNECTED_TO_ITEM rows*/
							/* when item in more then 1 table	*/
  variable struct VDTblId_Name	possible_tbls[0];	/* GRobj_env & Names of Tables		*/
  variable struct GRobj_env	possible_rows[0];	/* GRobj_env of possible rows		*/

	/*	Instance Variables for Auto Place Item		*/

  IGRboolean			fixed_table;
  IGRboolean			subform_display;
  IGRboolean			auto_check_frm;
  IGRint			auto_leader;
  IGRpoint			auto_offset;
  double			position;
  double			angle1, angle2,
				mylen1, mylen2;
  struct EX_button		window;

  variable struct GRobj_env	obj_selected[0];	/* Selected Objects for Auto Place	*/

  IGRint			nbObjs;			/* # of Objs connected to Table Row	*/
  variable struct GRobj_env	Objs_list[0];		/* List of Objs connected to Table Row	*/
};

override init_type,
         wakeup,
	 process_bln_form,
	 LC_selection,
	 place_dimension,
	 display_dimension,
         execute;

/*+me
 ---------------------------------------------------------------------------
  Private Message VDGetRowIdsForTbl

  Abstract
        This method initializes instance data

  Arguments
        IGRlong         *msg            O       Return code: MSSUCC / MSFAIL

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message VDGetRowIdsForTbl ( IGRlong *msg );

/*+me
 ---------------------------------------------------------------------------
  Private Message update_table_info_field

  Abstract
        This method checks to how many Rows / Tables is connected

  Arguments
        IGRlong         *msg            O       Return code: MSSUCC / MSFAIL
        struct GRid	 ModelId	I

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message	update_table_info_field ( IGRlong *msg; struct GRid ModelId );

/*+me
 ---------------------------------------------------------------------------
  Private Message auto_place_item

  Abstract
        This method implements Auto Place Item functionality

  Arguments
        IGRlong         *msg            O       Return code: MSSUCC / MSFAIL

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message	auto_place_item ( IGRlong *msg );

/*+me
 ---------------------------------------------------------------------------
  Private Message chg_props_leader

  Abstract
        This method sets LeaderLine & Arrow to NON_DISPLAYABLE & NON_LOCATABLE

  Arguments
        IGRlong         *msg            O       Return code: MSSUCC / MSFAIL
        struct GRid	 ItemId		I	VDitem

  Notes/Remarks

  Status/Return Code
      status == OM_S_SUCCESS    if success;
 ---------------------------------------------------------------------------
-me*/

message chg_props_leader ( IGRlong *msg; struct GRid ItemId );

end specification VDCmditem;
