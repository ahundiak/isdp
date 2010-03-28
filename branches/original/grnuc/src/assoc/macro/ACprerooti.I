/*
  ACpreroot_util.I
  robert patience
  21_feb_88
*/
class implementation ACpreroot;

#include "ASmacroi.h"
#include "parametric.h"
#include "macro.h"


extern IGRint ASgive_size_st();

#define AS_DEBUG


/* ========================================================================= */

method ACplace(int *suc; struct ret_struct *fts)
{
  me->fts=*fts;
  return(1);
}

/* ========================================================================= */

method NDprint(struct GRmd_env *md_env ; FILE *stream)
{
  int	status;
 
  status = om$send(msg = message NDnode.NDprint_root(md_env, stream),
		   targetid = my_id );
  as$status(action = RET_STATUS );

  return(1);
}

/* ========================================================================= */

#define MAX_CHAR 80

method NDprint_root( struct GRmd_env *md_env ; FILE *stream)
{
  int 			status,j,*iptr;
  long 			msg;
  char                	name[MAX_CHAR];
  struct ret_struct     rts;

  as$printer_set_name( prefix = "ROOT_PRETEND", name = name);
  if (strcmp(name,"")!=0)
  {
    status = om$send(msg = message NDnode.NDgive_structure(&msg, &rts,md_env),
		     targetid = my_id );
    as$status(action = RET_STATUS );
    fprintf(stream,"	rst[0].type=%#x; \n",rts.type);
    iptr=(int *) &(rts.var.dbg_st);
    for(j=0;j<(ASgive_size_st(rts.type)/4) +1;j++)
    {
      fprintf(stream,"	  rst[0].var.junk[%d]= %#x; \n",j,iptr[j]);
    }
    fprintf(stream,
	    "send ACpreroot.ACplace(&suc,rst) to %s;\n",name);
  }
  return(1);
}

/* ========================================================================= */

method NDmove_to_root( IGRlong *msg; struct GRid *src_grid; 
                       struct GRmd_env *md_env )
{
  src_grid->osnum = OM_Gw_current_OS;
  src_grid->objid = my_id;
  return(1);
}

/* ========================================================================= */

method NDcopy_to_root(IGRlong *msg; int cp_type;
		      struct GRmd_env *fr_env, *to_env;
		      struct GRid *newobjid)
{
  int	status;

  status = om$send(msg = message NDnode.NDcopy(msg, cp_type, fr_env, 
						to_env, newobjid),
                   targetid = my_id );
  as$status(action = RET_STATUS );
  return(1);
}

/* ========================================================================= */

method NDgive_structure(IGRlong *msg; struct ret_struct  *x; 
			struct GRmd_env *md_env)
{
  OM_BLOCK_MOVE( (char *) (&(me->fts)), (char *) x 
		,ASgive_size_st(me->fts.type));
  return(1);
} 

end implementation ACpreroot;

