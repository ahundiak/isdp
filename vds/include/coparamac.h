/* $Id: coparamac.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:        include/coparamac.h
 *
 * Description: Fence macros, not in a very good directory
 *              so moce them here for convience
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: coparamac.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1999/04/09  17:57:10  pinnacle
 * Fence macros
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/09/99  ah      Creation
 ***************************************************************************/

#omdef as$get_parent(
   msg = NULL,
   TokenList = TokenList,
   event1 = NULL,
   event2 = NULL,
   locate_mask = GRm_DATA|GRm_STRING|GRm_RESET|GRm_BACK_UP,
   input_mask =  GRm_DATA|GRm_STRING|GRm_RESET|GRm_BACK_UP, 
   event_size = sizeof(struct GRevent),
   display_flag = ELEM_HILIGHT | ALL_WINDOWS, 
   response = response,
   response_data = response_data,
   loc_prompt   = me->loc_prompt,
   acc_prompt   = me->acc_prompt,
   reloc_prompt = me->reloc_prompt, 
   attr = &me->attr,
   locate_stack = &me->locate_stack,
   type_generic = ~0,
   macro_name = NULL,
   nb_eligible = 0,
   eligible = NULL,
   nb_non_eligible = 0,
   non_eligible = NULL,
   returned_obj,
   returned_context,
   returned_struct = NULL )

ASget_var_parent( (msg) , (TokenList) , (event1) , (event2),
   (locate_mask) , (input_mask) , (event_size) , (display_flag),
   (response) , (response_data) , (loc_prompt) , (acc_prompt) , (reloc_prompt),
   (attr) , (locate_stack),
   (type_generic) , (macro_name),
   (nb_eligible) , (eligible) , (nb_non_eligible) , (non_eligible),
   (returned_obj), (returned_context) , (returned_struct))

#endomdef

#omdef as$start_fence(set,
		      set_env = NULL,
		      osnum = 0,
		      nb_obj ,
		      p_obj = NULL ^ p_obj_env = NULL,
		      response = NULL,
		      response_data = NULL,
		      make_source = FALSE,
		      type_generic = ~0,
		      macro_name   = NULL)

ASstart_var_fence((set),(set_env),(osnum),(nb_obj),(p_obj),(p_obj_env),
	(response),(response_data),(make_source),(type_generic),(macro_name))

#endomdef
/*
 ABSTRACT : Process fence contents


 ARGUMENTS :

struct GRid *set    I : set GRid
GRspacenum  osnum   I : object space of selected object if non 0
int         *nb_obj O : number of selected objects
struct GRid **p_obj O : pointer to buffer containing selected objects 
int       *response O : standart response and response data of command object. 
char *response_data O : If not NULL, fence contents is hilighted and user is
			prompt for accept/reject.
			If NULL, fence contents return without user control.
int make_source     I : Make or not a source on the located object.
			The source will be constructed in the current model
int type_generic    I : Eligible type for selected object
char *macro_name    I : Eligible macro name if selected object is macro.
		        No control if NULL.
*/
			
		      
			
