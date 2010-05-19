/* $Id: VDm_drawingi.I,v 1.6 2002/05/10 20:15:25 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/cmd / VDm_drawingi.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_drawingi.I,v $
 *	Revision 1.6  2002/05/10 20:15:25  ramarao
 *	Fixed TR# 6318.
 *	
 *	Revision 1.5  2001/02/06 17:22:39  ramarao
 *	Fixed TR# 4587.
 *	
 *	Revision 1.4  2001/01/23 16:08:32  ramarao
 *	Fixed TR# 3413.
 *	
 *	Revision 1.3  2001/01/19 22:06:07  ramarao
 *	Merged from SP.
 *	
# Revision 1.2  2000/11/30  15:20:06  pinnacle
# pn
#
# Revision 1.1  2000/06/10  17:30:30  pinnacle
# Created: vds/vddrawing/cmd/VDm_drawingi.I by rchennup for Service Pack
#
# Revision 1.4  1999/04/09  17:39:02  pinnacle
# Moved functions to imp/VDmisc.I
#
# Revision 1.3  1999/02/16  14:32:58  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by mdong for vds
#
# Revision 1.2  1999/02/16  14:26:18  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by mdong for vds
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.17  1998/03/29  16:44:14  pinnacle
# ah
#
# Revision 1.16  1998/03/24  18:37:36  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by azuurhou for vds
#
# Revision 1.15  1998/03/13  23:18:44  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by azuurhou for vds
#
# Revision 1.14  1998/02/12  14:23:36  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by v250_int for vds
#
# Revision 1.13  1998/02/11  20:25:02  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by azuurhou for vds
#
# Revision 1.12  1998/02/11  19:50:26  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by azuurhou for vds
#
# Revision 1.11  1998/01/29  22:17:02  pinnacle
# ah
#
# Revision 1.10  1998/01/23  10:40:22  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by smpathak for vds
#
# Revision 1.6  1998/01/08  22:25:42  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by yzhu for vds
#
# Revision 1.5  1997/12/19  15:59:54  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by v250_int for vds
#
# Revision 1.4  1997/12/19  15:23:02  pinnacle
# setup_Name
#
# Revision 1.3  1997/12/18  06:37:50  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for: CR 179603526 by smpathak for vds
#
# Revision 1.2  1997/07/14  19:26:34  pinnacle
# Replaced: vds/vddrawing/cmd/VDm_drawingi.I: for TR 179700418 by A.Gupta for VDS
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/10/26  21:46:44  pinnacle
# Replaced: ./vddrawing/cmd/VDm_drawingi.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/07/24  22:21:36  pinnacle
# Replaced: vddrawing/cmd/VDm_drawingi.I for:  by hverstee for vds.240
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
 *	jla	../../..	Creation date
 *	adz	08/27/92	Modification for ci_mac_def.ACplace
 *				Creation of default working directory
 *	adz	03/17/93	Modification for active working directory.
 *	adz	04/02/93	Modification for multiple reference attachment
 *	adz	05/01/93	Test on number selected objects;
 *				VDget_ctx_ref replaced
 *      rmn     07/08/94        Included LC_RIGIG_COMP in owner action for 
 *                              locate.
 *	12/19/97	ah		added extern to setupName
 *      01/23/98 	Sandeep		Modified for Fence processing.
 *	01/29/98	ah		Got rid of extern VDdraw_setup_Name
 *					Also rewrote get_setup_name
 *	02/11/98	adz		Correction for setup filename check.
 *	03/13/98	adz		Correction for setupFile & display.
 *					TR179800762,
 *	03/24/98	adz		TR179800825; Lbsys update directly.
 *      02/29/98        ah              TR179800825; Moved VDdrw_getDrawing_lbs
 *                                      to vddraw/imp/VDdrw2di.I
 *      02/15/99	Ming		TR179801989
 *	06/10/00	adz	  	etl#1879	
 *      11/30/00        pn              fix of status report(look up'Processing')
 *                                      for long time consumer processes
 *	02/06/01	RR		Throw out DMroot objects.
 * -------------------------------------------------------------------*/


class implementation VDm_drawing;

#include <stdio.h>
#include <ctype.h>
#include "string.h"
#include "OMmacros.h"
#include "OMindex.h"
#include "OMprimitives.h"
#include "AS_status.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "VDmsg.h"
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
#include "ACcheckin.h"
#include "refdef.h"
#include "ref.h"
#include "exdef.h"
#include "exmacros.h"
#include "v_miscmacros.h"

#include "v_dbgmacros.h"
#include "FI.h"
#include "OMprimitives.h"
#include "griodef.h"
#include "griomacros.h"
#include "viewdef.h"
#include "v_drwdef.h"
#include "vddrwproto.h"

from	NDnode		import NDget_objects, NDconnect,NDchange_connect,
				NDs_compute_node, NDgive_structure;
from	ACcpx		import ACload_macro,find_macro,ACfind_temp_obj;
from	ACncpx		import ACchange_feet,ACconstruct_feet;
from	ACcpx_defn	import ACgive_feet_desc,ACgive_name;
from	expression	import NDgive_value;
from	NDmacro		import ACreturn_foot;
from	GRgraphics	import GRdisplay,GRgetrang,GRremwrng,GRaddwrng,GRdelete;
from	GRvg		import GRchgname;
from	ACdb_info	import ACget_db_info,ACset_db_info,ACput_serial_no,
				ACcheckin_candidate;
from	IGEgragad	import DPinrot,DPinquire;
from	GRreffile	import GRgetlevels, GRinquireref;
from	ci_mac_def	import ACplace;
from	VDcontext	import VDset_level,VDset_lbs,VDset_proj_view,
				VDset_setup_name,VDget_setup_name,
				VDget_setup_name_size;
from  GRcontext         import  GRgetmodule_env;

extern	GRclassid	OPP_VDcontext_class_id,
			OPP_ci_mac_def_class_id,
			OPP_VDCmdDrwFr_class_id,
			OPP_VDdrawing_class_id;
extern	struct GRid	AC_construct_id;
extern			ACconstruct_wd(), ACconstruct_path();

extern  char * calloc();
extern  char * malloc();
extern  char * realloc();

extern  int UI_status();

#define AS_DEBUG
#define SETUP_FIELD	12

#define set_generic 0x10000000

%safe
  int VDlocal_change = 0;
%endsafe
struct  GRid            vdcontext_id;

/*
extern int 		VDlocal_change;
extern struct GRid	vdcontext_id;
*/

extern GRclassid	OPP_DMroot_class_id;

/* action and state table  */

#define NUM_STATES 	3
#define NUM_ACTIONS 	9
#define NUM_TOKENS 	3

/*
   different states and actions used in the state/action tables
*/

#define MAX_OBJ_NUM 60

enum possible_states { 	WAIT_OBJ 
		     };

enum possible_actions {	NIL,
			ERR,
			RESTART,
			REG_EXP,
			LOC_OBJ,
			STO_OBJ,
			EXTRACT
	 	       };

/* Possible entries */

enum possible_entries { PARENT,
			POINT,
			NOENT };

method sleep ( IGRint pos )
{
int	status;


 status = _VD_SEND_WRT_M( my_id, COpara.sleep(pos));
 return (status);

}


method wakeup ( IGRint n )
{
 int 			status;
//extern int 		VDlocal_change;

 status = _VD_SEND_WRT_M( my_id, COpara.wakeup(n));
 ex$message(msgnumb = VD_M_ExDr);

 /* TR# 6318 - 05/10/2002
 if(VDlocal_change == 0) {
   ex$message(msgnumb = VD_S_ModNScal);
  }
 else if (VDlocal_change == 1) {
   ex$message(msgnumb = VD_S_LocScal);
  }
 else if (VDlocal_change == 2) {
   ex$message(msgnumb = VD_S_ModScal);
  }
  */
 return (status);
}

%safe

static IGRint TokenList[] =
 		      {
			RESET,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ****************** TOKENS ***********
   Old State  *    RESET   , UNKNOWN , PARENT     */

/* WAIT_OBJ   */ { WAIT_OBJ,WAIT_OBJ , WAIT_OBJ  }};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            *************TOKENS ********************
   Old State  *     MOVE_ON    , UNKNOWN   , PARENT    */

/* WAIT_OBJ   */ { EXTRACT     , LOC_OBJ   , STO_OBJ   }};
%endsafe


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
IGRint      	status;         /* routine return status */
IGRint      	event_size;     /* size of GRevent buffer */
IGRlong     	display_flag;   /* display flag for locate filter */
IGRlong     	input_mask;     /* mask for GRgetevent */
IGRlong     	locate_mask;    /* mask for GRgetevent */
IGRlong     	loc_msg;        /* function return code */
struct GRevent 	grevent1, grevent2;  /* event returned by GRgetevent */
struct GRid  	macId, context; /* object located        */
IGRint 		resp;
IGRint 		j,token;
IGRint 		obj_generic;
IGRint 		nb_obj,i_obj;
IGRchar		full_path[256];
struct GRobj_env 	*obj_to_print;
struct ret_struct rst;
struct GRid located_obj,source;

//*response = TERMINATE;
  token = 0;

  obj_generic = macro_generic | set_generic;
  event_size = sizeof (struct GRevent);
  locate_mask = GRm_DATA|GRm_STRING|GRm_RESET|GRm_BACK_UP;
  input_mask  = GRm_DATA|GRm_STRING|GRm_RESET|GRm_BACK_UP; 
  display_flag = ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;

  me->attr.properties   = LC_LC_ONLY | LC_RW ;
  me->attr.owner_action = LC_RIGID_OWNER | LC_RIGID_COMP
			  | LC_REF_OBJECTS | LC_NO_REF_HEADER
                       	  | LC_FLEX_COMP   | LC_FLEX_OWNER;

  ex$message(buff = me->loc_prompt, msgnumb = VD_P_IdElEx);
  ex$message(buff = me->acc_prompt, msgnumb = VD_P_AccNex);

/* Modified by Sandeep for fence problem  */

  if ( *response == COMMAND || *response == D_RESET   )
  {
    /* 
     * Get setup file name
     */
    VDdrwSetSetupFileName("");

    status = _VD_SEND_MY( VDm_drawing.get_setup_file());
    if(!(status&1)) return OM_W_ABORT;

    /*
     * Define drawing macro
     */
    status = _VD_SEND_MY( VDm_drawing.read_drawing_macro());
    if(!(status&1)) return OM_W_ABORT;
  }

  *response = TERMINATE;

  /*
   *  loop until exit condition occurs
   */
  do{
      switch (me->action)
      {       
	 case NIL :     /*| nil */
	   break;

	 default :
	 case ERR :    /*| err  */
	   ex$message( msgnumb = AS_E_InvDefRest);


	 case RESTART : /*| restart */
	   me->state = WAIT_OBJ;
	   me->action= LOC_OBJ;
	   me->Nb_Max_Obj = 0;
	   me->Entry_Request = NOENT;
	   me->display_window.objid = NULL_OBJID;
	   break;

	 case STO_OBJ :   /*| sto_obj */
	   if(grevent1.response != SPECIFIED_OBJ)
	    {
	     status = EXputq_front(	&loc_msg,
					&resp,
					(IGRlong *) &event_size,
				   	(IGRchar *)&(grevent2.event));
	     if(me->display_window.objid == NULL_OBJID)
	      {
	       me->display_window.objid = grevent1.event.button.objid;
	       me->display_window.osnum = grevent1.event.button.osnum;
              }
 	    }

	   /* expend fence contents if necessary */

	       VDS_set_disthruref();
	       as$start_fence(set	= &located_obj,
			  set_env    = &grevent1.located_object[0].module_info,
			  nb_obj	= &nb_obj,
			  p_obj_env	= &obj_to_print,
			  response	= &resp,
			  response_data = response_data,
			  type_generic	= obj_generic,
			  macro_name = me->locate_type);
	       VDS_reset_disthruref();

	     __DBGpr_int(" nb_obj ", nb_obj  );
             status =
	     _VD_SEND_MY( VDm_drawing.realloc_obj (me->Nb_Max_Obj+nb_obj));
             as$status(action = RET_STATUS);

	     for(i_obj=0 ; i_obj<nb_obj ; i_obj++)
	      {
	       /* If they DMroot objects, just throw them away - RR 02/06/01
		  TR# 4587 */
	       if (vd_$is_ancestry_valid( object  = &obj_to_print[i_obj].obj_id,
			classid = OPP_DMroot_class_id ) ) continue;
	       
	       /* find context(s) and make sources */

		__DBGpr_obj(" OBJECT ", obj_to_print[i_obj].obj_id );

               status = GRfindcontext( &loc_msg,
		               &obj_to_print[i_obj].mod_env.md_env.matrix_type,
				obj_to_print[i_obj].mod_env.md_env.matrix,
                     	       &obj_to_print[i_obj].obj_id.osnum,
				&context );
		if( status != OM_S_SUCCESS || loc_msg != MSSUCC )
			context.objid = NULL_OBJID ;

	       /* create the default path for the macro library */
               status = di$give_pathname(
				osnum    = me->ModuleInfo.md_id.osnum,
                                pathname = full_path );
               strcat( full_path, ":constructs" );

               status = di$translate(objname = full_path,
                                     p_objid = &macId.objid,
                                     p_osnum = &macId.osnum );
               if( !(status&1)){
                 status = ac$construct_path( mode    = AC_ADD_PATH,
                                             name    = "." );
                 if( !(status&1)){
                   printf("Can't get construct path directory: %s\n",
								full_path );
                   return OM_W_ABORT;
                 }
                 status = ac$construct_wd(   mode    = AC_SET,
                                             name    = "." );
                 if( !(status&1)){
                   printf("Can't get construct working directory: %s\n",
								full_path );
                   return OM_W_ABORT;
                 }
               }

	       status = as$make_source( go_grid = obj_to_print[i_obj].obj_id,
			       context_grid = context,
			       as_os = me->ModuleInfo.md_id.osnum,
			       as_grid = &source);
	       if(status&1)
	        {
	         /* Search if already located */
	         for(j=0;j<me->Nb_Max_Obj;j++)
	           {if(me->Obj_List[j].objid == source.objid ) break;}
	         if(j>=me->Nb_Max_Obj)
                 me->Obj_List[me->Nb_Max_Obj++]= source;
		}
	      }
	     ASend_fence();

	     __DBGpr_int(" Nb_Max_Obj ", me->Nb_Max_Obj );

/* */
	     if( me->Nb_Max_Obj ){
		struct	GRid		modObj ;
		struct	GRmd_env	modEnv ;
		IGRlong			lmsg ;

		for( i_obj=0 ; i_obj<me->Nb_Max_Obj; i_obj++ ){
		  status =
		  om$send(msg = message NDmacro.ACreturn_foot(
					&lmsg, "", &modObj,
                                        &modEnv.md_env.matrix_type,
                                        modEnv.md_env.matrix ),
			targetid = me->Obj_List[i_obj].objid,
			targetos = me->Obj_List[i_obj].osnum,
			senderid = me->Obj_List[i_obj].objid );
		  if( !(status&lmsg&1)) continue ;

        	  modEnv.md_id.osnum = modObj.osnum;
		  status = ex$get_modid( mod_osnum = modEnv.md_id.osnum,
                       		         mod_id    = &modEnv.md_id.objid );

		  vd_$bulk_display(	count	= 1,
					dpmode	= GRhd,
					grids	= &modObj,
					theEnv	= &modEnv );
		}
	     }
/* */

        case LOC_OBJ :    /*| loc obj */
	   me->Entry_Request = PARENT; 
	   break;

	case EXTRACT :   /*| grap print */

	  /*
	   * Test if there are amy objects selected to extract.
	   */
	  if( me->Nb_Max_Obj ) {

	    /* extract geometry */
	    ex$message(msgnumb = VD_S_ChaSca);

	    status = _VD_SEND_MY( VDm_drawing.change_scale());
            as$status();

            ex$message(msgnumb = VD_S_ExtPro);

	    status = _VD_SEND_MY( VDm_drawing.extract());
            as$status();
            ex$message(msgnumb = VD_S_Done);
	  }

	  /* restart the command */
          me->Entry_Request = PARENT;
	  me->action = RESTART;
	  me->Entry_Request = NOENT;
	  break;
	
      }   /* end switch (me->state) */


    switch( me->Entry_Request)
    {
     case POINT :  /*| PROMPT */
          token = GRget_token(&status,TokenList,&input_mask,&grevent1,
                	      &event_size,&resp,response_data);
          break;

     case PARENT :  /*|  arent */
	  VDS_set_disthruref();
  	  token = as$get_parent(event1 = &grevent1,event2 = &grevent2,
			locate_mask = locate_mask,input_mask = input_mask, 
			response = &resp,
			type_generic = obj_generic,
			macro_name = me->locate_type,
			returned_obj = &located_obj,
			returned_context = &context,
			returned_struct = &rst);
	  VDS_reset_disthruref();

	  __DBGpr_int(" grevent1.response ", grevent1.response );

          break;
     
     case NOENT :  /*| Noent */
          break;

    }/* end of switch */

/* new action and new state */
	
     if(me->Entry_Request != NOENT)
      {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
      }
  /*"token %d me->action %d me->state %d\n",token,me->action,me->state*/

    } while(me->Entry_Request == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

    *response = resp;
    /*"response %d\n",*response */


    return( OM_S_SUCCESS);

}   /*  end execute method */

method realloc_obj(int nb_obj)
{
 long status;
 int previous_size;

  previous_size = om$dimension_of(varray = me->Obj_List);
  if(nb_obj > previous_size)
   {
     previous_size = 20*(nb_obj/20 +1);
             status = om$vla_set_dimension(varray = me->Obj_List,
                                           size = previous_size);
             as$status(action = RET_STATUS);

   }
  return OM_S_SUCCESS;
}

method extract()
{
 long loc_msg,status,error;
 int i_obj,i,count;
 char *model_def_name;
 struct GRid model_obj,model_def,drawing_def,drawing_obj,source,
	     *feet = NULL;
 int i_macro,nb_drawing_macros = 0;
 char **drawing_macros = NULL;
 char dir_name[DI_PATH_MAX];
 int nb_feet,feet_size = 0;
 struct myfeet *feet_desc; 
 struct GRmd_env model_env;
 enum GRdpmode dp_mode = GRbd;
 struct ACdb_info db_info;
 int level[32];
 struct var_list w_info[2];
 long bytes_returned;
 double vector[3],point[3];
 int nb_total,nb_attachement,nb_created;
 GRname			echoProc,msg;
 

 /* Get drawing macro */

  status = di$give_pathname ( osnum =  me->ModuleInfo.md_id.osnum,
                              pathname =  dir_name);
  strcat(dir_name,":constructs:*");

 di$ls(regexp=dir_name,
       lines = &drawing_macros,
       ptr = &nb_drawing_macros,
       options = 0);

 /* Get displayable level and view definition */

 for(i=0;i<2;i++)  vector[i] = 0;
 vector[2] = 1;
 for(i=0;i<3;i++)  point[i] = 0;

 if(me->display_window.objid != NULL_OBJID)
  {
   w_info[0].var = LEVELS;
   w_info[0].num_bytes = 32*sizeof(int);
   w_info[0].bytes_returned = &bytes_returned;
   w_info[0].var_ptr = (char *) level;
   w_info[1].var = END_PARAM; 
   status = om$send(msg = message IGEgragad.DPinquire(&loc_msg,&error,w_info),
		    targetid = me->display_window.objid,
		    targetos = me->display_window.osnum);
   as$status(action = RET_STATUS);

#if 0
   status = om$send (msg = message IGEgragad.DPinrot(&loc_msg,view_rot),
                    targetid = me->display_window.objid,
                    targetos = me->display_window.osnum);
   as$status(action = RET_STATUS);
   vector[0] = view_rot[8];
   vector[1] = view_rot[9];
   vector[2] = view_rot[10];

   point[0] = view_rot[12];
   point[1] = view_rot[13];
   point[2] = view_rot[14];
#endif
  }
 else
  { 
   for(i=0;i<32;i++) level[i] = ~0;
  }


 model_env.md_id.objid = NULL_OBJID;

/*"nb_obj %d\n",me->Nb_Max_Obj*/

nb_total = me->Nb_Max_Obj;
while (1)
{

/* works one reference file attachement at the time */

 NDsort_per_context(nb_total,me->Obj_List,&nb_attachement);

 if(!(nb_attachement)) break;

/* 
  add in the context object info like model file name, displayable level
  and view definition by changing its class to VDcontext
*/

 status = VDstore_levels_and_vol( me->Obj_List, nb_attachement, 
			level, point, vector, &me->ModuleInfo);
 /* If failed, goto reorder_list, instead of exiting the function. - TR# 3413 */
 if( !(status&1) ) 
 {
    printf( "Local Elements extraction failed!!!\n" );
    goto reorder_list ;
 }
 /* as$status(action = RET_STATUS); */


 nb_created = 0;
 for(i_obj=0 ; i_obj < nb_attachement ; i_obj++)
 {
   /* 
   Get macro definition of the selected object and search if there is a 
   drawing macro definition valid for this type of macro to know which 
   attributes should be extracted
   */

   /*
    * Ask for signal.
    */
   if( IGEstop()){
	/*
         * Request to stop process.
         */
        *msg = MSFAIL ;
        goto wrapup ;
   }
   /* 
    * fix of TR on needing status reported for long operations
    */
   sprintf(echoProc, "Pre-Processing Design File %.0f%% ",
                                (double)(i_obj*100./(double)nb_attachement) );
   UI_echo( echoProc );

   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",
				&model_obj,&model_env.md_env.matrix_type,
				model_env.md_env.matrix),
		    targetid = me->Obj_List[i_obj].objid,
		    targetos = me->Obj_List[i_obj].osnum);
   model_env.md_id.osnum = model_obj.osnum;
   if(!(status&loc_msg&1)) continue;

   status = om$send(msg = message ACcpx.find_macro(&model_def),
		    targetid = model_obj.objid,
		    targetos = model_obj.osnum);
   if(!(status&1)) continue;
   status = om$send(msg = message ACcpx_defn.ACgive_name(&model_def_name),
		    targetid = model_def.objid,
		    targetos = model_def.osnum);
   if(!(status&1)) continue;


   for(i_macro=0;i_macro<nb_drawing_macros;i_macro++)
     {
      status = di$translate(objname = drawing_macros[i_macro],
	      p_objid = &drawing_def.objid,
	      p_osnum = &drawing_def.osnum);

      if(!(status&1)) continue;
      status=om$send(msg = message ACcpx_defn.ACgive_feet_desc
							  (&nb_feet,&feet_desc),
		     targetid = drawing_def.objid,
		     targetos = drawing_def.osnum);
      if(!(status&1)) continue;
      if(nb_feet < 1) continue; /* facking macro for leader line */
      if(ASmatchRE(feet_desc[nb_feet-1].name,model_def_name)) break;
     }
   if(i_macro >=  nb_drawing_macros) continue;

   if(nb_feet>feet_size)
   {
	if(feet) om$dealloc(ptr = feet);
	feet_size=nb_feet;
	feet=(struct GRid *) om$malloc(size=nb_feet*sizeof(struct GRid));
   }

   /*
    * Check if occurence already exist of input object.
    */
   drawing_obj.objid = NULL_OBJID ;
   status = VDchk_child_on_class(	&loc_msg,
					&model_obj,
					&(me->Obj_List[i_obj]),
					"VDdrawing",
					&drawing_obj );
   if( drawing_obj.objid == NULL_OBJID ){

     __DBGpr_com(" Construct New Macro " );

     /* initialize the drawing macro with this */
     status =
     om$construct(classid = OPP_VDdrawing_class_id,
			 osnum = me->ModuleInfo.md_id.osnum,
			 msg = message NDnode.NDconnect(1,me->Obj_List+i_obj,
						NULL_GRID,ND_NEW),
			 p_objid = &drawing_obj.objid);
     if(!(status&1)) continue;

     drawing_obj.osnum = me->ModuleInfo.md_id.osnum;
     status =
     om$send(msg = message ACcpx.ACload_macro(drawing_def),
	     targetid = drawing_obj.objid, 
	     targetos = drawing_obj.osnum);
     me->Obj_List[nb_created++]= drawing_obj;
   }
   else{
	/*
	 * Check if object is already in list.
	 */
	__DBGpr_com(" Check in existing list " );

	for( i=0 ; i<nb_created; i++ )
	  if( IF_EQ_GRID( drawing_obj, me->Obj_List[i] )) break ;
	if( i>=nb_created )	me->Obj_List[nb_created++]= drawing_obj;
   }
		
   /* Initialize db_info for the drawing part */
   status =
   om$send(msg = message ACdb_info.ACcheckin_candidate
				(VDS_NORMAL_CHECKIN,(int *)&loc_msg),
           targetid = model_obj.objid,
           targetos = model_obj.osnum);
   if(!(status&loc_msg&1))
     status =
     om$send(msg = message ACdb_info.ACcheckin_candidate
				(VDS_FAST_CHECKIN,(int *)&loc_msg),
             targetid = model_obj.objid,
 	     targetos = model_obj.osnum);

   if(status&loc_msg&1){
     status =
     om$send(msg=message ACdb_info.ACget_db_info(&loc_msg,&db_info),
	     targetid = model_obj.objid,
	     targetos = model_obj.osnum);
     if(!(status&loc_msg&1)){
       /*
        * ad/alain: Instead of stopping the drawing extraction, give warning
        *	     for current object without database information and
        *	     continue with drawing extraction.
        */

	IGRchar	classname[100];

	om$get_classname(	objid	= model_obj.objid,
				osnum	= model_obj.osnum,
				classname = classname );

	printf("WARNING: %s [%d,%d] no db_info found.\n",
				classname, model_obj.objid, model_obj.osnum );

	/* return OM_W_ABORT; */

	continue;
     }
     status =
     om$send(msg = message ACdb_info.ACset_db_info(&loc_msg,&db_info),
             targetid = drawing_obj.objid,
             targetos = drawing_obj.osnum);

     status =
     om$send(msg = message ACdb_info.ACput_serial_no(db_info.serial_no),
	    targetid = drawing_obj.objid,
	    targetos = drawing_obj.osnum);
    }
 } /* for ... */

 UI_echo( " " );
 /* Now compute the initialized drawing macro, affect them db_info and display*/

 for(i_obj=0 ; i_obj < nb_created ; i_obj++)
  {

   if( IGEstop()){
        /*
         * Request to stop process.
         */
        *msg = MSFAIL ;
        goto wrapup ;
   }
   /* 
    * fix of TR on needing status reported for long operations
    */
   sprintf(echoProc, "Processing Design File %.0f%% ",
                                (double)(i_obj*100./(double)nb_created) );
   UI_echo( echoProc );

   status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,&source,1,NULL,
				   0,OM_K_MAXINT,&count),
		    targetid = me->Obj_List[i_obj].objid,
		    targetos = me->Obj_List[i_obj].osnum);

   status = om$send(msg = message ACncpx.ACconstruct_feet(&loc_msg,0,1,&source,
				   &me->ModuleInfo,&nb_feet,feet),
		    targetid = me->Obj_List[i_obj].objid,
		    targetos = me->Obj_List[i_obj].osnum);

   if(status & loc_msg &1)
    {
     status = om$send(msg = message ACncpx.ACchange_feet
                                        (nb_feet,feet,&me->ModuleInfo),
                    targetid = me->Obj_List[i_obj].objid,
                    targetos = me->Obj_List[i_obj].osnum);

     status = om$send(msg = message GRgraphics.GRdisplay(&loc_msg,
					&me->ModuleInfo.md_env.matrix_type,
					 me->ModuleInfo.md_env.matrix,
					&dp_mode,&me->ModuleInfo.md_id),
		    targetid = me->Obj_List[i_obj].objid,
		    targetos = me->Obj_List[i_obj].osnum);
    }
   else status = om$send(msg = message GRgraphics.GRdelete
				(&loc_msg,&me->ModuleInfo),
		    targetid = me->Obj_List[i_obj].objid,
		    targetos = me->Obj_List[i_obj].osnum);

		    
  }

reorder_list:

  UI_echo( " " );

 /* Prepare extraction of following elements */
 OM_BLOCK_MOVE(me->Obj_List+nb_attachement,me->Obj_List,
	       (nb_total-nb_attachement)*sizeof(struct GRid));
 nb_total -= nb_attachement;
}

wrapup:

 if(drawing_macros && nb_drawing_macros)
    di$free(lines = drawing_macros,
	    count = nb_drawing_macros);


 UI_echo("");
 return OM_S_SUCCESS;
}

method change_scale()
{
 struct GRid *list1,*list2,model,exp_scale;
 int nlist1,nlist2,nlist_os;
 long loc_msg,status;
 int i_obj,j_obj,j;
 struct GRmd_env model_info;
 int some_change;
 short matrix_type;
 double matrix[16];
 char *ptr_list;
 double fabs(),sqrt();
 OM_S_OBJID model_md;
 long rt_status,rt_msg;
 
 if(VDlocal_change == 0) return (OM_S_SUCCESS);

 /* Init */
 ptr_list = NULL;

 /* Get model object */

 ptr_list = om$malloc(size = me->Nb_Max_Obj * sizeof(struct GRid));
 list1 = (struct GRid *) ptr_list;
 if(!list1) return OM_W_ABORT;
 nlist1 = 0;
 
 for(i_obj=0;i_obj<me->Nb_Max_Obj;i_obj++)
  {
   status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,"",
                                &model,&matrix_type,matrix),
                    targetid = me->Obj_List[i_obj].objid,
                    targetos = me->Obj_List[i_obj].osnum);
   if(!(status&loc_msg&1)) continue;
   me->scale = matrix[0]*matrix[0] + matrix[1]*matrix[1] + matrix[2]*matrix[2];
   if(me->scale > 1.e-10) me->scale = 1/sqrt(me->scale);
   else me->scale = 1;
   for(j=0;j<nlist1;j++)
    {if(model.objid == list1[j].objid && model.osnum == list1[j].osnum) break;} 
   if(j >= nlist1) list1[nlist1++] = model;
  }
 
 /* loop per OS */

 model_info= me->ModuleInfo;
 while(nlist1>0)
 {
  NDsort_per_OS1(nlist1,list1,&nlist_os);
  model_info.md_id.osnum = list1[0].osnum;
  ex$get_modid(mod_osnum = list1[0].osnum,
	       mod_id = &model_md);

 /* Search wich one of these elements needs to change scale */

  some_change = 0;
  exp$create(exp_value = me->scale,
		exp_name = NULL,
	     osnum = list1[0].osnum,
	     p_exp_id = &exp_scale.objid);
  exp_scale.osnum = list1[0].osnum;


if(VDlocal_change == 1)
 {
/* Only rescale elements depending directly from scale */

  for(i_obj=0 ; i_obj<nlist_os; i_obj++)
   {
    if(VDchg_scale(list1+i_obj,me->scale,&exp_scale,&me->ModuleInfo))
     {
      /* The element is scale dependent and needs to be recomputed */
      some_change = TRUE;
      model_info.md_id.objid = model_md;
      rt_status = om$send(msg = message GRgraphics.GRremwrng
                                                    (&rt_msg,&model_info),
                       senderid = NULL_OBJID,
                       targetid =list1[i_obj].objid,
                       targetos =list1[i_obj].osnum);
      model_info.md_id.objid = NULL_OBJID;
      status = om$send(msg = message NDnode.NDs_compute_node(&loc_msg,0,
						&model_info),
		      targetid = list1[i_obj].objid,
		      targetos = list1[i_obj].osnum);
      as$status();
      if(rt_status&rt_msg&1)
       {
	model_info.md_id.objid = model_md;
        status = om$send(msg = message GRgraphics.GRaddwrng
                                                    (&loc_msg,&model_info),
                             targetid =list1[i_obj].objid,
                             targetos =list1[i_obj].osnum);
       }

     }
   }
 }
else
 {
/* search if parents are scale dependent */

  for(i_obj=0 ; i_obj<nlist_os; i_obj++)
   {
    nd$get_graph(p_tip = list1+i_obj, nb_tip = 1);
    status=nd$get_list_in_graph(acc_type=ND_BODY | ND_EXTERN | ND_ROOT | ND_TIP,
                              p_count = &nlist2,
                              buf_addr = &list2);
    for(j_obj=0; j_obj<nlist2 ; j_obj++)
    {
     if(VDchg_scale(list2+j_obj,me->scale,&exp_scale,&me->ModuleInfo))
      {
        /*" %d %d scale dependent\n",list2[j_obj].objid,list2[j_obj].osnum */
	some_change = TRUE;
      }
    }
   }

  if(some_change)
   {
    nd$get_graph(p_root = &exp_scale , nb_root = 1);
    status=nd$get_list_in_graph( p_count = &nlist2,
				 acc_type = ND_BODY,
				 buf_addr = &list2);
    for(j_obj=0; j_obj<nlist2 ; j_obj++)
    {
     if(nd$dep_exist(l_root = list2 + j_obj, nb_root = 1,
		     l_tip = list1, nb_tip = nlist_os))
       {
        /*"index %d %d %d recomputed\n",j_obj,list2[j_obj].objid,list2[j_obj].osnum */
      
	model_info.md_id.objid = model_md;
        rt_status = om$send(msg = message GRgraphics.GRremwrng
                                                    (&rt_msg,&model_info),
                       senderid = NULL_OBJID,
                       targetid =list2[j_obj].objid,
                       targetos =list2[j_obj].osnum);
	/*" range status %x mdg %x\n",rt_status,rt_msg */

	model_info.md_id.objid = NULL_OBJID;
        status = om$send(msg = message NDnode.NDs_compute_node(&loc_msg,0,
						&model_info),
		             targetid = list2[j_obj].objid,
		             targetos = list2[j_obj].osnum);
        as$status();
	model_info.md_id.objid = model_md;
        if(rt_status&rt_msg&1)
         {
          status = om$send(msg = message GRgraphics.GRaddwrng
                                                    (&loc_msg,&model_info),
                             targetid =list2[j_obj].objid,
                             targetos =list2[j_obj].osnum);
         }
	{enum  GRdpmode dpmode = GRbd;
	ACset_disthruref();
        status = om$send(msg = message GRgraphics.GRdisplay
                                              (&loc_msg,
					    &me->ModuleInfo.md_env.matrix_type,
					    me->ModuleInfo.md_env.matrix,
					    &dpmode,
					&me->ModuleInfo.md_id),
                             targetid =list2[j_obj].objid,
                             targetos =list2[j_obj].osnum);
	ACreset_disthruref();
	 }
 } } } }
  list1 += nlist_os; 
  nlist1 -= nlist_os;
 } /* end while on different OSs */

  if(ptr_list) om$dealloc(ptr = ptr_list);
			       
 return OM_S_SUCCESS;
}

method read_drawing_macro()
{
/* 
   This method initializes the drawing macro and the name of locatable parts.
   A predefined ASCII file is read to define the macro definitions to create.
   The file is called DrawingTable and is found in <product>/config/.

   The macro definitions are created in the default working directory "."
*/
#define MAX_FEET 200

long	status,loc_msg;
FILE	*input_file;

int	temp_type,len_locate_type;
int	nb_feet,i_feet,nb_feet_def;
char	tpname[macro_MAX_CHAR];
char	*temp_name, *feet_names[MAX_FEET];
char	ftname[MAX_FEET*macro_MAX_CHAR];
char	drawing_macro_name[macro_MAX_CHAR],
	model_macro_name[macro_MAX_CHAR],
	full_macro_name[80];
char	full_path[200];
char	cur_mac_lib[macro_MAX_CHAR+1];
int	cur_mac_len;

int	from_setup;

OM_S_OBJID drawing_macro;
struct	myfeet *feet_def;
struct	GRid	mac_lib_id;
GRclassid current_class;

 /* Template name and type init */

//printf("Entered read_drawing_macro\n");

  status = OM_S_SUCCESS;

  temp_type = 0;
  strcpy(tpname, "model" );
  temp_name = tpname;

  /* initialisation of the feet name table */
  VDinit_feet_name( ftname, feet_names, MAX_FEET);

  /* test if a macro library is active */
  cur_mac_lib[0] = '\0';
  cur_mac_len    = 0;
  status = ac$construct_wd(mode 	= AC_INQ,
			   name		= cur_mac_lib,
			   name_size	= macro_MAX_CHAR,
			   name_len	= &cur_mac_len );
  if( !(status&1)) return( status );

  /* create the default path for the macro library */
  status = di$give_pathname(	osnum	=  me->ModuleInfo.md_id.osnum,
				pathname = full_path );
  strcat( full_path, ":constructs" );

  status = di$translate(objname = full_path,
			p_objid = &mac_lib_id.objid,
			p_osnum = &mac_lib_id.osnum );
  if( !(status&1)){
    status = ac$construct_path(	mode	= AC_ADD_PATH,
				name	= "." );
    if( !(status&1)){
      printf("Can't get construct path directory: %s\n", full_path );
      return OM_W_ABORT;
    }
    status = ac$construct_wd(	mode	= AC_SET,
				name	= ".",
				dir	= &mac_lib_id );
    if( !(status&1)){
      printf("Can't get construct working directory: %s\n", full_path );
      return OM_W_ABORT;
    }
  }

  /*
   * search or initialize macro definition for geometry
   */
  sprintf(full_macro_name, "%s:VDgeomdef", full_path );
  status = di$translate(	objname = full_macro_name,
				osnum   = mac_lib_id.osnum,
				p_objid = &me->geom_macro.objid,
				p_osnum = &me->geom_macro.osnum);
  if( !(status&1)){

    status =
    om$construct(classid = OPP_ci_mac_def_class_id,
		osnum = mac_lib_id.osnum,
		p_objid = &me->geom_macro.objid,
		msg = message ci_mac_def.ACplace
					((int *)&loc_msg,0,"VDgeomdef",
					 "",0,1,&temp_name,&temp_type,
					 0,NULL,NULL,0,NULL,NULL,
					 MAX_FEET,feet_names,NULL,NULL)); 
    me->geom_macro.osnum = mac_lib_id.osnum; 
    as$status();
  }

  /*
   * search or initialize macro definition for frame extraction
   */

  len_locate_type = 0;
  sprintf(full_macro_name, "%s:drawing_frame", full_path );
  status = di$translate(objname = full_macro_name,
			osnum   = mac_lib_id.osnum,
			p_objid = &me->geom_macro.objid,
			p_osnum = &me->geom_macro.osnum);
  if( !(status&1)){
    nb_feet = 0;
    VDadd_predef_feet(&nb_feet,feet_names);
    strcpy(feet_names[nb_feet++],"VD*Pl*|SM*Pl*");

    /*
     * construct the macro definition
     */
    status =
    om$construct(classid = OPP_ci_mac_def_class_id,
		osnum = mac_lib_id.osnum,
		p_objid = &drawing_macro,
		msg = message ci_mac_def.ACplace
					((int *)&loc_msg,0,"drawing_frame",
					 "",0,1,&temp_name,&temp_type,
					 0,NULL,NULL,0,NULL,NULL,
					 nb_feet,feet_names,NULL,NULL));
  }

  /* add by ad */
  status = om$get_classid(      objid = my_id,
                                osnum = OM_Gw_current_OS,
                                p_classid = &current_class);
  as$status(action = RET_STATUS);

/* Modified by Sandeep  
   It should return if command is VDCmdDrwFr */

  if( om$is_ancestry_valid ( subclassid= current_class,
                    superclassid = OPP_VDCmdDrwFr_class_id) == OM_S_SUCCESS) {
  	return OM_S_SUCCESS;
  }
	


 /*
    Try to read the macro to extract from struct set up file , and if
    it doesn't work, take them from file DrawingTable
 */

 input_file = NULL;
 if(VDinit_from_drawing_setup()) from_setup = 1;
 else                            from_setup = 0;

 while(1)
  {
   if(from_setup > 0)
    {
     if(VDread_from_drawing_setup(drawing_macro_name,
	model_macro_name,feet_names,&nb_feet,MAX_FEET) == EOF)
       {
	if(from_setup ==2) break;
	else {from_setup = 0; continue;}
       }
     else
       {
	if(drawing_macro_name[0] == '\0') continue;
        /* Changed the value of from_setup to 2 instead of 0;
           Change made on 07/14/97 by A.Gupta
        */
	from_setup =  2 /*0*/;
       }
    }
   else if(from_setup == 0)
    {
     VDinit_from_DrawingTable(&input_file);
     if(!input_file) break;
     from_setup = -1;
     continue;
    }
   else
    {
     if(VDread_from_DrawingTable(input_file,drawing_macro_name,model_macro_name,
	feet_names,&nb_feet,MAX_FEET) == EOF) break;
    }

   /* That's because ci_mac_def.ACplace only accept ci_macro with 
      name_len = macro_MAX_CHAR-1
   */
   drawing_macro_name[macro_MAX_CHAR-2] = '\0';


/* construct search criteria */

   if(len_locate_type && len_locate_type < TYPE_MAX-1)
    {strcpy(me->locate_type+len_locate_type,"|");
     len_locate_type++;
    }
   if(strlen(model_macro_name) < TYPE_MAX - len_locate_type -1)
     {
      strcpy(me->locate_type+len_locate_type,model_macro_name);
      len_locate_type += strlen(model_macro_name);
     }


    /*
     * Add now feet with predefined names
     */

    VDadd_predef_feet(&nb_feet,feet_names);
    strncpy(feet_names[nb_feet],model_macro_name,macro_MAX_CHAR);
    (feet_names[nb_feet++])[macro_MAX_CHAR-1] = '\0';

    /*
     * contruct the macro definition if it does not already exist
     */

    sprintf(full_macro_name, "constructs:%s", drawing_macro_name );
    status = di$translate(	objname	= full_macro_name,
				osnum	= mac_lib_id.osnum,
				p_objid	= &drawing_macro);
    if(status&1){

      /*
       *  controle if the macro definition matches with the file definition
       */
      status = om$send(msg = message ACcpx_defn.ACgive_feet_desc
					(&nb_feet_def,&feet_def),
		       targetid = drawing_macro,
		       targetos = mac_lib_id.osnum,
		       senderid = NULL_OBJID);
      i_feet = -1;
      if(status&1 && nb_feet_def == nb_feet){
	for(i_feet=0;i_feet<nb_feet;i_feet++)
	 if(strcmp(feet_names[i_feet],feet_def[i_feet].name)) break;
      }
      if(i_feet >= nb_feet) continue;

      /* if the definition is changed
        - tell the user 
        - remove the name of previous def
      */

      status = 
      om$send(msg = message ACcpx.GRchgname( &loc_msg, &me->ModuleInfo, NULL),
	      targetid = drawing_macro,
	      targetos = mac_lib_id.osnum,
	      senderid = NULL_OBJID);
      as$status();
      ex$message(msgnumb = VD_S_WarMod, type = "%s",var = `drawing_macro_name`);
    }

    /*
     * construct the macro definition
     */
    status =
    om$construct(classid = OPP_ci_mac_def_class_id,
		osnum = mac_lib_id.osnum,
		p_objid = &drawing_macro,
		msg = message ci_mac_def.ACplace
					((int *)&loc_msg,0,drawing_macro_name,
					 "",0,1,&temp_name,&temp_type,
					 0,NULL,NULL,0,NULL,NULL,
					 nb_feet,feet_names,NULL,NULL));
    as$status(); 
  }

  if(input_file) fclose(input_file);
  return OM_S_SUCCESS;

}

/* ----------------------------------------------------
 * Get the setup file name from either VScontext or
 * from the user
 */
method get_setup_file()
{
  IGRlong msg;

  IGRint       contextCNT  = 0;
  struct GRid *contextLIST = NULL;
  struct GRid  contextID;

  IGRchar setupName[1024];
  IGRchar buf[1024];

  IGRint  response;
  struct  GRevent event;

  // Init
  VDdrwSetSetupFileName("");
  *setupName = 0;
  contextCNT  = 0;
  contextLIST = NULL;
  contextID.objid = NULL_OBJID ;

  if (*setupName == 0) strcpy(setupName,"setup");
  VDdrwSetSetupFileName(setupName);

get_filename:

  sprintf(buf," Default file name: '%s' ", setupName);
  UI_status(buf);

  response = 0;
  co$getevent (
    msg           = &msg,
    event_mask    = "GRm_STRING | GRm_RJT_MOVEON",
    prompt        = "Enter Setup Filename",
    response      = &response,
    response_data = buf,
    event         = &event 
  );

  if (response == GRm_STRING ) {
    if (strlen(buf) > 0) {

      /*
       * Check the setup file.
       */
      {
	GRname			relPathName, absPathName, firstDir;
	GRname			err;

	strcpy( relPathName, buf );
	strcpy( firstDir, "." );

        VD_findFileInDirOrProductPaths(	&msg,
					relPathName,
					firstDir,
					VD_K_DRW_CONFIG_RELPATH,
					absPathName );
	if( !(msg & 1 )){
		strcpy (err, "Setup file not found: ");
		strncat (err, buf, 80);
		UI_error (err);
		goto get_filename ;
        }
      }

      VDdrwSetSetupFileName(buf);
    }
  }

//wrapup:
  if (contextLIST) free(contextLIST);
  return OM_S_SUCCESS ;
}


end implementation VDm_drawing;
