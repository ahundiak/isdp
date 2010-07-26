/*
     FUNCTION:  DYiterator

    Abstract:  Used to acts on a parametre which acts on the graphic 
               object that we move.


     CHANGE HISTORY:

     bd     nov-86   - Created,
     ch     fev-87   - Modified,
     ch     Nov-87   - Modified (to act directly on a parametre).

-----*/

class implementation COiterator;

#include  "expression.h"
#include  "AS_status.h"
#include  "nd.h"
#include  "nddef.h"
#include  "ndmacros.h"
#include  "asdef.h"
#include  "asmacros.h"
#include  "asbox.h"
#include  "OMmacros.h"
#include  "dpdef.h"
#include  "dpmacros.h"
#include  "ASmatrix.h"
#include "godef.h"
#include  "igrtypedef.h"
#include  "igetypedef.h"
#include  "igrdp.h"
#include  "dpstruct.h"

#define AS_DEBUG 1
#define abs(n) (((n)>0)?(n):(-(n)))

from IGEgragad import DPinrot;
from NDnode import NDchange_node, NDget_objects,NDcopy;
from NDnode import NDgive_structure, NDdelete;
from NDnode import NDdisplay;
from expression import NDset_value;

extern IGRboolean dynamics_in_progress;

IGRlong msg;
IGRdouble fabs();
struct dyn_iter
  {
   struct GRid param_grid;
   struct GRid obj;
   struct GRmd_env clone_mod;
   IGRdouble savpar,oldpar,newpar,olddist,newdist,coef,tolerance;
   IGRmatrix vw_rot;        /* view rotation matrix   */  
   IGRboolean  first;
  };

struct      /* for moving a point by projection on his tangent 
			path */
  {
   IGRboolean flag; /* if vector defined */
   IGRpoint oldpt;
   IGRpoint vector;
  }vecdir;
/************************** DYiterdyn() *********************************/
/*
 *   FUNCTION:  DYiterdyn
 *   Abstract:  
 *     DYiterdyn performs the computation of descendance of the parameter
 *     to be drawn by DPdynamics.  The address of this function
 *     is passed as a parameter to DPdynamics for the dynamic to occur.
 */

#argsused
IGRint DYiterdyn( info_para,
                  point,
		  matrix,
                  objects,
                  num_objects,
                  buffer,
                  num_buffers,
                  in_dummy1,
                  in_dummy2,
                  in_dummy3,
                  out_dummy1,
                  out_dummy2,
                  out_dummy3 )

    struct  dyn_iter         *info_para;
    struct EX_button         *point;
    IGRdouble                *matrix;
    struct   GRid           **objects;
    IGRint                   *num_objects;
    struct   DPele_header   **buffer;
    IGRint                   *num_buffers;
    IGRchar                 **in_dummy1;
    IGRchar                 **in_dummy2;
    IGRchar                 **in_dummy3;
    IGRint                 *out_dummy1;  /* pour test */
    IGRchar                 **out_dummy2;
    IGRchar                 **out_dummy3;

{
 IGRshort rc;
 IGRint status;
 IGRdouble end_value = 0.0;
 extern IGRboolean ASbroadcast_in_progress;
 IGRboolean save_br;
 

 /*"obj: ( %d, %d )\n",info_para->obj.objid, info_para->obj.osnum */

save_br = ASbroadcast_in_progress;
ASbroadcast_in_progress = TRUE;
while(1)
{
 ASdisptobj(info_para->obj, point, end_value, info_para->vw_rot,
 	    &info_para->olddist, &info_para->clone_mod);
	
 info_para->newpar=info_para->oldpar - info_para->coef*info_para->olddist;

 status = om$send(msg=message expression.NDset_value("",info_para->newpar,
					  &info_para->clone_mod,&rc), 
  	   senderid = NULL_OBJID, targetid = info_para->param_grid.objid, 
	   targetos = info_para->param_grid.osnum );
 if(!(status&1)) break;

 nd$get_graph(nb_root = 1,
	      p_root = &info_para->param_grid);
 if(!(status&1)) break;

 status=nd$update_graph(cn_type = ND_COMP_NO_ERASE   | ND_COMP_NO_REM_RT |
                                  ND_COMP_NO_DISPLAY | ND_COMP_NO_REM_RT ,
                        root_compute = ND_DONT_UPT_ROOT,
                        md_env = &info_para->clone_mod);
 if(!(status&1)) break;

	/* find the new distance */

 ASdisptobj(info_para->obj, point, end_value, info_para->vw_rot,
            &info_para->newdist, &info_para->clone_mod);
	
 /*"DYiterdyn, newdist= %lf\n",info_para->newdist */
 /*"DYiterdyn, olddist= %lf\n",info_para->olddist */

 if( fabs(info_para->newdist - info_para->olddist) > info_para->tolerance )
  {
   info_para->coef=(info_para->newpar-info_para->oldpar)/(info_para->newdist-info_para->olddist);
  }
 info_para->oldpar=info_para->newpar;
 if (info_para->first)
    {
    info_para->first-- ;
    continue;
    }
 break;
}	
ASbroadcast_in_progress = save_br;
	       
dp$erase_hilite(msg = &status);
status = nd$broadcast_graph(p_msg = message NDnode.NDdisplay(0,GRhd,
						       &info_para->clone_mod) );
*out_dummy1 = DP_DONT_ERASE;
return(1);
}
/************************* DYiterator() ********************************/

IGRint DYiterator( parent_grid, param_grid, event, object_mod, curr_mod )

struct GRid parent_grid, param_grid;
struct GRevent *event;
struct GRmd_env *object_mod, *curr_mod;
{
  struct ret_struct  param_def, parent_def;
  struct dyn_iter iter_data;
  IGRboolean dyn_on, inquire = 1;
  IGRshort rc;
  IGRdouble end_value = 0.0;
  int status;
  struct GRid list[2],*list_deleted;
  struct NDcp_struct clone_info;
  int nb_deleted,i;

  /*"parent: ( %d, %d )\n", parent_grid.objid, parent_grid.osnum */
  /*"param: ( %d, %d )\n", param_grid.objid, param_grid.osnum */
  
  /*   
   *   if dynamics is off then exit
   */
   
  DPdynflags(&msg, &inquire, &dyn_on, NULL);
  if(!dyn_on) return(1);

  /* if the object is a parameter we do not need dynamic */
  status = as$any_give_structure
		(go_grid = parent_grid,
		 mod_env =  object_mod,
 		 inst = &parent_def);
  as$status(action = GOTO_VALUE, value = wrapup);
  if( parent_def.type & parameter_generic ) return(1);

  iter_data.tolerance = 1e-8;
  iter_data.clone_mod = *curr_mod;
  iter_data.clone_mod.md_id.objid = NULL_OBJID;

/* copy graph and return objid of copied object to iterate on */

  list[0] = param_grid;
  status = nd$get_graph(p_root = list, nb_root = 1);
  as$status(action = GOTO_VALUE, value = wrapup);

  status = nd$copy_graph(from_info = curr_mod,
			 to_info = &iter_data.clone_mod,
			 p_clone = &clone_info);
  as$status(action = GOTO_VALUE, value = wrapup);
  for(i=0;i<clone_info.nb_obj;i++)
   {
    if(clone_info.list[i].original == parent_grid.objid)
      {iter_data.obj.objid = clone_info.list[i].clone; 
       iter_data.obj.osnum = iter_data.clone_mod.md_id.osnum;
       break;
      }
   }

  for(i=0;i<clone_info.nb_obj;i++)
   {
    if(clone_info.list[i].original == param_grid.objid)
      {iter_data.param_grid.objid = clone_info.list[i].clone; 
       iter_data.param_grid.osnum = iter_data.clone_mod.md_id.osnum;
       break;
      }
   }

  if(clone_info.list) om$dealloc(ptr = clone_info.list);
/*  -----------------------------------------------------------------  */

  /*"new_obj: ( %d, %d )\n",iter_data.obj.objid,iter_data.obj.osnum */
  /*"new_par: ( %d, %d )\n",iter_data.param_grid.objid,iter_data.param_grid.osnum */
 

 /* preparation of computation for both dynamic and no dynamic */
			
  ASany_give_struct(iter_data.param_grid.objid, iter_data.param_grid.osnum,
   		    &iter_data.clone_mod, &param_def);

		/* inquire rotation matrix  */
  om$send( msg = message IGEgragad.DPinrot( &msg, iter_data.vw_rot ), 
           senderid = NULL_OBJID, targetid = event->event.button.objid, 
	   targetos = event->event.button.osnum );
	      
  vecdir.flag=0; /* in case of point */
  
                /* measure first distance */
  ASdisptobj( iter_data.obj, &event->event.button, end_value, 
  	      iter_data.vw_rot, &iter_data.olddist, &iter_data.clone_mod );

       /* set coef to allow only one computation in simple cases*/
  iter_data.coef= -0.01;
  iter_data.oldpar=param_def.var.root_pm_st.value;
  iter_data.savpar=iter_data.oldpar;	/* saving for error */
  iter_data.newpar=iter_data.oldpar - iter_data.coef * iter_data.olddist;


  status = om$send( msg = message expression.NDset_value
			      ("", iter_data.newpar, &iter_data.clone_mod, &rc),
  	   senderid = NULL_OBJID, targetid = iter_data.param_grid.objid, 
	   targetos = iter_data.param_grid.osnum );
  as$status(action = GOTO_VALUE, value = wrapup);

  iter_data.first=3;  /*  for the first iteration  */

  /*|before DPdynamics in DYiterator*/
  dp$dynamics( dyn_fun = DYiterdyn, information = &iter_data );

   
/* now delete the copy */

  status = nd$get_graph(p_root = &iter_data.param_grid, nb_root = 1);
  as$status(action = GOTO_VALUE, value = wrapup);

  nd$get_list_in_graph(acc_type = ND_ROOT | ND_BODY,
				buf_addr = &list_deleted,
				p_count = &nb_deleted);

  nd$wait_batch(type = GR_DELETED,
		l_object = list_deleted,
		nb_obj = nb_deleted);

wrapup :
  dynamics_in_progress = FALSE;
  return (1);
}
/*************************** ASiterend() ********************************/

int ASiterend( obj, param, event, my_id, md_env)
struct GRid obj, param;
GRobjid my_id;
struct GRevent *event;
struct GRmd_env *md_env;
/*.funct*/
{
int status;
short int rc;  
IGRmatrix		 vw_rot;        /* view rotation matrix   */
struct ret_struct  param_def, obj_def;
int nbpas=0;
IGRdouble param_hope = 0.0;
struct EX_button *point;
IGRdouble savpar,oldpar,newpar,olddist,newdist,coef,tolerance;

tolerance= 1e-8;

ASany_give_struct(obj.objid, obj.osnum, md_env, &obj_def);
if( obj_def.type & parameter_generic ) 
 {
  /*| parameter case */
  param_hope = event->event.value;
 }
else
 {
  /*| graphic object */
  point = &event->event.button;

  /* inquire rotation matrix  */
  status = om$send( msg = message IGEgragad.DPinrot(&msg,vw_rot),
		   senderid = my_id,
	   	   targetid = event->event.button.objid,
	   	   targetos = event->event.button.osnum );

  vecdir.flag=0; /* in case of point */
 }

/* measure first distance */
ASdisptobj( obj, point, param_hope, vw_rot, &olddist, md_env);

/* set initial arbitrary value of coef */
coef= -0.01;

/* get value of the actual parameter */
ASany_give_struct(param.objid, param.osnum, md_env, &param_def);
oldpar=param_def.var.root_pm_st.value;
savpar=oldpar;	/* saving for error */

while (1)
 {
  newpar=oldpar - coef*olddist;

  /*"ASiterend before set value newpar= %lf\n",newpar*/

  status = om$send( msg = message expression.NDset_value("",newpar, md_env,&rc),
  	   senderid = NULL_OBJID, targetid = param.objid,
	   targetos = param.osnum );
  if(!(status&1)) break;
  status = nd$get_graph(nb_root = 1,
	       		p_root = &param);
  if(!(status&1)) break;

  status=nd$update_graph(cn_type = ND_COMP_NO_ERASE   | ND_COMP_NO_REM_RT |
                                   ND_COMP_NO_DISPLAY | ND_COMP_NO_REM_RT ,
                         root_compute = ND_DONT_UPT_ROOT,
                         md_env = md_env);
  if(!(status&1)) break;


  /* find the new distance */
  ASdisptobj( obj, point, param_hope, vw_rot, &newdist, md_env);
	
  /*"ASiterend loop step= %d, newdist= %lf0.10\n",nbpas,newdist*/
  /* test the end of the loop */
  if(abs(newdist)< tolerance)
   {
    status=OM_S_SUCCESS;
    break;  /* good  end  */
   }
  if(((abs(newdist)>= abs(olddist))&& nbpas>6)||nbpas++>100||newdist==olddist)
   {
    /*  ATTENTION ICI A TRAITER PROCHAINEMENT */
    /* <-> Pour un point, il peut y avoir convergence (minimum distance) */
    status=OM_W_ABORT;
    break;  /* no convergence  */
   }
  coef= (newpar-oldpar)/(newdist-olddist);
  oldpar=newpar;
  olddist=newdist;
 }


/* If failure, restore initial value of the parameter */

if(status==OM_W_ABORT)
{
  om$send( msg = message expression.NDset_value("", savpar, md_env, &rc ), 
  	   senderid = NULL_OBJID, targetid = param.objid,
	   targetos = param.osnum );
  status = nd$get_graph(nb_root = 1,
	       		p_root = &param);

  status=nd$update_graph(cn_type = ND_COMP_NO_ERASE   | ND_COMP_NO_REM_RT |
                                   ND_COMP_NO_DISPLAY | ND_COMP_NO_REM_RT ,
                         root_compute = ND_DONT_UPT_ROOT,
                         md_env = md_env);
}
  return ( status );
}

/*************************** ASdistptobj() ******************************/
ASdisptobj(obj, point, end_value, mtx, dist, md_env)
    struct GRid obj;	     /* object to mouve 		    */
    struct EX_button *point; /* position point (mouse)		    */
    IGRdouble end_value;     /* paramter iteration, value expeted   */ 
    IGRdouble mtx[4][4];     /* rotation matrix of the window       */
    IGRdouble *dist;	     /* returned value of signed distance   */
    struct GRmd_env *md_env;
/*.funct*/
{
 struct ret_struct  obj_def;
 IGRvector v,p,q,nw,nc,pt;
 IGRdouble len,rad,a,b,c;

 ASany_give_struct(obj.objid, obj.osnum, md_env, &obj_def);
 switch(obj_def.type&(conic_generic|line_generic|point_generic|parameter_generic))
  {
    case parameter_generic:
      /*| case parameter_generic */
      *dist = end_value - obj_def.var.root_pm_st.value;
      break;

    case conic_generic:  /* compute  point in circle's plan */
      /* vector nornal to circle's plan */
      nc[0]=obj_def.var.circle_st.mat[2];
      nc[1]=obj_def.var.circle_st.mat[6];
      nc[2]=obj_def.var.circle_st.mat[10];
      /* vector normal to view's plan */
      nw[0]=mtx[2][0];		
      nw[1]=mtx[2][1];		
      nw[2]=mtx[2][2];		
      v_sub(obj_def.var.circle_st.cent_p,point,p);
      a=v_dot(p,nc);
      c=v_dot(nc,nw);    /* the cosinus */
      if (c ==0 )
	{
	  *dist=1;
	  break;    /* make it failled */
	}
      v_scale(nw,a/c,q);
      v_add(q,point,q);  /* q is the pojected point */    	
	
      v_sub(q,obj_def.var.circle_st.cent_p,v);
      len=v_len(v);	
      rad=obj_def.var.circle_st.rad;
      a=rad+len;  /* take the nearest for len  and -len */
      b=rad-len;
      c= (abs(a))-(abs(b)); 
      *dist=(c<0)?a:b; /* to allow keeping negative radius */
      break;

    case line_generic:
      v_sub(point,obj_def.var.line_st.p0,v);
      p[0]=mtx[2][0]; p[1]=mtx[2][1]; p[2]=mtx[2][2];
      v_cross(obj_def.var.line_st.v0,p,q);
      *dist=v_dot(q,v);
      break;

    case  point_generic:     
      /* report point into pt at the same window z of the
	 obj point (for no paralleles construction plans) */
		
      q[0]=mtx[2][0]; q[1]=mtx[2][1]; q[2]=mtx[2][2];
      v_sub(obj_def.var.point_st.pt,point,v);
      len=v_dot(q,v);
      v_scale(q,len,v);
      v_add(v,point,pt);
      if (vecdir.flag == 0)
       {
	 v_equal(obj_def.var.point_st.pt,vecdir.oldpt);
	 v_sub(pt,obj_def.var.point_st.pt,vecdir.vector);
	 len=v_len(vecdir.vector);
	 if (len == 0)
	  {
	    vecdir.vector[0]= 1;
	    vecdir.vector[1]= 0;
	    vecdir.vector[2]= 0;
	    *dist=0;
	  }
	 else
	  {
	    *dist=len/10;/* reduce distance since it is not the right distance 
	                    and a smaler make the iteration more quite */
	    len= 1/len;
	    v_scale(vecdir.vector, len, vecdir.vector);
	  }
	 vecdir.flag=1;    
	 break;
       }
      else
       {
	 v_sub(pt, obj_def.var.point_st.pt, p);
	 v_sub(obj_def.var.point_st.pt, vecdir.oldpt, v);
	 v_equal(obj_def.var.point_st.pt, vecdir.oldpt);
	 len=v_len(v);
	 if (len > 0.01)
	  {
	    if (0 < v_dot(vecdir.vector,v)) len = 1/len;
	    else 			    len = (-1)/len;
	    v_scale(v,len,vecdir.vector);
	  }
	 *dist = v_dot(vecdir.vector,p);
	}
      break;
	

    default: *dist=0;
  } /* end switch */

/*"ASdist.. --> dist: %lf\n", *dist */
  return(1);
}

end implementation COiterator;
