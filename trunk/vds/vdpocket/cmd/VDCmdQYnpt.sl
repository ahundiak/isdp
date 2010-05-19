/*$Id: VDCmdQYnpt.sl,v 1.2 2001/03/13 15:44:01 anand Exp $  */

/************************************************************************
 * I/VDS
 *
 * File:        vdpocket/com/VDCmdQYnpt.sl
 *
 * Description:
 *
 *      This command object controls the interface for creation of 
 *	new queries and the activation of queries to use.
 *
 * Dependencies:
 *
 *      The commands "Load / Save / Delete Queries". 
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/23/94        adz             Creation Date.
 *      10/27/94        yzhu		Modify
 *      03/06/95        yzhu		add keyin_query_name
 *      03/06/95        yzhu		add is_query_name_in_list
 *	03/13/01	Anand		Prevent attempt to malloc 0 bytes.
 ************************************************************************/

class           VDCmdQYnpt
product_name    "$VDS"
super_class     "COnpt"
super_class     "CEO_GSLOCATE"
options		"SItc"
start_state     terminate

/*--------------------
 * specification area
 *-------------------*/
specification

#include "de.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "FI.h"
#include "growner.h"
#include "ACrg_collect.h"
#include "VDQYdef.h"

/*+v
  Abstract
        The following instance are used to control the
        management of the queries.
-v*/

instance
{
    char                dir_name [DI_PATH_MAX]  /* directory name       */;
    struct GRid         ss_id;
    struct GRid         window_id;
    int                 query_state;  /* state of the query (MACRO, WHEREG,
                                      /* ATTRIBUTE, CONDITION, VALUE,
                                      /* CONJONCTION
                                      /**/

    int                 num_query_offsets;
    variable int        query_offsets[20];

    int                 form_displayed;
    int                 form_display_flag;
    char                buffercontent[4096];
    char                buffercontent1[4096];

    int			qry_delete_flag ;

    /*
     * existing query information.
     */
    variable struct GRid    queries[0];     /* list of queries */
    variable struct GRid    act_queries[0]; /* list of active queries. */
    GRname                  qry_dir;
    struct  GRid            qry_dirId;      /* directory id */

    GRname                  qry_File;       /* query ASCII file */
    char                    qrynames[4096];
    variable struct Qry_list qry_sortlist[0]; 	/* selected objects  */


    /* locate object */
    variable struct Qry_coll    qry_list[0]; 	/* selected objects  */
    variable struct GRobj_env   VDlocObjs[0]; 	/* selected objects  */
    variable struct ACrg_coll   VDslist[0]; 	/* selected objects  */
    IGRint                      VDnumobjs;
    IGRint		        locate_wakeup;
    IGRint		        locate_flag;
    IGRint                      rep_label;      /* Form return status   */
    IGRint                      act_nb;
    IGRint                      act_macrolistindex[1024];
    IGRint			macro_list;
    IGRint			macro_field;
    IGRint			feet_flag;

    variable IGRchar            keyinname[1];   /* key in name */
    int                         isdesignfile; 
}


/*---------------------
 * implementation area
 *-------------------*/
implementation

#include <stdio.h>
#include <string.h>

#include "OMprimitives.h"
#include "OMmacros.h"
#include "codebug.h"
#include "grerr.h"
#include "codef.h"
#include "msdef.h"
#include "dedef.h"
#include "igrmacros.h"
#include "coniarray.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "ex.h"
#include "exdef.h"
#include "exmacros.h"
#include "grdpbmacros.h"
#include "lcmacros.h"
#include "comiscmac.h"
#include "lcmacros.h"
#include "grownerdef.h"
#include "growner.h"
#include "grgsdef.h"
#include "grgs.h"
#include "grgsmacros.h"
#include "referr.h"
#include "exmacros.h"
#include "coparamac.h"			/* as$start_fence */
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DIomac.h"
#include "ACrg_collect.h"
#include "AS_status.h"
#include "grmsg.h"
#include "vdsetmacros.h"		/* For vd$filter_objects */
#include "v_miscmacros.h"
#include "v_dbgmacros.h"
#include "VDQYdef.h"
#include "vdparmacros.h"
#include "VDmsg.h"
#include "bsmalloc.h"
#include "VDmem.h"
#include "parametric.h"

#define VD_qry_nmName "name"

/* #define DEBUG	1   */ 

from GRgraphics   import    GRdisplay;
from GRgrset      import    GSobject_add, GSremove_member, GSadd;
from ACcpx        import    find_macro;
from GRowner	  import    GRget_channel_type;
from GRgraphics   import    GRgetname;
from GRgraphics   import    GRgetobjinfo;
from ACcpx_defn   import    ACgive_name;
from NDmacro      import    ACgive_structure;
from VDquery      import    VDname_query, VDgive_query;

extern IGRint VDQYselect();  
extern IGRint VDQYlocact();  
extern OPP_nci_macro_class_id;
extern OPP_VSfrzBeam_class_id;

#define         COMMAND_NAME            ":IGENOD:VDCmdQYnpt_comm_ID"

%safe
static	IGRchar	VDQYnpt_query[4*4096] = { 0 };
%endsafe


/*----------------------------------------
 *    define actions
 *---------------------------------------*/

action form_notification extern
action notify_query0(  int    form_label;
                       int    gadget_label;
                       double value;
                       Form   form_ptr )	extern
action notify_query1(  int    form_label;
                       int    gadget_label;
                       double value;
                       Form   form_ptr )	extern


action init_query()                             extern
action wakeup_query( )                          extern
action switch_query_state(int state; int reset) extern
action add_to_query(int label)                  extern
action back_up_query()                          extern
action set_locate_eligible( long *msg )	extern
action arrange_qrylist(char *in_query_list; char *bufferi)  extern
action query_struct(char **name_list; char **text_list; int nb_list) extern
action query_check(char **text_list; int nb_list) extern

action display_object
{
int			i;
OMuint			number_objects = 0;
struct GRobj_env	*object_list = NULL;

        SetProc( VDCmdQYnpt.display_object ); Begin
        
	/*
	 * get the channel list.
	 */
	status =
	om$get_channel_count(	objid = my_id,
				p_chanselect = &me->located_chansel,
			        count = &number_objects);

	if( number_objects ){

		object_list = _MALLOC( number_objects, struct GRobj_env );
                     
                if( object_list == NULL )       goto quit ;

		status =
		gr$gsget_objects(
			msg = sts,
			array = object_list,
			size = (sizeof(struct GRobj_env) * number_objects),
			count = &number_objects,
			p_chanselect = &me->located_chansel);

		for( i=0; i<number_objects; i++ ) {

			status =
			om$send(msg = message GRgraphics.GRdisplay(
				sts,
			        &object_list[i].mod_env.md_env.matrix_type,
			        object_list[i].mod_env.md_env.matrix,
			        &me->DisplayMode,
			        &me->ModuleInfo.md_id ),
				targetid = object_list[i].obj_id.objid,
				targetos = object_list[i].obj_id.osnum );
		}
	}

	_FREE(object_list );

	*sts = MSSUCC;
        End
        goto quit;
}
/***************************************************************************/
action VDdisplay_form
{
        SetProc( VDCmdQYnpt.VDdisplay_form ); Begin

        status = OM_S_SUCCESS ;
        *sts = MSSUCC;

        End
        goto quit ;
}
/**************************************************************************/
action init
{
struct GRid	myCommand;
char		path_name[DI_PATH_MAX];

    SetProc( VDCmdQYnpt.init ); Begin

    /*
     * Check if the command object is already active.
     */

    me->qry_delete_flag = 0 ;

    if( me->mytype == 1 ){

	status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     	pathname = path_name );

	if( status != DIR_S_SUCCESS ){

	  di$report_error( sts = status,  comment = "error in give pathname" );	
	  return ( OM_I_STOP_SENDING );
	}

	strcat( path_name, COMMAND_NAME );

	myCommand.objid = NULL_OBJID ;

	status =
	di$translate (	objname = path_name,
			osnum	= OM_Gw_TransOSnum_0,
			p_objid = &myCommand.objid,
			p_osnum = &myCommand.osnum );

	if ( status != DIR_S_SUCCESS ){

	  if ( status == DIR_W_NAME_NOT_FOUND ){

	    /*
             * fprintf(" Couldn't find it, so trying to create my entry\n\n" );
             */

            status =
	    di$add_name( objname = path_name,
			 objid   = my_id,
			 osnum   = OM_Gw_TransOSnum_0 );

	    if( status != DIR_S_SUCCESS ){
	      di$report_error( sts     = status,
                               comment = "Error : di$add_name" );
            }
	  }
          else {
         	di$report_error( sts     = status,
                          comment = "  Unable to find my entry\n" );
          }
	}
	else if ( myCommand.objid != my_id ){

	  /* CO id and my id not the same */
	  me->qry_delete_flag = 1 ;
	  me->state = _terminate;
	  return( OM_I_STOP_SENDING );
	}
     } /* mytype == 1 */

     status =
     om$send(msg = message CEO_LOCATE.init( type, str_ptr ),
		mode = OM_e_wrt_message,
                targetid = my_id );
     as$status();

/*
        if(     ex$is_cmd_stack_empty() ) {

                ex$message(msgnumb = VD_E_CmdStkEpt);
                status = OM_E_ABORT;
                return OM_S_SUCCESS;
        }
        if( ex$is_cmd_stack_empty()  && me->mytype == 1 ){

          UI_status (" NO command on stack ");

          me->qry_delete_flag = 1 ;
          me->state = _terminate;
          return( OM_I_STOP_SENDING );
        }

*/
	me->form_displayed = FALSE;
        me->locate_wakeup  = TRUE;
    	me->locate_flag    = FALSE;
    	me->feet_flag      = TRUE;
    	me->macro_field    = FALSE;

	*me->event1.event.keyin = '\0';
        *me->buffercontent = '\0';
	
        End
        goto quit ;
}
/***************************************************************************/
action delete
{
struct GRid	myCommand;
char		path_name[DI_PATH_MAX];
IGRlong		msg;

    SetProc( VDCmdQYnpt.delete ); Begin

    /*
     * Check if the command object is already active.
     */

    if( me->qry_delete_flag ){

	return OM_S_SUCCESS ;
    }

    if( me->mytype == 1 ){

	status = di$give_pathname( osnum = OM_Gw_TransOSnum_0,
			     	pathname = path_name );

	if( status != DIR_S_SUCCESS ){
	  di$report_error( sts = status,  comment = "error in give pathname" );	
	  return ( OM_I_STOP_SENDING );
	}

	strcat( path_name, COMMAND_NAME );

	myCommand.objid = NULL_OBJID ;
	status =
	di$translate (	objname = path_name,
			osnum	= OM_Gw_TransOSnum_0,
			p_objid = &myCommand.objid,
			p_osnum = &myCommand.osnum );

	if ( status == DIR_S_SUCCESS &&  myCommand.objid != NULL_OBJID ){

            status =
	    di$rm_name( regexp = path_name,
			osnum   = OM_Gw_TransOSnum_0 );
        }
     }

           
     status =
     om$send(msg = message CEO_GSLOCATE.delete( f_defer_flag ),
		mode = OM_e_wrt_message,
                targetid = my_id );
     as$status();

     status =
     om$send(msg = message COnpt.clear_channels( &msg ),
		mode = OM_e_wrt_message,
		targetid = my_id );
     as$status();
	
     End
     goto quit ;
}

/***************************************************************************/
action wakeup
{
        SetProc( VDCmdQYnpt.wakeup ); Begin

	/*
         * send to my grandparent
	 */

	status =
	om$send(msg = message COnpt.wakeup( pos ),
		mode = OM_e_wrt_message,
                targetid = my_id );
        as$status();

	if( me->form_displayed && me->locate_wakeup){
		/*
		 * display the form.
		 */
		if( me->forms[0].form_ptr )
			FIf_display( me->forms[0].form_ptr );
	}
        End 
        goto quit ;

}
/***************************************************************************/
action sleep
{
	SetProc( VDCmdQYnpt.sleep );   Begin
	/*
	 * call sleep of COnpt.
	 */

	FIf_is_displayed( me->forms[0].form_ptr, &me->form_displayed );
	if( me->form_displayed ){
		me->form_displayed = 1;
		FIf_erase( me->forms[0].form_ptr );
	}
	
	status =
	om$send(msg = message COnpt.sleep ( pos ),
		mode = OM_e_wrt_message,
		targetid = my_id );
        as$status();

        End
        goto quit ;
}
/**************************************************************************/
action filter
{
IGRint		sts;

	SetProc(VDCmdQYnpt.filter);   Begin

	/*
	 *  initialize status to be good ( i am an optimist )
	 */

	sts = OM_S_SUCCESS;
	status = OM_S_SUCCESS;

	switch ( filter )
	{

#ifdef DEBUG
        case _gr_locate:
	    __DBGpr_com(" gr_locate ");
            
            me->select = (IGRchar (*)())VDQYselect;
            me->action_handler = (IGRchar (*)())VDQYlocact;
            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(_gr_locate,
                                                               response,
                                                               response_data),
                              targetid = my_id );
            as$status();
            break;
#endif 

        case _gs_locate:

            __DBGpr_com(" gs_locate ");

            me->select = (IGRchar (*)())VDQYselect;

            me->action_handler = (IGRchar (*)())VDQYlocact;

            status = om$send( mode = OM_e_wrt_message,
                             msg = message CEO_GSLOCATE.filter(_gs_locate, 
                                                               response,
                                                               response_data),
                             targetid = my_id );
            as$status();

            break;

        case _get_event:
            
	    __DBGpr_com(" get_event ");
            
            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(_get_event, 
                                                               response,
                                                               response_data),
                              targetid = my_id );
            as$status();

            break;

        default:

 	    __DBGpr_com(" defult ");
            
            status = om$send( mode = OM_e_wrt_message,
                              msg = message CEO_GSLOCATE.filter(filter,
                                                                response,
                                                                response_data),

                              targetid = my_id );
            as$status();
            break;

    } /* end switch */

    End
    goto quit ;

} /* filter */
/***************************************************************************/
action store_locate_context
{
struct GRobj_env	*object_list = NULL;
IGRint			count;
OM_S_OBJECT_LINKAGE	*chan_list = NULL;

        SetProc(VDCmdQYnpt.store_locate_context);   Begin

        *sts = MSSUCC ;

	/*
	 * store contents.
	 */

        /* check if me->located_chansel is a graphics set */
	status =
	gr$gsis_graphics_set(msg = sts,
			     p_chanselect = &me->located_chansel);

	if(( status&1)  & (*sts&1) ){

	  gr$gsinqcount(	msg = sts,
				count = &count,
				p_chanselect = &me->located_chansel );

          __DBGpr_int("count of store_locate_context ",count);
	  
          if( ! count ) goto DEFLT;

	  object_list = _MALLOC( count, struct GRobj_env);

	  if( ! object_list ) goto DEFLT;

	  gr$gsget_objects(
			msg = sts,
			array = object_list,
			size = (sizeof(struct GRobj_env) * count),
			count = &count,
			p_chanselect = &me->located_chansel);
       
      {
	  int		i, type,conn_type;
	  OMuint		num;
	  OMuint		chan_count;
	  OM_S_CHANSELECT	MyChannelStruct;
	  struct GRid	grid;
	  struct GRid	grset_id;

	  if( count ){

	    /*
	     * get grid of active graphic set
             * to retrieve the current select set
	     */
	    status =
	    gr$gsget_select_set(msg = sts,
				select_set_id = &grset_id);

            __DBGpr_obj( "  grid of active graphic set ", grset_id); 
	    /*
	     * make channel connection to save set
	     */
	    status =
	    om$make_chanselect(channame     = "GRgrset.to_sets",
                               p_chanselect = &MyChannelStruct );

	    /*
	     * get grid of save set
	     */
	    status =
	    om$get_objid_at_index(   objid = grset_id.objid,
                                     osnum = grset_id.osnum,
                                     p_chanselect = &MyChannelStruct,
                                     index = 0,
                                     objidaddr = &me->ss_id.objid,
                                     osnumaddr = &me->ss_id.osnum );

            __DBGpr_obj( "  grid of save set ", me->ss_id ); 

	    /*
	     * make channel connection to the to_owners
	     */
	    status =
	    om$make_chanselect(channame = "GRconnector.to_owners",
                               p_chanselect = &MyChannelStruct );
	  }

	  for( i=0 ; i<count ; i++ ){

	    /*
	     * if the object is connected to an owner with a rigid connection
	     */
	 
            num = 0; 
            status =
	    om$get_channel_count( objid = object_list[i].obj_id.objid,
                                  osnum = object_list[i].obj_id.osnum,
                                  p_chanselect = &MyChannelStruct,
                                  count = &num);

	    /*
	     * if only one owner (the save set) then do not replace the GO
	     */
	  
            if( num > 1 ){

	      /*
	       * if more than one owner,
	       * we remove the object from the save set
	       */

	      num--;
	      chan_list = _MALLOC( num, OM_S_OBJECT_LINKAGE );

	      status =
	      om$get_channel_objects(objid = object_list[i].obj_id.objid,
                                     osnum = object_list[i].obj_id.osnum,
                                     p_chanselect = &MyChannelStruct,
                                     list  = chan_list,
                                     size  = num,
                                     count = &chan_count );

	      /*
	       * and add all the parents of the object to the save set
	       */
	      {
		int j;

		for( j=0 ; j<chan_count ; j++ ){

                  /* following two line should be delected ?? */
		  me->ss_id.objid = chan_list[0].S_objid;   
		  me->ss_id.osnum = chan_list[0].osnum;

		  grid.objid = chan_list[j].S_objid;
		  grid.osnum = chan_list[j].osnum;
                  
		  status =
		  om$send(msg = message GRowner.GRget_channel_type(
							sts,
							&type,
							&conn_type ),
			  targetid = grid.objid,
			  targetos = grid.osnum );
	  
		  if( type == GR_RIGID ){
                  
                    __DBGpr_com( " type = GR_RIGID "); 
                     
		    /*
		     * we remove the object form the save set and
		     * add this parent to the save set
		     */

		    status =
		    om$send(msg = message GRgrset.GSremove_member(
						sts,
						&object_list[i].obj_id ),
			    targetid = me->ss_id.objid,
			    targetos = me->ss_id.osnum );

		    status =
		    om$send(msg = message GRgrset.GSadd(
						sts,
						&grid,
						NULL ),
			    targetid = me->ss_id.objid,
			    targetos = me->ss_id.osnum );
		  }
		} /* j<chan_count */
	      }
	    }
            _FREE( chan_list   );
            chan_list = NULL;
	  } /* i<count */
	 }
	}
	else{  /* not graphic set case */
DEFLT:
	 	status =
	 	om$send(msg = message COnpt.store_locate_context(sts),
		  	mode = OM_e_wrt_message,
		  	targetid = my_id );

	}
  
        _FREE( object_list );
        _FREE( chan_list   );

        End
        goto quit ;

} /* store_locate_context */

/******************************************************************************
Method: store_query

Description:

   This method stores the query :
	otherwise from keyin (very if syntax) or from VDQYnpt_query 
	(the previous query).
	if there is nothing defined sts= MSFAIL (will push in state get_query)

******************************************************************************/
action store_query
{
IGRchar			tmp[8*QUERY_LEN],
                        ttmp[8*QUERY_LEN]; 
IGRint			j,sizBuffer;

IGRchar                 **querylist;
IGRint                  qry_count;
IGRint                  cl_count;
OMuword         	my_os1;         
OM_S_OBJID      	my_id1;        
struct GRmd_env 	my_env1;   
IGRint          	syntax1;   
IGRint                  listnum;
IGRlong			msg;
IGRlong                 NumberOfBytes,
                        BytesReceived;
IGRint			nbAct;

	SetProc( VDCmdQYnpt.store_query ); Begin 

	*sts = MSSUCC ;

	tmp[0] ='\0';
	ttmp[0] ='\0';

        qry_count  = 0;
        sizBuffer = 0;
        cl_count = 0;
        me->buffercontent1[0] = '\0';
       	my_os1 = 0;         
      	my_id1 = NULL_OBJID;        
       	syntax1 = 1;   

        NumberOfBytes = sizeof(my_env1);
        BytesReceived = 0;
        gr$get_module_env(      msg    = &msg,
                                sizbuf = &NumberOfBytes,
                                buffer = &my_env1,
                                nret   = &BytesReceived);

        querylist = NULL;      
        listnum   = Qrylistnum;
        VDmalloc_str_list(&querylist, listnum, Qrylistlen);           

        /* if me->act_queries == NULL, set VDQYnpt_query[0] = '\0' */
        nbAct   = om$dimension_of( varray = me->act_queries ); 
        if(!nbAct)
            VDQYnpt_query[0] = '\0';

        /* me-buffercontent include active queries */

	if( (*me->buffercontent) && me->event1.response == EX_STRING ){

            VDQYnpt_query[0] = '\0';
	    VDQYget_individual_query(	me->buffercontent,
					&querylist,
					listnum,
					&qry_count ); 

            for ( j = 0; j < qry_count; j++) {  

		/*
		 * check just the syntax of the new query
		 */
	
         	*sts =
		VDDIprocess_query(
                                querylist[j],
				&my_os1,
				&my_id1,
				&my_env1,
				syntax1 ) >= 0 ? MSSUCC : MSFAIL;
 
		if( *sts == MSSUCC ){
			strcat( VDQYnpt_query, querylist[j] );     
			strcat( me->buffercontent1, querylist[j] ); 
                        cl_count ++;
		}
		else{
			printf("Syntax error: %s\n", querylist[j] );
		}

            } /* for */

	    FIf_erase( me->forms[0].form_ptr ); 

            if( cl_count == 0) {
                     UI_status ( "No Class Be Found" ); 
                     *sts = MSFAIL;
            }
            else{
             *sts = MSSUCC;
            }
	} /* if */
	else{
		if( *VDQYnpt_query ) {
			strcpy( me->buffercontent1, VDQYnpt_query ); 
                }
		else{
			*sts = MSFAIL;
		}
	}

       /* free memory */ 
       VDfree_str_list(querylist, listnum);

        __DBGpr_int( "VDQYnpt_query sts", *sts);

        status = OM_S_SUCCESS ;
        End
        goto quit;

} /* store query */

/***************************************************************************/
action send_query
{
struct  GRobj_env       *object_list = NULL;
struct  GRobj_env       *object_list_tmp = NULL;
IGRint                  env_prop;
IGRint                  i, count = 0,j;
IGRint                  response;
IGRlong                 size;
struct  GRevent         event;
OM_S_CHANSELECT         MyChannelStruct;
GRclassid               classid;
struct  GRid            grset_id;
IGRchar                 **querylist = NULL;
IGRint                  qry_count;
IGRchar                 **query_class_name = NULL;
IGRint                  cl_count;
IGRint                  syntax1;
IGRint                  listnum = 200;
IGRint                  sj,bj;
GRname                  my_msg;
IGRboolean              Route_VRplane = TRUE;
struct  GRobj_env       *outList = NULL;
IGRint                  del_num = 0, count1 = 0,ii = 0;

        SetProc(VDCmdQYnpt.send_query); Begin

        *sts = VD_QRY_SUCCESS; 
        dp$erase_hilite( msg = sts );

        /* find number of objects */
        status =
        gr$gsinqcount(  msg = sts,
                        count = &count,
                        p_chanselect = &me->located_chansel);

        __DBGpr_int(" totol object in the located_chansel ", count);

        object_list = _MALLOC(count, struct GRobj_env);

        if( object_list == NULL ) {
             __DBGpr_com(" object_list malloc failed ");
             *sts = VD_QRY_ERROR;
             goto wrapup ;
        }

        /* get env of object list */
        status =
        gr$gsget_objects(       msg = sts,
                                array = object_list,
                                size = (sizeof(struct GRobj_env) * count),
                                count = &count,
                                p_chanselect = &me->located_chansel);

        if( !(status&*sts&1) ) {
             __DBGpr_com(" gr$gsget_objects failed ");
             *sts = VD_QRY_ERROR;
             goto wrapup ;
        }
 
        /* 
         * check object list: 
         * 1. if object and object owners are both in the list, keep owner 
         *    object  in list
         * 2. for VR*Correction, get its components
         */
        {
           int                     outCount = 0 ;
           int                     i0;
       
           status  =
	   vd$filter_objects(	msg	= sts,
				iList	= object_list,
				iCount	= count,
				oList	= &outList,
				oCount	= &outCount );
           if( (status & *sts & 1) ) {

             _FREE(object_list);
             object_list = NULL;

             object_list = _MALLOC(outCount, struct  GRobj_env);

             __DBGpr_int(" new count of object_list ", outCount);

             count = outCount;
             for ( i0 = 0; i0 < outCount; i0++) {
                 object_list[i0] = outList[i0];
             } 
           }
           _FREE( outList );
           outList = NULL;
        }

        /*
         * call the process query function
         */

        listnum   = Qrylistnum;
        status = VDmalloc_str_list(&querylist, listnum, Qrylistlen);
        if( !(status&1) ) {
             __DBGpr_com(" querylist malloc failed ");
             *sts = VD_QRY_ERROR;
             goto wrapup ;
        }

        qry_count  = 0;
        status =  VDQYget_individual_query(me->buffercontent1,
                                  &querylist,
                                  listnum,
                                  &qry_count);
        if( !(status&1) ) {
             __DBGpr_com(" Can not get query list ");
             *sts = VD_QRY_ERROR;
             goto wrapup ;
        }
       
        /*
         * Classid to check against.
         */

        status = om$get_classid( classname = "VRplane",
                                 p_classid = &classid );

        if( !(status & 1))   { Route_VRplane = FALSE ; }

        del_num = 0; 
        for( i=0; i<count; i++ ){           

          /*
           * verify several class obect to avoid from any interest.
           */
          if( Route_VRplane && SMIsKindOf(&object_list[i].obj_id, classid)) {
             
                __DBGpr_com(" Found VRplane object ");
                *sts = VD_QRY_ERROR;
                goto DISCONN;
          }

          /*
           * call the process query function to find one query in 
           * query list which is ok for this element
           */

          syntax1 = 0;
          bj = -1;    /* next starting point */
          sj = 0;

          /*
           * check the object per query. If object is valid for all
           * the queries, it will be put in the resulted select set.
           * sj is starting point which may vary.
           */

restart:
          status = 0 ;
          for( j = sj; j<qry_count; j++ ){

            status =
            VDDIprocess_query(  querylist[j],
                                &object_list[i].obj_id.osnum,
                                &object_list[i].obj_id.objid,
                                &object_list[i].mod_env,
                                syntax1 );

            /* here the ncimacro is filter out */
            if( status ){

              __DBGpr_int(" Found query at j = ", j);

              /*
               * Found a valid query for my object.
               */
              bj = j + 1;

              query_class_name = NULL;
              status = 
              VDmalloc_str_list(&query_class_name, Qrynamenum, Qrynamelen);
        
              if( !(status&1) ) {
                  __DBGpr_com(" query_class_name malloc failed ");
                  *sts = VD_QRY_ERROR;
                  goto wrapup ;
              }

              cl_count = 0;
              status = VDQYget_query_names(&query_class_name, &cl_count);
              if( !(status&1) ) {
                  __DBGpr_com(" can not get query_class_name ");
                  *sts = VD_QRY_ERROR;
                  goto wrapup ;
              }

              break;
            }
          } /* for( j = sj; j<qry_count; j++ ) */

          /* if j < qry_count-1, we need to check rest of querylist against
           * object when its name not match query_class_name or regular 
           * expression. If j >= (qry_count-1, it means all querylists
           * have been checked.
           */   

          if( j >= (qry_count-1) ) bj = -1;

          if( status == OM_S_SUCCESS ){

            char        	class_name[80], mac_name[80];
            struct GRid 	tmp_grid;

            /*
             * is the class/macro name in the select list?
             */

            mac_name[0] = '\0';

            /*
             * get the class of the object
             */
            status =
            om$get_classname(   classname = class_name,
                                objid = object_list[i].obj_id.objid,
                                osnum = object_list[i].obj_id.osnum  );
            if( !(status&1) ) {
                  __DBGpr_com(" can not find class name of object ");
            }

            /*
             * is it a macro? if element's superclass_name
             * is ACcpx, go to find macro id and pathnames
             * then split it into macro names
             * if classname = "ACdiowner" , make channel and
             * get macro_names.
             */

            if( vd_$is_ancestry_valid(  object  = &object_list[i].obj_id,
                                        classid = OPP_ACcpx_class_id )){

                   __DBGpr_com(" object blong to ACcpx ");

                   VD_drwGetACcpxInfo(  &object_list[i].obj_id,
                                        mac_name, TRUE );
                   __DBGpr_obj(" xxxxxxxxxxxx object ", object_list[i].obj_id);
                   __DBGpr_str(" macro name", mac_name);

            } /* vd_$is_ancestry_valid */
            else{
                /*
                 * if object is ACdiowner, then get the GO (graphic object)
                 */
                if( !( strcmp( class_name, "ACdiowner" ) ) ){
                    __DBGpr_com(" class name =  ACdiowner ");

                  /*
                   * make channel connection to GO
                   */
                  status =
                  om$make_chanselect( channame = "GRcmpowner.to_components",
                                      p_chanselect = &MyChannelStruct );

                  /*
                   * get the actual GO connected to the ACdiowner
                   */
                  status =
                  om$get_objid_at_index(
                                objid = object_list[i].obj_id.objid,
                                osnum = object_list[i].obj_id.osnum,
                                p_chanselect = &MyChannelStruct,
                                index = 0,
                                objidaddr = &tmp_grid.objid,
                                osnumaddr = &tmp_grid.osnum );

                  /*
                   * get the class of the GO
                   */
                  status =
                  om$get_classname(classname = mac_name,
                                   objid = tmp_grid.objid,
                                   osnum = tmp_grid.osnum  );
                  if( (status&1) )      
                    __DBGpr_str(" macro name",  mac_name);
                }
            } /* else .. vd_$is_ancestry_valid */

            /*
             * Compare the Names:
             * 1. if macro name is not empty, check macro name against
             *    all query_class_names or match them with regular expression
             *    and check the class name against all query_class_names or
             *    match them with regular expression
             * 2. if macro name is empty, check class name against all
             *    query_class_names or match them with regular expression 
             */
            if( mac_name[0] != '\0' ) {

                status = 0;
                for( j=0; j<cl_count; j++ ){

                  __DBGpr_str(" query_class_name ", query_class_name[j]);

                  if( VDQYis_subclas(mac_name, query_class_name[j]) ||
                      VDQYis_subclas(class_name, query_class_name[j])||
                      VD_matchRE(query_class_name[j],class_name) ||
                      VD_matchRE(query_class_name[j],mac_name) ) {

                    status = 1;
                    __DBGpr_com(" Find match query_class_name ");
                    break;
                  }
                }
            }
            else if(    mac_name[0] == '\0'     ||
                        status != OM_S_SUCCESS ){

                 status = 0;
                 for ( j = 0; j < cl_count; j++) {
                   
                   __DBGpr_str(" query_class_name ", query_class_name[j]);
                  
                   if( VDQYis_subclas(class_name, query_class_name[j])||
                       VD_matchRE(query_class_name[j],class_name) ) {

                     status = 1;
                     __DBGpr_com(" Find match query_class_name(no macro) ");
                     break;
                   }
                 }
            }

#ifdef  temarary keep it
            if ( !status ) {   /* special case for piping */
                 status = 0;

                 for ( j = 0; j < cl_count; j++) {
                    if( !(strcmp( class_name, "VRPCorentity")) && 
                        (!(strcmp(query_class_name[j], "PPccdef")) ||
                         !(strcmp(query_class_name[j], "VRPComp")) )) {
                        status = 1;
                        break;
                    }
                    else if (
                        !(strcmp( class_name, "VRHCorentity")) && 
                        (!(strcmp(query_class_name[j], "HVccdef")) ||
                         !(strcmp(query_class_name[j], "VRHComp")) )) {
                        status = 1;
                        break;
                    }  
                    else if (
                        !(strcmp( class_name, "VRRCorentity")) && 
                        (!(strcmp(query_class_name[j], "RWccdef")) ||
                         !(strcmp(query_class_name[j], "VRRComp")) )) {
                        status = 1;
                        break;
                    }  
                 } 
            } /* if (!satatus ) */ 
#endif

            /*
             * free the memory.
             */
           
  	    VDfree_str_list(query_class_name, Qrynamenum);

            cl_count = 0;

          } /* if( status == OM_S_SUCCESS ) */


          /* when bj != -1 and status != OM_S_SUCCESS, no query name is found
           * , so the object need to be check against rest of querylistis, 
           * bj is next index of querylist, at which we should continue to 
           * check the querylist
           */

          if(    status != OM_S_SUCCESS && bj != (-1)) {
            sj = bj;
            goto restart;
          }


DISCONN:

          if( status != OM_S_SUCCESS ){

                /*
                 * we disconnect this guy from the save set
                status =
                om$send(msg = message GRgrset.GSremove_member(
                                        sts,
                                        &object_list[i].obj_id ),
                        p_chanselect = &me->located_chansel );
                */
                /* set the guy id = NULL_OBJID */

                object_list[i].obj_id.objid = NULL_OBJID;
                del_num = del_num + 1;        
           }
           else{
                __DBGpr_obj(" ACCEPT ", object_list[i].obj_id );

                status =
                vd_$bulk_display(       count   = 1,
                                        dpmode  = GRhd,
                                        objenvs = &object_list[i]);
           }
        } /* for i<count */

        __DBGpr_int( " del_num ", del_num); 
        count1 = count - del_num;
        __DBGpr_int( " count1 ", count1); 
	/* Below check added by Anand (for CR 4488) */
	if( count1 <= 0 )
	    goto wrapup;

        object_list_tmp = NULL;
        object_list_tmp = _MALLOC(count1, struct GRobj_env);
        if( !object_list_tmp ) {
                 printf(" malloc fail!"); 
                 goto wrapup; 
        }
        ii = 0;
        for( i = 0; i < count; i++ ) {
             if( object_list[i].obj_id.objid != NULL_OBJID ) {
                 object_list_tmp[ii] = object_list[i]; 
                 ii++; 
             }
        }
        __DBGpr_int( " ii = ", ii); 
        /*
         * create the new set
         */

        grset_id.osnum = me->ModuleInfo.md_id.osnum;

        status =
        gr$gsinit(      msg = sts,
                        flag = 2,
                        p_objid = &grset_id.objid,
                        osnum = grset_id.osnum,
                        p_chanselect = &me->located_chansel);

        if( !(status & 1) || *sts != MSSUCC ){
                        om$report_error( sts = status );
		        *sts = VD_QRY_ERROR; 
                        goto wrapup;
        }

        status =
        gr$gspost_processing( msg = sts,
                              p_chanselect = &me->located_chansel );

        if( !( status & 1 )){
                om$report_error( sts = status );
		*sts = VD_QRY_ERROR; 
                goto wrapup;
        }

        env_prop = 0;

        for( i=0 ; i<count1 ; i++ ){
                status =
                om$send(msg = message GRgrset.GSobject_add(
                                        sts,
                                        &object_list_tmp[i].obj_id,
                                        &object_list_tmp[i].mod_env,
                                        &env_prop,NULL,NULL ),
                        targetid = grset_id.objid,
                        targetos = grset_id.osnum);

                if( !( status & 1)){
                        om$report_error(sts = status);
                        printf("ERROR: msg GRgrset.GSobject_add\n");
                        *sts = VD_QRY_ERROR;
                        goto wrapup;
                }
                __DBGpr_obj(" result object ", object_list_tmp[i].obj_id);
        }

        status =
        gr$gsput_select_set(    msg     = sts,
                                mod_env = &me->ModuleInfo.md_env,
                                select_set_id = &grset_id );
        if( !( status & 1 )){
                        om$report_error(sts = status);
		        *sts = VD_QRY_ERROR; 
                        goto wrapup;
        }

        /*
         *  Format response data.
         */

        co$build_button(msg = sts,
                        objid = me->window_id.objid,
                        osnum = me->window_id.osnum,
                        button = &event.event.button);

        event.num_id = 1;
        event.num_val = 0;
        event.response = EX_DATA;
        event.subtype = GRst_LOCATE;
        event.located_object[0].located_obj = grset_id;
        event.located_object[0].module_info = me->ModuleInfo;

        size = sizeof( struct GRevent ) - ( 2 * sizeof ( IGRlong ) );

        /*
         * Put EX_OBJID event on front of software queue
         */


        response = EX_OBJID;     
        ex$putque(      msg = sts,
                        response = &response,
                        byte     = &size,
                        buffer   = (IGRchar *)&event.event.button );

        __DBGpr_int(" ex$putque msg ", *sts);
        *sts = VD_QRY_SUCCESS ;

wrapup:

        /* give message */
        sprintf(my_msg, " %d elements are found", count1);
        UI_status(my_msg );

        __DBGpr_com( my_msg );

        /* free memory */ 
        VDfree_str_list(querylist, listnum);

        _FREE( object_list_tmp );
        _FREE( object_list );
        _FREE( outList );

        End 
        goto quit;

} /*send_query*/

/******************************************************************************

Method:
    
    get_all_elt_in_file

Description:

    This method is called if the user has made a MoveOn when he was asked
	to locate  where he wanted the query to be located. What is done
	here is only push on the queue the command "get all elts in file".

******************************************************************************/

action get_all_elt_in_file
{

IGRint          response;
IGRlong         size, msg;
struct EX_cmd	cmd;
struct GRevent	event;
IGRchar		cmd_name[50];

        SetProc(VDCmdQYnpt.get_all_elt_in_file);

	strcpy(cmd_name,"GRSlAlE");

	if( ! ex$get_cmd_info(	string = cmd_name,
				mode = EX_CMD_KEY,
				cmdstr = &cmd))
		*sts = MSFAIL;

	strcpy(event.event.keyin,cmd.command_key);
	size = sizeof( event.event.keyin ) ;

        __DBGpr_int("size ",size);

	/*
	 * Put EX_CMD_KEY event on front of software queue
	 */

	response = EX_CMD_KEY;

	/*
	 * send event
	 */
	status =
	ex$putque(	msg      = &msg,
                        response = &response,
                        byte     = &size,
                        buffer   = event.event.keyin );
	if( !( status & msg & 1 )){
		om$report_error( sts = status );
		*sts = MSFAIL;
	}
        End
        goto quit;

}

/*************************************************************************/
action	create_list
{
IGRint			count = 0 ,num;
        SetProc(VDCmdQYnpt.create_list); Begin

	*sts = MSSUCC ;
        num = om$dimension_of(   varray  = me->queries );
        __DBGpr_int(" size of me->queries ", num);

	status =
	om$vla_set_dimension(	varray	= me->queries,
				size	= 0 );

        /*
         * find the existing query objects.
         */

	status =
	vd$qry_get_id_list(	msg 	= sts,
				count	= &count,
                                ref_file  = TRUE);

	status =
	om$vla_set_dimension(	varray	= me->queries,
				size	= count );

	status =
	vd$qry_get_id_list(	msg		= sts,
				list_size	= count,
				list		= me->queries,
				count		= &count,
                                ref_file        = TRUE);
        num = om$dimension_of(   varray  = me->queries );

        __DBGpr_int(" size of me->queries ", num);

	status = OM_S_SUCCESS;
        End
        goto quit;
} /* create list */

/*=========================================================================*/
action locate_process
{
struct GRobj_env	*locObjs = NULL;
IGRint			NbLocObjs;
IGRint              	i,j;
IGRint              	count, suc, dirIndex = -1;
struct  ret_struct      retStr ;  
IGRint                  DangleFlag = FALSE;
enum GRdpmode           dpmode; 
struct  GRmd_env        ModEnvObj;
IGRchar                 classname[80];

     SetProc(VDCmdQYnpt.locate_process); Begin

     *sts = MSSUCC ;

     status =
     as$start_fence( set    = &me->event1.located_object[0].located_obj,
                     set_env = &me->event1.located_object[0].module_info,
                     nb_obj        = &NbLocObjs,
                     p_obj_env     = &locObjs,    
                     response      = me->response,
                     response_data = me->response_data );

     count = om$dimension_of( varray = me->VDlocObjs );
 
     if ( NbLocObjs ) {
       /*
        * check if object is in list.
       */
       for( i=0 ; i<NbLocObjs ; i++ ){
	 for( j=0 ; j<count ; j++ ){
          if((locObjs[i].obj_id.objid ==  me->VDlocObjs[j].obj_id.objid) &&
             (locObjs[i].obj_id.osnum ==  me->VDlocObjs[j].obj_id.osnum)) 
	  {
	    locObjs[i].obj_id.objid = NULL_OBJID ;
	  }
	 }
       }

       /*
        * not locate dangel  for tr179602956
       */
       dpmode = GRhe;
       for( i=0 ; i<NbLocObjs ; i++ ){
         if( locObjs[i].obj_id.objid != NULL_OBJID ){
          status =
          om$get_classname(
                        classname = classname,
                        objid = locObjs[i].obj_id.objid,
                        osnum = locObjs[i].obj_id.osnum  );
          CheckRC(status,1);

          if( !strcmp( classname, "VRPComp") ){
           /* VRplane will produce error msg from NDmacr method */
          status =
          _VD_SEND_OBJN(  locObjs[i]._grid,
                                 NDmacro.ACgive_structure(& suc,
                                                        & dirIndex,
                                                        "comp_code",
                                                        & retStr,
                                                        & locObjs[i].mod_env ));
          CheckRC(status,suc);

             if(( status& suc & 1 )            &&
                   ( retStr.type == text_type ) &&
                   ( strcmp( retStr.var.text_st.text_string,
                             "dangle" ) == 0 )){
                  __DBGpr_obj("Found the dangle ", locObjs[i]._grid);

                  ModEnvObj.md_id.osnum = locObjs[i].obj_id.osnum;
                  ModEnvObj.md_id.objid = NULL_OBJID;

                  /* erase highlight */
                  status =
                  om$send(msg = message GRgraphics.GRdisplay(
                                sts,
                                &locObjs[i].mod_env.md_env.matrix_type,
                                locObjs[i].mod_env.md_env.matrix,
                                &dpmode,
                                &ModEnvObj.md_id ),
                                targetid = locObjs[i].obj_id.objid,
                                targetos = locObjs[i].obj_id.osnum );
                  CheckRC(status,*sts);
                  locObjs[i].obj_id.objid = NULL_OBJID ;
                  DangleFlag = TRUE;
              } /* if */
          } /* if */
        } /* if */
     } /* for i */
     /* increase the list of me->VDlocObjs */	
	for( i=0 ; i<NbLocObjs ; i++ ){
	/*
	 * add in list.
	 */
	if( locObjs[i].obj_id.objid != NULL_OBJID ){
	  /*
	   * increment of list.
	   */
	  status =
	  om$vla_set_dimension(  varray =  me->VDlocObjs,
				size   =  count +1 );
	  me->VDlocObjs[count]	= locObjs[i];
	  count ++;
	}
      }
     } /* if ( NbLocObjs ) */

     /* tr179602956 */
     if( DangleFlag == TRUE ) {
       FIfld_set_text ( me->forms[0].form_ptr, 10, 0, 0, 
			"Dangle can not be located", FALSE);
       if( !count )
        UI_status(" Dangle can not be located");
       else
        UI_status(" Dangle objects are taken out from located list");
     }

     dpmode = GRhd,
     ASend_fence(); 
     /* highlight selected object list*/  
     for( i = 0; i < count; i++ ) {
                  ModEnvObj.md_id.osnum = me->VDlocObjs[i].obj_id.osnum;
                  ModEnvObj.md_id.objid = NULL_OBJID;

                  /* erase highlight */
                  status =
                  om$send(msg = message GRgraphics.GRdisplay(
                                sts,
                                &me->VDlocObjs[i].mod_env.md_env.matrix_type,
                                me->VDlocObjs[i].mod_env.md_env.matrix,
                                &dpmode,
                                &ModEnvObj.md_id ),
                                targetid = me->VDlocObjs[i].obj_id.objid,
                                targetos = me->VDlocObjs[i].obj_id.osnum );
                  CheckRC(status,*sts);
     }
     End
     goto quit; 

} /* locate_process */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action set_form
{
IGRint              count;
IGRint              i;
IGRchar             class_name[80];
IGRchar             text[QUERY_LEN];
IGRchar             str[QUERY_LEN];
IGRchar             *ptr,
                    buffer[4*QUERY_LEN],
                    query[4*QUERY_LEN];
IGRint              kk, q_flag, len;
IGRchar             *tmp[500];

        SetProc(VDCmdQYnpt.set_form);

	/*
	 * set found information in the form.
	 */
     	count = om$dimension_of( varray = me->VDlocObjs );
        if(!count) {
        me->query_state = 0;

	/* added by alwin,  TR#: 179601572 Date: 5/24/96 */
	SMVA_enable(me->forms[0].form_ptr, 6, FI_RESET, FI_CANCEL,
			QUERY_CMD_SAVE, QUERY_CMD_LOAD, 
			QUERY_CMD_DELETE, BACKUP_BUTTON );
	/* added by alwin,  TR#: 179601572 Date: 5/24/96 */

        status =
        om$send(msg = message VDCmdQYnpt.switch_query_state
                                            (me->query_state, TRUE),
                targetid = my_id );
            goto wrapup;
        }

	text[0] = '\0';
	str[0] = '\0';
        
        for( i = 0; i < count; i++) {
       	   status =
           om$get_classname( 
			classname = class_name,
                        objid = me->VDlocObjs[i].obj_id.objid,
                        osnum = me->VDlocObjs[i].obj_id.osnum  );
           
	   /* put class name into VDquery form on Query*/
           if(text[0] == '\0') {
                strcat(text, class_name);
           }
           else{        
        	strcat(text,"-");
                strcat(text, class_name);
           }

         } /* for */


         /* put query into QUERY field */
         ptr = &text[0];
         buffer[0] = '\0';
         kk = 0;
         q_flag = 1;
         while(ptr != NULL ){
                strcpy(text, &ptr[0]);
                if( VDSGetNextWord(text, query, QUERY_LEN, '-', &ptr) == 0){
                        printf("ERROR VDSGetNextWord\n");
                        return 0;
                }

                /* in order to avoid duplication of names in select filed */

                tmp[kk] = NULL;
                tmp[kk] = _MALLOC(100, char);
                for( i=0; i<kk; i++) {
                  if (strcmp(query, tmp[i])==0) {
                     q_flag = 0;
                     break;
                  }
                }

                if (q_flag == 1) {
                   strcpy(tmp[kk], query);
                   len = strlen(query);
                   tmp[kk][len] = '\0';
                   kk +=1;

                   if(buffer[0] == '\0') 
			strcpy(buffer,"select ");
                   else strcat(buffer,"-"); {
                        strcat(buffer,query ); 
	          }
               } 
                q_flag = 1;
        } /* while */

        /* set MACRO_FIELD */
        if( buffer[0] != '\0')
              FIfld_set_text ( me->forms[0].form_ptr, 
				 MACRO_FIELD, 0, 0, &buffer[7], FALSE);
        else 
              FIfld_set_text ( me->forms[0].form_ptr, 
				 MACRO_FIELD, 0, 0, "", FALSE);
        
        strcat(buffer, " ");

       	/*
       	* write the constructed query in the QUERY field and go to the
       	* next state
       	*/

       	VDqry_set_text(  me->forms[0].form_ptr, QUERY, buffer );
        FIg_disable( me->forms[0].form_ptr, MACRO_LIST );
        FIg_disable( me->forms[0].form_ptr, MACRO_FIELD );

 
        me->query_state = 1;

	/* added by alwin */
	SMVA_enable(me->forms[0].form_ptr, 6, FI_RESET, FI_CANCEL,
			QUERY_CMD_SAVE, QUERY_CMD_LOAD, 
			QUERY_CMD_DELETE, BACKUP_BUTTON ) ;
	FIg_disable(me->forms[0].form_ptr, EDIT_QRY_TOGGLE ) ;
	/* added by alwin */

        status =
        om$send(msg = message VDCmdQYnpt.switch_query_state
                                            (me->query_state, TRUE),
                targetid = my_id );

        /* free memory */
        for ( i=0; i<kk; i++) {
                        _FREE(tmp[i]); 
        }

wrapup:
        End
        goto quit;
} /* set form */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
action return_form
/*----------------------------------------------------------------------------*
 * status field in CEO_LOCATE to get return value of the
 * routine form_notification; sts is used in state table
 *----------------------------------------------------------------------------*/
{
        SetProc(VDCmdQYnpt.return_form); Begin

        *sts = me->rep_label;
        status = OM_S_SUCCESS;

        End
        goto quit;
}

action change_label
{
        SetProc(VDCmdQYnpt.change_label); Begin

        me->rep_label = VD_FORM_DISPLAY;
        me->locate_wakeup = TRUE;
        *sts = me->rep_label;
        FIf_display(me->forms[0].form_ptr); 
        status = OM_S_SUCCESS;
        End
        goto quit;

}

action removefrm
{
        SetProc(VDCmdQYnpt.removefrm); Begin

 	FIf_erase( me->forms[0].form_ptr );
        *sts = MSSUCC;  
        status = OM_S_SUCCESS;
       
        End
        goto quit;
}

/*---------------------------------------------------------------------*/
/*  locelig: return state: VDqry_loc_eli_Zero or VDqry_loc_eli_no_Zero */
/*---------------------------------------------------------------------*/
action locelig
{
int 	el_num; 
        SetProc(VDCmdQYnpt.removefrm); Begin
        
	el_num = om$dimension_of(varray =  me->eligible_classids);
        if(!el_num) {
            *sts = MSFAIL;  
        }
        else 
            *sts = MSSUCC;  

        status = OM_S_SUCCESS;
      
        End 
        goto quit;
}

/*----------------------------------------------------------------------*/
/* keyin_query_name: this function is used to return different state    */
/*                if key in "select query", return VD_QRY_START_IN_FORM */      
/*                if key in "select query = queryname", return          */
/*                               VD_QRY_SUCCESS				*/     
/************************************************************************/ 
action keyin_query_name
{
     IGRint  len = 0;
        
     SetProc(VDCmdQYnpt.keyin_query_name); Begin

     *sts = VD_QRY_SUCCESS;

     len = strlen( me->event1.event.keyin ) + 1;

     if( len == 1 )
     {
          *sts = VD_QRY_START_IN_FORM;
          goto wrapup;
     } 

     
     status = om$vla_set_dimension( varray = me->keyinname, size = len );
     as$status();

     if( status == OM_E_NODYNMEM )
     {
          *sts = VD_QRY_ERROR;
          goto wrapup;
     }
          

     strcpy( me->keyinname, me->event1.event.keyin );

     __DBGpr_str("key in name ", me->keyinname );
wrapup:
     End
     goto quit;
}

/*----------------------------------------------------------------------*/
/* is_query_name_in_list: check key in query name to see if it is in    */
/*                        query list.   			        */
/* return state:          if it is in, return VD_QRY_SUCCESS            */
/*                        else         return VD__QRY_ERROR             */ 
/*----------------------------------------------------------------------*/
action is_query_name_in_list
{
int     		num = 0, i, ii = -1;
IGRchar                 *pSelect,
                        *pWhere,
                        select[QUERY_LEN],
                        where[QUERY_LEN],
                        buffer[QUERY_LEN];
GRname                  gvName;
int                     sts2,sts1,
                        directIndex = 0;
struct  ret_struct      retStr;
struct  GRmd_env        mdEnv;
long                    msg;
OMuword                 my_os1  = 0;
OM_S_OBJID              my_id1  = NULL_OBJID;
struct GRmd_env         my_env1;
IGRint                  syntax1 = 1;

     SetProc(VDCmdQYnpt.is_query_name_in_list); Begin
     
     *sts  = VD_QRY_ERROR;

     num = om$dimension_of(   varray  = me->qry_sortlist );

     /* check key in name to see if it is in list */
     for ( i = 0; i < num; i ++ ) {
         if(strcmp( me->qry_sortlist[i].name, me->keyinname) == NULL) 
          {
  		*sts = VD_QRY_SUCCESS;
                ii = i;
                break;
          }
     }

     /*  get active query from qyery list according to query name */

     if(*sts == VD_QRY_SUCCESS) { 
        /* set active query = null, only have one active query */
        status =
        om$vla_set_dimension(   varray = me->act_queries,
                                size   = 1 );
        as$status();

        /* find relative me->queries */
        strcpy( gvName, VD_qry_nmName );

        for( i=0 ; i<num ; i++ ){
        	status =
        	om$send(msg = message NDmacro.ACgive_structure(
                                                &sts2,
                                                &directIndex,
                                                gvName,
                                                &retStr,
                                                &mdEnv ),
                        mode     = OM_e_wrt_message,
                        targetid = me->queries[i].objid,
                        targetos = me->queries[i].osnum );
        	as$status();

          	if(!strcmp(me->keyinname, retStr.var.text_st.text_string)) {
                        me->act_queries[0].objid = me->queries[i].objid;
                        me->act_queries[0].osnum = me->queries[i].osnum;
                        break;
                }
         }
         /* clear field */
	 VDqry_clr_display(  me->forms[0].form_ptr, QRY_SEL_ACTIVE );
         VDqry_clr_display(  me->forms[0].form_ptr, QRY_SEL_DEF );

         /*
          * fill in field.
          */

         FIfld_set_text(  me->forms[0].form_ptr, QRY_SEL_ACTIVE, 0, 0,
                        me->keyinname, FALSE );

         pSelect = NULL;
         pWhere = NULL;
         ii = 0;
         status =
         om$send(msg = message VDquery.VDgive_query(
                                                        &msg,
                                                        &pSelect,
                                                        &pWhere,
                                                        NULL ),
                                targetid = me->act_queries[0].objid,
                                targetos = me->act_queries[0].osnum,
                                senderid = NULL_OBJID );

        if( (status & msg & 1) && pSelect ){

                     strcpy( buffer, pSelect );
                     strcat( buffer, " " );
                     if( pWhere ) strcat( buffer, pWhere );

                     VDqry_splt_string( buffer, select, where );

                     FIfld_set_text(  me->forms[0].form_ptr, QRY_SEL_DEF,
                                     ii++, 0, select, FALSE );

                     FIfld_set_text(  me->forms[0].form_ptr, QRY_SEL_DEF,
                                     ii++, 0, where, FALSE );

                     strcat( buffer, ";" );
/*
                     if( pSelect ) om$dealloc( ptr = pSelect );
                     if( pWhere  ) om$dealloc( ptr = pWhere  );
*/
                     _FREE ( pSelect );
                     _FREE ( pWhere  );
                     pSelect = NULL;
                     pWhere  = NULL;
 
        	me->buffercontent[0] = '\0';
        	strcpy( me->buffercontent,buffer);

        	sts1 =
        	VDDIprocess_query(
                                me->buffercontent,
                                &my_os1,
                                &my_id1,
                                &my_env1,
                                syntax1 ) >= 0 ? MSSUCC : MSFAIL;


        	if( sts1 == MSSUCC ){
                        VDQYnpt_query[0] = '\0';
                        me->buffercontent1[0] = '\0';
                        strcat( VDQYnpt_query,  me->buffercontent);
                        strcat( me->buffercontent1,  me->buffercontent);
        	}
        	else{
                        UI_status(" Syntax error in query"); 

        	}
        } /*if( (status & msg & 1) && pSelect ) */
        else {

               *sts = VD_QRY_ERROR;
        }
     } /*if(*sts == VD_QRY_SUCCESS) */
     else {
               *sts = VD_QRY_ERROR;
     }

     End
     goto quit;
}
/*---------------------------------------------------------------------*/
/* this function is used to check event                                */
/*---------------------------------------------------------------------*/
action checkEvent
{
        int myresp;
     
        SetProc(VDCmdQYnpt.checkEvent); Begin
        
        if( ex$peek_event_queue( resp = &myresp ) )
        {
                *sts = VD_QRY_CHECK_EVN;
        }
        else
                *sts = MSSUCC;

        status = OM_S_SUCCESS ;

        End
        goto quit;
}

