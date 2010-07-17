/* $Id: VRcons_node.I,v 1.2 2001/02/20 01:13:01 build Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrconstrain / VRcons_node.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VRcons_node.I,v $
 *	Revision 1.2  2001/02/20 01:13:01  build
 *	Replaced v_dbgmacros.h with product specific dbgmacros.h
 *	
 *	Revision 1.1.1.1  2001/01/04 21:12:47  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.1  1997/07/17  18:30:54  pinnacle
# route 2.5
#
# Revision 1.1  1996/07/25  18:25:44  pinnacle
# Creation of Route 241 project
#
# Revision 1.4  1996/04/16  18:56:24  pinnacle
# Replaced: vrconstrain/VRcons_node.I for:  by ashankar for route240
#
# Revision 1.3  1996/04/05  17:55:14  pinnacle
# Replaced: vrconstrain/VRcons_node.I for:  by msmanem for route240
#
# Revision 1.2  1996/01/16  22:12:04  pinnacle
# Replaced: vrconstrain/VRcons_node.I for:  by r240_int for route240
#
 *
 * History:
 *	01/16/96	tlb	Add prototypes
 *
 *************************************************************************/
class implementation VRcons;

/*
#define vdsDEBUG
#define vdserrDEBUG
*/

#include "OMerrordef.h"
#include "OMmacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "AS_status.h"
#define AS_DEBUG

#include "v_miscmacros.h"
#include "vrdbgmacros.h"
#include "v_datamacros.h"

#include "godef.h"
#include "vrconstr_pto.h"

from VRconc import VRget_nb_constrain,VRget_constrain;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
method NDcompute_node(IGRlong *msg; IGRint cn_type;
		      int count; struct GRid parent[]; struct GRmd_env *md_env)
{
 int status;
 int iconc,nb_cons,ic,ip;
 int cons_type;
 struct GRid cons_obj[6];
 int cons_obj_index[6];
 int size_cons_obj = 6,nb_cons_obj;
 int node_type,obj_state;
 extern IGRboolean dynamics_in_progress;

 double cons_val[1];
 int size_cons_val = 1,nb_cons_val;

 int  verify,all_verify;
 double delta;


/* Does nothing in dynamics */

if(dynamics_in_progress) return OM_S_SUCCESS;


/* Count iteration */

 me->iteration_number += 1;

/* Optimist initialization */

 all_verify = TRUE;
 me->nb_unknown = 0;
 me->nb_equation =0;

/* Reset to query plane definition */
 for(ip=0 ; ip<me->nb_plane ; ip++)
	 me->plane_state[ip] &= VR_CONS_STATE;

/* Get the constraints I'm suppose to solve */

 for(iconc=0;iconc<me->nb_conc;iconc++)
   {
    status = om$send(msg = message VRconc.VRget_nb_constrain(&nb_cons),
		     targetid = me->conc[iconc].objid,
		     targetos = me->conc[iconc].osnum);
    as$status(action = RET_STATUS);
    /*" %d --> %d constrain\n",me->conc[iconc].objid,nb_cons*/

   
  for(ic=0;ic<nb_cons;ic++)
     {
/* get and store planes concerned */
      status = om$send(msg = message VRconc.VRget_constrain (msg,ic,&cons_type,
					cons_obj,&nb_cons_obj,size_cons_obj,
					cons_val,&nb_cons_val,size_cons_val),
		       targetid = me->conc[iconc].objid,
		       targetos = me->conc[iconc].osnum);
      as$status();
      /*"nb_cons_obj %d\n",nb_cons_obj*/
      if(!(status&1)) continue;
      for(ip=0;ip<nb_cons_obj;ip++)
       {
        if(me->solver_state == VR_SOLVER_PROPAGATE)
           obj_state = VR_CONS_EXT;
        else
          {
           status = nd$get_type(nb_obj = 1,
			    p_object = cons_obj + ip,
			    p_type = &node_type);

           if(node_type & ND_EXTERN) 
	       obj_state = VR_CONS_EXT;
           else
	       obj_state = VR_CONS_INIT;
          }

        status = om$send(msg = message VRcons.VRstore_plane
                            (cons_obj+ip, cons_obj_index+ip, obj_state, md_env),
                         targetid = my_id);
        as$status(action = RET_STATUS);
       }

	
/* Check if the constraint is verified           */
/* and transform it into a numeric equation      */
	
      status = om$send(msg = message VRcons.VRverify_af_constrain
					       (cons_type,
						cons_val,nb_cons_val,
						cons_obj_index,nb_cons_obj,
						&verify,md_env),
			 targetid = my_id);
       all_verify = verify && all_verify; 
       as$status();
     }
    }

/*^ printf("definition of the planes\n");

  for(ip = 0; ip<me->nb_plane; ip++)
   { printf("%d state %x vectorial %d unknown %d  equation %lf %lf %lf %lf\n",
	    me->plane[ip].objid,me->plane_state[ip],
    	    me->plane_vectoriel[ip],
            me->unknown_index[ip],
	    me->plane_eq[4*ip]  , me->plane_eq[4*ip+1],
	    me->plane_eq[4*ip+2], me->plane_eq[4*ip+3]);
   }
*/
	

/*
Depending upon the solver state, store this plane as
-  INITIAL_PLANE
-  FREED_PLANE
-  EXTERNAL_PLANE
*/

 if(!all_verify)
  {
   /*| Some of the constrains are not verified */
   status = om$send(msg = message VRcons.VRsolve_af_constrain(&all_verify),
		    targetid = my_id);
   /*" sover returns %x\n",all_verify */
   if(all_verify == VR_SIMPLEX_ERROR)
    {
     printf("FAILURE IN SOLVER\n");
     return OM_S_SUCCESS;
    }
   else if(all_verify == VR_ALL_OK)
    {
    /*| nothing to do, all the constrains are verified */
     return OM_S_SUCCESS;
 
    }
   else if(all_verify & VR_MOVE_EXTERN)
    {
     /*| Free external planes and restart broadcast */
     for(ip=0;ip<me->nb_plane;ip++)
      {
	if(!(me->plane_state[ip]&(VR_CONS_FIXED)) &&
	   !(me->plane_state[ip]&(VR_CONS_FREE)) &&
	    (me->plane_state[ip]&(VR_CONS_EXT|VR_CONS_ERROR))
	          ==             (VR_CONS_EXT|VR_CONS_ERROR))
         {
	  me->plane_state[ip] &= ~VR_CONS_EXT;
	  me->plane_state[ip] |=  VR_CONS_FREE;
          /*"Free plane %d\n",me->plane[ip].objid*/
	  nd$wait_batch(type = GR_GEOM_POSTED,
			nb_obj = 1,
			l_object = me->plane+ip );
          *msg = ND_COMP_REST;
         }
      }
    }

   if(*msg != ND_COMP_REST)
    {
     /*| Post the obtained solution */
     for(ip=0;ip<me->nb_plane;ip++)
       {
	if(  (me->plane_state[ip]&VR_CONS_ERROR) 
	   &&(  me->plane_state[ip]&VR_CONS_FREE
              ||me->plane_state[ip]&VR_CONS_INIT))
         { delta = - me->matrix[me->unknown_index[ip]]
          	   + me->matrix[me->unknown_index[ip]+1];

          me->plane_eq[4*ip+3] += delta;

	  /*"move %lf on %d\n",delta,me->plane[ip].objid */
	  status = ASplane_set_equation (me->plane_eq+4*ip,me->plane+ip,md_env);
	  as$status();
         }
       }
    }
  }

 return(OM_S_SUCCESS);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

%safe

static int loc_size = 0;
static struct GRid *my_buffer = NULL;

%endsafe 

method NDget_virtual_objects(int type;struct GRid *list;int size;
                         struct GRid **buffer; int ifrom,ito,*count,*virt_count)
{
int status;
int loc_count;
int iconc;
int i,ii,j;
struct GRid *obj;

/* Get dependent objects. There should be no dependent */

 status = MSSUCC;

 if(type&ND_CHILDREN)
  {
   *virt_count = *count = 0;
   return OM_S_SUCCESS;
  }

 
/* The objects I depend upon are the roots of the constrained objects */ 

  *count = 0;
  *virt_count = 0;
  for(iconc=0;iconc<me->nb_conc;iconc++)
    {
     status =  om$send(msg = message NDnode.NDget_objects(ND_ROOT | ND_IN_BUF,
				       NULL,0,&obj,0,OM_K_MAXINT,&loc_count),
                        targetid = me->conc[iconc].objid,
			targetos = me->conc[iconc].osnum);
     as$status(action = RET_STATUS);

     if(*virt_count + loc_count > loc_size) 
       {
        int new_size;
	new_size = 1.5*(*virt_count + loc_count);
        if(loc_size == 0)
         {
	  /*" Alloc local array with size %d\n",new_size */
          /* my_buffer = (struct GRid *) om$malloc
	   *				(size = new_size * sizeof(struct GRid));
	   */
	   my_buffer = _MALLOC ( new_size, struct GRid );
	   if(my_buffer == NULL){ loc_size = 0; return (OM_W_ABORT);}
	 }
        else
	 {
	  /*" Realloc local array with size %d\n",new_size */
          /* my_buffer = (struct GRid *) om$realloc
	   *				(size = new_size * sizeof(struct GRid),
	   *				  ptr = (char * )my_buffer);
	   */
	   my_buffer = _REALLOC ( my_buffer, new_size, struct GRid );

	   if(my_buffer == NULL){ loc_size = 0; return (OM_W_ABORT);}
         }
        loc_size = new_size;
       }

     for(ii=0;ii<loc_count;ii++,obj++)
      { 
	for(j=0 ; j<*virt_count ; j++)
	 {
	  if(  (my_buffer[j].objid == obj->objid)
	     &&(my_buffer[j].osnum == obj->osnum)) break;
         }
        if(j < *virt_count) continue;

	/* To avoid creation of loops when an object which defines constrains
	   depends upon another object which defines constrain
	   Do I need a nd$dep_exist ? Not for now ....
        */
	for(j=0 ; j<me->nb_conc ; j++)
	 {
	  if(  (obj->objid == me->conc[j].objid)
	     &&(obj->osnum == me->conc[j].osnum)) break;
	 }
        if(j < me->nb_conc) continue;

        /*" store %d %d at index %d of size %d\n",obj->objid,obj->osnum,*virt_count,loc_size*/
        my_buffer[(*virt_count)++] = *obj;
      }
    }

/*| Return this information in the required form */

if(type&ND_IN_BUF)
 {
  *buffer = my_buffer + ifrom; 
 }
 
else
 {
  for(i=0,ii=ifrom ; i<size && ii<*virt_count ; i++,ii++)
    {
     list[i] = my_buffer[ii];
    }
 }
 return(status);
}

method NDget_objects(int type;struct GRid *list;int size; struct GRid **buffer;
                     int ifrom,ito,*count)
{
 *count = 0;
 return OM_S_SUCCESS;
}

method NDcopy(IGRlong *msg; IGRint cp_type;
              struct GRmd_env *obj_env,*new_env;
              struct GRid *newobjid)
{
 newobjid->objid = NULL_OBJID;
 *msg = MSSUCC;
 return OM_S_SUCCESS;
}

method NDdelete(struct GRmd_env *md_env)
{
 return OM_S_SUCCESS;
}

method NDsleep(struct GRmd_env *md_env)
{
 int status;
 status = om$send(msg = message Root.delete(1),
		  targetid = my_id);
 as$status();
 VRreset_solver();
 return OM_S_SUCCESS;
}

end implementation VRcons;
