/*d-----------------------------------------------------------------------------


	Class Name:	VLplEdAtCmd

	Abstract:	Place Edge Attributes Command 

			This command looks at the surface or underlying surface
			if it's a plate to see if there aren't any edge attrib
			macros already connected via an ASindex curve or an
			ext_bound nci macro.  If there aren't any already, it
			places the ext_bound macro and the edge attribute macros

			Dec. '92 convert from LLC's PPL
			Feb. '93 add VSplates to locate mechanism
			Dec. '93 make sure edge attributes are placed on the 
				 surface of the place which has the most marks.
			Aug. '94 clean-up and change default value to R + 0.
				 ie offset at 0., due to problems with placing
				 the offset curves.

------------------------------------------------------------------------------*/

command_string	VLC_M_EDGE_ATTRIBUTES, 0, VLPlEdAt
synonym		VLC_M_Mod_ED_ATTRIBUTES, 1, VLMoEdAt
command_table	"vl.cmd"
class		VLplEdAtCmd
super_class	VLlocateCmd 
product_name	"$LOFT"
form            "VLedgeAttr.frm", 0, 2, "-1", "-1"

start_state	start

specification
#include "vledgeattr.h"

extern int VLhilitePlateAH();

instance {

/*c	Same as superclass + **/

	int	numTopMarks;
	int	numBotMarks;
 struct GRid *	topMarks;
 struct GRid *	botMarks;
 struct GRobj_env edge_attr;
        int	process_step;
        double	list_att[ATT_NB_ATT];
        double	old_list_att[ATT_NB_ATT];
        char    *list_att_txt[ATT_NB_ATT];
        char    *old_list_att_txt[ATT_NB_ATT];
        char	word[150],word1[150];
 struct GRid    old_box;
}

implementation

#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include <stdio.h>
#include "FI.h"
#include "EMSstruct.h"
#include "bserr.h"
#include "msdef.h"
#include "madef.h"
#include "maerr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "grmacros.h"
#include "dpmacros.h"
#include "growner.h"
#include "nddef.h"
#include "macro.h"
#include "asmacros.h"
#include "asbox.h"
#include "graph.h"
#include "ndmacros.h"
#include "vsplatedef.h"
#include "vsbmaxisdef.h"
#include "expmacros.h"
#include "expression.h"
#include "vsgeommacros.h"
#include "vsmiscmacros.h"
#include "EMSssprops.h"
#include "vlstructure.h"
#include "vlmark.h"
#include "vlmsg.h"
#include "vluserkey.h"
#include "ACrg_collect.h"
#include "ACattrib.h"
#include "vledgeattr.h"

%safe
static int xx=-1,yy,heig,wid,screen;
%endsafe

extern int VLhilitePlateAH();

	//local defines for default type and value of edge attributes

/********************** start DEBUGGING*********************************

#define vsDEBUG         1
#define vserrDEBUG      1

********************** end DEBUGGING*********************************/

#include "vldbgmacros.h"
#include "vledgeattr.h"

/*c	External Functions ****/
/*c defined in include files */

/*c  External Methods ****/

from  NDnode		import	NDget_objects;
from  VLmrkLine		import	WhichSide;

from  NDmacro           import  ACreturn_foot;
from  NDnode            import  ASreturn_go;
from  ci_macro          import  init;
from  NDnode            import  NDchg_state;
from  GRgraphics        import  GRchgprops;
from  NDnode            import  NDchange_connect;
from  GRgraphics        import  GRdisplay;
from ACrg_collect import AClist_attribute;
from ACrg_collect import ACadd_list_attribute;
from  ACcpx             import  find_macro;
from  ACcpx_defn        import  ACgive_name;

/*c	Extern variables ***/

/*c	threexternal vars.. ***/
extern GRclassid	OPP_nci_macro_class_id,
                        OPP_VLmrkLine_class_id,
			OPP_VSplate_class_id,
                        OPP_ACrg_collect_class_id,
                        OPP_ACpretend_class_id;

extern OM_S_CHANSELECT	AS_to_comp;
#define MY_ERROR 530
#define LOCATE_EDGE 531
#define VL_NOOBJ_SELECTED 101

/*c	Define the state transitions... *****/

state_table

#include	"vlmsg.h"
#include	"vltemplate.h"
#include	"OMerrordef.h"
#define MY_ERROR 530
#define LOCATE_EDGE 531
#define VL_NOOBJ_SELECTED 101

state start
  on CMD_TYPE = 0	state  GETPLATE 
  on CMD_TYPE = 1       state  GETEDATT

state GETPLATE
	message_key		VL_S_EDGE_ATTRIBUTES
        execute                 dis_en_able_gadgets
	prompt_key		VL_P_PLATE
	accept_key		VL_M_PLATE
	locate_eligible		"VSbooPlate,+VSimbPlate,VSmodPlate,VSplate,VSholPlate,
				 VSsplPlate,VSsrcPlate,VSsubPlate,VSvarPlate"
	locate_owner		"LC_RIGID_COMP | LC_RIGID_OWNER |
				 LC_FLEX_COMP  | LC_FLEX_OWNER  | 
				 LC_REF_OBJECTS"
	filter			locate


	on EX_OBJID or EX_DATA  do VLstoreLocate( &me->ret )
				do VLstoreResponse( &me->ret )
				do VLstoreList( &me->ret, 1, 1)
                                do DispArrowGadgets
				on RETURN_CODE=VL_NOOBJ_SELECTED do status ""
						   state start
				state modify_form

        on GR_UNKNOWN_TYPE.LOCATE_EDGE                 state locate_edge


state modify_form
   message_key		VL_S_EDGE_ATTRIBUTES
   prompt_key           VL_P_ChForm
   filter       	get_event

        on GR_UNKNOWN_TYPE.LOCATE_EDGE                 state locate_edge
        on EX_BACK_UP				       state GETPLATE

state locate_edge
	message_key		VL_S_EDGE_ATTRIBUTES
        execute                 dis_en_able_gadgets
        execute                 assign_action_handler
        prompt_key              VL_P_ED_ATT_VAL
        locate_eligible         "nci_macro"
        locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER |
                                 LC_FLEX_COMP  | LC_FLEX_OWNER  "
        filter                  locate

        on EX_OBJID or EX_DATA  do control_edge
                                 on RETURN_CODE = MY_ERROR
                                   state .
                                state modify_form1
        on EX_BACK_UP           do chg_process_step
                                state GETPLATE

state modify_form1
   message_key		VL_S_EDGE_ATTRIBUTES
   prompt_key           VL_P_ChForm
   filter       	get_event

        on GR_UNKNOWN_TYPE.LOCATE_EDGE                 state locate_edge
        on EX_BACK_UP				       state -

state GETEDATT
        message_key             VL_S_MOD_ED_ATTRIBUTES
        status_key		VL_E_Nothing
        execute			assign_action_handler
        prompt_key              VL_P_ED_ATT
        locate_eligible         "nci_macro"
        locate_owner            "LC_RIGID_COMP | LC_RIGID_OWNER |
                                 LC_FLEX_COMP  | LC_FLEX_OWNER  "
        filter                  locate

        on EX_OBJID or EX_DATA  do control_edge
                                 on RETURN_CODE = MY_ERROR
                                   state .
                                state .

at init		do	init_instance()
at wakeup 	do 	form_pos
at sleep        do      erase_hilite
at delete	do	remove_instance()

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* action defined in VLEdAtMethod.I                                         */

action save_all extern
action control_edge extern
action modify_mac extern

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

/************************

        find_dependents:  given a plate, find the number of marks, control and
                          roll lines that are attached.
*******+++++++++++++++++++++++++++++++++++++++++++++++++**********************/

action find_dependents(

struct GRid *   plate;          /*I:    id of plate/surface to interrogate */
int         *   topmarks;       /*0:    no of marks on top surface      */
int         *   botmarks        /*0:    no of marks on bottom surface   */ ) {

        IGRboolean add  = TRUE ;                /*result of make source tolist*/
        IGRint  ind     = 0,
                numSuccessors = 0;              /* number of dependents       */

        int     TypeSide;                       /* which side of plate is mark*/

        OMuword child_cl;                       /* class of plate's dependent*/

 struct GRid *  lchild  = NULL,                 /* list of dependents         */
             *  lToProcess = NULL,              /* total list to process */
                objInThisOs;

 #ifdef vsDEBUG
        IGRchar classname[80];
 #endif

 if ( !plate || !topmarks || !botmarks ) goto wrapup;

     /* navigate from located object */

 status = as$make_source( go_grid  = *plate,
                          mod_env = &me->ModuleInfo,
                          as_grid =   &objInThisOs);
 CheckRC( status, 1 ) ;

 *topmarks = *botmarks = 0;

 __DBGpr_obj( "get_objects on", *plate );
 status = om$send ( msg =  message NDnode.NDget_objects(
                                                ND_IN_BUF | ND_CHILDREN,
                                                (struct GRid *)NULL,
                                                0,
                                                &lchild,
                                                0,
                                                OM_K_MAXINT,
                                                &numSuccessors ),
                targetid        = plate->objid,
                targetos        = plate->osnum,
                senderid        = NULL_OBJID );

   __CheckRC( status, 1, "NDnode.NDget_objects fd", wrapup );
   __DBGpr_int( "fd: plateside has this many dependents", numSuccessors );

   if ( !numSuccessors || !lchild ) goto wrapup ;

                                /* copy the buffer before its reused */
   lToProcess =  _MALLOC( numSuccessors+1, struct GRid );

   for ( ind=0; ind<numSuccessors; ++ind ) {
        lToProcess[ind] = lchild[ind];
        if ( lToProcess[ind].objid == objInThisOs.objid ) add = FALSE;
   }

   if ( plate->objid != objInThisOs.objid && add ) {
                        /* make sure to check plate's marker */
        lToProcess[ind] = objInThisOs ;
        numSuccessors++ ;
   }

   for ( ind=0; ind<numSuccessors; ++ind ) {

        __DBGpr_obj( "successor", lToProcess[ind] );
        status = om$get_classid( osnum  = lToProcess[ind].osnum,
                        objid           = lToProcess[ind].objid,
                        p_classid       = &child_cl     ) ;
        __CheckRC( status, 1, "get_classid", next_child );

        #ifdef vsDEBUG
        status = om$get_classname( osnum        = lToProcess[ind].osnum,
                        objid           = lToProcess[ind].objid,
                        classname       = classname ) ;
        __CheckRC( status, 1, "get_classname", next_child );
        __DBGpr_str( "classname", classname );
        #endif

        if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id,
                                      subclassid =child_cl ) == OM_S_SUCCESS) {
                int botMarks = 0,
                    topMarks = 0;

                __DBGpr_obj( "findp pretend: recurvsive", lToProcess[ind] );

                status = om$send( msg = message VLplEdAtCmd.find_dependents(
                                        &lToProcess[ind],
                                        &topMarks,
                                        &botMarks ),
                                targetid = my_id );

                __CheckRC( status, 1, "find_dep:find_dep", wrapup );
                __DBGpr_int( "recur find_d top", topMarks );
                __DBGpr_int( "recur find_d bot", botMarks );
                *botmarks += botMarks;
                *topmarks += topMarks;

        } /* if a pretend */

        if( om$is_ancestry_valid( superclassid = OPP_VLmrkLine_class_id,
                                     subclassid   = child_cl ) == OM_S_SUCCESS){

                __DBGpr_obj( "its a mark",lToProcess[ind] );

                status= om$send ( msg = message VLmrkLine.WhichSide( &TypeSide),
                        senderid = NULL_OBJID,
                        targetid        = lToProcess[ind].objid,
                        targetos        = lToProcess[ind].osnum);

                __CheckRC( status, 1, "VLmrkLine.WhichSide", next_child );
                __DBGpr_int( "side of plate", TypeSide );

                if ( TypeSide == VS_K_baOnTopOfPlate ) {
                   int i = 0;
                        while ( me->topMarks[i].objid != NULL_OBJID ) ++i ;

                        me->topMarks[i] = lToProcess[ind];
                        ++(*topmarks);

                        if ( *topmarks >= me->numTopMarks ) {
                                __DBGpr_com( "REALLOC on topMarks" );
                                me->numTopMarks *= 2;
                                me->topMarks = (struct GRid *)
                                        om$realloc( ptr  = (char *)me->topMarks,
                                                    size = me->numTopMarks );
                        }
                        me->topMarks[i+1].objid = NULL_OBJID;
                }
                else {
                   int i = 0;
                        while ( me->botMarks[i].objid != NULL_OBJID ) ++i ;

                        __DBGpr_obj( "adding to list", lToProcess[ind] );
                        me->botMarks[i] = lToProcess[ind];
                        __DBGpr_obj( "added  to list", me->botMarks[*botmarks]);
                        ++(*botmarks);

                        if ( *botmarks >= me->numBotMarks ) {
                                __DBGpr_com( "REALLOC on botMarks" );
                                me->numBotMarks *= 2;
                                me->botMarks = (struct GRid *)
                                        om$realloc( ptr  = (char *)me->botMarks,
                                                    size = me->numBotMarks );
                        }
                        me->botMarks[i+1].objid = NULL_OBJID;
                } /* mark on bottom */

           } /* if mark */

   next_child:
        status = OM_S_SUCCESS;

   } /* for all the children */

        __DBGpr_int( "find_dep: no tops", *topmarks );
        __DBGpr_int( "find_dep: no bots", *botmarks );
        __DBGpr_int( "find_dep: no bot mark", me->numBotMarks );
        __DBGpr_int( "find_dep: no top mark", me->numTopMarks );
wrapup:

  _FREE( lToProcess );

	if ( status == OM_S_SUCCESS ) goto quit ;		// for COB
  return ( status );

} /* end find_dependents */

/*******+++++++++++++++++++++++++++++++++++++++++++++++++**********************/

action init_instance ( ) {
int	i;

#define NUMMARKS 20

  me->numTopMarks	= NUMMARKS;
  me->topMarks		= NULL;
  me->numBotMarks	= NUMMARKS;
  me->botMarks		= NULL;

  me->topMarks	= (struct GRid *)om$malloc( 
				       size = NUMMARKS * sizeof( struct GRid) );

  if ( !me->topMarks ) return OM_E_NODYNMEM;
  else			me->topMarks[0].objid = NULL_OBJID ;

  me->botMarks	= (struct GRid *)om$malloc( 
				       size = NUMMARKS * sizeof( struct GRid) );

  if ( !me->botMarks ) status = OM_E_NODYNMEM;

  else {
	me->botMarks[0].objid = NULL_OBJID ;
	status = OM_S_SUCCESS ; 
  }

  me->edge_attr.obj_id.objid = NULL_OBJID;
  for (i=0; i< ATT_NB_ATT;i++)
    me->list_att[i] = me->old_list_att[i] = 0;

  me->list_att_txt[ATT_IDX_TYPE_ANGLE] = me->word;
  me->list_att_txt[ATT_IDX_PROCESS] = &me->word[50];
  me->list_att_txt[ATT_IDX_SPEC_NB] = &me->word[100];

  me->old_list_att_txt[ATT_IDX_TYPE_ANGLE] = me->word1; 
  me->old_list_att_txt[ATT_IDX_PROCESS] = &me->word1[50];
  me->old_list_att_txt[ATT_IDX_SPEC_NB] = &me->word1[100];

  VLgetProcSpec("EdgeAttr_setup",me->forms[0].form_ptr,G_PROCESS,G_SPEC_NB);

  FIg_get_text(me->forms[0].form_ptr,G_PROCESS,
                            me->list_att_txt[ATT_IDX_PROCESS]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_PROCESS,
                         0,0,me->list_att_txt[ATT_IDX_PROCESS],0,0);

  FIg_get_text(me->forms[0].form_ptr,G_SPEC_NB,
                                     me->list_att_txt[ATT_IDX_SPEC_NB]);
  FIfld_set_default_text(me->forms[0].form_ptr,G_SPEC_NB,
                         0,0,me->list_att_txt[ATT_IDX_SPEC_NB],0,0);

  strcpy(me->list_att_txt[ATT_IDX_TYPE_ANGLE], DEFAULT_ANGLE);
  FIfld_set_default_text(me->forms[0].form_ptr,G_TYPE_ANGLE,
                         0,0,me->list_att_txt[ATT_IDX_TYPE_ANGLE],0,0);

  if (me->mytype == 0)
    me->process_step = 0;
  else {
    FIg_erase(me->forms[0].form_ptr,G_TYPE_CHAMF);
    me->process_step = 1;
  }

  if ( status == OM_S_SUCCESS ) goto quit ;		// for COB
  return status ;

}

/********+++++++++++++++++++++++++++++++++++++++++++++++++++++++++*************/

action remove_instance ( ) {

  me->numTopMarks = 0;
  me->numBotMarks = 0;

  if ( me->topMarks ) { om$dealloc(  ptr = me->topMarks ); me->topMarks = NULL;}

  if ( me->botMarks ) { om$dealloc(  ptr = me->botMarks ); me->botMarks = NULL;}

  status = OM_S_SUCCESS;
  goto quit ;			// cob overdefine

}

action assign_action_handler
{

  status = 1;
  me->action_handler = (char (*)()) VLhilitePlateAH;
  goto quit;
}

action chg_process_step
{
  status = 1;
  dp$erase_hilite( msg = &status ) ;
  FIg_enable(me->forms[0].form_ptr,G_TYPE_CHAMF);
  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);
  me->action_handler = (char (*)()) NULL;
  me->process_step = 0;
  goto quit;
}


/***************************************************************************
/*c This method returns the number of macros in macrosOcId
/*c action getChildMacro(parentId,macName,macrosOcId,numMaxMacros)
****************************************************************************/

action VLgetChldMac(
struct GRid     parentId;               /* I As source object */
char            *macName;               /* I macro name */
struct GRid     *macrosOcId;            /* Grid list allocated by caller*/
IGRint          numMaxMacros;           /* number of ID allocated */
IGRint          *numMacros              /* O number of ID found */
)
{
IGRint          i		=	0,
		numObjects	=	0,
		numMacro	=	0;

char            *theMacroName;
OMuword         ids_cl;         /* classe id of the current object*/

struct GRid     *GridBuffer,theMacroId;

status = OM_E_INVARG;

 if ( !numMacros || !macrosOcId || !macName ) goto wrapup;

 *numMacros = 0;

 status= om$send ( msg =  message NDnode.NDget_objects( ND_IN_BUF |ND_CHILDREN,
                        (struct GRid *)NULL,
                        0,
                        &GridBuffer,
                        0,
                        OM_K_MAXINT,
                        &numObjects),
		senderid	= NULL_OBJID,
                targetid        = parentId.objid,
                targetos        = parentId.osnum);

  __CheckRC( status, 1, "NDnode.NDget_objects", wrapup );
  __DBGpr_objlist( "NDget_objects", numObjects, GridBuffer );

/*
 * keep the nci_macros
 */


 while ((i<numObjects)&&( numMacro<numMaxMacros))  {
        om$get_classid( osnum           = GridBuffer[i].osnum,
                        objid           = GridBuffer[i].objid,
                        p_classid       = &ids_cl       ) ;

        if( om$is_ancestry_valid( superclassid = OPP_nci_macro_class_id ,
                                  subclassid   =ids_cl  ) ==OM_S_SUCCESS) {
                status= om$send ( msg = message ACcpx.find_macro(&theMacroId),
				senderid	= NULL_OBJID,
                        	targetid        = GridBuffer[i].objid,
                        	targetos        = GridBuffer[i].osnum);

		__CheckRC( status, 1, "ACcpx.find_macro", wrapup );

                status= om$send ( msg = message ACcpx_defn.ACgive_name(
								&theMacroName),
				senderid	= NULL_OBJID,
                        	targetid        = theMacroId.objid,
                        	targetos        = theMacroId.osnum);

		__CheckRC( status, 1, "ACcpx_defn.ACgive_name", wrapup );
		__DBGpr_str("found macro", theMacroName );
		__DBGpr_obj("id", theMacroId );
                /*
                 *keep correct nci_macro
                 */
                if (!strcmp(theMacroName,macName))      {
                        macrosOcId[numMacro].objid = GridBuffer[i].objid;
                        macrosOcId[numMacro].osnum = GridBuffer[i].osnum;
                        numMacro = numMacro + 1;
                }
        } /* end if nci_macro */
        i = i + 1;
  } /** end while **/

 *numMacros = numMacro;

wrapup:
	if ( status == OM_S_SUCCESS ) goto quit ;		// for COB
	return status;

} /*c end method getChildMacro */

action VLplEdAtCmdributes( long * ret )
{
 struct GRid		TEMP[NB_TEMPLATE],	//templates for edge/bound macro
			 base_surf,		//the surf for the edge attribs
			 EDGE_ATT,		//the edge attribute macro
			 ext_bound,		//the surface boundary macro
			boundary,		//the bound macro's footboundary
		*	list	  =	NULL;   //list of marks

 struct GRmd_env	loc_env;

 struct GRobj_env	surfObj;

 IGRint			i,			//counter
			cur_loop,
			numMacros, 
			current_obj,		//current obj being processed
			topmarks = 0,
			botmarks = 0,
			number	 = 0;

 IGRuint		objs_on_chan;		//objs on boundary channel

 IGRint			i_msg; 			//message int argument

 IGRlong		l_msg;	 

 IGRchar		bound_name[32],		//boundary foot's name
			state_ed = ND_DONT_MVRT ,
			state_ex = ND_DONT_MVRT | ND_DEL_NO_CH,
		*	name = NULL;

 IGRshort		action, 		//GRproperties
			prop, 
			matrix_type;
 IGRdouble		matrix[16];
 IGRboolean		fl_edge_loop;
 OMuword                TEMP_cl;		//classid of current object
 char			word[DI_PATH_MAX];
 char			theword[DI_PATH_MAX];
 enum    GRdpmode        dpmode=GRbd;
struct ACrg_coll 	ACrg[ATT_NB_ATT];
int			nb_edge=0,already_placed = 0;


 SetProc( VLplEdAtCmdributes ) ;	Begin

	// use COB defaults if there's a problem
 if ( ! me->Cnt1 )		goto quit ;
 else			status	=	OM_E_INVARG;  // assume failure
 
 if ( !ret ) goto wrapup;			//no argument, so leave

 *ret		= VL_S_SUCCESS;
 loc_env	= me->ModuleInfo;
 fl_edge_loop	= (IGRboolean)FALSE;

 for ( current_obj=0;current_obj<me->Cnt1;++current_obj ){
     surfObj = me->Lst1[current_obj];
     base_surf = surfObj.obj_id; 

    __DBGpr_int( "Locate returned objects",  me->Cnt1);
    __DBGpr_obj( "got object",  base_surf );


                // retrieve the support surface of the plate

     om$get_classid( osnum           = surfObj._osnum  ,
                     objid           = surfObj._objid  ,
                     p_classid       = &TEMP_cl      ) ;

   if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id,
                                  subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

        __DBGpr_obj( "got reference object before ret_go",surfObj.obj_id );

        status = om$send( msg  = message NDnode.ASreturn_go(
                                        &base_surf,
                                        &surfObj._matrix_type,
                                         surfObj._matrix ),
                        senderid = NULL_OBJID,
                        targetid = surfObj._objid,
                        targetos = surfObj._osnum );

        __CheckRC( status, 1, "PlEd:return_go", next_object );

        status = om$get_classid( osnum   = base_surf.osnum  ,
                                 objid   = base_surf.objid  ,
                                 p_classid       = &TEMP_cl      ) ;
        __CheckRC( status, 1, "PlEd:get_classid", next_object );

    }  // end if its a reference object

    if( om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id,
                                  subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

	__DBGpr_com( "It's a plate!!" );
                        /*
                         * Get side of plate with most marks.
                         */

	status = om$send( msg = message VLplEdAtCmd.find_dependents( &base_surf,
								    &topmarks,
								    &botmarks ),
			targetid = my_id );
        if (!(status&1)) {
          *ret = MY_ERROR;
          goto wrapup;
        }
	__DBGpr_int( "topmarks", topmarks );
	__DBGpr_int( "botmarks", botmarks );
	__DBGpr_int( "topMarks", me->topMarks);
	__DBGpr_int( "botMarks", me->botMarks );

	if ( topmarks > botmarks ){ 
		list	= me->topMarks;	name = VS_K_plTopSfPath;
		number	= topmarks;
	}
	else {  list	= me->botMarks;	name = VS_K_plBotSfPath;
		number	= botmarks;
	}
			
        status= om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        name,
                                        &TEMP[0],
                                        &surfObj.mod_env.md_env.matrix_type,
                                        surfObj.mod_env.md_env.matrix ),
			senderid = NULL_OBJID,
			targetid = base_surf.objid,
			targetos = base_surf.osnum ) ;

        if (!(status&l_msg&1)) {
          *ret = MY_ERROR;
          goto wrapup;
        }
       
     } // if it's a plate

     else{
                __DBGpr_com("not a Plate!");
		TEMP[0] = base_surf;
     }

   //c place look for Marks etc and place edge_att macro

     as$make_source(    go_grid = TEMP[0],
                        mod_env = &me->Loc_env.mod_env,
                        as_grid = &TEMP[0] );

//c place ext_bound macro ----------------------

  numMacros=0;
  status= om$send ( msg = message VLplEdAtCmd.VLgetChldMac( TEMP[0],
					"ext_bound",&ext_bound,1,&numMacros),
            targetid = my_id,
            mode = OM_e_wrt_message );

  if (!(status&1)) {
    *ret = MY_ERROR;
    goto wrapup;
  }

  if ( numMacros == 0 ) {
     ext_bound.objid = NULL_OBJID;
     ext_bound.osnum  = me->ModuleInfo.md_id.osnum;
     loc_env.md_id.objid     = NULL_OBJID;
     status = om$construct( classid = OPP_nci_macro_class_id,
                			msg = message ci_macro.init(&i_msg ,
                                              AChdr_nodisplay |AChdr_norange,
                                              "ext_bound",
                                              1 ,
                                              TEMP,
                                              NULL, &loc_env ),
                        p_objid = &ext_bound.objid,
                        osnum   = ext_bound.osnum);

     if (!(status&i_msg&1)) {
       *ret = MY_ERROR;
       goto wrapup;
     }

     loc_env.md_id.objid = me->ModuleInfo.md_id.objid;
   
     status = om$send( msg = message NDnode.NDchg_state
                             		    ( state_ex, state_ex ),
                      	   senderid = NULL_OBJID,
                      	   targetid = ext_bound.objid,
                       	   targetos = ext_bound.osnum );
     if (!(status&1)) {
       *ret = MY_ERROR;
       goto wrapup;
     }
   } //c if on numMacros

   TEMP[ATT_T_IDX_SURF] = TEMP[0];

// find boundary foot of ext_bound macro ----------------------

   for( cur_loop=0; ; ++cur_loop ){

        if( cur_loop == 0 )     sprintf( bound_name, "boundary" );
        else                    sprintf( bound_name, "bound%d", cur_loop+ 1 );

        boundary.objid  = NULL_OBJID;
        status = om$send(msg = message  NDmacro.ACreturn_foot(
                                                  &l_msg,
                                                  bound_name,
                                                  &boundary,
                                                  &matrix_type,
                                                  matrix ),
                       senderid     = NULL_OBJID,
                       targetid     = ext_bound.objid,
                       targetos     = ext_bound.osnum);

     if (!(status&l_msg&1)) {
       break;
     }
        if( boundary.objid == NULL_OBJID ){
		__DBGpr_com( " No more boundaries ");
		goto boundary_break;
        }
	else {
		__DBGpr_obj(" boundary ", boundary );
		__DBGpr_str(" bound_name ",bound_name );
        }
// find components of boundary contour ------------------------

        objs_on_chan =0;
        status = om$get_channel_count (osnum    = boundary.osnum,
                                   objid        = boundary.objid,
                                   p_chanselect = &AS_to_comp,
                                   count        = &objs_on_chan );
	__DBGpr_int(" objs_on_chan ", objs_on_chan );

        if( objs_on_chan == 0 ) {
		__DBGpr_int( "IN objs_on_chan == 0", objs_on_chan );
                TEMP[ATT_T_IDX_EDGE_3D]       = boundary;
                fl_edge_loop    = (IGRboolean)TRUE;
                objs_on_chan       = 1;
        }
	else
                fl_edge_loop    = (IGRboolean)FALSE;

             /* prepare ACrg collection */
        strcpy(ACrg[ATT_IDX_TYPE].name,ATT_TYPE);
        ACrg[ATT_IDX_TYPE].desc.type = AC_ATTRIB_DOUBLE;
        if (!strcmp(name,VS_K_plTopSfPath)) {
          if (me->list_att[ATT_IDX_TYPE_CHAMF] == 0)
            ACrg[ATT_IDX_TYPE].desc.value.att_exp = ATT_OFFSET_FAT;
          else
            ACrg[ATT_IDX_TYPE].desc.value.att_exp = ATT_OFFSET_THIN;
        }
        else {
          if (me->list_att[ATT_IDX_TYPE_CHAMF] == 0)
            ACrg[ATT_IDX_TYPE].desc.value.att_exp = ATT_BASE_FAT;
          else
            ACrg[ATT_IDX_TYPE].desc.value.att_exp = ATT_BASE_THIN;
        }
        VLfillACrg(ACrg,me->list_att,me->list_att_txt);

        TEMP[ATT_T_IDX_BOX].objid = NULL_OBJID;
        TEMP[ATT_T_IDX_BOX].osnum = me->ModuleInfo.md_id.osnum;
        status = om$construct(classid = OPP_ACrg_collect_class_id,
                              osnum   = TEMP[ATT_T_IDX_BOX].osnum,
                              p_objid = &TEMP[ATT_T_IDX_BOX].objid);
        if (!(status&1)) {
          *ret = MY_ERROR;
          goto wrapup;
        }
      
        om$send( msg = message NDnode.NDchg_state(ND_DEL_NO_CH, ND_DEL_NO_CH ),
                 targetid = TEMP[ATT_T_IDX_BOX].objid,
                 targetos = TEMP[ATT_T_IDX_BOX].osnum );
      
        status = om$send(msg = message ACrg_collect.ACadd_list_attribute
                         (&l_msg, ATT_NB_ATT, ACrg),
                         targetid = TEMP[ATT_T_IDX_BOX].objid,
                         targetos = TEMP[ATT_T_IDX_BOX].osnum);
        if(!(status & l_msg & 1)) {
          *ret = MY_ERROR;
          goto wrapup;
        }
                
        EDGE_ATT.osnum  = me->ModuleInfo.md_id.osnum;
        for( i=0; i<objs_on_chan; i=i+1 ){
		if( fl_edge_loop == (IGRboolean)FALSE ){
		status = om$get_objid_at_index(
                                osnum   = boundary.osnum,
                                objid   = boundary.objid,
                        p_chanselect    = &AS_to_comp,
                        index           = i,
                        objidaddr       = &TEMP[ATT_T_IDX_EDGE_3D].objid,
                        osnumaddr       = &TEMP[ATT_T_IDX_EDGE_3D].osnum );

                    if(!(status & 1)) {
                      *ret = MY_ERROR;
                      goto wrapup;
                    }

		}
		status = as$make_source( go_grid = TEMP[ATT_T_IDX_EDGE_3D],
                        		 mod_env = &me->Loc_env.mod_env,
                                	 as_grid = &TEMP[ATT_T_IDX_EDGE_3D] );

                if(!(status & 1)) {
                   *ret = MY_ERROR;
                   goto wrapup;
                }

		numMacros=0;
        	status = om$send ( msg = message VLplEdAtCmd.VLgetChldMac( 
					TEMP[ATT_T_IDX_EDGE_3D],
					"edge_att",&EDGE_ATT,1,&numMacros),
                	targetid = my_id,
                	mode	 = OM_e_wrt_message );

                if(!(status & 1)) {
                   *ret = MY_ERROR;
                   goto wrapup;
                }

                nb_edge++;

                if ( numMacros == 0 ) {
			__DBGpr_objlist( "placement T", NB_TEMPLATE, TEMP );

                  EDGE_ATT.objid  = NULL_OBJID;
                  EDGE_ATT.osnum  = loc_env.md_id.osnum;
                  status = om$construct( classid = OPP_nci_macro_class_id,
                			msg = message ci_macro.init(&i_msg,
                                                 0,
                                                 "edge_att",
                                                 NB_TEMPLATE,
                                                 TEMP,
                                                NULL,
                                                &loc_env ),
                        p_objid = &EDGE_ATT.objid,
                        osnum   = EDGE_ATT.osnum);

                if(!(status &i_msg& 1)) {
                   *ret = MY_ERROR;
                   goto wrapup;
                }

                  status = om$send(msg = message NDnode.NDchg_state
                                 		( state_ed, state_ed ),
                        	senderid = NULL_OBJID,
                        	targetid = EDGE_ATT.objid,
                        	targetos = EDGE_ATT.osnum );

                if(!(status & 1)) {
                   *ret = MY_ERROR;
                   goto wrapup;
                }
   
		  if(!(VLgetName(&(surfObj.obj_id),word)))
                    strcpy(word,"Defined");
                  sprintf(theword,"%s_%d",word,i);
                  status = om$send(msg = message VLplEdAtCmd.VLsetSymbNameDisp(
                                                &l_msg,
                                                theword,
                                                ED_ATT_3D_KEY,
                                                &(surfObj.obj_id),
                                                EDGE_ATT,
                                                &dpmode),
                        targetid = my_id );
                  if(!(status & l_msg & 1))
                    ex$message(msgnumb = VL_E_BadChgName);
		} //c if num macros is 0

		else {
                   already_placed++;
                  __DBGpr_int( "found edge_att macros", numMacros );
		}

        }//c end for edge

   }//c end for loop on boundaries

boundary_break:			////////// GOTO 

   if( ext_bound.objid != NULL_OBJID ){

        action= 0;	//c action set to clear
        prop    = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
        status  = om$send( msg = message GRgraphics.GRchgprops
                                        ( &l_msg, &action, &prop),
                        senderid = NULL_OBJID,
                        targetid = ext_bound.objid,
                        targetos = ext_bound.osnum);

         if(!(status &l_msg& 1)) {
            *ret = MY_ERROR;
            goto wrapup;
         }

   } //c if ext_bound exists

next_object:		////////////////// GOTO

	status = OM_S_SUCCESS;

 } //c end for on located objects

  nb_edge = nb_edge - already_placed;
  ex$message(msgnumb = VL_E_EdgeAttPlaced,type="%d",var=`nb_edge`);
  if (already_placed)
    ex$message(msgnumb = VL_E_EdgeAttAlDef,type="%d",var=`already_placed`);

wrapup:			////////////// cleanup GOTO

    End
    return ( status );
    
} /*c end method PlEdgAtt */

action form_notification ( int form_label ; int gadget_label ; double value ;
                           char * form_ptr )
{

  if( form_ptr == NULL ) return( OM_E_INVARG );

  FIg_set_text(form_ptr,FI_MSG_FIELD,"");

  switch (gadget_label) {
    case FI_EXECUTE :
    case FI_ACCEPT :
      status = om$send(msg = message VLplEdAtCmd.save_all(&me->ret),
                     targetid = my_id);
      if (!(status&me->ret&1)) {
          FIg_set_state_off(form_ptr,gadget_label);
          ex$message( msgnumb = VL_E_BadPlc);
          goto quit;
      }
      if (me->process_step == 0) {
        status = om$send(msg = message VLplEdAtCmd.VLplEdAtCmdributes(&me->ret),
                             targetid = my_id);
        if (!(status&me->ret&1)) {
          FIg_set_state_off(form_ptr,gadget_label);
          ex$message( msgnumb = VL_E_BadPlc);
          goto quit;
        }
        me->process_step = 1;
        FIg_disable(form_ptr,G_TYPE_CHAMF);
      }
      else {
        status = om$send(msg = message VLplEdAtCmd.modify_mac(&me->ret),
                             targetid = my_id);
        if (!(status&me->ret&1)) {
          FIg_set_state_off(form_ptr,gadget_label);
          ex$message( msgnumb = VL_E_BadPlc);
          goto quit;
        }
      }
      FIg_set_state_off(form_ptr,gadget_label);
      if ( gadget_label == FI_EXECUTE )
      {  _put_response(resp = LOCATE_EDGE); }
      else
      {  _put_response(resp = TERMINATE); }

      break;

    case FI_CANCEL :
      FIg_set_state_off(form_ptr,FI_CANCEL);
      _put_response(resp = TERMINATE);
      break;

    case FI_RESET :
      if (!me->mytype && me->process_step)
        FIg_disable(form_ptr,G_TYPE_CHAMF);
      break;
  }
}

action DispArrowGadgets
{
struct GRobj_env	surf_obj,GObj;
       int		i,dim;
       OMuword          TEMP_cl;
       long		l_msg;

  if(me->Cnt1){

  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);

   // Unhighlight old side and normal.
  dp$erase_hilite( msg = &status ) ;

  for (i=0;i<me->Cnt1;i++)
  {
    om$get_classid( osnum           = me->Lst1[i]._osnum  ,
                    objid           = me->Lst1[i]._objid  ,
                    p_classid       = &TEMP_cl      ) ;

    GObj = me->Lst1[i];
    if( om$is_ancestry_valid( superclassid = OPP_ACpretend_class_id,
                                  subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

        __DBGpr_obj( "got reference object before ret_go",
				me->Lst1[i].obj_id );

        status = om$send( msg  = message NDnode.ASreturn_go(
                                        &GObj.obj_id,
                                        &GObj._matrix_type,
                                         GObj._matrix ),
                        senderid = NULL_OBJID,
                        targetid = me->Lst1[i]._objid,
                        targetos = me->Lst1[i]._osnum );

        if (!(status&1)) continue;

        status = om$get_classid( osnum   = GObj.obj_id.osnum  ,
                                 objid   = GObj.obj_id.objid  ,
                                 p_classid   = &TEMP_cl);
    }
    if( om$is_ancestry_valid( superclassid  = OPP_VSplate_class_id,
                              subclassid    = TEMP_cl ) == OM_S_SUCCESS ) {

        __DBGpr_com( "It's a plate!!" );
        status= om$send( msg = message NDmacro.ACreturn_foot(
                                        &l_msg,
                                        VS_K_plBotSfPath,
                                        &surf_obj.obj_id,
                                        &surf_obj.mod_env.md_env.matrix_type,
                                        surf_obj.mod_env.md_env.matrix ),
                        senderid = NULL_OBJID,
                        targetid = GObj.obj_id.objid,
                        targetos = GObj.obj_id.osnum ) ;
        if (!(status&l_msg&1)) continue;
        if (GObj.mod_env.md_env.matrix_type != MAIDMX) {
          dim = 4;
          MAmulmx(&status,&dim,&dim,&dim,GObj.mod_env.md_env.matrix,
                  surf_obj.mod_env.md_env.matrix,
                  surf_obj.mod_env.md_env.matrix);
          MAtypemx( &status, surf_obj.mod_env.md_env.matrix,
                    &surf_obj.mod_env.md_env.matrix_type);
        }

    }
    else surf_obj = GObj;

    vs$bulk_display(count = 1,
                    dpmode = GRhdo,
                    objenvs = &surf_obj);

    // Display normal
    VSdisplaySurfaceNormal(&status,&surf_obj,TRUE,&me->ActiveDisplay,GRhd);
    ex$message( msgnumb = VL_E_BASE);
  }
 }
 else	*sts=VL_NOOBJ_SELECTED;

  goto quit;
}

action form_pos
{
  status = 1;
  if (xx != -1 ) {
    FIf_set_location(me->forms[0].form_ptr, xx,yy);
    FIf_set_size(me->forms[0].form_ptr, heig,wid);
    FIf_set_screen(me->forms[0].form_ptr, screen);
  }
  FIg_enable(me->forms[0].form_ptr,G_L);
  FIg_enable(me->forms[0].form_ptr,G_S);
  FIg_enable(me->forms[0].form_ptr,G_A);
  FIg_enable(me->forms[0].form_ptr,G_TYPE_ANGLE);
  FIg_enable(me->forms[0].form_ptr,G_TYPE_CHAMF);
  FIg_enable(me->forms[0].form_ptr,G_B);
  FIg_enable(me->forms[0].form_ptr,G_V);
  FIg_enable(me->forms[0].form_ptr,G_Y);
  FIg_enable(me->forms[0].form_ptr,G_X);
  FIg_enable(me->forms[0].form_ptr,G_H);
  FIg_enable(me->forms[0].form_ptr,G_C);
  FIg_enable(me->forms[0].form_ptr,G_N);
  FIg_enable(me->forms[0].form_ptr,G_T);
  FIg_enable(me->forms[0].form_ptr,G_ALLOWANCE);
  FIg_enable(me->forms[0].form_ptr,G_PROCESS);
  FIg_enable(me->forms[0].form_ptr,G_SPEC_NB);
  FIg_enable(me->forms[0].form_ptr,FI_CANCEL);
  FIg_enable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_enable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_enable(me->forms[0].form_ptr,FI_RESET);
  if (me->mytype == 0)
  {
    FIg_erase(me->forms[0].form_ptr, G_MOD_EDGE);
    FIg_display(me->forms[0].form_ptr, G_PL_EDGE);
  }
  else 
  {
    FIg_erase(me->forms[0].form_ptr, G_PL_EDGE);
    FIg_display(me->forms[0].form_ptr, G_MOD_EDGE);
  }
  goto quit;
}

action erase_hilite
{
int     loc_msg;

  status = dp$erase_hilite(msg=&loc_msg,
                           objid = me->ModuleInfo.md_id.objid,
                           osnum = me->ModuleInfo.md_id.osnum);

  FIf_get_size(me->forms[0].form_ptr,&heig,&wid);
  FIf_get_location(me->forms[0].form_ptr,&xx,&yy);
  FIf_get_screen(me->forms[0].form_ptr,&screen);
  FIg_disable(me->forms[0].form_ptr,FI_CANCEL);
  FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
  FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);
  FIg_disable(me->forms[0].form_ptr,FI_RESET);
  FIg_disable(me->forms[0].form_ptr,G_L);
  FIg_disable(me->forms[0].form_ptr,G_S);
  FIg_disable(me->forms[0].form_ptr,G_A);
  FIg_disable(me->forms[0].form_ptr,G_TYPE_ANGLE);
  FIg_disable(me->forms[0].form_ptr,G_TYPE_CHAMF);
  FIg_disable(me->forms[0].form_ptr,G_B);
  FIg_disable(me->forms[0].form_ptr,G_V);
  FIg_disable(me->forms[0].form_ptr,G_Y);
  FIg_disable(me->forms[0].form_ptr,G_X);
  FIg_disable(me->forms[0].form_ptr,G_H);
  FIg_disable(me->forms[0].form_ptr,G_C);
  FIg_disable(me->forms[0].form_ptr,G_N);
  FIg_disable(me->forms[0].form_ptr,G_T);
  FIg_disable(me->forms[0].form_ptr,G_ALLOWANCE);
  FIg_disable(me->forms[0].form_ptr,G_PROCESS);
  FIg_disable(me->forms[0].form_ptr,G_SPEC_NB);
  goto quit;
}

action dis_en_able_gadgets
{
  status = 1;
  if (!me->Cnt1) {
    FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
    FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);
    FIg_disable(me->forms[0].form_ptr,FI_RESET);
  }
  if (me->edge_attr.obj_id.objid == NULL_OBJID && me->process_step == 1) {
    FIg_disable(me->forms[0].form_ptr,FI_EXECUTE);
    FIg_disable(me->forms[0].form_ptr,FI_ACCEPT);
    FIg_disable(me->forms[0].form_ptr,FI_RESET);
  }
  goto quit;
}
/********************	end of command object 			***************/
