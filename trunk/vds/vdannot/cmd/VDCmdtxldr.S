/* $Id: VDCmdtxldr.S,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdtxldr.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdtxldr.S,v $
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
# Revision 1.3  1996/03/26  15:27:54  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldr.S for:  by yzhu for vds.240
#
# Revision 1.2  1995/01/13  20:36:26  pinnacle
# Replaced:  vdannot/cmd/VDCmdtxldr.S r#
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

class specification VDCmdtxldr (2:0) of VDCmdAnnot;

#include "VDSannot.h"

instance VDCmdtxldr
{
  /* formatted expression directory */
  char		dir_name[TEXT_SIZE];
  
  /* macro identifier and name */
  IGRchar		macro_name[TEXT_SIZE];
  IGRchar		prev_macro_name[TEXT_SIZE];

  /* new ldexpr instance */
  variable struct VDmacro_occ	macro_list[0];	/* all defined macros with expr */
  variable struct VDldline_expr ldexpr_list[0];	/* all formats in system */
  struct	VDldline_expr	form_expr;	/* current expression */

  /* place macro occurence */
  struct	GRobj_env	HDR_OCC;
  struct	GRid		MACRO_OCC;

  IGRuchar	an_box_type;			/* graphical box option. */
  IGRint        control_display;
};

override init_type,
	 wakeup,
	 notify_form,
	 display_form,
	 LC_selection,
	 place_dimension,
         execute;

message create_macro ( long * sts );

message txt_output ( long * sts );

message set_ldexpr_active ( long * sts; int index );

message get_default_ldexpr ( long * sts; int * index );

message set_default_ldexpr ( long * sts; int index );

message get_exist_formats ( long * sts );

message get_parent_formats ( long * sts );

message get_global_formats ( long * sts );

message disp_exist_formats ( long * sts; int active );

message disp_exist_macros ( long * sts );

message place_form ( long * sts );

end specification VDCmdtxldr;
