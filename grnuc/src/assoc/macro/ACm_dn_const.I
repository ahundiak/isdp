/*
  ACm_dn_const.I
  robert patience
  1 sept 1989
*/
class implementation ACmacro_defn;

#include "ASmacroi.h"
#include "macro.h"
#include "batch.h"
#include <alloca.h>

#define AS_DEBUG

from ACncpx import ACchange_feet;
from ACcpx import ACload_macro;


method ACinit_map_ptr(long *msg; struct GRid *list; int nb_temp)
{
 long status;
 struct GRid *slist;
 int i;

 *msg = MSFAIL;
 if(nb_temp != me->tot_up) return OM_W_ABORT;

/* allocate space */

 if(!me->map_struct)
    {
      status = om$vla_set_dimension(varray = me->inst_save,
				    size = me->tot_up * sizeof( struct GRid ));
      if(!(status&1)) return OM_W_ABORT;
      me->map_struct = me->inst_save;
     }

/* Store id */
 slist=(struct GRid  *) me->map_struct;
 for(i=0;i<me->tot_up;i++) slist[i]=list[i];

 *msg= MSSUCC;
 return OM_S_SUCCESS;
}

/* ========================================================================= */
method ACconstruct_feet(IGRlong *msg;char rep;int tempsz;
		struct GRid sym;struct GRid *list;
		int *fcount;struct GRid *feet_list;struct GRmd_env *md_env)
{
int status,i,index;
int fmax,nb_other;
OM_S_OBJID *other;

*msg = MSFAIL;

/* Make the definition points to the correct parents */

status = om$send(msg = message ACmacro_defn.ACinit_map_ptr(msg,list,me->tot_up),
		 targetid = my_id);
if(!(status&*msg&1)) return OM_W_ABORT;

/* Get associative object describing macro behaviour */

  fmax=-1;
  for(i=0;i<me->feet_num;i++)
  {
  if((me->myfeet[i].chan & 3) == feet_in_graphic )
  {

  status = om$send(msg = message ACcomplex.ACget_other(msg,&nb_other,&other),
		   targetid = my_id);
  as$status(action = RET_STATUS);

  index = me->myfeet[i].chan >> 2;
  if(index<nb_other)
   {
    feet_list[me->myfeet[i].pos].objid = other[index];
    feet_list[me->myfeet[i].pos].osnum = OM_Gw_current_OS;
   }
  else
   {
    return OM_W_ABORT;
   }

/*" %d foot to %d\n", feet_list[me->myfeet[i].pos].objid,me->myfeet[i].pos*/
    fmax=me->myfeet[i].pos>fmax ? me->myfeet[i].pos : fmax;
    }
  }
  *fcount=fmax+1;
  *msg = 1;
  return(OM_S_SUCCESS);
}

/* ========================================================================= */
method  ACcontext_compute_feet(char rep;int fcnt,ctxcnt;
		struct GRid *feet_list,*ctx_list;
		struct GRmd_env *md_env)
{
int status,loc_msg;
struct GRid ctx_ft, new_other,
	    *l_anc = NULL;
OM_S_OBJID *other;
int nb_other;
int i_other,j,j_feet;
int cn_type;
int nb_anc,
    s_anc = 0;
int *l_state = NULL;
int union_status;


/* Get the list of associative elements which describe the macro */ 

  status=om$send(msg = message ACcomplex.ACget_other((IGRlong *)&loc_msg,&nb_other,&other),
                   targetid = my_id);
  as$status(action = RET_STATUS);


/* Context compute each of them */

  cn_type = ND_COMP_IN_LIB | ND_COMP_NO_ERASE   | ND_COMP_NO_REM_RT |
			     ND_COMP_NO_DISPLAY | ND_COMP_NO_ADD_RT  ;
  union_status = MSSUCC;
  for(i_other=0;i_other<nb_other;i_other++)
   {
    /* Retrieve context object if any */

    ctx_ft.objid=NULL_OBJID;
    for(j_feet=0;j_feet<fcnt;j_feet++)
     {
     if(IF_EQ_OBJID(other[i_other],feet_list[j_feet].objid))
      {
      if(j_feet<ctxcnt) ctx_ft=ctx_list[j_feet];
      break;
      }
     }

    /* get parents of the computed element */

    while(1)
    {
     status = om$send(msg = message NDnode.NDget_objects
			     (ND_ROOT,l_anc,s_anc,NULL,0,OM_K_MAXINT,&nb_anc),
		     targetid = other[i_other]);
     if(nb_anc <= s_anc) break;
     {
      /* parent size not enought */
      s_anc = 25*(1+nb_anc/25);
      l_anc = (struct GRid *) alloca(s_anc*sizeof(struct GRid));
      l_state = (int *) alloca(s_anc*sizeof( int ));
      for(j=0;j<s_anc;j++) l_state[j] = ND_COMP_SUCC;
     }
    }

    /* Recompute it */
    
    loc_msg = 1;
    status = om$send(msg = message NDnode.NDupdate
	      (&loc_msg,cn_type,nb_anc,l_anc,l_state,&ctx_ft,&new_other,md_env),
		     targetid = other[i_other]);
    if(!(status&loc_msg&1)) union_status = MSFAIL;
    as$status();

    /* Update if necessary my list of "other object */

    me->others[i_other] = new_other.objid;
    if(j_feet<fcnt) feet_list[j_feet] = new_other;
  }

   if(union_status == MSFAIL)
    {
     printf("error when recomputing macro %s\n",me->macro_name);
     return OM_W_ABORT;
    }
   else
     return(OM_S_SUCCESS);
}

end implementation ACmacro_defn;
