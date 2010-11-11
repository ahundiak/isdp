/* $Id: VDCmdDrwFri.I,v 1.2 2001/06/24 18:06:20 jayadev Exp $*/
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/cmd / VDCmdDrwFri.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDCmdDrwFri.I,v $
 *	Revision 1.2  2001/06/24 18:06:20  jayadev
 *	element locate modified
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.7  1999/12/10  15:33:44  pinnacle
# CR179900941
#
# Revision 1.6  1999/04/09  17:39:02  pinnacle
# Moved functions to imp/VDmisc.I
#
# Revision 1.5  1999/03/30  22:50:50  pinnacle
# tr179900479
#
# Revision 1.4  1999/02/12  20:03:50  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFri.I for:  by mdong for vds
#
# Revision 1.3  1998/12/03  14:26:24  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFri.I for:  by mdong for vds
#
# Revision 1.2  1998/10/23  13:33:02  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFri.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.7  1998/03/06  20:57:54  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFri.I for:  by yzhu for vds
#
# Revision 1.6  1998/01/23  21:54:16  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFri.I for:  by yzhu for vds
#
# Revision 1.5  1998/01/15  14:24:48  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFri.I for:  by yzhu for vds
#
# Revision 1.4  1998/01/07  20:52:14  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFri.I for:  by yzhu for vds
#
# Revision 1.2  1997/10/07  14:34:18  pinnacle
# Replaced: vddrawing/cmd/VDCmdDrwFri.I for:  by yzhu for vds
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
 *	09/04/97	yzhu		rewrite execute, table and 
 *					added new methods
 *      09/25/98        Ming            TR179801648
 *      11/02/98        Ming            TR179801745
 *      02/04/99	Ming            TR179801899
 *      03/30/99	ylong           TR179900479
 *      04/09/99        ah              Moved functions to ../imp/VDmisc.I
 *      12/10/99        ylong           CR179900941
 *      06/23/01        Jayadev         selection of isoframes disabled 
 * -------------------------------------------------------------------*/

class implementation VDCmdDrwFr;

#include <stdio.h>
#include <ctype.h>
#include "OMparameters.h"
#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "OMminimum.h"
#include "OMtypes.h"
#include "AS_status.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "dp.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "acdef.h"
#include "acmacros.h"
#include "coparadef.h"
#include "nddef.h"
#include "asbox.h"
#include "asdef.h"
#include "asmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "ACdb_info.h"
#include "macro.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "go.h"
#include "gomacros.h"
#include "ACcheckin.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "growner.h"
#include "SMdef.h"
#include "SMmacros.h"
#include "detaildef.h"
#include "VDmsg.h"
#include "VDobj.h"
#include "VDchn.h"
#include "v_miscmacros.h"
#include "VDCmdDrwFr.h"
#include "msdef.h"
#include "refdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "dim.h"
#include "asbox.h"
#include "FI.h"
#include "FEI.h"
#include "grimport.h"
#include "gocmacros.h"
#include "godef.h"

#include "grownmacros.h"
#include "cotxmacros.h"
#include "grownerdef.h"
#include "bsconic.h"
#include "bserr.h"
#include "bsparameters.h"
#include "grdpbmacros.h"
#include "grdpb.h"
#include "grerr.h"
#include "grgsdef.h"
#include "grmacros.h"
/*
#define   vdsDEBUG
*/
#include "v_dbgmacros.h"

from GRreffile  import GRinquireref;
from GRcontext  import GRgetinstance;
from NDnode     import 	NDget_objects, NDdrawing_copy_geom,
                   	NDdrawing_copy_attr, NDgive_structure;
from ASnode     import 	ASreturn_go;
from GRreffile  import 	GRgetenvironment;
from IGRdir     import 	translate;
from SMfrm_syst import  SMfind_inter_frame,SMfind_all_frame;
from SMframe    import  SMfind_frame_num;
from GRvg       import  GRgetname,GRdetplane;
from GRdrawview import  GRget_component_id;
from GRdrawview import  GRget_drawview_scale;
from OMObjSpace import  pass;
from GRgraphics import  GRfunction, GRdisplay, GRgetrang, GRaltconstruct;
from ACcpx      import 	find_macro;
from ACcpx_defn import 	ACgive_name;
from NDmacro    import  ACreturn_foot;
from ACncpx     import 	ACchg_STATE;
from COdim	import  notify_form;
from VDdrawing  import  VDset_DrwFrParaIns;
from GRlinear   import  GRputpolyline, GRgetpolyline;
from GRdrawview import  GRget_model_matrix;
from GRdrawview import  GRget_model_geometry;

extern OM_S_CHANSELECT AS_listeners;
extern GRclassid OPP_GRreffile_class_id,
		 OPP_GRdrawview_class_id,
		 OPP_VDdrawing_class_id,
		 OPP_GR3dlineseg_class_id,
		 OPP_GR3dpolygon_class_id,
		 OPP_GRgrset_class_id,
		 OPP_GRgencs_class_id;
extern GRclassid OPP_SMInfPlane_class_id;
extern GRclassid OPP_ACpretendin_class_id;
extern GRclassid OPP_VDcontext_class_id;
extern GRclassid OPP_GRdvattach_class_id;
extern GRclassid OPP_ACpretendin_class_id;

/* action and state table  */
#define NUM_STATES 	3
#define NUM_TOKENS 	7


long VDframeObjToDrwObj();
long VDget_drwviewId();
void VDchg_FrPs_field();

/*
 * different states and actions used in the state/action tables
*/
enum possible_states { 	WAIT_OBJ,
			WAIT_FRM,
			WAIT_DRW
		     };

enum possible_actions {	NIL,
			ERR,
			RESTART,
			LOC_OBJ,
                        FORM_DIS,
                        STO_FRM,
			STO_DRW,
			EXTRACT,
			REC_FRM
	 	       };

/* Possible entries */
enum possible_entries { PARENT,
			POINT,
			NOENT };

/* state table */

%safe
static IGRint	    VDFrameNameCase;
static IGRint	    VDFrameLabelType;
static IGRchar	    VDFrameLabelPrefix[6];
static double       VDCenterLinePosition;
static struct GRid  VDdrawview;   /* keep the drawing view id*/
static int          show_pos = 0;   /* along vertical direction */
static int          x_pos = -1,y_pos = -1;
static int          x1_pos = -1,y1_pos = -1;
static double       range_p1[] = { 0.0, 0.0, 0.0};
static double       range_p2[] = { 0.0, 0.0, 0.0};
static IGRint       TokenList[] =
                    {
			RESET,          /* =2 or EX_MOVE_ONin exdef.h */ 
   			D_RESET,	/* =5 or EX_BACH_UP in exdef.h */
                        DATA,		/* =1 or EX_DATA in exdef.h */
			EXEC,           /* =7 for execute case in exdef.h */
                        FORM_FINISHED,  /* =20 in exdef.h */
			GR_UNKNOWN_TYPE,/* = 256 in griodef */ 
			LOC_PARENT      /* = 21 */
		    };

static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {
/**********  ***************TOKENS *********************************/   
/* Old St *  * RESET , D_RESET,  DATA  , EXEC   ,FORM_F , UNKNOWN, PARENT */
/*----------------------------------------------------------------*/
/*WAIT_OBJ*/{WAIT_OBJ,WAIT_OBJ,WAIT_FRM,WAIT_FRM,WAIT_DRW,WAIT_OBJ,WAIT_FRM},
/*WAIT_FRM*/{WAIT_FRM,WAIT_FRM,WAIT_FRM,WAIT_DRW,WAIT_DRW,WAIT_FRM,WAIT_FRM},
/*WAIT_DRW*/{WAIT_DRW,WAIT_DRW,WAIT_DRW,WAIT_DRW,WAIT_DRW,WAIT_DRW,WAIT_DRW}};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
/**********  ****************** TOKENS ****************************/   
/* Old St *  *RESET  , D_RESET,  DATA  , EXEC   , FORM_F , UNKNOWN, PARENT */
/*----------------------------------------------------------------*/
/*WAIT_OBJ*/{ NIL    , NIL    , NIL    ,FORM_DIS, ERR    ,   NIL  ,FORM_DIS},
/*WAIT_FRM*/{ NIL    , NIL    , NIL    ,STO_FRM , STO_FRM,   NIL  , NIL    },
/*WAIT_DRW*/{ NIL    , NIL    , STO_DRW, NIL    , NIL    ,   NIL  ,LOC_OBJ }};
%endsafe


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method execute ( int *response;
                 char *response_data;
                 int  pos)
{
    long      		status,loc_msg; /* routine return status */
    IGRint      	event_size;     /* size of GRevent buffer */
    IGRlong     	display_flag;   /* display flag for locate filter */
    IGRlong     	input_mask;     /* mask for GRgetevent */
    IGRlong     	locate_mask;    /* mask for GRgetevent */
    struct GRevent 	grevent1, grevent2,locate_event; 
					 /* event returned by GRgetevent */
    IGRint 		resp;
    IGRint 		token = 0;
    struct GRmd_env 	ref_env;
    int 		i_fra,i_ref,i;
    extern (*AStranslate) ();
    OM_S_CLASSLIST 	ref_class_list;
    GRclassid 		ref_class[2]; 
    int 		dummy, count = 0, class_flag;
    enum GRdpmode dpmode;
    
    char 		*strchr(),*strtok(),*asstrrpbrk();
    struct GRobj_env	*drwlist;
    struct GRid		located_obj, drawview, pretendID;
    GRclassid           cid;
    struct GRmd_env     mod_env;
    struct GRid         display_info;
    struct GRmd_env     md_env;
    IGRint		size = sizeof( struct GRmd_env),
			nret,
			flag;
    IGRmatrix           matrix;
    IGRdouble		y_dir[4], y_normal[4];
    long		bs_rc;
    IGRboolean          isoFlag = FALSE;
    GRname              macName;

    SetProc( VDCmdDrwFr.execute ); Begin 
    *response = TERMINATE;
    __DBGpr_int( " init response ", *response);
    __DBGpr_me();

    event_size = sizeof (struct GRevent);
    
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP 
                  | GRm_SPECIFIED_OBJ;
    input_mask  = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP 
                  | GRm_SPECIFIED_OBJ;
    
    display_flag = ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;
    
    __DBGpr_int( " execute me->mytype ", me->mytype);
    if( !me->mytype ) { /* for Extract Drawing View */
      UI_message( "Extract Drawing Frame");
      me->attr.properties   = LC_LC_ONLY | LC_RW;
      me->attr.owner_action = LC_REF_HEADER;
      
      ref_class_list.w_count = 2;
      ref_class_list.w_flags = OM_CLST_subclass;
      ref_class_list.p_classes = ref_class;
      ref_class[0] =  OPP_GRreffile_class_id;
      ref_class[1] =  OPP_GRdrawview_class_id;
    }
    else { /* for Modify Drawing View */ 
      UI_message( "Modify Drawing Frame");
      me->attr.properties   = LC_LC_ONLY | LC_RW;
      me->attr.owner_action = LC_RIGID_COMP 
	                      | LC_RIGID_OWNER | LC_FLEX_COMP  
	                      | LC_FLEX_OWNER  | LC_REF_OBJECTS;
      ref_class_list.w_count = 2;
      ref_class_list.w_flags = OM_CLST_subclass;
      ref_class_list.p_classes = ref_class;
      ref_class[0] =  OPP_VDdrawing_class_id;
      ref_class[1] =  OPP_GRgrset_class_id;
    }
    
    __DBGpr_com("read_drawing_macro");
    /* Define drawing macro */
    status = om$send(msg = message VDm_drawing.read_drawing_macro(),
		     targetid = my_id);
    __DBGpr_com("read_drawing_macro - 11");
    
    if(!(status&1)) return OM_W_ABORT;
    		  
    /*
     *  loop until exit condition occurs
     */
    
    do
    {
      __DBGpr_me();
      switch (me->action)
      {       
	case NIL :     /*| nil */
	  break;
	  
	default :
	case ERR :    /*| err  */
	  ex$message( msgnumb = AS_E_InvDefRest);
	  
	case RESTART : /*| restart */
          __DBGpr_com( "RESTART");
	  me->state = WAIT_OBJ;
	  me->action= LOC_OBJ;
	  me->Nb_Max_Fra = 0;
	  me->Nb_Max_Ref = 0;
	  me->display_window.objid = NULL_OBJID;
	  me->first = 0;
	  
	  me->axis.nb_frame = 0;
	  
	  /* modify following by yzhu */        
	  __DBGpr_int( " command_type ", me->mytype);
	  
	  
	case LOC_OBJ: 
          __DBGpr_com( "LOC_OBJ");
	  if( me->mytype == 0 ) {
	    strcpy(me->loc_prompt,"Identify drawing attachment / Move-on");
	    strcpy(me->acc_prompt,"Accept with next attachment / Reject");
	    input_mask = GRm_DATA | GRm_RESET | 
	                 GRm_BACK_UP | GRm_SPECIFIED_OBJ ;
	    strcpy(me->attr.classes,"GRreffile");
	  }
	  else { 
	    strcpy(me->loc_prompt,"Identify drawing frames/ Move-on");
	    strcpy(me->acc_prompt,"Accept  / Reject");
	    input_mask = GRm_DATA | GRm_RESET |
	                 GRm_BACK_UP | GRm_SPECIFIED_OBJ ;
	    strcpy(me->attr.classes,"VDdrawing");
	  }
	  me->Entry_Request = PARENT;
	  break;
	  
	case FORM_DIS :  /* = 4 */ 
          __DBGpr_com( "FORM_DIS");
	  if( !me->form_displayed ) {
	    me->form_displayed = TRUE;
	    om$send(msg = message VDCmdDrwFr.display_form(),
		    targetid = my_id );
	  }
	  else {
	    resp = 0;
	    grevent1.event.button.objid = NULL_OBJID;
	  }  
	  UI_prompt( " " );
	  UI_prompt( " Enter parameters in the form " );
	  
	  me->Entry_Request = POINT;
	  input_mask = GRm_STRING | GRm_RESET ;
	  break;
	  
	case STO_FRM :   /*| sto_frame */
	  __DBGpr_com( "STO_FRM");
	  /* store systems */
	  if(me->select_axis) {
	    status = om$send(msg = message VDCmdDrwFr.store_frsys_by_axis(
	                                                    me->act_frsys),
			     targetid = my_id );
	    as$status();
	  }
	  else  {
	    status = om$send(msg = 
			    message VDCmdDrwFr.store_frsys_by_name(
				                     me->act_frsys),
                            targetid = my_id );
	    as$status();
	  }
	  
	  /* store frame */
	  if( !me->select_all ) {
	    status = om$send(msg = 
			     message VDCmdDrwFr.store_frame_by_name(
					             me->act_frname),
			     targetid = my_id );
	    as$status();
	  } 
	  else {
	    status = om$send(msg = 
			     message VDCmdDrwFr.store_frame_by_all(),
			     targetid = my_id );
	    as$status();
	  }
	  if( me->mytype == 0 ) {
	    me->action = STO_DRW;
	    me->Entry_Request = NOENT;
	  } /* if */
	  else {
	    me->action = REC_FRM;
	    me->Entry_Request = NOENT;
	  }
	  break;
	  
        case STO_DRW :   /*| sto_drawing view*/
	  __DBGpr_com( "STO_DRW");
	  if(grevent1.response != SPECIFIED_OBJ)
	  {
	    status = EXputq_front(     &loc_msg,
				       &resp,
				       (IGRlong *)&event_size,
				       (IGRchar *)&(grevent2.event));
	    
	    if(me->display_window.objid == NULL_OBJID)
	    {
	      me->display_window.objid = grevent1.event.button.objid;
	      me->display_window.osnum = grevent1.event.button.osnum;
	    }
	  }
	  
	  /* For drawing view, retrieve ref file attachment */
	  __DBGpr_obj( "me->located_obj", me->located_obj);
	  status = om$send(msg=message GRdrawview.GRget_component_id
                                                (&loc_msg,GR_DV_REFFILE,
                                                 1,&located_obj,&dummy),
                            targetid = me->located_obj.objid,
                            targetos = me->located_obj.osnum);
	  __DBGpr_obj( "located_obj", located_obj);
	  
	  // 1/23/98 me->located_obj = located_obj ;
	  
	  /* Find matrix corresponding to the attachment */
	  
	  status = om$send(msg = message GRreffile.GRgetenvironment(&loc_msg,
                                        &me->ModuleInfo,&ref_env),
                            targetid = located_obj.objid,
                            targetos = located_obj.osnum);
	  //     targetid = me->located_obj.objid,
	  //     targetos = me->located_obj.osnum);
	  
	  /* Get corresponding context */
	  
	  if(status&loc_msg&1)
	  {
            status = GRfindcontext(&loc_msg,&ref_env.md_env.matrix_type,
                                   ref_env.md_env.matrix,&ref_env.md_id.osnum,
                                   me->ref);
            if(status&loc_msg&1)
	    {
              me->Nb_Max_Ref = 1;
              me->first = 1;
	    }
            else me->Nb_Max_Ref = 0;
	  }
	  
	  
        case EXTRACT :
	  
          __DBGpr_com( "EXTRACT");
          ex$message(msgnumb = VD_S_ExtPro);
	  
	  /* TR179801745 by Ming */
	  if( !(strcmp(me->act_frpos,"CenterLine")) )
	  {
            gr$get_module_env( msg     = &loc_msg,
                               sizbuf  = &size,
                               buffer  = &md_env,
                               nret    = &nret );
	    
            flag = FALSE;
            status =
	      om$send( msg      = message GRdrawview.GRget_model_matrix(
                                                                &loc_msg,
                                                                &md_env,
                                                                flag,
                                                                matrix),
                     targetid = me->located_obj.objid,
                     targetos = me->located_obj.osnum );
            as$status(action = RET_STATUS);
	    
            y_dir[0] = 0.0;
            y_dir[1] = 100.0;
            y_dir[2] = 0.0;
            y_dir[3] = 1.0;
	    
            BSmult_mats( 4, 4, matrix, FALSE, 4, 1,
                         y_dir, FALSE, y_normal, &bs_rc );
            if( (fabs(y_normal[0]-matrix[3]) < 0.0000001) &&
                (fabs(y_normal[2]-matrix[7]) < 0.0000001) )
            {
              me->action = NIL;
              me->state  = WAIT_OBJ;
              resp = TERMINATE;
              me->Entry_Request =  NOENT;
              UI_status("Center line is not available on this drawing!");
              break;
            }
	    
            VDCenterLinePosition = matrix[7];
	  }
	  
          status = om$send(msg=message VDm_drawing.realloc_obj(me->Nb_Max_Fra),
                           targetid = my_id);
	  
          __DBGpr_int ("me->Nb_Max_Fra", me->Nb_Max_Fra);
          __DBGpr_int ("me->Nb_Max_Ref", me->Nb_Max_Ref);
          for(i_ref = 0;i_ref<me->Nb_Max_Ref;i_ref++) {
	    for(i_fra = 0, me->Nb_Max_Obj=0 ; i_fra<me->Nb_Max_Fra;i_fra++) {
	      status = as$make_source(go_grid = me->frame[i_fra],
				      context_grid = me->ref[i_ref],
				      as_os = me->ModuleInfo.md_id.osnum,
				      as_grid = me->Obj_List + me->Nb_Max_Obj);
	      if(status&1) { 
		__DBGpr_obj(" me->ref[i_ref] ", me->ref[i_ref] );
		__DBGpr_obj(" me->frame[i_fra] ", me->frame[i_fra] );
		__DBGpr_obj(" me->Obj_List ", me->Obj_List[me->Nb_Max_Obj]);
		me->Nb_Max_Obj++;
	      }
	    }
	    
	    status = om$send(msg = message VDm_drawing.extract(),
			     targetid = my_id);
          }
	  
          /* find me->drwlist from me->Obj_List */
	  status = om$vla_set_dimension(varray = me->drwlist,
                                        size = 0);
	  as$status(action = RET_STATUS);
	  
	  status = om$vla_set_dimension(varray = me->drwlist,
					size = me->Nb_Max_Obj);
	  as$status(action = RET_STATUS);
	  for( i = 0; i < me->Nb_Max_Obj; i++) {
	    me->drwlist[i].mod_env = me->ModuleInfo;
	    me->drwlist[i].obj_id = me->Obj_List[i];
	    __DBGpr_obj("me->drwlist", me->drwlist[i].obj_id);
	  }
          ex$message(msgnumb = VD_S_Done);
	  
        case REC_FRM :
	  
          __DBGpr_com( "REC_FRM");
          if( me->modify_flag ) { 
            status = om$send(msg= 
			     message VDCmdDrwFr.process_object(),
			     targetid = my_id);
          }
          if ( me->form_displayed )  { /* for EXECUTE case */
	    if ( !me->mytype ) { /* for extract drawing frame command */
	      me->action = LOC_OBJ;
	      me->state  = WAIT_OBJ;
	      me->Entry_Request = NOENT;
	    }
	    else {
	      me->action = FORM_DIS;
	      me->state  = WAIT_FRM;
	      me->Entry_Request = NOENT;
	    }
          }
          else { /* for ACCEPT case */
	    me->action = NIL;
	    me->state  = WAIT_OBJ;
	    
	    resp = TERMINATE;
	    me->Entry_Request =  NOENT;
	    
          }
          break;
	  
      }   /* end switch (me->action) */
      
      switch( me->Entry_Request)
      {
        case POINT :  /*| PROMPT */
          token = GRget_token(&status,TokenList,&input_mask,&grevent1,
                              &event_size,&resp,response_data);
	  
          __DBGpr_int( " resp in POINT ", resp );
          __DBGpr_str( " response_data in POINT ", response_data );
          __DBGpr_int( " token after POINT--0 ", token );
	  
          for (token=0; TokenList[token] != resp &&
                 TokenList[token] != GR_UNKNOWN_TYPE; token++);
	  
          if ( resp == TERMINATE ) { 
	    for (token=0; TokenList[token] != GR_UNKNOWN_TYPE; token++); 
          }
	  
          __DBGpr_int( " token after POINT--1 ", token );
	  
          break;
	  
        case PARENT :  /*| parent */
          __DBGpr_com( "PARENT" );
          status = lc$locate(rc = &loc_msg,
                             event1 = &grevent1,event2 = &grevent2,
                             event3 = &locate_event,
                             mask1 = locate_mask, mask2 = input_mask,
                             eventsize = &event_size,
                             display_flag = display_flag,
                             response = &resp,
                             response_data = response_data,
                             locate_prompt = me->loc_prompt,
                             acc_prompt = me->acc_prompt,
                             relocate_prompt = me->reloc_prompt,
                             attributes = &me->attr,
                             stack = &me->locate_stack,
                             unhilight_mode = GRhe,
                             eligible_classes = &ref_class_list);
	  
          __DBGpr_int( " resp ", resp );
	  
          if(status&1 && loc_msg == LC_OBJ_LOCATED) {
            __DBGpr_com( " locate OK" );
            for(token=0;TokenList[token]!=LOC_PARENT;token++);
	    
            me->located_obj = locate_event.located_object[0].located_obj;
	    __DBGpr_obj( " located_obj before fence", me->located_obj);
	    
            om$get_classid(       osnum = me->located_obj.osnum,
                                  objid = me->located_obj.objid,
                        	  p_classid = &cid );
	    /*
	     * checking proper input for the modify case 
	     */
	    if(me->mytype)
	    {
	      if( om$is_ancestry_valid(   subclassid = cid,
					  superclassid = OPP_GRgrset_class_id ) 
		  != OM_S_SUCCESS )
	      {
		macName[0] = '\0';
		vdobj$Get(objID = &me->located_obj, macName = macName);
		__DBGpr_str(" MACRONAME for drawing_obj ",macName);
		if(strcmp(macName,"drawing_frame"))
		{ 
		  UI_status("Invalid selection : Please select a drawing frame ");
		  return( OM_S_SUCCESS);
		}
		
		vdchn$Get2(objID  = &me->located_obj,
			   chnIDx = VDCHN_IDX_PARENT,
			   nth    = 1,
			   outID  = &pretendID );
		if(pretendID.objid != NULL_OBJID)
		{
		  isoFlag = TRUE; 
		  UI_status("Iso Frame selected : Use -> Modify Iso Frame   ");
		  return( OM_S_SUCCESS);
		}
	      }
	    }
	    
  	    if( om$is_ancestry_valid(     subclassid = cid,
					  superclassid = OPP_GRdrawview_class_id )
		== OM_S_SUCCESS  && 
		(me->line_obj.objid == NULL_OBJID ||
		 me->poly_obj.objid == NULL_OBJID) ) 
	      
            {
              /* get renge of the drawing view */
              GRrange range;
              IGRboolean world;
              struct GRid	      model_obj;
               __DBGpr_com(" Belong to GRdrawview");
   	      /* GRmd_env */
              status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",
                                &model_obj,&mod_env.md_env.matrix_type,
                                mod_env.md_env.matrix),
              targetid = me->located_obj.objid,
              targetos = me->located_obj.osnum);
   
              mod_env.md_id.objid = NULL_OBJID;
              /* get range */
              world = FALSE;
              status =
              om$send(msg = message GRgraphics.GRgetrang(&loc_msg,
                                        &mod_env.md_env.matrix_type,
                                        mod_env.md_env.matrix,
                                        &world,
                                        range),
              targetid = me->located_obj.objid,
              targetos = me->located_obj.osnum);
              as$status(action = RET_STATUS);

              __DBGpr_dbl (" range[0] ", range[0]);
              __DBGpr_dbl (" range[1] ", range[1]);
              __DBGpr_dbl (" range[2] ", range[2]);
              __DBGpr_dbl (" range[3] ", range[3]);
              __DBGpr_dbl (" range[4] ", range[4]);
              __DBGpr_dbl (" range[5] ", range[5]);
 
              /* set global */ 
              range_p1[0] = range[0];
              range_p1[1] = range[1];
              range_p1[2] = range[2];
              range_p2[0] = range[3];
              range_p2[1] = range[4];
              range_p2[2] = range[5];

	      __DBGpr_vec( "range_p1", range_p1);
	      __DBGpr_vec( "range_p2", range_p2);

              /* store drawing view id */
              VDdrawview.objid = me->located_obj.objid;
              VDdrawview.osnum = me->located_obj.osnum;
            } /* OPP_GRdrawview_class_id */ 

            class_flag = 0;

  	    if( om$is_ancestry_valid(   subclassid = cid,
                                	superclassid = OPP_GRgrset_class_id )
                == OM_S_SUCCESS ){

                __DBGpr_com(" Belong to GRgrset");

        	dpmode = GRhd ;
        	GRfindmod( &display_info );

        	status =
        	om$send(msg = message GRgraphics.GRdisplay(
                                        &loc_msg,
                                        &mod_env.md_env.matrix_type,
                                        mod_env.md_env.matrix,
                                        &dpmode,
                                        &display_info ),
                targetid = me->located_obj.objid,
                targetos = me->located_obj.osnum );

                class_flag = 1;

  	    } /* if */
  	    else if( om$is_ancestry_valid(     subclassid = cid,
                                superclassid = OPP_VDdrawing_class_id )
                == OM_S_SUCCESS ){
                __DBGpr_com(" Belong to VDdrawing");
            
                class_flag = 2;
            }

	    __DBGpr_int (" class_flag", class_flag);
            // sts = dp$erase_hilite( msg = &loc_msg);

	    /* get fence for locate object */ 
            count = 0;
            as$start_fence(set = &me->located_obj,
			   set_env = &mod_env,
			   nb_obj = &count,
			   p_obj_env = &drwlist );

            if( class_flag ) {
                /* find the frame system form the single frame */
                struct GRid inputVDdrwing;
                inputVDdrwing.objid  = drwlist[0].obj_id.objid;  
                inputVDdrwing.osnum  = drwlist[0].obj_id.osnum; 
                __DBGpr_obj( "inputVDdrwing", inputVDdrwing); 
               
                /* get drawing view */ 
                status = VDget_drwviewId( &loc_msg, inputVDdrwing, &drawview ); 
                if ( status &loc_msg & 1) {
              		VDdrawview.objid = drawview.objid;
              		VDdrawview.osnum = drawview.osnum;
                }
                status =
                om$send(msg = message VDCmdDrwFr.set_form_by_frsys_or_frame( 
				&loc_msg, inputVDdrwing, class_flag),
                                targetid = my_id);
            }
	    __DBGpr_obj( " located_obj after fence", me->located_obj);
	    __DBGpr_int( " count ", count);
         
             status = om$vla_set_dimension(varray = me->drwlist,
                                           size = 0);
             as$status(action = RET_STATUS);

             status = om$vla_set_dimension(varray = me->drwlist,
                                           size = count);
             as$status(action = RET_STATUS);
             for( i = 0; i < count; i++) {
                me->drwlist[i] = drwlist[i];
                __DBGpr_obj("me->drwlist", me->drwlist[i].obj_id);
	     }
            
             ASend_fence();	
          }
          else {
            __DBGpr_com( " locate not OK" );
            for (token=0; TokenList[token] != resp &&
                 TokenList[token] != GR_UNKNOWN_TYPE; token++);
          }
          __DBGpr_int( " token after PARENT ", token );
          break;

        case NOENT :  /*| Noent */
          __DBGpr_com( " case NOENT " );
          break;

      }/* end of switch me->Entry_Request */

      /* 
      * new action and new state 
      */
      __DBGpr_int( " token      ", token);
      __DBGpr_int( " before me->action ", me->action);
      __DBGpr_int( " before me->state  ", me->state);
	
      if(me->Entry_Request != NOENT)
      {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
      }
      __DBGpr_int( " me->action ", me->action);
      __DBGpr_int( " me->state  ", me->state);

      /* accept case */
      if( me->Entry_Request == NOENT && resp == TERMINATE ) break; 

    } while(me->Entry_Request == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

    *response = resp;
    if ( resp == FORM_FINISHED ) {
             *response = TERMINATE;
    }
      
    __DBGpr_int (" response ",*response); 

    End
    return( OM_S_SUCCESS);

}   /*  end execute method */

/************ overwire  init ************************************/
method init (int type; char *string_ptr )
{
long    status, nb_vdfrsys, i;
double  val;

  SetProc(  VDCmdDrwFr.init ); Begin

    __DBGpr_int( "my_id", my_id);

    me->axis.size_frame = 0;
    me->axis.frame = NULL;

    /* TR179801648 by Ming */
    VDCenterLinePosition  = 0.0;
    VDFrameLabelType      = 0;
    VDFrameLabelPrefix[0] = '\0';

    /* CR179900941 by ylong */
    VDFrameNameCase       = 0;

    /*
     * delete the form created by anplace.init
     */

    if(me->form){
        FIf_delete(me->form);
        me->form = NULL;
    }
    if(me->subform){
        FIf_delete(me->subform);
        me->subform = NULL;
    }

    VDdrawview.objid = NULL_OBJID;

    status =
    om$send(msg = message VDCmdDrwFr.create_form(VD_FRM_MAIN_FORM_LABEL,
                                        "VDFrmStpForm", &me->form),
            targetid = my_id);
    as$status();

    /* sub_form */
    status =
    om$send(msg = message VDCmdDrwFr.create_form(VD_FRM_SUB_FORM_LABEL,
                                        "VDsetFrmPos", &me->subform),
            targetid = my_id);
    as$status();

    me->state = WAIT_OBJ;
    me->action = RESTART;
    __DBGpr_int( "me->state", me->state);
    __DBGpr_int( "me->action", me->action);

    /* init instance */
    me->select_axis = 0;    /* default to select frame system */
    me->select_all = 1;    /* default to select all frames in a frame system */

    me->form_displayed = FALSE;;
    me->act_frsys[0] = '\0';
    me->act_frname[0] = '\0';
    me->act_frpos[0] = '\0';
    me->act_txpos[0] = '\0';
    me->act_printe = 0;
    me->act_prfact[0] = '\0';
    me->act_txinte = 0;
    me->modify_flag = 0;
 
    me->line_obj.objid = NULL_OBJID;

    me->poly_obj.objid = NULL_OBJID;

    /* get list of the frame system name in the design file */
    status =
    om$send(msg = message VDCmdDrwFr.get_frsys_list(),
            targetid = my_id);
    as$status();


    /* init VD_DrwFr_FrSy_tg as Frame system */
    FIg_set_state( me->form, VD_DrwFr_FrSy_tg, FALSE );

    /* set list VD_DrwFr_FrSy_fd */
    FIfld_set_list_num_rows( me->form, VD_DrwFr_FrSy_fd, 0, 0 );
    nb_vdfrsys = om$dimension_of(varray = me->vdfrsys);
    for( i=0; i<nb_vdfrsys; i++){
      FIfld_set_list_default_text( me->form, VD_DrwFr_FrSy_fd, i, 0,
                        me->vdfrsys[i].name, FALSE);
    }

    /* set list VD_DrwFr_TxIn_fd */
    FIfld_set_list_num_rows( me->form, VD_DrwFr_TxIn_fd, 0, 2 );
    FIfld_set_list_default_text( me->form, VD_DrwFr_TxIn_fd, 0, 0,
                        "1", FALSE);
    FIfld_set_list_default_text( me->form, VD_DrwFr_TxIn_fd, 1, 0,
                        "2", FALSE);
    val = 1;
    FIg_set_value( me->form, VD_DrwFr_TxIn_fd, val );

    /* set check box */
    if( show_pos ) { 
       FIg_set_value( me->form, VD_DrwFr_ShCk_Vert, 1.0 );
       FIg_set_value( me->form, VD_DrwFr_ShCk_Hori, 0.0 );
    }
    else {
       FIg_set_value( me->form, VD_DrwFr_ShCk_Vert, 0.0 );
       FIg_set_value( me->form, VD_DrwFr_ShCk_Hori, 1.0 );
    }

  End 
  return om$send(msg = message VDm_drawing.init(type,string_ptr),
                targetid = my_id,
                mode = OM_e_wrt_message);
}
/*****************DELETE****************************************/
method delete(int n)
{
  long 	status;

  SetProc(  VDCmdDrwFr.delete ); Begin
  if(me->axis.frame) om$dealloc(ptr = me->axis.frame);

  /* save form position */
  status = om$send(msg = message VDCmdDrwFr.save_form_pos(),
                  targetid = my_id);
  

  if(me->form){
        FIf_delete(me->form);
        me->form = NULL;
  }

  if(me->subform){
        FIf_delete(me->subform);
        me->form = NULL;
  }
  /* delete range object */

  if(  me->line_obj.objid != NULL_OBJID ){ /* not display text */
                                gr$display_object(
                                        object_id = &me->line_obj,
                                        mode = GRbeheo );
                                status =
                                om$send(msg = message Root.delete( 1 ),
                                        targetid = me->line_obj.objid,
                                        targetos = me->line_obj.osnum);
                                me->line_obj.objid = NULL_OBJID ;
  }
 
  if(  me->poly_obj.objid != NULL_OBJID ){ /* not display text */
                                gr$display_object(
                                        object_id = &me->poly_obj.objid,
                                        mode = GRbeheo );
                                status =
                                om$send(msg = message Root.delete( 1 ),
                                        targetid = me->poly_obj.objid,
                                        targetos = me->poly_obj.osnum);
                                me->poly_obj.objid = NULL_OBJID ;
  }

  End
  return   om$send(msg = message VDm_drawing.delete(n),
                  targetid = my_id,
                  mode = OM_e_wrt_message);
}

/*********************wakeup********************************/
method wakeup ( IGRint n )
{
 int status;

 SetProc(  VDCmdDrwFr.wakeup ); Begin
 status = om$send(msg = message COpara.wakeup(n),
                  targetid = my_id,
                  mode = OM_e_wrt_message);

 ex$message(msgnumb = VD_M_ExDrFr);

 /* set form position */
 status = om$send(msg = message VDCmdDrwFr.set_form_pos(),
                  targetid = my_id);
  

 End
 return (status);
}


/***********************************************************************/
method process_object()
{
int			ind;
struct GRid             par_obj;
GRclassid             	cid;
int                     chan_size;
OMuint                  nblist;
extern int              GRfindmod();
OM_S_OBJECT_LINKAGE     slist[10];
long                  	msg;
int                   	sts, count;
int                   	fr_number;
GRname			buffer;
struct VDdrwFrmPar      drwFrmPar;

  SetProc( process_object ); Begin

  count = om$dimension_of(varray = me->drwlist);

  __DBGpr_int( " count ", count );
  for ( ind = 0; ind < count; ind = ind + 1 )
  {
    __DBGpr_obj( "me->drwlist[ind].obj_id", me->drwlist[ind].obj_id);
    sts = om$get_classid(osnum     = me->drwlist[ind].obj_id.osnum,
                         objid     = me->drwlist[ind].obj_id.objid,
                         p_classid = &cid );

    if( om$is_ancestry_valid( subclassid   = cid,
                              superclassid = OPP_VDdrawing_class_id )
                != OM_S_SUCCESS ) {

        me->drwlist[ind].obj_id.objid = NULL_OBJID ;
        continue;
    }

    __DBGpr_obj(" me->drwlist[ind].obj_id", me->drwlist[ind].obj_id);

    chan_size = 10;

    sts =
    om$get_channel_objects(
                objid           = me->drwlist[ind].obj_id.objid,
                osnum           = me->drwlist[ind].obj_id.osnum,
                p_chanselect    = &ND_father,
                list            = slist,
                size            = chan_size ,
                count           = &nblist );
    if( (!(sts&1)) || ( nblist == 0 ) ){
        me->drwlist[ind].obj_id.objid = NULL_OBJID ;
        continue;
    }

    __DBGpr_int(" slist[0].S_objid ", slist[0].S_objid);
    __DBGpr_int(" slist[0].osnum ", slist[0].osnum);

    sts =
    om$send(msg = message NDmacro.ACreturn_foot(&msg,"", &par_obj, NULL, NULL ),
            targetid = slist[0].S_objid,
            targetos = slist[0].osnum );

    __DBGpr_obj(" par_obj ", par_obj);

    sts =
    om$get_classid(osnum   = par_obj.osnum,
                 objid     = par_obj.objid,
                 p_classid = &cid );

    if( om$is_ancestry_valid( subclassid   = cid,
                              superclassid = OPP_SMframe_class_id )
                != OM_S_SUCCESS ) {

        me->drwlist[ind].obj_id.objid = NULL_OBJID ;
        continue;
    }

    sts =
    om$send(msg = message SMframe.SMfind_frame_num( &msg, &fr_number),
           targetid = par_obj.objid,
           targetos = par_obj.osnum );

    if( !( sts & msg & 1)){
        me->drwlist[ind].obj_id.objid = NULL_OBJID ;
        continue ;
        /* goto get_occurence; */
    }

    sprintf( buffer, "Processing Drawing Frame : %d\n", fr_number );
    UI_status( buffer );

    __DBGpr_int("Processing Drawing Frame Number", fr_number );


    /* change STATE 
    sts = om$send(msg=message VDCmdDrwFr.recompute_STATE(fr_number,ind),
                           targetid = my_id);
    */
    /* set drawing frame parameters */
    sts = 
    om$send(msg=message VDCmdDrwFr.VDset_drwFramePara(fr_number, &drwFrmPar ),
                           targetid = my_id);

    sts = om$send(msg = message VDdrawing.VDset_DrwFrParaIns( &msg, drwFrmPar),
            targetid = me->drwlist[ind].obj_id.objid,
            targetos = me->drwlist[ind].obj_id.osnum );

    /* recomputer */
    sts = om$send(msg=message VDCmdDrwFr.recompute_object(ind ),
                           targetid = my_id);
  } /* for */
  End
  return( OM_S_SUCCESS);
} /* process_object */ 
/***********************************************************************/
method VDset_drwFramePara(int fr_number;struct VDdrwFrmPar *drwFrmPar)
{

  int		status;
  long 		msg;
  double 	temp_double;

  SetProc( VDset_drwFramePara ); Begin

  if( !strcmp ( me->act_prfact, "Cross view"))
       drwFrmPar->prfact = -1;          /* primary factor */
  else 
       drwFrmPar->prfact = atoi(me->act_prfact);          /* primary factor */
  status = VDstrToVal(&msg, me->act_frpos, &temp_double);
  drwFrmPar->frpos = temp_double ;             /* frame position */
  status = VDstrToVal(&msg, me->act_txpos, &temp_double);
  drwFrmPar->txpos = (int) temp_double;        /* text position */
   
  drwFrmPar->symb_flag = me->symb_flag;        /* symb flag */
 
  strcpy ( drwFrmPar->frname, me->act_frname);
  strcpy ( drwFrmPar->frsys, me->act_frsys);

/*
  drwFrmPar->range_p1[0]  = me->range_p1[0];
  drwFrmPar->range_p1[1]  = me->range_p1[1];
  drwFrmPar->range_p1[2]  = me->range_p1[2];
  drwFrmPar->range_p2[0]  = me->range_p2[0];
  drwFrmPar->range_p2[1]  = me->range_p2[1];
  drwFrmPar->range_p2[2]  = me->range_p2[2];
*/
  drwFrmPar->range_p1[0]  = range_p1[0];
  drwFrmPar->range_p1[1]  = range_p1[1];
  drwFrmPar->range_p1[2]  = range_p1[2];
  drwFrmPar->range_p2[0]  = range_p2[0];
  drwFrmPar->range_p2[1]  = range_p2[1];
  drwFrmPar->range_p2[2]  = range_p2[2];

  if( me->modify_flag == 1) 
	drwFrmPar->md_flag = 1; 
  else 
	drwFrmPar->md_flag = 0; 

  __DBGpr_int( "fr_number", fr_number);
  __DBGpr_int( "prfact", drwFrmPar->prfact);
  __DBGpr_dbl( "frpos ", drwFrmPar->frpos);
  __DBGpr_int( "txpos ", drwFrmPar->txpos);
  __DBGpr_int( "md_flag", drwFrmPar->md_flag);
  __DBGpr_int( "symb_flag", drwFrmPar->symb_flag);
  __DBGpr_vec( "range_p1", drwFrmPar->range_p1);
  __DBGpr_vec( "range_p2", drwFrmPar->range_p2);
  __DBGpr_int( "act_printe", me->act_printe);
  __DBGpr_int( "act_txinte", me->act_txinte);
  __DBGpr_str( "act_frname", drwFrmPar->frname);
  __DBGpr_str( "act_frsys", drwFrmPar->frsys);

  drwFrmPar->tx_flag = 1; /* init with text */
  drwFrmPar->pr_flag = 1; /* init as primary line */

  if( me->act_printe != 0 && (fr_number % me->act_printe) != 0 ){
        drwFrmPar->tx_flag = 0; /* without text */
        drwFrmPar->pr_flag = 0; /* init as primary line */
  }

  __DBGpr_int( "act_txinte", me->act_txinte);

  /* just if it is without text */
  if(  me->act_txinte != 0 && (fr_number % me->act_txinte) != 0) {
        drwFrmPar->tx_flag = 0; /* without text */
        __DBGpr_com( "Not integel times of act_txinte");
  }

  __DBGpr_int( "final tx_flag", drwFrmPar->tx_flag);
  __DBGpr_int( "final pr_flag", drwFrmPar->pr_flag);

  /* TR179801648 by Ming */
  drwFrmPar->labelText  = VDFrameLabelType;
  strcpy( drwFrmPar->prefix, VDFrameLabelPrefix );
  /* TR179801899 by Ming */
  drwFrmPar->iso_flag = FALSE;

  /* CR179900941 by ylong */
  drwFrmPar->nameCase = VDFrameNameCase ;

  End
  return( OM_S_SUCCESS);
} /* VDset_drwFramePara */


/***********************************************************************/
method recompute_object(int index)
{
int             cn_type, wait_batch;

  SetProc( recompute_object ); Begin

  /*
   * recompute the object.
   */

  __DBGpr_int( "index", index);

  cn_type    = ND_COMP; /* recompute the object */

  /* set  NDmodif_flag and NDmodif */
  nd$wait_batch(type       = GR_GEOM_POSTED,
                l_object   = &me->drwlist[index].obj_id,
                l_obj_info = &cn_type,
                nb_obj     = 1 );

  __DBGpr_com( "after wait_batch");

  /* get active mode */
  nd$mod_batch(request    = ND_INQ,
                p_ret_mode = &wait_batch);

  __DBGpr_int( "after mod_batch : wait_batch", wait_batch);

  nd$exec_batch(      mode            = ND_DISP_ROOT|ND_DISP_BODY,
                      defer_flag      = ND_IMMEDIATE );

  __DBGpr_com( "after exec_batch");

  End
  return( OM_S_SUCCESS);
}

/***********************************************************************/
method store_frsys_by_axis(char *input_text)
{
int 		nb_ref, i_ref;
GRspacenum 	ref[20];
OM_S_CLASSLIST  clist;
int 		SMframe_axis();
struct          GRfunction_info f_info;
OM_S_OBJID 	ref_obj;
OMuword         sel_class[2];
IGRlong		status, loc_msg;

   SetProc( store_frsys_by_axis ); Begin
   
   status =  OM_S_SUCCESS;
   if(strcmp(input_text,"x") == 0 ||
      strcmp(input_text,"y") == 0 ||
      strcmp(input_text,"z") == 0)
   { /* Select byaxis */ 

     /* Get the possible plane by passing the OS */

     go$build_user_function_buffer(buffer    = &f_info,
                                   your_info = &me->axis);
     clist.w_count   = 2;
     clist.w_flags   = OM_CLST_subclass;
     sel_class[0] = OPP_nci_macro_class_id;
     sel_class[1] = OPP_SMInfPlane_class_id;
     clist.p_classes = sel_class;

     me->axis.axis = input_text[0] - 'x'; 
     me->axis.md_env = me->ModuleInfo;

     VDfind_ref_files(ref,20,&nb_ref);
     for(i_ref=0;i_ref<nb_ref;i_ref++) {
	om$osnum_to_oso_objid(osnum = ref[i_ref],p_objid = &ref_obj);
        status = om$send(msg = message OMObjSpace.pass(&clist,OM_e_wrt_object,
                         message GRgraphics.GRfunction(&loc_msg,SMframe_axis,
                                                       (char *) &f_info)),
                         senderid = NULL_OBJID,
                         targetid = ref_obj,
                         targetos = ref[i_ref]);
        as$status();
     }
     SMframe_order(&me->axis);
     me->fr_system.objid = NULL_OBJID;
   }  
   End
   return status;
} /* store_frsys_by_axis */ 

/***********************************************************************/
method get_frsys_list ()
{
struct SMObjList        list;
IGRchar                 name_fr_syst[DI_PATH_MAX],s_name[DI_PATH_MAX];
long                    status,loc_msg; /* routine return status */
int                     i_obj, ii;
int			previous_size;

   SetProc( get_frsys_list ); Begin
   status = om$vla_set_dimension(varray = me->vdfrsys,
                               size = 0);
   as$status(action = RET_STATUS);

   /* Select all frame system */
   list.nb_objects = 0;
   list.list = NULL;
   status = SM$CritSel( msg = &loc_msg,
                        type = SM_FRM,
                        options = SM_REF_FILE,
                        list = &list);

   if(status & loc_msg & 1) {
     __DBGpr_int( "list.nb_objects", list.nb_objects);
     ii = 0;
     for(i_obj=0;i_obj<list.nb_objects;i_obj++) {
       status = om$send(msg = message GRvg.GRgetname (&loc_msg,name_fr_syst),
                        targetid = list.list[i_obj].obj_id.objid,
                        targetos = list.list[i_obj].obj_id.osnum);
       if(status & loc_msg & 1) {
         previous_size = om$dimension_of(varray = me->vdfrsys);
         status = om$vla_set_dimension(varray = me->vdfrsys,
                                 size = previous_size + 1);
         as$status(action = RET_STATUS);
         di$split(pathname = name_fr_syst,name = s_name);
         strcpy(me->vdfrsys[ii].name,s_name); 
         me->vdfrsys[ii].grid = list.list[i_obj].obj_id;
         __DBGpr_str( "frame system name", me->vdfrsys[ii].name);
         __DBGpr_obj( "frame system obj", me->vdfrsys[ii].grid);
         ii = ii + 1;
       }
     }
   }

   if(list.nb_objects > 0 && list.list != NULL) free(list.list);
   End
   return status;
} /* get_frsys_list */
/***********************************************************************/
method store_frsys_by_name ( char *input_text)
{
long                    status; /* routine return status */
int			i_obj = 0, nb_frsys=0;

   SetProc( store_frsys_by_name ); Begin

   status = OM_S_SUCCESS; 

   __DBGpr_str( "input_text", input_text);

   nb_frsys = om$dimension_of(varray = me->vdfrsys);

   for(i_obj=0;i_obj<nb_frsys;i_obj++) {
         if(strcmp(me->vdfrsys[i_obj].name,input_text) == 0) {
           me->fr_system.objid = me->vdfrsys[i_obj].grid.objid;
           me->fr_system.osnum = me->vdfrsys[i_obj].grid.osnum;
           break;
         }
   }
     
   if(i_obj >= nb_frsys) {
       status = OM_W_ABORT; 
       UI_status("Frame system not found");
       me->state = WAIT_OBJ;
       me->action= LOC_OBJ;
       me->Entry_Request = NOENT;
   }
   else
    	__DBGpr_obj( "me->fr_system", me->fr_system);

   End
   return status;
} /* store_frsys_by_name */

/***********************************************************************/
method store_frame_by_name (char *response_data )
{
char                *c,*c1,*c2,*strchr(),*strtok(),*asstrrpbrk();
long                status,loc_msg; /* routine return status */
int                 ifr = 0,ifr1;
struct GRid 	    located_obj;	
int                 loop,i;

   SetProc( store_frame_by_name ); Begin
          __DBGpr_str( "input frame name", response_data );
          /*
           * Define first if - is inbeded in name or is a separator
           * Insert blank between  frame name and - separator
          */
          c = response_data;
          while(1) {
            c1 = strchr(c,'-');
            if(!c1) break;
            if     (*(c1-1) == ' ') {asstrinsert(c1+1," "); c = c1+2;}
            else if(*(c1+1) == ' ') {asstrinsert(c1-1," "); c = c1+2;}
            else {
              c2 = asstrrpbrk(response_data,c1-1," ,");
              if(!c2) c2 = response_data;
              *c1 = '\0';
              if(me->fr_system.objid != NULL_OBJID) {
                status=om$send ( msg = message IGRdir.translate((int *)&loc_msg,
                                                c2,0,NULL,&located_obj.objid),
                     targetid = me->fr_system.objid,
                     targetos = me->fr_system.osnum );
                located_obj.osnum = me->fr_system.osnum;   
                // 1/23/98me->located_obj = located_obj;
              }
              else {
                status = loc_msg = 0;
                for(i=0;i<me->axis.nb_frame;i++)
                 {if(strcmp(me->axis.frame[i].name,c2) == 0)
                   {status=loc_msg=1;break;}
                 }

              }
              if(status&loc_msg&1) {
                *c1 = ' ';
                asstrinsert(c1+1,"- ");
                c = c1+3;
              }
              else {
                *c1 = '-';
                c = c1+1;
              }
             }
          }  /* while */

          /* find the me->drwlist */
          status = 
	  om$send(msg = message VDCmdDrwFr.get_VDdrawing_by_frame_name(
						&loc_msg, response_data), 
                                   targetid = my_id);
          as$status(action = RET_STATUS);

          /* Now get the list of located frame */
          c = strtok(response_data," ,");
          loop = 0;
          while(c) {
            if(!strcmp(c,"-"))
             {
               loop = 1;
               c = strtok(NULL," ,");
               continue;
             }

            if(me->fr_system.objid != NULL_OBJID) {
              status = om$send ( msg = message IGRdir.translate
                              ((int *)&loc_msg,c,0,NULL,&located_obj.objid),
                              targetid = me->fr_system.objid,
                              targetos = me->fr_system.osnum );
              located_obj.osnum = me->fr_system.osnum;
            }
            else {
              status = loc_msg = 0;
              for(ifr=0;ifr<me->axis.nb_frame;ifr++)
                {if(strcmp(me->axis.frame[ifr].name,c) == 0)
                   {status=loc_msg=1;
                    located_obj=me->axis.frame[ifr].obj;
                    break;}
                }
            }
            // 1/23/98 me->located_obj = located_obj;
            __DBGpr_obj( "me->located_obj", me->located_obj);

            if(status&loc_msg&1) {
              int lowest,prec_num,highest,cur_num,nb_elem;

              if(loop && me->Nb_Max_Fra >0)
                {
                if(me->fr_system.objid != NULL_OBJID) {

                  status = om$send(msg = message SMframe.SMfind_frame_num
                               (&loc_msg,&prec_num),
                               targetid = me->frame[me->Nb_Max_Fra-1].objid,
                               targetos = me->frame[me->Nb_Max_Fra-1].osnum);

                  if(!(status & loc_msg & 1)) {
			printf("Erreur get frame number\n"); 
			return OM_W_ABORT;
                  }

                  status = om$send(msg = message SMframe.SMfind_frame_num
                                   (&loc_msg,&cur_num),
                                   targetid = located_obj.objid,
                                   targetos = located_obj.osnum);
                  if(!(status & loc_msg & 1)) {
			printf("Erreur get frame number\n"); 
			return OM_W_ABORT;
		  }

                  if(prec_num <= cur_num)
                   {lowest = prec_num; highest = cur_num;}
                  else
                   {lowest = cur_num; highest = prec_num;}

                  status = om$send(msg = message VDCmdDrwFr.realloc_frame
                                   (me->Nb_Max_Fra + highest - lowest + 1),
                                   targetid = my_id);
                  as$status(action = RET_STATUS);

                  status = om$send(msg = message SMfrm_syst.SMfind_inter_frame
                                   (&loc_msg,&lowest,&highest,
                                    me->frame + me->Nb_Max_Fra,&nb_elem),
                                   targetid = me->fr_system.objid,
                                   targetos = me->fr_system.osnum);

                  if(!(status & loc_msg & 1)) {
			printf("Erreur get intermediate frame\n");
			return OM_W_ABORT;
		  }
                  else
                    me->Nb_Max_Fra += nb_elem;
                } 
                else {
                  if(ifr < me->last_ifr)
                   {lowest = ifr; highest = me->last_ifr-1;}
                  else
                   {lowest = me->last_ifr+1; highest = ifr;}

                  status = om$send(msg = message VDCmdDrwFr.realloc_frame
                                   (me->Nb_Max_Fra+highest-lowest+1),
                                   targetid = my_id);
                  as$status(action = RET_STATUS);
                  for(ifr1 = lowest;ifr1<highest;ifr1++)
                     me->frame[me->Nb_Max_Fra++] = me->axis.frame[ifr1].obj;
                }
               } /* if(loop */
               else
                { me->frame[me->Nb_Max_Fra++] = located_obj;}
            } /* if(status */
            me->last_ifr = ifr;
            loop = 0;
            c = strtok(NULL," ,");
         } /* while */
   End
   return OM_S_SUCCESS;
} /* store_frame_by_name */

/***********************************************************************/
method store_frame_by_all ()
{
struct 		GRid *frame, drwObj, tmp1, drawview;
IGRint 		lowest,highest,nb_elem,i;
long 		loc_msg, status;
struct GRobj_env    tmp_drwlist;

   SetProc( store_frame_by_all ); Begin
   /* store all */
   __DBGpr_int( "me->Nb_Max_Fra", me->Nb_Max_Fra);

   if(!me->Nb_Max_Fra) {
     if( me->fr_system.objid != NULL_OBJID) {
       status = om$send(msg = message SMfrm_syst.SMfind_all_frame
                       (&loc_msg,&frame,NULL,&nb_elem,&lowest,&highest),
                        targetid = me->fr_system.objid,
                        targetos = me->fr_system.osnum );
       if(!(status & loc_msg & 1)) return OM_W_ABORT;

       status = om$send(msg = message VDCmdDrwFr.realloc_frame
                               (me->Nb_Max_Fra + nb_elem),
                               targetid = my_id);

       // tr179900479 by ylong  03-30-99
       if( me->drwlist == NULL ) return OM_W_ABORT;

       tmp_drwlist = me->drwlist[0];
       status = om$vla_set_dimension(varray = me->drwlist,
                                           size = 0);
       as$status(action = RET_STATUS);

       status = om$vla_set_dimension(varray = me->drwlist,
                                           size = nb_elem);
       drawview = VDdrawview; 
       for(i=0;i<nb_elem;i++) { 
                me->frame[i] = frame[i];
                tmp1 = frame[i];
                status = VDframeObjToDrwObj( &loc_msg, tmp1, drawview, &drwObj);
                if(status&loc_msg&1) {
                   me->drwlist[i] = tmp_drwlist;
                   me->drwlist[i].obj_id = drwObj;
                   __DBGpr_obj ( "me->drwlist[i].obj_id", 
                                  me->drwlist[i].obj_id);
                }
       }
     
       me->Nb_Max_Fra = nb_elem;
       om$dealloc(ptr = frame);
     }
     else {
       status = om$send(msg = message VDCmdDrwFr.realloc_frame
                               (me->Nb_Max_Fra + me->axis.nb_frame),
                               targetid = my_id);

       for(i=0;i<me->axis.nb_frame;i++)
            me->frame[i] = me->axis.frame[i].obj;

       me->Nb_Max_Fra = me->axis.nb_frame;
     }
   } /* if(!me->Nb_Max_Fra) */
   __DBGpr_int( "after me->Nb_Max_Fra", me->Nb_Max_Fra);

   End
   return OM_S_SUCCESS;
} /* store_frame_by_all */
/**********************************************************************/
method set_form_by_frsys_or_frame(long *loc_msg; 
				  struct GRid inputVDdrwing; 
				  int  class_flag)
{
struct GRid     *frame = NULL;
int             nb_frame = 0, i, j,  size = 0;
IGRint          lowest = 0, highest = 0;
long            status;
char            *frame_name,*strrchr(), *framesys_name,occ_name[DI_PATH_MAX];
int		find_match;
struct GRid             par_obj;
GRclassid               cid;
int                     chan_size, nb_vdfrsys = 0;
OMuint                  nblist;
OM_S_OBJECT_LINKAGE     slist[10];
 
   SetProc( set_form_by_frsys_or_frame ); Begin

   __DBGpr_int( "class_flag", class_flag);
   __DBGpr_obj( "inputVDdrwing", inputVDdrwing);
  
   /* find the relative SMframe from inputVDdrwing(VDdrawing object)*/

   status = OM_S_SUCCESS;
   chan_size = 10;

   status =
   om$get_channel_objects(
                objid           = inputVDdrwing.objid,
                osnum           = inputVDdrwing.osnum,
                p_chanselect    = &ND_father,
                list            = slist,
                size            = chan_size ,
                count           = &nblist );
    if( (!(status&1)) || ( nblist == 0 ) ){
        __DBGpr_com( " Can not find ACpretendin object");
        goto wrapup;
    }

    __DBGpr_int(" slist[0].S_objid ", slist[0].S_objid);
    __DBGpr_int(" slist[0].osnum ", slist[0].osnum);

    status =
    om$send(msg = message NDmacro.ACreturn_foot(loc_msg,"", 
					&par_obj, NULL, NULL ),
            targetid = slist[0].S_objid,
            targetos = slist[0].osnum );

    __DBGpr_obj(" par_obj ", par_obj);

    status =
    om$get_classid(osnum   = par_obj.osnum,
                 objid     = par_obj.objid,
                 p_classid = &cid );

    if( om$is_ancestry_valid( subclassid   = cid,
                              superclassid = OPP_SMframe_class_id )
                != OM_S_SUCCESS ) {
        
        __DBGpr_com( " Can not find SMframe object");
        goto wrapup;
   }


   size = om$dimension_of(varray = me->vdfrsys);
   __DBGpr_int( " previous size of me->vdfrsys", size);
   
   find_match = 0; 
   for( i = 0; i < size; i++ ) {
     nb_frame = 0;
     status = om$send(msg = message SMfrm_syst.SMfind_all_frame
             (loc_msg,&frame,NULL,&nb_frame,&lowest,&highest),
                        targetid = me->vdfrsys[i].grid.objid,
                        targetos = me->vdfrsys[i].grid.osnum );
     if(!(status &*loc_msg & 1)) continue;
      
     __DBGpr_obj( "matched me->vdfrsys[i].grid", me->vdfrsys[i].grid);
     for ( j = 0; j < nb_frame; j++ ) {
         __DBGpr_obj( "frame[j]", frame[j]);
         if( frame[j].objid == par_obj.objid &&
	     frame[j].osnum == par_obj.osnum ) { 
      	   me->fr_system.objid = me->vdfrsys[i].grid.objid;
           me->fr_system.osnum = me->vdfrsys[i].grid.osnum;
           find_match = 1; 
         }
     }  /* for j */
     if ( find_match ) break;
   }       /* for i */
   __DBGpr_int( "find_match", find_match);

   if( !find_match ) goto wrapup;

   if( class_flag == 2 ) { 
   	/* set active frame name */ 
   	occ_name[0] = '\0';
   	frame_name = occ_name;
   	status = om$send(msg = message GRvg.GRgetname (loc_msg,occ_name),
                     senderid = NULL_OBJID,
                     targetid = par_obj.objid,
                     targetos = par_obj.osnum);
   	if(status & *loc_msg & 1) {
        frame_name = strrchr(occ_name,':');

        if(frame_name) frame_name++;
        else           frame_name = occ_name;

        __DBGpr_str( "frame_name", frame_name);
        FIg_set_text( me->form, VD_DrwFr_FrNm_fd, frame_name);
   	}
   } 
   else {
        FIg_set_text( me->form, VD_DrwFr_FrNm_fd, "ALL");

   }
 
   /* set active frame system name */
   occ_name[0] = '\0';
   framesys_name = occ_name;
   status = om$send(msg = message GRvg.GRgetname (loc_msg,occ_name),
                     senderid = NULL_OBJID,
                     targetid = me->fr_system.objid,
                     targetos = me->fr_system.osnum);
   if(status & *loc_msg & 1) {
        framesys_name = strrchr(occ_name,':');

        if(framesys_name) framesys_name++;
        else           framesys_name = occ_name;

        __DBGpr_str( "framesys_name", framesys_name);
        FIg_set_text( me->form, VD_DrwFr_FrSy_fd, framesys_name);
        if ( me->mytype ) { /* for modify command */
             /* set list VD_DrwFr_FrSy_fd only include one*/
             nb_vdfrsys = om$dimension_of(varray = me->vdfrsys);
             for( j=0; j<nb_vdfrsys; j++){
                 FIfld_set_list_default_text( me->form, VD_DrwFr_FrSy_fd, j, 0,
                        "", FALSE);
             }
             FIfld_set_list_num_rows( me->form, VD_DrwFr_FrSy_fd, 0, 1 );
             FIfld_set_list_default_text( me->form, VD_DrwFr_FrSy_fd, 0, 0,
                 framesys_name, FALSE);
        }
   }


   /* set frame list */
   status =
   om$send(msg = message VDCmdDrwFr.get_frame_name_from_frsys(loc_msg,i),
                          targetid = my_id );
 
wrapup:
   if( frame )
   	om$dealloc(ptr = frame); 
  
   End
   return OM_S_SUCCESS;
} /* set_form_by_frsys_or_frame */
/**********************************************************************/
method get_VDdrawing_by_frame_name(long *loc_msg; char *input_name)
{
struct GRid     *frame = NULL, drwObj, drawview;
int             nb_frame = 0, i;
IGRint          lowest = 0, highest = 0, ii;
long            status;
char            *frame_name,*strrchr(), occ_name[DI_PATH_MAX];

   SetProc( get_VDdrawing_by_frame_name ); Begin
  
   __DBGpr_obj( "me->fr_system", me->fr_system);
   nb_frame = 0;
   status = om$send(msg = message SMfrm_syst.SMfind_all_frame
             (loc_msg,&frame,NULL,&nb_frame,&lowest,&highest),
                        targetid = me->fr_system.objid,
                        targetos = me->fr_system.osnum );
   if(!(status &*loc_msg & 1)) return OM_W_ABORT;

   __DBGpr_int( "Frame number in the frame system", nb_frame);
   __DBGpr_int( "lowest",lowest);
   __DBGpr_int( "highest",highest);


   drawview = VDdrawview; 
   /* find the name and set it to form */
   ii = 0;
   for( i = 0; i < nb_frame; i++) {
     __DBGpr_obj( "frame obj", frame[i]);

     /* get VDdrawing from frame */
     status = VDframeObjToDrwObj( loc_msg, frame[i], drawview, &drwObj);
     __DBGpr_obj( "drwObj", drwObj);

     occ_name[0] = '\0';
     frame_name = occ_name;
     status = om$send(msg = message GRvg.GRgetname (loc_msg,occ_name),
                     senderid = NULL_OBJID,
                     targetid = frame[i].objid,
                     targetos = frame[i].osnum);

     if(status & *loc_msg & 1) {
        frame_name = strrchr(occ_name,':');

        if(frame_name) frame_name++;
        else           frame_name = occ_name;

        __DBGpr_str( "frame_name", frame_name);

        if( !strcmp ( input_name, frame_name )) {
     	  /* get VDdrawing from frame */
          status = VDframeObjToDrwObj( loc_msg, frame[i], drawview, &drwObj);
          __DBGpr_obj( "find drwObj", drwObj);
        
          /* find me->drwlist from me->Obj_List */

          status = om$vla_set_dimension(varray = me->drwlist,
                                        size = 1);
          me->drwlist[0].mod_env = me->ModuleInfo;
          me->drwlist[0].obj_id = drwObj;
          __DBGpr_obj("me->drwlist[0].obj_id", me->drwlist[0].obj_id);
          break;
        }
     }
   }


   if( frame )
      om$dealloc(ptr = frame);
   End
   return status;
} /* get_frame_name_from_frsys */

/**********************************************************************/
method get_frame_name_from_frsys(long *loc_msg; int index) 
{
struct GRid 	*frame = NULL, drwObj, drawview ; 
int 		nb_frame = 0, i; 
IGRint 		lowest = 0, highest = 0, ii;
long		status;
char 		*frame_name,*strrchr(), occ_name[DI_PATH_MAX];

   SetProc( get_frame_name_from_frsys ); Begin
   
   __DBGpr_obj( "me->vdfrsys[index].grid", me->vdfrsys[index].grid);
   nb_frame = 0;
   status = om$send(msg = message SMfrm_syst.SMfind_all_frame
             (loc_msg,&frame,NULL,&nb_frame,&lowest,&highest),
                        targetid = me->vdfrsys[index].grid.objid,
                        targetos = me->vdfrsys[index].grid.osnum );
   if(!(status &*loc_msg & 1)) return OM_W_ABORT;

   __DBGpr_int( "Frame number in the frame system", nb_frame);
   __DBGpr_int( "lowest",lowest);
   __DBGpr_int( "highest",highest);

   drawview = VDdrawview;

   /* find the name and set it to form */
   FIfld_set_list_default_text( me->form, VD_DrwFr_FrNm_fd, 0, 0, 
				"ALL", FALSE);
   ii = 0;
   for( i = 0; i < nb_frame; i++) {
     __DBGpr_obj( "frame obj", frame[i]);

     /* get VDdrawing from frame */
     status = VDframeObjToDrwObj( loc_msg, frame[i], drawview, &drwObj);
     __DBGpr_obj( "drwObj", drwObj);

     occ_name[0] = '\0';
     frame_name = occ_name;
     status = om$send(msg = message GRvg.GRgetname (loc_msg,occ_name),
                     senderid = NULL_OBJID,
                     targetid = frame[i].objid,
                     targetos = frame[i].osnum);
     if(status & *loc_msg & 1) { 
        frame_name = strrchr(occ_name,':');
     
        if(frame_name) frame_name++;
        else           frame_name = occ_name;
        
   	__DBGpr_str( "frame_name", frame_name);
        FIfld_set_list_default_text( me->form, VD_DrwFr_FrNm_fd, ii+1, 0,
                        frame_name, FALSE);
        ii++;
     } 
   }
   if( frame ) 
      om$dealloc(ptr = frame);
   End
   return status;
} /* get_frame_name_from_frsys */

/****************************************************************/
IGRint VDnotify_form (form_label,label,value,form_ptr)
int form_label;
int label;
IGRdouble value;
Form form_ptr;
{
        int status;
        OM_S_OBJID objid;
        OMuword osnum;

        status =
        FIf_get_cmd_oid_os(form_ptr, &objid, &osnum);
        if (status != FI_SUCCESS)
        {
                /*|DMnotify_form: FI_get_cmd_oid_os fails*/
                return 0;
        }

        status =
        om$send(msg = message VDCmdDrwFr.notify_form(form_label,
                                                label,
                                                value,
                                                form_ptr),
                senderid = NULL_OBJID,
                targetid = objid,
                targetos = osnum);
        as$status(action = RET_STATUS);

        return 1;
}

/**********************************************************************/
method create_form(
        int form_label;
        char *form_name;
        Form *form)
{
        int VDnotify_form();
	long status;

        SetProc( create_form ); Begin

        __DBGpr_int(" form_label ", form_label);
        __DBGpr_str(" form_name ", form_name);

        status =
        FIf_new(form_label, form_name, VDnotify_form, form);
        if (status != FI_SUCCESS)
        {
                __DBGpr_com("create_form: FIf_new failed");
                return(OM_E_ABORT);
        }
        status =
        FIf_set_cmd_oid_os(*form, my_id, OM_Gw_current_OS);
        if (status != FI_SUCCESS)
        {
                __DBGpr_com("create_form: FIf_set_cmd_oid_os failed");
                return(OM_E_ABORT);
        }

        __DBGpr_int(" Form Pointer ", *form);

        End
        return OM_S_SUCCESS;
}
/*===========================================================================*/
/*     Method           place_form                                           */
/*===========================================================================*/
method  place_form( long * sts )
{

  SetProc( VDCmdDrwFr.place_form ) ; Begin

  /*
   * This method initialize/displays the gadgets of the active form:
  */

  /* set toggle 0(off)  -- for select frame system name.
   * set toggle 0(on)   -- for select frame name.
  */
  FIg_set_state( me->form, VD_DrwFr_FrSy_tg, FALSE );
 
  // FIg_set_text( me->form, EXIST_FORMAT, "" );

  *sts = MSSUCC;

  End
  return( OM_S_SUCCESS );
}


/************************************************************************/
/* METHOD display_form                                                  */
/************************************************************************/
method display_form()
{
IGRint		status;
IGRlong		sts;
int		label ;

        SetProc( VDCmdDrwFr.display_form ) ; Begin
        /*
         * display the drawing frame control parameters.
         */
        status =
        om$send(msg = message VDCmdDrwFr.place_form( &sts ),
                targetid = my_id );
        as$status( action = RET_STATUS );

        label = VD_DrwFr_FrPs_fd;
        status =
        om$send(msg = message VDCmdDrwFr.notify_form(0, label, 1, me->form),
                targetid = my_id);
        as$status( action = RET_STATUS );

        if ( me->form_displayed == TRUE ) {
          status = FIf_display(me->form);
          if(status != FI_SUCCESS) { return(OM_E_ABORT); }

          __DBGpr_int( "me->mytype", me->mytype);
          if( !me->mytype ) { /* for Extract Drawing View */
                UI_message( "Extract Drawing Frame");
           	FIg_erase( me->form, 11);
      		FIg_display( me->form, 12);
    	  }
    	  else { /* for Modify Drawing View */
                UI_message( "Modify Drawing Frame");
      		FIg_erase( me->form, 12);
      		FIg_display( me->form, 11);
    	  }
	}

        /* CR179900941 by ylong */
	FIg_get_state( me->form, VD_DrwFr_Label_tg, &VDFrameNameCase );

	if( VDFrameNameCase ) {
	  FIg_display( me->form, VD_DrwFr_Prefix_text );
	  FIg_display( me->form, VD_DrwFr_Prefix_fd );
	}
	else {
          FIg_display( me->form, VD_DrwFr_AllCaps_chck );
	}

        End
        return OM_S_SUCCESS;

}

/*==========================================================================*/
/*    Method Notify_Form                                                    */
/*==========================================================================*/

method notify_form(
                   int     form_label;
                   int     label;
                   double  value;
                   Form    form   )

{

 IGRint     	status, resp, i, nb_vdfrsys ;
 IGRlong    	msg;
 int		flag, row, prinVal, chck;
 double		val;
 char 		txinText[20];

 enum GRdpmode  dpmode;
 
 struct GRid    display_info;
 IGRdouble      temp_double;
 IGRint         sel_flag;
 IGRint         r_pos;
 double 	val_v, val_h; 
 IGRint		state_flag;

 SetProc( VDCmdDrwFr.notify_form ) ; Begin

 __DBGpr_int( "form_label ", form_label);
 __DBGpr_int( "label ", label);

 switch( form_label ) {

   case VD_FRM_MAIN_FORM_LABEL:
     switch( label ) {
 
       case VD_DrwFr_FrSym_tg:

	FIg_get_state( me->form, VD_DrwFr_FrSym_tg, &flag );
       	__DBGpr_int( " symb flag ", flag);
        break;

       case VD_DrwFr_FrSy_tg:

	FIg_get_state( me->form, VD_DrwFr_FrSy_tg, &flag );
       	__DBGpr_int( " flag ", flag);

       	/* clear */
       	FIg_set_text( me->form, VD_DrwFr_FrSy_fd, "");
        
       	FIfld_get_list_num_rows( me->form, VD_DrwFr_FrSy_fd, 0, &row );
       	for( i=0; i<row; i++){
          FIfld_set_list_default_text( me->form, VD_DrwFr_FrSy_fd, i, 0,
                        "", FALSE);
       	} 

       	if( !flag ){ /* change to frame system */
         /* set list VD_DrwFr_FrSy_fd */
	 me->select_axis = 0;
         nb_vdfrsys = om$dimension_of(varray = me->vdfrsys);
         FIfld_set_list_num_rows( me->form, VD_DrwFr_FrSy_fd, 0, nb_vdfrsys );

         for( i=0; i<nb_vdfrsys; i++){
          FIfld_set_list_default_text( me->form, VD_DrwFr_FrSy_fd, i, 0,
                        me->vdfrsys[i].name, FALSE);
         }
        } 
        else {  /* change to axis */
	 me->select_axis = 1;
         FIg_set_text( me->form, VD_DrwFr_FrSy_fd, "");
         FIfld_set_list_num_rows( me->form, VD_DrwFr_FrSy_fd, 0, 3);
         FIfld_set_list_default_text( me->form, VD_DrwFr_FrSy_fd, 0, 0,
                        "x", FALSE);
         FIfld_set_list_default_text( me->form, VD_DrwFr_FrSy_fd, 1, 0,
                        "y", FALSE);
         FIfld_set_list_default_text( me->form, VD_DrwFr_FrSy_fd, 2, 0,
                        "z", FALSE);
        } 
        break;

       case VD_DrwFr_FrSy_fd:

        /* get relative frame names */
        flag = FALSE;
        nb_vdfrsys = 0;

        status = FIfld_get_list_num_rows( me->form, label, 0, &nb_vdfrsys);
        if (status != FI_SUCCESS) { return(OM_E_ABORT); }
        __DBGpr_int("# nb_vdfrsys ", nb_vdfrsys );

        row = 0;
        do{
             status = FIfld_get_list_select( me->form, label, row, 0, &flag );
                  if (status != FI_SUCCESS) { return(OM_E_ABORT); }
                  row++;
        }
        while( flag != TRUE && row <= nb_vdfrsys );
       
        if( me->mytype ) { /* for modify command */
          if( row <= nb_vdfrsys ){ 
             /* find the relative frame names from frame system */
             row--;
             __DBGpr_int(" Active Row", row );

             status =
             om$send(msg = message VDCmdDrwFr.get_frame_name_from_frsys(&msg,
									row),
                          targetid = my_id );
             as$status();
	  }
        } 
        break;

       case VD_DrwFr_FrNm_fd:
       	break;

       case VD_DrwFr_FrPs_bt:
          if (value == 1) {

             status = VDstrToVal(&msg, me->act_frpos, &temp_double);

             __DBGpr_dbl(" temp_double ", temp_double);
             VDupdsubform(&msg, temp_double,me->subform);

             /* display the subform */
             FIf_display(me->subform);
          }
          else {
             /*
              * the subform button was popped; erase the subform;
              */

             FIf_erase(me->subform);
          }
          break;

       case VD_DrwFr_FrPs_fd:
        break;

       case VD_DrwFr_PrIn_fd:

        /* set list VD_DrwFr_TxIn_fd */
        FIg_get_value( me->form, VD_DrwFr_PrIn_fd,  &val);
        prinVal = (int) val;
        txinText[0] = '\0';
        sprintf( txinText, "%d", prinVal);
        FIfld_set_list_text( me->form, VD_DrwFr_TxIn_fd, 0, 0,
                        txinText, FALSE);
        txinText[0] = '\0';
        sprintf( txinText, "%d", 2*prinVal);
        FIfld_set_list_text( me->form, VD_DrwFr_TxIn_fd, 1, 0,
                        txinText, FALSE);
        FIg_set_value( me->form, VD_DrwFr_TxIn_fd, val, FALSE);
        break;
       case VD_DrwFr_PrFc_fd:
        break;
       case VD_DrwFr_TxIn_fd:
        break;

       case VD_DrwFr_TxPs_fd:
        break;

       case VD_DrwFr_ShCk_Vert:
        show_pos = 1;
        val_v = 1.0; 
        val_h = 0.0; 
        /* set check box */
        status = FIg_set_value(me->form,
                            VD_DrwFr_ShCk_Vert,
                            val_v);

        status = FIg_set_value(me->form,
                            VD_DrwFr_ShCk_Hori,
                            val_h);

        break;

       case VD_DrwFr_ShCk_Hori:
        show_pos = 0;
        val_v = 0.0; 
        val_h = 1.0; 
        /* set check box */
        status = FIg_set_value(me->form,
                            VD_DrwFr_ShCk_Vert,
                            val_v);

        status = FIg_set_value(me->form,
                            VD_DrwFr_ShCk_Hori,
                            val_h);
        break;

       case VD_DrwFr_FrSh_tg:
        FIg_get_state( me->form, VD_DrwFr_FrSh_tg, &flag );
        __DBGpr_int( " flag ", flag);
 
        if ( flag ) { /* show range and position line */

	  struct IGRpolyline      polyline;
          IGRdouble               points[6];
          char 			  act_frpos[20];
          double		  temp_double;
          struct GRvg_construct cnst_lis, cnst_lis1;
          struct IGRdisplay  	display, display1;
          GRclassid 		go_classid, go_classid1;
          int  			alt_const, Active_level;
          struct IGRpolyline    polyline1;
          IGRdouble             drw_range_poly[15];
	  GRspacenum            cur_os; 


	  /* read value from frame position */
          FIg_get_text( me->form, VD_DrwFr_FrPs_fd,  act_frpos);
          __DBGpr_str( "act_frpos", act_frpos);
          status = VDstrToVal(&msg, act_frpos, &temp_double);
          __DBGpr_dbl( "temp_double", temp_double);

          /* create range object */
	  ex$get_cur_mod( osnum   = &cur_os );

          me->line_obj.osnum = cur_os;
          me->poly_obj.osnum = cur_os;
	  me->line_obj.objid = NULL_OBJID;          
	  me->poly_obj.objid = NULL_OBJID;         
          __DBGpr_obj( "me->line_obj", me->line_obj); 
          __DBGpr_obj( "me->poly_obj", me->poly_obj); 

          /* set symbology */
          cnst_lis.msg = &msg;
          cnst_lis.env_info = &me->ModuleInfo;/* context returned from ?? */
          cnst_lis.newflag = FALSE;
          cnst_lis.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
          cnst_lis.display = &display;
          cnst_lis.class_attr = NULL;
          cnst_lis.name = NULL;

          cnst_lis1.msg = &msg;
          cnst_lis1.env_info = &me->ModuleInfo;
          cnst_lis1.newflag = FALSE;
          cnst_lis1.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
          cnst_lis1.display = &display1;
          cnst_lis1.class_attr = NULL;
          cnst_lis1.name = NULL;


          ASget_active_symb(&Active_level,&display);
          ASget_active_symb(&Active_level,&display1);

          cnst_lis.level = Active_level;
          cnst_lis1.level = Active_level;

          display.color = 3;
          display.style = 2;
          display.weight = 2;

          display1.color = 2;
          display1.style = 2;
          display1.weight = 2;

          /*| Create Line/Linestr */

          if ( show_pos ) { /* = 1, in vertical direction */
            points[0] = range_p1[0];
            points[1] = range_p1[1] + temp_double*(range_p2[1] - range_p1[1]) ;
            points[2] = 0.0;
            points[3] = range_p2[0];
            points[4] = range_p1[1] + temp_double*(range_p2[1] - range_p1[1]) ;
            points[5] = 0;
          }
          else {
            points[0] = range_p1[0] + temp_double*(range_p2[0] - range_p1[0]);
            points[1] = range_p1[1] ;
            points[2] = 0.0;
            points[3] = range_p1[0] + temp_double*(range_p2[0] - range_p1[0]) ;
            points[4] = range_p2[1] ;
            points[5] = 0;
	  }

          drw_range_poly[0] = range_p1[0];
          drw_range_poly[1] = range_p1[1];
          drw_range_poly[2] = 0.0;
          drw_range_poly[3] = range_p2[0];
          drw_range_poly[4] = range_p1[1];
          drw_range_poly[5] = 0.0;
          drw_range_poly[6] = range_p2[0];
          drw_range_poly[7] = range_p2[1];
          drw_range_poly[8] = 0.0;
          drw_range_poly[9] = range_p1[0];
          drw_range_poly[10] = range_p2[1];
          drw_range_poly[11] = 0.0;
          drw_range_poly[12] = range_p1[0];
          drw_range_poly[13] = range_p1[1];
          drw_range_poly[14] = 0.0;

 
          polyline.num_points = 2;
          polyline.points = points;
          cnst_lis.geometry = (char *)&polyline;
          go_classid = OPP_GR3dlineseg_class_id;
          alt_const = TRUE;

          polyline1.num_points = 5;
          polyline1.points = drw_range_poly;
          cnst_lis1.geometry = (char *)&polyline1;
          go_classid1 = OPP_GR3dpolygon_class_id;
          alt_const = TRUE;

          /*| altconstruct */
          status =
          om$construct( classid = go_classid,
                        msg = message GRgraphics.GRaltconstruct(
                                                        &cnst_lis),
                          p_objid = &me->line_obj.objid,
                          osnum = me->line_obj.osnum);
          as$status();
          __DBGpr_obj(" line_obj", me->line_obj );


          status =
          om$construct( classid = go_classid1,
                          msg = message GRgraphics.GRaltconstruct(
                                                          &cnst_lis1),
                            p_objid = &me->poly_obj.objid,
                            osnum = me->poly_obj.osnum);
          as$status();
          __DBGpr_obj(" poly_obj", me->poly_obj );

          /* display */ 
          dpmode = GRbdhd ;
          GRfindmod( &display_info );

          status =
          om$send(msg = message GRgraphics.GRdisplay(
                                        &msg,
 					&me->ModuleInfo.md_env.matrix_type,
                                        me->ModuleInfo.md_env.matrix,
                                 /*       &mod_env.md_env.matrix_type,
                                        mod_env.md_env.matrix,
                                  */
                                        &dpmode,
                                        &display_info ),
          targetid = me->line_obj.objid,
          targetos = me->line_obj.osnum );

          status =
          om$send(msg = message GRgraphics.GRdisplay(
                                        &msg,
 					&me->ModuleInfo.md_env.matrix_type,
                                        me->ModuleInfo.md_env.matrix,
                                        &dpmode,
                                        &display_info ),
              targetid = me->poly_obj.objid,
              targetos = me->poly_obj.osnum );
        }
        else {
          dpmode = GRbeheo ;
          GRfindmod( &display_info );

          if ( me->line_obj.objid != NULL_OBJID ) { 
            status =
            om$send(msg = message GRgraphics.GRdisplay(
                                        &msg,
 					&me->ModuleInfo.md_env.matrix_type,
                                        me->ModuleInfo.md_env.matrix,
                                        &dpmode,
                                        &display_info ),
            		targetid = me->line_obj.objid,
            		targetos = me->line_obj.osnum );
 	    status =
                   om$send(msg = message Root.delete( 1 ),
                          targetid = me->line_obj.objid,
                          targetos = me->line_obj.osnum);
            me->line_obj.objid = NULL_OBJID ;
          }
          if ( me->poly_obj.objid != NULL_OBJID ) { 
            status =
            om$send(msg = message GRgraphics.GRdisplay(
                                        &msg,
 					&me->ModuleInfo.md_env.matrix_type,
                                        me->ModuleInfo.md_env.matrix,
                                        &dpmode,
                                        &display_info ),
              targetid = me->poly_obj.objid,
              targetos = me->poly_obj.osnum );

            status =
            om$send(msg = message Root.delete( 1 ),
                          targetid = me->poly_obj.objid,
                          targetos = me->poly_obj.osnum);
            me->line_obj.objid = NULL_OBJID ;
 
          }
        }
        break;

      /* TR179801648 by Ming */
      case VD_DrwFr_Label_tg:
	FIg_get_state( me->form, label, &state_flag );

	if( state_flag )
	{
          // added erase for CR179900941, by ylong
          FIg_erase( me->form, VD_DrwFr_AllCaps_chck );

	  FIg_display( me->form, VD_DrwFr_Prefix_text );
	  FIg_display( me->form, VD_DrwFr_Prefix_fd );
	}
	else
	{
	  FIg_erase( me->form, VD_DrwFr_Prefix_text );
	  FIg_erase( me->form, VD_DrwFr_Prefix_fd );

          // added display for CR179900941, by ylong
          FIg_display( me->form, VD_DrwFr_AllCaps_chck );
	}
	break;

      case VD_DrwFr_Prefix_fd:
 	break;

      case FI_CANCEL:
       me->modify_flag = 0;
       me->form_displayed = FALSE;
       status = FIf_erase(form);

       if( me->subform ) {
           FIf_erase(me->subform);
       }

       resp = TERMINATE;
       ex$putque( msg      = &msg,
                  response = &resp );
       break;

      case FI_EXECUTE:
           FIg_set_text( me->form, 10, "");
           me->Nb_Max_Fra = 0;
           me->Nb_Max_Ref = 0;

      case FI_ACCEPT:
       me->modify_flag = 1;
       FIg_get_state( me->form, VD_DrwFr_FrSym_tg, &flag ); 
       if ( flag ) 
		me->symb_flag = 1;
       else
		me->symb_flag = 0;

       FIg_get_text( me->form, VD_DrwFr_FrSy_fd,  me->act_frsys);
       __DBGpr_str( "me->act_frsys", me->act_frsys);	
 
       if( me->act_frsys[0] == '\0')  { 
        FIg_set_text( me->form, VD_DrwFr_Msg_fd, 
			"Select Frame System Name!");
        __DBGpr_com(" Do nothing if no frame system");
        break;
       }

       FIg_get_text( me->form, VD_DrwFr_FrNm_fd,  me->act_frname);

       if( !strcmp( me->act_frname, "ALL") ) {
		me->select_all = 1;
       }
       else 
		me->select_all = 0;
             	
       __DBGpr_int( "me->select_all", me->select_all);	
       __DBGpr_str( "me->act_frname", me->act_frname);	

       FIg_get_text( me->form, VD_DrwFr_FrPs_fd,  me->act_frpos);
       __DBGpr_str( "me->act_frpos", me->act_frpos);	

       FIg_get_value( me->form, VD_DrwFr_PrIn_fd,  &val);
       me->act_printe = (int) val;
       __DBGpr_int( "me->act_printe", me->act_printe);	

       FIg_get_text( me->form, VD_DrwFr_PrFc_fd,  me->act_prfact);
       __DBGpr_str( "me->act_prfact", me->act_prfact);	

       FIg_get_value( me->form, VD_DrwFr_TxIn_fd,  &val);
       me->act_txinte = (int) val;
       __DBGpr_int( "me->act_txinte", me->act_txinte);	

       FIg_get_text( me->form, VD_DrwFr_TxPs_fd,  me->act_txpos);
       __DBGpr_str( "me->act_txpos", me->act_txpos);	

       /* TR179801648 by Ming */
       FIg_get_state( me->form, VD_DrwFr_Label_tg, &state_flag );
       VDFrameLabelType = state_flag;

       if( VDFrameLabelType )
       {
	 FIg_get_text( me->form, VD_DrwFr_Prefix_fd,  VDFrameLabelPrefix );
       }
	// CR179900941 by ylong
       else {
	 FIg_get_state( me->form, VD_DrwFr_AllCaps_chck,  &VDFrameNameCase );
       }

       if( label == FI_ACCEPT) { 
         me->form_displayed = FALSE;
         status = FIf_erase(form);

         if( me->subform ) {
           FIf_erase(me->subform);
         }

         if(status != FI_SUCCESS) { return(OM_E_ABORT); }
       }
       else {
         me->form_displayed = TRUE;
       }
       if (label == FI_ACCEPT )
          resp = FORM_FINISHED;
       else 
          resp = EXEC;

       ex$putque( msg      = &msg,
                 response = &resp );

       break;

       default:
        	return(OM_S_SUCCESS);
     } /* label */

     break; /* case VD_FRM_MAIN_FORM_LABEL */

   case VD_FRM_SUB_FORM_LABEL:

    switch( label ) {
      case FI_CANCEL:
       /*  erase the subform */
       FIf_erase(me->subform);
        /*
         * Pop the subform button on the main form
         */
       FIg_set_state_off(me->form,VD_DrwFr_FrPs_bt);
       break;

      case FI_ACCEPT:
       
        /*  erase the subform  and set buttom on*/
        FIf_erase(me->subform);

        /*
         * Pop the subform button on the main form
         */
        FIg_set_state_off(me->form,VD_DrwFr_FrPs_bt);

        /* get the value from the slide */
        FIfld_get_value(me->subform,VD_DrwFr_SubSlPs_fd,0,0,
			&temp_double,&sel_flag, &r_pos);
        sprintf( me->act_frpos, "UserDef[%f]", temp_double); 
        FIg_set_text( me->form, VD_DrwFr_FrPs_fd, me->act_frpos);
        
        __DBGpr_str("me->act_frpos", me->act_frpos);   
        break;

      case VD_DrwFr_SubFrPs_sl:
       /*
        FIg_set_continuous_routine(me->subform,
                                  VD_DrwFr_SubFrPs_sl,
                                  VDchg_FRps_Field);
       */

        /*
         * value returned from the slider must
         * be valid
        */

        sprintf( me->act_frpos, "UserDef[%f]", value); 
        __DBGpr_com( " me->act_frpos "); 
        
	/* update the subform */
        VDupdsubform(&msg, value,me->subform);

        break;


      case VD_DrwFr_SubSlPs_fd:
         FIfld_get_value(me->subform,label, 0,0,&temp_double,&sel_flag,
                                                    &r_pos);

         if ((temp_double >= VD_DrwFr_LO_Ps) &&
             (temp_double <= VD_DrwFr_HI_Ps)) { 
             sprintf( me->act_frpos, "UserDef[%f]", temp_double); 
             __DBGpr_com( " me->act_frpos "); 
         }
	
	 /* update the subform */
         VDupdsubform(&msg, temp_double,me->subform);
         break;

      default:
       break;

    } 
    break; /* VD_FRM_SUB_FORM_LABEL */

  default: /* incalid type */
    break;

 } /* form_label */
 End

 return( OM_S_SUCCESS );

}



/*****************************************************************************/
method realloc_ref(int nb_ref)
{
 long status;
 int previous_size;
  
  SetProc( realloc_ref ); Begin
  previous_size = om$dimension_of(varray = me->ref);
  if(nb_ref > previous_size)
   {
     previous_size = 20*(nb_ref/20 +1);
             status = om$vla_set_dimension(varray = me->ref,
                                           size = previous_size);
             as$status(action = RET_STATUS);

   }
  End
  return OM_S_SUCCESS;
}

/*********************************************************************/
method realloc_frame(int nb_frame)
{
 long status;
 int previous_size;

  SetProc( realloc_frame ); Begin

  previous_size = om$dimension_of(varray = me->frame);
  if(nb_frame > previous_size)
   {
     previous_size = 20*(nb_frame/20 +1);
             status = om$vla_set_dimension(varray = me->frame,
                                           size = previous_size);
             as$status(action = RET_STATUS);

   }
  End
  return OM_S_SUCCESS;
}


/***********************************************************************
     FUNCTION NAME:             VDchg_FrPs_Field

     Abstract:
      This function updates the field of FrPs_fd gadget on the form.

     VALUE =  VDchg_FrPs_Field(form_label,label,value,form_ptr)

     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------
     form_label    int                form label
     label         int                label of the gadget whose data has
                                      changed
     value         double             return value of the gadget
     form_ptr      Form               pointer to the form whose gadget was
                                      updated

************************************************************************/
void VDchg_FrPs_field(form_label,label,value,form_ptr)
int form_label;  /* form label                                   */
int label;       /* label of the gadget whose data has changed   */
IGRdouble value;    /* return value of the gadget                   */
Form form_ptr;   /* pointer to the form whose gadget was updated */
{
    __DBGpr_dbl( "VDchg_FrPs_field value", value);
    FIg_set_value(form_ptr,VD_DrwFr_SubFrPs_sl,value);
}


/**************************************************************8*A
This function will update the subform for frame position.
******************************************************************/
IGRint VDupdsubform(msg,active_position,form_ptr)
IGRlong           *msg;          /* return code                   */
IGRdouble         active_position; /* active position  */
Form              form_ptr;      /* pointer to form to be updated */
{

    *msg = MSSUCC;

    /*
     *  update the slider and the value field on the form
     */

    FIg_set_value(form_ptr,VD_DrwFr_SubFrPs_sl,active_position);
    FIg_set_value(form_ptr,VD_DrwFr_SubSlPs_fd,active_position);

    return(TRUE);
}

/*****************************************************************
This function will return value from string mte->act_frpos.
******************************************************************/
IGRint VDstrToVal(msg,string,value)
IGRlong           *msg;          /* return code                   */
IGRdouble         *value; /* active position  */
char              *string;      /* pointer to form to be updated */
{
IGRchar        *ptr1 = NULL, *ptr2 = NULL, tmp[20], tmp1[20];
int            len1,len2;


    SetProc( VDstrToVal ); Begin 
    *msg = MSSUCC;

    if( string )
      __DBGpr_str( "Input string", string);

    tmp[0]  ='\0';
    tmp1[0]  ='\0';

    *value = 0.0;
    strcpy( tmp, string);

    if( string[0] == '\0')
                *value = 0.0;
    else if( !strcmp( string, "Top Or Right" ))
                *value = 1.0;
    else if( !strcmp( string, "Center" ))
                *value = 0.5;
    /* TR179801745 by Ming */
    else if( !strcmp( string, "CenterLine" ))
    {
	      if( fabs(range_p2[1] - range_p1[1]) > 0.0 )
                *value = (VDCenterLinePosition - range_p1[1]) /
			 (range_p2[1] - range_p1[1]);
    }
    else if (!strncmp( string, "UserDef[",8) ){
               ptr1 = strchr( tmp, '[');
               len1 = strlen( &ptr1[1] );
               ptr2 = strchr( tmp, ']');
               len2 = strlen( &ptr2[0] );
               strncpy( tmp1, &ptr1[1], len1 - len2);
               __DBGpr_str(" tmp1 ", tmp1);
               *value = atof( tmp1 );
   }

   __DBGpr_dbl(" value ", *value);

   End
   return TRUE;	
}


/******************** save_form_pos *************************/
method  save_form_pos()
{
long	status;
        
        FIf_get_location(me->form,&x_pos,&y_pos);
        FIf_get_location(me->subform,&x1_pos,&y1_pos);
       
        status = OM_S_SUCCESS ;
        return status; 
}

/* set_form_position */
method  set_form_pos () 
{
long	status;
        /*
         * get the form position.
         */
        if(x_pos != -1 && y_pos != -1)
                FIf_set_location ( me->form, x_pos, y_pos );

        if(x1_pos != -1 && y1_pos != -1)
                FIf_set_location ( me->subform, x_pos, y_pos );

        status = OM_S_SUCCESS ;
        return status; 
}

end implementation VDCmdDrwFr;


