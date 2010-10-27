/* $Id: VDCmditemi.I,v 1.2 2001/09/14 15:06:07 ylong Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdannot/cmd/VDCmditemi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmditemi.I,v $
 *	Revision 1.2  2001/09/14 15:06:07  ylong
 *	highlight selected table
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/04/17  20:14:36  pinnacle
# TR179800949
#
# Revision 1.2  1998/04/15  23:59:24  pinnacle
# Replaced: vdannot/cmd/VDCmditemi.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/22  18:59:48  pinnacle
# Replaced: vdannot/cmd/VDCmditemi.I for:  by yzhu for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.25  1996/04/10  18:25:44  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.24  1996/01/10  18:55:56  pinnacle
# Replaced: vdannot/cmd/VDCmditemi.I for:  by jwfrosch for vds.240
#
# Revision 1.23  1995/11/29  13:54:54  pinnacle
# Replaced: ./vdannot/cmd/VDCmditemi.I for:  by ksundar for vds.240
#
# Revision 1.22  1995/09/11  21:53:32  pinnacle
# Replaced: vdannot/cmd/VDCmditemi.I for:  by jwfrosch for vds.240
#
# Revision 1.21  1995/09/11  20:48:48  pinnacle
# Replaced: vdannot/cmd/VDCmditemi.I for:  by jwfrosch for vds.240
#
# Revision 1.20  1995/09/11  13:56:56  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.19  1995/09/08  21:28:00  pinnacle
# Replaced: vdannot/cmd/*.I for:  by jwfrosch for vds.240
#
# Revision 1.18  1995/09/06  21:09:56  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.17  1995/08/31  18:40:32  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.16  1995/08/30  13:26:54  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.15  1995/08/29  21:31:48  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.14  1995/08/24  17:39:26  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.13  1995/08/21  21:48:02  pinnacle
# Replaced: vdannot/cmd/VDCmditemi.I for:  by jwfrosch for vds.240
#
# Revision 1.12  1995/08/18  22:48:40  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.11  1995/08/04  22:33:52  pinnacle
# Replaced: vdannot/cmd/VDCmditemi.I for:  by jwfrosch for vds.240
#
# Revision 1.10  1995/08/04  16:24:56  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.[IS] for:  by jwfrosch for vds.240
#
# Revision 1.9  1995/07/26  20:07:52  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.8  1995/07/25  22:49:18  pinnacle
# Replaced: vdannot/cmd/* for:  by jwfrosch for vds.240
#
# Revision 1.7  1995/07/13  15:18:04  pinnacle
# Replaced: vdannot/cmd/VDCmditem* for:  by jwfrosch for vds.240
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *      01/06/95    cvr		New VDitem created for prefix, Hence CO changed
 *
 *	06/15/95    tlb		Modify to use new VDitem, VDitemSet, VDitemMgr
 *
 *	01/10/96     HF		Modify for the NEW VDPlItem FORM
 *
 *	04/10/96     HF		TR179601220
 *
 *      04/10/98   Ming         TR179800949
 *      04/17/98   ah           TR179800949 Removed static from _memo variables
 * -------------------------------------------------------------------*/

class implementation VDCmditem;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "AS_status.h"
#include "VDmsg.h"
#include "coparadef.h"
#include "coparamac.h"
#include "dimanform.h"
#include "VDSannot.h"
#include "vdandef.h"
#include "vdanmacros.h"
#include "VDTblItem_pr.h"
#include "asdef.h"
#include "asmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "asbox.h"

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"

#include "vddrwattr.h"
#include "v_miscmacros.h"

#include "VDdrwlo.h"
#include "VDdrwlo_pr.h"
#include "VDitemNum.h"

#include "grmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

from	DMroot		import	replace_text;
from	NDnode		import	NDconnect;
from	NDmacro		import	ACreturn_foot;
from	GRgraphics	import	GRdisplay;
from	expression	import	modify;
from	VDitem		import	VDputItemInfo;
from	VDitemMgr	import	VDcleanUp,
				VDconnectItmObjs;

from	VDdrwTbl	import	VDgetTotalNbOfRows,
				VDgetTableType;
from	VDdrwTblHdr	import	VDgetRowInfo,
				VDrowNoToGRid;
from	VDdrwTblRow	import	VDgetItemNumber,
				VDgetParentObjectList,
				VDisRowLinedOut;
from	GRvg		import	GRgetattr;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

extern GRclassid	OPP_ACpretend_class_id,
			OPP_ACpretendin_class_id,
			OPP_ACncpx_class_id,
			OPP_GRclhdr_class_id,
			OPP_GRsmhdr_class_id,
			OPP_VDitem_class_id,
			OPP_VDdrw2d_class_id,
			OPP_VDdrw3d_class_id,
			OPP_VDdrwTbl_class_id,
			OPP_VDdrwTblHdr_class_id,
			OPP_NDnodein_class_id;

extern int              VDGetVDdrw2dObject_FrmModelObj();

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				GLOBAL VARIABLES				*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

%safe
static int	VDPlItem_x_memo,
		VDPlItem_y_memo,
		VDPlItem_s_memo;
%endsafe

int VDitem_get_VDPlItem_x_memo( )
{
	return VDPlItem_x_memo;
}
void VDitem_set_VDPlItem_x_memo( int x )
{
	VDPlItem_x_memo = x;
}

int VDitem_get_VDPlItem_y_memo( )
{
	return VDPlItem_y_memo;
}
void VDitem_set_VDPlItem_y_memo( int y )
{
	VDPlItem_y_memo = y;
}

int VDitem_get_VDPlItem_s_memo( )
{
	return VDPlItem_s_memo;
}
void VDitem_set_VDPlItem_s_memo( int s )
{
	VDPlItem_s_memo = s;
}

static struct VDitem_geom
{
  IGRint	is_init;
  IGRint	offset_on;
  IGRint	leader_on;
  IGRdouble	position;
  IGRpoint	offset;
  IGRdouble	length1;
  IGRdouble	length2;
  IGRdouble	angle1;
  IGRdouble	angle2;
} VDitem_geom;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

static int comp_ItemNmrs
(
  struct GRobj_env	*in_row,
  struct GRobj_env	*out_row
)
{
  IGRlong	 msg;
  int		 status;

  char		 ItemNumIn	[VD_ITEMNUM_LEN],
		 ItemNumOut	[VD_ITEMNUM_LEN],
		 PrefixIn	[VD_ITEMNUM_LEN],
		 PrefixOut	[VD_ITEMNUM_LEN],
		 SuffixIn	[VD_ITEMNUM_LEN],
		 SuffixOut	[VD_ITEMNUM_LEN];
  IGRint	 itemsz = 0;

  ItemNumIn [0]	= ItemNumOut[0] = PrefixIn[0] = PrefixOut[0] = SuffixIn[0] = SuffixOut[0] = '\0';

  status = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber ( &msg, &itemsz, ItemNumIn ),
			senderid = NULL_OBJID,
			targetid = in_row->obj_id.objid,
			targetos = in_row->obj_id.osnum );
  as$status();

  status = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber ( &msg, &itemsz, ItemNumOut ),
			senderid = NULL_OBJID,
			targetid = out_row->obj_id.objid,
			targetos = out_row->obj_id.osnum );
  as$status();

  return ( VD_comp_ItemNumbers (ItemNumIn, ItemNumOut) );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

  /*
   * Display / Erase hilite
   */

void	VDdisplay_erase_hilite
(
  IGRlong		*msg,
  int			 nb_rows,
  int			 mode,
  struct GRobj_env	*RowId
)
{
  int		i0;
  struct GRid	oids_buf[1];

  for ( i0=0; i0 < nb_rows; i0++ )
  {
    oids_buf[0] = RowId[i0].obj_id;

    dp$display (msg	= msg,
		oids	= oids_buf,
		mode	= mode );
  }

}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method init_type()
{
  IGRchar		*dirname	= { "drw_tables" },
			*superClassName = { "VDdrwTbl" },
			 TableType[VD_DRWLO_CHR_IDFLD];
  IGRchar		 tmptxt [TEXT_SIZE];
  IGRlong		 msg;
  IGRint		 i0, status = OM_S_SUCCESS, count = 0, ref_file = 1, BOM_cnt = 0;
  struct VD_id_name	*IdName = NULL;

  __enterMethod ( name = "init_type" );

  status =
  VD_get_tableName ( &msg, dirname, superClassName, &count, ref_file, &IdName);

  for( i0=0 ; i0 < count ; i0++ )
  {
    if ( DMancestry_valid( IdName[i0].tbl_id, OPP_VDdrwTbl_class_id ) == OM_S_SUCCESS )
    {
      TableType[0] = '\0';
      status =
      om$send (	msg	 = message VDdrwTbl.VDgetTableType ( &msg, TableType ),
		targetid = IdName[i0].tbl_id.objid,
		targetos = IdName[i0].tbl_id.osnum );

      __printf ( "status = %d, IdName[%d] = [%d,%d], IdName[].tbl_name = <%s>, TableType = <%s>",
	`status, i0, IdName[i0].tbl_id.osnum, IdName[i0].tbl_id.objid, IdName[i0].tbl_name, TableType` );

      if ( strcmp ( "BOM", TableType ) == 0 ) BOM_cnt++;
    }
  }

  me->auto_check_frm	= FALSE;

  if ( ! count || ! BOM_cnt )
  {
    IGRint	  resp;

    resp = TERMINATE;
    ex$putque ( msg      = &msg,
		response = &resp );

    GRstatus_display_button(0);

    me->auto_check_frm = 1;

    status = OM_S_SUCCESS;
  }

  status =
  om$send (	msg	 = message VDCmdAnnot.init_type(),
		targetid = my_id,
		mode	 = OM_e_wrt_message);
  as$status();
  if ( ! ( status & 1 ) )
  {
    __print_goto ("wrapup");
    goto wrapup;
  }

  UI_status ( "" );	// Erasing "Options form available"
  GRstatus_display_button(0);

  me->table_info.tbl_nm[0]		= '\0';
  me->table_info.tbl_id.obj_id.objid	= NULL_OBJID;
  me->active_row.obj_id.objid		= NULL_OBJID;

  me->obj_list_tgl	= 0;
  me->nb_Tbl_Info	= 0;
  me->tot_nb_rows	= 0;
  me->an_classid	= OPP_VDitem_class_id;
  me->msgnumb		= VD_M_PlItNm;
  me->loc_key		= VD_P_IdElIt;
  me->global_leader	= TRUE;
  me->locat_all_tgl	= 0;

  if ( VDitem_geom.is_init )
  {
    me->auto_leader		= VDitem_geom.leader_on;
    me->position		= VDitem_geom.position;
    me->auto_offset[0]		= VDitem_geom.offset[0];
    me->auto_offset[1]		= VDitem_geom.offset[1];
    me->auto_offset[2]		= VDitem_geom.offset[2];
    me->mylen1			= VDitem_geom.length1;
    me->mylen2			= VDitem_geom.length2;
    me->angle1			= VDitem_geom.angle1;
    me->angle2			= VDitem_geom.angle2;
  }
  else
  {
    VDitem_geom.is_init		= 1;
    VDitem_geom.offset_on	= FALSE;
    me->auto_leader		= VDitem_geom.leader_on	= FALSE;
    me->position		= VDitem_geom.position	= VD_ANNOT_CENTER_CENTER;
    me->auto_offset[0]		= VDitem_geom.offset[0]	=   0.0;
    me->auto_offset[1]		= VDitem_geom.offset[1]	=   0.0;
    me->auto_offset[2]		= VDitem_geom.offset[2]	=   0.0;
    me->mylen1			= VDitem_geom.length1	=  10.0;
    me->mylen2			= VDitem_geom.length2	=  10.0;
    me->angle1			= VDitem_geom.angle1	=  45.0;
    me->angle2			= VDitem_geom.angle2	=   0.0;
  }

  me->subform_display	= FALSE;

  me->window.objid	= NULL_OBJID;
  me->fixed_table	= FALSE;
  me->nbObjs		= 0;

  status =
  om$send (	msg	 = message COdim.create_form ( 0, "VDPlItem", &me->form ),
		targetid = my_id);
  as$status();
  if ( ! ( status & 1 ) )
  {
    __print_goto ("wrapup");
    goto wrapup;
  }

  status =
  om$send (	msg	 = message COdim.create_form ( 1, "VDPlItemAut", &me->subform ),
		targetid = my_id);
  as$status();
  if ( ! ( status & 1 ) )
  {
    __print_goto ("wrapup");
    goto wrapup;
  }

  if ( VDitem_geom.leader_on == TRUE )
  {
    sprintf ( tmptxt, "%lg", me->mylen1 );
    FIg_set_text ( me->subform, VDLDRL1, tmptxt );

    sprintf ( tmptxt, "%lg", me->mylen2 );
    FIg_set_text ( me->subform, VDLDRL2, tmptxt );

    sprintf ( tmptxt, "%lg", me->angle1 );
    FIg_set_text     ( me->subform, VDLDRA, tmptxt );
    FIg_set_state_on ( me->subform, VDLDRL_OPTION );

    FIg_display  ( me->subform, SBF_LDR_GROUP );
  }
  else
  {
    FIg_set_state_off ( me->subform, VDLDRL_OPTION );
    FIg_erase	      ( me->subform, SBF_LDR_GROUP );
  }

  if ( VDitem_geom.offset_on == TRUE )
  {
    for ( i0=0; i0<3; i0++ )
    {
      me->auto_offset[i0] = VDitem_geom.offset[i0];
    }
    sprintf ( tmptxt, "%lg", me->auto_offset[0] );
    FIg_set_text ( me->subform , VDOFFSETX, tmptxt );

    sprintf ( tmptxt, "%lg", me->auto_offset[1] );
    FIg_set_text ( me->subform , VDOFFSETY, tmptxt );

    sprintf ( tmptxt, "%lg", me->auto_offset[2] );
    FIg_set_text     ( me->subform, VDOFFSETZ, tmptxt );
    FIg_set_state_on ( me->subform, VDOFFSET_OPTION );

    FIg_display  ( me->subform , SBF_POS_GROUP );
  }
  else
  {
    FIg_set_state_off ( me->subform, VDOFFSET_OPTION );
    FIg_erase	      ( me->subform, SBF_POS_GROUP );
  }
  __printf ( ">>>>> VDPlItem_xys_memo = [%d,%d,%d]", `VDPlItem_x_memo, VDPlItem_y_memo, VDPlItem_s_memo` );

  if ( VDPlItem_x_memo != 0 && VDPlItem_y_memo != 0 /* && VDPlItem_s_memo != 0 */ )
  {
    FIf_set_location ( me->form, VDPlItem_x_memo, VDPlItem_y_memo );
    FIf_set_screen   ( me->form, VDPlItem_s_memo );
  }

  FIg_set_state ( me->subform, (int)VDitem_geom.position + VDBOTTOM_LEFT, TRUE );

  FIg_erase	      ( me->form, VD_STCK_GRP );
  FIg_erase	      ( me->form, VD_STAC_GRP );
  FIg_erase	      ( me->form, VD_TEXT_GRP );

  if ( count && BOM_cnt )
  {
    status =
    om$send (	msg	 = message VDCmdAnnot.display_form(),
		targetid = my_id);
    as$status();
  }

 /*
  * Get the item manager id (creates it if it does not yet exist)
  */

  status = ex$get_super (	mod_id		= me->md_env.md_id.objid,
				mod_osnum	= me->md_env.md_id.osnum,
				super_name	= "ItemMgr",
				create		= 1,
				super_class	= "VDitemMgr",
				super_id	= &me->MgrId.objid,
				super_osnum	= &me->MgrId.osnum );
  as$status();

wrapup:

  /* free memory */

  _FREE ( IdName );

  __exitMethod ( name = "init_type" );

  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method wakeup ( int pos )
{
  IGRchar		*dirname	= { "drw_tables" },
			*superClassName = { "VDdrwTbl" },
			 TableType[VD_DRWLO_CHR_IDFLD],
			 tablename[80];
  IGRlong		 msg;
  long			 status = OM_S_SUCCESS;
  IGRint		 sts, count = 0, ref_file = 1;
  int			*BOM_flg = NULL, gadget, i0, txtlng = 0, old_sz,
			 BOM_cnt = 0, indx = 0, label;
  struct VD_id_name	*IdName = NULL;

  __enterMethod ( name = "wakeup" );

  status =
  om$send (	msg	 = message COanplace.wakeup (pos),
		mode	 = OM_e_wrt_message,
		targetid = my_id );
  as$status();if (! (status & 1) ){__print_goto ( "wrapup" );goto wrapup;}

  UI_status ( "" );	// Erasing "Options form available"
  GRstatus_display_button(0);
  /*
   * fill list yzhu 5/17/95
   *
   * Get table name from :designfile:usr:drw_tables
   */

  status =
  VD_get_tableName ( &msg, dirname, superClassName, &count, ref_file, &IdName);

  if ( count ) BOM_flg = _CALLOC ( count, int );

  for( i0=0 ; i0 < count ; i0++ )
  {
    if ( DMancestry_valid( IdName[i0].tbl_id, OPP_VDdrwTbl_class_id ) == OM_S_SUCCESS )
    {
      TableType[0] = '\0';
      status =
      om$send (	msg	 = message VDdrwTbl.VDgetTableType ( &msg, TableType ),
		targetid = IdName[i0].tbl_id.objid,
		targetos = IdName[i0].tbl_id.osnum );

      if ( strcmp ( "BOM", TableType ) == 0 )
      {
	BOM_flg[i0] = 1;
	BOM_cnt++;
      }

      __printf ( "status = %d, BOM_flg[%d] = %d, BOM_cnt = %d, IdName[%d] = [%d,%d], IdName[].tbl_name = <%s>, TableType = <%s>",
	`status, i0, BOM_flg[i0], BOM_cnt, i0, IdName[i0].tbl_id.osnum, IdName[i0].tbl_id.objid, IdName[i0].tbl_name, TableType` );
    }
  }

  if ( ! count || ! BOM_cnt )
  {
    IGRint	  resp;

    resp = TERMINATE;
    ex$putque ( msg      = &msg,
		response = &resp );

    me->auto_check_frm = 1;

    status = OM_W_ABORT;
    __print_goto ("wrapup");
    goto wrapup;
  }

  /*
   * Allocate Buffer to store Pre_Loaded rows from Query
   */

  FIg_enable  ( me->form, FI_MSG_FIELD );
  FIg_display ( me->form, FI_MSG_FIELD );
  FIg_set_text( me->form, FI_MSG_FIELD, "" );

  old_sz = om$dimension_of ( varray = me->Tbl_Info ) / sizeof (struct VDTblId_Name);

  if ( BOM_cnt && BOM_cnt != old_sz )
  {
    sts = om$vla_set_dimension ( varray	= me->Tbl_Info,
				 size	= BOM_cnt * sizeof (struct VDTblId_Name) );
    as$status(sts = sts);
    if ( sts != OM_S_SUCCESS )
    {
      FIg_set_text ( me->form, FI_MSG_FIELD,
		  "No Dynamic Memory Available" );
      UI_status ( "No Dynamic Memory Available" );

      __print_goto ("wrapup");
      goto wrapup;
    }
  }

  me->nb_Tbl_Info = BOM_cnt;

  /*
   * reset field list to null
   */
  gadget = GAD_TABLE;

  FIfld_set_list_num_rows( me->form, gadget, 0, BOM_cnt );

  /*
   * display the table name in the form.
   */

  for( i0=0 ; i0< count ; i0++ )
  {
    tablename[0] = '\0';
    if ( BOM_flg[i0] == 0 ) continue;

    strcat( tablename, IdName[i0].tbl_name);
    strcat( tablename, "[");
    strcat( tablename, IdName[i0].deg_file.fname);
    strcat( tablename, "]");

    strcpy( me->Tbl_Info[indx].tbl_nm, tablename );
    strcpy( me->Tbl_Info[indx].pth_nm, IdName[i0].deg_file.pname );
	    me->Tbl_Info[indx].tbl_id.obj_id = IdName[i0].tbl_id;

    VDfld_set_list_text ( me->form, gadget, indx, 0, tablename, FALSE);

    if ( 0 == indx )
    {
      sts = FIfld_get_text_length ( me->form, gadget, 0, 0, &txtlng);
      if ( 0 == txtlng )
      {
	FIfld_set_text ( me->form, gadget, 0, 0, tablename, FALSE);

	me->table_info = me->Tbl_Info[indx];
        gr$display_object (	object_id = &me->table_info.tbl_id.obj_id,
				mode      = GRhd);
      }
    }

    __printf ( "me->Tbl_Info[indx].tbl_id[%d] = [%d,%d] \n\tme->Tbl_Info[indx].tbl_nm = <%s> \n\tme->Tbl_Info[indx].pth_nm = <%s>",
	`indx, me->Tbl_Info[indx].tbl_id.obj_id.osnum, me->Tbl_Info[indx].tbl_id.obj_id.objid,
	     me->Tbl_Info[indx].tbl_nm, me->Tbl_Info[indx].pth_nm` );
    indx++;
  }

  __printf ( "me->table_info.tbl_id.obj_id = [%d,%d] \n\tme->table_info.tbl_nm = <%s>",
	`me->table_info.tbl_id.obj_id.osnum, me->table_info.tbl_id.obj_id.objid, me->table_info.tbl_nm` );

  /*
   * When table changes update instance data containing RowIds for that Table
   */
  VDdisplay_erase_hilite ( &msg, me->tot_nb_rows, GRhe, me->row_id );

  sts = om$send (msg	 = message VDCmditem.VDGetRowIdsForTbl ( &msg ),
		targetid = my_id );
  as$status( sts = sts );

  __printf ( "me->form_display = %d, me->subform_display = %d", `me->form_display, me->subform_display` );

  if ( me->subform_display )
  {
    label = (int)me->position + VDBOTTOM_LEFT ;

    FIg_set_state ( me->form, label, TRUE );
    FIf_display   ( me->subform );
    FIf_display   ( me->form );
  }

  /* free memory */

  _FREE ( IdName );
  _FREE ( BOM_flg );

  __exitMethod ( name = "wakeup" );
  return OM_S_SUCCESS;

wrapup:

  /* free memory */

  _FREE ( IdName );
  _FREE ( BOM_flg );

  __exit_error_Method ( name = "wakeup" );
  return (status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method LC_selection(IGRint *msg; struct GRlc_info *lc_info)
{
  IGRint		 status = OM_S_SUCCESS, sts,
			 i0 = 0, count = 0, Valid_Ancestor;
  IGRlong		 rc;
  struct GRobj_env	*obj;

  __enterMethod ( name = "LC_selection" );

  *msg   = OM_S_SUCCESS;
  status = OM_S_SUCCESS;

  if( me->state == WAIT_MAC )
  {
    count = 0;
    as$start_fence(	set		= &lc_info->located_obj,
			nb_obj		= &count,
			p_obj_env	= &obj,
			response	= NULL,
			response_data	= NULL );

    for( i0=0; i0 < count; i0++ )
    {
      __printf ( "as$start_fence(): obj[%d].obj_id = [%d,%d]", `i0, obj[i0].obj_id.osnum , obj[i0].obj_id.objid` );
    }

    ASend_fence();

    me->obj_not_in_table = FALSE;

    /*
     * Check if located object is in a Drawing View
     * If this is true, then replace it with the originating Model object
     */
    {
      VDpartAttr	attr;

      attr.Iwant	= VD_I_drwParentObj;

      for( i0=0; i0 < count; i0++ )
      {
	if( DMancestry_valid( obj[i0].obj_id, OPP_VDdrw2d_class_id ) == OM_S_SUCCESS )
	{
	  status =
	  om$send (	msg	 = message GRvg.GRgetattr( &rc, (char *)&attr ),
			targetid = obj[i0].obj_id.objid,
			targetos = obj[i0].obj_id.osnum );
	  if ( status & rc & 1 )
	  {
              if( DMancestry_valid( attr.obj.obj_id,
                                    OPP_VDdrw3d_class_id ) == OM_S_SUCCESS )
              {
                VDpartAttr       attr1;
                struct GRid      ownId = NULL_GRID;
                struct GRid      modObj;
                struct GRmd_env  modEnv;

                attr1.Iwant     = VD_I_drwParentObj;
                status =
                om$send(msg = message GRvg.GRgetattr( &rc, (char *)&attr1 ),
                        targetid = attr.obj.obj_id.objid,
                        targetos = attr.obj.obj_id.osnum );
                if( status & rc & 1 )
                {
                   ASget_as_owner( &attr1.obj.obj_id, &ownId );
                   if(  ownId.objid != NULL_OBJID )
                   {
                     status =
                     om$send( msg = message NDmacro.ACreturn_foot(
                                            &rc,
                                            "",
                                            &modObj,
                                            &modEnv.md_env.matrix_type,
                                            modEnv.md_env.matrix),
                              targetid = ownId.objid,
                              targetos = ownId.osnum );

                     if( status & rc & 1 )
                     {
                       modEnv._MD_OS = modObj.osnum;
                       status = ex$get_modid( mod_osnum = modEnv._MD_OS,
                                              mod_id    = &modEnv._MD_ID );
                       if( status )
                       {
                         attr1.obj.mod_env  = modEnv;
                         attr1.obj.obj_id   = modObj;
                       }
                     }
                   }

                   attr = attr1 ;
                }
              }
	    obj[i0] = attr.obj;
	  }
	}
      }
    }

    i0 = 0;
    me->save_located = obj[i0];

    Valid_Ancestor =	DMancestry_valid ( obj[i0].obj_id, OPP_ACncpx_class_id  ) ||
			DMancestry_valid ( obj[i0].obj_id, OPP_GRclhdr_class_id ) ||
			DMancestry_valid ( obj[i0].obj_id, OPP_GRsmhdr_class_id );

    if ( ! me->obj_list_tgl )
    {
      if( Valid_Ancestor & OM_S_SUCCESS )
      {
	sts = om$send (	msg	 = message VDCmditem.update_table_info_field ( &rc, obj[i0].obj_id ),
			targetid = my_id );
      }
      else
      {
	FIg_set_text ( me->form, FI_MSG_FIELD, "Incorrect Element Selected" );

	me->obj_not_in_table = TRUE;
      }
    }
    else
    {
      if( DMancestry_valid(obj[i0].obj_id, OPP_VDitem_class_id) 
          == OM_S_SUCCESS )
      {
	__printf ( "LIST mode(goto wrapup): me->obj_list_tgl =%d", me->obj_list_tgl );
	goto wrapup;
      }
      else if( Valid_Ancestor & OM_S_SUCCESS )
      {
        sts = om$send( msg      = message VDCmditem.update_table_info_field(
                                                    &rc, obj[i0].obj_id),
                       targetid = my_id );
      }
      else
      {
	FIg_set_text ( me->form, FI_MSG_FIELD, "Incorrect Element Selected" );

	me->obj_not_in_table = TRUE;
      }
    }

    __printf ( "me->state == WAIT_MAC = %d, me->action = %d, me->input_required = %d",
	`me->state, me->action, me->input_required` );
  }
  else
  {
    __printf ( "me->state != WAIT_MAC = %d, me->action = %d, me->input_required = %d",
	`me->state, me->action, me->input_required` );

    status =
    om$send (	msg	 = message VDCmdAnnot.LC_selection(msg,lc_info),
		targetid = my_id,
		mode	 = OM_e_wrt_message);
    as$status();if (! (status & 1) ){__print_goto ( "wrapup" );goto wrapup;}
  }
wrapup:
  __exitMethod ( name = "LC_selection" );

  return status ;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method place_dimension()
{
  IGRboolean		 item_found;
  IGRint		 status = OM_S_SUCCESS, rc, i, count, mk_src = 1,
			 item_used = 0, item_flag = 0;
  IGRlong		 loc_msg, stat1, msg;
  IGRchar		*ItemNum = NULL, item_string[VD_ITEMNUM_LEN];
  struct GRobj_env	*objs = NULL, row_id, item_id;
  struct GRid		 null_grid, row_src, obj_src, loc_obj[2], ContextId;

  __enterMethod ( name = "place_dimension" );

  null_grid.objid = NULL_OBJID;

  /*
   * call the main place_dimension method first and then connect the
   * macros to the item number.
   */
  status =
  om$send (	msg	 = message COanplace.place_dimension(),
		targetid = my_id,
		mode	 = OM_e_wrt_message);
  as$status();if (! (status & 1) ){__print_goto ( "wrapup" );goto wrapup;}

  if( me->an_grid.objid == NULL_OBJID )
  {
    __print_goto ( "wrapup" );
    status = OM_S_SUCCESS;
    goto wrapup;
  }

  /*
   * connect all macros to the place item
   */
  count = mk_src = 0;
  as$start_fence(	set		= &me->hdr_set.obj_id,
			nb_obj		= &count,
			p_obj_env	= &objs,
			make_source	= mk_src,
			response	= NULL,
			response_data	= NULL );

  __printf ( "me->hdr_set = [%d,%d], me->an_grid = [%d,%d], me->table_info.tbl_id.obj_id = [%d,%d]",
	`me->hdr_set.obj_id.osnum, me->hdr_set.obj_id.objid,
	 me->an_grid.osnum, me->an_grid.objid,
	 me->table_info.tbl_id.obj_id.osnum, me->table_info.tbl_id.obj_id.objid` );

  status = om$send( msg      = message VDitemMgr.VDcleanUp( &msg ),
		    targetid = me->MgrId.objid,
		    targetos = me->MgrId.osnum );

  for( i=0; i < count; i++ )
  {
    loc_msg  =	DMancestry_valid( objs[i].obj_id, OPP_ACncpx_class_id)		||
		DMancestry_valid( objs[i].obj_id, OPP_NDnodein_class_id)	||
		DMancestry_valid( objs[i].obj_id, OPP_GRclhdr_class_id)		||
		DMancestry_valid( objs[i].obj_id, OPP_GRsmhdr_class_id)		||
		DMancestry_valid( objs[i].obj_id, OPP_VDitem_class_id);

    __printf ( ">>>>>>>>>> loc_msg = %d, objs[%d].obj_id = [%d,%d]",
	`loc_msg, i, objs[i].obj_id.osnum, objs[i].obj_id.objid` );

    obj_src = objs[i].obj_id;

    if( ( loc_msg & OM_S_SUCCESS ) )
    {
      status =
      vd$getItemNoForObj (	obj	=  objs[i].obj_id,
				tblName	=  me->table_info.tbl_nm,
				itemId	= &item_id.obj_id,
				itemNo	= &ItemNum,
				found	= &item_found);
      if ( ItemNum )
      {
	__printf ( ">>>>> item_found = %d, item_id.obj_id = [%d,%d], ItemNum = <%s>",
			`item_found, item_id.obj_id.osnum, item_id.obj_id.objid, ItemNum` );
	_FREE ( ItemNum );
      }

      if ( me->active_row.obj_id.objid != NULL_OBJID )
      {
	item_flag = 1;

	row_id = me->active_row;
	FIg_get_text ( me->form, GAD_ROW_LST, item_string );
      }
      else
      {
	item_flag = 0;

	row_id.obj_id.objid = NULL_OBJID;
	item_string[0] = '\0';
      }

      __printf ( ">>>>> me->active_row = [%d,%d], row_id.obj_id = [%d,%d], item_string = <%s>",
		  `me->active_row.obj_id.osnum, me->active_row.obj_id.objid,
		   row_id.obj_id.osnum, row_id.obj_id.objid, item_string` );

      if( ! item_flag )
      {
	if ( item_found )
	{
	  FIg_set_text ( me->form, FI_MSG_FIELD,
			 "Object Already Connected to Item");
	  UI_status    ( "Object Already Connected to Item");

	  VDdisplay_erase_hilite ( &msg, 1, GRbdhd, &objs[i] );
	  VDdisplay_erase_hilite ( &msg, 1, GRbdhd, &item_id );
	}
	else
	{
	  FIg_set_text ( me->form, FI_MSG_FIELD,
			 "Hilited Object is not in this Table");
	  UI_status    ( "Hilited Object is not in this Table");

	  VDdisplay_erase_hilite ( &msg, 1, GRbdhd, &objs[i] );
	}

	item_used = 0;
      }
      else
      {
	VDdisplay_erase_hilite ( &msg, 1, GRbdhd, &row_id );

	/*
	 * find context(s) and make sources
	 */
//////////// TR # 179601220
	if ( mk_src == 0 )
	{
	  status =
	  om$send (	msg	 = message NDmacro.ACreturn_foot(
						&msg,
						 "",
						&objs[i].obj_id,
						&objs[i].mod_env.md_env.matrix_type,
						 objs[i].mod_env.md_env.matrix ),
			targetid = objs[i].obj_id.objid,
			targetos = objs[i].obj_id.osnum );
	  as$status();

	  __printf ( "status = %d, msg = %d, objs[i].obj_id = [%d,%d], me->md_env.md_id = [%d,%d]",
		`status, msg, objs[i].obj_id.osnum, objs[i].obj_id.objid,
		 me->md_env.md_id.osnum, me->md_env.md_id.objid` );

	  /* get the context object for as$make_source */

	  if ( objs[i].obj_id.osnum == me->md_env.md_id.osnum )
	  {
	    ContextId = NULL_GRID;
	  }
	  else
	  {
	    status = GRfindcontext ( &msg,
				      NULL,	// &objs[i].mod_env.md_env.matrix_type,
				      NULL,	//  objs[i].mod_env.md_env.matrix,
				     &objs[i].obj_id.osnum,
				     &ContextId );

	    if ( ! ( status & 1 & msg ) )
	    {
	      __prints ( "ContextId not found" );
	      ContextId = NULL_GRID;
	    }
	  }

	  __printf ( "status = %d, msg = %d, ContextId = [%d,%d]", `status, msg, ContextId.osnum, ContextId.objid` );

	  as$make_source (	go_grid		= objs[i].obj_id,
				context_grid	= ContextId,
//				as_os		= me->md_env.md_id.osnum,
				as_os		= objs[i].obj_id.osnum,
				as_grid		= &obj_src );

	  __printf ( ">>>>> objs[%d].obj_id = [%d,%d], obj_src = [%d,%d], as_os = %d",
		`i,objs[i].obj_id.osnum, objs[i].obj_id.objid, obj_src.osnum, obj_src.objid, me->md_env.md_id.osnum` );
	}
////////////
	status =
	om$send (	msg	 = message NDmacro.ACreturn_foot(
						&msg,
						 "",
						&row_id.obj_id,
						&row_id.mod_env.md_env.matrix_type,
						 row_id.mod_env.md_env.matrix ),
			targetid = row_id.obj_id.objid,
			targetos = row_id.obj_id.osnum );
	as$status();

	__printf ( "status = %d, msg = %d, row_id.obj_id = [%d,%d]", `status, msg, row_id.obj_id.osnum, row_id.obj_id.objid` );

	status = GRfindcontext( &msg,
				&row_id.mod_env.md_env.matrix_type,
				 row_id.mod_env.md_env.matrix,
				&row_id.obj_id.osnum,
				&ContextId );
	if( !(status&msg&1) ) ContextId.objid = NULL_OBJID ;

	__printf ( "status = %d, msg = %d, ContextId = [%d,%d]", `status, msg, ContextId.osnum, ContextId.objid` );

	as$make_source (go_grid		= row_id.obj_id,
			context_grid	= ContextId,
			as_os		= me->md_env.md_id.osnum,
			as_grid		= &row_src );

	__printf ( ">>>>> row_id.obj_id = [%d,%d], row_src = [%d,%d]",
		`row_id.obj_id.osnum, row_id.obj_id.objid, row_src.osnum, row_src.objid` );

	if( ! me->obj_list_tgl )
	{
	  loc_obj[0] = obj_src;		// objs[i].obj_id;
	  loc_obj[1] = row_src;
	  item_used  = 2;
	}
	else
	{
	  loc_obj[0] = row_src;
	  item_used  = 1;
	}

	status =
	om$send(msg	 = message NDnode.NDconnect (	item_used,
							loc_obj,
							null_grid,
							ND_NEW),
		targetid = me->an_grid.objid,
		targetos = me->an_grid.osnum);
	as$status();if (! (status & 1) ){__print_goto ( "wrapup" );goto wrapup;}
      }
    }
  }

  ASend_fence();

  /*
   * put the item number as the dimensional text
   */

  if( item_used )
  {
    status =
    om$send (	msg	 = message DMroot.replace_text(
						&rc,
						 DIM_TEXT,
						 (struct GRid *) NULL,
						&me->dyn_env,
						strlen(item_string),
						(IGRuchar *)item_string),
		targetid = me->an_grid.objid,
		targetos = me->an_grid.osnum);
    status =
    om$send (	msg	 = message VDitem.VDputItemInfo(
						&stat1,
						 item_string),
		targetid = me->an_grid.objid,
		targetos = me->an_grid.osnum);
    as$status();if (! (status & 1) ){__print_goto ( "wrapup" );goto wrapup;}

    status =
    om$send (	msg	 = message VDitemMgr.VDconnectItmObjs( &msg,
						 me->table_info.tbl_nm,
						 1,
						&me->an_grid ),
		targetid = me->MgrId.objid,
		targetos = me->MgrId.osnum );
    as$status();
  }
  else
  {
    status =
    om$send (	msg	 = message VDCmdAnnot.delete_dimension (),
		targetid = my_id);

    me->an_grid.objid = NULL_OBJID;
  }

wrapup:

  FIg_set_text  ( me->form, FI_MSG_FLD_9, "" );
  FIg_disable   ( me->form, FI_MSG_FLD_9 );
  FIg_erase     ( me->form, FI_MSG_FLD_9 );

  __exitMethod ( name = "place_dimension" );

  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method display_dimension(int ele; int type)
{
IGRint		status = OM_S_SUCCESS;

  status =
  om$send (	msg	 = message VDCmdAnnot.display_dimension(ele,type),
		targetid = my_id,
		mode	 = OM_e_wrt_message);

  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method VDGetRowIdsForTbl ( IGRlong  *msg )
{
  int		 sts, i0, j0, NbTblHdr = 0, startRow = 0, indx = 0, old_sz;
  IGRint	 nbRows = 0;
  struct GRid	*TblHdr = NULL;

  char		 ItemNum[VD_ITEMNUM_LEN];
  IGRshort	 isLinedOut = -1;
  IGRint	 itemsz = 0;

  __enterMethod ( name = "VDGetRowIdsForTbl" );

  *msg = MSSUCC;

  if ( me->nb_Tbl_Info == 0 || me->table_info.tbl_id.obj_id.objid == NULL_OBJID )
  {
    *msg = MSFAIL;
    goto wrapup;
  }

  sts =
  om$send (	msg	 = message VDdrwTbl.VDgetTotalNbOfRows (msg, &nbRows),
		targetid = me->table_info.tbl_id.obj_id.objid,
		targetos = me->table_info.tbl_id.obj_id.osnum,
		senderid = my_id );
  if ( ! (sts & *msg & 1) )
  {
    *msg = MSFAIL;
    goto wrapup;
  }

  if ( nbRows )
  {
    me->tot_nb_rows = nbRows;
    old_sz = om$dimension_of ( varray = me->row_id ) / sizeof (struct GRobj_env);

    if ( nbRows != old_sz )
    {
      sts = om$vla_set_dimension ( varray	= me->row_id,
				   size		= nbRows * sizeof (struct GRobj_env) );
      if ( sts != OM_S_SUCCESS )
      {
	*msg = MSFAIL;

	FIg_set_text ( me->form, FI_MSG_FIELD,
		    "No Dynamic Memory Available" );
	UI_status ( "No Dynamic Memory Available" );

	__print_goto ("wrapup");
	goto wrapup;
      }
    }

    sts = VDGetGridsFromChan_of_Class ( msg, me->table_info.tbl_id.obj_id, &AS_to_comp,
					OPP_VDdrwTblHdr_class_id, &NbTblHdr, &TblHdr );

    for ( i0=0; i0 < NbTblHdr; i0++ )
    {
      sts = om$send (	msg	 = message VDdrwTblHdr.VDgetRowInfo (msg, &nbRows, &startRow),
			targetid = TblHdr[i0].objid,
			targetos = TblHdr[i0].osnum,
			senderid = my_id );
      if ( ! (sts & *msg & 1) )
      {
	*msg = MSFAIL;
	goto wrapup;
      }

      for ( j0 = startRow; j0 < nbRows + startRow; j0++ )
      {
	struct GRid	tmp_id;
	sts = om$send (	msg	 = message VDdrwTblHdr.VDrowNoToGRid (msg, j0, &tmp_id),
			targetid = TblHdr[i0].objid,
			targetos = TblHdr[i0].osnum,
			senderid = my_id );
	if ( ! (sts & *msg & 1) )
	{
	  *msg = MSFAIL;
	  goto wrapup;
	}
	me->row_id[indx].obj_id = tmp_id;

	__printf ( ">>me->tot_nb_rows = %d, me->row_id[%d].obj_id = [%d,%d]",
		`me->tot_nb_rows, indx,me->row_id[indx].obj_id.osnum, me->row_id[indx].obj_id.objid` );

	/*
	 * Get mod_env and make sources
	 */
	sts =
	om$send(msg	 = message NDmacro.ACreturn_foot(
						 msg,
						 "",
						&me->row_id[indx].obj_id,
						&me->row_id[indx].mod_env.md_env.matrix_type,
						 me->row_id[indx].mod_env.md_env.matrix ),
		targetid = me->row_id[indx].obj_id.objid,
		targetos = me->row_id[indx].obj_id.osnum );
	as$status(sts = sts);

	ItemNum[0] = '\0';
	isLinedOut = -1;
	itemsz	 = 0;

	sts = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber ( msg, &itemsz, ItemNum ),
			targetid = me->row_id[indx].obj_id.objid,
			targetos = me->row_id[indx].obj_id.osnum );
	if ( sts & *msg & 1 )
	{
	  if ( ItemNum[0] != '\0' )
	  {
	    sts = om$send(msg	 = message VDdrwTblRow.VDisRowLinedOut ( msg, &isLinedOut ),
			targetid = me->row_id[indx].obj_id.objid,
			targetos = me->row_id[indx].obj_id.osnum );
	    if ( sts & *msg & 1 && isLinedOut == 0 )
	    {
//	      VDfld_set_list_text ( me->form, GAD_ROW_LST, indx /* TBD ?? i0 or indx */, 0, ItemNum, FALSE);
	      indx++;
	    }
	  }
	}

	if ( indx > me->tot_nb_rows )
	{
	  printf ("Not enough memory allocated\n" );
	  goto wrapup;
	}
      }
    }

    /*
     * Reset me->tot_nb_rows to indx : the actual number of selectable rows
     */
    me->tot_nb_rows = indx;

    FIfld_set_list_num_rows ( me->form, GAD_ROW_LST, 0, me->tot_nb_rows );

    __printf ( ">>>>> NEW me->tot_nb_rows = %d", `me->tot_nb_rows` );

    /*
     * Sort the ItemNum's ...
     */

    if ( me->tot_nb_rows > 1 )
    {
      qsort ( (char *)me->row_id, me->tot_nb_rows, sizeof ( struct GRobj_env ), (int (*)(const void *, const void *)) comp_ItemNmrs );
    }

    for ( i0=0; i0 < me->tot_nb_rows; i0++ )
    {
      ItemNum[0] = '\0';
      isLinedOut = -1;
      itemsz	 = 0;

      sts = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber ( msg, &itemsz, ItemNum ),
			targetid = me->row_id[i0].obj_id.objid,
			targetos = me->row_id[i0].obj_id.osnum );
      if ( sts & *msg & 1 )
      {
	VDfld_set_list_text ( me->form, GAD_ROW_LST, i0, 0, ItemNum, FALSE);
      }
    }
  }
  else
  {
    me->tot_nb_rows = 0;

    FIfld_set_list_num_rows ( me->form, GAD_ROW_LST, 0, 0 );
    FIg_set_text  ( me->form, FI_MSG_FIELD, "No Item numbers defined for this Table" );
    FIg_set_state ( me->form, GAD_TOGGLE_1, 0 );
    FIg_disable   ( me->form, GAD_ROW_LST );
  }

wrapup:

  _FREE ( TblHdr );

  __exitMethod ( name = "VDGetRowIdsForTbl" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method	update_table_info_field
(
  IGRlong	*msg;
  struct GRid	 ModelId
)
{
  IGRint	  status = OM_S_SUCCESS;
  int		  i0, sts, NbFound = 0, active_tbl = -1, indx = 0;
  struct GRid	 *RowId	  = NULL;
  struct GRid	 *TblId	  = NULL;
  char		**ItemNum = NULL;
  char		**TblNam  = NULL;
  char		**PthNam  = NULL;
  char		  txtbuf  [DI_PATH_MAX];
  int		  NbUnCnctd    = 0;
  int		 *UnCnctdFlag  = NULL;
  int		  old_sz = 0;

  struct VDTblId_Name	 fixed_tbl;

  __enterMethod ( name = "update_table_info_field" );

  FIg_disable ( me->form, FI_MSG_FLD_9 );
  FIg_erase   ( me->form, FI_MSG_FLD_9 );

  *msg   = OM_S_SUCCESS;
  status = OM_S_SUCCESS;
  me->tot_posble_rows = 0;

  fixed_tbl	= me->table_info;

  __printf ( "ModelId = [%d,%d]", `ModelId.osnum , ModelId.objid` );

  sts = VDGetRowIdsItemNums_TblIdsTblNms_FromObjId
		( msg, &NbFound, &NbUnCnctd, &UnCnctdFlag, ModelId, &RowId, &TblId, &ItemNum, &TblNam, &PthNam );

  __printf ( "ModelId[%d,%d] is connected to %d Tables (%d unconnected); sts = %d, *msg = %d",
	`ModelId.osnum, ModelId.objid, NbFound, NbUnCnctd, sts, *msg` );

  for ( i0=0; i0 < NbFound; i0++ )
  {
    __printf (  "RowId[%d] = [%d,%d] TblId = [%d,%d] UnCnctdFlag [%d] ItemNum = <%s>\n\t\t\t\tTblNam = <%s>\n\t\t\t\tPthNam = <%s>",
		`i0, RowId[i0].osnum, RowId[i0].objid, TblId[i0].osnum, TblId[i0].objid,
		 UnCnctdFlag [i0], ItemNum[i0], TblNam[i0], PthNam[i0]` );
  }

  if ( sts != OM_S_SUCCESS )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  me->obj_not_in_table = FALSE;

  if ( NbFound == 0 )
  {
    FIg_set_text ( me->form, GAD_ROW_LST , "");
    FIg_set_text ( me->form, FI_MSG_FIELD,
		   "Selected Object is not in Table");
    UI_status    ( "Selected Object is not in Table");

    me->obj_not_in_table = TRUE;

    __print_goto ( "wrapup" );
    goto wrapup;
  }
  else if ( NbFound > 0 )
  {
    char *s = { ( NbFound > 1 ) ? "s" : "" };

    sprintf ( txtbuf, "Object in %d Table%s; # Items to place %d", NbFound, s, NbUnCnctd );

    me->tot_posble_rows = NbFound;
    old_sz = om$dimension_of ( varray = me->possible_rows ) / sizeof (struct GRobj_env);

    if ( me->tot_posble_rows != old_sz )
    {
      sts = om$vla_set_dimension ( varray	= me->possible_rows,
				   size		= me->tot_posble_rows * sizeof (struct GRobj_env) );
      if ( sts != OM_S_SUCCESS )
      {
	*msg = MSFAIL;

	FIg_set_text ( me->form, FI_MSG_FIELD,
		    "No Dynamic Memory Available" );
	UI_status ( "No Dynamic Memory Available" );

	__print_goto ("wrapup");
	goto wrapup;
      }

      sts = om$vla_set_dimension ( varray	= me->possible_tbls,
				   size		= me->tot_posble_rows * sizeof (struct VDTblId_Name) );
      if ( sts != OM_S_SUCCESS )
      {
	*msg = MSFAIL;

	FIg_set_text ( me->form, FI_MSG_FIELD,
		    "No Dynamic Memory Available" );
	UI_status ( "No Dynamic Memory Available" );

	__print_goto ("wrapup");
	goto wrapup;
      }
    }

    FIfld_set_list_num_rows( me->form, FI_MSG_FLD_9, 0, me->tot_posble_rows );
    FIg_set_text ( me->form, FI_MSG_FIELD, txtbuf );
    UI_status ( txtbuf );

    for ( i0=0; i0 < NbFound; i0++ )
    {
      {
	sprintf ( txtbuf, "%s (%s)", TblNam[i0], ItemNum[i0] );

	VDfld_set_list_text ( me->form, FI_MSG_FLD_9, indx, 0, txtbuf, FALSE);

	me->possible_rows[indx].obj_id = RowId[i0];

	me->possible_tbls[indx].tbl_id.obj_id =  TblId [i0];
	strcpy ( me->possible_tbls[indx].tbl_nm, TblNam[i0] );
	strcpy ( me->possible_tbls[indx].pth_nm, PthNam[i0] );

	VDdisplay_erase_hilite ( msg, 1, GRbdhd, &me->possible_rows[indx] );
	indx++;
      }
    }

    for ( i0=0; i0 < NbFound; i0++ )
    {
      /*
       * compare   me->table_info.tbl_nm   with   me->possible_tbls[].tbl_nm
       */
      if ( strcmp ( me->possible_tbls[i0].tbl_nm, me->table_info.tbl_nm ) == 0
	&& strcmp ( me->possible_tbls[i0].pth_nm, me->table_info.pth_nm ) == 0 )
      {
	active_tbl = i0;
      }
    }
  }

  if ( me->fixed_table == TRUE )
  {
    int	tbl_found = 0;

    for ( i0=0; i0 < NbFound; i0++ )
    {
      if ( TblId[i0].objid != fixed_tbl.tbl_id.obj_id.objid )
      {
	continue;
      }
      else
      {
	tbl_found = 1;
	break;
      }
    }

    if ( tbl_found == 0 )
    {
	__prints ( "\tTABLE FIXED: NO change of table allowed" );

	FIg_set_text ( me->form, FI_MSG_FIELD,
			"TABLE FIXED: NO change table allowed" );
	UI_status (	"TABLE FIXED: NO change table allowed" );

	me->obj_not_in_table = TRUE;

	me->input_required	= NOENT;
	me->state		= INITIAL;
	me->action		= PRT_LD ;

	goto wrapup;
    }
  }

  if ( NbFound > 0 )
  {
    if ( active_tbl == -1 )
    {
      me->table_info = me->possible_tbls[0];
      me->active_row = me->possible_rows[0];

      sts = om$send (	msg	 = message VDCmditem.VDGetRowIdsForTbl ( msg ),
			targetid = my_id );
      as$status( sts = sts );
    }
    else
    {
      me->active_row = me->possible_rows[active_tbl];
    }

    FIg_set_text ( me->form, FI_MSG_FLD_9, me->table_info.tbl_nm );
    FIg_set_text ( me->form, GAD_TABLE   , me->table_info.tbl_nm );
    gr$display_object (	object_id = &me->table_info.tbl_id.obj_id,
			mode      = GRhd);

    for ( i0=0; i0 < NbFound; i0++ )
    {
      if ( me->active_row.obj_id.objid == RowId[i0].objid
	&& me->active_row.obj_id.osnum == RowId[i0].osnum )
      {
	FIg_set_text ( me->form, GAD_ROW_LST , ItemNum[i0] );
	break;
      }
    }

    if ( NbFound > 1 )
    {
      FIg_enable   ( me->form, FI_MSG_FLD_9 );
      FIg_display  ( me->form, FI_MSG_FLD_9 );
    }

    __print_goto ( "wrapup" );
    goto wrapup;
  }

wrapup:

  __printf ( "me->active_row = [%d,%d]", `me->active_row.obj_id.osnum, me->active_row.obj_id.objid` );

  _FREE ( RowId );
  _FREE ( TblId );
  _FREE ( UnCnctdFlag );

  for ( i0=0; i0 < NbFound; i0++ )
  {
    _FREE ( (ItemNum)[i0] );
    _FREE ( (TblNam )[i0]);
    _FREE ( (PthNam )[i0]);
  }

  _FREE ( ItemNum );
  _FREE ( TblNam );
  _FREE ( PthNam );

  __exitMethod ( name = "update_table_info_field" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

method process_bln_form
(
  IGRboolean	display;
  IGRint	label;
  IGRdouble	value;
  Form		form
)
{
  IGRint		status = OM_S_SUCCESS;
  struct DMsenv_param	par_senv;
  char			tbl_name[81];
  IGRint		resp;
  IGRlong		msg;
  int			i, toggl = 0, sts, form_label;
  IGRboolean		item_found = 0;

  IGRint		offset_opt, ldr_opt;
  IGRchar		tmptxt [TEXT_SIZE];
  int                   ii, TotNbDrw2d;
  int 			TotNbObj, TotOldNb;
  struct GRobj_env      *TotDrw2d = NULL;
  char		        msg_text[120];

  __enterMethod ( name = "process_bln_form" );

  FIf_get_label ( form, &form_label );
  FIg_get_state ( me->form, GAD_TOGGLE_1, &toggl );

  if ( ! toggl )
  {
    FIg_disable ( me->form, GAD_ROW_LST );
    FIg_disable	( me->form, VD_STAC_TGL );
    me->obj_list_tgl = 0;
  }
  else
  {
    if ( me->tot_nb_rows )
    {
      FIg_enable    ( me->form, GAD_ROW_LST );
      FIg_enable    ( me->form, VD_STAC_TGL );
      FIg_set_text  ( me->form, FI_MSG_FIELD, "Select ItemNo from List" );
      me->obj_list_tgl = 1;
    }
    else
    {
      FIg_set_text  ( me->form, FI_MSG_FIELD, "No Item numbers defined for this Table" );
      FIg_set_state ( me->form, GAD_TOGGLE_1, 0 );
      FIg_disable   ( me->form, GAD_ROW_LST );
      FIg_disable   ( me->form, VD_STAC_TGL );
    }
  }

  __printf ( "display = %d, form_label = %d, gadget_label = %d", `display, form_label, label` );

  FIg_enable  ( form, FI_MSG_FIELD );
  FIg_display ( form, FI_MSG_FIELD );

  dm$get_dim_param(type = DM_SENV_PARAM, p_data = &par_senv);

  if( display )
  {
    status =
    om$send (	msg	 = message COanplace.process_bln_form
					(display, label, value, form),
		targetid = my_id,
		mode	 = OM_e_wrt_message);
    as$status();if (! (status & 1) ){__exit_error_Method ( name = "process_bln_form" );return status;}

    FIg_enable  ( form, FI_MSG_FIELD );
    FIg_display ( form, FI_MSG_FIELD );

    UI_status ( "" );	// Erasing "Options form available"
  }
  else
  {
    /*
     * Get info from displayed form
     */

    UI_status ( "" );	// Erasing "Options form available"

    switch ( form_label )
    {
     case 0 :		/* MAIN Form : Place Item Balloon	*/
     {
      switch ( label )
      {
	case GAD_TABLE:
	{
	  int	sel_flg = 0;
	  for ( i=0; i < me->nb_Tbl_Info ; i++ )
	  {
	    FIfld_get_list_select ( form, GAD_TABLE, i, 0, &sel_flg );
	    if ( sel_flg ) break;
	  }

	  __printf ( "selected row = %d, sel_flg = %d", `i, sel_flg` );

	  FIg_get_text		( form, GAD_TABLE, tbl_name );
	  FIfld_set_list_select	( form, GAD_TABLE, i, 0, FALSE );

	  if( me->table_info.tbl_id.obj_id.objid != NULL_OBJID )
          {
	     gr$display_object( object_id = &me->table_info.tbl_id.obj_id,
				mode      = GRhe);
          }

	  me->table_info = me->Tbl_Info[i];
	  gr$display_object (	object_id = &me->table_info.tbl_id.obj_id,
				mode      = GRhd);

	   /*
	    * When table changes update instance data containing RowIds for that Table
	    */
	  FIg_set_text ( form, GAD_ROW_LST, "" );

	  VDdisplay_erase_hilite ( &msg, me->tot_nb_rows, GRhe, me->row_id );

	  sts = om$send (	msg	 = message VDCmditem.VDGetRowIdsForTbl ( &msg ),
				targetid = my_id );
	  as$status( sts = sts );

	  __printf ( "me->table_info.tbl_id.obj_id = [%d,%d] \n\tme->table_info.tbl_nm = <%s> \n\tme->table_info.pth_nm = <%s>",
			`me->table_info.tbl_id.obj_id.osnum, me->table_info.tbl_id.obj_id.objid,
			 me->table_info.tbl_nm, me->table_info.pth_nm` );
	  break;
	}
	case GAD_ROW_LST:
	{
	  char			 ItemNum[VD_ITEMNUM_LEN], tmpItNum[VD_ITEMNUM_LEN];
	  int			 i0, sz, old_sz, list_count;

	  FIg_get_text ( form, GAD_ROW_LST, ItemNum );

	  if ( strcmp ( "", ItemNum ) == 0 )
	  {
	    __printf ( "me->active_row = [%d,%d], ItemNum = <%s>",
			`me->active_row.obj_id.osnum, me->active_row.obj_id.objid, ItemNum` );

	    FIg_set_text	( form, FI_MSG_FIELD, "No Item numbers defined for this Table" );
	    FIg_set_state	( form, GAD_TOGGLE_1, 0 );
	    FIg_disable		( form, GAD_ROW_LST );
	    FIg_disable		( form, VD_STAC_TGL );

	    me->obj_list_tgl = 0;

	    break;
	  }

	  VDdisplay_erase_hilite ( &msg, me->tot_nb_rows, GRhe, me->row_id );
	  VDdisplay_erase_hilite ( &msg, me->nbObjs     , GRhe, me->Objs_list );

	  /*
	   * This will only function properly if ItemNum's in a Table are UNIQUE
	   */

	  for ( i0=0; i0 < me->tot_nb_rows; i0++ )
	  {
	    sts = om$send (	msg	 = message VDdrwTblRow.VDgetItemNumber ( &msg, &sz, tmpItNum ),
				senderid = my_id,
				targetid = me->row_id[i0].obj_id.objid,
				targetos = me->row_id[i0].obj_id.osnum );

	    if ( strcmp ( ItemNum, tmpItNum ) == 0 )
	    {
	      me->active_row = me->row_id[i0];
	      break;
	    }
	  }

	  VDdisplay_erase_hilite ( &msg, 1, GRbdhd, &me->active_row );

	  __printf ( "me->active_row = [%d,%d], ItemNum = <%s>, tmpItNum[%d] = <%s>",
			`me->active_row.obj_id.osnum, me->active_row.obj_id.objid, ItemNum, i0, tmpItNum` );

	  /*
	   * Get the graphics parents of `me->active_row' to hilite them ...
	   */

	  status =
	  om$send (	msg	 = message VDdrwTblRow.VDgetParentObjectList ( &msg, &me->nbObjs, NULL ),
			targetid = me->active_row.obj_id.objid,
			targetos = me->active_row.obj_id.osnum );
	  as$status();

	  list_count = me->nbObjs;	// Save "me->nbObjs"

	  old_sz = om$dimension_of ( varray = me->Objs_list ) / sizeof (struct GRobj_env);

	  if ( me->nbObjs != old_sz )
	  {
	    status = om$vla_set_dimension ( varray	= me->Objs_list,
					    size	= me->nbObjs * sizeof (struct GRobj_env) );
	    as$status();
	    if ( status != OM_S_SUCCESS )
	    {
	      break;
	    }
	  }

	  status =
	  om$send (	msg	 = message VDdrwTblRow.VDgetParentObjectList ( &msg, &me->nbObjs, me->Objs_list ),
			targetid = me->active_row.obj_id.objid,
			targetos = me->active_row.obj_id.osnum );
	  as$status();

          TotNbObj = me->nbObjs;
          for( ii = 0 ; ii < me->nbObjs ; ++ii )
          {
            status = VDGetVDdrw2dObject_FrmModelObj( &msg,
                                                     &TotNbDrw2d,
						     me->Objs_list[ii].obj_id,
       						     &TotDrw2d );

            if( TotNbDrw2d > 0 )
            {
              TotOldNb = TotNbObj;
              TotNbObj += TotNbDrw2d;
              status = om$vla_set_dimension( varray    = me->Objs_list, 
                  			     size      = TotNbObj );
              as$status();

              memcpy( &me->Objs_list[TotOldNb],
                      TotDrw2d,
                      sizeof(struct GRobj_env)*TotNbDrw2d );
            }
            _FREE( TotDrw2d );
            TotDrw2d = NULL;
            TotNbDrw2d = 0;
          }
          me->nbObjs = TotNbObj;

	  /*
	   * Now hilite the graphics elements ...
	   */
	  VDdisplay_erase_hilite ( &msg, me->nbObjs, GRbdhd, me->Objs_list );

	  for( i0=0; i0 < list_count; i0++ )
	  {
	    int			 NbPrtnd = 0, NbDrw2d = 0, j0, k0, VDComp_class = TRUE, loc1_msg, loc2_msg;
	    struct GRid		*Prtnd = NULL, *Drw2d = NULL, object;
	    struct GRobj_env	 ObjEnv;
	    GRclassid		 classid;

	    __printf ( ">>>>>>>>>> me->Objs_list[%d] = [%d,%d]",
			`i0, me->Objs_list[i0].obj_id.osnum, me->Objs_list[i0].obj_id.objid` );

	    /*
	     * Special case to handle VRCorrection/VRComponent objects properly
	     * First get the owner of the VRComponent ==>> VRCorrection ...
	     */

	    ObjEnv.obj_id = me->Objs_list[i0].obj_id;

	    VDComp_class = TRUE;
	    status =
	    om$get_classid (	classname = "VRComponent",
				p_classid = &classid );
	    if ( ! ( status & 1 ) ) VDComp_class = FALSE;

	    loc1_msg = ( VDComp_class && DMancestry_valid ( me->Objs_list[i0].obj_id, classid ) );

	    if ( loc1_msg )
	    {
	      int	j;

	      for( j = 0 ; j < OM_K_MAXINT ; j++ )
	      {
		status = om$get_objid_at_index( objid	= me->Objs_list[i0].obj_id.objid,
						osnum	= me->Objs_list[i0].obj_id.osnum,
						index	= j,
						p_chanselect = &AS_to_owner,
						objidaddr    = &object.objid,
						osnumaddr    = &object.osnum);
		if( !(status & 1) )
		{
		  break;
		}

		VDComp_class = TRUE;
		status =
		om$get_classid (	classname = "VRCorrection",
					p_classid = &classid );
		if ( ! ( status & 1 ) ) VDComp_class = FALSE;

		loc2_msg = ( VDComp_class && DMancestry_valid ( object, classid ) );

		__printf ( ">>>>>object[%d] = [%d,%d]", `j, object.osnum, object.objid` );

		if ( loc2_msg )
		{
		  ObjEnv.obj_id = object;	// We found the VRCorrection
		  break;
		}
	      }
	    }

	    /*
	     * Get the ACpretendin's / ASsourcein's on the notification channel
	     * Both are subclassed from NDnodein
	     */

	    status = VDGetGridsFromChan_of_Class ( &msg, ObjEnv.obj_id, &AS_notification,
						   -OPP_NDnodein_class_id /*OPP_ACpretendin_class_id*/,
						   &NbPrtnd, &Prtnd );

	    for ( j0 = 0; j0 < NbPrtnd; j0++)
	    {

	      /*
	       * Get the VDdrw2d's on the children channel
	       */

	      status = VDGetGridsFromChan_of_Class ( &msg, Prtnd[j0], &ND_children,
						     OPP_VDdrw2d_class_id, &NbDrw2d, &Drw2d );

	      for ( k0 = 0; k0 < NbDrw2d; k0++)
	      {
		ObjEnv.obj_id = Drw2d[k0];

		me->nbObjs++;

		old_sz = om$dimension_of ( varray = me->Objs_list ) / sizeof (struct GRobj_env);

		if ( me->nbObjs != old_sz )
		{
		  status = om$vla_set_dimension ( varray = me->Objs_list,
						    size = me->nbObjs * sizeof (struct GRobj_env) );
		  as$status();
		  if ( status != OM_S_SUCCESS )
		  {
		    break;
		  }
		}

		/*
		 * Save all VDdrw2d's in me->Objs_list
		 */

		me->Objs_list [me->nbObjs - 1].obj_id = Drw2d[k0];
	      }

	      _FREE ( Drw2d );
	    }

	    _FREE ( Prtnd );
	  }

	  VDdisplay_erase_hilite ( &msg, me->nbObjs, GRbdhd, me->Objs_list );

	  break;
	}
	case GAD_TOGGLE_1:
	{
	  FIg_get_state ( form, GAD_TOGGLE_1, &toggl );
	  FIg_set_text  ( form, GAD_ROW_LST, "" );

	  VDdisplay_erase_hilite ( &msg, me->tot_nb_rows, GRhe, me->row_id );
	  VDdisplay_erase_hilite ( &msg, me->nbObjs     , GRhe, me->Objs_list );

	  if ( ! toggl )
	  {
	    FIg_disable ( form, GAD_ROW_LST );
	    FIg_disable	( form, VD_STAC_TGL );
	    FIg_disable	( form, VD_STAC_DST );
	    me->obj_list_tgl = 0;
	  }
	  else
	  {
	    if ( me->tot_nb_rows )
	    {
	      FIg_set_text	( form, FI_MSG_FIELD, "Select ItemNo from List" );
	      FIg_enable	( form, GAD_ROW_LST );
	      FIg_enable	( form, VD_STAC_TGL );
	      FIg_enable	( form, VD_STAC_DST );
	      me->obj_list_tgl  = 1;
	    }
	    else
	    {
	      FIg_set_text	( form, FI_MSG_FIELD, "No Item numbers defined for this Table" );
	      FIg_set_state	( form, GAD_TOGGLE_1, 0 );
	      FIg_disable	( form, GAD_ROW_LST );
	      FIg_disable	( form, VD_STAC_TGL );
	      FIg_disable	( form, VD_STAC_DST );
	      me->obj_list_tgl  = 0;
	    }

//	    FIg_set_state_on ( form, GAD_TOGGLE_3 );	// Default no leaderline in LIST mode
//	    me->global_leader = FALSE;
	  }

	  break;
	}
	case GAD_TOGGLE_2:
	{
	  int xpos, ypos, xsz, ysz;

	  FIg_get_state ( form, GAD_TOGGLE_2, &toggl );
	  if ( ! toggl )
	  {
	    me->locat_all_tgl   = 0;
	    me->subform_display = FALSE;
	    FIg_enable ( form, GAD_TOGGLE_3 );
	    FIg_enable ( form, GAD_TOGGLE_3 - 1 );
	    FIf_erase  ( me->subform );
	  }
	  else
	  {
	    FIf_get_location ( form, &xpos, &ypos );
	    FIf_get_size     ( form, &xsz , &ysz );
	    FIf_set_location ( me->subform, xpos, ypos + ysz );

	    FIg_disable ( form, GAD_TOGGLE_3 );
	    FIg_disable ( form, GAD_TOGGLE_3 - 1 );
	    FIf_display ( me->subform );
//	    FIg_disable ( me->subform, FI_FORM_GROUP );
//	    FIg_disable ( form, GAD_GROUP );

	    me->locat_all_tgl   = 1;
	    me->subform_display = 1;
	  }

	  break;
	}
	case GAD_TOGGLE_3:
	{
	  FIg_get_state ( form, GAD_TOGGLE_3, &toggl );
	  if ( ! toggl )
	  {
	    me->global_leader = TRUE;
	  }
	  else
	  {
	    me->global_leader = FALSE;
	  }
	  __printf ( "me->global_leader = %d", `me->global_leader` );

	  break;
	}
	case DIM_ENV_FORM  + 100 :
	case MOD_DIM_ANNOT + 100 :
	case FRM_TXT_LDRL  + 100 :
	{
	  break;
	}
	case VD_FIXED_TBL:
	{
	  FIg_get_state ( form, VD_FIXED_TBL, &toggl );
	  if ( toggl == 0 )
	  {
	    me->fixed_table = FALSE;
	  }
	  else
	  {
	    me->fixed_table = TRUE;
	  }
	  break;
	}
	case FI_MSG_FLD_9:
	{
	  char		*cptr, ItemNum[VD_ITEMNUM_LEN];
	  int		 tbl_fnd = -1, i0, j0;

	  /*
	   * Decompose string in (FI_MSG_FLD_9) into <tbl_name> & <ItemNum>
	   */
	  FIg_get_text  ( form, FI_MSG_FLD_9, tbl_name );
	  cptr = strchr ( tbl_name, ' ' );		// Find blank ' '

	  strcpy ( ItemNum, (cptr+2) );			// Skipping ' ('
	  ItemNum [ strlen (ItemNum)-1 ] = '\0';	// Removing last ')'

	  *cptr = '\0';
	  __printf ( "tbl_name = <%s>, ItemNum = <%s>", `tbl_name, ItemNum` );

	  {
	    for ( i=0; i < me->nb_Tbl_Info ; i++ )
	    {
	      if ( strcmp ( tbl_name, me->Tbl_Info[i].tbl_nm ) == 0 )
	      {
		tbl_fnd = i;
		break;
	      }
	    }
	    if ( tbl_fnd >= 0 )
	    {
	      me->table_info = me->Tbl_Info[tbl_fnd];

	      FIg_set_text ( form, GAD_TABLE  , me->table_info.tbl_nm );
	      FIg_set_text ( form, GAD_ROW_LST, ItemNum );

	      VDdisplay_erase_hilite ( &msg, me->tot_nb_rows    , GRhe, me->row_id );
	      VDdisplay_erase_hilite ( &msg, me->tot_posble_rows, GRhe, me->possible_rows );

	      sts = om$send (	msg	 = message VDCmditem.VDGetRowIdsForTbl ( &msg ),
				targetid = my_id );
	      as$status( sts = sts );

	      for ( i0=0; i0 < me->tot_nb_rows; i0++ )
	      {
		for ( j0=0; j0 < me->tot_posble_rows; j0++ )
		{
		  if (  me->row_id[i0].obj_id.objid == me->possible_rows[j0].obj_id.objid
		     && me->row_id[i0].obj_id.osnum == me->possible_rows[j0].obj_id.osnum )
		  {
		    me->active_row = me->row_id[i0];

		    VDdisplay_erase_hilite ( &msg, 1, GRbdhd, &me->active_row );

		    goto found_row;
		  }
		}
	      }
found_row:

	      __printf ( "me->active_row = [%d,%d], me->row_id[%d] = [%d,%d]",
			`me->active_row.obj_id.osnum, me->active_row.obj_id.objid, i0,
			 me->row_id[i0].obj_id.osnum, me->row_id[i0].obj_id.objid` );
	    }
	    else
	    {
	      FIg_set_text ( form, FI_MSG_FIELD, "ERROR: No Matching Table Found ??" );
	    }
	  }

	  break;
	}
// 01/10/96 HF : New gadgets & functionality ( $VDS/vdinclude/dimanform.h )
	case GAD_BL_SPLIT_CIRCLE	:
	case GAD_BL_SPLIT_TRIANGLE	:
	case GAD_BL_SPLIT_SQUARE	:
	case GAD_BL_SPLIT_POLYGON	:
	case GAD_BL_SPLIT_ELLIPSE	:
	case GAD_BL_SPLIT_INV_TRIANGLE	:
	case GAD_BL_SPLIT_RECTANGLE	:
	case GAD_BL_TWO_LINES_TEXT	:
	{
//	  FIg_display ( form, VD_TEXT_GRP );
	  /*
	   * DO NOT DISPLAY TOP/BOTTOM TOGGLE !!!
	   *
	   * TBD : Make sure that <Item Nr> is on TOP line ALWAYS
	   */

          /*
          ** Store the msg.
          */
          FIg_get_text( form, FI_MSG_FIELD, msg_text );

	  /*
	   * Regular processing for the place text with balloon form
	   */
	  status =
	  om$send (	msg	 = message COanplace.process_bln_form
						(display, label, value, form),
			targetid = my_id,
			mode	 = OM_e_wrt_message);
         
          /*
          ** Redisplay the msg.
          */
          FIg_set_text( form, FI_MSG_FIELD, msg_text );
          FIg_display( form, FI_MSG_FIELD );

	  break;
	}
	case GAD_BL_CIRCLE		:
	case GAD_BL_TRIANGLE		:
	case GAD_BL_SQUARE		:
	case GAD_BL_POLYGON		:
	case GAD_BL_ELLIPSE		:
	case GAD_BL_INV_TRIANGLE	:
	case GAD_BL_RECTANGLE		:
	case GAD_BL_ONE_LINE_TEXT	:
	{
	  FIg_erase ( form, VD_TEXT_GRP );

          /*
          ** Store the msg.
          */
          FIg_get_text( form, FI_MSG_FIELD, msg_text );

	  /*
	   * Regular processing for the place text with balloon form
	   */
	  status =
	  om$send (	msg	 = message COanplace.process_bln_form
						(display, label, value, form),
			targetid = my_id,
			mode	 = OM_e_wrt_message);
          /*
          ** Redisplay the msg.
          */
          FIg_set_text( form, FI_MSG_FIELD, msg_text );
          FIg_display( form, FI_MSG_FIELD );

	  break;
	}
	case VD_TEXT_TGL :
	{
	  FIg_get_state  ( form, VD_TEXT_TGL, &toggl );
	  if ( toggl )
	  {
	    FIg_set_text ( form, FI_MSG_FIELD, "Not yet implemented" );
	  }
	  else
	  {
	    FIg_set_text ( form, FI_MSG_FIELD, "" );
	  }

	  break;
	}
	case VD_STAC_TGL:
	{
	  FIg_get_state ( form, VD_STAC_TGL, &toggl );
	  if ( toggl )
	  {
//	    FIg_display  ( form, VD_STAC_GRP );
	  /*
	   * DO NOT DISPLAY STACKING FREE/FIXED TOGGLE !!!
	   */
	    FIg_set_text ( form, FI_MSG_FIELD, "Not yet implemented" );
	  }
	  else
	  {
	    FIg_erase    ( form, VD_STAC_GRP );
	    FIg_set_text ( form, FI_MSG_FIELD, "" );
	  }
	  break;
	}
	case VD_STAC_DST:
	{
	  FIg_set_text ( form, FI_MSG_FIELD, "Not yet implemented" );
	  /*
	   * Regular processing for the place text with balloon form
	   */
	  status =
	  om$send (	msg	 = message COanplace.process_bln_form
						(display, label, value, form),
			targetid = my_id,
			mode	 = OM_e_wrt_message);
	  break;
	}
	case FI_CANCEL:
	{
	  if ( me->subform_display )
	  {
	    status = FIf_erase ( me->subform );
	    me->subform_display = FALSE;
	  }
	  status = FIf_erase ( form );
	  if(status != FI_SUCCESS)
	  {
	    __exit_error_Method ( name = "process_bln_form" );
	    return(OM_E_ABORT);
	  }

	  me->form_display = FALSE;

	  resp = TERMINATE;
	  ex$putque( msg = &msg, response = &resp );
	  break;
	}
	case FI_ACCEPT:
	{
	  if ( me->subform_display )
	  {
	    status = FIf_erase ( me->subform );
	    me->subform_display = FALSE;
	  }
	  if( me->table_info.tbl_nm[0] == '\0' )
	  {
	    FIg_set_text ( form, FI_MSG_FIELD, "Enter Table Name" );
	    FIg_display  ( form, FI_MSG_FIELD );
	    break;
	  }
	  GRstatus_display_button(1);

	  /* NOTE : no break for this case */
	}
	default :
	{
          /*
          ** Store the msg.
          */
          FIg_get_text( form, FI_MSG_FIELD, msg_text );

	  /*
	   * Regular processing for the place text with balloon form
	   */
	  status =
	  om$send (	msg	 = message COanplace.process_bln_form
						(display, label, value, form),
			targetid = my_id,
			mode	 = OM_e_wrt_message);

          /*
          ** Redisplay the msg.
          */
          FIg_set_text( form, FI_MSG_FIELD, msg_text );
          FIg_display( form, FI_MSG_FIELD );

         /* tr179602432: in COanplace.process_bln_form, the field 29 is pop up
            when the stack space < input size + 1, this feature is not
            used for VDS
          */

          FIg_erase( form, VD_STAC_DST );

//	11/14/95 HF : Temporarily disabled because of NEW BALLOON FORM
//
//	  as$status();
//	  if (! (status & 1) )
//	  {
//	    __exit_error_Method ( name = "process_bln_form" );
//	    return status;
//	  }
	  break;
	}
      }
      break;
     }
     case 1 :		/* Sub Form : Auto Place Item	*/
     {
      switch ( label )
      {
	case VDBOTTOM_LEFT:	VDitem_geom.position = me->position = VD_ANNOT_LEFT_BASE;	break;
	case VDCENTER_LEFT:	VDitem_geom.position = me->position = VD_ANNOT_LEFT_CENTER;	break;
	case VDTOP_LEFT:	VDitem_geom.position = me->position = VD_ANNOT_LEFT_CAP;	break;
	case VDTOP_CENTER:	VDitem_geom.position = me->position = VD_ANNOT_CENTER_CAP;	break;
	case VDCENTER_CENTER:	VDitem_geom.position = me->position = VD_ANNOT_CENTER_CENTER;	break;
	case VDBOTTOM_CENTER:	VDitem_geom.position = me->position = VD_ANNOT_CENTER_BASE;	break;
	case VDCENTER_RIGHT:	VDitem_geom.position = me->position = VD_ANNOT_RIGHT_CENTER;	break;
	case VDBOTTOM_RIGHT:	VDitem_geom.position = me->position = VD_ANNOT_RIGHT_BASE;	break;
	case VDTOP_RIGHT:	VDitem_geom.position = me->position = VD_ANNOT_RIGHT_CAP;	break;

	case VDOFFSET_OPTION:
	{
	  FIg_get_state ( form, VDOFFSET_OPTION, &offset_opt );

	  VDitem_geom.offset_on = offset_opt;

	  if ( offset_opt == 0 )
	  {
	    FIg_erase ( form , SBF_POS_GROUP );
	    for ( i=0; i<3; i++ )
	    {
	      me->auto_offset[i] = 0.0;
	    }
	  }
	  else
	  {
	    for ( i=0; i<3; i++ )
	    {
	      me->auto_offset[i] = VDitem_geom.offset[i];
	    }
	    sprintf ( tmptxt, "%lg", me->auto_offset[0] );
	    FIg_set_text ( form , VDOFFSETX, tmptxt );

	    sprintf ( tmptxt, "%lg", me->auto_offset[1] );
	    FIg_set_text ( form , VDOFFSETY, tmptxt );

	    sprintf ( tmptxt, "%lg", me->auto_offset[2] );
	    FIg_set_text ( form , VDOFFSETZ, tmptxt );

	    FIg_display  ( form , SBF_POS_GROUP );
	  }
	  break;
	}
	case VDOFFSETX:
	{
	  FIg_get_text ( form, VDOFFSETX, tmptxt );
	  VDitem_geom.offset[0] = me->auto_offset[0] = atof ( tmptxt );
	  break;
	}
	case VDOFFSETY:
	{
	  FIg_get_text ( form, VDOFFSETY, tmptxt );
	  VDitem_geom.offset[1] = me->auto_offset[1] = atof ( tmptxt );
	  break;
	}
	case VDOFFSETZ:
	{
	  FIg_get_text ( form, VDOFFSETZ, tmptxt );
	  VDitem_geom.offset[2] = me->auto_offset[2] = atof ( tmptxt );
	  break;
	}
	case VDLDRL_OPTION:
	{
	  FIg_get_state ( form, VDLDRL_OPTION, &ldr_opt );

	  if( ldr_opt == 0 )
	  {
	    /*
	     * The leader-line will be NON_DISPLAYABLE & NON_LOCATABLE
	     * The Position of the Balloon is determined by the chosen Justification
	     * (The leader-line doubles back on itself:
	     *  if this is not the case, then me->angle2 has to be modified)
	     */
	    FIg_erase ( form , SBF_LDR_GROUP );

	    me->mylen1 =  10.0;
	    me->mylen2 =  10.0;

	    me->angle1 =   0.0;
	    me->angle2 = 180.0;

	    VDitem_geom.leader_on = me->auto_leader = FALSE;
	  }
	  else
	  {
	    me->mylen1 = VDitem_geom.length1;
	    me->mylen2 = VDitem_geom.length2;
	    me->angle1 = VDitem_geom.angle1;
	    me->angle2 = VDitem_geom.angle2;

	    sprintf ( tmptxt, "%lg", me->mylen1 );
	    FIg_set_text ( form, VDLDRL1, tmptxt );

	    sprintf ( tmptxt, "%lg", me->mylen2 );
	    FIg_set_text ( form, VDLDRL2, tmptxt );

	    sprintf ( tmptxt, "%lg", me->angle1 );
	    FIg_set_text ( form, VDLDRA, tmptxt );

	    FIg_display  ( form, SBF_LDR_GROUP );

	    VDitem_geom.leader_on = me->auto_leader = TRUE;
	  }
	  break;
	}
	case VDLDRL1:
	{
	  FIg_get_text ( form, VDLDRL1, tmptxt );
	  VDitem_geom.length1 = me->mylen1 = atof ( tmptxt );
	  break;
	}
	case VDLDRL2:
	{
	  FIg_get_text ( form, VDLDRL2, tmptxt );
	  VDitem_geom.length2 = me->mylen2 = atof ( tmptxt );
	  break;
	}
	case VDLDRA:
	{
	  FIg_get_text ( form, VDLDRA, tmptxt );
	  VDitem_geom.angle1 = me->angle1 = atof ( tmptxt );

	  if ( 90.0 < me->angle1 && me->angle1 < 270.0 )
	  {
	    VDitem_geom.angle2 = me->angle2 = 180.0;
	  }
	  else
	  {
	    VDitem_geom.angle2 = me->angle2 = 0.0;
	  }

	  break;
	}
	case FI_ACCEPT:
	{
	  me->subform_display = FALSE;

//	  me->locat_all_tgl   = 0;
//	  FIg_set_state ( me->form, GAD_TOGGLE_2, me->locat_all_tgl );

	  status = FIf_erase ( form );

	  if ( me->auto_leader )
	  {
	    FIg_get_text ( form, VDLDRL1, tmptxt );
	    VDitem_geom.length1 = me->mylen1 = atof ( tmptxt );

	    FIg_get_text ( form, VDLDRL2, tmptxt );
	    VDitem_geom.length2 = me->mylen2 = atof ( tmptxt );

	    FIg_get_text ( form, VDLDRA, tmptxt );
	    VDitem_geom.angle1 = me->angle1 = atof ( tmptxt );

	    if ( 90.0 < me->angle1 && me->angle1 < 270.0 )
	    {
	      VDitem_geom.angle2 = me->angle2 = 180.0;
	    }
	    else
	    {
	      VDitem_geom.angle2 = me->angle2 = 0.0;
	    }

	    if ( me->mylen1 < 1e-6 && me->mylen2 < 1e-6 )
	    {
	      VDitem_geom.length1 = VDitem_geom.length2 = me->mylen1 = me->mylen2 = 10.0;
	      VDitem_geom.angle1 = me->angle1 =   0.0;
	      VDitem_geom.angle2 = me->angle2 = 180.0;
	    }
	  }

	  break;
	}
	default :
	{
	  break;
	}
      }
      break;
     }
    }
  }

  if ( item_found == FALSE )
  {
    FIg_set_text  ( form, FI_MSG_FLD_9, "" );
    FIg_disable   ( form, FI_MSG_FLD_9 );
    FIg_erase     ( form, FI_MSG_FLD_9 );
  }

  __exitMethod ( name = "process_bln_form" );

  return(status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDCmditem;
