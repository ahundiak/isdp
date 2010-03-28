class implementation AScontents;

#include "OMmacros.h"
#include "grerr.h"
#include "grownerdef.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "asbox.h"
#include "AS_status.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "batch.h"
#include "msmacros.h"
#include "ASmsg.h"

#define AS_DEBUG 1

extern IGRboolean ASbroadcast_in_progress;

// extern struct GRmd_env NDor_env,NDto_env;

extern GRclassid OPP_ASsource_class_id,
		 OPP_AScontents_class_id;

from ASsource import GRconstruct;
double sqrt();


method NDcopy(IGRlong *msg; IGRint cn_type;
	      struct GRmd_env *obj_env, *new_env; struct GRid *newobj)
{
 long status;

 /* initialization */
 *msg	= MSSUCC;

 /*" Copy the AScontents object: %d\n", my_id */
 status = om$construct_and_copy( object = me, 
				 obj_osnum = obj_env->md_id.osnum, 
	    			 osnum = new_env->md_id.osnum,
            			 p_objid = &newobj->objid);
 as$status();
 newobj->osnum = new_env->md_id.osnum;

 /*" Copied object: %d, %d\n", newobj->objid, newobj->osnum */
 return(status);
}


method NDdelete(struct GRmd_env *md_env)
{
 long status;
  status=om$send( msg = message Root.delete(1),
		  targetid = my_id );
  as$status();
  return(status);
}
     
method NDplace(struct GRas *asso_lis;struct GRmd_env *md_env; 
		IGRchar *go_cnst_lis)
 {
  IGRlong msg,status;
  struct GRid *list;
  IGRint count,i;
  struct ret_struct refdef;
  
  list  = asso_lis->parents;
  count = asso_lis->num_parents;

  /*"count: %d, root: %d, %d\n", count, list[0].objid, list[0].osnum */

  /*| store the actual matrix of coordinate system */
  status = om$send( msg = message NDnode.NDgive_structure(&msg,&refdef,md_env),
                    targetid = list[0].objid, targetos = list[0].osnum);
  as$status(action = RET_STATUS);
  if(!refdef.type &  ref_generic) return(OM_W_ABORT);

  for(i=0;i<16;i++) me->mat[i] = refdef.var.ref_st.t[i];

  /*| connect */
  status=om$send(msg = message NDnode.NDconnect(count,list,NULL_GRID,ND_NEW),
            	 targetid =  my_id);
 /*^ pr_mat("my matrix",4,4,me->mat);*/
  as$status(action = RET_STATUS);
  return(OM_S_SUCCESS);
 }
  
method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count; struct GRid list[]; struct GRmd_env *md_env)
 {
  IGRlong status;
  IGRshort   matrix_type;
  GRobjid    newobjid;
  IGRint     i;
  IGRshort   four = 4;
  IGRmatrix tmp_matrix, trans_matrix;
  struct ret_struct refdef;
  IGRboolean save_broad;
  struct GRid my_grid;

  /* initialization */

  save_broad = ASbroadcast_in_progress;
  ASbroadcast_in_progress = TRUE;
  status = OM_S_SUCCESS;

  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;


  /*| get the new matrix of coordinate system */

  status = om$send( msg = message NDnode.NDgive_structure(msg,&refdef,md_env),
		    targetid = list[0].objid );
  as$status(action = RET_STATUS);
  

  /*| Update element */
  /*"md_env: %d %d\n",md_env->md_id.objid,md_env->md_id.osnum */
  /*" matrix type: %d\n",  md_env->md_env.matrix_type */

if ( (cn_type&ND_COMP_TYPE) == ND_COMP_XF)
   {
/*| objects have already been xformed when the cs received the xform message */

   }

else
   {
    /*| objects are xformed from coordinate system and contents matrix */
    /*| compute transformation matrix */
    MAinvmx(msg,&four, me->mat, tmp_matrix);

    MAmulmx(msg,&four,&four,&four,refdef.var.ref_st.t,tmp_matrix,trans_matrix);
    MAtypemx(msg, trans_matrix, &matrix_type);

    MAmulmx(msg,&four,&four,&four,refdef.var.ref_st.t,tmp_matrix,trans_matrix);
    /*^ pr_mat("transformation mat",4,4,trans_matrix); */
    status = om$send( msg = message GRgraphics.GRxform(msg, md_env,
  	            &matrix_type, trans_matrix, &newobjid),
                    p_chanselect = &AS_to_comp);
    as$status( action = GOTO_VALUE, value = wrapup);
   }

  /*| update matrix */
  for (i=0 ; i<16 ; i++) me->mat[i] = refdef.var.ref_st.t[i];

 /*^ pr_mat("my matrix",4,4,me->mat);*/
 
  wrapup :
  ASbroadcast_in_progress= save_broad;
  return (status);
 }

method NDprint_root(struct GRmd_env *md_env ; FILE *stream)
 {
  /*| The Contents object is not printable, relay the message to the coord */
  om$send( msg = message NDnode.NDprint_root( md_env, stream ),
           p_chanselect = &ND_father );
  return(OM_S_SUCCESS);
 }

method NDprint( struct GRmd_env *md_env; FILE *stream )
{
 return(OM_S_SUCCESS);
}


method NDmove_to_root(IGRlong *msg; struct GRid *src_grid; 
		      /*IGRint src_del;*/ struct GRmd_env *md_env )
{
 IGRlong status;

 /*| Kill the AScontents object */
 status = om$send(msg = message Root.delete(1), targetid = my_id);
 as$status();

return(status);
}


method NDgive_structure(IGRlong *msg; struct ret_struct *str;
		 	struct GRmd_env *md_env )
{
 /*| relay the message to the coordinate system */
 om$send( msg = message NDnode.NDgive_structure(msg, str, md_env ),
	  p_chanselect = &ND_father );
 return(OM_S_SUCCESS);
}


method GRxform(IGRlong *msg; struct GRmd_env *md_env;
               IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
 IGRint status = OM_S_SUCCESS;
 struct GRid my_grid;
 IGRint cn_type;


  my_grid.objid = my_id;
  my_grid.osnum = OM_Gw_current_OS;
 

  /* do the wait batch */

  if(!ASbroadcast_in_progress)
   {

    status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
    cn_type = ND_COMP_XF;

    nd$wait_batch(type = GR_GEOM_POSTED,
		  l_object  = &my_grid,  l_obj_info = &cn_type,
		  nb_obj    = 1);
   }

 *newobjid = my_id;
 return(status);
}

 

method GRget_locate_properties(IGRlong *msg; IGRint *properties )
{
 *msg = MSSUCC;
 *properties = GR_LC_CMP_READ     | GR_LC_CMP_WRITE     | 
	       GR_LC_CMP_PRM_READ | GR_LC_CMP_PRM_WRITE |
/*	       GR_LC_OWN_PRM_READ | GR_LC_OWN_PRM_WRITE | */
   	       GR_LC_FLEXIBLE;
 return(OM_S_SUCCESS);
}


method ACcompute_node( IGRlong *msg; IGRint cn_type;
			   IGRint count; struct GRid list []; 
                           struct GRmd_env *md_env;
			   int *prop,*size_inst,*no_go;
			   char *inst_save)
{
int siz_inst,csize,status,status1;

/*
   save instances corresponding to previous occurence, load instance
   corresponding to new one 
*/

 siz_inst=sizeof(me->mat);
 OM_BLOCK_MOVE(  inst_save,me->mat, 
		siz_inst);
     
 status = om$send(msg =  message NDnode.NDcompute_node (msg,cn_type ,
					count,list, 
					md_env),
  		   targetid =my_id ); 
     as$status( );

 if (!( (me->state) & ND_OUT_OF_RT)&& *no_go != -1 )
   {
   status1 = om$get_channel_count(object = me,
			       p_chanselect = &AS_to_comp,
			       count = (OMuint *)&csize);
   as$status(sts = status1);
   *no_go += csize;
   }

 OM_BLOCK_MOVE( me->mat, inst_save,
		siz_inst);
 *size_inst += siz_inst ;

  return (1) ;
}

/*********************************************************************
 *								     *
 *  If the intermediate object "contents" does not exist, create and *
 *  connecte it to the coordinate system (ref).		 	     *
 *********************************************************************/

asmake_contents(ref, contents)
struct GRid ref;        /* coordinnate system object  		*/
struct GRid *contents;  /* contents linked to the coord. system */
/*.asmake_contents*/
{
 IGRlong status,msg;
 struct GRid *list;
 IGRint count,i;
 GRclassid obj_class;
 struct GRid context;
 struct GRas asso_lis;
 struct GRmd_env md_env;

 as$make_source(go_grid=ref, as_grid=&ref, as_os = ref.osnum);
 /*" coord. systeme: %d, %d\n", ref.objid, ref.osnum */

 /*| get the children of the ref. If one is a contents use it */
 status = om$send( msg = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF,
                   NULL,0,&list,0,OM_K_MAXINT,&count), senderid = NULL_OBJID,
		   targetid = ref.objid, targetos = ref.osnum);
 as$status(action = RET_STATUS);

 for(i=0 ; i<count ; i++)
  {
   om$get_classid( objid = list[i].objid, osnum = list[i].osnum,
		   p_classid = &obj_class);
   if(om$is_ancestry_valid( subclassid = obj_class,
			    superclassid = OPP_AScontents_class_id) == OM_S_SUCCESS)
    {
     *contents = list[i];
     /*" contents already exist %d %d\n",contents->objid,contents->osnum */
     return (OM_S_SUCCESS);
    }
  }

 /*| Need to create it */
 context.objid = NULL_OBJID;
 asso_lis.num_parents = 1;
 asso_lis.parents     = &ref;
 asso_lis.context     = &context;
 asso_lis.as_attr     = NULL;

{
 IGRlong NumberOfBytes;
 IGRlong BytesReceived;

 NumberOfBytes = sizeof( md_env);
 gr$get_module_env(
                msg = &msg,
                sizbuf = &NumberOfBytes,
                buffer = &md_env,
                nret = &BytesReceived);
}


 contents->osnum = ref.osnum;
 status = om$construct( osnum = ref.osnum, classid = OPP_AScontents_class_id,
			msg = message NDnode.NDplace(&asso_lis,&md_env,NULL),
			p_objid = &contents->objid);
 as$status();
 /*" contents %d %d created\n",contents->objid,contents->osnum */
 status = om$send(msg = message NDnode.NDchg_state
                                              (ND_SUP_ONLY,ND_SUP_ONLY),
		  senderid = NULL_OBJID,
		  targetid = contents->objid,
		  targetos = contents->osnum);
 as$status();
 return (status);
}
/*
   contents only receive GRdelete on fence delete. Needs to send the
   message to itself and to the connected sources
*/

method GRdelete(IGRlong *msg;struct GRmd_env *md_env)
{
IGRint status;
IGRint count;
struct GRid *list;
 
 status = om$send (msg=message ASnode.GRdelete(msg,md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
 status = om$send(msg =message NDnode.NDget_objects
	(ND_CHILDREN|ND_IN_BUF,NULL,0,&list,0,OM_K_MAXINT,&count),
		targetid=my_id);
 if(status != OM_S_SUCCESS) count=0;
 nd$wait_batch(type = GR_DELETED,
	       nb_obj =count,
	       l_object =list);
return(status);
}

method NDmake_source(IGRlong *msg;struct GRid *located_obj,*context;char *path;
                     GRspacenum as_osnum; struct GRid *as)
{
 IGRlong status;
 int                    nb_child, i;
 struct GRid            *list_child;
 struct GRid            my_grid,go;
 IGRlong 		cnst_lis_msg;
 struct GRvg_construct  cnst_lis;
 struct GRas            asso_lis;


/*
   To connect dependency
   - use a sourcein object connected by tag if there is a context
   - use a source object if there is no context
*/

 if(context->objid != NULL_OBJID)
  {
   status = om$send(msg = message ASnode.NDmake_source
                                 (msg,located_obj,context,path,as_osnum,as),
                    mode = OM_e_wrt_message,
                    targetid = my_id);
   as$status();
  }
 else if(   located_obj->objid == my_id 
	 && located_obj->osnum == OM_Gw_current_OS)
  {
   as->objid = my_id;
   as->osnum = OM_Gw_current_OS;
   status = OM_S_SUCCESS;
   *msg = MSSUCC;
  }
 else
  {
   status = om$send(msg = message NDnode.NDget_objects(
                                ND_CHILDREN | ND_IN_BUF,
                                NULL, 0, &list_child,
                                0, OM_K_MAXINT, &nb_child ),
                    targetid = my_id );
   as$status( );
   if(!(status&1)) nb_child = 0;

   as->objid = NULL_OBJID;
   for( i=0 ; i < nb_child ; i++ )
   {
    status = om$send(   msg = message NDnode.ASreturn_go(&go,NULL,NULL),
                        targetid = list_child[i].objid,
                        targetos = list_child[i].osnum );
    if(!(status&1)) continue;
    if(IF_EQ_OBJID(go.objid ,  located_obj->objid) &&
                   go.osnum == located_obj->osnum)
      {
        /*| have found an already existing source */

        as->objid = list_child[i].objid;
        as->osnum = list_child[i].osnum;
        break;
      }
   }

   if(IF_NULL_OBJID(as->objid))
     {
      /*| Need to construct a source object */
 
      cnst_lis.msg         = &cnst_lis_msg;
      cnst_lis.class_attr  = (char *) &asso_lis;

      asso_lis.my_context  = *context;
      asso_lis.as_attr     = NULL;
      asso_lis.go_objid    = *located_obj;
      asso_lis.num_parents = 1;
      asso_lis.parents     = &my_grid;

      my_grid.objid = my_id;
      my_grid.osnum = OM_Gw_current_OS;

      /* as->osnum should be initialized ,TR#11913234*/
      as->osnum = OM_Gw_current_OS;
      status = om$construct( osnum = as_osnum,
                         msg = message ASsource.GRconstruct(&cnst_lis),
                         classid = OPP_ASsource_class_id, p_objid = &as->objid);

     }
  }
 /*" source %d %d\n",as->objid,as->osnum */
 return(status);
}

/* When a contents is located for copy, it returns the elements it contains */

method NDselect_copy(long *msg; int select_type;
                       struct GRid *selected_obj; int *info;
                        int selected_size, *selected_nb)
{
 long status;

 *msg = MSSUCC;
 status = om$send(msg = message NDnode.NDget_objects(ND_CHILDREN,
					selected_obj,selected_size,NULL,
					0,OM_K_MAXINT,selected_nb),
		  targetid = my_id);
 return status;
}

method  NDattach_to_cs(IGRlong *msg; struct GRid cs_grid,contents;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
 long status;
 status  = om$send(msg = message NDnode.NDattach_to_cs
			(msg,cs_grid,contents,as_grid,md_env),
		   p_chanselect = &ND_children); 
 *as_grid = contents;
 return status;
}

method  NDdetach_from_cs(IGRlong *msg; struct GRid cs_grid,contents;
                       struct GRid *as_grid; struct GRmd_env *md_env)
{
 long status;
 struct GRid my_grid;
  /* disconnect the source object from the AScontents */

     status = om$send( msg = message NDnode.NDdisconnect( 0, NULL ),
		       p_chanselect = &ND_children);
     as$status();

  /* disconnect the graphic object from contents */

     my_grid.objid = my_id;
     my_grid.osnum = OM_Gw_current_OS;
     status = om$send( msg = message GRconnector.GRdisconn( msg, &my_grid ),
                       p_chanselect = &AS_listeners);
     as$status();
return status;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                         metod GRgetobjinfo                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
     *msg = OM_S_SUCCESS ;
     ex$message (buff=info->type,msgnumb=AS_I_AScontents);
     return(OM_S_SUCCESS);
}
		    
end  implementation AScontents;
