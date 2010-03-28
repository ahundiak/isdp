/* ASsupport.I
/* design date  : jan 1987 by jla
/* revised date : dec 1987 by ch*/
/*
/*   This file contains many useful routines for the associatif
/**/

class implementation ASnode;

#include "OMmacros.h"
// no longer there  #include "OMintprims.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "exmacros.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "OMindex.h"
#include "macro.h"
#include "DIdef.h"
#include "exmacros.h"

#include "actparam.h"

#define NULL 0
#define AS_DEBUG 1

from GRconic   import GRgetarc;
from GRlinear  import GRgetpolyline;
from OMindex   import translate;
from ACpretgo  import ACgive_info;
from ASsource  import GRconstruct;

extern GRclassid OPP_NDnode_class_id,
		 OPP_AScontents_class_id,
		 OPP_ASmodlin_class_id,
		 OPP_ASmodifier_class_id,
	         OPP_GRcurve_class_id,
		 OPP_GRtext_class_id,
		 OPP_GRgencs_class_id,
		 OPP_GRlineseg_class_id,
		 OPP_GRpoint_class_id,
		 OPP_GRcirarc_class_id,
		 OPP_GRcircle_class_id,
   		 OPP_ASsource_class_id,
		 OPP_ASsourcein_class_id,
 		 OPP_GRgrset_class_id,
		 OPP_GRcsmgr_class_id;

static IGRboolean aflag;


extern	GRclassid OPP_ACcpx_class_id;
extern  OMuword   OPP_ACconst_class_id;

/****************************************************************************
   transform the class name and channel name to class_id and channel_id.
   This id will be used rather than name to improve speed
   Fucntion called by super command object
*****************************************************************************/
    struct GRid NULL_GRID;

    OM_S_CHANSELECT ND_children,
		    ND_father,
		    AS_to_comp,
		    AS_listeners,
		    AS_notification,
		    AS_to_owner;


/*******************

 Fonction declaree pour transaction

*********************/

AStransaction()
{
IGRint batch_mode;
  nd$mod_batch(request = ND_INQ,
 	      p_ret_mode = &batch_mode);
 
 if(batch_mode != ND_DEFER) nd$exec_batch();
	      
 /*|trans*/
 return 1;
}

/***************************************************************************
 
 Global flags used by associative command objects

****************************************************************************/

#define PARAM_NEW 1
#define PARAM_SHARE 2
struct GRid G_active_reference  ;
struct GRid G_active_trackpoint ;
IGRint      G_active_para_type ;
IGRchar G_active_point_weight ;



COpara_init()
/*.COpara_init*/
{
     G_active_reference.objid  = NULL_OBJID  ;
     G_active_trackpoint.objid = NULL_OBJID ;
     G_active_para_type        = PARAM_NEW ;
     G_active_point_weight     = 4 ;
     return(1);
}


ASassoc_init()
/*.ASassoc_init*/
    {
     IGRint status;
     static IGRint already_done = 0;

     if(already_done) return(OM_S_SUCCESS);
     already_done = 1;

/*| Initialize NULL_GRID */
  
      NULL_GRID.objid = NULL_OBJID;
      NULL_GRID.osnum = 0;

/*| Get channel */
        ND_children.type = OM_e_num;
        status = om$get_channel_number
			(channame ="NDchildren.children",
		 	 p_channum = &ND_children.u_sel.number);
	as$status();


        ND_father.type = OM_e_num;
        status = om$get_channel_number
			(channame ="NDfather.father",
		 	 p_channum = &ND_father.u_sel.number);
	as$status();

        AS_to_owner.type = OM_e_num;
        om$get_channel_number
			(channame ="GRconnector.to_owners",
		 	 p_channum = &AS_to_owner.u_sel.number);


        AS_to_comp.type = OM_e_num;
        om$get_channel_number
		(channame ="GRcmpowner.to_components",
		 p_channum = &AS_to_comp.u_sel.number);


        AS_listeners.type = OM_e_num;
        om$get_channel_number
		(channame ="ASsource.listeners",
		 p_channum = &AS_listeners.u_sel.number);


        AS_notification.type = OM_e_num;
        om$get_channel_number
		(channame ="GRnotify.notification",
		 p_channum = &AS_notification.u_sel.number);

/* function to be called before each input by the user --> transaction */
         ex$add_function( fun = AStransaction,
				  mode = EX_START_FUNC);
    return 1;
   }

/****************************************************************************
   Given an object an a locate module, this function returns the adequate object
   to connect dependency.
*****************************************************************************/
 
ASmake_source_from_env(go,mod_env,source,option)
struct GRid *go,*source;
struct GRmd_env *mod_env;
int option;
/*.ASmake_source_from_env*/
{
 struct GRid context;
 IGRlong status,msg;
 GRspacenum cur_osnum;

 status = GRfindcontext( &msg, &mod_env->md_env.matrix_type,
                     mod_env->md_env.matrix, &go->osnum, &context );
 if(status != OM_S_SUCCESS || msg != MSSUCC ) context.objid = NULL_OBJID;

 ex$get_cur_mod( osnum = &cur_osnum);

 status = as$make_source(go_grid = *go,
			 context_grid = context,
			 as_os = cur_osnum,
			 as_grid = source,
			 option = option);
 return(status);
}

/****************************************************************************
   Given an object an a context, this function returns the adequate object
   to connect dependency.
   This adequate object can be :
   - the input object itself if already associatif without context
   - a pretend object if the input object is owned by a an ACsym
   - an already exising source object or a new created one
*****************************************************************************/


ASmake_source(go,context,as_osnum,as,option)
GRspacenum  as_osnum;
struct GRid go, context, *as;
int option;
/*.ASmake_source*/
 {
  IGRlong status, msg;
  GRclassid obj_class, mac_class;
  char path[DI_PATH_MAX];
  struct GRid mac;

  /*"go %d %d context %d %d\n",go.objid,go.osnum,context.osnum,context.objid */

  ASsuper_construct();

/*
   Kludge for make_source on member of a symbol macro when this make source
   is performed during action handler locate 
*/
{
extern int ACSloc_symb;
extern struct GRid ACSinitial_context;

if (ACSloc_symb)
 {
  struct GRid new_go;
  status = ACScreate_dyn_tf_foot(&go,&new_go);
  /*" new_go %d %d\n",new_go.objid,new_go.osnum */
  as$status(action = RET_STATUS);
  go = new_go;
  context = ACSinitial_context;
 }
}
/* end of kludge */

/* If the object understand the message GRnotify.GRmake_source, it is enought */

 as->objid = NULL_OBJID;

 /* look if object go have a macro in owner */
 mac.objid = NULL_OBJID;
 ASget_mac_owner( &go, &mac );
 /*" go : %d/%d; mac : %d/%d\n", go.objid, go.osnum, mac.objid, mac.osnum */

/*
 if( mac.objid == NULL_OBJID ){
*/

/*
 * begin pp 06/08/92
 *
 * Replaced the above line with the following code since construction
 * macros are handled at the solid and surface level.
 */

 if (mac.objid != NULL_OBJID)
 {
  status = om$get_classid(objid = mac.objid,
		         osnum = mac.osnum,
			 p_classid = &mac_class);
 }

 if (((mac.objid != NULL_OBJID) && (om$is_ancestry_valid(subclassid = mac_class,
	  superclassid = OPP_ACconst_class_id) == OM_S_SUCCESS)) ||
     (mac.objid == NULL_OBJID))
 { 
   status = om$send(msg = message GRnotify.GRmksource
				     (&msg,&context,as_osnum,as,option),
  		    senderid = NULL_OBJID,
		    targetid = go.objid,
		    targetos = go.osnum);
   if(status&1) return OM_S_SUCCESS;
 }

/* end pp */


/* retrieve associative owner if any */

 ASget_as_owner(&go,as);

/* There is no associative owner. Is the object itself associative */

  if(IF_NULL_OBJID(as->objid))
   {
    status = om$get_classid(objid = go.objid,
			  osnum = go.osnum,
			  p_classid = &obj_class);
    if(om$is_ancestry_valid(subclassid = obj_class,
			  superclassid = OPP_NDnode_class_id) == OM_S_SUCCESS)
      {
        /*| located object is associative */
        as->objid = go.objid;
        as->osnum = go.osnum;
       }
   }
   

/* No associative owner at all */

  if(IF_NULL_OBJID(as->objid))
    {
     /*| located object is not associative */
     ASmake_source_from_go(&msg,&go,&context,as_osnum,as);
    }

/* either the associative object or its owner is associative */

/* Modif jla 07-jan-91 : Send always make_source to the object, even if  */
/* the object is already a source        				 */
/* It allows some magic for people sublassing ASsource object            */
/*  else */

   {
     path[0] = 0;
     status = om$send(msg = message NDnode.NDmake_source
					  (&msg,&go,&context,path,as_osnum,as),
		      senderid = NULL_OBJID,
		      targetid = as->objid,
		      targetos = as->osnum);
     as$status(action = RET_STATUS);
    }

 /*"src %d %d\n",as->objid,as->osnum */
 return (OM_S_SUCCESS);
 }

/*****************************************************************************
  given a graphic object and a context contruct the corresponding source object
  or retrieve a existing source object with the same context
*****************************************************************************/


ASmake_source_from_go(msg,go,context,as_osnum,as)
IGRint *msg;
struct GRid *go,*context,*as;
GRspacenum as_osnum;
/*.ASmake_source_from_go*/
{
  IGRlong status;
  IGRlong cnst_lis_msg;
  struct GRvg_construct cnst_lis;
  struct GRas asso_lis;
  OM_S_OBJID new_id = NULL_OBJID;
 

/* Is  there already an adequate source element */

  ASget_source( go, context, as, as_osnum );

  if(as->objid !=  NULL_OBJID) 
   {
    /*| matching source found */
    *msg = MSSUCC;
    status = OM_S_SUCCESS;
   }
  else
   {
    /*| Need to create one */
    asso_lis.context = NULL;
    asso_lis.parents = NULL;

    cnst_lis.msg         = &cnst_lis_msg;
    cnst_lis.class_attr  = (char *) &asso_lis;

    asso_lis.my_context  = *context;
    asso_lis.as_attr     = NULL;
    asso_lis.go_objid    = *go;
    asso_lis.num_parents = 0;

    aflag = pwIsActivationOn();
    if((aflag)?(as_osnum == go->osnum):
               (IF_NULL_OBJID(context->objid) && as_osnum == go->osnum))
      {
       /*| source is NOT in a reference file */
       status = om$construct( osnum = as_osnum,
		         msg = message ASsource.GRconstruct(&cnst_lis),
                         classid = OPP_ASsource_class_id, p_objid = &new_id); 

      }
    else
      {
       status = om$construct( osnum = as_osnum,
		         msg = message ASsource.GRconstruct(&cnst_lis),
                         classid =OPP_ASsourcein_class_id, p_objid = &new_id); 
      }

    as$status(action = RET_STATUS);
    as->objid = new_id;
    as->osnum = as_osnum;
   }

  /*" src %d %d\n",as->objid,as->osnum*/
  return(status);
}

/* ********************************************************************* */
/* ASget_mac_owner()
/* 
/*	Get the first macro owner of the given go
/*
/* ********************************************************************	*/

ASget_mac_owner( go, mc_own )

struct GRid *go, *mc_own;
/*.ASget_mac_owner*/
{

 IGRlong status;
 OMuint count;
 OM_S_OBJECT_LINKAGE as_link;
 GRclassid obj_clas;
 struct GRid cmp_object;

 /*" entry with go %d %d\n",go->objid,go->osnum */

 /* initialization to failure */

   mc_own->objid = NULL_OBJID;
   cmp_object = *go;

   while(1)
   {
    status = om$get_channel_objects( osnum = cmp_object.osnum,
				     objid = cmp_object.objid,
				     p_chanselect = &AS_to_owner,
				     list = &as_link,
				     size = 1, count = &count);
    if( !(status&1) || count == 0) break;

    /*"owner is %d %d\n",as_link.S_objid, as_link.osnum */
    status = om$get_classid( osnum = as_link.osnum,
			     objid = as_link.S_objid,
	                     p_classid = &obj_clas );

    /* JUST A KLUDGE BECAUSE CS MANAGER DOES NOT RESPECT CONNECTION ORDER */
   {
    if((om$is_ancestry_valid(subclassid  = obj_clas,
			     superclassid = OPP_GRcsmgr_class_id)
							     == OM_S_SUCCESS))
    {
     OM_S_OBJECT_LINKAGE zz_link[2];

     /*|KLUDGE FOR GRcsmgr */

     status = om$get_channel_objects( osnum = cmp_object.osnum,
                                     objid = cmp_object.objid,
                                     p_chanselect = &AS_to_owner,
                                     list = zz_link,
                                     size = 2, count = &count);
     if((status&1) && (count>1))
       {
	/*|take second object on owner channel */
        as_link=zz_link[1];

        status = om$get_classid( osnum = as_link.osnum,
			     objid = as_link.S_objid,
	                     p_classid = &obj_clas );

       }
    }
   } /* end of the kludge */

    if(	om$is_ancestry_valid( subclassid   = obj_clas,
			      superclassid = OPP_ACcpx_class_id )
		== OM_S_SUCCESS )
	{
	 mc_own->objid = as_link.S_objid;
	 mc_own->osnum = as_link.osnum;
	 break;
        } 
    else
        {
	 cmp_object.objid = as_link.S_objid;
	 cmp_object.osnum = as_link.osnum;
        }
   }

 /*"return mc_own %d %d\n", mc_own->objid, mc_own->osnum */

return	OM_S_SUCCESS;
}
/* ************************************************************************ */
/* ASget_as_owner()
/*
/* 	Give the next associative object able to give a path for a 
/*	given object.
/*
/*	*go	: IN	object who look for next associative owner.
/*	*owner  : OUT	next valid associative owner;
/*			owner->objid = NULL_OBJID if no object found.
/*
/*	algo :
/*	-----
/*	is go a macro : ?  No
/*		go got a macro in owner : ? Yes --> return it
/*
/*	find the fisrt associative object on channel to_owner.
/*
/**********************************************************************	*/


ASget_as_owner( go, owner )
struct GRid *go;         /*  graphic object or owner                          */
struct GRid *owner;      /*  returned as header connected on the channel owner*/
/*.ASget_as_owner*/
{
 IGRlong status;
 OMuint count;
 OM_S_OBJECT_LINKAGE as_link;
 GRclassid obj_clas, go_class;
 struct GRid cmp_object;

 /*" entry with go %d %d\n",go->objid,go->osnum */

	/*| check if macro in owner */
	owner->objid = NULL_OBJID;
	status = om$get_classid(	osnum	= go->osnum,
					objid	= go->objid,
					p_classid = &go_class );
	as$status();
  /*
	if( om$is_ancestry_valid( subclassid	= go_class,
				  superclassid 	= OPP_ACcpx_class_id )
		!= OM_S_SUCCESS ){

		ASget_mac_owner( go, owner );
		if( owner->objid != NULL_OBJID ) return OM_S_SUCCESS;
	}
  */

 /* initialization to failure */

   owner->objid = NULL_OBJID;
   cmp_object = *go;

   while(1)
   {
    status = om$get_channel_objects( osnum = cmp_object.osnum,
				     objid = cmp_object.objid,
				     p_chanselect = &AS_to_owner,
				     list = &as_link,
				     size = 1, count = &count);
    if( !(status&1) || count == 0) break;

    /*"owner is %d %d\n",as_link.S_objid, as_link.osnum */
    status = om$get_classid( osnum = as_link.osnum,
			     objid = as_link.S_objid,
	                     p_classid = &obj_clas );

    /* JUST A KLUDGE BECAUSE CS MANAGER DOES NOT RESPECT CONNECTION ORDER */
   {
    if((om$is_ancestry_valid(subclassid  = obj_clas,
			     superclassid = OPP_GRcsmgr_class_id)
							     == OM_S_SUCCESS))
    {
     OM_S_OBJECT_LINKAGE zz_link[2];

     /*|KLUDGE FOR GRcsmgr */

     status = om$get_channel_objects( osnum = cmp_object.osnum,
                                     objid = cmp_object.objid,
                                     p_chanselect = &AS_to_owner,
                                     list = zz_link,
                                     size = 2, count = &count);
     if((status&1) && (count>1))
       {
	/*|take second object on owner channel */
        as_link=zz_link[1];

        status = om$get_classid( osnum = as_link.osnum,
			     objid = as_link.S_objid,
	                     p_classid = &obj_clas );

       }
    }
   } /* end of the kludge */

    if((om$is_ancestry_valid(subclassid  = obj_clas,
			     superclassid = OPP_NDnode_class_id)
							     == OM_S_SUCCESS))
	{
	 owner->objid = as_link.S_objid;
	 owner->osnum = as_link.osnum;
	 break;
        } 
    else
        {
	 cmp_object.objid = as_link.S_objid;
	 cmp_object.osnum = as_link.osnum;
        }
    
   }

 /*"return owner %d %d\n",owner->objid, owner->osnum */
 return(OM_S_SUCCESS);
}

/****************************************************************************
   Given a graphic object return if there is a source element connected.
   If there is a context specified in call, return if exist the source
   connected to this context.
   If no object found returns NULL_GRID
*****************************************************************************/

ASget_source( go, context, as, as_osnum )
struct GRid *go;      /* graphic object	    */
struct GRid *context; /* context object     */
struct GRid *as;      /* source object	    */
GRspacenum as_osnum;
/*.ASget_source*/
{
 IGRlong status,stat_get;
 IGRint i, size;
 OMuint count, src_count;
 OM_S_OBJECT_LINKAGE _link[5],src_list[2],*src_link;
 GRclassid obj_classid;
 char *ptr;

 /*"go_objid %d,  go_osnum %d\n",go->objid, go->osnum  */

 as->objid   = NULL_OBJID;
 ptr = NULL;
 size = 5;
 src_link = _link;
 status = OM_S_SUCCESS;

 while (1)
  {
   stat_get = om$get_channel_objects(osnum = go->osnum, objid = go->objid,
				     p_chanselect = &AS_notification,
				     list = src_link, size = size,
				     count = &count);
   if(stat_get != OM_S_SUCCESS &&
      stat_get != OM_I_LISTOVFLOW) count = 0;

   for(i=0; i<count; i++)
       {
	if(src_link[i].osnum != as_osnum) continue;

        om$get_classid( objid = src_link[i].S_objid, osnum = src_link[i].osnum, 
     		        p_classid = &obj_classid );

        if(om$is_ancestry_valid( subclassid   = obj_classid,
                          superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS)
         { 
	  /* controle context */

          status = om$get_channel_objects(osnum = src_link[i].osnum,
				          objid = src_link[i].S_objid, 
				  	  p_chanselect = &AS_listeners,
					  list = src_list,
				  	  size = 2, count = &src_count);
	  if(IF_NULL_OBJID(context->objid) && src_count == 1)
	    {
	      /*| matching source found */
	      as->objid = src_link[i].S_objid;
	      as->osnum = src_link[i].osnum;
	      goto wrapup;
	    }
          else if(src_count == 1)
	   {
	    /*| No matching because no context connected */
	   }
          else
	   {
	    if(  (IF_EQ_OBJID(src_list[0].S_objid ,  context->objid)
		             && src_list[0].osnum == context->osnum)
	       ||(IF_EQ_OBJID(src_list[1].S_objid ,  context->objid)
		             && src_list[1].osnum == context->osnum))
	     {
	      /*| matching source found */
	      as->objid = src_link[i].S_objid;
	      as->osnum = src_link[i].osnum;
	      goto wrapup;
	     }
	   }
	 }
       }  /* end for */

   /* Are all the notifier be checked ? */

   if(stat_get == OM_I_LISTOVFLOW)
     {
      status = om$get_channel_count( osnum = go->osnum, objid = go->objid,
			       p_chanselect = &AS_notification, count = &count);
      as$status(action = RET_STATUS);	 
      /*" %d object connected on the notify channnel\n",count*/

      ptr = om$malloc(size = count * sizeof(OM_S_OBJECT_LINKAGE));
      if(ptr == NULL) { /*| bad malloc */ return(OM_W_ABORT); }
       src_link = (OM_S_OBJECT_LINKAGE *) ptr;
       size = count;
     }
   else
     {
      goto wrapup;
     }

   }  /* while(1) */


wrapup :
      if(ptr != NULL)
       {
        /*| free of array */
        om$dealloc( ptr = ptr );
       } 

  /*" return %d %d\n", as->objid,as->osnum */

 return(status);
}


/*****************************************************************************

  Return the structure of an graphic or associatif object

*****************************************************************************/

 ASany_give_struct( object_id,object_os,md_env,inst )
 GRobjid object_id;
 GRspacenum object_os;
 struct GRmd_env *md_env;
 struct ret_struct *inst;
/*.ASany_giv_struct*/
{
 GRclassid go_classid;
 IGRlong status,msg;
 struct GRmd_env local_env;

/*" object %d %d\n",object_id,object_os */
/*" md_id %d %d\n",md_env->md_id.objid,md_env->md_id.osnum */
/*^ printf("matrix_type %d\n",md_env->md_env.matrix_type);
    pr_mat("matrix",4,4,md_env->md_env.matrix);
*/

   /*
      Is module env provided by the caller 
   */
if(md_env == NULL)
  {
   IGRlong NumberOfBytes, BytesReceived,rt;
   /*|give_any_struc provides md_env */
   NumberOfBytes = sizeof( local_env );
   gr$get_module_env(msg = &rt,
                sizbuf = &NumberOfBytes,
                buffer = &local_env,
                nret = &BytesReceived );
   md_env = &local_env;
  }
     

   /*
      depending on the class of the object perform the necessary function
      or method call
   */
   status = om$get_classid(osnum = object_os,objid = object_id,
		  	   p_classid = &go_classid);
   as$status(action = RET_STATUS);
   if (om$is_ancestry_valid(subclassid = go_classid,
                                      superclassid = OPP_NDnode_class_id)==OM_S_SUCCESS)
    {
      status = om$send( msg = message NDnode.NDgive_structure(&msg,inst,md_env),
  	       		senderid = NULL_OBJID,
			targetid = object_id,
			targetos = object_os );
      as$status();
    }
   else
    {
     status = ASgo_give_structure(object_id,object_os,md_env,inst);
    }

/*" return struct type %#x\n", inst->type */
   return(status); 
  }

/* Return the structure of a graphic object */

 ASgo_give_structure( object_id,object_os,md_env,inst )
 GRobjid object_id;
 GRspacenum object_os;
 struct GRmd_env *md_env;
 struct ret_struct *inst;
/*.ASgo_giv_struct*/
{
 GRclassid go_classid;
 IGRint status;
 struct GRid temp_id;
   status = om$get_classid(osnum = object_os,objid = object_id,
		  	   p_classid = &go_classid);
   as$status(action = RET_STATUS);

   if((om$is_ancestry_valid(subclassid = go_classid,
                      superclassid = OPP_ACpretgo_class_id)==OM_S_SUCCESS))
     {
      status = om$send(msg = message ACpretgo.ACgive_info(&temp_id),
  	       		senderid = NULL_OBJID,
	targetid = object_id,targetos = object_os);
      as$status();
      object_id=temp_id.objid;
      object_os=temp_id.osnum;
      status = om$get_classid(osnum = object_os,objid = object_id,
		  	      p_classid = &go_classid);
      as$status(action = RET_STATUS);
      }

   if(om$is_ancestry_valid(subclassid = go_classid,
                          superclassid = OPP_GRcircle_class_id)==OM_S_SUCCESS)
      {
        status = AScircle_give_struct(object_id,object_os,md_env,inst);
        inst->type = circle_type;
      }
   else if(om$is_ancestry_valid(subclassid = go_classid,
                           superclassid = OPP_GRcirarc_class_id)==OM_S_SUCCESS)
      {
         status = AScircle_give_struct(object_id,object_os,md_env,inst);
	 inst->type = arc_type;
      }
   else if (om$is_ancestry_valid(subclassid = go_classid,
                             superclassid = OPP_GRpoint_class_id)==OM_S_SUCCESS)
      {
	 status = ASpoint_give_struct(object_id,object_os,md_env,inst);
      }
   else if (om$is_ancestry_valid(subclassid = go_classid,
                           superclassid = OPP_GRlineseg_class_id)==OM_S_SUCCESS)
      {
         status = ASline_give_struct(object_id,object_os,md_env,inst);
      }
   else if (om$is_ancestry_valid(subclassid = go_classid,
                            superclassid = OPP_GRgencs_class_id)==OM_S_SUCCESS)
      {
       status = ASref_give_struct(object_id,object_os,md_env,inst);
      }
   else if (om$is_ancestry_valid(subclassid = go_classid,
                             superclassid = OPP_GRtext_class_id)==OM_S_SUCCESS)
      {
        status = AStext_give_struct(object_id,object_os,md_env,inst);
      }
   else if (om$is_ancestry_valid(subclassid = go_classid,
                             superclassid = OPP_GRcurve_class_id)==OM_S_SUCCESS)
      {
        inst->type = curve_generic;
        status = OM_S_SUCCESS;
      }

   else if (om$is_ancestry_valid(subclassid = go_classid,
                                   superclassname = "EMSplane" )==OM_S_SUCCESS)
      {
       status = ASplane_give_struct(object_id,object_os,md_env,inst);
      }

    else if (om$is_ancestry_valid( subclassid = go_classid, 
 		          superclassid = OPP_GRgrset_class_id) == OM_S_SUCCESS)
      {
        inst->type = set_generic;
        status = OM_S_SUCCESS;
      }
   else
      {
	inst->type = other_generic;
        status = OM_S_SUCCESS;
      } 
 return(status);
}/* ASany_give_struct */


 AScircle_give_struct( object_id,object_os,md_env,inst)
 GRobjid object_id;
 GRspacenum object_os;
 struct GRmd_env *md_env;
 struct ret_struct *inst;

/*.circle_give_structure*/
{
  struct IGRarc arc;
  IGRlong msg,status;
  IGRshort mat_type;
  IGRmatrix mat_id;			/* environment matrix                */
  IGRdouble *matrix;
  IGRshort i;
  struct circle_data *circledef;
  IGRdouble *x,*y;

  /*  en attendant d'utiliser directement le buffer */
  GRabsg_del_all();

if (md_env == NULL)
 {
  mat_type = MAIDMX;
  MAidmx(&msg,mat_id);
  matrix = mat_id;
 }
else
 {
  mat_type = md_env->md_env.matrix_type;
  matrix = md_env->md_env.matrix;
 }


  status = om$send( msg = message GRconic.GRgetarc(&msg,&mat_type,matrix,&arc),
	   senderid = NULL_OBJID, 
	   targetid = object_id, targetos = object_os );
  as$status(test = (!(status&1) || msg != MSSUCC),
	    action = RET_VALUE,
	    value  = OM_W_ABORT);

  circledef = &(inst->var.circle_st);
  

      circledef->start_angle = arc.start_angle;
      circledef->sweep_angle = arc.sweep_angle;

      circledef->rad = arc.prim_axis;

      x = circledef->mat;
      y = arc.rot_matrix;
      for( i=0; i<16; ++i )
	 {
	   x[i] = y[i];
	 }

/* to have a real 4x4 transformation matrix */
      y = arc.origin;
      x[3] = y[0];
      x[7] = y[1];
      x[11] = y[2];
      x[15] = 1.;

      x = circledef->cent_p;
      x[0] = y[0];
      x[1] = y[1];
      x[2] = y[2];
  return( 1 );
} /* AScircle_give_struct */


 ASline_give_struct( object_id,object_os,md_env,inst )
 GRobjid object_id;
 GRspacenum object_os;
 struct GRmd_env *md_env;
 struct ret_struct *inst;

/*.line_give_structure*/
{
/* struct IGRbsp_curve *bc;		/* abstract geom pointer	     */
  struct IGRpolyline polyline;

  IGRmatrix mat_id;			/* environment matrix                */
  IGRdouble *matrix;

  IGRshort mat_type;			/* environment matrix type           */

  /* IGRlong i;				/* index			     */
  IGRlong msg,status;			/* return code			     */
  IGRint action;

  struct line_data *linedef;
/*   IGRdouble *x,*y,*v0;  */




if (md_env == NULL)
 {
  mat_type = MAIDMX;
  MAidmx(&msg,mat_id);
  matrix = mat_id;
 }
else
 {
  mat_type = md_env->md_env.matrix_type;
  matrix = md_env->md_env.matrix;
 }

/*
    modif jla to use the GRgetpolyline method 
*/

  action = 1;
  linedef = &inst->var.line_st;
  polyline.points = linedef->p0;
  inst->type = line_generic;
  status = om$send(msg = message GRlinear.GRgetpolyline(&msg,&mat_type,
					matrix,&action,&polyline),
	           senderid = NULL_OBJID,
		   targetid = object_id,targetos = object_os);
  as$status(action = RET_STATUS);
  if(msg != MSSUCC) return (OM_W_ABORT);
  if(polyline.num_points != 2) return(OM_W_ABORT);

  MAsubvc(&msg,linedef->p1 , linedef->p0 , linedef->v0);
  MAunitvc(&msg , linedef->v0 , linedef->v0);
  if(msg == MASDGENRAT)
   {
    /*| I never want unit vector to degenerate !!!! */
    linedef->v0[0] = 1.;
   }
  GRabsg_del_all();

  return( OM_S_SUCCESS );
} /* ASline_give_struct */


 ASpoint_give_struct( object_id,object_os,md_env,inst )
 GRobjid object_id;
 GRspacenum object_os;
 struct GRmd_env *md_env;
 struct ret_struct *inst;

/*.point_give_structure*/
{

/*IGRchar *ptr;				/* abstract geom pointer	     */

  IGRmatrix mat_id;			/* environment matrix                */
  IGRdouble *matrix;

  IGRshort mat_type;			/* environment matrix type           */

  IGRlong msg;				/* return code			     */
  IGRint status;
  IGRint action;

  struct IGRpolyline polyline;
  /* struct point_data *pointdef; */
  /* IGRdouble *x,*y;  */




if (md_env == NULL)
 {
  mat_type = MAIDMX;
  MAidmx(&msg,mat_id);
  matrix = mat_id;
 }
else
 {
  mat_type = md_env->md_env.matrix_type;
  matrix = md_env->md_env.matrix;
 }
  action = 1;
  polyline.points = inst->var.point_st.pt;
  inst->type = point_generic;
  status = om$send(msg = message GRlinear.GRgetpolyline(&msg,&mat_type,
					matrix,&action,&polyline),
	           senderid = NULL_OBJID,
		   targetid = object_id,targetos = object_os);
  as$status(action = RET_STATUS);
  if(msg != MSSUCC && msg != MAIDGENRAT) return (OM_W_ABORT);
  if(polyline.num_points != 1) return(OM_W_ABORT);
  GRabsg_del_all();
  return( OM_S_SUCCESS );
 }  /* ASpoint_give_struc */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         method AS_ref_give_structure                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASref_give_struct( object_id,object_os,md_env,refdef )

  GRobjid         object_id;
  GRspacenum      object_os;
  struct GRmd_env *md_env;
  struct ret_struct *refdef;      /* Structure wich return the instances     */

/*.ref_give_structure*/
  {
  IGRchar    *p_geom;              /* Pointer on the abstract geometry        */
  IGRlong    status;               /* Status returned by om                   */
  IGRint     index;                /* Index for a loop                        */
  IGRlong    msg;                  /* Status returned by functions            */
  IGRshort   mat_type;          /* Type of the matrix                      */
  IGRmatrix mat_id;			/* environment matrix                */
  IGRdouble *matrix;
  IGRdouble *x,*y;

  /*| Get the generic type */

  refdef->type = ref_generic;

  /*| Get the referential matrix */


if (md_env == NULL)
 {
  mat_type = MAIDMX;
  MAidmx(&msg,mat_id);
  matrix = mat_id;
 }
else
 {
  mat_type = md_env->md_env.matrix_type;
  matrix = md_env->md_env.matrix;
 }

  status = om$send(msg = message GRvg.GRgenabsg(&msg,&mat_type,matrix,&p_geom),
                   senderid = NULL_OBJID,
                   targetid = object_id,
                   targetos = object_os);    

  as$status(test = (!(status&1) || msg != MSSUCC),
	    action = RET_VALUE,
	    value  = OM_W_ABORT);

  x = refdef->var.ref_st.t;
  y = ((struct IGRlbsys *) p_geom)->matrix;
 
  /*| Load the matrix of the referential */

  for(index=0; index<16; index++) 
    x[index] = y[index];

  return(OM_S_SUCCESS);
}/* end fuction ASref_give_struct */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         method ASplane_give_structure                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASplane_give_struct( object_id,object_os,md_env,inst )

  GRobjid         object_id;
  GRspacenum      object_os;
  struct GRmd_env *md_env;
  struct ret_struct *inst;

/*.plane_give_structure*/
{
  struct IGRplane	plane;
  IGRmatrix mat_id;			/* environment matrix                */
  IGRdouble *matrix;
  IGRshort mat_type;			/* environment matrix type           */
  IGRlong msg,status;			/* return code			     */
  struct line_data *linedef;

  linedef = &inst->var.line_st;
  /* to not break dimensioning, don't return line_generic .....*/
  inst->type = debug_type;

if (md_env == NULL)
 {
  mat_type = MAIDMX;
  MAidmx(&msg,mat_id);
  matrix = mat_id;
 }
else
 {
  mat_type = md_env->md_env.matrix_type;
  matrix = md_env->md_env.matrix;
 }

  plane.point  =linedef->p0;
  plane.normal =linedef->p1;

  status = om$send( msg = message  GRvg.GRdetplane( &msg,
			       		         &mat_type,
			       		        matrix,
                                                 &plane),
                   senderid = NULL_OBJID,
                   targetid = object_id,
                   targetos = object_os);    

  as$status(test = (!(status&1) || msg != MSSUCC),
	    action = RET_VALUE,
	    value  = OM_W_ABORT);

  MAsubvc(&msg,linedef->p1 , linedef->p0 , linedef->v0);
  MAunitvc(&msg , linedef->v0 , linedef->v0);
  return( OM_S_SUCCESS );
} /* ASplane_give_struct */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         method AStext_give_structure                       */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

AStext_give_struct( object_id,object_os,md_env,textdef )

  GRobjid         object_id;
  GRspacenum      object_os;
  struct GRmd_env *md_env;
  struct ret_struct *textdef;     /* Structure wich return the instances     */

/*.text_give_structure*/
 {
  char *ptr;

  IGRdouble *matrix;
  IGRmatrix mat_id;			/* environment matrix                */
  IGRshort mat_type;			/* environment matrix type           */
  struct IGRlbsys *lb_def;

  IGRlong i;				/* index			     */
  IGRlong msg;				/* return code			     */
  IGRlong status;			/* OM return code		     */


if( md_env == NULL)
  {
   mat_type = MAIDMX;
   MAidmx(&msg,mat_id);
   matrix = mat_id;
  }
else
  {
   mat_type = md_env->md_env.matrix_type;
   matrix   = md_env->md_env.matrix;
  }

  status = om$send(msg = message GRvg.GRgenabsg(&msg,&mat_type,matrix, &ptr),
                   senderid = NULL_OBJID,
                   targetid = object_id,
                   targetos = object_os);    
  as$status(action = RET_STATUS);



  lb_def = (struct IGRlbsys *) ptr;
/**************/

  for (i=0 ; i<16 ; i++)  textdef->var.lb_st.matrix[i] = lb_def->matrix[i]; 

  for (i=0 ; i<3 ; i++) textdef->var.lb_st.diag_pt1[i] = lb_def->diag_pt1[i];

  for (i=0 ; i<3 ; i++) textdef->var.lb_st.diag_pt2[i] = lb_def->diag_pt2[i];

  textdef->type = lbs_generic;


  return(OM_S_SUCCESS);
  

}

/* 
  return the real size of the returned_structure 
  depending upon the type of the object
*/

IGRint ASgive_size_st(type)
IGRint type;
/*.ASgive_size_st*/
{
IGRint size;

if(type&line_generic)      	size =  8+sizeof(struct line_data);
else if(type&point_generic)     size =  8+sizeof(struct point_data);
else if(type&conic_generic)     size =  8+sizeof(struct circle_data);
else if(type==double_type)      size =  8+sizeof(struct root_parameter_data);
else if(type==text_type)        size =  8+sizeof(struct text_data);
else if(type&lbs_generic)       size =  8+sizeof(struct lbs_data);
else if(type&ref_generic)       size =  8+sizeof(struct ref_data);
else if(type&macro_generic)     size =  8+sizeof(struct macro_data);
else 				size =  sizeof(struct ret_struct);
size = 1+(size-1)/8;
return (8*size);

}



/* fonction used to find the modifier acting on an object */

ASfind_modifier(object,other,modifier)
   struct GRid object,other,*modifier;
  /*.find_modifier*/
  {
  IGRint status;
  struct GRid *buffer;
  int count_c,count_i;
  GRclassid obj_class;

  modifier->objid = NULL_OBJID;

  status = om$send
             (msg      = message NDnode.NDget_objects(ND_CHILDREN | ND_IN_BUF,
                                        NULL,0,&buffer,0,OM_K_MAXINT,&count_c),
              senderid = NULL_OBJID,
	      targetid = object.objid,
              targetos = object.osnum);
  as$status(action = RET_STATUS);

  /*" The object %d has %d children\n",object.objid,count_c */
  for(count_i=0 ; count_i<count_c ; count_i++)
    {
    om$get_classid(osnum     = buffer[count_i].osnum,
	           objid     = buffer[count_i].objid,
                   p_classid = &obj_class);
    as$status(action = RET_STATUS);

    if(((om$is_ancestry_valid(subclassid = obj_class,superclassid = OPP_ASmodifier_class_id) == OM_S_SUCCESS)
    || (om$is_ancestry_valid(subclassid = obj_class,superclassid = OPP_ASmodlin_class_id) == OM_S_SUCCESS)))
      {
      if(!(IF_EQ_OBJID(other.objid,buffer[count_i].objid)))
        {
        modifier->objid = buffer[count_i].objid;
        modifier->osnum = buffer[count_i].osnum;
        break;
      }/* end if(!(IF_EQ_OBJID(other.objid,buffer[count_i].objid))) */
    }/* end if */
  }/* end for */
  return(OM_S_SUCCESS);
}/* end ASfind_modifier */

int ASold_count;

#argsused
AScontrole_rtree(string,code)
IGRchar *string;
IGRint code;
/*.controle_rtree*/
 {
/*^
   {
    OM_S_CHANSELECT   chan;
    IGRchar	      name[8];
    IGRint	      how_big;
    IGRlong           status;
    OM_S_KEY_DESC     rtree_key_test;
    DB_3D_DBL_BOX     rtrange_test;
    IGRlong NumberOfBytes, BytesReceived,rt;
    struct GRmd_env local_env;

    int ret_bis,i,array_size;
    OM_S_OBJARRAY *obj_array;

   NumberOfBytes = sizeof( local_env );
   gr$get_module_env(msg = &rt,
                sizbuf = &NumberOfBytes,
                buffer = &local_env,
                nret = &BytesReceived );


    strcpy(name, "primary");
    chan.type = OM_e_name;
    chan.u_sel.name = name;
    how_big = sizeof (DB_3D_DBL_BOX);    

    rtree_key_test.type = KEY_3D_DBL;
    rtree_key_test.key.p_3ddbl = &rtrange_test;


    rtree_key_test.type = KEY_3D_DBL;
    rtree_key_test.key.p_3ddbl = &rtrange_test;

    array_size = (sizeof(OM_S_OBJID) * 100) +
                   sizeof(OM_S_OBJARRAY);

    obj_array = om$malloc(size = array_size);
    obj_array->size = array_size;

    obj_array->count = 0;
    obj_array->tree_type = KEY_3D_DBL;

    rtrange_test.xmin = -100000;
    rtrange_test.ymin = -100000;
    rtrange_test.zmin = -100000;

    rtrange_test.xmax = 100000;
    rtrange_test.ymax = 100000;
    rtrange_test.zmax = 100000;

    status = om$send(msg = message OMindex.translate(obj_array,
				   &rtree_key_test, NULL,NULL,&ret_bis),
		     senderid  = local_env.md_id.objid,
		     targetos = local_env.md_id.osnum,
                     p_chanselect = &chan);
    as$status();
    if(ASold_count != obj_array->count)
		 printf("nb of obj in rtree change old %d\n",ASold_count);
      
    if(code&1 || ASold_count != obj_array->count)
        printf(" %s ,new count %d obj\n",string,obj_array->count);
    

    if(code&2 || ASold_count != obj_array->count )
      {
       for(i=0;i<obj_array->count&&i<100;i++)
	 {printf("%d ",obj_array->array[i]);}
       printf("\n");
      }
    ASold_count = obj_array->count;
    om$dealloc(ptr = obj_array);
   }
  */
  return 1;
 }

 
end implementation ASnode;
