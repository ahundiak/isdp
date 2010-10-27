/* $Id: VDm_rextraci.I,v 1.1.1.1 2001/01/04 21:08:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/cmd / VDm_rextraci.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDm_rextraci.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/29  10:01:22  pinnacle
# Replaced: vddrawing/cmd/VDm_rextraci.I for:  by rgade for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1995/09/13  20:05:56  pinnacle
# Replaced: vddrawing/cmd/VDm_rextraci.I for:  by rmanem for vds.240
#
# Revision 1.3  1995/05/05  17:27:26  pinnacle
# Replaced: vddrawing/cmd/VDm_rextraci.I by azuurhou r#
#
# Revision 1.2  1995/05/02  22:02:18  pinnacle
# Replace: vddrawing/cmd/VDm_rextraci.I by rmanem for OPE
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
 *	05/02/95	R. Manem	Handle broken connections also
 *	09/13/95	R. Manem	Delete pretendin objects, after
 *					sending NDmove_to_root message to
 *					children  : needed to fix problem
 *					in Modify Table command
 *	08/28/96	Ravi		Avoid the gap in locate process
 *
 * -------------------------------------------------------------------*/

/* crao  added line  if( me->n_mismatched ){
         to avoid error messages. the macro nd$get_graph gives
         error messages if me->n_mismatched is zero.

   Ad    added return OM_S_SUCCESS to wrapup in init. If there are
         no refernce files then the status returned causes the 
         super_cmd init method to give errors when the command is
         invoked. 
*/
      
class implementation VDm_rextrac;

#include "OMmacros.h"
/* #include "OMtags.h" */
#include "ode_export.h"
#include "AS_status.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "exmacros.h"
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
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "coparamac.h"
#include "ACdb_info.h"
#include "macro.h"
#include <stdio.h>
#include <ctype.h>
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "madef.h"
#include "parametric.h"
#include "go.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "v_dbgmacros.h"
#include "ACcheckin.h"

from	NDnode		import	NDmove_to_root, NDget_objects, NDdisplay;
from	NDmacro		import	ACreturn_foot;
from	GRcontext	import	GRgetinstance;

extern GRclassid OPP_VDcontext_class_id;
extern OM_S_CHANSELECT AS_listeners;

#define AS_DEBUG

/* 
	#define INPUT_FILE "drawing_macro"
	#define GEOM_PART  "constructs:VDgeomdef"
	#define PREDEFINED_FEET 4
	#define PREDEF0 "macro"
	#define PREDEF1 "occurence"
	#define PREDEF2 "design"
	#define PREDEF3 "quantity"
	#define set_generic 0x10000000
 */

method init (int type; char *string_ptr )
{
long		status = OM_S_SUCCESS;
GRspacenum	main_osnum,
		ref_osnum[100];
IGRint		i,
		size,
		size_ref=100,
		nb_ref,
		i_ref,
		count;
OMuint		nb;
OM_S_CHANNUM	listener;
OM_S_TAG_CON_INFO *tag_info = NULL;

  status = om$get_channel_number(channame = "ASsource.listeners",
		                 p_channum = &listener);
  as$status(action = RET_STATUS);

  status = om$send(msg = message COpara.init(type,string_ptr),
                   targetid = my_id,
                   mode = OM_e_wrt_message);
  as$status(action = RET_STATUS);

  /*
   * Find missing attachement
   */
  status = VDattach_missing_ref(me->added_ref,100,&me->n_added_ref);
  if( ! (status & 1)){
    UI_status( "No reference files available " );
    goto wrapup;
  }

  /*
   * Get reference file attached
   */
  status = VDfind_ref_files(ref_osnum,size_ref,&nb_ref);
  if( ! (status & 1)){
    UI_status( "No reference files available " );
    goto wrapup;
  }

  me->n_mismatched = 0;
  main_osnum = me->ModuleInfo.md_id.osnum;

  /*
   * Get broken connections memory to allocate
   */
  size = 100;
  tag_info = NULL;
  tag_info = (OM_S_TAG_CON_INFO *) om$malloc
		      (size = size * sizeof(OM_S_TAG_CON_INFO));
  if( ! tag_info ){
    status = OM_E_ABORT;
    goto wrapup;
  }

  /*
   * get broken connection
   */
  for( i_ref=0; i_ref<nb_ref; i_ref++ ){

    /*" main_os %d ref_os %d\n",main_osnum,ref_osnum[i_ref] */
    status =
    om$broken_connects( osnum		= main_osnum,
			tagged_osnum	= ref_osnum[i_ref],
			p_count		= &nb,
			p_tag_con_info	= tag_info,
			size		= size );
    if(!(status&1)) { nb = 0; status = OM_S_SUCCESS;}

	__DBGpr_int(" nb_mismatched ", nb );

    /*
     * reallocate if necessary.
     */
    if( nb>size ){
      om$dealloc(ptr = tag_info);
      size = 100*(1+nb/100);
      tag_info =(OM_S_TAG_CON_INFO *) om$malloc
				      (size = size * sizeof(OM_S_TAG_CON_INFO));
      if(!tag_info){
        status = OM_E_ABORT;
        goto wrapup;
      }
   
      status =
      om$broken_connects(osnum = main_osnum,
			tagged_osnum = ref_osnum[i_ref],
			p_count = &nb,
			p_tag_con_info = tag_info,
			size = size);
      as$status(action = GOTO_VALUE, value = wrapup);
    }

    /* Now store them in my instances */
    status =
    om$send(msg = message VDm_rextrac.realloc_broken(me->n_broken+nb),
	    targetid = my_id);
    as$status(action = GOTO_VALUE, value = wrapup);

    for( i=0; i<nb; i++){
      if( tag_info[i].chan.classid != listener.classid
       || tag_info[i].chan.number  != listener.number) continue;

      status =
      om$send(msg = message NDnode.NDget_objects(
						ND_CHILDREN,
						NULL,
						0,
						NULL,
						0,
						OM_K_MAXINT,
						&count),
	    targetid = tag_info[i].objid,
	    targetos = main_osnum);
      if( !(status&1) || count < 1) continue;

      me->broken[me->n_broken].objid = tag_info[i].objid;
      me->broken[me->n_broken].osnum = main_osnum;
      me->n_broken++;
    }
  }

  /*
   * get mismatched connection
   */

  for( i_ref=0; i_ref<nb_ref; i_ref++){

    /*" main_os %d ref_os %d\n",main_osnum,ref_osnum[i_ref] */
    status =
    om$mismatched_connections(osnum = main_osnum,
			    tagged_osnum = ref_osnum[i_ref],
			    p_count = &nb,
			    p_tag_con_info = tag_info,
			    size = size);
    if(!(status&1)) { nb = 0; status = OM_S_SUCCESS;}

	__DBGpr_int(" nb_mismatched ",nb );

    if(nb>size){
      om$dealloc(ptr = tag_info);
      size = 100*(1+nb/100);
      tag_info =(OM_S_TAG_CON_INFO *) om$malloc
			      (size = size * sizeof(OM_S_TAG_CON_INFO));
      if( !tag_info ){
        status = OM_E_ABORT;
        goto wrapup;
      }
   
      status =
      om$mismatched_connections(osnum = main_osnum,
			    tagged_osnum = ref_osnum[i_ref],
			    p_count = &nb,
			    p_tag_con_info = tag_info,
			    size = size);
      as$status(action = GOTO_VALUE, value = wrapup);
    }

    /* Now store them in my instances */
    status =
    om$send(msg = message VDm_rextrac.realloc_mis(me->n_mismatched+nb),
	    targetid = my_id);
    as$status(action = GOTO_VALUE, value = wrapup);

    for(i=0;i<nb;i++)
    {
      if(   tag_info[i].chan.classid != listener.classid
         || tag_info[i].chan.number  != listener.number) continue;

      /*
       * Temperary because the list of mismatched connection seems to be
       *  build at wake_up 
       */
      {
        OMuword his_version;
        OM_S_OBJID ref_obj;
        status =
        om$tag_to_objid(osnum = ref_osnum[i_ref],
 		        tag =   tag_info[i].tag,
		        p_objid = &ref_obj,
		        p_version = &his_version);
        as$status();
        /*"his_version %d my_version %d\n",his_version,tag_info[i].version */
        if(his_version == tag_info[i].version) continue; 
      }

      me->mismatched[me->n_mismatched].objid = tag_info[i].objid;
      me->mismatched[me->n_mismatched].osnum = main_osnum;
      me->n_mismatched++;
    }
  } /* on ref os */

wrapup :

  if( !(status&1) ){
    me->state = _terminate;
    status = OM_S_SUCCESS;
  }
  if(tag_info) om$dealloc(ptr = tag_info);

  return status;
}


method wakeup ( IGRint n )
{
 int status;
 status = om$send(msg = message COpara.wakeup(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 ex$message(msgnumb = VD_M_UptDra);

 return (status);
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{

#define NUM_STATES  2
#define NUM_ACTIONS 4
#define NUM_TOKENS  4

enum possible_states { 	INITIAL,
		        HAV_OBJ
		     };

enum possible_actions {	NIL,
			ERR,
			LOC_BROK,
			STO_BROK,
			LOC_OBJ,
			UPDATE_ONE,
			UPDATE_ALL
		       };

enum possible_entry {
		     PARENT,
		     POINT,
		     NOENT
		    };

static IGRint TokenList[] =
 		      { RESET,
			DATA,
			GR_UNKNOWN_TYPE,
			LOC_PARENT
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*        *********************** TOKENS ***********************
   Old State  *   RESET     , DATA, 	UNKNOWN   , PARENT */

/* INITIAL    */ {HAV_OBJ   , INITIAL,	INITIAL   , HAV_OBJ },
/* HAV_OBJ    */ {INITIAL   , INITIAL,	INITIAL   , INITIAL }};

static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*        *********************** TOKENS ***********************
   Old State  *   RESET      , DATA,		UNKNOWN   , PARENT */

/* INITIAL    */ {STO_BROK   , STO_BROK,	LOC_BROK  , STO_BROK },
/* HAV_OBJ    */ {UPDATE_ALL , UPDATE_ALL,	LOC_OBJ   , UPDATE_ONE	}};

    IGRint      	status;         /* routine return status */
    IGRint      	event_size;     /* size of GRevent buffer */
    IGRlong     	display_flag;   /* display flag for locate filter */
    IGRlong     	input_mask;     /* mask for GRgetevent */
    IGRlong     	locate_mask;    /* mask for GRgetevent */
    IGRlong     	msg;            /* function return code */
    struct GRevent 	grevent1, grevent2;  /* event returned by GRgetevent */
    struct GRid  	context; /* object located        */
    IGRint 		resp;
    IGRlong		size= sizeof( struct GRevent );
    IGRint 		i;
    IGRint 		token;
    IGRint 		obj_generic;
    IGRint 		nb_obj,nb_objb,i_obj,countr,i_mis;
    struct GRid 	*obj_to_update,*l_root,go;
    GRclassid obj_class;
    struct ret_struct rst;
    struct GRid located_obj;
    int new_n;
    OMuword his_version,my_version;

    *response = TERMINATE;
    token = 0;

    obj_generic = macro_generic | set_generic;
    event_size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP;
    input_mask  = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP; 
    display_flag = ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;

    me->attr.owner_action = LC_RIGID_OWNER 
			  | LC_NO_REF_HEADER | LC_NO_REF_OBJECTS | 
			    LC_FLEX_COMP   | LC_FLEX_OWNER;

    /*
     *  loop until exit condition occurs
     */

   do
    {
      switch (me->action)
      {       
	 case NIL :     /*| nil */

		__DBGpr_com("	execute	NIL " );
		break;

	 default :
	 case ERR :    /*| err  */

		__DBGpr_com("   execute : ERR " );
		ex$message( msgnumb = AS_E_InvDefRest);

	case LOC_BROK: /* Hilight broken connection */

		 __DBGpr_com("   execute : LOC_BROK " );

	   if(me->n_broken)
	     {
     		nd$get_graph(p_root = me->broken,
		  	     nb_root = me->n_broken);
     		status = nd$broadcast_graph(p_msg = message NDnode.NDdisplay
					(0,GRhd,&me->ModuleInfo));
	        ex$message(msgnumb = VD_S_HighDel);

#ifdef OLDCODE
	        ex$message(msgnumb = VD_P_DelNam);
#endif

		UI_prompt( "Update elements?  Accept/Reject" );
                me->Entry_Request = POINT;
		break ;
	      }
	    else
	     {
	      me->action = LOC_OBJ; 
	      me->Entry_Request = NOENT;
	     }
/**
	    break;
 **/

	case STO_BROK :

		__DBGpr_com("   execute : STO_BROK " );

	   if(me->n_broken)
	    {

		IGRint		nret,
				size = sizeof( struct GRmd_env);
		OMuword		curos;
		struct GRid	obj;
		struct GRmd_env	mod_env;

		/* get current module environment */

		gr$get_module_env(	msg	= &msg,
					sizbuf	= &size,
					buffer	= &mod_env,
					nret	= &nret );

		/* get current osnum */

		ex$get_cur_mod(	osnum	= &curos );
#ifdef OLDCODE
	     if(response_data[0] == 'd' || response_data[0] == 'D')
	     {
	     }
	    else if(response_data[0] == 'd' || response_data[0] == 'D')
	     {
	     }
#endif
	     	if( resp == RESET )
	     	{
			/* don't touch the objects */
	     	}
	     	else if( resp == DATA )
	     	{
			/* update the objects */
	
			for( i = 0 ; i < me->n_broken ; i++ )
			{
		    		om$send( msg	= message NDnode.NDmove_to_root(
								&msg,
								&obj,
								&mod_env ),
			     		senderid	= me->broken[i].objid,
			     		p_chanselect 	= &ND_children,
					targetos	= curos );

				om$send( msg	= message Root.delete( 0 ),
					 targetid = me->broken[i].objid,
					 targetos = me->broken[i].osnum );
			}
	     	}
	   }
	 me->state = HAV_OBJ;

		__DBGpr_com("   execute : new state : HAV_OBJ ");

         case LOC_OBJ:

		__DBGpr_com("   execute : LOC_OBJ ");
           /*
            *  hilite elements which are out of date
            */

	   dp$erase_hilite(msg = &msg);
	
	   /* Remove already updated elements */

	   for(i=0,new_n=0;i<me->n_mismatched;i++)
	    {
	     if(me->mismatched[i].objid != NULL_OBJID)
	      {
	       me->mismatched[new_n].objid = me->mismatched[i].objid;
	       me->mismatched[new_n].osnum = me->mismatched[i].osnum;
	       new_n += 1;
	      }
            }
	   me->n_mismatched = new_n;
           if( me->n_mismatched ){

	     /* hilite dependency */
	     ex$message(msgnumb = VD_S_HighOut);
 	     status = nd$get_graph(p_root = me->mismatched,
		       		    nb_root = me->n_mismatched);

 	     status = nd$broadcast_graph(p_msg = message NDnode.NDdisplay
						(0,GRhhd,&me->ModuleInfo));
             /*
              *  Identify element to update
              */
	     ex$message(msgnumb = VD_P_IdRexRes, buff = me->loc_prompt);
	    }
	   else
	    { ex$message(msgnumb = VD_P_IdRex, buff = me->loc_prompt);
	    }

           ex$message( buff = me->acc_prompt, msgnumb = VD_P_AccNex);
           me->Entry_Request = PARENT;
           break;



     
         case UPDATE_ONE:

		__DBGpr_com("   execute : UPDATE_ONE ");
  
           /*
            *  store the information in the instance and put
            *  the accept point 
 	    */
            me->Entry_Request = NOENT;
            me->action = LOC_OBJ;
            me->state = HAV_OBJ;
            
/*
            me->state = INITIAL;
*/

		__DBGpr_com("   execute : new state : INITIAL ");
/* Added putq_front for TR#179527874 dt.08/28/96 -Ravi */
	    if(grevent1.response != SPECIFIED_OBJ)
            {
             status = EXputq_front(     &msg,
                                        &resp,
                                        (IGRlong *) &size,
                                        (IGRchar *)&(grevent2.event));
            }

            ASstart_fence(located_obj,me->ModuleInfo.md_id.osnum,&nb_obj,
			 &obj_to_update,&resp,response_data);

	    for(i_obj=0,nb_objb=0;i_obj<nb_obj;i_obj++)
                 {
		  om$get_classid(osnum = obj_to_update[i_obj].osnum,
				 objid = obj_to_update[i_obj].objid,
				 p_classid = &obj_class);
		  if(om$is_ancestry_valid(subclassid=obj_class,
			     superclassid=OPP_NDnode_class_id)!=OM_S_SUCCESS)
							   	     continue;
		  obj_to_update[nb_objb++] = obj_to_update[i_obj];
		 }
	    nb_obj = nb_objb;
	      /*" %d object to update\n",nb_obj */

            /*| get corresponding roots */

	     if(nb_obj == 0) break;
             status = nd$get_graph(p_tip = obj_to_update,
				   nb_tip = nb_obj);
	     status = nd$get_list_in_graph(rej_type = ND_BODY,
					   buf_addr = &l_root,
					   p_count   = &countr);
	     /*"%d root\n",countr */

            /* free array if necessary */

	     ASend_fence();


      case UPDATE_ALL :

		__DBGpr_com("   execute : UPDATE_ALL ");

             if(me->action == UPDATE_ALL)
               {
                l_root = me->mismatched;
                countr = me->n_mismatched;
/* Added  for TR#179527874 dt.08/28/96 -Ravi */
            	me->action = LOC_OBJ;
		me->Entry_Request = NOENT;
          	me->state = HAV_OBJ;
               }
	
	  status = om$send(msg = message VDm_rextrac.realloc_obj(countr),
			   targetid = my_id);
	  as$status(action = RET_STATUS);
	  for(i_obj=0;i_obj<countr;i_obj++) me->Obj_List[i_obj] = l_root[i_obj];
	  me->Nb_Max_Obj = countr;
 
	  if( !me->Nb_Max_Obj )
		return OM_S_SUCCESS;

	  ex$message(msgnumb = VD_S_ChaSca);

	  status = om$send(msg = message VDm_drawing.change_scale(),
			   targetid = my_id);
          as$status();

	  
	  /* 
		Remove updated elements from out of date list,
	        update tag counter and update dependency 
	  */

	  ex$message(msgnumb = VD_S_UpdExt);


	  for(i_obj=0;i_obj<me->Nb_Max_Obj;i_obj++)
	   {
	    nd$wait_batch(type = GR_GEOM_POSTED,
			  l_obj_info = &me->ModuleInfo,
			  l_object = me->Obj_List+i_obj,
			  nb_obj = 1);
   	    status = om$send(msg = message NDmacro.ACreturn_foot(&msg,"",
				&go,NULL,NULL),
		    targetid = me->Obj_List[i_obj].objid,
		    targetos = me->Obj_List[i_obj].osnum);
            status = om$test_connection(osnum = me->Obj_List[i_obj].osnum,
                                        objid = me->Obj_List[i_obj].objid,
                                        p_chanselect = &AS_listeners,
                                        tag_osnum = go.osnum,
                                        tag_objid = go.objid,
                                       p_tag_chanselect = &AS_notification,
                                       p_tag_version = &his_version,
                                  p_tag_connect_version = &my_version,
                                             force_flag = TRUE);

/**
            as$status();
 **/
	    for(i_mis=0;i_mis<me->n_mismatched;i_mis++)
	      {
		if(me->Obj_List[i_obj].objid == me->mismatched[i_mis].objid &&
		   me->Obj_List[i_obj].osnum == me->mismatched[i_mis].osnum)
		 {me->mismatched[i_mis].objid = NULL_OBJID; break;}
	      }
	   }
          nd$exec_batch();

	  break;
	
      }   /* end switch (me->state) */


    switch( me->Entry_Request)
    {
     case POINT :  /*| PROMPT */

	  __DBGpr_com(" me->Entry_Request = POINT ");

          token = GRget_token(&status,TokenList,&input_mask,&grevent1,
                              &event_size,&resp,response_data);
          break;


     case PARENT :  /*|  arent */

	   __DBGpr_com(" me->Entry_Request = PARENT ");

  	  token = as$get_parent(event1 = &grevent1,event2 = &grevent2,
			locate_mask = locate_mask,input_mask = input_mask, 
			response = &resp,
			type_generic = obj_generic,
			returned_obj = &located_obj,
			returned_context = &context,
			returned_struct = &rst);
	  /*"response_data[0] %c\n",response_data[0]*/
          break;
     
     case NOENT :  /*| Noent */

	  __DBGpr_com(" me->Entry_Request = NOENT ");
          break;

    }/* end of switch */

/* new action and new state */
	
     if(me->Entry_Request != NOENT)
      {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
      }

	__DBGpr_int("	Token ", token );
	__DBGpr_int("	Action", me->action );
	__DBGpr_int("	State ", me->state );

    } while(	me->Entry_Request == NOENT ||
		TokenList[token] != GR_UNKNOWN_TYPE );

	*response = resp;

	__DBGpr_int(" response ", *response );

	return( OM_S_SUCCESS);

}   /*  end execute method */

#include "msdef.h"
#include "refdef.h"
#include "madef.h"

method realloc_mis(int nb_obj)
{
IGRint		status = OM_S_SUCCESS;
IGRint		previous_size;

  previous_size = om$dimension_of(varray = me->mismatched);
  if( nb_obj > previous_size){
     previous_size = 20*(nb_obj/20 +1);
     status = om$vla_set_dimension(varray = me->mismatched,
                                   size = previous_size);
     as$status(action = RET_STATUS);
  }
  return OM_S_SUCCESS;
}

method realloc_broken(int nb_obj)
{
IGRint		status = OM_S_SUCCESS;
IGRint		previous_size;

  previous_size = om$dimension_of(varray = me->broken);
  if(nb_obj > previous_size){
     previous_size = 20*(nb_obj/20 +1);
     status = om$vla_set_dimension(varray = me->broken,
                                   size = previous_size);
     as$status(action = RET_STATUS);
  }
  return OM_S_SUCCESS;
}

method delete(int n)
{
/* detach reference file attached by the command */
return OM_S_SUCCESS;
}


/*****
VDretrieve_ref()
{
 OMmsg = ex$retrieve_module(filename = filename,
                            ftype = EX_invisible,
                            mount_name = path,
                            flag = my_flag,
                            file_no = &index,
                            mod_type = 2,
                            fstat = EX_old_module,
                            type = 1,
                            msg = &msg1);

}
*******/

end implementation VDm_rextrac;
