class implementation COm_modif;

#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include <limits.h>
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "FI.h"
#include "asbox.h"

#define AS_DEBUG

from NDnode import NDgive_structure;
from ACdiowner import ACgive_path;

method write_form ()
{
int i;
char * fp;
char *c,*strrchr();
char syntax[80];

/*" Display Macro name %s\n",me->macro_name */

  fp = me->form_ptr;
  c = strrchr(me->macro_name,':');
  if(!c) c = me->macro_name;
  else c += 1;
  FIg_set_text(fp,MACRO_NAME,c);

/* Display name of default occurence */
  c = strrchr(me->def_name,':');
  if(!c) c = me->def_name;
  else c += 1;
  FIfld_set_text(fp,DEF_NAME,0,0,c,FALSE);

 
/*" Display macro template nb %d\n",me->Nb_Max_Temp */

  FIfld_set_num_rows(fp,TEMPLATE_LIST,me->Nb_Max_Temp);
  for(i=0;i<me->Nb_Max_Temp;i=i+1)
    {
     COm_display_line(fp,TEMPLATE_LIST,2,i,me->dup[i].prompt,me->dup[i].type,
		      me->Temp_Value+i,&NULL_GRID,0);
    }


/* Display additional options if any */

  FIfld_set_num_rows(fp,OTHER_OPTIONS,0);
  for(i=0;i<me->Nb_Max_Opt;i++)
   {
    FIfld_set_text(fp,OTHER_OPTIONS,i,0,me->Opt_Name+i*OPT_LEN,FALSE);

    /* write its value */
    if(me->Opt_Value[i].type == text_type)
      FIfld_set_text(fp,OTHER_OPTIONS,i,1,
		     me->Opt_Value[i].var.text_st.text_string,FALSE);
    else if (me->Opt_Value[i].type == double_type) 
     {
      sprintf(syntax,"%10.3lf",me->Opt_Value[i].var.root_pm_st.value);
      FIfld_set_text(fp,OTHER_OPTIONS,i,1,syntax,FALSE);
     }
   }
 
  /* add a blank line to add other options */

  FIfld_set_text(fp,OTHER_OPTIONS,me->Nb_Max_Temp,0,"",FALSE);
  FIfld_set_text(fp,OTHER_OPTIONS,me->Nb_Max_Temp,1,"",FALSE);
return(OM_S_SUCCESS);
}

method set_action_and_state(enum possible_actions action;
			    enum possible_states  state)
{
 long size;
 int resp;
 char data[1];
 IGRlong status,msg;

 /*"set state to %d and action to %d\n",state,action */
     me->action = action;
     me->state =  state;
     me->Entry_Request = NOENT;

     resp = ABS_DIG; /* Just to have an "unkown" */
     data[0]=0;
     size = 1;
     status = ex$putque(msg = &msg, response = &resp,
                      byte = &size, buffer = data);

     return (OM_S_SUCCESS);
}

COm_is_optional(def_id,index,opt_id,opt_name,opt_value,dup,Nb_Max_Temp,md_env)
struct GRid *def_id,*opt_id;
int index,Nb_Max_Temp;
char *opt_name;
struct ret_struct *opt_value;
struct sup *dup;
struct GRmd_env *md_env;
{

 long status,msg;
 char *c,*strchr(),*strrchr();
 int i;
 struct GRid opt;

/* Init */
 opt_id->objid = NULL_OBJID;

 status = om$get_objid_at_index(objid = def_id->objid,
				osnum = def_id->osnum,
				index = index,
				p_chanselect = &AS_to_comp,
				objidaddr = &opt.objid,
				osnumaddr = &opt.osnum);
 if(!(status&1)) return status;

 status = om$send(msg = message NDnode.NDgive_structure
					(&msg,opt_value,md_env),
		  senderid = NULL_OBJID,
		  targetid = opt.objid,
		  targetos = opt.osnum);

  if(!(status&1) || !(opt_value->type & parameter_generic)) return OM_S_SUCCESS;

  opt_name[0] = '\0';
  status = om$send(msg = message ACdiowner.ACgive_path(&msg,&opt,opt_name),
		   senderid = NULL_OBJID,
		   targetid = def_id->objid,
		   targetos = def_id->osnum);

  if(!(status&1) || opt_name[0] == '\0') return OM_S_SUCCESS;
  c = opt_name;

 /* verify if that's not one of the template */

 if(!strcmp(c,"~~search_path")) return OM_S_SUCCESS;
 if(!strcmp(c,"~~symbology")) return OM_S_SUCCESS;
 if(!strcmp(c,"~~macro")) return OM_S_SUCCESS;
 for(i=0;i<Nb_Max_Temp;i++)
  {
   if(strcmp(c,dup[i].prompt) == 0) return OM_S_SUCCESS;
  }

 /* This is really an optional info */
 *opt_id = opt;
 return OM_S_SUCCESS;

}

end implementation COm_modif;
