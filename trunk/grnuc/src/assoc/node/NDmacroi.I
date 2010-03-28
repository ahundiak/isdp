class implementation NDmacro;
/*

   This file implements the methods used by the macros.
*/

#include "AS_status.h"
#include "nddef.h"
#include "madef.h"
#define AS_DEBUG

from NDnode import NDdisconnect;

method ACbecome_macro (IGRlong *msg;IGRint position; struct GRmd_env *md_env)
{
 *msg = ND_DROP_MAC | ND_CONS_MAC | ND_SYMB_MAC;
 return(OM_S_SUCCESS);
}




method  ACmap_from_visible(OM_S_OBJID **list;int *obj_buf_sz,*count;
		int *sz_inst_save,*inst_buf_sz;char **inst_save)
{
  return (  OM_S_SUCCESS );
}

/* ========================================================================= */

method ACgive_structure( int *suc,*direct_index; char *feet_name;
			 struct ret_struct  *ptr_rst; struct GRmd_env *md_env )
{
  struct GRid 		feet_obj;
  IGRint   		status,loc_msg;
  struct GRmd_env loc_env;
  IGRdouble matrix[16];
  short matrix_type;
  short four = 4;
  char *c,*strchr();

/*"feet name%s \n",feet_name */

/* Does the recusion on ACgive_structure to beheave well on virtual feet */


/*| Is there nesting */

  c=strchr(feet_name,':');
  if(c)
   { /*| yes */
     *c = '\0'; 

     /*" Retrieve my direct foot %s\n",feet_name */

     status=om$send(msg = message NDmacro.ACreturn_foot((IGRlong *)suc,
				       feet_name,&feet_obj,&matrix_type,matrix),
		    targetid = my_id );
     *c = ':';
     if(status&1 && *suc&1)
      {
       /*"nesting --> send to col %d %d\n",feet_obj.objid,feet_obj.osnum*/

       status = om$send(msg = message NDmacro.ACgive_structure
			           (suc,NULL,c+1,ptr_rst,md_env),
		       targetid = feet_obj.objid,
		       targetos = feet_obj.osnum);
/*       as$status(); */
      }
     if(status&1 && *suc&1) return OM_S_SUCCESS;
    }

/*| No nesting or the ACgive_structure of my component fails */

   status=om$send(msg = message NDmacro.ACreturn_foot((IGRlong *)suc,
				       feet_name,&feet_obj,&matrix_type,matrix),
		  targetid = my_id );
/*"suc %d mat_t %d ft %d %d\n",*suc,matrix_type,feet_obj.objid,feet_obj.osnum */
   as$status(action = RET_STATUS);
   if(!(*suc&1)) return OM_S_SUCCESS;

/* Get geometry of the component */

   if(matrix_type != MAIDMX)
      {
       MAmulmx(&loc_msg,&four,&four,&four,md_env->md_env.matrix,matrix,
	      loc_env.md_env.matrix);
       MAtypemx(&loc_msg,loc_env.md_env.matrix,&loc_env.md_env.matrix_type);
       loc_env.md_id = md_env->md_id;
       md_env = &loc_env;
      }
      
   status=ASany_give_struct( feet_obj.objid,feet_obj.osnum,md_env,ptr_rst );
   as$status();
   if(status&1) *suc=1;
 
  return ( status );
}

/* ========================================================================= */

method ACgive_foot(int *suc;char *foot_name; struct GRid *foot_GRid )
{
 int status;
 
 status = om$send(msg = message NDmacro.ACreturn_foot
				 ((IGRlong *)suc,foot_name,foot_GRid,NULL,NULL),
		  targetid = my_id);
 return status;
}

/* Test if a foot with a given name exist */

method ACtest_foot(long *suc;char *feet_name)
{
 char *c;
 char *strchr();
 struct ret_struct rst;
 struct GRmd_env md_env;
 struct GRid feet_obj;
 int status,loc_msg;

/* am I directly this element */

 if(feet_name[0] == '.' || feet_name[0] == '\0')
  { *suc = 1; return OM_S_SUCCESS;}


/* if nesting find my component and send it the message test_foot */

 c=strchr(feet_name,':');
 if(c)
  { *c = '\0';
    status=om$send(msg = message NDmacro.ACreturn_foot
				           (suc,feet_name,&feet_obj,NULL,NULL),
                   targetid = my_id );
    *c = ':';
    as$status( action = RET_STATUS );
    if(*suc == 0)
     {
      status = om$send(msg = message NDmacro.ACtest_foot(suc,c+1),
		       targetid = feet_obj.objid,
		       targetos = feet_obj.osnum);
     }
  }
 status = OM_W_ABORT;
 if(!(status&1))
  {
   int direct_index = -1;
   /* for object which does not override test_foot */
   ASmake_md_env(OM_Gw_current_OS,&md_env);
  
   status = om$send(msg = message NDmacro.ACgive_structure
			((int *) suc,&direct_index,feet_name,&rst,&md_env),
		    targetid = my_id);
   as$status();
   if(*suc) *suc = 1; /* old story with old return code */
  }
 return OM_S_SUCCESS;

}
method ACbecome_foot(long *msg; struct GRid *new_obj; struct GRmd_env *md_env)
{
 long status;

 status = om$send(msg = message NDnode.NDdisconnect(0,NULL),
                  targetid = my_id);
 *msg = MSSUCC;
 new_obj->objid = my_id;
 new_obj->osnum = OM_Gw_current_OS;
 return status;
}

end implementation NDmacro;
