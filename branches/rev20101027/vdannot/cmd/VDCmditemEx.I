/* $Id: VDCmditemEx.I,v 1.2 2001/09/14 15:06:05 ylong Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	vdannot/cmd/VDCmditemEx.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmditemEx.I,v $
 *	Revision 1.2  2001/09/14 15:06:05  ylong
 *	highlight selected table
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/15  23:58:24  pinnacle
# Replaced: vdannot/cmd/VDCmditemEx.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.20  1996/05/06  17:48:14  pinnacle
# Replaced: vdannot/cmd/VDCmditemEx.I for:  by v240_int for vds.240
#
# Revision 1.19  1996/04/10  18:25:44  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.18  1996/01/15  23:32:24  pinnacle
# Replaced: vdannot/cmd/VDCmditemEx.I for:  by jwfrosch for vds.240
#
# Revision 1.17  1995/09/11  13:56:56  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.16  1995/09/08  21:28:00  pinnacle
# Replaced: vdannot/cmd/*.I for:  by jwfrosch for vds.240
#
# Revision 1.15  1995/09/06  21:09:56  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.14  1995/08/31  18:40:32  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.13  1995/08/30  13:26:54  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.12  1995/08/29  21:31:48  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.11  1995/08/24  17:39:26  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.10  1995/08/23  17:50:24  pinnacle
# Replaced: vdannot/cmd/VDCmditemEx.I for:  by jwfrosch for vds.240
#
# Revision 1.9  1995/08/18  22:48:40  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
#
# Revision 1.8  1995/08/04  16:24:56  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.[IS] for:  by jwfrosch for vds.240
#
# Revision 1.7  1995/07/28  16:09:56  pinnacle
# Replaced: vdannot/cmd/VDCmditemEx.I for:  by jwfrosch for vds.240
#
# Revision 1.6  1995/07/27  16:19:36  pinnacle
# Replaced: vdannot/cmd/VDCmditemEx.I for:  by jwfrosch for vds.240
#
# Revision 1.5  1995/07/26  20:07:52  pinnacle
# Replaced: vdannot/cmd/VDCmditem*.I for:  by jwfrosch for vds.240
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
 *	11/20/92    ADZ		In case the object is an occurence of a ACheader
 *				object, the returned object (leaf_id) to
 *				attach to is found from ACmodel object.
 *				In this case the leaf_id will be refused.
 *
 *	08/30/94    Chaya Rao	Modified the file to make item associative
 *				to the object  without identifying leaf.
 *				Ci_macro "midpnts " makes item * associative.
 *				Changed the interface to achieve this.
 *
 *      01/06/95    cvr		New VDitem created for prefix, hence CO changed
 *
 *	6/15/95	    tlb		Modify to use new VDitem, VDitemSet, and VDitemMgr
 *
 *	07/20/95    HF		Functionality of "midpnts" has been taken over
 *				by ci_macro "src_obj"
 *
 *	01/15/96    HF		TR 179528298
 *				Calculate offset for partially hidden objects.
 *
 *				TR 179528573
 *				Do NOT place VDitem when object is completely hidden
 *
 *				Changes to "method auto_place_item"
 *
 *	04/10/96    HF		TR 179601220
 *
 *
 *      04/10/98   Ming         TR 179800949
 *************************************************************************/

class implementation VDCmditem;

#include <stdio.h>
#include <string.h>

#include "bs.h"
#include "griodef.h"
#include "AS_status.h"
#include "coparadef.h"
#include "coparamac.h"
#include "VDmsg.h"
#include "dpdef.h"
#include "dp.h"
#include "dpezmac.h"
#include "dpmacros.h"
#include "dimdef.h"
#include "exdef.h"
#include "exmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "dimmacros.h"
#include "grmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "vdandef.h"
#include "vdanmacros.h"
#include "dimsrc.h"

#include "vddrwattr.h"
#include "v_miscmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

from	NDnode		import	NDchg_state,
				NDconnect;
from	DMannot		import	ANadd_delete_vertex,
				set_dim_state;
from	GRgraphics	import	GRlnproject,
				GRdisplay,
				GRchgprops;

from	GRgraphics	import	GRgetrang;
from	ci_macro	import	init;
from	IGEgragad	import	DPinrot;
from	NDmacro		import	ACreturn_foot;
from	GR3dpoint	import	GRgetpolyline;
from	VDitem		import	VDputItemInfo;
from	VDitemMgr	import	VDconnectItmObjs;
from	DMroot		import	return_dim_go,
				delete_dim_go;
from	GRvg		import	GRgetattr;
from	VDitem		import	VDgetNbBreakPts;

extern GRclassid	OPP_GRbspline_class_id,
			OPP_ACheader_class_id,
			OPP_ACncpx_class_id,
			OPP_GRclhdr_class_id,
			OPP_GRsmhdr_class_id,
			OPP_VDitem_class_id,
			OPP_VDdrw2d_class_id,
			OPP_VDdrw3d_class_id,
			OPP_VDdrwGm_class_id,
			OPP_GRvg_class_id,
			OPP_nci_macro_class_id;

extern IGRchar		term_type;

/* they are changed to static in VDCmditemi.I
extern int		VDPlItem_x_memo,
			VDPlItem_y_memo,
			VDPlItem_s_memo;
*/
static int		VDPlItem_x_memo,
			VDPlItem_y_memo,
			VDPlItem_s_memo;

extern IGRint VD_DMlocate
(
  IGRlong		 *rc,		/* Return code from ls$locate	*/
  struct GRevent	 *event1,	/* Event for the locate point	*/
  struct GRevent	 *event2,	/* Event for the accept point	*/
  IGRlong		 *mask1,	/* Mask for the locate		*/
  IGRlong		 *mask2,	/* Mask for the input events	*/
  IGRlong		  display_flag,	/* Flag to define the display mode */
  IGRint		 *response,
  IGRchar		 *response_data,
  IGRchar		 *locate_prompt,
  IGRchar		 *acc_prompt,
  IGRchar		 *relocate_prompt,
  struct GRlc_locate	 *attributes,	/* Attributes to be found	*/
  struct DMact_info	 *act_parms,	/* Action handler parameters	*/
  struct GRlc_dynamics	 *hand_dyn,	/* Function & args for dynamics	*/
  OM_p_CLASSLIST	  Class_List	/* List of classes to locate; may be NULL */
);

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method execute
(
  int	*response;
  char	*response_data;
  int	 pos
)
{
  unsigned short	 mask;

  IGRboolean		 world = 1, put_intoque = FALSE, created_annot;

  IGRlong		 size = sizeof(struct GRevent);
  long			 status, msg;

  IGRint		 action, Valid_Ancestor;
  int			 msg_key, rc, token, control, k, index = 0;

  IGRdouble		 dummy_par, points[3], out_pt[3];
  IGRdouble		*local_attr;

  IGRpoint		 input_pt, center_pt, offset;
  IGRpoint		 norpt, dummy_pt;

  IGRmatrix		 matrix;
  GRrange		 range;

  struct GRid		 new_src_obj, TEMP[2], BubbleId, window_id;
  struct IGRpolyline	 polyline;
  struct IGRline	 view_line;
  struct DMobj_info	 obj_info;
  struct GRobj_env	*objs, connect_pt;
  struct GRmd_env	 lc_env;
  OM_S_CHANSELECT	 To_Comp;

  OM_S_CLASSLIST	 classlist;
  OMuword		 class[4];

  static int TokenList[] = {	RESET,
				D_RESET,
				DATA,
				GR_UNKNOWN_TYPE,
				STATUS_DISP,
				LOC_PARENT
			   };


  static enum possible_states NewState [ NUM_STATES ] [ NUM_TOKENS ] = {

  /*        ******************************   TOKENS *****************************
  Old State *    RESET    , D_RESET ,  DATA   ,  GR_UNK  , FORM    ,  LOC_PAREN *
	    *********************************************************************/

  /*INITIAL  */ {WAIT_MAC,  INITIAL,  WAIT_MAC,  INITIAL,  INITIAL,    INITIAL  },
  /*WAIT_MAC */ {WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_LEA  },
  /*WAIT_LEA */ {WAIT_LEA,  WAIT_MAC, WAIT_LEA,  WAIT_LEA, WAIT_LEA,  WAIT_BK1  },
  /*WAIT_POSN*/ {WAIT_LEA,  WAIT_MAC, WAIT_POSN, WAIT_POSN,WAIT_POSN, WAIT_BK1  },
  /*WAIT_BK1 */ {WAIT_BRK,  WAIT_MAC, WAIT_BRK,  WAIT_BK1, WAIT_BK1,  WAIT_BK1  },
  /*WAIT_BRK */ {WAIT_MAC,  WAIT_MAC, WAIT_BRK,  WAIT_BRK, WAIT_BRK,  WAIT_BRK  },
  /*WAIT_POS */ {WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_POS, WAIT_POS,  WAIT_POS} };


// *INITIAL  */ {WAIT_MAC,  INITIAL,  WAIT_MAC,  INITIAL,  INITIAL,    INITIAL  },
// *WAIT_MAC */ {WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_LEA  },
// *WAIT_LEA */ {WAIT_LEA,  WAIT_MAC, WAIT_LEA,  WAIT_LEA, WAIT_LEA,  WAIT_BK1  },
// *WAIT_POSN*/ {WAIT_LEA,  WAIT_MAC, WAIT_POSN, WAIT_POSN,WAIT_POSN, WAIT_BK1  },
// *WAIT_BK1 */ {WAIT_LEA,  WAIT_MAC, WAIT_BRK,  WAIT_BK1, WAIT_BK1,  WAIT_BK1  },
// *WAIT_BRK */ {WAIT_MAC,  WAIT_MAC, WAIT_BRK,  WAIT_BRK, WAIT_BRK,  WAIT_BRK  },
// *WAIT_POS */ {WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_POS, WAIT_POS,  WAIT_POS  };

  static enum possible_actions NewAction [ NUM_STATES ] [ NUM_TOKENS ] = {

  /*        ******************************   TOKENS ***************************
  Old State *     RESET   , D_RESET , DATA   ,  GR_UNK  , FORM    , LOC_PAREN *
	    *******************************************************************/

  /*INITIAL  */ { STO_NOLD ,PRT_LD   ,STO_LD   ,LOC_MAC  ,DIS_FOR  ,STO_MAC  },
  /*WAIT_MAC */ { LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,DIS_FOR  ,STO_MAC  },
  /*WAIT_LEA */ { NO_LEAF  ,LOC_MAC  ,STO_LEAF ,LOC_LEAF ,DIS_FOR  ,STO_LEAF },
  /*WAIT_POSN*/ { LOC_LEAF ,LOC_MAC  ,STO_LEAF ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
  /*WAIT_BK1 */ { PLACE    ,LOC_MAC  ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
  /*WAIT_BRK */ { PLACE    ,DELETE   ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
  /*WAIT_POS */ { DELETE   ,DELETE   ,PLACE    ,GET_BRK  ,DIS_FOR  ,GET_BRK  } };

// *INITIAL  */ { STO_NOLD ,PRT_LD   ,STO_LD   ,PRT_LD   ,DIS_FOR  ,PRT_LD   },
// *WAIT_MAC */ { LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,DIS_FOR  ,STO_MAC  },
// *WAIT_LEA */ { NO_LEAF  ,LOC_MAC  ,LOC_LEAF ,LOC_LEAF ,DIS_FOR  ,STO_LEAF },
// *WAIT_POSN*/ { LOC_LEAF ,LOC_MAC  ,STO_LEAF ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
// *WAIT_BK1 */ { LOC_LEAF ,LOC_MAC  ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
// *WAIT_BRK */ { PLACE    ,DELETE   ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
// *WAIT_POS */ { DELETE   ,DELETE   ,PLACE    ,GET_BRK  ,DIS_FOR  ,GET_BRK  };

  __enterMethod ( name = "execute" );

  ex$message(msgnumb = me->rel_key, buff = me->relocate_prompt);

  classlist.w_count	= 4;
  classlist.w_flags	= OM_CLST_subclass;
  classlist.p_classes	= class;

  class[0] = OPP_ACncpx_class_id;
  class[1] = OPP_GRsmhdr_class_id;
  class[2] = OPP_GRclhdr_class_id;
  class[3] = OPP_VDitem_class_id;

  status =
  om$make_chanselect(	channame	= "GRcmpowner.to_components",
			p_chanselect	= &To_Comp );

  /* init */

  token = control = 0;

  created_annot	= FALSE;

  msg_key = VD_P_EntBrPt;

  __printf ( "TokenList = %3d %3d %3d %3d %3d %3d\n", ` TokenList[0], TokenList[1], TokenList[2],
							TokenList[3], TokenList[4], TokenList[5]` );

  for ( k = 0; k < NUM_STATES; k++ )
  {
    __printf ( "NewState  = %3d %3d %3d %3d %3d %3d", ` NewState[k][0], NewState[k][1], NewState[k][2],
							NewState[k][3], NewState[k][4], NewState[k][5]` );
  }
  __prints ( "" );
  for ( k = 0; k < NUM_STATES; k++ )
  {
    __printf ( "NewAction = %3d %3d %3d %3d %3d %3d", ` NewAction[k][0], NewAction[k][1], NewAction[k][2],
							NewAction[k][3], NewAction[k][4], NewAction[k][5]` );
  }

RESTART:

  do
  {
    switch( me->action)
    {
      case NIL :
	{
	  __printf ( ">><< case NIL      (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`NIL, me->input_required, me->action, me->state` );

	  break;
	}
      case ERR :
	{
	  __printf ( ">> case ERR        (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`ERR, me->input_required, me->action, me->state` );

	  me->state  = INITIAL;
	  me->action = PRT_LD ;

	  __printf ( "<< case ERR        (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`ERR, me->input_required, me->action, me->state` );
	}
      case PRT_LD :		/* ask if leader line or not */
	{
	  __printf ( ">> case PRT_LD     (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`PRT_LD, me->input_required, me->action, me->state` );

	  /*
	   * startup option to choose VDitem with or without leader line.
	   *
	   * The functionality for placement with/without leaderline has been modified and is
	   * now controlled by GAD_TOGGLE_3 in STATUS_FORM
	   */

//	  FIg_set_text ( me->form, FI_MSG_FIELD, "" );
//	  UI_status ( "" );

	  me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

	  me->an_grid.objid		= NULL_OBJID;
	  me->hdr_set.obj_id.objid	= NULL_OBJID;

	  me->input_required = POINT;

	  ex$message(msgnumb = VD_P_IdElIt);

	  __printf ( "<< case PRT_LD     (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`PRT_LD, me->input_required, me->action, me->state` );

	  break;
	}
      case STO_LD :		/* place with leader line: Controlled by GAD_TOGGLE_3 in FORM */
	{
	  __printf ( ">><< case STO_LD   (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`STO_LD, me->input_required, me->action, me->state` );

	  ex$putque (	msg      = &msg,
			response =  response,
			byte     = &size,
			buffer   = (IGRchar *) &(me->event1.event));
	}
      case STO_NOLD :		/* place without leader line: Controlled by GAD_TOGGLE_3 in FORM */
	{
	  __printf ( ">><< case STO_NOLD (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`STO_NOLD, me->input_required, me->action, me->state` );

	}
      case LOC_MAC :		/* locate macro to hook leader line */
	{
	  __printf ( ">> case LOC_MAC    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`LOC_MAC, me->input_required, me->action, me->state` );

	  /*
	   * set masks for the macro and the wireframe object
	   */
	  me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
	  me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

	  me->an_grid.objid	   = NULL_OBJID;
	  me->hdr_set.obj_id.objid = NULL_OBJID;

	  me->input_required = PARENT;

	  ex$message(msgnumb = me->loc_key, buff = me->locate_prompt);
	  ex$message(msgnumb = VD_P_AccRej, buff = me->acc_prompt);

	  /*
	   * ENABLE the gadgets in GAD_GROUP (lower half of STATUS_FORM)
	   */

	  if ( me->locat_all_tgl == FALSE )
	  {
	    FIg_set_text ( me->form, FI_MSG_FIELD, "" );
	    UI_status ( "" );
	  }

	  __printf ( "<< case LOC_MAC    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`LOC_MAC, me->input_required, me->action, me->state` );

	  break;
	}
      case STO_MAC :
	{
	  __printf ( ">> case STO_MAC    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`STO_MAC, me->input_required, me->action, me->state` );

	  if ( me->obj_not_in_table )
	  {
	    /*
	     * Force transition to action PRT_LD
	     */
	    me->input_required	= NOENT;
	    me->state		= INITIAL;
	    me->action		= PRT_LD ;

	    me->obj_not_in_table = FALSE;

	    break;
	  }

	  UI_prompt ( "" );

	  as$start_fence (	set		= &me->loc_event.located_object[0].located_obj,
				set_env		= &me->loc_event.located_object[0].module_info,
				nb_obj		= &me->count_macro,
				p_obj_env	= &objs,
				response	= response,
				response_data	= response_data );
	  ASend_fence();

	  __printf ( ">>>>>>>>>> me->count_macro = %d me->locat_all_tgl = %d, response = %d",
			`me->count_macro, me->locat_all_tgl, *response` );

	  if ( me->count_macro < 1  )
	  {
	    if ( *response > RESET )
	    {
	      /*
	       * Command could be stacked ...
	       */

	      me->action	= STO_MAC;

	      goto quit;
	    }
	    else
	    {
	      /*
	       * fence rejected
	       */

	      me->action	= LOC_MAC;
	      me->input_required= NOENT;

	      break;
	    }
	  }

	  if ( me->locat_all_tgl == TRUE )
	  {
	    char	cls_nm[DI_PATH_MAX];

	    if ( me->count_macro < 1 )
	    {
	      me->input_required= NOENT;
	      me->action	= STO_MAC;
	    }
	    else
	    {
	      /*
	       * Processing Fence : Auto Place Item
	       */
	      me->input_required= NOENT;
	      me->action	= PRT_LD;

//	      for ( k=0; k < me->count_macro; k++ )
//	      {
//		om$get_classname (	osnum = objs[k].obj_id.osnum,
//					objid = objs[k].obj_id.objid,
//					classname	= cls_nm );
//
//		__printf ( "\tobjs.obj_id[%d] = [%d,%d], classname = <%s>",
//			`k, objs[k].obj_id.osnum, objs[k].obj_id.objid, cls_nm` );
//	      }

	      status = om$vla_set_dimension (	varray =  me->obj_selected,
						size   =  me->count_macro );
	      index = 0;
	      for( k=0 ; k < me->count_macro ; k++ )
	      {
		Valid_Ancestor =
			DMancestry_valid ( objs[k].obj_id, OPP_ACncpx_class_id  ) ||
			DMancestry_valid ( objs[k].obj_id, OPP_GRclhdr_class_id ) ||
			DMancestry_valid ( objs[k].obj_id, OPP_GRsmhdr_class_id );

		if( Valid_Ancestor & OM_S_SUCCESS )
		{
		  me->obj_selected [index++] = objs[k];
		}
	      }

	      me->count_macro = index;

	      status = om$vla_set_dimension (	varray =  me->obj_selected,
						size   =  me->count_macro  );

	      for( k=0 ; k < me->count_macro ; k++ )
	      {
		om$get_classname (	osnum = me->obj_selected[k].obj_id.osnum,
					objid = me->obj_selected[k].obj_id.objid,
					classname	= cls_nm );

		__printf ( "\tme->obj_selected[%d] = [%d,%d], classname = <%s>",
			`k, me->obj_selected[k].obj_id.osnum, me->obj_selected[k].obj_id.objid, cls_nm` );
	      }

	      /*
	       * If me->window.objid == NULL_OBJID ...
	       */

	      while( me->window.objid == NULL_OBJID || me->window.objid == 0 )
	      {
		struct GRevent	event;
		int	response;

		while ( ! co$getevent (	msg		= &msg,
					event_mask	= ( GRm_DATA ),
					prompt		= "Identify Window",
					response	= &response,
					response_data	=  response_data,
					event		= &event ) ) ;

		if( ( msg & 1 ) && ( response == EX_DATA ) )
		{
		    me->window.objid = event.event.button.objid;
		    me->window.osnum = event.event.button.osnum;
		    window_id.objid  = me->window.objid;
		    window_id.osnum  = me->window.osnum;
		    break;
		}
	      }

	      /*
	       * Now proceed with Auto Placement of Items
	       */

	      status =
	      om$send (	msg	 = message VDCmditem.auto_place_item ( &msg ),
			targetid = my_id );
//	      as$status();

	      me->action	 = LOC_MAC;
	      me->state		 = WAIT_MAC;
	      me->input_required = NOENT;

	    }

	    break;
	  }

	  /*
	   * Check if located object is in a Drawing View
	   * If this is true, then replace it with the originating Model object
	   */
	  if( DMancestry_valid( me->loc_event.located_object[0].located_obj,
              OPP_VDdrw2d_class_id ) == OM_S_SUCCESS )
	  {
	    VDpartAttr		 attr;

	    attr.Iwant	= VD_I_drwParentObj;

	    status =
	    om$send (	msg	 = message GRvg.GRgetattr( &msg, (char *)&attr ),
			targetid = me->loc_event.located_object[0].located_obj.objid,
			targetos = me->loc_event.located_object[0].located_obj.osnum );
	    if ( status & msg & 1 )
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
                om$send(msg = message GRvg.GRgetattr( &msg, (char *)&attr1 ),
                        targetid = attr.obj.obj_id.objid,
                        targetos = attr.obj.obj_id.osnum );
                if( status & msg & 1 )
                {
                   ASget_as_owner( &attr1.obj.obj_id, &ownId );
                   if(  ownId.objid != NULL_OBJID )
                   {
                     status =
                     om$send( msg = message NDmacro.ACreturn_foot(
                                            &msg,
                                            "",
                                            &modObj,
                                            &modEnv.md_env.matrix_type,
                                            modEnv.md_env.matrix),
                              targetid = ownId.objid,
                              targetos = ownId.osnum );

                     if( status & msg & 1 )
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
	      me->loc_event.located_object[0].located_obj = attr.obj.obj_id;
	      me->loc_event.located_object[0].module_info = attr.obj.mod_env;
	    }
	  }

	  /*
	   * save the macro object
	   */

	  me->hdr_set.obj_id  = me->loc_event.located_object[0].located_obj;
	  me->hdr_set.mod_env = me->loc_event.located_object[0].module_info;

	  if ( me->global_leader )
	  {
	    me->input_required = POINT;

	    msg_key = VD_P_EntPlPt;

	    ex$message(msgnumb = msg_key);
	  }
	  else
	  {
	    /*
	     * This effectively removes the prompt "Enter Placement Point"
	     * In this mode the placement point is the center of the located Object
	     */
	    me->input_required	= NOENT;
	    me->action		= CNST_DIM;

	    msg_key = VD_P_EntDpPt;

	    ex$message(msgnumb = msg_key);
	  }

	  /*
	   * DISABLE the gadgets in GAD_GROUP (lower half of STATUS_FORM)
	   */

	  __printf ( "<< case STO_MAC    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`STO_MAC, me->input_required, me->action, me->state` );

	  break;
	}
      case LOC_LEAF :
	{
	  __printf ( ">> case LOC_LEAF   (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`LOC_LEAF, me->input_required, me->action, me->state` );

	  /*
	   * set masks and prompts for accept reject of the wireframe object.
	   */

	  if( ! put_intoque )
	  {
	    ex$putque (	msg      = &msg,
			response =  response,
			byte     = &size,
			buffer   = (IGRchar *) &(me->event1.event));

	    put_intoque = TRUE;
	  }
	  me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ ;
	  me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

	  ex$message(msgnumb = VD_P_AccRej, buff = me->locate_prompt );
	  ex$message(msgnumb = VD_P_AccRej, buff = me->acc_prompt );

	  /* locate filter */

	  __printf ( "<< case LOC_LEAF   (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`LOC_LEAF, me->input_required, me->action, me->state` );

	  break;
	}
      case NO_LEAF  :
	{
	  __printf ( ">> case NO_LEAF    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`NO_LEAF, me->input_required, me->action, me->state` );

	  me->state	     = WAIT_POSN;
	  me->input_required = POINT;

	  msg_key = VD_P_EntPlPt;

	  ex$message(msgnumb = msg_key);

	  __printf ( "<< case NO_LEAF    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`NO_LEAF,me->input_required, me->action, me->state` );

	  break;
	}
      case STO_LEAF :
      case CNST_DIM :
	{
	  __printf ( ">> case CNST_DIM   (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`CNST_DIM, me->input_required, me->action, me->state` );

	  /*
	   * Construct the text with balloon
	   */

	  me->leader = (me->count_macro == 1) ? 1 : 0;

	  __printf ( "me->global_leader = %d, me->leader = %d",
			`me->global_leader, me->leader` );

	  if( me->leader )
	  {
	    char	*exp_name = NULL;
	    char	textbuffer[80];

	    input_pt[0] = me->event1.event.button.x;
	    input_pt[1] = me->event1.event.button.y;
	    input_pt[2] = me->event1.event.button.z;

	    status =
	    om$send (	msg	 = message GRgraphics.GRgetrang
						( &msg,
						  &me->hdr_set.mod_env.md_env.matrix_type,
						   me->hdr_set.mod_env.md_env.matrix,
						  &world,
						   range ),
			targetid = me->hdr_set.obj_id.objid,
			targetos = me->hdr_set.obj_id.osnum );

	    for( k=0 ; k<3 ; k++ )
	    {
	      center_pt[k] = ( range[3+k] + range[k] ) / 2.0 ;
	    }

	    /*
	     * If NO leader line, then reset the placement point to the center
	     * of the located object
	     */

	    if ( ! me->global_leader )
	    {
	      if( DMancestry_valid ( me->hdr_set.obj_id, OPP_VDitem_class_id ) == OM_S_SUCCESS )
	      {
		status =
		om$get_objid_at_index (	objid		= me->hdr_set.obj_id.objid,
					osnum		= me->hdr_set.obj_id.osnum,
					index		= 3,		// Bubble Object
					p_chanselect	= &To_Comp,
					objidaddr	= &BubbleId.objid,
					osnumaddr	= &BubbleId.osnum);
		as$status();
		__printf ( ">>>>>>>>>> BubbleId = [%d,%d]", `BubbleId.osnum, BubbleId.objid` );

		status =
		om$send (	msg	 = message GRgraphics.GRgetrang
						( &msg,
						  &me->md_env.md_env.matrix_type,
						   me->md_env.md_env.matrix,
						  &world,
						   range ),
			targetid = BubbleId.objid,
			targetos = BubbleId.osnum );
		as$status();
		__printf ( "Bubble Range[LO] = %14.6lf %14.6lf %14.6lf", `range[0], range[1], range[2]` );
		__printf ( "Bubble Range[HI] = %14.6lf %14.6lf %14.6lf", `range[3], range[4], range[5]` );

	      }

	      for( k=0 ; k<3 ; k++ )
	      {
		center_pt[k] = ( range[3+k] + range[k] ) / 2.0 ;
		input_pt [k] = center_pt[k];
	      }
	      me->event1.event.button.x = center_pt[0];
	      me->event1.event.button.y = center_pt[1];
	      me->event1.event.button.z = center_pt[2];
	    }

	    for( k=0 ; k<3 ; k++ )
	    {
	      offset[k] =  input_pt[k] - center_pt[k] ;
	    }
	    /*
	     * Reset offset[2] to active z
	     */

	    status =
	    dp$view_vol (	msg		= &msg,
				gg_id		= &window_id, 
				new_active_z	= &offset[2] );
	    as$status();

	    if ( ABS ( offset[2] ) < 1e-8 ) offset[2] = 0.0;

	    __printf ( "input_pt  []  : %14.6lf %14.6lf %14.6lf", `input_pt[0], input_pt[1], input_pt[2]` );
	    __printf ( "center_pt []  : %14.6lf %14.6lf %14.6lf", `center_pt[0], center_pt[1], center_pt[2]` );
	    __printf ( "offset[IACT]  : %14.6lf %14.6lf %14.6lf", `offset[0], offset[1], offset[2]` );

	    TEMP[0].objid   = NULL_OBJID;
	    TEMP[0].osnum   = me->md_env.md_id.osnum;

	    as$make_source (	go_grid  =  me->hdr_set.obj_id,
				mod_env  = &me->hdr_set.mod_env,
				as_grid  = &TEMP[0] );

	    __printf ( ">>>>>>>>>> me->hdr_set.obj_id [%d,%d] ==>> [%d,%d]",
		`me->hdr_set.obj_id.osnum, me->hdr_set.obj_id.objid, TEMP[0].osnum, TEMP[0].objid` );

	    new_src_obj.osnum = me->md_env.md_id.osnum;

	    status =
	    om$construct (	classid	= OPP_nci_macro_class_id,
				p_objid	= &new_src_obj.objid,
				osnum	= me->md_env.md_id.osnum);
	    as$status();

	    sprintf ( textbuffer, "%d %lf %lf %lf", (int)VD_ANNOT_CENTER_CENTER, offset[0], offset[1], offset[2] );

	    status = exp$create (	exp_name	= exp_name,
					exp_syntax	= textbuffer,
					osnum		= me->md_env.md_id.osnum,
					p_exp_id	= &(TEMP[1].objid),
					p_osnum		= &(TEMP[1].osnum),
					type_rq		= EXP_TEXT );

	    status = om$send (	msg	 = message NDnode.NDchg_state( (char)16, (char)16 ),
				targetid = TEMP[1].objid,
				targetos = TEMP[1].osnum );

	    __printf ( "CI_MACRO src_obj = [%d,%d]", `new_src_obj.osnum, new_src_obj.objid` );

	    status =
	    om$send (	msg	 = message ci_macro.init(&rc,
							 0,
							 "src_obj",
							 2,
							 TEMP,
							 NULL,
							&me->md_env ),
			targetid = new_src_obj.objid,
			targetos = new_src_obj.osnum);
	    as$status();

	    UI_prompt ( "" );

	    /* return the graphic object (foot) from the nci_macro */

	    status =
	    om$send (	msg	 = message NDmacro.ACreturn_foot(
							&msg,
							 "pnt",
							&connect_pt.obj_id,
							&connect_pt.mod_env.md_env.matrix_type,
							 connect_pt.mod_env.md_env.matrix ),
			targetid = new_src_obj.objid,
			targetos = new_src_obj.osnum );

	    as$status();

	    __printf ( "connect_pt       = [%d,%d]", `connect_pt.obj_id.osnum, connect_pt.obj_id.objid` );

	    mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

	    gr$put_properties (	object_id	= &connect_pt.obj_id,
				action		= 0,
				properties_mask = mask);

	    gr$display_object( object_id = &connect_pt.obj_id, mode = GRbeheo );

	    action = 1;

	    polyline.points = points;

	    status =
	    om$send (	msg	 = message GR3dpoint.GRgetpolyline(
							&msg,
							&connect_pt.mod_env.md_env.matrix_type,
							 connect_pt.mod_env.md_env.matrix,
							&action,
							&polyline),
			targetid = connect_pt.obj_id.objid,
			targetos = connect_pt.obj_id.osnum );

	    as$status();

	    __printf ( "points[]         = %14.6lf %14.6lf %14.6lf", `points[0], points[1], points[2]` );

	    lc_env = me->md_env;
	    obj_info.grid = connect_pt.obj_id;

	    status =
	    om$send (	msg	 = message IGEgragad.DPinrot( (IGRlong *) &rc, matrix),
			targetid = me->event1.event.button.objid,
			targetos = me->event1.event.button.osnum);
	    as$status();

	    view_line.point1 = &polyline.points[0];

	    norpt[0] = view_line.point1[0] + matrix[ 8];
	    norpt[1] = view_line.point1[1] + matrix[ 9];
	    norpt[2] = view_line.point1[2] + matrix[10];

	    view_line.point2 = norpt;

	    status =
	    om$send (	msg	 = message GRgraphics.GRlnproject(
							 (IGRlong *) &rc,
							&lc_env.md_env.matrix_type,
							 lc_env.md_env.matrix,
							&view_line,
							 dummy_pt,
							 obj_info.lnproj,
							&dummy_par,
							&obj_info.par),
			targetid = obj_info.grid.objid,
			targetos = obj_info.grid.osnum);
	    as$status();

	    status =
	    GRfindcontext(	&rc,
				&connect_pt.mod_env.md_env.matrix_type,
				 connect_pt.mod_env.md_env.matrix,
				&obj_info.grid.osnum,
				&obj_info.context);

	    if (status != OM_S_SUCCESS || rc != MSSUCC )
	    {
	      obj_info.context.objid = NULL_OBJID;
	    }

	    /* replace method get_dim_plane */
	    {
	      IGRint status;
	      struct GRid win_grid;

	      win_grid.objid = me->event1.event.button.objid;
	      win_grid.osnum = me->event1.event.button.osnum;

	      status =
	      dm$get_dim_plane (win_grid = win_grid,
				md_env	 = &me->md_env,
				p_grid	 = &me->list[DIM_ROOT_PLAN]);
	      as$status();

	      status =
	      dm$get_plan_info (plan_objid	= me->list[DIM_ROOT_PLAN].objid,
				osnum		= me->list[DIM_ROOT_PLAN].osnum,
				md_env		= &me->md_env,
				plan_info	= &me->plan_info);
	      as$status();

	    }
	    status =
	    BSproj1 (	&rc,
			&me->event1.event.button.x,
			&me->plan_info.win_plan.matrix[8],
			 obj_info.lnproj,
			 out_pt);

	    as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}

	    local_attr = &out_pt[0];

	    __printf ( "button.P = %14.6lf %14.6lf %14.6lf (Point to Project)",
		`me->event1.event.button.x, me->event1.event.button.y, me->event1.event.button.z` );

	    __printf ( "matrix[8]= %14.6lf %14.6lf %14.6lf (Plane Normal Vector)",
		`me->plan_info.win_plan.matrix[8], me->plan_info.win_plan.matrix[9], me->plan_info.win_plan.matrix[10]` );

	    __printf ( "lnproj[0]= %14.6lf %14.6lf %14.6lf (Point on Plane)",
		`obj_info.lnproj[0], obj_info.lnproj[1], obj_info.lnproj[2]` );

	    __printf ( "points[] = %14.6lf %14.6lf %14.6lf", `points[0], points[1], points[2]` );
	    __printf ( "out_pt[] = %14.6lf %14.6lf %14.6lf", `out_pt[0], out_pt[1], out_pt[2]` );

	    status=
	    dm$create_root (	type     =  DMptdist,
				count    =  1,
				list     = &obj_info.grid,
				context  = &obj_info.context,
				attr     =  local_attr,
				md_env   = &lc_env,
				p_root   = &me->list[AN_ROOT_ELEM1]);
	    as$status();

	    status = om$send (	msg	 = message VDCmditem.place_dimension(),
				targetid = my_id);
	    as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}

	    if ( me->an_grid.objid == NULL_OBJID )
	    {
	      /*
	       * The balloon or the text has not been created
	       */

	      me->state		 = WAIT_MAC;
	      me->action	 = LOC_MAC;
	      me->input_required = NOENT;

	      break;
	    }
	    else
	    {
	      created_annot = TRUE;
	    }

	    status =
	    om$send (	msg	 = message DMannot.set_dim_state
						(BIT_SET, DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
	    as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}
	  }
	  __printf ( "<< case CNST_DIM   (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`CNST_DIM, me->input_required, me->action, me->state` );

	}
      case GET_BRK :
	{
	  __printf ( ">> case GET_BRK    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`GET_BRK, me->input_required, me->action, me->state` );

	  me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP ;

	  me->input_required = POINT;

	  control = me->leader ? MOVE_BREAK_PT : 0;

	  if ( me->global_leader )
	  {
	    msg_key = VD_P_EntBrPt;
	  }
	  else
	  {
	    msg_key = VD_P_EntDpPt;
	  }
	  ex$message(msgnumb = msg_key);

	  status =
	  om$send (	msg	 = message VDCmdAnnot.position_dim
							( msg_key,
							  TRUE, NULL, NULL,
							  control, NULL, NULL),
			targetid = my_id);

	  if( created_annot )
	  {
	    created_annot = FALSE;
	    if( me->global_leader )
	    {
		me->state	= WAIT_BK1;
		me->action	= ADD_BRK;
//		me->state	= WAIT_BRK;
//		me->action	= GET_BRK;
	    }
	    else
	    {
		me->input_required = NOENT;
		me->state	   = WAIT_MAC;
		me->action	   = PLACE;
	    }
	  }

	  __printf ( "<< case GET_BRK    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`GET_BRK, me->input_required, me->action, me->state` );

	  break;
	}
      case ADD_BRK :
	{
	  __printf ( ">> case ADD_BRK    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`ADD_BRK, me->input_required, me->action, me->state` );

	  msg_key = VD_P_EntBrPt;

	  status =
	  om$send (	msg	 = message COanplace.position_dim
							( msg_key,
							  FALSE, NULL, NULL,
							  control, NULL, NULL),
			targetid = my_id);

	  status =
	  om$send (	msg	 = message DMannot.ANadd_delete_vertex(
								&rc,
								 ADD_VERTEX,
								 NULL,
								&me->dyn_env),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
	  as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}

	  status =
	  om$send (	msg	 = message DMannot.set_dim_state (
							BIT_SET,
							DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
	  as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}

	  me->action = GET_BRK;

	  me->input_required = NOENT;

	  __printf ( "<< case ADD_BRK    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`ADD_BRK, me->input_required, me->action, me->state` );
	  break;
	}
      case PLACE :
	{
	  IGRint	NbBreakPts = 0;

	  __printf ( ">> case PLACE      (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`PLACE, me->input_required, me->action, me->state` );

	  status =
	  om$send (	msg	 = message VDitem.VDgetNbBreakPts( &msg, &NbBreakPts ),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);

	  __printf ( "status = %d, msg = %d, NbBreakPts = %d", `status, msg, NbBreakPts` );

	  if( me->leader )
	  {
	    status =
	    om$send (	msg	 = message VDCmdAnnot.delete_vertex( &rc ),
			targetid = my_id );
	    as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}

	    status =
	    om$send (	msg	 = message VDCmdAnnot.compute_dimension(),
			targetid = my_id );
	    as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}

	    status =
	    om$send (	msg	 = message VDCmdAnnot.display_dimension( ROOT, DISPLAY | ADDWRNG),
			targetid = my_id);
	    as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}
	  }

	  me->action		= LOC_MAC;
	  me->state		= WAIT_MAC;
	  me->input_required	= NOENT;

	  if ( ! me->global_leader )
	  {
	    status =
	    om$send (	msg	 = message VDCmditem.chg_props_leader ( &msg, me->an_grid ),
			targetid = my_id );
	    as$status();
	  }

	  __printf ( "<< case PLACE      (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`PLACE, me->input_required, me->action, me->state` );

	  break;

	  /* in case of no leader delete item number on move on */
	}
      case DELETE :
	{
	  __printf ( ">> case DELETE     (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`DELETE, me->input_required, me->action, me->state` );

	  status = om$send (	msg	 = message VDCmdAnnot.delete_dimension (),
				targetid = my_id);
	  as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}

	  me->state	     = WAIT_MAC;
	  me->action	     = LOC_MAC;
	  me->input_required = NOENT;

	  __printf ( "<< case DELETE     (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`DELETE, me->input_required, me->action, me->state` );

	  break;
	}
      case DIS_FOR :
	{
	  __printf ( ">> case DIS_FOR    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`DIS_FOR, me->input_required, me->action, me->state` );

	  FIg_enable  ( me->form, FI_MSG_FIELD );
	  FIg_display ( me->form, FI_MSG_FIELD );
	  FIf_display ( me->form );

	  if     ( me->state == INITIAL  )   me->action = PRT_LD;
	  else if( me->state == WAIT_MAC )   me->action = LOC_MAC;
	  else if( me->state == WAIT_LEA )   me->action = LOC_LEAF;
	  else if( me->state == WAIT_POSN)   me->action = NO_LEAF;
	  else if( me->state == WAIT_POS ||
		   me->state == WAIT_BK1 ||
		   me->state == WAIT_BRK )   me->action = GET_BRK;
	  else
	  {
	    __exit_error_Method ( name = "execute" );
	    return OM_W_ABORT;
	  }
	  me->input_required = NOENT;

	  __printf ( "<< case DIS_FOR    (%2d): me->input_required = %d me->action = %2d me->state = %d",
		`DIS_FOR, me->input_required, me->action, me->state` );

	  break;
	}
    }		/* End switch on actions */

    switch ( me->input_required  )
    {
      case PARENT :
      {
	__printf ( ">> case PARENT     (%2d): me->input_required = %d me->action = %2d me->state = %d token = %d",
		`PARENT, me->input_required, me->action, me->state, token` );

	if ( me->obj_list_tgl )
	{
	  classlist.w_count	= 4;	/* Include VDitem in list of locatable classes	*/
	}
	else
	{
	  classlist.w_count	= 3;
	}

	status = VD_DMlocate (	(IGRlong *)&me->locate_rc,
				&me->loc_event,
				&me->event1,
				 (IGRlong *)me->mask1,
				 (IGRlong *)me->mask2,
				 me->display_flag,
				 (IGRint  *) response,
				 (IGRchar *) response_data,
				 me->locate_prompt,
				 me->acc_prompt,
				 me->relocate_prompt,
				&me->attr,
				&me->act_parms,
				&me->lc_dyn,
				&classlist );
	if (! (status & 1) )
	{
	  /*
	   * Force transition to action LOC_MAC
	   */
	  me->input_required	= NOENT;
	  me->state		= WAIT_MAC;
	  me->action		= LOC_MAC ;

	  break;
	}

	me->window = me->loc_event.event.button;
	window_id.objid  = me->window.objid;
	window_id.osnum  = me->window.osnum;

	__printf ( "me->obj_not_in_table = %d, me->locat_all_tgl = %d, me->locate_rc = %d, me->window = [%d,%d]",
		`me->obj_not_in_table, me->locat_all_tgl, me->locate_rc, me->window.osnum, me->window.objid` );

	if ( me->obj_not_in_table )
	{
	  /*
	   * Force transition to action PRT_LD ([ INITIAL ] [ LOC_PARENT ])
	   */
	  me->input_required = 0;
	  me->state = 0;
	  token     = 5;
	}
	else if ( me->locate_rc == LC_OBJ_LOCATED )
	{
	  for ( token=0; TokenList[token] != LOC_PARENT; token++);
	}
	else if ( *response == STATUS_DISP )
	{
	  for ( token=0; TokenList[token] != STATUS_DISP; token++);
	}
	else
	{
	  for ( token=0; TokenList[token] != *response && TokenList[token] != GR_UNKNOWN_TYPE; token++);
	}

	__printf ( "<< case PARENT     (%2d): me->input_required = %d me->action = %2d me->state = %d token = %d",
		`PARENT, me->input_required, me->action, me->state, token` );

	break;
      }
      case POINT:
      {
	__printf ( ">> case POINT      (%2d): me->input_required = %d me->action = %2d me->state = %d token = %d",
		`POINT, me->input_required, me->action, me->state, token` );

	token = GRget_token ( &msg, TokenList, &me->mask1, &me->event1,
				     &size, response, response_data);

	if ( *response == STATUS_DISP )
	{
	  for ( token=0; TokenList[token] != STATUS_DISP; token++ );
	}

	__printf ( "<< case POINT      (%2d): me->input_required = %d me->action = %2d me->state = %d token = %d",
		`POINT, me->input_required, me->action, me->state, token` );

	break;
      }
      case NOENT :
      {
	__printf ( ">><< case NOENT    (%2d): me->input_required = %d me->action = %2d me->state = %d token = %d",
		`NOENT, me->input_required, me->action, me->state, token` );

	break;
      }
      default :
      {
	printf ("input_required : %d (invalid)\n", me->input_required );
	break;
      }
    }

    if ( me->input_required != NOENT )
    {
      me->action = (IGRint) NewAction[ me->state ][ token ];
      me->state  = (IGRint) NewState [ me->state ][ token ];
    }

    __printf ( "<< DO_WHILE            : me->input_required = %d new_action = %2d new_state = %d token = %d",
		`me->input_required, me->action, me->state, token` );

  } while ( me->input_required == NOENT || TokenList [ token ] != GR_UNKNOWN_TYPE );

//  if ( *response == EX_POCKET )
//  {
//    *response = TERMINATE ;
//  }

quit:

  if ( *response == EX_POCKET )
  {
    if ( me->locat_all_tgl == TRUE )
    {
      me->action = LOC_MAC;
    }
    else
    {
      FIg_set_text ( me->form, FI_MSG_FIELD,
		  "Pocket Menu only in mode Locate All" );
      UI_status ( "Pocket Menu only in mode Locate All" );

      me->action = PRT_LD;
      goto RESTART;
    }
  }

  if ( *response == TERMINATE && me->an_grid.objid != NULL_OBJID )
  {
    status = om$send (	msg	 = message COanplace.delete_dimension(),
			targetid = my_id);
    as$status();if (! (status & 1) ){__exit_error_Method ( name = "execute" );return status;}
  }

  FIf_get_location ( me->form, &VDPlItem_x_memo, &VDPlItem_y_memo );
  FIf_get_screen   ( me->form, &VDPlItem_s_memo );
  VDitem_set_VDPlItem_x_memo ( VDPlItem_x_memo );
  VDitem_set_VDPlItem_y_memo ( VDPlItem_y_memo );
  VDitem_set_VDPlItem_s_memo ( VDPlItem_s_memo );

  __printf ( "<<<<< VDPlItem_xys_memo = [%d,%d,%d]", `VDPlItem_x_memo, VDPlItem_y_memo, VDPlItem_s_memo` );

  if ( me->auto_check_frm )
  {
    char	*msgtxt = { "No BOM Table Defined; Terminating Command" };
    int		msglng = strlen(msgtxt);

    UI_status ( msgtxt );

    FI_message_box (	FI_CURRENT_SCREEN, -1, -1, "Place Item Balloon", FI_BLACK, "swiss742b", 25.0,
			msgtxt, FI_BLACK, "swiss742b", 18.0, FI_FITTED, msglng );
  }

  __printf ( "<<<<<<<<<< response = %d, me->auto_check_frm = %d", `*response, me->auto_check_frm` );

  __exitMethod ( name = "execute" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method chg_props_leader
(
  IGRlong	*msg;
  struct GRid	 ItemId
)
{
  IGRshort	props = 0x60, actn = 0;	/* Clear LOCATABLE & DISPLAYABLE bits	*/
  IGRlong	retcd;
  long		status = OM_S_SUCCESS;
  int		rc;
  struct GRid	lead_grid, arrow_grid;

  enum GRdpmode	dpmode = GRbeheo;

  __enterMethod ( name = "chg_props_leader" );

  *msg = MSSUCC;

  status =
  om$send (	msg	 = message DMroot.return_dim_go(
						&rc,
						DIM_LEADER,
						TRUE,
						DM_LINE_STR,
						&me->md_env,
						&lead_grid),
		targetid = ItemId.objid,
		targetos = ItemId.osnum);
  as$status();

  status =
  om$send (	msg	 = message DMroot.return_dim_go(
						&rc,
						DIM_ORI_TERM,
						TRUE,
						DM_LINE_STR,
						&me->md_env,
						&arrow_grid),
		targetid = ItemId.objid,
		targetos = ItemId.osnum);
  as$status();

  status =
  om$send (	msg	 = message GRgraphics.GRchgprops(
						&retcd,
						&actn,
						&props),
		targetid = lead_grid.objid,
		targetos = lead_grid.osnum);
  as$status();
  __printf ( ">>>>>>>>>>lead_grid  = [%d,%d], props = %#o", `lead_grid.osnum, lead_grid.objid, props` );

  status =
  om$send (	msg	 = message GRgraphics.GRchgprops(
						&retcd,
						&actn,
						&props),
		targetid = arrow_grid.objid,
		targetos = arrow_grid.osnum);
  as$status();
  __printf ( ">>>>>>>>>>arrow_grid = [%d,%d], props = %#o", `arrow_grid.osnum, arrow_grid.objid, props` );

  status =
  om$send (	msg	 = message GRgraphics.GRdisplay
						(&retcd,
						 &me->md_env.md_env.matrix_type,
						  me->md_env.md_env.matrix,
						 &dpmode,
						 &me->md_env.md_id),
		targetid = lead_grid.objid,
		targetos = lead_grid.osnum);

  status =
  om$send (	msg	 = message GRgraphics.GRdisplay
						(&retcd,
						 &me->md_env.md_env.matrix_type,
						  me->md_env.md_env.matrix,
						 &dpmode,
						 &me->md_env.md_id),
		targetid = lead_grid.objid,
		targetos = lead_grid.osnum);

  __exitMethod ( name = "chg_props_leader" );

  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method auto_place_item ( IGRlong  *msg )
{
  IGRchar		*Itm_Num = NULL, item_string[40];
  IGRboolean		 world = 1, item_found = 0;
  long			 status = OM_S_SUCCESS;
  IGRint		 item_used = 0, bln_type, bln_sides;
  int			 i0, j0, k0, index = -1, tbl_found = 0;

  IGRdouble		 bln_size;
  VDpartAttr		 attr;

  struct DMsenv_param	 par_senv;
  struct GRid		 item_id, ItmId;
  struct VDan_ldrline	 leader_line;
  struct VDTblId_Name	 fixed_tbl;

  int			  NbFound = 0;
  struct GRid		 *RowId	  = NULL;
  struct GRid		 *TblId	  = NULL;
  char			**ItemNum = NULL;
  char			**TblNam  = NULL;
  char			**PthNam  = NULL;
  int			  NbUnCnctd    = 0;
  int			  NbGRvg  = 0;
  int			 *UnCnctdFlag  = NULL;

  struct GRid		  null_grid, row_src, loc_obj[2], ContextId, window_id;
  struct GRobj_env	  VDdrwGm_id;
  struct GRid		 *GRvgId = NULL;
  GRrange		 range;
  IGRpoint		 offset;

  __enterMethod ( name = "auto_place_item" );

  attr.Iwant	= VD_I_drwParentObj;

  leader_line.num_segs	= 2;
  leader_line.segs	= NULL;

  *msg	= MSSUCC;
  null_grid.objid = NULL_OBJID;
  VDdrwGm_id.obj_id.objid = NULL_OBJID;

  if ( me->window.objid == NULL_OBJID || me->window.objid == 0 )
  {
    *msg = MSFAIL;
    status = OM_W_ABORT;

    __print_goto ( "wrapup" );
    goto wrapup;
  }
  window_id.objid  = me->window.objid;
  window_id.osnum  = me->window.osnum;

  dm$get_dim_param (	type	= DM_SENV_PARAM,
			p_data	= (char *)&par_senv );

  bln_type	= par_senv.bln_type ;
  bln_size	= par_senv.bln_size ;
  bln_sides	= par_senv.num_sides;

  item_id.objid	= NULL_OBJID;
  fixed_tbl	= me->table_info;

  leader_line.segs = _MALLOC ( leader_line.num_segs, struct VDan_segs );

  if( leader_line.segs == NULL )
  {
    printf ( "ERROR: memory allocation of leader_line.segs\n" );
    goto wrapup;
  }
  leader_line.segs[0].angle = me->angle1;
  leader_line.segs[1].angle = me->angle2;
  leader_line.segs[0].len   = me->mylen1;
  leader_line.segs[1].len   = me->mylen2;

  world = 1;

  for ( i0=0; i0 < me->count_macro; i0++ )
  {
    me->hdr_set = me->obj_selected[i0];
    index = -1;
    memset ( offset, 0, sizeof ( IGRpoint ) );

    /*
     * Check if located object is in a Drawing View
     * If this is true, then replace it with the originating Model object
     */

    if( DMancestry_valid( me->hdr_set.obj_id, OPP_VDdrw2d_class_id ) == OM_S_SUCCESS )
    {
      status =
      om$send (	msg	 = message NDmacro.ACreturn_foot(
							 msg,
							 "geom",
							&VDdrwGm_id.obj_id,
							&VDdrwGm_id.mod_env.md_env.matrix_type,
							 VDdrwGm_id.mod_env.md_env.matrix ),
			targetid = me->hdr_set.obj_id.objid,
			targetos = me->hdr_set.obj_id.osnum );

      as$status();

      __printf ( "VDdrwGm_id       = [%d,%d]", `VDdrwGm_id.obj_id.osnum, VDdrwGm_id.obj_id.objid` );

      if( DMancestry_valid( VDdrwGm_id.obj_id, OPP_VDdrwGm_class_id ) == OM_S_SUCCESS )
      {
	status = VDGetGridsFromChan_of_Class ( msg, VDdrwGm_id.obj_id, &AS_to_comp,
						-OPP_GRvg_class_id, &NbGRvg, &GRvgId );
	__printf ( "NbGRvg = %d", NbGRvg );

	if ( NbGRvg == 0 )
	{
	  /*
	   * TR 179528573
	   *
	   * This means that there is NO GRAPHICS VISIBLE of the 3D object in the drawing view:
	   *   It is COMPLETELY hidden behind another object.
	   * In this case : DO NOT replace the Drawing View object with the 3D Model object
	   * and ignore completely, because the Item Balloon should NOT be placed.
	   */

	  _FREE ( GRvgId );

	  continue;
	}
	else
	{
	  /*
	   * TR 179528298
	   *
	   * Something needs to be done about the connect point for the CI_MACRO, 
	   * particularly in case the object is partially hidden.
	   *
	   * Find the cumulated centerpoint of the VDdrw2D objects and use this point
	   * to calculate the offset from the centerpoint of the 3D Model object.
	   */

	   status = VDget_cum_cnt_pt ( msg, NbGRvg, GRvgId, offset );
	}
      }

      status =
      om$send (	msg	 = message GRvg.GRgetattr( msg, (char *)&attr ),
		targetid = me->hdr_set.obj_id.objid,
		targetos = me->hdr_set.obj_id.osnum );
      as$status();

      if ( status & *msg & 1 )
      {
	me->hdr_set = attr.obj;
	index = i0;

	/*
	 * Calculate the centerpoint of the 3D Model object and reset the offset...
	 */
	status =
	om$send (	msg	 = message GRgraphics.GRgetrang
						(  msg,
						  &me->hdr_set.mod_env.md_env.matrix_type,
						   me->hdr_set.mod_env.md_env.matrix,
						  &world,
						   range ),
			targetid = me->hdr_set.obj_id.objid,
			targetos = me->hdr_set.obj_id.osnum );

	for( k0=0 ; k0<3 ; k0++ )
	{
	  offset[k0] -= ( range[3+k0] + range[k0] ) / 2.0 ;
	}
	/*
	 * Reset offset[2] to active z
	 */

	status =
	dp$view_vol (	msg		=  msg,
			gg_id		= &window_id, 
			new_active_z	= &offset[2] );
	as$status();

	if ( ABS ( offset[2] ) < 1e-8 ) offset[2] = 0.0;

	__printf ( "offset[AUTO]  : %14.6lf %14.6lf %14.6lf", `offset[0], offset[1], offset[2]` );

      }

      _FREE ( GRvgId );
    }

    status = VDGetRowIdsItemNums_TblIdsTblNms_FromObjId
		( msg, &NbFound, &NbUnCnctd, &UnCnctdFlag, me->hdr_set.obj_id, &RowId, &TblId, &ItemNum, &TblNam, &PthNam );
    as$status();

    __printf ( "ModelId[%d,%d] is connected to %d Tables (%d unconnected); status = %d, *msg = %d",
	`me->hdr_set.obj_id.osnum, me->hdr_set.obj_id.objid, NbFound, NbUnCnctd, status, *msg` );

    tbl_found = 0;

    for ( j0=0; j0 < NbFound; j0++ )
    {
      /*
       * compare   TblId[j0].objid   with   fixed_tbl.tbl_id.obj_id.objid
       */
      if ( me->fixed_table == TRUE )
      {
	if ( TblId[j0].objid != fixed_tbl.tbl_id.obj_id.objid )
	{
//	  goto CONTINUE_;
	  continue;
	}
	else
	{
	  tbl_found = 1;
	}
      }

      item_id.objid  = NULL_OBJID;
      item_string[0] = '\0';
      strcpy ( item_string, ItemNum[j0] );

      if ( UnCnctdFlag[j0] == 0 )
      {
	__printf ( "\tme->obj_selected[%d] = [%d,%d] : ALREADY HAS ITEM PLACED",
		`i0, me->hdr_set.obj_id.osnum, me->hdr_set.obj_id.objid` );
	if ( index == -1 )
	{
	  /*
	   * Prevent multiple VDitem's connected to the same element ...
	   */
	  FIg_set_text ( me->form, FI_MSG_FIELD,
			"Object already has Item" );
	  UI_status (	"Object already has Item" );

	  goto CONTINUE_;
	}
	else
	{
	  /*
	   * Allow multiple VDitem's connected to the same Model Object in the case
	   * of multiple Drawing_Views ...
	   * But we must prevent multiple labeling of the VDdrw2d Object : me->obj_selected[index]
	   */

	  Itm_Num = NULL;
	  status =
	  vd$getItemNoForObj (	obj	=  me->obj_selected[index].obj_id,
				tblName	=  TblNam[j0],
				itemId	= &ItmId,
				itemNo	= &Itm_Num,
				found	= &item_found);
	  if ( Itm_Num )
	  {
	    __printf ( ">>>>> item_found = %d, ItmId.obj_id = [%d,%d], Itm_Num = <%s>, TblNam[%d] = <%s>",
			`item_found, ItmId.osnum, ItmId.objid, Itm_Num, j0, TblNam[j0]` );

	    if ( item_found && strcmp (item_string, Itm_Num) == 0 )
	    {
	      _FREE ( Itm_Num );

	      FIg_set_text ( me->form, FI_MSG_FIELD,
				"Object already has Item" );
	      UI_status (	"Object already has Item" );

	      goto CONTINUE_;
	    }
	    else
	    {
	      _FREE ( Itm_Num );
	    }
	  }
	}
      }

//      if ( item_string[0] == '\0' )
//      {
//	__printf ( "\tme->obj_selected[%d] = [%d,%d] : EMPTY ItemNum - Item NOT placed",
//		`i0, me->hdr_set.obj_id.osnum, me->hdr_set.obj_id.objid` );
//	goto CONTINUE_;
//      }

      __printf ( "\titem_string[%d] = <%s>", `j0, item_string` );

      if( me->an_classid == OPP_VDitem_class_id )
      {
	leader_line.segs[0].len   = (j0 + 1) * me->mylen1;

	for( k0=0 ; k0<3 ; k0++ )
	{
	  offset[k0] += me->auto_offset[k0];
	}

	status = VDitem_place (	&me->hdr_set,
				&bln_type,
				&bln_sides,
				&bln_size,
				 1,
				&leader_line,
				 (int) me->position,
				 offset,
				&me->window,
				&item_id,
				 item_string);

//	vd$place_item (	object		= &me->hdr_set,
//			bln_type	= &bln_type,
//			bln_sides	= &bln_sides,
//			bln_size	= &bln_size,
//			position	=  (int) me->position,
//			offset		=  offset,
//			leader_line	= &leader_line,
//			window		= &me->window,
//			p_item		= &item_id,
//			itemNo		=  item_string);
	as$status();

	__printf ( "\titem_id    [%d] = [%d,%d]", `j0, item_id.osnum, item_id.objid` );

////////////////////////////////////////////
	/*
	 * THIS SECTION COULD/SHOULD BE MOVED TO : vd$place_item ?!?!?
	 *
	 * The current implementation of vd$place_item (see "vdanmacros.h")
	 * cannot be used to place the new VDitem objects
	 */

	/*
	 * find context(s) and make sources
	 */
	status =
	om$send (	msg	 = message NDmacro.ACreturn_foot(
						 msg,
						 "",
						&RowId[j0],
						&me->md_env.md_env.matrix_type,
						 me->md_env.md_env.matrix ),
			targetid = RowId[j0].objid,
			targetos = RowId[j0].osnum );
	as$status();

	__printf ( "status = %d, *msg = %d, RowId[%d] = [%d,%d]", `status, *msg, j0, RowId[j0].osnum, RowId[j0].objid` );

	status = GRfindcontext(  msg,
				&me->md_env.md_env.matrix_type,
				 me->md_env.md_env.matrix,
				&RowId[j0].osnum,
				&ContextId );
	if( ! ( status & *msg & 1 ) ) ContextId.objid = NULL_OBJID ;

	__printf ( "status = %d, *msg = %d, ContextId = [%d,%d]", `status, *msg, ContextId.osnum, ContextId.objid` );

	as$make_source (go_grid		= RowId[j0],
			context_grid	= ContextId,
			as_os		= RowId[j0].osnum,
			as_grid		= &row_src );

	__printf ( ">>>>> RowId[%d] = [%d,%d], row_src = [%d,%d]",
		`j0, RowId[j0].osnum, RowId[j0].objid, row_src.osnum, row_src.objid` );

	loc_obj[0] = row_src;
	item_used  = 1;

	status =
	om$send(msg	 = message NDnode.NDconnect (	item_used,
							loc_obj,
							null_grid,
							ND_NEW),
		targetid = item_id.objid,
		targetos = item_id.osnum);
	as$status();if (! (status & 1) ){__print_goto ( "wrapup" );goto wrapup;}

	status =
	om$send (	msg	 = message VDitemMgr.VDconnectItmObjs
								(  msg,
								   TblNam[j0],
								   1,
								  &item_id ),
			targetid = me->MgrId.objid,
			targetos = me->MgrId.osnum );
	as$status();

	status =
	om$send (	msg	 = message VDitem.VDputItemInfo (
								msg,
								item_string ),
			targetid = item_id.objid,
			targetos = item_id.osnum );
	as$status ();

////////////////////////////////////////////

	if ( me->auto_leader == FALSE )
	{
	  status =
	  om$send (	msg	 = message VDCmditem.chg_props_leader ( msg, item_id ),
			targetid = my_id );
	  as$status();
	}
      }
    }

    if ( me->fixed_table == TRUE && tbl_found == 0 )
    {
	__prints ( "\tTABLE FIXED: NO change of table allowed" );

	FIg_set_text ( me->form, FI_MSG_FIELD,
			"TABLE FIXED: NO change table allowed" );
	UI_status (	"TABLE FIXED: NO change table allowed" );

	me->obj_not_in_table = TRUE;
    }

CONTINUE_:

    _FREE ( UnCnctdFlag );
    _FREE ( RowId );
    _FREE ( TblId );

    for ( k0=0; k0 < NbFound; k0++ )
    {
	_FREE ( (ItemNum)[k0] );
	_FREE ( (TblNam )[k0] );
	_FREE ( (PthNam )[k0] );
    }

    _FREE ( ItemNum);
    _FREE ( TblNam );
    _FREE ( PthNam );

  }

wrapup:

  _FREE ( leader_line.segs );

  __exitMethod ( name = "auto_place_item" );

  return (status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDCmditem;
