/* $Id: VDCmdtxldrEx.I,v 1.2 2001/11/08 15:42:51 hans Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdtxldrEx.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdtxldrEx.I,v $
 *	Revision 1.2  2001/11/08 15:42:51  hans
 *	Fix for TR# MP5641
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *
# Revision 1.2  1999/10/14  20:20:00  pinnacle
# (No comment)
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/09/18  03:07:52  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldrEx.I for:  by mdong for vds
#
# Revision 1.2  1997/08/26  22:06:14  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldrEx.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.3  1996/08/23  19:45:58  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldrEx.I for:  by yzhu for vds.241
#
# Revision 1.2  1996/08/12  09:30:52  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldrEx.I for:  by rgade for vds.241
#
# Revision 1.11  1996/05/09  22:35:00  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldrEx.I for:  by yzhu for vds.240
#
# Revision 1.10  1996/05/02  12:06:48  pinnacle
# Replaced: ./vdannot/cmd/VDCmdtxldrEx.I for:  by azuurhou for vds.240
#
# Revision 1.9  1996/04/18  15:10:04  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldrEx.I for:  by yzhu for vds.240
#
# Revision 1.8  1996/04/12  03:01:34  pinnacle
# Replaced: vdannot/cmd/VDCmdtxldrEx.I for:  by yzhu for vds.240
#
# Revision 1.4  1996/02/16  23:54:22  pinnacle
# Replaced: ./vdannot/cmd/VDCmdtxldrEx.I for:  by azuurhou for vds.240
#
# Revision 1.3  1995/07/25  22:49:18  pinnacle
# Replaced: vdannot/cmd/* for:  by jwfrosch for vds.240
#
# Revision 1.2  1995/01/19  22:10:02  pinnacle
# Replaced:  vdannot/cmd/VDCmdtxldrEx.I r#
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YYYY	AUTHOR		DESCRIPTION
 *      05/06/96        yzhu            change all VDtxbox to VDfrmtxt
 *      10/14/99	Ming		tr179900855
 *      11/08/2001	HF		Fix for TR 5641
 * -------------------------------------------------------------------*/

/* I/VDS
 *
 * File:	 ~VDS/VDSannot/.I
 *
 * Description: This file consists of the methods to place annotation.
 *	      it contains the execute for annotation
 * History:
 *
 *   ADZ	20/11/1992
 *
 *   In case the object is an occurence of a ACheader object,
 *   the returned object (leaf_id) to attach to is found from
 *   ACmodel object.
 *   In this case the leaf_id will be refused.
 *
 *   08/20/94	Chaya V. Rao
 *   modified the file to make annotation associative to the object
 *   without identifying leaf. ci_macro "src_obj " makes annotation
 *   associative.
 *   changed the interface to achieve this.
 *
 */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

class implementation VDCmdtxldr;

#include "griodef.h"
#include "AS_status.h"
#include "coparadef.h"
#include "coparamac.h"
#include "VDmsg.h"
#include "dpdef.h"
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
#include "v_dbgmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

from	NDnode		import	NDchg_state;
from	DMannot		import	ANadd_delete_vertex,set_dim_state;
from	DMsrc		import	DMgive_structure,DMmodify;
from	GRgraphics	import	GRlnproject;
from	DMsrc		import	DMdisplay_source;
from	GRowner		import	GRget_number_components, GRget_components;
from	GRgraphics	import	GRgetrang;
from	ci_macro	import	init;
from	IGEgragad	import	DPinrot;
from	NDmacro		import	ACreturn_foot;
from	GR3dpoint	import	GRgetpolyline;
from    VDfrmtxt        import  VDsetAttribute;

extern GRclassid	OPP_GRbspline_class_id,
			OPP_VDfrmtxt_class_id,
			OPP_ACheader_class_id,
			OPP_GRsmhdr_class_id,
			OPP_GRclhdr_class_id,
			OPP_ACncpx_class_id,
			OPP_VDitbln_class_id,
			OPP_nci_macro_class_id;

extern IGRdouble 	VDCmdtxldr_text_angle;
extern IGRlong       	VDCmdtxldr_text_flag;

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

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

method execute
(
  int	*response;
  char	*response_data;
  int	 pos
)
{
  IGRchar		*exp_name = NULL;

  IGRboolean		 world, no_ldrline, no_wireframe;
  IGRuchar		 box;
  IGRboolean		 put_intoque = FALSE, created_annot;

  unsigned short	 mask;

  IGRlong		 size = sizeof ( struct GRevent );
  IGRlong		 status, msg, retn, stat, retmsg, arrow_index;
  IGRlong		 text_flag;

  IGRint		 action;
  int			 msg_key, rc, token, control, k, p, ret_val, ret_back;

  IGRdouble		 points[3], out_pt[3];
  IGRdouble		 dummy_par;
  IGRdouble		*local_attr;

  IGRpoint		 input_pt, center_pt, offset;
  IGRpoint		 norpt, dummy_pt;
  GRrange		 range;
  IGRmatrix		 matrix;

  struct GRid		*obj;
  struct GRid		 new_src_obj, TEMP[2];

  struct IGRpolyline	 polyline;
  struct IGRline	 view_line;
  struct DMobj_info	 obj_info;
  struct GRobj_env	 connect_pt;
  struct GRmd_env	 lc_env;

  OM_S_CLASSLIST         classlist;
  OMuword                class[4];

  int                    Num_Bk;
  static int TokenList[] = {	RESET		,
				D_RESET		,
				DATA		,
				GR_UNKNOWN_TYPE	,
				STATUS_DISP	,
				LOC_PARENT	};


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*        ******************************   TOKENS *************************
Old State *    RESET    , D_RESET ,  DATA   , GR_UNK  , FORM    , LOC_PAREN *
          *****************************************************************/

/*INITIAL */  {WAIT_MAC,  INITIAL,  WAIT_MAC,  INITIAL,  INITIAL,    INITIAL  },
/*WAIT_MAC*/  {WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_LEA  },
/*WAIT_LEA*/  {WAIT_LEA,  WAIT_MAC, WAIT_LEA,  WAIT_LEA, WAIT_LEA,  WAIT_BK1  },
/*WAIT_POSN*/ {WAIT_LEA,  WAIT_MAC, WAIT_POSN, WAIT_POSN,WAIT_POSN, WAIT_BK1  },
/*WAIT_BK1*/  {WAIT_LEA,  WAIT_MAC, WAIT_BRK,  WAIT_BK1, WAIT_BK1,  WAIT_BK1  },
/*WAIT_BRK*/  {WAIT_MAC,  WAIT_MAC, WAIT_BRK,  WAIT_BRK, WAIT_BRK,  WAIT_BRK  },
/*WAIT_POS*/  {WAIT_MAC,  WAIT_MAC, WAIT_MAC,  WAIT_POS, WAIT_POS,  WAIT_POS} };


static enum possible_actions NewAction[NUM_STATES][NUM_TOKENS] = {

/*        ******************************   TOKENS *************************
Old State *   RESET   , D_RESET ,  DATA   , GR_UNK  , FORM    , LOC_PAREN *
          *****************************************************************/

/*INITIAL */{ STO_NOLD ,PRT_LD   ,STO_LD   ,PRT_LD   ,DIS_FOR  ,PRT_LD   },
/*WAIT_MAC*/{ LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,DIS_FOR  ,STO_MAC  },
/*WAIT_LEA*/{ NO_LEAF  ,LOC_MAC  ,LOC_LEAF ,LOC_LEAF ,DIS_FOR  ,STO_LEAF },
/*WAIT_POSN*/{LOC_LEAF ,LOC_MAC  ,STO_LEAF ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
/*WAIT_BK1*/{ LOC_LEAF ,LOC_MAC  ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
/*WAIT_BRK*/{ PLACE    ,DELETE   ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
/*WAIT_POS*/{ DELETE   ,DELETE   ,PLACE    ,GET_BRK  ,DIS_FOR  ,GET_BRK  } };

  SetProc( VDCmdtxldrEx.execute );  Begin;

  __enterMethod ( name = "execute" //, argfmt = "", args = ``
  );

  ex$message(msgnumb = me->rel_key, buff = me->relocate_prompt);

  __DBGpr_int( " start response       = ",*response);
  __DBGpr_int( " start token          = ",token);
  __DBGpr_int( " start_state          = ",me->state);
  __DBGpr_int( " start_action         = ",me->action);
  __DBGpr_int( " start input_required = ",me->input_required);

  __printf( " start response     = %d", `*response`);
  __printf( " start token        = %d", `token`);
  __printf( " me->state          = %d", `me->state`);
  __printf( " me->action         = %d", `me->action`);
  __printf( " me->input_required = %d", `me->input_required`);

  /* init */

  Num_Bk = 0;
  token = control = 0;

  no_ldrline    =  FALSE;
  no_wireframe  = FALSE;
  created_annot = FALSE;

  msg_key = VD_P_EntBrPt;

  do
  {
    switch( me->action)
    {
      case NIL :
      {
        __DBGpr_com( " NIL ");
        __prints( ">>><<< NIL ");
        break;
      }
      case ERR :
      {
        __DBGpr_com( " ERR ");
        __prints( ">>><<< ERR ");
        me->state  = INITIAL;
        me->action = PRT_LD ;
      }
      case PRT_LD :		/* ask if leader line or not */
      {
        /*
         * startup option to choose for formatted text with or without
         * leader line.
         */
        __DBGpr_com( " PRT_LD ");
        __prints( ">>> PRT_LD ");

/*	me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;*/
        me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP;
        me->an_grid.objid	   = NULL_OBJID;
        me->hdr_set.obj_id.objid = NULL_OBJID;
        me->input_required	   = POINT;

        ex$message(msgnumb = VD_P_IdElNoLead);
/*	UI_prompt(" Place with Leader (Data)/ No (Move-on)"); */

        __prints( "<<< PRT_LD ");
        break;
      }
      case STO_LD :		/* place with leader line */
      {
        __DBGpr_com( " STO_LD ");
        __prints( ">>> STO_LD ");
        ex$putque (	msg      = &msg,
			response = response,
			byte     = &size,
			buffer   = (IGRchar *) &(me->event1.event));
        me->global_leader = TRUE;
        __prints( "<<< STO_LD ");
      }
      case STO_NOLD :	/* place without leader line */
      {
        __DBGpr_com( " STO_NOLD ");
        __prints( ">>> STO_NOLD ");
        if(me->action == STO_LD)
        {
          me->global_leader = TRUE;
        }
        else
        {
          me->global_leader = FALSE;
          no_ldrline	= TRUE;
        }
        __prints( "<<< STO_NOLD ");
      }
      case LOC_MAC :	/* locate macro to hook leader line */
      {
        __DBGpr_com( " LOC_MAC ");
        __prints( ">>> LOC_MAC ");
        /*
         * set masks for the macro and the wireframe object
         */
        me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
        me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

        me->an_grid.objid	= NULL_OBJID;
        me->hdr_set.obj_id.objid = NULL_OBJID;
        me->input_required = PARENT;

        ex$message(msgnumb = me->loc_key, buff = me->locate_prompt);
        ex$message(msgnumb = VD_P_AccRej, buff = me->acc_prompt);

        __prints( "<<< LOC_MAC ");
        break;
      }
      case STO_MAC :
      {
        __DBGpr_com( " STO_MAC ");
        __prints( ">>> STO_MAC ");
        UI_prompt(" ");

        as$start_fence(set           = &me->loc_event.located_object[0].located_obj,
                       nb_obj        = &me->count_macro,
                       p_obj         = &obj,
                       response      = response,
                       response_data = response_data );
        ASend_fence();
        __DBGpr_int( " STO_MAC: response =  ", *response);
        __DBGpr_int( " STO_MAC:  me->count_macro =  ",  me->count_macro);

        if( me->count_macro < 1 )
        {
          /*
           * fence rejected
           */

          me->action         = LOC_MAC;
          me->state          = WAIT_MAC;
          me->input_required = NOENT;

          break;
        }

        /*
         * save the macro object
         */

        me->hdr_set.obj_id  = me->loc_event.located_object[0].located_obj;
        me->hdr_set.mod_env = me->loc_event.located_object[0].module_info;

        if( no_ldrline )
        {
          me->input_required = POINT;
          me->state = WAIT_POS;

          msg_key = VD_P_EntPlPt;
          ex$message(msgnumb = msg_key);
        }
        else
        {
          me->input_required = POINT;
          me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
/*	  UI_prompt( "Identify wireframe/Move-on no wireframe"); */
          ex$message(msgnumb = VD_P_IdWiNoWire );

        }
        __prints( "<<< STO_MAC ");
        break;
      }
      case LOC_LEAF :
      {
        __DBGpr_com( " LOC_LEAF");
        __prints( ">>> LOC_LEAF");
        /*
         * set masks and prompts for accept reject of the wireframe object.
         */

        if( !no_ldrline )
        {
          if( me->action == LOC_LEAF )
          {
            if( !put_intoque )
            {
              __DBGpr_com( " LOC_LEAF put_intoque  =  TRUE");
              ex$putque (	msg	 = &msg,
				response = response,
				byte     = &size,
				buffer   = (IGRchar *) &(me->event1.event));

              put_intoque  =  TRUE;
            }
            me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP ;

            /* about TR 179601635 and 179601584 */
            ex$message(msgnumb = VD_P_IdWiNoWire, buff = me->locate_prompt );
          }
        }

        me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP ;

        ex$message(msgnumb = VD_P_AccRej, buff = me->acc_prompt );

        /* locate filter */

        if( !no_ldrline ) { me->input_required = PARENT; }

        __prints( "<<< LOC_LEAF");
        break;
      }
      case NO_LEAF  :
      {
        __DBGpr_com( " NO_LEAF");
        __prints( ">>> NO_LEAF");
        no_wireframe       = TRUE;

        me->state          = WAIT_POSN;
        me->input_required = POINT;

        Num_Bk             = 0;
        msg_key            = VD_P_EntPlPt;
        ex$message(msgnumb = msg_key);

        __prints( "<<< NO_LEAF");
        break;
      }
      case STO_LEAF :
      case CNST_DIM :
      {
        __DBGpr_com( " STO_LEAF and CNST_DIM");
        __printf( ">>> STO_LEAF and CNST_DIM: no_ldrline = %d, me->input_required = %d, PARENT = %d",
                  `no_ldrline, me->input_required, PARENT`);
        /*
         * Construct the text with balloon
         */

        me->leader = (me->global_leader && me->count_macro ==1) ? 1 : 0;

        if( !no_ldrline )
        {
          if( me->leader )
          {
            /* Added by Ming for tr179900855 */

            if( me->input_required == PARENT )
            {
              struct GRid      ownId       = NULL_GRID;
              struct GRid      wireframeId = NULL_GRID;

              wireframeId = me->loc_event.located_object[0].located_obj;

              if( wireframeId.osnum != OM_Gw_current_OS );
              {
                ASget_as_owner( &wireframeId, &ownId );

                __printf("wireframeId = [%d,%d], ownId = [%d,%d]",
                         `wireframeId.osnum, wireframeId.objid, ownId.osnum, ownId.objid`);

                if(//ownId.objid == NULL_OBJID ||        // HF: 11/08/2001 - Fix for TR 5641
                    (ownId.objid == wireframeId.objid &&
                     ownId.osnum == wireframeId.osnum) )
                {
                  no_wireframe       = TRUE;
                  me->state          = WAIT_POSN;
                  me->input_required = POINT;
                  Num_Bk             = 0;
                  msg_key            = VD_P_EntPlPt;

//                    ex$message(msgnumb = msg_key);
//                    UI_status("Bad Wireframe. Place texts without wireframe.");
//                    printf("Bad Wireframe. Place texts without wireframe.\n");

                  break;
                }
              }
            }

            if( no_wireframe )
            {
              input_pt[0] = me->event1.event.button.x;
              input_pt[1] = me->event1.event.button.y;
              input_pt[2] = me->event1.event.button.z;

              world = 1;

              status =
		om$send( msg	  = message GRgraphics.GRgetrang(&retn,
					&me->hdr_set.mod_env.md_env.matrix_type,
					me->hdr_set.mod_env.md_env.matrix,
					&world,
					range ),
                         targetid = me->hdr_set.obj_id.objid,
                         targetos = me->hdr_set.obj_id.osnum );

              for( k=0 ; k<3 ; k=k+1 )
              {
                center_pt[k] = ( range[3+k] + range[k] ) / 2.0 ;
              }

              for( k=0 ; k<3 ; k=k+1 )
              {
                offset[k] =  input_pt[k] - center_pt[k] ;
              }

              for( p=0 ; p<2 ; p++ )
              {
                TEMP[p].objid = NULL_OBJID;
                TEMP[p].osnum = me->md_env.md_id.osnum;
              }

              as$make_source( go_grid  = me->hdr_set.obj_id,
                              mod_env  = &me->hdr_set.mod_env,
                              as_grid  = &TEMP[0] );

              new_src_obj.osnum = me->md_env.md_id.osnum;

              status =
		om$construct (	classid	= OPP_nci_macro_class_id,
				p_objid	= &new_src_obj.objid,
				osnum	= me->md_env.md_id.osnum );
              as$status();

              for( p=1 ; p<2 ; p++ )
              {
                char	textbuffer[80];

                sprintf ( textbuffer, "%d %lf %lf %lf",
                          (int)VD_ANNOT_CENTER_CENTER,offset[0], offset[1], offset[2] );

                status = exp$create ( exp_name   = exp_name,
                                      exp_syntax = textbuffer,
                                      osnum      = me->md_env.md_id.osnum,
                                      p_exp_id   = &(TEMP[p].objid),
                                      p_osnum    = &(TEMP[p].osnum),
                                      type_rq    = EXP_TEXT );

                status = om$send(msg = message NDnode.NDchg_state(
                                   (char)16,(char)16 ),
                                 targetid = TEMP[p].objid,
                                 targetos = TEMP[p].osnum );
              }

              status =
		om$send ( msg	 = message ci_macro.init (  &ret_back,
							     0,
							     "src_obj",
							     2,
							     TEMP,
							     NULL,
							    &me->md_env ),
			targetid = new_src_obj.objid,
			targetos = new_src_obj.osnum);
              as$status();

              UI_prompt( " " );

              /* create_arrow */

              /* return the graphic object (foot) from the nci_macro */

              status =
		om$send(msg	 = message NDmacro.ACreturn_foot(
					&stat,
					"pnt",
					&connect_pt.obj_id,
					&connect_pt.mod_env.md_env.matrix_type,
					 connect_pt.mod_env.md_env.matrix ),
			targetid = new_src_obj.objid,
			targetos = new_src_obj.osnum );

              as$status();

              /* make the point nonlocatable and nondisplayable */

              mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

              gr$put_properties( object_id       = &connect_pt.obj_id,
                                 action          = 0,
                                 properties_mask = mask);

              gr$display_object( object_id = &connect_pt.obj_id,
                                 mode      = GRbeheo );

              action = 1;

              polyline.points = points;

              status =
		om$send( msg	 = message GR3dpoint.GRgetpolyline(
					&retmsg,
					&connect_pt.mod_env.md_env.matrix_type,
					 connect_pt.mod_env.md_env.matrix,
					&action,
					&polyline),
			targetid = connect_pt.obj_id.objid,
			targetos = connect_pt.obj_id.osnum );

              as$status();

              lc_env = me->md_env;
              obj_info.grid = connect_pt.obj_id;

              status =
		om$send(msg	 = message IGEgragad.DPinrot(
					   (IGRlong *) &rc, matrix),
			targetid = me->event1.event.button.objid,
			targetos = me->event1.event.button.osnum);
              as$status();

              view_line.point1 = &polyline.points[0];

              norpt[0] = view_line.point1[0] + matrix[8];
              norpt[1] = view_line.point1[1] + matrix[9];
              norpt[2] = view_line.point1[2] + matrix[10];

              view_line.point2 = norpt;

              status =
		om$send (msg	 = message GRgraphics.GRlnproject(
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
		GRfindcontext(&rc,
                              &connect_pt.mod_env.md_env.matrix_type,
                              connect_pt.mod_env.md_env.matrix,
                              &obj_info.grid.osnum,
                              &obj_info.context);

              if (status != OM_S_SUCCESS || rc != MSSUCC )
              {
                obj_info.context.objid = NULL_OBJID;
              }

              arrow_index  = AN_ROOT_ELEM1;

              /* replace method get_dim_plane */
              {
                IGRint status;
                struct GRid win_grid;

                win_grid.objid = me->event1.event.button.objid;
                win_grid.osnum = me->event1.event.button.osnum;

                status =
		  dm$get_dim_plane (	win_grid = win_grid,
					md_env = &me->md_env,
					p_grid = &me->list[DIM_ROOT_PLAN]);
                as$status();

                status =
		  dm$get_plan_info (plan_objid = me->list[DIM_ROOT_PLAN].objid,
					osnum = me->list[DIM_ROOT_PLAN].osnum,
					md_env = &me->md_env,
					plan_info = &me->plan_info);
                as$status();
              }

              status =
		BSproj1 (&rc,
                         &me->event1.event.button.x,
                         &me->plan_info.win_plan.matrix[8],
                         obj_info.lnproj,
                         out_pt);

              as$status(action = RET_STATUS);

              local_attr = &out_pt[0];

              status=
		dm$create_root( type     = DMptdist,
				count    = 1,
				list     = &obj_info.grid,
				context  = &obj_info.context,
				attr     = local_attr,
				md_env   = &lc_env,
				p_root   = &me->list[arrow_index]);
              as$status();

            } /* no_wireframe */
            else
            {
              status = om$send (msg	 = message VDCmdAnnot.create_arrow(),
                                targetid = my_id);
              as$status( action = RET_STATUS );
            }

            status = om$send (msg      = message VDCmdAnnot.place_dimension(),
                              targetid = my_id);
            as$status( action = RET_STATUS );

            if(me->an_grid.objid == NULL_OBJID)
            {
              /*
               * The balloon or the text has not been created
               */

              me->state  = WAIT_MAC;
              me->action = LOC_MAC;
              me->input_required = NOENT;

              break;
            }
            else
            {
              created_annot = TRUE;
            }

            text_flag = TEXTANGLE;
            status =
              om$send (msg      = message VDfrmtxt.VDsetAttribute(
					  &msg,
					  text_flag,
                                          (IGRchar *) &VDCmdtxldr_text_angle),
                       targetid = me->an_grid.objid,
                       targetos = me->an_grid.osnum);
            as$status(action = RET_STATUS);

            if(VDCmdtxldr_text_flag & VD_text_CAPS)
            {
              text_flag = TEXTCAPS;
              status=
                om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                         targetid = me->an_grid.objid,
                         targetos = me->an_grid.osnum);
              as$status(action = RET_STATUS);
            }
            else
            {
              text_flag = TEXTCAPS_NO;
              status=
                om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                         targetid = me->an_grid.objid,
                         targetos = me->an_grid.osnum);
              as$status(action = RET_STATUS);
            }

            if(VDCmdtxldr_text_flag & VD_text_MIRROR)
            {
              text_flag = TEXTMIRROR;
              status=
                om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                         targetid = me->an_grid.objid,
                         targetos = me->an_grid.osnum);
              as$status(action = RET_STATUS);
            }
            else
            {
              text_flag = TEXTMIRROR_NO;
              status=
                om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                         targetid = me->an_grid.objid,
                         targetos = me->an_grid.osnum);
              as$status(action = RET_STATUS);
            }

            if(VDCmdtxldr_text_flag & VD_text_REVERSE)
            {
              text_flag = TEXTREVERSE;
              status=
                om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                         targetid = me->an_grid.objid,
                         targetos = me->an_grid.osnum);
              as$status(action = RET_STATUS);
            }
            else
            {
              text_flag = TEXTREVERSE_NO;
              status=
                om$send( msg = message VDfrmtxt.VDsetAttribute(
                                          &msg,
                                          text_flag,
                                          NULL),
                         targetid = me->an_grid.objid,
                         targetos = me->an_grid.osnum);
              as$status(action = RET_STATUS);
            }

            status =
	      om$send (	msg	 = message DMannot.set_dim_state(BIT_SET,
					DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
            as$status(action = RET_STATUS);
          }
        }
        __prints( "<<< STO_LEAF and CNST_DIM");
      }
      case GET_BRK :
      {
        __DBGpr_com( " GET_BRK");
        __prints( ">>> GET_BRK");
        me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP ;
        me->input_required = POINT;
        control = me->leader ? MOVE_BREAK_PT : 0;
        if( !no_ldrline ){

          /* TR 179601582 change msg_key */
          if(me->leader)
          {
            if( Num_Bk == 0 )
            {
              Num_Bk = 1;
              msg_key = VD_P_EntBrRe;
            }
            else
              msg_key = VD_P_EntBrPt;
          }
          ex$message(msgnumb = msg_key);

          status =
	    om$send (	msg	 = message VDCmdAnnot.position_dim( msg_key,
							TRUE, NULL, NULL,
							control, NULL, NULL),
			targetid = my_id);
          if( created_annot )
          {
            me->state  = WAIT_BK1;
            me->action = ADD_BRK;
            created_annot  = FALSE;
          }
        }
        __prints( "<<< GET_BRK");
        break;
      }
      case ADD_BRK :
      {
        __DBGpr_com( " ADD_BRK");
        __prints( ">>> ADD_BRK");
        status =
	  om$send (	msg	 = message COanplace.position_dim( msg_key,
						FALSE, NULL, NULL,
						control, NULL, NULL),
			targetid = my_id);

        status =
	  om$send (	msg	 = message DMannot.ANadd_delete_vertex( &rc,
								ADD_VERTEX,
								NULL,
								&me->dyn_env),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
        as$status(action= RET_STATUS);

        status =
	  om$send (	msg	 = message DMannot.set_dim_state(BIT_SET,
					DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE),
			targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
        as$status(action = RET_STATUS);

        me->action = GET_BRK;
        me->input_required = NOENT;

        __prints( "<<< ADD_BRK");
        break;
      }
      case PLACE :
      {
        __DBGpr_com( " PLACE");
        __prints( ">>> PLACE");
        __DBGpr_int( " no_ldrline = ", no_ldrline );

        __DBGpr_str(" Format ", me->form_expr.string );
        __DBGpr_str(" Pamams ", me->form_expr.params );

        if( no_ldrline )
        {
          input_pt[0] = me->event1.event.button.x;
          input_pt[1] = me->event1.event.button.y;
          input_pt[2] = me->event1.event.button.z;

          world = 1;

          status =
	    om$send (	 msg	 = message GRgraphics.GRgetrang(&retn,
					&me->hdr_set.mod_env.md_env.matrix_type,
					 me->hdr_set.mod_env.md_env.matrix,
						&world,
						range ),
			targetid = me->hdr_set.obj_id.objid,
			targetos = me->hdr_set.obj_id.osnum );

          as$status(action = RET_STATUS);
          for( k=0 ; k<3 ; k=k+1 )
          {
            center_pt[k] = ( range[3+k] + range[k] ) / 2.0 ;
          }

          for( k=0 ; k<3 ; k=k+1 )
          {
            offset[k] = input_pt[k] - center_pt[k];
          }

          if( me->an_classid == OPP_VDfrmtxt_class_id )
          {
            box = me->an_box_type;

            ret_val = vd$place_annot( object   =  &me->hdr_set,
                                      format   = me->form_expr.string,
                                      param    = me->form_expr.params,
                                      box      = box,
                                      position = VD_ANNOT_CENTER_CENTER,
                                      offset   = offset,
                                      window   = &me->event1.event.button);
              __DBGpr_int(" ret_val = ", ret_val);
          }

        }
        else
        {
          if(me->leader)
          {
            status =
	      om$send( msg	 = message VDCmdAnnot.delete_vertex( &rc ),
			targetid = my_id );
            as$status( action=RET_STATUS );

            status =
	      om$send(	msg	 = message VDCmdAnnot.compute_dimension(),
			targetid = my_id );
            as$status( action = RET_STATUS );

            status =
	      om$send(	msg	 = message VDCmdAnnot.display_dimension( ROOT,
							DISPLAY | ADDWRNG),
			targetid = my_id);
            as$status(action = RET_STATUS);
          }
        }
        me->state = WAIT_MAC;
        me->action = LOC_MAC;
        me->input_required = NOENT;
        Num_Bk = 0;
        /* tr179602476 */
        me->MACRO_OCC.objid    = NULL_OBJID;

        __prints( "<<< PLACE");
        break;

        /* in case of no leader delete item number on move on */
      }
      case DELETE :
      {
        __DBGpr_com( " DELETE ");
        __prints( ">>> DELETE ");
        status =
	  om$send(	msg	 = message VDCmdAnnot.delete_dimension (),
			targetid = my_id);
        as$status(action = RET_STATUS);

        me->state          = WAIT_MAC;
        me->action         = LOC_MAC;
        me->input_required = NOENT;

        __prints( "<<< DELETE ");
        break;
      }
      case DIS_FOR :
      {
        __DBGpr_com( " DIS_FOR ");
        __prints( ">>> DIS_FOR ");
        status =
	  om$send (	msg	 = message VDCmdAnnot.display_form(),
			targetid = my_id);
        as$status(action = RET_STATUS);

        if     ( me->state == INITIAL  )   me->action = PRT_LD;
        else if( me->state == WAIT_MAC )   me->action = LOC_MAC;
        else if( me->state == WAIT_LEA )   me->action = LOC_LEAF;
        else if( me->state == WAIT_POSN)   me->action = NO_LEAF;
        else if( me->state == WAIT_POS ||
                 me->state == WAIT_BK1 ||
                 me->state == WAIT_BRK )   me->action = GET_BRK;
        else return OM_W_ABORT;

        me->input_required = NOENT;
        __prints( "<<< DIS_FOR ");
        break;
      }
    } /*end loop on actions */

    switch ( me->input_required  )
    {
      case PARENT :
      {
        __printf(">>>>> case PARENT token = %d, me->state = %d", `token, me->state`);
        if( me->state == WAIT_LEA )
        {
          classlist.w_count   = 1;
          classlist.w_flags   = OM_CLST_subclass;
          classlist.p_classes = class;

          class[0] = OPP_GRbspline_class_id;
        }
        else
        {
          classlist.w_count   = 3 ;
          classlist.w_flags   = OM_CLST_subclass;
          classlist.p_classes = class;

          class[0] = OPP_ACncpx_class_id;
          class[1] = OPP_GRsmhdr_class_id;
          class[2] = OPP_GRclhdr_class_id;
          class[3] = OPP_VDitbln_class_id;
        }
        __printf(">>>>> VD_DMlocate classlist.w_count = %d", `classlist.w_count`);
        __DBGpr_com( "VD_DMlocate Begin");
        status = VD_DMlocate( (IGRlong *)&me->locate_rc,
                              &me->loc_event,
                              &me->event1,
                              (IGRlong *)me->mask1,
                              (IGRlong *)me->mask2,
                              me->display_flag,
                              (IGRint *) response,
                              (IGRchar *) response_data,
                              me->locate_prompt,
                              me->acc_prompt,
                              me->relocate_prompt,
                              &me->attr,
                              &me->act_parms,
                              &me->lc_dyn,
                              &classlist );
        __DBGpr_com( "VD_DMlocate After");
        __printf("<<<<< VD_DMlocate status = %d, response = %d, me->locate_rc = %#x, LC_OBJ_LOCATED = %#x",
                 `status, *response, me->locate_rc, LC_OBJ_LOCATED`);
        if (! (status & 1) )
        {
          /*
           * Force transition to action LOC_MAC
           */
          me->input_required = NOENT;
          me->state          = WAIT_MAC;
          me->action         = LOC_MAC ;

          break;
        }

        Num_Bk = 0;

        if ( me->locate_rc == LC_OBJ_LOCATED )
        {
          for(token=0;TokenList[token] != LOC_PARENT; token++);
        }
        else if(  *response == STATUS_DISP ||
                ( *response == 23 && !strcmp( response_data, "GRStFr")))
        {
          for(token=0;TokenList[token] != STATUS_DISP; token++);
          *response = STATUS_DISP;
        }

        /*	  else if(*response == STATUS_DISP)
                  {
                  for(token=0;TokenList[token] != STATUS_DISP; token++);
                  }
        */
        else
        {
          for (token=0; TokenList[token] != *response && TokenList[token] != GR_UNKNOWN_TYPE; token++);
        }

        __DBGpr_int( "*********modify token = ",token);
        __printf("<<<<< case PARENT token = %d", `token`);
        break;
      }
      case POINT:
      {
        __prints( ">>> POINT ");
        LCdef_cursor();
        token = GRget_token(&msg,TokenList,&me->mask1,&me->event1,
                            &size, response,response_data);
        __DBGpr_int( "*********get token = ",token);
        LCrestore_cursor();

        if(*response == STATUS_DISP ||
           ( *response == 23 && !strcmp( response_data, "GRStFr")))
        {
          for(token=0;TokenList[token] != STATUS_DISP; token++);
          *response = STATUS_DISP;
        }
        __DBGpr_int( "*********modify token = ",token);

        __prints( "<<< POINT ");
        break;
      }
      case NOENT :
      {
        __prints( ">>><<< NOENT ");
        break;
      }
      default :
      {
        printf(" input_required : %d (invalid)\n", me->input_required );
        break;
      }
    }


    __DBGpr_int( "token          = ",token);
    __DBGpr_int( "response       = ",*response);
    __DBGpr_int( "input_required = ",me->input_required);
    __DBGpr_com( "--------- before new_state = ");
    __DBGpr_int( "new_state  = ",me->state);
    __DBGpr_int( "new_action = ",me->action);

    if(me->input_required != NOENT)
    {
      me->action = (IGRint) NewAction[me->state ][ token ];
      me->state  = (IGRint) NewState[ me->state ][ token ];
    }

    __DBGpr_com( "--------- after new_state = ");
    __DBGpr_int( "new_state  = ",me->state);
    __DBGpr_int( "new_action = ",me->action);

    __printf( "<<< response           = %d", `*response`);
    __printf( "<<< token              = %d", `token`);
    __printf( "<<< me->state          = %d", `me->state`);
    __printf( "<<< me->action         = %d", `me->action`);
    __printf( "<<< me->input_required = %d", `me->input_required`);

  } while(me->input_required == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

  if(*response == EX_POCKET )
  {
    *response = TERMINATE ;
  }

  if( *response == TERMINATE && me->an_grid.objid != NULL_OBJID)
  {
    status =
      om$send (	msg	 = message COanplace.delete_dimension(),
		targetid = my_id);
    as$status(action = RET_STATUS);
  }
   __DBGpr_int( " end response = ",*response);

  __exitMethod  ( name = "execute" //, argfmt = "", args = ``
  );

  End
  return OM_S_SUCCESS;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

end implementation VDCmdtxldr;
