/* $Id: ACm_dn_const.I,v 1.3 2001/07/14 17:34:20 ramarao Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        vdassoc/ACm_dn_const.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: ACm_dn_const.I,v $
 * Revision 1.3  2001/07/14 17:34:20  ramarao
 * Fixed CR# 5346.
 *
 * Revision 1.2  2001/01/18 19:08:45  ramarao
 * Merged Service Pack Files to 262 pload.
 *
# Revision 1.8  2000/10/23  22:09:48  pinnacle
# Replaced: vds/vdassoc/ACm_dn_const.I for:  by jpulapar for Service Pack
#
# Revision 1.7  2000/10/23  20:05:14  pinnacle
# Replaced: vds/vdassoc/ACm_dn_const.I for:  by jpulapar for Service Pack
#
# Revision 1.6  2000/10/17  21:12:10  pinnacle
# Replaced: vds/vdassoc/ACm_dn_const.I for:  by jpulapar for Service Pack
#
# Revision 1.5  2000/10/05  15:03:02  pinnacle
# Replaced: vds/vdassoc/ACm_dn_const.I for:  by jpulapar for Service Pack
#
# Revision 1.4  2000/09/24  17:41:56  pinnacle
# Replaced: vds/vdassoc/ACm_dn_const.I for:  by jpulapar for Service Pack
#
# Revision 1.3  2000/09/24  17:12:34  pinnacle
# Replaced: vds/vdassoc/ACm_dn_const.I for:  by jpulapar for Service Pack
#
# Revision 1.2  2000/09/24  16:49:24  pinnacle
# Replaced: vds/vdassoc/ACm_dn_const.I for:  by jpulapar for Service Pack
#
 # Revision 1.1  1998/09/27  14:22:06  pinnacle
 # tr179801268
 #
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 07/23/98  ah      TR179801268 Need to skip over invalid objects 
 *                   in the 'other' array
 *
 ***************************************************************************/

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
#include "VDmaster.h"

#define AS_DEBUG

from ACncpx import ACchange_feet;
from ACcpx import ACload_macro;

extern int VDgetAStoggle_com();
extern IGRlong VDbroGetObjDesc();
extern IGRlong VDbroGetObjInfo();


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
  int status,loc_msg,ii;
  struct GRid ctx_ft, new_other,
    *l_anc = NULL,parent;
  OM_S_OBJID *other;
  int nb_other;
  int i_other,j,j_feet;
  int cn_type;
  int nb_anc,
    s_anc = 0;
  int *l_state = NULL;
  int union_status;
  IGRboolean is_macro_lib;
  long stat;
  VDbroObjInfo objInfo;
  char objDesc[1024], path_name[1024];
  int AStoggle_com;

  AStoggle_com = VDgetAStoggle_com();
 
  /* Get the list of associative elements which describe the macro */ 
  
  status=om$send(msg = message ACcomplex.ACget_other((IGRlong *)&loc_msg,&nb_other,&other),
		 targetid = my_id);
  as$status(action = RET_STATUS);

  path_name[0] = '\0';

  ACos_to_path( OM_Gw_current_OS, path_name );
  if( path_name[0] != '\0' )  is_macro_lib = TRUE;
  else			      is_macro_lib = FALSE;
  
  
  /* Context compute each of them */
  
  cn_type = ND_COMP_IN_LIB | ND_COMP_NO_ERASE   | ND_COMP_NO_REM_RT |
    ND_COMP_NO_DISPLAY | ND_COMP_NO_ADD_RT  ;
  union_status = MSSUCC;
  
  if(AStoggle_com){
    sprintf(objDesc,"\n*********MACRO: %s[%d,%d] ************\n",me->macro_name,OM_Gw_current_OS, my_id);
    printf(" %s \n",objDesc);
    printf("Steps in MACRO : %d \n",nb_other);
  }
  
  for(i_other=0;i_other<nb_other;i_other++)
    {
      /* TR179801268
       * Make sure object is valid
       */
      {
	IGRint sts;
	GRclassid classID;
	
	sts = om$get_classid(
			     osnum = OM_Gw_current_OS,
			     objid = other[i_other],
			     p_classid = &classID
			     );
	if (!(sts & 1)) goto skip_it;
      }
      
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
      
      if(AStoggle_com){
	parent.objid = other[i_other];
	parent.osnum = OM_Gw_current_OS;
	
	stat = VDbroGetObjInfo(&parent,&objInfo);
	stat = VDbroGetObjDesc(&objInfo,objDesc);
	printf("[%d]: %s \n",i_other,objDesc);
	for(ii=0;ii<nb_anc;ii++){
	  stat = VDbroGetObjInfo(&l_anc[ii],&objInfo);
	  stat = VDbroGetObjDesc(&objInfo,objDesc);
	  printf("\tParent[%d]: %s \n",ii,objDesc);
	}
      }	
      
      
      loc_msg = 1;
      status = om$send(msg = message NDnode.NDupdate
		       (&loc_msg,cn_type,nb_anc,l_anc,l_state,&ctx_ft,&new_other,md_env),
		       targetid = other[i_other]);
      if(!(status&loc_msg&1)){
	union_status = MSFAIL;
	if( AStoggle_com )
	    printf("Compute of [%d,%d] failed \n",other[i_other],OM_Gw_current_OS);
	goto end_loop;
      }
      else
	{
	  if(AStoggle_com) printf("Compute of [%d,%d] succeeded \n\n",other[i_other],OM_Gw_current_OS);
	}
      as$status();
      
      /* Update if necessary my list of "other object */
      
      me->others[i_other] = new_other.objid;
      if(j_feet<fcnt) feet_list[j_feet] = new_other;
      
      /* TR179801268 for skipping invalid objects */
    skip_it: continue;
      
    }
  
 end_loop: 
  
  if(union_status == MSFAIL)
    {
      if( AStoggle_com || is_macro_lib == FALSE )
      	printf("ERROR MACRO: %s - [%d,%d]\n",me->macro_name, 
				OM_Gw_current_OS, my_id);
      return OM_W_ABORT;
    }
  else
    return(OM_S_SUCCESS);
}

end implementation ACmacro_defn;



