class implementation expression;

#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "nddef.h"
#include "ndmacros.h"
#include "coparadef.h"
#include "AS_status.h"
#include "expression.h"
#include "expmacros.h"
#define AS_DEBUG

%safe
static char *option[4] =
{
"shared_parameter_option",
"batch_option",
"copy_option",
"save_libraries"
};

static char *dir_opt_name = ":IGENOD:assoc_option";
%endsafe

extern IGRboolean ASbroadcast_in_progress;
extern IGRint ACauto_save;


/* Retrieve option header */

AScreate_option(osnum)
GRspacenum osnum;
/*.AScreate_option_header*/
{
 int status;
 int iopt;
 struct GRid header,obj;
 char dir_name[DI_PATH_MAX];
 double value;

 value = 0;
 status = di$give_pathname ( osnum =  osnum,
                              pathname =  dir_name);
 strcat(dir_name,dir_opt_name);
 status = di$translate ( osnum =  osnum,
                         objname = dir_name,
                         p_objid = &header.objid);
 if(!(status&1))
  {
   status = di$mkdir(osnum = osnum,
	    	     dirname = dir_name,
	    	     p_dirid = &header.objid);
   as$status(action = RET_STATUS);
  }

 for(iopt=0 ; iopt<4 ; iopt++)
  {
   status = ASbuild_name(osnum,option[iopt],dir_name);
   as$status(action = RET_STATUS);
   status = di$translate(objname = dir_name,
		         p_objid = &obj.objid,
		         p_osnum = &obj.osnum);
   if(!(status&1))
    {
     exp$create(exp_name = dir_name,
		exp_value = value,
		p_exp_id = &obj.objid,
		osnum = osnum);
    }
  }
 return status;

}

ASbuild_name(osnum,opt_name,dir_name)
GRspacenum osnum;
char *opt_name,*dir_name;
/*.ASbuild_name*/
{
 int status;
 int len;

 status = di$give_pathname ( osnum =  osnum,
                             pathname =  dir_name);
 as$status(action = RET_STATUS);

 strcat(dir_name,dir_opt_name);
 len = strlen(dir_name);
 dir_name[len++] = ':';

 strcpy(dir_name+len,opt_name);
 /*"name %s\n",dir_name*/
 return OM_S_SUCCESS;
}


/* Retrieve option expression */ 

ASretrieve_option_obj(osnum,opt_name,obj,val)
GRspacenum osnum;
char *opt_name;
struct GRid *obj;
double *val;
/*.ASretrieve_option_obj*/
{
 int status;
 char dir_name[DI_PATH_MAX];

 obj->objid = NULL_OBJID;

/* Build full path for the name */

 ASbuild_name(osnum,opt_name,dir_name);

 status = di$translate(objname = dir_name,
		       p_objid = &obj->objid,
		       p_osnum = &obj->osnum);

 if(!(status&1)) obj->objid = NULL_OBJID;
 else
  {
   status = om$send(msg = message expression.NDgive_value(val),
		    senderid = NULL_OBJID,
		    targetid = obj->objid,
		    targetos = obj->osnum);
   /*"value %lf\n",*val*/
  }
 return(status);
}
 
/* Retrieve option */ 

ASretrieve_option(osnum)
GRspacenum osnum;
/*.ASretrieve_option*/
{
 int status;
 struct GRid exp;
 double value;
 int ival;

/* Retrieve option for share parameter */

 status = ASretrieve_option_obj(osnum,option[0],&exp,&value);
 if(status&1)
  {
   G_active_para_type = value;
  }

/* Retrieve option for update dependency */

 status = ASretrieve_option_obj(osnum,option[1],&exp,&value);
 if(status&1)
  {
   ival = value;
   nd$mod_batch( request = ND_SET,
		 req_mode = ival);
  }

/* Retrieve option for copy and delete graph */

 status = ASretrieve_option_obj(osnum,option[2],&exp,&value);
 if(status&1)
  {
   ival = value;
   nd$mod_graph( request = ND_SET,
		 req_mode = ival);
  }

/* Retrieve option for auto_save */

 status = ASretrieve_option_obj(osnum,option[3],&exp,&value);
 if(status&1)
  {
   ACauto_save = value;
  }
 return 1;
}


ASsave_option(md_env)
struct GRmd_env *md_env;
/*.ASsave_option*/
{
 long status;
 short rc;
 struct GRid exp;
 double value;
 int ival;
 IGRboolean save_br;
 GRspacenum osnum;

/* Save option for share parameter */

 osnum = md_env->md_id.osnum;
 save_br = ASbroadcast_in_progress;  /* To avoid wait batch performed by   */
 ASbroadcast_in_progress =TRUE;	     /*	set value 			   */
 

 status = ASretrieve_option_obj(osnum,option[0],&exp,&value);
 if(status&1)
  {
   value = G_active_para_type;
   status = om$send(msg = message expression.NDset_value(NULL,value,md_env,&rc),
		    senderid = NULL_OBJID,
		    targetid = exp.objid,
		    targetos = exp.osnum);

  }
 


/* Save option for update dependency */


 status = ASretrieve_option_obj(osnum,option[1],&exp,&value);
 if(status&1)
  {
   nd$mod_batch( request = ND_INQ,
		 p_ret_mode = &ival);
   value = ival;
   status = om$send(msg = message expression.NDset_value(NULL,value,md_env,&rc),
		    senderid = NULL_OBJID,
		    targetid = exp.objid,
		    targetos = exp.osnum);
  }

/* Save option for copy and delete graph */

 status = ASretrieve_option_obj(osnum,option[2],&exp,&value);
 if(status&1)
  {
   nd$mod_graph( request = ND_INQ,
		 p_ret_mode = &ival);
   value = ival;
   status = om$send(msg = message expression.NDset_value(NULL,value,md_env,&rc),
		    senderid = NULL_OBJID,
		    targetid = exp.objid,
		    targetos = exp.osnum);
  }

/* Save option for auto save */
 status = ASretrieve_option_obj(osnum,option[3],&exp,&value);
 if(status&1)
  {
   value = ACauto_save;
   status = om$send(msg = message expression.NDset_value(NULL,value,md_env,&rc),
                    senderid = NULL_OBJID,
		    targetid = exp.objid,
		    targetos = exp.osnum);
  }

 ASbroadcast_in_progress = save_br;
 return 1;
}

end implementation expression;
