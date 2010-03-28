/*
   ASsource implementation file

HISTORY :
   jla nov 86  : design date
   ch  dec 87  : update for version 1.1
*/

class implementation ASsource;

#include "OMmacros.h"
#include "godef.h"
#include "grerr.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "ASmatrix.h"
#include "AS_status.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "madef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "batch.h"
#include "csdef.h"
#include "griodef.h"
#include "grcoordsys.h"



#define AS_DEBUG

from GRnotify    import GRntfyconn;
from GRgraphics  import GRconstruct, GRaltconstruct, GRcopy, GRdisplay,
			GRdelete, GRremwrng, GRchgprops;
from GRconnector import GRflexconn,GRdisconn;
from GRcontext   import GRgetinstance;

from ACpretgo    import ACgive_info;

extern IGRboolean ASbroadcast_in_progress;

extern GRclassid  OPP_AScontents_class_id;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* return structure of an element waiting delete 			      */
/* (the graphic object is already deleted)				      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

%safe

struct ext_list NDstoel     /* list of objects with stored ret_struct       */
       = {NULL,NULL,NULL,0,0,0,0};
struct ret_struct *NDstorst  /*  corresponding returned structure       */
       = NULL;
extern struct ext_list NDdelete;
%endsafe


ASfind_in_del(obj,rst)
struct GRid obj;
struct ret_struct *rst;
/*.ASfind_in_del*/
{
 IGRint index_in_buf;

     index_in_buf = NDin_buffer(obj,&NDstoel);

     if(index_in_buf != -1)
       {
	 /*"%d found\n",obj.objid */
	 
         /* *rst=NDstorst[index_in_buf]; */

         OM_BLOCK_MOVE( (char *)&NDstorst[index_in_buf], (char *)rst, ASgive_size_st(NDstorst[index_in_buf].type) );
         return(OM_S_SUCCESS);
       }
     else
       {
	 /*"%d not found\n",obj.objid */
	 return(OM_W_ABORT);
       }
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* add the structure of an element waiting delete  in the list                */
/* because the graphic object will be deleted before the move_to_root         */
/* of children and one of them could ask its structure during move_to_root    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASadd_in_del(obj,rst)
struct GRid obj;
struct ret_struct *rst;
/*.ASadd_in_del*/
{
 IGRint index_in_buf;
 IGRlong status;

/*
   If there more object storing give_structure than object waiting delete
   clear the list
*/

  if(NDstoel.nb_obj > NDdelete.nb_obj)
    {
     /*| clear stoel list */
     NDstoel.nb_obj = 0;
    }

/* is obj already in list */

  index_in_buf = NDin_buffer(obj,&NDstoel);

  if(index_in_buf != -1)
    { /*"%d already in list !!\n",obj.objid */
      NDstorst[index_in_buf] = *rst;
    }

  else
    { /*"%d add in list\n",obj.objid */
     status = NDdef_size(1,&NDstoel,&NDstorst,sizeof(struct ret_struct),0);
     NDstoel.list_id[NDstoel.nb_obj] = obj;
     NDstorst[NDstoel.nb_obj] = *rst;
     NDstoel.nb_obj += 1;
    }
 return 1;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* clear the list of stored ret_struct 					      */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

ASclear_del()
{
 NDstoel.nb_obj = 0;
 return(OM_S_SUCCESS);
}

method NDcopy(IGRlong *msg; IGRint cn_type;
	      struct GRmd_env *obj_env, *new_env; struct GRid *newobjid)
{
 IGRlong status;
 struct GRid graphic_c;
 OMuint count;
 OM_S_OBJECT_LINKAGE go_link;
 IGRint  list_index;
 IGRboolean old_ASbroad, tag_conn;
 IGRboolean split_flag;
 GRspacenum tag_osnum;

 newobjid->objid = NULL_OBJID;
 old_ASbroad = ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;
 split_flag = FALSE;

 /*" Copy the source object: %d\n", my_id */
 status = om$construct_and_copy( object = me, 
				 obj_osnum = obj_env->md_id.osnum, 
	    			 osnum = new_env->md_id.osnum,
            			 p_objid = &newobjid->objid);
 as$status(action = GOTO_VALUE, value = wrapup);

 newobjid->osnum = new_env->md_id.osnum;
 /*" Copied object: %d, %d\n", newobjid->objid, newobjid->osnum */

/* Get graphic object */

 status = om$get_channel_objects(osnum = obj_env->md_id.osnum, 
   				 objid = my_id, p_chanselect = &AS_listeners,
				  list = &go_link, size = 1, count = &count);
 as$status(action = GOTO_VALUE, value = wrapup);
 if(count != 1) {status = OM_W_ABORT;goto wrapup;}

 /*" Object connected: %d, %d\n", go_link.S_objid, go_link.osnum */


 /* Copy the graphic object */

/*^pr_mat("obj_env",4,4,obj_env->md_env.matrix);
   pr_mat("new_env",4,4,new_env->md_env.matrix);
*/
  if(ASMget_splitpart() == TRUE)
   {
     if(IF_NULL_OBJID(new_env->md_id.objid))
      {
        new_env->md_id.objid = obj_env->md_id.objid;
        split_flag = TRUE;
      }
   }
  status = om$send( msg = message GRgraphics.GRcopy( msg, obj_env,
 		    new_env, &graphic_c.objid ),
 		    targetid = go_link.S_objid, targetos = go_link.osnum);

  if(split_flag)
    new_env->md_id.objid = NULL_OBJID;

  as$status(action = GOTO_VALUE,
	     value = wrapup);
  graphic_c.osnum = new_env->md_id.osnum;
  /*" Graphic object copied: %d, %d\n",graphic_c.objid,graphic_c.osnum */ 

 /* Connect together the graphic and the associative object */
 
  tag_conn = FALSE;
  list_index = OM_K_MAXINT;
  status = om$send( msg = message GRnotify.GRntfyconn( msg, newobjid,
	            &AS_listeners, &list_index, &tag_conn, &tag_osnum ),
		    targetid = graphic_c.objid, targetos = graphic_c.osnum );
  as$status(action = GOTO_VALUE,
	     value = wrapup);


 wrapup : 
 ASbroadcast_in_progress = old_ASbroad;
 return(status);
}


/*
   Reconnect if necessary graphic object to contents
*/

 method NDconnect(int nb_root; struct GRid *root; struct GRid original;
                  IGRint type)
 
 {
  IGRint i;
  IGRlong flag, index, graphics_index;
  IGRlong status,msg;
  GRclassid obj_clas;

 /* first does the node connection */
 
 status = om$send(msg=message NDnodein.NDconnect(nb_root, root, original, type),
		  targetid=my_id,
		  mode = OM_e_wrt_message);
 as$status(action = RET_STATUS);


 /* if contents as root, reconnect graphic object to contents */

 
 for( i=0; i<nb_root; i++ )
  {
   om$get_classid( objid = root[i].objid, osnum = root[i].osnum, 
   		   p_classid = &obj_clas );
   if(om$is_ancestry_valid( subclassid   = obj_clas,
   		       superclassid = OPP_AScontents_class_id) == OM_S_SUCCESS)
    {
     /*| Connect the GO to the AScontents object */
     flag = 0;
     index = 0;
     graphics_index = 0;
  
     status=om$send( msg = message GRconnector.GRflexconn(&msg, &flag, &root[i],
                       				       &index, &graphics_index),
   		     p_chanselect = &AS_listeners);
     if( msg == GRDEFAULT_USED ) printf("connection to an another index\n");
     if( msg == GRNOCONNECT )    printf("Rigid owners already exists\n");
     if( msg == MSFAIL) 	 printf("error in the reconnection\n");
    }
  }     

 return(status);
}

 


/* disconnect from contents if any */

method NDmove_to_root(IGRlong *msg; struct GRid *src_grid; 
		      struct GRmd_env *md_env )
{
 struct GRid *roots;
 GRclassid obj_clas;
 IGRint i,count;
 long status;
 char obj_state;
 
 status = om$send(msg = message NDnode.NDget_state(&obj_state),
		  targetid = my_id);
 if(status&1 && obj_state&ND_DONT_MVRT)
  {
   status=om$send(msg = message NDnodein.NDmove_to_root(msg, src_grid, md_env),
		    mode = OM_e_wrt_message,
		    targetid = my_id);
   return(status);
  }

 src_grid->osnum = OM_Gw_current_OS;
 src_grid->objid = my_id;

 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,
					NULL,0,&roots,0,OM_K_MAXINT,&count),
		  targetid = my_id);

 as$status();
 if((status&1) && count > 1)
   {
    for(i=0;i<count;i++)
    {
     om$get_classid(objid= roots[i].objid,osnum=roots[i].osnum,
		    p_classid = &obj_clas);
     if(om$is_ancestry_valid( subclassid   = obj_clas,
                       superclassid = OPP_AScontents_class_id) == OM_S_SUCCESS)
       {
        status=om$send( msg = message GRconnector.GRdisconn( msg, &roots[i] ),
                       p_chanselect = &AS_listeners);
        as$status();
       }
     }
    status = om$send(msg = message  NDnode.NDdisconnect(0,NULL),
		        targetid = my_id);
    as$status();

   }
 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}

/* copy_to_root fo source is  same as copy  */

method NDcopy_to_root(IGRlong *msg;IGRint cp_type;
		      struct GRmd_env *obj_env, *new_env; 
		      struct GRid *newobjid)
{
 IGRlong status;
 status = om$send(msg = message ASsource.NDcopy(msg,cp_type,obj_env,new_env,
						newobjid),
		  targetid = my_id);
 as$status();
 return(status);
}

method NDprint( struct GRmd_env *md_env; FILE *stream )
{
 as$printer_print_root( flag = AS_PR_WITH_REF );
 return( OM_S_SUCCESS );
}

method NDprint_root( struct GRmd_env *md_env; FILE *stream )
{
 as$printer_print_root( flag = AS_PR_WITHOUT_REF );
 return( OM_S_SUCCESS );
}

method NDgive_structure(IGRlong *msg; struct ret_struct *str;
			 struct GRmd_env *md_env )
{
 IGRint status;
 struct GRid my_grid, go;

/*| get graphic object connected ---*/
/*" obj %d \n",my_id*/

 *msg = MSSUCC;

 status = om$send(msg = message ASsource.ASreturn_go( &go, NULL, NULL),
		  targetid = my_id);
 if(status & 1)
 {
   /*" graphics object: %d, %d\n",go.objid, go.osnum */
   status = ASgo_give_structure( go.objid, go.osnum,
                                 md_env ,str );
  }
 else
  {
     /*| DELETED ELEMENT */
     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;
     status = ASfind_in_del(my_grid,str);
  }

 return( status );
}

method GRconstruct( struct GRvg_construct *arglist )
{
 struct GRas *class_attr;
 IGRlong status, msg;
 IGRint i, list_index;
 struct GRid *parent_id, my_grid, *context_id;
 GRclassid parent_classid;
 struct ret_struct root_def;
 IGRboolean tag_conn;
 GRspacenum tag_osnum;

 
 *(arglist->msg) = OM_S_SUCCESS;
 class_attr = (struct GRas *) arglist->class_attr;
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 /*| create the associative object in a sub class of source if needed */
 /* If root is a coordonate system  */
 parent_id = class_attr->parents;
 context_id = class_attr->context;
 for(i = 0 ; i < class_attr->num_parents ; i++)
  {
   /*" The source depends on a root: %d\n",parent_id[i].objid,parent_id[i].osnum */
   om$get_classid( osnum = parent_id[i].osnum, objid = parent_id[i].objid,
  		   p_classid = &parent_classid );

   if(om$is_ancestry_valid( subclassid = parent_classid,
   		            superclassid = OPP_AScontents_class_id ) == OM_S_SUCCESS)
    {
     /*| The source object depends on a contents (coord) */
     continue;
    }
   if( context_id != NULL )
    {
     status = as$make_source( go_grid = parent_id[i], as_grid = &parent_id[i],
                              context_grid = context_id[i] );
    }
   else
    {
     status = as$make_source( go_grid = parent_id[i], as_grid = &parent_id[i] );
    }
   as$status(action = RET_STATUS);

   /*"root source: %d, %d\n", parent_id[i].objid, parent_id[i].osnum */

   status = om$send(msg = message NDnode.NDgive_structure
                                        (&msg,&root_def,arglist->env_info),
                    targetid = parent_id[i].objid,
                    targetos = parent_id[i].osnum);
   if(!(root_def.type&ref_generic))
    {
      printf("object %d is a bad root for source %d --> does not connect",
              parent_id[i].objid,my_id);
      class_attr->num_parents = 0;
    }
  }

   /*| connect together the graphic and the associative object */
     tag_conn = FALSE;
     list_index = OM_K_MAXINT;
     status = om$send( msg = message GRnotify.GRntfyconn( &msg, &my_grid,
  	           &AS_listeners, &list_index, &tag_conn, &tag_osnum ), targetid = class_attr->go_objid.objid, 
		   targetos = class_attr->go_objid.osnum );
     as$status(action = RET_STATUS);

/**************************************************************************
        DLB - CHANGE TO (1 & msg) since applications may have return code
	other than MSSUCC *****12/3/92*******
    if( msg == MSSUCC ) return(OM_S_SUCCESS);
***************************************************************************/

     if (1 & msg) return(OM_S_SUCCESS);
/********END DLB CHANGE*********/	

/**************************************************************************
	DLB - USE arglist->env_info for NDdelete instead of NULL 
**************************************************************************/
 
     /*|  Connection impossible -> On tue l'object associatif */
     status = om$send( msg = message NDnode.NDdelete(arglist->env_info), 
     			targetid = my_id ); 
     return (OM_W_ABORT);
} /* GRconstruct */

method NDdisplay(IGRint dp_mode;enum GRdpmode pen; struct GRmd_env *obj_env)
 {
  IGRint status;
  struct GRid mod_grid;
  IGRshort mat_type;
  IGRmatrix mat_ident;
  IGRdouble *mat;
  IGRlong msg;
  

  if(obj_env == NULL)
    {
     mat_type = MAIDMX;
     MAidmx(&msg,mat_ident);
     mat = mat_ident;
    }
  else
    { 
     mat_type = obj_env->md_env.matrix_type;
     mat = obj_env->md_env.matrix;
    }
  GRfindmod(&mod_grid);
  status = om$send(msg = message GRgraphics.GRdisplay(&msg,
				  &mat_type, mat, &pen, &mod_grid),
		   p_chanselect = &AS_listeners);
   as$status();
   return(status);
  }

method unknown(OM_S_MESSAGE *msg)
{
 IGRlong status;
 
 status = om$send( msg = msg, p_chanselect = &AS_listeners);
 return(status);
}

method ASreturn_go(struct GRid *go;IGRshort *mat_type;IGRdouble *matrix)
{
 IGRint status,msg;
 extern GRclassid OPP_ACpretgo_class_id;
 OM_S_OBJECT_LINKAGE go_link;
 OMuint count;
 GRclassid go_classid;


/*| get graphic object */


 status = om$get_channel_objects(object = me, p_chanselect = &AS_listeners,
				 list = &go_link,size = 1, count = &count);

 as$status(action = RET_STATUS);

 if(count<1) return (OM_W_ABORT);

 status = om$get_classid( osnum = go_link.osnum, objid = go_link.S_objid,
		  	  p_classid = &go_classid);
 as$status(action = RET_STATUS);

 if((om$is_ancestry_valid( subclassid = go_classid,
                           superclassid = OPP_ACpretgo_class_id)==OM_S_SUCCESS))
      {
        /*| The object is an ACpretgo */ 
        status = om$send(msg = message ACpretgo.ACgive_info(go),
		         targetid = go_link.S_objid,
			 targetos = go_link.osnum );
        as$status();
      }
   else
      {
 	go->objid = go_link.S_objid;
	go->osnum = go_link.osnum;
      }

/* context now */
 
   if(mat_type != NULL) *mat_type = MAIDMX;
   if(matrix != NULL)   MAidmx(&msg,matrix);

 /*"Graphic object returned: %d, %d\n", go->objid, go->osnum */
 return (OM_S_SUCCESS);
}

method NDdelete(struct GRmd_env *md_env)
{
 IGRlong msg, status;
 IGRboolean old_ASbroad;
 OM_S_OBJID save_md;
  
 /*| remove if necessary from R-tree and delete graphic object */

 old_ASbroad =  ASbroadcast_in_progress;
 ASbroadcast_in_progress = TRUE;
 save_md = md_env->md_id.objid;

 if(md_env->md_id.objid != NULL_OBJID)
  {
   om$send(msg = message GRgraphics.GRremwrng( &msg,md_env),
	   p_chanselect = &AS_listeners);
  }

 md_env->md_id.objid = NULL_OBJID;
 status = om$send( msg = message GRgraphics.GRdelete( &msg, md_env),
 		   p_chanselect = &AS_listeners);
 /* as$status(); The G. o. may be already deleted */

 ASbroadcast_in_progress = old_ASbroad;
 md_env->md_id.objid = NULL_OBJID;

 /*| delete my_self */
 status = om$send( msg = message NDnode.NDdelete(md_env),
		   mode = OM_e_wrt_message,
		   targetid = my_id);
 as$status();

 return(OM_S_SUCCESS);
}


method NDsleep(struct GRmd_env *md_env)
{
IGRint count,status;
char obj_state;

status = om$send(msg = message NDnode.NDget_state(&obj_state),
		 targetid = my_id);

if(status&1 && obj_state&ND_DEL_NO_CH)
  { status = om$send(msg = message NDnode.NDsleep(md_env),
		     targetid = my_id,
		     mode = OM_e_wrt_message); 
    as$status();
  }
else
  {
    status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,NULL,0,
					  NULL,1,0,&count),
		     targetid = my_id);
    as$status();
    if(count != 0) return(OM_S_SUCCESS);
  
    status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,NULL,0,
					  NULL,1,0,&count),
		     targetid = my_id);
    as$status();
    if(count != 0) return(OM_S_SUCCESS);

    /*" delete the source %d, doesn't touch go\n",my_id */

    status = om$send(msg = message Root.delete(1),
		     targetid = my_id);
    as$status();
  }

return(OM_S_SUCCESS);
}

method  NDcompute_node (IGRlong *msg;IGRint cn_type;
			int count; struct GRid list []; 
                         struct GRmd_env *md_env )
{
 *msg = MSSUCC;
 return (OM_S_SUCCESS);
}

/* Transfer symbology + with respect to message */

method NDupdate(int *msg, cn_type, count;
                struct GRid *parents;
                int *parent_state;
                struct GRid *context,*new_objid;
                struct GRmd_env *md_env)
{
 struct GRid my_grid,my_go;
 int i;
 GRclassid obj_class,obj_class1;
 extern GRclassid OPP_GRgrgrp_class_id,OPP_ASgroup_class_id;
 long status;

/* If context compute, transfer symbology */
 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 if(context && context->objid != NULL_OBJID)
 {

/* jla march 93 when a graphic is in a macro
  - 1.4 behaviour does not transfer symbology 
  - 2.2 behaviour the graphic group is transformed to ASgroup during
    message ACcopy_to_Groot. Transfer symbology of components
*/

 status=om$get_classid(objid = context->objid,osnum = context->osnum,
                       p_classid = &obj_class);
 status = om$send(msg = message NDnode.ASreturn_go(&my_go,NULL,NULL),
		   targetid = my_id);
 status=om$get_classid(objid = my_go.objid,osnum = my_go.osnum,
                       p_classid = &obj_class1);

 if(om$is_ancestry_valid(subclassid = obj_class1,
 			 superclassid = OPP_GRgrgrp_class_id) == OM_S_SUCCESS)
   {
    if(om$is_ancestry_valid(subclassid = obj_class,
 			 superclassid = OPP_ASgroup_class_id) == OM_S_SUCCESS)
     {
      struct GRid context_cmp,my_cmp;
      extern OM_S_CHANSELECT AS_to_comp;

      for (i=0;i<OM_K_MAXINT;i++)
      {
        status = om$get_objid_at_index(objid = context->objid,
                                     osnum = context->osnum,
                                     objidaddr = &context_cmp.objid,
                                     osnumaddr = &context_cmp.osnum,
                                     p_chanselect = &AS_to_comp,
                                     index = i);
        if(!(status&1)) break;

        status = om$get_objid_at_index(objid = my_go.objid,
                                     osnum = my_go.osnum,
                                     objidaddr = &my_cmp.objid,
                                     osnumaddr = &my_cmp.osnum,
                                     p_chanselect = &AS_to_comp,
                                     index = i);
        if(!(status&1)) break;
        ACtrans_symb(context_cmp,my_cmp);
       }
     }
   }
 else
   {
    ACtrans_symb(*context,my_grid);
   }
 }
 return om$send(msg = message NDnodein.NDupdate(msg,cn_type,count,parents,
					parent_state,context,new_objid,md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
}


/* 
  jla march 93 transform GRgrgrp into ASgroup when they become foot of a 
   macro. It allows future symbology tranfer and does not mess up foot
   indexing fo the macro 
*/

method ACcopy_to_Groot(IGRlong *msg;IGRint cp_type;
			 struct GRmd_env *md_env,*new_info;
  			 struct GRid *newobjid)
{
 GRclassid obj_class;
 extern OM_S_CHANSELECT AS_to_comp, AS_notification;
 long status,loc_msg;
 struct GRid go,newgo;
 extern GRclassid  OPP_GRgrgrp_class_id, OPP_ASgroup_class_id;
 short set,props;
 set = 1;
 props = GR_RIGID_RELATIONSHIP;

/* regular copy */
 status = om$send( msg = message NDnode.NDcopy_to_root(msg,cp_type,  
 		   md_env,new_info,newobjid),
                   targetid = my_id);
 as$status(action = RET_STATUS);

/* test class of graphic */
 status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
		  targetid = newobjid->objid,
		  targetos = newobjid->osnum);
 as$status(action = RET_STATUS);

 status = om$get_classid(objid = go.objid, osnum = go.osnum,
			p_classid = &obj_class);
 as$status(action = RET_STATUS);

 if(om$is_ancestry_valid(superclassid = OPP_GRgrgrp_class_id,
			 subclassid = obj_class) != OM_S_SUCCESS) return status;

/* transform it to ASgroup */

 status = om$construct(classid = OPP_ASgroup_class_id,
		       osnum = go.osnum,
		       p_objid = &newgo.objid);
 as$status(action = RET_STATUS);
 newgo.osnum = go.osnum;

 status = om$send(msg = message Root.move_chan(AS_to_comp,go.objid,
					go.osnum,AS_to_comp),
		  targetid = newgo.objid,
		  targetos = newgo.osnum);
 as$status(action = RET_STATUS);

 status = om$send(msg = message Root.move_chan(AS_notification,go.objid,
					go.osnum,AS_notification),
		  targetid = newgo.objid,
		  targetos = newgo.osnum);
 as$status(action = RET_STATUS);

 status = om$send(msg = message GRgraphics.GRchgprops(&loc_msg,&set,&props),
		  p_chanselect = &AS_to_comp,
		  senderid = newgo.objid,
		  targetos = newgo.osnum);
 as$status();
 status = om$send(msg = message Root.delete(1),
		  targetid = go.objid,
		  targetos = go.osnum);
 as$status();
 return ( OM_S_SUCCESS  );
}

end implementation ASsource;
