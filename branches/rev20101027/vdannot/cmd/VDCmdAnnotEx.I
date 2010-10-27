/* $Id: VDCmdAnnotEx.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/cmd / VDCmdAnnotEx.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdAnnotEx.I,v $
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

/*
 * ADZ	20/11/1992
 * 
 * In case the object is an occurence of a ACheader object,
 * the returned object (leaf_id) to attach to is found from
 * ACmodel object.
 * In this case the leaf_id will be refused.
 */

class implementation VDCmdAnnot;

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


from NDnode import NDchg_state;
from DMannot import ANadd_delete_vertex,set_dim_state;
from DMsrc import DMgive_structure,DMmodify;
from DMsrc import DMdisplay_source;
from GRowner import GRget_number_components, GRget_components;

#define set_generic 0x10000000

extern GRclassid OPP_GRbspline_class_id;
extern GRclassid OPP_ACheader_class_id;

int auto_increment;
extern int current_item_number;

method execute(int *response; char *response_data; int pos)
{
long	status,msg;
int	msg_key, rc, token,control;
IGRlong	size = sizeof(struct GRevent);
struct GRid *obj;

static int TokenList[] ={  RESET          ,
                           D_RESET        ,
                           DATA           ,
                           GR_UNKNOWN_TYPE,
                           STATUS_DISP    ,
                           LOC_PARENT      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*        ******************************   TOKENS *************************
Old State *  RESET    , D_RESET ,  DATA   , GR_UNK  , FORM    , LOC_PAREN *
          *****************************************************************/

/*INITIAL */{WAIT_MAC ,INITIAL  ,WAIT_MAC ,INITIAL  ,INITIAL  , INITIAL  },
/*WAIT_MAC*/{WAIT_MAC ,WAIT_MAC ,WAIT_MAC ,WAIT_MAC ,WAIT_MAC , WAIT_LEA },
/*WAIT_LEA*/{WAIT_LEA ,WAIT_MAC ,WAIT_LEA ,WAIT_LEA ,WAIT_LEA , WAIT_BK1 },
/*WAIT_BK1*/{WAIT_LEA ,WAIT_MAC ,WAIT_BRK ,WAIT_BK1 ,WAIT_BK1 , WAIT_BK1 },
/*WAIT_BRK*/{WAIT_MAC ,WAIT_MAC ,WAIT_BRK ,WAIT_BRK ,WAIT_BRK , WAIT_BRK },
/*WAIT_POS*/{WAIT_MAC ,WAIT_MAC ,WAIT_MAC ,WAIT_POS ,WAIT_POS , WAIT_POS } };


static enum possible_actions NewAction[NUM_STATES][NUM_TOKENS] = {

/*        ******************************   TOKENS *************************
Old State *   RESET   , D_RESET ,  DATA   , GR_UNK  , FORM    , LOC_PAREN *
          *****************************************************************/

/*INITIAL */{STO_NOLD ,PRT_LD   ,STO_LD   ,PRT_LD   ,DIS_FOR  ,PRT_LD   },
/*WAIT_MAC*/{LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,LOC_MAC  ,DIS_FOR  ,STO_MAC  },
/*WAIT_LEA*/{LOC_LEAF ,LOC_MAC  ,LOC_LEAF ,LOC_LEAF ,DIS_FOR  ,STO_LEAF },
/*WAIT_BK1*/{LOC_LEAF ,LOC_MAC  ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
/*WAIT_BRK*/{PLACE    ,DELETE   ,ADD_BRK  ,GET_BRK  ,DIS_FOR  ,GET_BRK  },
/*WAIT_POS*/{DELETE   ,DELETE   ,PLACE    ,GET_BRK  ,DIS_FOR  ,GET_BRK  } };


 ex$message(msgnumb = me->rel_key, buff = me->relocate_prompt);

 /* init */
 token = control = 0;
 msg_key = VD_P_EntBrPt;

do
{
 switch( me->action)
 {
  case NIL :
    break;

  case ERR :
    me->state  = INITIAL;
    me->action = PRT_LD ;

  case PRT_LD :		/* ask if leader line or not */

    /*
     * startup option to choose for formatted text with or without
     * leader line.
     */
    me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
    me->an_grid.objid        = NULL_OBJID;
    me->hdr_set.obj_id.objid = NULL_OBJID;

    me->input_required = POINT;

    ex$message(msgnumb = VD_P_IdElNoLead);

    break;

  case STO_LD :		/* place with leader line */

    ex$putque(  msg      = &msg,
                response = response,
                byte     = &size,
                buffer   = (IGRchar *) &(me->event1.event));

  case STO_NOLD :	/* place without leader line */

    if(me->action == STO_LD) me->global_leader = TRUE;
    else 		     me->global_leader = FALSE;

  case LOC_MAC :	/* locate macro to hook leader line */

    /*
     * set masks for the macro and the wireframe object
     */
    me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;
    me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ;

    me->an_grid.objid        = NULL_OBJID;
    me->hdr_set.obj_id.objid = NULL_OBJID;

    me->input_required = PARENT;

    ex$message(msgnumb = me->loc_key, buff = me->locate_prompt);
    ex$message(msgnumb = VD_P_IdLeaf, buff = me->acc_prompt);

    break;

  case STO_MAC :

    as$start_fence(	set	= &me->loc_event.located_object[0].located_obj,
			nb_obj	= &me->count_macro,
			p_obj	= &obj,
			response = response,
			response_data = response_data );

    ASend_fence();
    if( me->count_macro < 1 ){
      /*
       * fence rejected
       */
      me->action = LOC_MAC;
      me->state  = WAIT_MAC;

      me->input_required = NOENT;
      break;
    }

    /*
     * save the macro object
     */
    me->hdr_set.obj_id  = me->loc_event.located_object[0].located_obj;
    me->hdr_set.mod_env = me->loc_event.located_object[0].module_info;

    /*
     * put the wireframe event in the queue to test accept/reject
     */
    ex$putque(  msg      = &msg,
                response = response,
                byte     = &size,
                buffer   = (IGRchar *) &(me->event1.event));

  case LOC_LEAF :

    /*
     * set masks and prompts for accept reject of the wireframe object.
     */
    if( me->action == LOC_LEAF ){
      me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP | GRm_SPECIFIED_OBJ ;
      ex$message(msgnumb = VD_P_IdLeaf, buff = me->locate_prompt );
    }
    else{
      me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP ;
      ex$message(msgnumb = VD_P_AccRej, buff = me->locate_prompt );
    }
    me->mask2 = GRm_DATA | GRm_RESET | GRm_BACK_UP ;
    ex$message(msgnumb = VD_P_AccRej, buff = me->acc_prompt );

    /*
     * locate filter 
     */
    me->input_required = PARENT;

    break;

  case STO_LEAF :

  case CNST_DIM :

    /*
     * Construct the text with balloon
     */
    me->leader = (me->global_leader && me->count_macro ==1) ? 1 : 0;
    
    status = om$send(msg = message VDCmdAnnot.create_arrow(),
		     targetid = my_id);
    as$status( action = RET_STATUS );

    status = om$send(msg = message VDCmdAnnot.place_dimension(),
		     targetid = my_id);
    as$status( action = RET_STATUS );

    if(me->an_grid.objid == NULL_OBJID){
      /*
       * The balloon or the text has not been created
       */
      me->state  = WAIT_MAC;
      me->action = LOC_MAC;
      me->input_required = NOENT;
      break;
    }

    status = om$send(msg = message DMannot.set_dim_state(BIT_SET,
                                        DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE),
                        targetid = me->an_grid.objid,
			targetos = me->an_grid.osnum);
    as$status(action = RET_STATUS);

  case GET_BRK :

    me->mask1 = GRm_DATA | GRm_RESET | GRm_BACK_UP ;
    me->input_required = POINT;

    control = me->leader ? MOVE_BREAK_PT : 0;

    if(me->leader) msg_key = VD_P_EntBrPt;
    else         { msg_key = VD_P_EntPlPt; me->state = WAIT_POS;}

    ex$message(msgnumb = msg_key);

    status = om$send(msg = message VDCmdAnnot.position_dim( msg_key,
                                                TRUE, NULL, NULL,
                                                control, NULL, NULL),
                     targetid = my_id);
    break;

  case ADD_BRK :

    status = om$send(msg = message COanplace.position_dim( msg_key,
                                                FALSE, NULL, NULL,
                                                control, NULL, NULL),
                     targetid = my_id);

    status = om$send(msg = message DMannot.ANadd_delete_vertex( &rc,
                                                                ADD_VERTEX,
                                                                NULL,
                                                                &me->dyn_env),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum);
    as$status(action= RET_STATUS);

    status = om$send(msg = message DMannot.set_dim_state(BIT_SET,
                                        DIM_IN_PLACEMENT | DIM_NEEDS_UPDATE),
                     targetid = me->an_grid.objid,
                     targetos = me->an_grid.osnum);
    as$status(action = RET_STATUS);

    me->action = GET_BRK;
    me->input_required = NOENT;

    break;

  case PLACE :

    if(me->leader){

      status = om$send(msg = message VDCmdAnnot.delete_vertex( &rc ),
                       targetid = my_id );
      as$status( action=RET_STATUS );

      status = om$send(msg = message VDCmdAnnot.compute_dimension(),
                       targetid = my_id );
      as$status( action = RET_STATUS );
     }
     else{
       /* new state */
       status = om$send(msg = message COanplace.position_dim( msg_key,
                                                FALSE, NULL, NULL,
                                                control, NULL, NULL),
                        targetid = my_id);

       /* old stat */
       status = om$send(msg = message COanplace.update_text_string(),
                        targetid = my_id );
       as$status(action = RET_STATUS);

       {
	/*
         * replace method connect_leader
         */
	int	display, project, type;
	struct IGRline boreline;
	IGRdouble point2[3], point1[3], tolerance;
	struct	dim_ret_struct dim_str;
	struct	GRid	*connect_grid,win_grid;

	/* 
         * fill the window grid from event
         */
	win_grid.objid = me->event1.event.button.objid;
	win_grid.osnum = me->event1.event.button.osnum;

	/*
         * get the tolerance band from the current window
         */
	DMget_dit_tol(&win_grid, &tolerance);
	connect_grid = &me->list[me->arrow_index];

	type = ORIG_INFO;
	status =
	om$send(msg = message DMsrc.DMgive_structure(	&rc,
							type,
							FALSE,
							&dim_str,
							&me->md_env),
		targetid = connect_grid->objid,
		targetos = connect_grid->osnum);
	as$status(action = RET_STATUS);

        /*
         * get the boreline points
         */
	status = BSproj1( &rc,
                          &me->event1.event.button.x,
                          &me->plan_info.win_plan.matrix[8],
                          dim_str.var.dm_ptdist.point,
                          point1 );
        as$status(action = RET_STATUS);

        boreline.point1 = point1;

	point2[0] = boreline.point1[0] + me->plan_info.act_plan.matrix[8];
	point2[1] = boreline.point1[1] + me->plan_info.act_plan.matrix[9];
	point2[2] = boreline.point1[2] + me->plan_info.act_plan.matrix[10];

	boreline.point2 = point2;

	/*^ 
	  printf(" src grid:%d,%d",connect_grid->objid,connect_grid->osnum);
	  printf("boreline pt1 %f, %f, %f\n",point1[0], point1[1], point1[2]);
	  printf("boreline pt2 %f, %f, %f\n",point2[0], point2[1], point2[2]);
         */

	status =
	om$send(msg = message DMsrc.DMdisplay_source(	&rc,
							&tolerance,
							&boreline,
							&display,
							&me->md_env),
		targetid = connect_grid->objid,
		targetos = connect_grid->osnum);
	as$status(action = RET_STATUS);

	project = ( display ) ? 0 : 1;

	status =
	om$send(msg = message DMsrc.DMmodify(	&rc,
						&me->md_env,
						project,
						TRUE,  /* ptdist: or FALSE */
						&boreline),
		targetid = connect_grid->objid,
		targetos = connect_grid->osnum);
	as$status(action = RET_STATUS);

       }	
       status = om$send(msg = message COanplace.compute_dimension(),
			targetid = my_id );
       as$status(action = RET_STATUS);
      }

     status = om$send(msg = message VDCmdAnnot.display_dimension( ROOT,
                                                DISPLAY | ADDWRNG),
                                        targetid = my_id);
     as$status(action = RET_STATUS);

/** */
     status = om$send( msg = message NDnode.NDchg_state (
						ND_DONT_MVRT,ND_DONT_MVRT),
                 targetid = me->an_grid.objid,
                 targetos = me->an_grid.osnum);
     as$status(action = RET_STATUS);
/*  **/

     me->state = WAIT_MAC;
     me->action = LOC_MAC;
     me->input_required = NOENT;

     break;

    /* in case of no leader delete item number on move on */ 

  case DELETE :

     status = om$send(msg = message VDCmdAnnot.delete_dimension (),
                      targetid = my_id);
     as$status(action = RET_STATUS);

     me->state = WAIT_MAC;
     me->action = LOC_MAC;
     me->input_required = NOENT;

     break;

   case DIS_FOR :

     status =
     om$send(msg = message VDCmdAnnot.display_form(),
             targetid = my_id);
     as$status(action = RET_STATUS);

     if     ( me->state == INITIAL  )   me->action = PRT_LD;
     else if( me->state == WAIT_MAC )   me->action = LOC_MAC;
     else if( me->state == WAIT_LEA )   me->action = LOC_LEAF;
     else if( me->state == WAIT_POS ||
	      me->state == WAIT_BK1 ||
	      me->state == WAIT_BRK )   me->action = GET_BRK;
     else return OM_W_ABORT;
     me->input_required = NOENT;
     break;

 } /*end loop on actions */

 switch ( me->input_required  ){

   case PARENT :

        status = DMlocate(
                &me->locate_rc,
                &me->loc_event,
                &me->event1,
                me->mask1,
                me->mask2,
                me->display_flag,
                response,
                response_data,
                me->locate_prompt,
                me->acc_prompt,
                me->relocate_prompt,
                &me->attr,
                &me->act_parms,
                &me->lc_dyn);
        as$status(action = RET_STATUS);

	if(me->locate_rc == LC_OBJ_LOCATED)
	 for(token=0;TokenList[token] != LOC_PARENT; token++);
        else if(*response == STATUS_DISP) 
	 for(token=0;TokenList[token] != STATUS_DISP; token++);
	else
  	 for (token=0; TokenList[token] != *response &&
           TokenList[token] != GR_UNKNOWN_TYPE; token++);

     break;
   
   case POINT:

     token = GRget_token(&msg,TokenList,&me->mask1,&me->event1,
                                   &size, response,response_data);

     if(*response == STATUS_DISP) 
	 for(token=0;TokenList[token] != STATUS_DISP; token++);

     break;

   case NOENT :
     break;

   default : 
	printf(" input_required : %d (invalid)\n", me->input_required );
	break;
 }


 if(me->input_required != NOENT){
   me->action = (IGRint) NewAction[me->state ][ token ];
   me->state  = (IGRint) NewState[ me->state ][ token ];
 }

 /*"token %d new_action %d new_state %d\n",token,me->action,me->state*/

} while(me->input_required == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);


 if( *response == TERMINATE && me->an_grid.objid != NULL_OBJID){
   status = om$send(msg = message COanplace.delete_dimension(),
                    targetid = my_id);
   as$status(action = RET_STATUS);
 }

 return OM_S_SUCCESS;
}

end implementation VDCmdAnnot;
