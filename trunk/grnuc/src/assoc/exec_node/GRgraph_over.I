class implementation ASnode;
/*
   Ch    dec 87 :  update for the 1.1 release

   This is the implementation file of the class ASnode and gather only the
   overrided method of GRgraphics.
*/

#include "AS_status.h"
#include "godef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grerr.h"
#include "OMmacros.h"
#include "grownmacros.h"
#include "asdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "OMprimitives.h"
#include "exdef.h"
#include "exmacros.h"
#include "msmacros.h"
extern IGRboolean ASbroadcast_in_progress;


#define AS_DEBUG 1

/* 
 *  function call to change node when necessary
 *  (and get_module_env if necessary)
 */

AScompute_and_change_node(obj_id,env)
OM_S_OBJID obj_id;
struct GRmd_env *env;
{
 IGRlong NumberOfBytes, BytesReceived,rt;
 struct GRmd_env local_env;
 IGRlong status,msg;
 IGRint cn_type;


 if(env == NULL)
  {
   NumberOfBytes = sizeof( struct GRmd_env );
   gr$get_module_env( msg = &rt, sizbuf = &NumberOfBytes,
                      buffer = &local_env, nret = &BytesReceived );
   env = &local_env;
  }

 cn_type = 0;
 status = om$send(msg = message NDnode.NDs_compute_node(&msg,cn_type,env),
		  senderid = obj_id,
	          targetid = obj_id);

 status = om$send(msg = message NDnode.NDchange_node(NULL),
		  senderid = obj_id,
		  targetid = obj_id);
 return(status);
}

ASchange_node(obj_id,env)
OM_S_OBJID obj_id;
struct GRmd_env *env;
{
 IGRlong NumberOfBytes, BytesReceived,rt;
 IGRlong status;
 struct GRmd_env local_env;

 if(env == NULL)
  {
   NumberOfBytes = sizeof( struct GRmd_env );
   gr$get_module_env( msg = &rt, sizbuf = &NumberOfBytes,
                      buffer = &local_env, nret = &BytesReceived );
   env = &local_env;
  }

 status = om$send(msg = message NDnode.NDchange_node(NULL),
		  senderid = obj_id,
		  targetid = obj_id);
 return(status);
}

/* GRcopy produces in 2.0 a copy to root of the element */

method GRcopy( IGRlong *msg; struct GRmd_env *obj_dsenv;
     	       struct GRmd_env *new_dsenv; GRobjid *newobjid)
{
 IGRint status;

  status = om$send( msg = message GRgraphics.GRcopy
					(msg,obj_dsenv,new_dsenv,newobjid),
		    p_chanselect = &AS_to_comp);
  as$status();

  return status;
}

method GRdelete( IGRlong *msg; struct GRmd_env *md_env)
{
 IGRlong status;
 struct GRid  my_grid;
 short action;
 IGRint mod_batch;
 short mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

 /*"mod %d, %d matrix %d\n",md_env->md_id.objid,md_env->md_id.osnum,md_env->md_env.matrix_type */

 my_grid.objid = my_id;
 my_grid.osnum = OM_Gw_current_OS;

 /* put the deleted element in the batch queue   */

if(!ASbroadcast_in_progress)
 {
    nd$wait_batch(type = GR_DELETED,
		  nb_obj = 1,
		  l_object = &my_grid);

 /*
    If batch mode is deffer, change go properties to non locatable and non
    displayable 
 */

    nd$mod_batch(request = ND_INQ,
		 p_ret_mode = &mod_batch);


    if(mod_batch == ND_DEFER)
      {
       /*| Change the properties if necessary  */
       action=0;
       status = om$send(msg      = message GRvg.GRchgprops(msg,&action,&mask),
                        p_chanselect = &AS_to_comp);
       as$status();
      }
  }
 else
  {
   status = om$send( msg = message NDnode.NDdelete(md_env),
                   targetid = my_id);
   as$status();
  }

 *msg = MSSUCC;
 return(OM_S_SUCCESS);
}


method GRxform( IGRlong *msg; struct GRmd_env *md_env;
	        IGRshort *matrix_type; IGRmatrix matrix; GRobjid *newobjid)
{
 long status;
 struct GRid my_grid;
 extern IGRboolean ASbroadcast_in_progress;
 IGRint cn_type;
 char obj_state;

 *msg = MSSUCC;
 *newobjid = my_id;

/*
  to well beheave with fence move or copy
  and to have a good range for cell definition
  To be suppress as soon as the cell creation directly send the transformation
  matrix in the GRcopy
*/

/*
   To redirect the xform message to the graphic object and recompute 
   after must be address very carefully 
   The test on ACsym subclass has been 
   - remove I don't remember why
   - added again (11-jan-89 JLA) because it creates if not a double
     displacement of element connected to a coor sys when these elements
     are displayable and when the coor sys is in a symbol macro.
   - but continue to send if the element is degraded
*/ 
     status = om$send(msg = message NDnode.NDget_state(&obj_state),
     		      targetid = my_id);
     if(status&1 && obj_state&ND_DEGRADED)
      {
       ASredirect_msg(OPPmargs,&me->to_components,my_id);
      }
       *newobjid = my_id;  /* because ASredirecs_msg(OPPmargs has change the */
			   /*  value of newobjid */

 if(!ASbroadcast_in_progress)
   {
    my_grid.objid = my_id;
    my_grid.osnum = OM_Gw_current_OS;
    cn_type = ND_COMP;
    nd$wait_batch(type = GR_GEOM_POSTED,
	       l_object = &my_grid,
               l_obj_info = &cn_type,
	       nb_obj   = 1);
   }
 return(OM_S_SUCCESS);
}

#define MAX_PRTS 20

method GRconstruct(struct GRvg_construct *arglist)
{
  struct GRas 		*class_attr;
  IGRlong 		status;
  IGRint 		i;
  struct GRid 		source, _loc_parent[MAX_PRTS],
              		*context, *sav_parent, *loc_parent;
  struct GRvg_construct go_cnst_lis;
  IGRchar 		*ptr;


  *(arglist->msg) = OM_S_SUCCESS;
  class_attr = (struct GRas *) arglist->class_attr;

  ptr = NULL;
  ASsuper_construct();

  /*"create associative object in source for %d parent",class_attr->num_parents*/
 
  sav_parent = class_attr->parents;

  /* modif momo 23/02/89 */

  if(class_attr->num_parents > MAX_PRTS)
  {
    /*| before Allocation */
    ptr = om$malloc(size = class_attr->num_parents * sizeof(struct GRid));
    if(ptr == NULL)
    {
      printf("GRgraph_over : ERROR in malloc function\n");
      return(OM_W_ABORT);
    }

    loc_parent = (struct GRid *) ptr;
  }
  else
  {
    loc_parent = _loc_parent;
    ptr = NULL;
  }

  context = class_attr->context;

  for(i=0 ; i<class_attr->num_parents ; i++)
  {
    if(class_attr->context != NULL)
    {
      status = as$make_source(go_grid = sav_parent[i],
 			      context_grid = context[i],
	                      as_grid = &source );
      /*" %deme parent  %d %d\n",i,sav_parent[i].objid,sav_parent[i].osnum */
      /*" %deme context %d %d\n",i,context[i].objid,context[i].osnum */
      /*" %deme source  %d %d\n",i,source.objid,source.osnum */
    }
    else
    {
      status = as$make_source(go_grid = sav_parent[i], 
	                      as_grid = &source );
      /*" %dem parent %d %d\n",i,sav_parent[i].objid,sav_parent[i].osnum */
      /*" %dem source %d %d\n",i,source.objid,source.osnum */
    }
    as$status(action = GOTO_VALUE,
              value  = wrapup);

    loc_parent[i] = source;
  }

  /*| We evaluate the associative object */

    class_attr->parents = loc_parent;

    class_attr->go_objid.objid = NULL_OBJID;
    go_cnst_lis = *arglist;
    go_cnst_lis.class_attr = class_attr->go_attr;

    status = om$send(msg      = message ASnode.NDplace
                                (class_attr,arglist->env_info,
                                 (IGRchar *)&go_cnst_lis),
	             targetid = my_id );

    as$status(action = GOTO_VALUE,
              value  = wrapup);

/*  remove jla 01-june-89
/*  gr$add_to_active_owner( msg = &msg, mod_env = arglist->env_info, 
/*	                  objid = my_id );
/*******/

  wrapup : if(ptr != NULL) 
           {
             /*| Before dealloc */
	     om$dealloc(ptr = ptr);
	   }
            
  class_attr->parents = sav_parent;

  return (status);

} /* GRconstruct */


method GRdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix
                        matrix;  enum GRdpmode *mode;
			struct IGRaltdisplay *alt_symb;
			struct DP_information *sp_info;
                        OM_p_KEY_DESC range_key)
{
IGRint status;
struct GRid my_grid,modifier;
extern IGRboolean dynamics_in_progress;
extern IGRboolean ASbroadcast_in_progress,save_br;
char obj_state;

/* display the element */
my_grid.objid = my_id;
my_grid.osnum = OM_Gw_current_OS;

status = om$send(msg = message NDnode.NDget_state(&obj_state),
		 targetid = my_id);

if(!(status&1) || !(obj_state & ND_DIS_BY_CH))
  {
   status = om$send(msg = message GRowner.GRdisyourself( msg, mx_type,
				   matrix, mode,alt_symb, sp_info, range_key),
			  mode = OM_e_wrt_message,
			  targetid = my_id);
  }
else
  {
   ASfind_modifier(my_grid,NULL_GRID,&modifier);
   status = om$send(msg = message GRowner.GRdisyourself( msg, mx_type,
				   matrix, mode,alt_symb, sp_info, range_key),
			  mode = OM_e_wrt_message,
			  targetid = modifier.objid,
			  targetos = modifier.osnum);
  }

*msg = MSSUCC;
return(OM_S_SUCCESS);
}

method GRlocaldp(IGRlong *msg; IGRshort *type; IGRmatrix matrix;
			struct GRparms *parms; enum GRdpmode *mode;
			struct GRid *display_info; IGRshort 
			*display_location; IGRshort *display_flag)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
return(status);
}


method GRgetobjinfo(IGRlong *msg; struct GRobj_info *info)
{
IGRint status;

status = ASredirect_msg(OPPmargs,&me->to_components,my_id);
as$status();
return(status);
}

#define OUTSIDE 0
#define INSIDE  1
#define OVERLAP 2
method GRclip(IGRlong *msg; struct GRmd_env *env,*target_env;
		IGRchar *prism;struct GRid *in_id;
		struct GRid *out_id; struct GRid *ovl_id;
		IGRlong *clip_flags)
{
IGRlong in_out;
IGRshort type_prism;
IGRlong status;
 *msg= MSSUCC;
 status =OM_S_SUCCESS;

 if(*clip_flags & GR_CLIP_NORGCK)
 {
 	*msg=MSINARG;
	status=OM_E_ABORT;
 }
 else
 {
  if(*clip_flags &GR_CLIP_RTPRISM) type_prism=0;
  else				   type_prism=1;

  status = om$send(
	msg =message GRvg.GRprismrel
		(msg,&env->md_env.matrix_type,
		 env->md_env.matrix,NULL,
		&type_prism,prism,&in_out),
	targetid = my_id);
    
   if(!(status &1 & *msg))
   {
    *msg=MSFAIL;
   }
   else
   {
    switch(in_out)
    {
     case OUTSIDE:
	*msg = GR_I_OBJOUTSIDE;
	break;
     case INSIDE:
	*msg = GR_I_OBJINSIDE;
	break;
     case OVERLAP:
	break;
     default:
       *msg = MSINARG;
    }
   }
  }
 return(status);
}


end implementation ASnode;
