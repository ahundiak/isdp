/*----
CHANGE HISTORY:

jla 13-jan-87   : design date
----*/

class implementation COparaext;


#include "coparadef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "ASmessages.h"
#include "msmacros.h"
#include "OMmacros.h"

#define  AS_DEBUG

from GRgraphics
import
GRconstruct,
GRdisplay;

extern GRclassid OPP_ASextseg_class_id,
		 OPP_ASmodbsp_class_id;
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             wakeup                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup ( int pos)
{

ex$message( msgnumb = AC_M_ParaExtnd);
return( OM_S_SUCCESS);
}



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
	 char *response_data;
	 int  pos)
{


#define NUM_STATES 2
#define NUM_ACTIONS 6
#define NUM_TOKENS 3


enum possible_states { 	INITIAL,
		WAIT_PT 
	     };

enum possible_actions {	NIL,
		ERR,
		LOC_SEG,
		STO_SEG,
		LOC_PT,
		MAK_SEG
	       };

static IGRint TokenList[] =
	      { 
		RESET,
		GR_UNKNOWN_TYPE ,
		LOC_PARENT
	      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ************* TOKENS *****************
Old State  *     RESET   ,  UNKNOWN  , PARENT   */

/* INITIAL   */ { INITIAL  , INITIAL   , WAIT_PT  },
/* WAIT_PT   */ { INITIAL  , WAIT_PT   , INITIAL  }};



static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            *********************** TOKENS ********************
Old State  *     RESET    ,  UNKNOWN   , PARENT   */

/* INITIAL   */ {   LOC_SEG  ,  LOC_SEG   , STO_SEG   },
/* WAIT_PT   */ {   LOC_SEG  ,  LOC_PT    , MAK_SEG   }};

struct GRvg_construct        cnst_lis;     /* construction list         */
struct GRas        		 asso_lis;     /* associative information   */
					
					
IGRlong     cnst_lis_msg;  /* return msg from cnst          */

				    
enum GRdpmode     DisplayMode;    /* display mode for display msg send */

  struct     GRid         src_grid;      /* Src object of the graphic object  */

IGRint      status;         /* routine return status */
IGRint      size;           /* size of GRevent buffer (struct GRevent) */
IGRlong     display_flag;   /* display flag for locate filter */
IGRlong     input_mask;           /* mask for GRgetevent */
IGRlong     locate_mask;    /* mask for GRgetevent */
IGRlong     msg;            /* function return code */

IGRint resp;
struct  GRevent grevent1, grevent2;     /* event returned by GRgetevent */
struct GRid               SegmentGrid;      /* grid for line segment    */
struct GRid               DisplayGrid;  /* mod_id abd space number      */
struct GRid  locate_obj;		    /* object located               */
struct GRid               context;      /* Context of the located object     */
IGRint generic = 0;                     /* type waited                  */
struct ret_struct obj_struct;
IGRint token;


*response = TERMINATE;
/*
* initialization
*/

cnst_lis.msg = &cnst_lis_msg;         /* message returned from construct*/
cnst_lis.env_info = &me->ModuleInfo; /* context returned          */
cnst_lis.display = &me->Active_display; /* constr display params*/
cnst_lis.geometry = 0;                           /* bspline geometry     */
cnst_lis.newflag = FALSE;           
cnst_lis.level = me->Active_level;           
cnst_lis.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
cnst_lis.class_attr = (IGRchar *)  &asso_lis;
cnst_lis.name = NULL;

asso_lis.parents = me->list_id;
asso_lis.go_attr = NULL;
asso_lis.as_attr = (IGRchar *) me->point;
asso_lis.context = me->context;

DisplayMode = GRbd;                        /* how to display element   */


/*
* get module id and space number.
*/
status = GRfindmod(&DisplayGrid);
if( !(status&1))
{
printf("COparaext: err: GRfindmod status = %d\n", status);
om$report_error(sts = status);
}
/*
*  Initialization for locate
*/

size = sizeof (struct GRevent);
locate_mask = GRm_DATA | GRm_STRING | GRm_RESET;
input_mask = GRm_DATA | GRm_RESET;
display_flag = ELEM_HILIGHT | ALL_WINDOWS;

/*
*  loop until exit condition occurs
*/

do
{
switch (me->action)
{       
 case NIL :
	 break;

 case ERR :
	 ex$message( msgnumb = AS_E_InvDefRest);
	 me->state = INITIAL;
	 me->action= LOC_SEG;

 case LOC_SEG :
	generic = line_generic | curve_generic | conic_generic;
	ex$message( buff = me->loc_prompt ,msgnumb = AS_P_LocObjExt);
	ex$message( buff = me->acc_prompt , 
	       msgnumb = AS_P_AccNearExt);
	break;


 case STO_SEG :

	me->list_id[0]=locate_obj;
	me->context[0]=context;
        status = as$make_source(go_grid = locate_obj,
				as_os = me->ModuleInfo.osnum,
				mod_env = &me->ModuleInfo,
                                as_grid = &src_grid);
        as$status(action = RET_STATUS);
	me->point[0]=grevent2.event.button.x;
	me->point[1]=grevent2.event.button.y;
	me->point[2]=grevent2.event.button.z;
	me->point[3]=1;/* 1 snap point */
        if(obj_struct.type & line_generic)
	     me->as_classid = OPP_ASextseg_class_id;
	else me->as_classid = OPP_ASmodbsp_class_id;

 case LOC_PT :
	generic = point_generic;
	ex$message( buff = me->loc_prompt ,
	       msgnumb = AS_P_LocPntExt);
	ex$message( buff = me->acc_prompt,msgnumb = AS_P_AccRej);
	break;



case MAK_SEG :

	/*
	 *  construct object by classid
	 */

	me->list_id[1]=locate_obj;
	me->context[1]=context;

	/* Is ther a track point */
        if(!IF_NULL_OBJID(G_active_trackpoint.objid) && ( 1 & 
            om$is_objid_valid( objid = G_active_trackpoint.objid, 
                               osnum = G_active_trackpoint.osnum )))
         {
           /* Active track point */
	   asso_lis.num_parents = 3;
	   me->list_id[2] = G_active_trackpoint;
           me->context[2].objid = NULL_OBJID;
	 }
	else
	 {
	   G_active_trackpoint.objid = NULL_OBJID;
	   asso_lis.num_parents = 2;
	 }
	
        /*| Constructing the extend segment */

	SegmentGrid.osnum = me->ModuleInfo.md_id.osnum;
	status = om$construct(osnum   = SegmentGrid.osnum,
			      classid = me->as_classid,
			      p_objid = &SegmentGrid.objid,
			      msg     =  message GRgraphics.GRconstruct(&cnst_lis));
	as$status();

	 /*
	  * Display object by object id
	  */

	status = om$send
		   (msg      = message GRgraphics.GRdisplay( &msg,
		    &me->ModuleInfo.md_env.matrix_type,
		    me->ModuleInfo.md_env.matrix,
		    &DisplayMode, &DisplayGrid),
		    targetid = SegmentGrid.objid,
		    targetos = SegmentGrid.osnum);
	as$status();

	 /* restart the command */

	generic = line_generic | curve_generic | conic_generic;
	ex$message( buff = me->loc_prompt ,msgnumb = AS_P_LocObjExt);
	ex$message( buff = me->acc_prompt , 
	       msgnumb = AS_P_AccNearExt);

	break;
	


}   /* end switch (me->state) */

token = ASget_parent (&msg,TokenList, &grevent1, &grevent2,
		&locate_mask, &input_mask, &size, &display_flag, &resp,
		response_data, me->loc_prompt,
		me->acc_prompt,me->reloc_prompt,
		&me->attr, &me->locate_stack,
		generic,&locate_obj,&context,&obj_struct);

/* new action and new state */


me->action = (IGRint) Action[   me->state ][ token ];
me->state =  (IGRint) NewState[ me->state ][ token ];

/*"token : %d \n new_action : %d \n new_state : %d \n",token,me->action,me->state*/

}  while( TokenList[token] != GR_UNKNOWN_TYPE);   /* end do */


*response = resp;
return( status);

}   /*  end execute method */

end implementation COparaext;
