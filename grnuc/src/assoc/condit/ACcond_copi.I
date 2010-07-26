class implementation ACcond_def;

#include "ASmacroi.h"
#include "macro.h"
#include "acdef.h"
#include "acmacros.h"

#define AS_DEBUG

method ACcopy_definition (long *msg;char *new_name;
		          struct GRmd_env *fr_env,*to_env; struct GRid *new_def)
{
 long status,abort;
 int num_cond,num_def,i;
 struct ACcond_descrip *condit;
 struct ACcond_temp *def;
 char macro_name[DI_PATH_MAX], *cname, *strchr();
 struct GRid mac;
 
 
/* Make sure that all the macros contained have also been copied */

 status = om$send(msg = message ACcond_def.ACgive_condit_desc
				(&num_cond,&condit,&num_def,&def),
		 targetid = my_id);

  di$give_pathname(osnum = to_env->md_id.osnum,
		   pathname = macro_name);
  strcat(macro_name,":constructs:");
  cname = strchr(macro_name,'\0');

 abort = 0;
 for(i=0;i<num_cond;i++)
   {strcpy(cname,condit[i].konst);

    status = di$translate( objname = macro_name,
                           p_objid = &mac.objid,
                           p_osnum = &mac.osnum );
    if(!(status&1))
      {
       abort = 1;
       printf("macro %s must be copied before to the target library\n",
	       condit[i].konst);
      }
   }

 *msg = MSFAIL;
 if(abort) return OM_W_ABORT;

 status = om$construct_and_copy(object = me,
				osnum = to_env->md_id.osnum,
				p_objid = &new_def->objid);
 new_def->osnum = to_env->md_id.osnum;

 if(status&1) status = ac$add_macro_name(macro_name = new_name,
                            osnum = new_def->osnum,
                            macro_defn_id = new_def->objid);

 if(status&1) *msg = MSSUCC;
 return status;;
}
end implementation ACcond_def;
