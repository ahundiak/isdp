/*----
     CHANGE HISTORY:

     D.Payannet   1-mar-87    : Design date              
     JLA         25-may-87    : create the expression in get_param if necessary
     JSD          9-mar-92    : prevent locate of profiles
     DLB          8-jul-92    : prevent locate of most dprs
     DLB          8-jul-92    : allow locate of EMSgencompsf

     PROGRAM DESCRIPTION:

     each of these 3 function allow to locate a selected element

     get_param    --> Locate a parameter
     get_parent   --> Locate a parent

     each of these function call an action handler

     ASctl_param_type   --> Control the parameter of the entity
     ASctl_parent_type  --> Control the type of the entity

----*/

class implementation COpara;

#include "ASmessages.h"
#include "msmacros.h"
#include "coparadef.h"
#include "coparamac.h"
#include "expression.h"
#include "expmacros.h"
#include "exmacros.h"
#include "lcmacros.h"
#include "nddef.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "griomacros.h"
#include "asmacros.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "OMmacros.h"
#include "madef.h"
#include "macro.h"

#include "AS_status.h"            /* For the verification of the OM status    */
#define  AS_DEBUG                 /* For the debug                            */

%safe
int (*AStranslate) () = NULL;
%endsafe


/* IMPORTED METHODS */

from NDnode import NDget_objects,NDchg_state,NDgive_structure,
 		   NDctl_parent_type;
from GRgraphics import GRdisplay, GRgetprops;

struct ctl_par_arg           /* Arguments for the act. handler(parents,param) */
{
  IGRint type_generic;       /* Type for the selection criteria               */
  struct GRlc_stack *stack;  /* Contains the information of the stack         */
  IGRint num_eligible;       /* Number of eligible elements if any            */
			     /* If 0, all elements are eligible		      */
  struct GRid *eligible;     /* Array of eligible elements                    */
  IGRint num_non_eligible;   /* Number of non eligible elements if any 	      */
  struct GRid *non_eligible; /* Array of non eligible 			      */
  char *macro_name;          /* macro name				      */
  GRclassid classid;         /* eligible class				      */
};

char *strchr();

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                 Action Handler to control the parent type                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint ASctl_parent_type(act_parms,new_entry,locate_args,action)

/* control the parent type during locate (and before accept/reject by user    */

         IGRchar   *act_parms;    /* Parameters for the selection criteria    */
  struct GRlc_info *new_entry;    /* Information for the graphic object       */
  struct LC_action_args   *locate_args; /* quelque chose 		      */
  IGRint *action;

  /*.ASctl_parent_type*/
  {
  IGRint   loc_status,status,loc_msg; /* Status return by the function        */
  struct ctl_par_arg *parent_arg; /* Pointer on the control arguments         */
  char *name;
  char dummy_name[2];

  /*| Get the argument list of the handler */

  parent_arg = (struct ctl_par_arg *) act_parms;

  if(*action == start_transition || *action == end_transition)
    {
     /*| begin or end transition */
     loc_status = LCptlocact(parent_arg->stack,new_entry,locate_args,action);
     return(loc_status);
    }

  /*"obj %d %d \n",new_entry->located_obj.objid,new_entry->located_obj.osnum*/

/*
   When a list of eligible element is defined,
   verify if the element is eligible
*/
  if(parent_arg->eligible)
   {
    return(LC_RELOCATE);
   }

/*
   When a list of non eligible element is defined
   verify if the element is non eligible
*/
  else if(parent_arg->non_eligible)
   {
    return(LC_RELOCATE);
   }

/* Verify if the object is eligible */

 if(parent_arg->macro_name) name = parent_arg->macro_name;
 else
  { name = dummy_name;
    strcpy(dummy_name,"*");
  }
 
 status = NDctl_parent_type
                        (&loc_msg,parent_arg->type_generic,name,
                         &new_entry->located_obj,
                         &new_entry->module_info);

 if(!(status&loc_msg&1)) return LC_RELOCATE;

 loc_status = LCptlocact(parent_arg->stack,new_entry,locate_args,action);
 return loc_status;
  
}/* end function ASctl_parent_type */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                 Get Parents                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

/* 
  select a parent with a given type
  Return its objid, objspace and give_structure
*/

IGRint ASget_parent
  (
  ret_code,TokenList,event1,event2,locate_mask,input_mask,event_size,
  display_flag,response,response_data,locate_prompt,acc_prompt,relocate_prompt,
  attributes,stack,type_generic,located_obj,context,obj_struct )

  IGRlong   *ret_code;            /* Return code from ls$locate               */
  IGRint    TokenList[];          /* List of token of the command object      */
  struct    GRevent   *event1;    /* Event for the locate point               */
  struct    GRevent   *event2;    /* Event for the accept point               */
  IGRlong   *locate_mask;         /* Mask for the locate                      */
  IGRlong   *input_mask;          /* Mask for the input events                */
  IGRint    *event_size;          /* Size of the returned event               */
  IGRlong   *display_flag;        /* Flag to define the display mode          */
  IGRint    *response;            /* Response returned from GRgetevent        */
  IGRchar   *response_data;       /* Response data returned from GRgetevent   */
  IGRchar   *locate_prompt;       /* Prompt for the locate step               */
  IGRchar   *acc_prompt;          /* Prompt for the accept step               */
  IGRchar   *relocate_prompt;     /* Prompt for the relocate step             */
  IGRint    type_generic;         /* Type of entity to select                 */
  struct GRlc_locate *attributes; /* Attributes to be found                   */
  struct GRlc_stack  *stack;      /* Contains objid and context               */
  struct GRid        *located_obj;/* Located object                           */
  struct GRid        *context;    /* Context object                           */
  struct ret_struct  *obj_struct; /* Structure of the returned object         */

  /*.ASget_parent*/
  {
  long status;
  status = as$get_parent(
		msg = ret_code,
		TokenList = TokenList,
		event1 = event1,
		event2 = event2,
		locate_mask = *locate_mask,
		input_mask = *input_mask,
		event_size = *event_size,
		display_flag = *display_flag,
		response = response,
		response_data = response_data,
		loc_prompt = locate_prompt,
		acc_prompt = acc_prompt,
		reloc_prompt = relocate_prompt,
		attr = attributes,
		locate_stack = stack,
		type_generic = type_generic,
		returned_obj = located_obj,
		returned_context = context,
		returned_struct  = obj_struct );
  return status;
 }

IGRint ASget_var_parent
  ( ret_code,TokenList,event1,event2,locate_mask,input_mask,event_size,
  display_flag,response,response_data,locate_prompt,acc_prompt,relocate_prompt,
  attributes,stack,type_generic,macro_name,nb_eligible,eligible,
  nb_non_eligible,non_eligible,located_obj,context,obj_struct )

  IGRlong   *ret_code;            /* Return code from ls$locate               */
  IGRint    TokenList[];          /* List of token of the command object      */
  struct    GRevent   *event1;    /* Event for the locate point               */
  struct    GRevent   *event2;    /* Event for the accept point               */
  IGRlong   locate_mask;         /* Mask for the locate                      */
  IGRlong   input_mask;          /* Mask for the input events                */
  IGRint    event_size;          /* Size of the returned event               */
  IGRlong   display_flag;        /* Flag to define the display mode          */
  IGRint    *response;            /* Response returned from GRgetevent        */
  IGRchar   *response_data;       /* Response data returned from GRgetevent   */
  IGRchar   *locate_prompt;       /* Prompt for the locate step               */
  IGRchar   *acc_prompt;          /* Prompt for the accept step               */
  IGRchar   *relocate_prompt;     /* Prompt for the relocate step             */
  struct GRlc_locate *attributes; /* Attributes to be found                   */
  struct GRlc_stack  *stack;      /* Contains objid and context               */
  IGRint    type_generic;         /* Type of entity to select                 */
  char *macro_name;
  struct GRid *eligible,*non_eligible;
  int nb_eligible,nb_non_eligible;
  struct GRid        *located_obj;/* Located object                           */
  struct GRid        *context;    /* Context object                           */
  struct ret_struct  *obj_struct; /* Structure of the returned object         */
 {
  IGRlong status,msg,loc_ret_code;
  IGRint  index_token;            /* Index returned for the tokenlist         */
  struct  ctl_par_arg act_parms;  /* Contains the value for the selection     */
  struct  GRevent  loc_event1,loc_event2;
  struct  GRevent  locate_event;  /* Event for the locate point               */
  struct  GRmd_env *mod_env;      /* Information about the environment        */
  int is_set; 			  /* Located object is a set		      */
  OM_S_CLASSLIST eligible_classes, *p_eligible;
  GRclassid list_of_classes[18];


  if(event1 == NULL) event1 = &loc_event1;
  if(event2 == NULL) event2 = &loc_event2;
  if(ret_code == NULL) ret_code = &loc_ret_code;


/*"get_parent with type %x\n",type_generic */

  /* Initialize the arguments for the action handler */
  act_parms.type_generic = type_generic;
  act_parms.stack        = stack;
  act_parms.macro_name   = macro_name;
  act_parms.num_eligible   = nb_eligible;
  act_parms.eligible   = eligible;
  act_parms.num_non_eligible   = nb_non_eligible;
  act_parms.non_eligible   = non_eligible;

  /* Call locate filter to locate an object  */

/* en attendant que le locate par nom marche mieux */

  locate_mask = (locate_mask | GRm_SPECIFIED_OBJ) & (~GRm_STRING);

  *ret_code = MSSUCC;

/*********
lc$locate takes eventsize as *int.  The following call was just passing int.
I added the & to event_size.  This was a hidden problem on the clipper but
crashes on the sparc. - Dave Brann 10/5/91.
**********/

/*********
The default class list was being used (GRgraphics) but we want to prevent
the locate of profile components.  The w_flags are defined in lcmacros.h
Jimmy Dodd 03/04/92.
**********/

  if (om$get_classid(classname = "SKconstraint", 
                     p_classid = &list_of_classes[0]) == OM_S_SUCCESS)
  {
    om$get_classid(classname = "SKvariable", p_classid = &list_of_classes[1]);
    om$get_classid(classname = "SKgmhndlpt", p_classid = &list_of_classes[2]);

    eligible_classes.w_count = 3;
    eligible_classes.w_flags = OM_CLST_subclass | OM_CLST_negation;

    if ((attributes->owner_action & LC_INTERMIDIATE) &&
        (attributes->owner_action & LC_BOTTOM_UP))
    {
      /*Disallow locate of DPR operations which don't support track pts.
       * Currently, EMSsfimpbnd, EMSsfmkface, EMSslmkface & EMSsfboolean only.
       * DLB 7/10/92.
       */
      om$get_classid(classname="EMSsflm",     p_classid=&list_of_classes[3]);
      om$get_classid(classname="EMSlift",     p_classid=&list_of_classes[4]);
      om$get_classid(classname="EMSsfround",  p_classid=&list_of_classes[5]);
      om$get_classid(classname="EMSsfrndbool",p_classid=&list_of_classes[6]);
      om$get_classid(classname="EMSsfboolfea",p_classid=&list_of_classes[7]);
      om$get_classid(classname="EMSslboolean",p_classid=&list_of_classes[8]);
      om$get_classid(classname="EMSsfrembnd", p_classid=&list_of_classes[9]);
      om$get_classid(classname="EMSsfspltwsf",p_classid=&list_of_classes[10]);
      om$get_classid(classname="EMSsfmacro",  p_classid=&list_of_classes[11]);
      om$get_classid(classname="EMSsfstitch", p_classid=&list_of_classes[12]);
      om$get_classid(classname="EMSsubbs",    p_classid=&list_of_classes[13]);
      om$get_classid(classname="EMSswcompsf", p_classid=&list_of_classes[14]);
      om$get_classid(classname="EMSsfsolid",  p_classid=&list_of_classes[15]);
      om$get_classid(classname="EMSgensolid", p_classid=&list_of_classes[16]);
      om$get_classid(classname="EMSpolyhdrn", p_classid=&list_of_classes[17]);

      eligible_classes.w_count += 15;
    }

    eligible_classes.p_classes = list_of_classes;
    p_eligible = &eligible_classes;

  }
  else
    p_eligible = NULL;

  status = lc$locate(rc =ret_code,
                     event1=event1,
                     event2=event2,
                     event3=&locate_event,
                     mask1=locate_mask,
                     mask2=input_mask,
                     eventsize=&event_size,  /*added & - DLB 10/5/91*/
                     display_flag=display_flag,
                     response=response,
                     response_data=response_data,
                     locate_prompt=locate_prompt,
                     acc_prompt=acc_prompt,
                     relocate_prompt=relocate_prompt,
                     attributes=attributes,
                     stack=stack,
                     act_handler=ASctl_parent_type,
                     unhilight_mode = GRhe,
                     eligible_classes = p_eligible, /*added JSD 3/4/92*/
                     act_args=&act_parms);

is_set = 0;
if((status&1) && (*ret_code == LC_OBJ_LOCATED))
{
 int stat_class;
  GRclassid obj_class;
  extern GRclassid OPP_GRgrset_class_id;
  stat_class = om$get_classid(p_classid = &obj_class,
    		 objid = locate_event.located_object[0].located_obj.objid,
    		 osnum = locate_event.located_object[0].located_obj.osnum);
  if(   (stat_class&1)
     && (om$is_ancestry_valid( superclassid = OPP_GRgrset_class_id,
     			       subclassid = obj_class) == OM_S_SUCCESS))
   {
    is_set = 1;
   }
}

 /* 
    Locate by name jla 13-oct-89 
 */
  else if(*response == STRING)
    {
     char real_name[DI_PATH_MAX];
     int status_dir;
     /*| try translate */
     /*| SUPPOSED TO BE IN CURRENT MODULE BECAUSE I DON'T KNOW HOW TO GET */
     /*| TRANSFORMATION MATRIX						  */

     /* Stupid user mode */

     di$cvt_name_from_input(u_path = response_data,
			    s_path = real_name);

     /*"u_path %s s_path %s\n",response_data,real_name */
     if(AStranslate)
      {
	/*| Attention au trou .... */
	status_dir = AStranslate( response_data,
   		   &locate_event.located_object[0].located_obj.objid,
   		   &locate_event.located_object[0].located_obj.osnum,
		   NULL);
      }
     else
      {
       status_dir = di$translate( objname = real_name,
   		   p_objid = &locate_event.located_object[0].located_obj.objid,
   		   p_osnum = &locate_event.located_object[0].located_obj.osnum);
      }
     /*"status %d %x\n",status_dir,status_dir*/
     if(status_dir == DIR_S_SUCCESS)
       {
        event1->response = SPECIFIED_OBJ;
	*ret_code = LC_OBJ_LOCATED;
        locate_event.located_object[0].module_info.md_env.matrix_type = MAIDMX;
        MAidmx(&msg,locate_event.located_object[0].module_info.md_env.matrix);
        /*" %d %d located\n",locate_event.located_object[0].located_obj.objid,locate_event.located_object[0].located_obj.osnum*/
 
       }
    }

  /* Check the return code */

  if(!(status&1)) goto FAILURE; /* filter error */

  if(*ret_code != LC_OBJ_LOCATED) goto INTERRUP;/*No element located */

  /*| An element has been located. */

   located_obj->objid = locate_event.located_object[0].located_obj.objid;
   located_obj->osnum = locate_event.located_object[0].located_obj.osnum;
      

   mod_env = &locate_event.located_object[0].module_info;


/* modif momo 04-01-89 */
/*| get the module env of the located object in event1 */

    event1->located_object[0].module_info = *mod_env;

/* end of modif */

   /*"look for the context matrix type: %d\n",mod_env->md_env.matrix_type*/
   status = GRfindcontext( &msg, &mod_env->md_env.matrix_type, 
                     mod_env->md_env.matrix, &located_obj->osnum, context );
   if(status == OM_S_SUCCESS && msg == MSSUCC )
        {
          /*"context object found: %d, %d\n", context->objid, context->osnum */
          if(context->osnum == located_obj->osnum)
            {
             /*|context dans le meme os */
            }
        }
      else
       {
        context->objid = NULL_OBJID;
        /*"context pas trouve msg = %d\n",msg */
        }

    status = NDctl_parent_type(&msg, type_generic, macro_name, located_obj,
			       mod_env);

    if(!(status&msg&1)) goto FAILURE;

    /* Get if possile the structure of the object selected */
    status=as$any_give_structure(
		           go_grid = (*located_obj),
                           mod_env = mod_env,
			   inst    = obj_struct);
    as$status(action = RET_STATUS);

/*    if(   !(status&1)                       
/*       || !(obj_struct->type & type_generic)) goto FAILURE; 
/****/


/*| SUCCESS : object with right type located */
  *ret_code = 1;
  for (index_token=0;TokenList[index_token] != LOC_PARENT;index_token++);
  return(index_token);

FAILURE : /*| Failure in locate process */ 
  *ret_code = 0;
  for (index_token=0; TokenList[index_token] != GR_UNKNOWN_TYPE;index_token++);
  return(index_token);

INTERRUP : /*| Command interupted (by another command for example */
  *ret_code = 1;
  for (index_token=0; TokenList[index_token] != *response && 
         TokenList[index_token] != GR_UNKNOWN_TYPE; index_token++);
  return(index_token);
}/* end function ASget_parent */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                 Action Handler to control the parameter                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint ASctl_param(act_parms,new_entry,locate_args,action)

/* control that the object selected or its parent is a parameter              */

         IGRchar      *act_parms; /* parameters for the selection criteria    */
  struct GRlc_info    *new_entry; /* Information for the graphic object       */
  struct LC_action_args   *locate_args; /* quelque chose 		      */
  IGRint *action;

  /*.ASctl_param_type*/
  {
  struct ctl_par_arg  *param_arg; /* Parameters for the selection criteria    */
  struct GRid list;    		  /* List of the parents of the selected obj  */
  struct ret_struct   obj_struct; /* Structure of the object selected         */
  IGRint       loc_status,status; /* Status return by the function            */
  IGRint              count;      /* number of parents of the selected object */
  long                msg;
  short               props;

  /* make sure the guy is locatable AND displayable */
  status = om$send ( msg = message GRgraphics.GRgetprops ( &msg, &props ),
     senderid = NULL_OBJID,
     targetid = new_entry->located_obj.objid,
     targetos = new_entry->located_obj.osnum );
  if (!(status & 1)) return LC_RELOCATE;
  if (!(props & GRIS_LOCATABLE)) return LC_RELOCATE;
  if (!(props & GRIS_DISPLAYABLE)) return LC_RELOCATE;

  /* Get the argument list of the handler */
  param_arg = (struct ctl_par_arg *) act_parms;

  if(*action == start_transition || *action == end_transition)
    {
     /*| begin or end transition */
     loc_status = LCptlocact(param_arg->stack,new_entry,locate_args,action);
     return(loc_status);
    }


  /* Get the structure of the object */
 
   status = ASany_give_struct(new_entry->located_obj.objid,
                              new_entry->located_obj.osnum,
 			     &new_entry->module_info,&obj_struct);
  if (!(status&1))  return(LC_RELOCATE);

  if ((obj_struct.type&param_arg->type_generic) == param_arg->type_generic)
      {
      /*| Put the parameter in the stack */
       loc_status = LCptlocact(param_arg->stack,new_entry,locate_args,action);
       return(loc_status);
       }
  else
       {
      /*"Get first root of %d",new_entry->located_obj.objid*/

        status = om$send (msg      = message NDnode.NDget_objects(ND_ROOT,
						&list,1,NULL,0,1,&count),
                        senderid = NULL_OBJID,
                        targetid = new_entry->located_obj.objid,
                        targetos = new_entry->located_obj.osnum);
        if(!(status&1))  return(LC_RELOCATE);

	if(count <= 0) return (LC_RELOCATE);
      
      /*" Get the structure of this parent %d %d",list.objid,list.osnum */

         status = as$any_give_structure(go_grid = list,
					mod_env = &new_entry->module_info,
					inst    = &obj_struct);
         if((obj_struct.type&param_arg->type_generic)!=param_arg->type_generic)
         						    return(LC_RELOCATE);

        /*| Put the object in the stack */

        loc_status = LCptlocact(param_arg->stack,new_entry,locate_args,action);
        return(loc_status);
       }
}/* end function ASctl_param */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint ASget_all_param
(
  IGRlong            *ret_code,
  IGRint              TokenList[],
  struct GRevent     *event1,
  struct GRevent     *event2,
  IGRlong            *locate_mask,
  IGRlong            *input_mask,
  IGRint             *event_size,
  IGRlong            *display_flag,
  IGRint             *response,
  IGRchar            *response_data,
  IGRchar            *locate_prompt,
  IGRchar            *acc_prompt,
  IGRchar            *relocate_prompt,
  struct GRlc_locate *attributes,
  struct GRlc_stack  *stack,
  int                 type_generic,
  struct GRid        *located_obj,
  double             *param_value
)
#if 0
  IGRlong   *ret_code;            /* Return code from ls$locate               */
  IGRint    TokenList[];          /* List of token of the command object      */
  struct    GRevent   *event1;    /* Event for the locate point               */
  struct    GRevent   *event2;    /* Event for the accept point               */
  IGRlong   *locate_mask;         /* Mask for the locate                      */
  IGRlong   *input_mask;          /* Mask for the input events                */
  IGRint    *event_size;          /* Size of the returned event               */
  IGRlong   *display_flag;        /* Flag to define the display mode          */
  IGRint    *response;            /* Response returned from GRgetevent        */
  IGRchar   *response_data;       /* Response data returned from GRgetevent   */
  IGRchar   *locate_prompt;       /* Prompt for the locate step               */
  IGRchar   *acc_prompt;          /* Prompt for the accept step               */
  IGRchar   *relocate_prompt;     /* Prompt for the relocate step             */
  double    *param_value;         /* Value of the parameter selected          */
  struct GRlc_locate *attributes; /* Attributes to be found                   */
  struct GRlc_stack  *stack;      /* Contains objid and context               */
  struct GRid        *located_obj;/* Located object                           */
  int 	    type_generic;	  /* eligible type			      */
#endif


  /*.ASget_all_param*/
  {
  IGRlong status,msg;             /* Status returned by the primitives        */
  IGRint  index_token;            /* Index returned for the tokenlist         */
  struct  ctl_par_arg act_parms;  /* Contains the value for the selection     */
  struct  GRevent  locate_event;  /* Event for the locate point               */
  IGRint  count;                  /* number of parents of the selected object */
  struct ret_struct   str;        /* Structure of the object selected         */
  struct GRid list;    		  /* List of the parents of the selected obj  */
  IGRlong local_locate_mask;
  struct GRmd_env dummy_env;
  IGRchar   copy_data[1024];      /* copy of the responsedata for parsing */
  

  /* Initialize the arguments for the action handler */

  act_parms.type_generic = type_generic;
  act_parms.stack        = stack;

  /* Initialize dummy env used later in the function to get parameter 
     type and value and to erase the located object */

  MAidmx(&msg,dummy_env.md_env.matrix);
  dummy_env.md_env.matrix_type = MAIDMX;
  ex$get_cur_mod(id = &dummy_env.md_id.objid, osnum = &dummy_env.md_id.osnum);

  /* Call locate filter to locate an object  */

  *locate_mask |= GRm_SPECIFIED_OBJ;


/* en attendant que le locate par nom marche mieux */

  local_locate_mask = (*locate_mask | GRm_SPECIFIED_OBJ) & (~GRm_STRING);

  *ret_code = MSSUCC;
  status = lc$locate(rc =ret_code,
                     event1=event1,
                     event2=event2,
                     event3=&locate_event,
                     mask1=local_locate_mask,
                     mask2=*input_mask,
                     eventsize=event_size,
                     display_flag=*display_flag,
                     response=response,
                     response_data=response_data,
                     locate_prompt=locate_prompt,
                     acc_prompt=acc_prompt,
                     relocate_prompt=relocate_prompt,
                     attributes=attributes,
                     stack=stack,
                     act_handler=ASctl_param,
                     act_args=&act_parms);

/*"ret_code %d status %d\n",*ret_code,status */

  if (!(status&1)) goto FAILURE;  /* error in locate */

  else if (*ret_code == 0 && *response != STRING) goto INTERRUP; 

  else if (*ret_code == 0 && *response == STRING)
   {
    /* ASget_param_from_string modifies the input response_data(from now
       on copy_data) so the response_data is copied into another variable
       copy_data and sent to the function. -subhasish */

    strcpy( copy_data,response_data );
    status = ASget_param_from_string(copy_data,type_generic,
				     located_obj,param_value,&dummy_env);
			
     if(!(status&1)) goto FAILURE;
    }

 else
    {
      struct GRid cur_mod;
      enum GRdpmode erase = GRhe;

      located_obj->objid = locate_event.located_object[0].located_obj.objid;
      located_obj->osnum = locate_event.located_object[0].located_obj.osnum;

      status = ex$get_cur_mod(id = &cur_mod.objid, osnum = &cur_mod.osnum);
      as$status();

      om$send(msg = message GRgraphics.GRdisplay(&msg,
   		 &locate_event.located_object[0].module_info.md_env.matrix_type,
   		  locate_event.located_object[0].module_info.md_env.matrix,
		 &erase,&cur_mod),
		 senderid = NULL_OBJID,
    		 targetid = located_obj->objid,
    		 targetos = located_obj->osnum);
    as$status();

/*"Is the located obj %d %d the pm\n",located_obj->objid,located_obj->osnum */

      status = om$send(msg = message NDnode.NDgive_structure
							(&msg,&str,&dummy_env),
                       senderid = NULL_OBJID,
                       targetid = located_obj->objid,
		       targetos = located_obj->osnum);
      if((status&1) &&
          (str.type&type_generic) == type_generic )
       {
        if(type_generic != text_type) *param_value = str.var.root_pm_st.value;
        goto SUCCESS;
       }


      /*If its first parent is the parameter, get it */

        status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,&list,1,
							    NULL,0,1,&count),
                   senderid = NULL_OBJID,
                   targetid = located_obj->objid,
                   targetos = located_obj->osnum);

        if(!(status&1) || count ==0) goto FAILURE;

        /*| Load the parameter in located_obj */

        located_obj->objid = list.objid;
        located_obj->osnum = list.osnum;

      /* Get the value of the parameter */

      status = om$send(msg = message NDnode.NDgive_structure
							 (&msg,&str,&dummy_env),
                       senderid = NULL_OBJID,
                       targetid = located_obj->objid,
		       targetos = located_obj->osnum);
      if(!(status&1) ||
          (str.type&type_generic) != type_generic ) goto FAILURE;
      if(type_generic != text_type) *param_value = str.var.root_pm_st.value;
    }


SUCCESS : /*| a parameter is found */
      for (index_token=0; TokenList[index_token] != LOC_PARAM ;index_token++);
      /*"return %d\n",index_token*/
      return(index_token);

FAILURE : /*| no parameter located */
       for (index_token=0; TokenList[index_token] != GR_UNKNOWN_TYPE;
	    index_token++);
/*"token %d resp %d resp_data %s\n",index_token,*response, response_data */
       response_data[0] = '\0';
       return(index_token);

INTERRUP : /*| Command interupted (by another command for example */
  for (index_token=0; TokenList[index_token] != *response && 
         TokenList[index_token] != GR_UNKNOWN_TYPE; index_token++);
  return(index_token);

}/* end function ASget_param */

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*
/* That's just the old flavor of ASget_param where it is not possible to 
/* specify if we search a double parameter or a text parameter 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

IGRint ASget_param
(
  IGRlong            *ret_code,
  IGRint              TokenList[],
  struct GRevent     *event1,
  struct GRevent     *event2,
  IGRlong            *locate_mask,
  IGRlong            *input_mask,
  IGRint             *event_size,
  IGRlong            *display_flag,
  IGRint             *response,
  IGRchar            *response_data,
  IGRchar            *locate_prompt,
  IGRchar            *acc_prompt,
  IGRchar            *relocate_prompt,
  struct GRlc_locate *attributes,
  struct GRlc_stack  *stack,
  struct GRid        *located_obj,
  double             *param_value
)
#if 0
  IGRlong   *ret_code;            /* Return code from ls$locate               */
  IGRint    TokenList[];          /* List of token of the command object      */
  struct    GRevent   *event1;    /* Event for the locate point               */
  struct    GRevent   *event2;    /* Event for the accept point               */
  IGRlong   *locate_mask;         /* Mask for the locate                      */
  IGRlong   *input_mask;          /* Mask for the input events                */
  IGRint    *event_size;          /* Size of the returned event               */
  IGRlong   *display_flag;        /* Flag to define the display mode          */
  IGRint    *response;            /* Response returned from GRgetevent        */
  IGRchar   *response_data;       /* Response data returned from GRgetevent   */
  IGRchar   *locate_prompt;       /* Prompt for the locate step               */
  IGRchar   *acc_prompt;          /* Prompt for the accept step               */
  IGRchar   *relocate_prompt;     /* Prompt for the relocate step             */
  double    *param_value;         /* Value of the parameter selected          */
  struct GRlc_locate *attributes; /* Attributes to be found                   */
  struct GRlc_stack  *stack;      /* Contains objid and context               */
  struct GRid        *located_obj;/* Located object                           */
#endif
{
int status;
status =  ASget_all_param
  ( ret_code,TokenList,event1,event2,locate_mask,input_mask,event_size,
  display_flag,response,response_data,locate_prompt,acc_prompt,relocate_prompt,
  attributes,stack,parameter_generic,located_obj,param_value);
return status;
}

NDctl_parent_type(msg, type, info, object, md_env)
long *msg;
int type;
char *info;
struct GRid *object;
struct GRmd_env *md_env;
{
 struct ret_struct rst;
 long status;

 if(type == ~0) { *msg = MSSUCC; return OM_S_SUCCESS; }

 status = om$send(msg = message NDnode.NDctl_parent_type (msg,type,info),
		  senderid = NULL_OBJID,
		  targetid = object->objid, 
		  targetos = object->osnum);

 if(!(status&1))
  {
   /* for object not sub class of node */
   status = as$any_give_structure(go_grid = (*object),
                                mod_env = md_env,
                                inst    = &rst);
    
    if(rst.type & type) *msg = MSSUCC;
    else *msg = MSFAIL;
  }
 return OM_S_SUCCESS;
}
end implementation COpara;
