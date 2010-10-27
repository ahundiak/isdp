/* $Id: ASget_par.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	vdassoc/ASget_par.I
 *
 * Description:
 *		ASSOC Correction.
 *		THe macro as$get_parent() can fail on specific cases where
 *		lc$locate likes to be correctm but a NULL_OBJID is returned.
 *		Temporay correction.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ASget_par.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.5  1996/01/24  15:52:46  pinnacle
# Replaced: vdassoc/ASget_par.I for:  by azuurhou for vds.240
#
# Revision 1.4  1996/01/02  21:03:28  pinnacle
# Replaced: vdassoc/ASget_par.I for:  by jwfrosch for vds.240
#
# Revision 1.3  1995/11/10  20:30:30  pinnacle
# Replaced: ./vdassoc/ASget_par.I for:  by azuurhou for vds.240
#
# Revision 1.1  1995/08/16  17:13:36  pinnacle
# Created: vdassoc/ASget_par.I by azuurhou for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	08/16/95	ravi,adz	creation date
 *	11/10/95	adz		When AStranslate fail retry wi di$tr
 *
 ***************************************************************************/


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
#include "v_dbgmacros.h"
#define  AS_DEBUG                 /* For the debug                            */

/**
%safe
int (*AStranslate) () = NULL;
%endsafe
**/

extern int (*AStranslate) ();


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

extern	int ASctl_parent_type();

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                 Get Parents                                */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

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

  SetProc( ASget_var_parent ); Begin


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

  __DBGpr_com(" Start Locate of lc$locate ");
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
__DBGpr_int("Locate status ", status );
__DBGpr_int("Locate ret_cd ", *ret_code );
if((status&1) && (*ret_code == LC_OBJ_LOCATED))
{
 int stat_class;
  GRclassid obj_class;
  extern GRclassid OPP_GRgrset_class_id;
  stat_class = om$get_classid(p_classid = &obj_class,
    		 objid = locate_event.located_object[0].located_obj.objid,
    		 osnum = locate_event.located_object[0].located_obj.osnum);
  if(!(stat_class&1)){
	UI_status(" Invalid Object Located ");
	goto FAILURE;
  }

  if( om$is_ancestry_valid( superclassid = OPP_GRgrset_class_id,
     			      subclassid = obj_class) == OM_S_SUCCESS )
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

     __DBGpr_str(" Response ", response_data );
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
	__DBGpr_com(" Call AStranslate ");
	status_dir = AStranslate( response_data,
   		   &locate_event.located_object[0].located_obj.objid,
   		   &locate_event.located_object[0].located_obj.osnum,
		   NULL);
	if( status_dir != DIR_S_SUCCESS ){
	  status_dir =
	  di$translate( objname = real_name,		
   		  p_objid = &locate_event.located_object[0].located_obj.objid,
   		  p_osnum = &locate_event.located_object[0].located_obj.osnum);
	}
      }
     else
      {
	__DBGpr_com(" Call DItranslate ");
       status_dir = di$translate( objname = real_name,
   		   p_objid = &locate_event.located_object[0].located_obj.objid,
   		   p_osnum = &locate_event.located_object[0].located_obj.osnum);
      }
     if(status_dir == DIR_S_SUCCESS)
       {
        event1->response = SPECIFIED_OBJ;
	*ret_code = LC_OBJ_LOCATED;
        locate_event.located_object[0].module_info.md_env.matrix_type = MAIDMX;
        MAidmx(&msg,locate_event.located_object[0].module_info.md_env.matrix);
        /*" %d %d located\n",locate_event.located_object[0].located_obj.objid,locate_event.located_object[0].located_obj.osnum*/
 
       }
    }

  __DBGpr_int(" Checking RC ", status );
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
    if(!(status&msg&1)) goto FAILURE;

/**
  *  as$status(action = RET_STATUS);
  *
  *    if(   !(status&1)                       
  *       || !(obj_struct->type & type_generic)) goto FAILURE; 
  ***/


/*| SUCCESS : object with right type located */
  *ret_code = 1;
  for (index_token=0;TokenList[index_token] != LOC_PARENT;index_token++);
  End
  return(index_token);

FAILURE : /*| Failure in locate process */ 
  *ret_code = 0;
  for (index_token=0; TokenList[index_token] != GR_UNKNOWN_TYPE;index_token++);
  End
  return(index_token);

INTERRUP : /*| Command interupted (by another command for example */
  *ret_code = 1;
  for (index_token=0; TokenList[index_token] != *response && 
         TokenList[index_token] != GR_UNKNOWN_TYPE; index_token++);
  End
  return(index_token);
}/* end function ASget_parent */

end implementation COpara;
