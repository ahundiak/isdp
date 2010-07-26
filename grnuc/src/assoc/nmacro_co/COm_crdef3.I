/*

Name
  COm_crdef3.I

Description
  This has routines  for the command object for Macro creation.

Notes


 */

/*
     jla  23_sep_86 : Design date
     jla  04-nov-86 : Associative implementation
*/

class implementation COm_crdef;

#include "msmacros.h"
#include "ASmessages.h"
#include <stdio.h>
#include <alloca.h>
#include "coparadef.h"
#include "expression.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "griomacros.h"
#include "nddef.h"
#include "ndmacros.h"
#include "asdef.h"
#include "asmacros.h"
#include "AS_status.h"
#include "asbox.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "macro.h"
#include "acdef.h"
#include "acmacros.h"

#define  AS_DEBUG  1


from ACmacro_defn import ACgive_upscan,ACbuild_min_macro;
from NDnode   import NDgive_structure,NDselect_copy,NDget_parent_type;

extern GRclassid OPP_expression_class_id,
		 OPP_NDnode_class_id,
		 OPP_ACmacro_defn_class_id;

extern char *COm_crdef_form_ptr;

extern struct GRid AC_construct_id;


%safe
static IGRint TokenList[] =
 		      {
			RESET,
			GR_UNKNOWN_TYPE ,
			LOC_PARENT  
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ****************** TOKENS ***********
   Old State  *    RESET   , UNKNOWN , PARENT     */

/* WAIT_OBJ   */ { FULL_DEF, WAIT_OBJ , WAIT_OBJ  },
/* FULL_DEF   */ { FULL_DEF, FULL_DEF , FULL_DEF  }};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            *************TOKENS ********************
   Old State  *     MOVE_ON    , UNKNOWN   , PARENT    */

/* WAIT_OBJ   */ { LOC_FORM    , LOC_OBJ   , STO_OBJ   }, 
/* FULL_DEF   */ { LOC_FORM    , LOC_FORM  , LOC_FORM  }};
%endsafe


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
    IGRint      	status;         /* routine return status */
    IGRint      	event_size;     /* size of GRevent buffer */
    IGRlong     	display_flag;   /* display flag for locate filter */
    IGRlong     	input_mask;     /* mask for GRgetevent */
    IGRlong     	locate_mask;    /* mask for GRgetevent */
    IGRlong     	msg;            /* function return code */
    struct GRevent 	grevent1, grevent2;  /* event returned by GRgetevent */
    struct GRid  	context; /* object located        */
    IGRint 		resp;
    IGRint 		i,j,k,ii;
    IGRint 		token=0;
    IGRint 		obj_generic;
    IGRint 		nb_obj,i_obj;
    struct GRid 	*obj_to_print,*obj;
    IGRint 		remaining_size;
    int start_locate,some_located_not_selected,nb_selected,located_selected;
    struct GRid source,macro,macro_def,def_occ;
    int def_mode;
    struct ret_struct rst;
    int el_type;
    GRclassid obj_class;
    char **lines;
    char temp_prompt[80];
    int real_feet_num;
    int feet_reintegrated = 0;

    char *c,*ct,*cf,
	 *strrchr();
    int error;
    char wd_name[DI_PATH_MAX];
    struct GRid wd;
    int *info;
    int invisible;
    struct GRid *cyc_grid = (struct GRid *)alloca(sizeof(struct GRid) * MAX_NUM_EQN_VAR);
    struct GRid input_grid;
    int cyc_count;
       
    start_locate=0;
    *response = TERMINATE;
    if(!COm_crdef_form_ptr) return OM_S_SUCCESS;

    obj_generic = 0xffffffff;
    event_size = sizeof (struct GRevent);
    locate_mask = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP;
    input_mask  = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP; 
    display_flag = ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;

    me->attr.properties   = LC_DP_ONLY | LC_LC_ONLY | LC_RW;
    me->attr.owner_action = LC_RIGID_COMP| LC_RIGID_OWNER 
                       	  | LC_FLEX_COMP | LC_FLEX_OWNER 
			  | LC_HANDLES | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;


  /* Test if a working directory has been defined */
 ac$construct_wd(mode = AC_INQ,
                 name = wd_name,
                 name_size = DI_PATH_MAX,
                 dir = &wd);
 if(wd.objid == NULL_OBJID)
  {
   ex$message(msgnumb = AS_F_NoWLib);
   *response = TERMINATE;
   return OM_S_SUCCESS;
  }
 else
  {
   ex$message(msgnumb = AS_S_MLibIs,type="%s",
              var = `wd_name`);
  }

    /*
     *  loop until exit condition occurs
     */

   do
    {
      switch (me->action)
      {       
	 case NIL :     /*| nil */
	   break;

	 default :
	 case ERR :    /*| err  */
	   ex$message( msgnumb = AS_E_InvDefRest);


	 case RESTART : /*| restart */
	   me->state = WAIT_OBJ;
	   me->action= LOC_OBJ;
	   me->Nb_Max_Feet = 0;
	   me->Nb_Max_Temp = 0;
	   me->Nb_Max_Obj = 0;
	   me->Entry_Request = NOENT;
	   me->macro_name[0] = '\0';
	   me->template_type = ND_ROOT | ND_BODY;
	   if(COm_crdef_form_ptr) 
	    {
	     status = om$send(msg = message COm_crdef.write_form
							   (COm_crdef_form_ptr),
			      targetid = my_id); 
	     as$status();
	    }
	   break;

	 case REG_EXP : /*| reg_exp */
	   lines = NULL;
	   nb_obj = 0;
	   start_locate = me->Nb_Max_Obj; 
  	   status = di$ls( regexp = response_data ,
                  	   lines = &lines ,
                           ptr = &nb_obj,
		           options = NULL);
	   if(!(status&1)) break;

	   status = om$send(msg = message COm_crdef.realloc_obj
						       (me->Nb_Max_Obj+nb_obj),
			    targetid = my_id);
	   as$status(action = RET_STATUS);

	   me->located_obj.osnum = me->ModuleInfo.md_id.osnum;
           for(i_obj=0 ; i_obj<nb_obj ; i_obj++)
            {
  	     status = di$translate ( osnum =  me->ModuleInfo.md_id.osnum,
                                     objname = lines[i_obj],
                                     p_objid = &me->located_obj.objid,
                                     p_osnum = &me->located_obj.osnum);

	     om$get_classid(objid = me->located_obj.objid,
  	       osnum = me->located_obj.osnum, p_classid = &obj_class);
	     if(om$is_ancestry_valid(superclassid = OPP_NDnode_class_id,
			      subclassid = obj_class) != OM_S_SUCCESS)
             {
               /*
                * We make source
                */
               status = as$make_source ( go_grid = me->located_obj,
                 as_os = me->located_obj.osnum, as_grid = &me->located_obj );
 	       if(!(status&1)) continue;
             }

             for(j=0;j<me->Nb_Max_Obj;j++)
               { if(me->Obj_List[j].objid == me->located_obj.objid) break;}
             if(j>=me->Nb_Max_Obj)
              {
	       j = me->Nb_Max_Obj;
               me->Obj_List[me->Nb_Max_Obj++]=me->located_obj;
              }
	     me->Obj_Info[j] = me->template_type;
            }

           if(lines != NULL && nb_obj != 0)
            {
             di$free(lines = lines,
                     count = nb_obj);
	    }
	    
	   if (!me->Nb_Max_Obj)
	   {
	     me->action = LOC_OBJ;
	     break; 
	   }

	 case STO_OBJ :   /*| sto_obj */

	  if(me->action == STO_OBJ)
	  {
	   if(grevent1.response != SPECIFIED_OBJ)
	   status = EXputq_front(&msg, &resp, (IGRlong *)&event_size, 
	                        (IGRchar *)&(grevent2.event));

	   /* expend fence contents if necessary */

	   ASstart_fence(me->located_obj,me->located_obj.osnum,&nb_obj,
			      &obj_to_print,&resp,response_data);

           status = om$send(msg = message COm_crdef.realloc_obj
                                                       (me->Nb_Max_Obj+nb_obj),
                            targetid = my_id);
           as$status(action = RET_STATUS);

	   start_locate = me->Nb_Max_Obj; 
	   for(i_obj=0 ; i_obj<nb_obj ; i_obj++)
	    {
	     status = as$make_source(go_grid = obj_to_print[i_obj],
                         	     as_os = obj_to_print[i_obj].osnum,
                         	     as_grid = &source);
 	     if(!(status&1)) continue;
	     if(source.objid == NULL_OBJID) continue;
 
	     for(j=0;j<me->Nb_Max_Obj;j++)
	      {if(me->Obj_List[j].objid == source.objid) break;}
	     if(j>=me->Nb_Max_Obj)
	      {
	       j = me->Nb_Max_Obj;
               me->Obj_List[me->Nb_Max_Obj++]=source;
               /*"add %d %d\n",source.objid,source.osnum*/
	      }
	     me->Obj_Info[j] = me->template_type;
	    }
	   ASend_fence();
          }

	  /* Send them "select_copy" message to know who is really located */

	   some_located_not_selected = 0;
	   for(;start_locate < me->Nb_Max_Obj;start_locate++)
           {
	    remaining_size =
		      om$dimension_of(varray = me->Obj_List) - me->Nb_Max_Obj;
	    obj = me->Obj_List+me->Nb_Max_Obj;
	    info = me->Obj_Info+me->Nb_Max_Obj;
	    for(i=0;i<remaining_size;i++) info[i] = ND_ROOT | ND_BODY;
	    status = om$send(msg = message NDnode.NDselect_copy(&msg,0,
			       		  obj,info,remaining_size,&nb_selected),
			     targetid = me->Obj_List[start_locate].objid,
			     targetos = me->Obj_List[start_locate].osnum);
            /*
             * It is OK to not know the message (non assoc objects).
             */
            if (status == OM_W_UNKNOWN_MSG)
              status = OM_S_SUCCESS;
	    if(nb_selected > remaining_size)
	     {
              status = om$send(msg = message COm_crdef.realloc_obj
                                                  (me->Nb_Max_Obj+nb_selected),
                               targetid = my_id);
              as$status(action = RET_STATUS);

	      remaining_size =
		      om$dimension_of(varray = me->Obj_List) - me->Nb_Max_Obj;
	      obj = me->Obj_List+me->Nb_Max_Obj;
	      info = me->Obj_Info+me->Nb_Max_Obj;
	      for(i=0;i<remaining_size;i++) info[i] = ND_ROOT | ND_BODY;
	      status = om$send(msg = message NDnode.NDselect_copy(&msg,0,
			       		  obj,info,remaining_size,&nb_selected),
			     targetid = me->Obj_List[start_locate].objid,
			     targetos = me->Obj_List[start_locate].osnum);
	      as$status(action = RET_STATUS);
	     }
	     /* Only the target of the message is a selected element */
	     if(nb_selected == 1 &&
		me->Obj_List[start_locate].objid == obj[0].objid)
	      {
	       if(*info)
	       me->Obj_Info[start_locate]= me->Obj_Info[start_locate] 
			  & (*info | ND_TEMPLATE_AND_FEET | ND_INVISIBLE);
	       continue;
	      }

	     /* Other elements are selected */
	     located_selected = 0;
	     for(i=0;i<nb_selected;i++,obj++,info++)
	      {
	       if(me->Obj_List[start_locate].objid == obj[i].objid)
		{located_selected = 1;
	         if(*info)
	         me->Obj_Info[start_locate]= me->Obj_Info[start_locate] 
			 & (*info | ND_TEMPLATE_AND_FEET | ND_INVISIBLE);
		 continue;
		}
	       
	       for(j=0;j<me->Nb_Max_Obj;j++)
	        {
		 if(me->Obj_List[j].objid == obj->objid)
		 { 
		   if(*info)
		   me->Obj_Info[j] = me->Obj_Info[j] & *info;
		   break;
		  }
		}
	       if(j>=me->Nb_Max_Obj)
		{
		 if(*info)
		 me->Obj_Info[me->Nb_Max_Obj] = *info;
		 else 
		 me->Obj_Info[me->Nb_Max_Obj]=ND_ROOT | ND_BODY | ND_INVISIBLE;
                 me->Obj_List[me->Nb_Max_Obj++]=*obj;
		}
              }
	     if(!located_selected) 
	      { 
	       some_located_not_selected = 1;
	       me->Obj_List[start_locate].objid = NULL_OBJID;
	      }
	   }

	 /* remove null objid if any */

	 if(some_located_not_selected)
	  {
	   for(i=0,j=0 ; i<me->Nb_Max_Obj ; i++)
            {
	     if(me->Obj_List[i].objid != NULL_OBJID)
		{
	     	 me->Obj_Info[j] = me->Obj_Info[i];
	     	 me->Obj_List[j++] = me->Obj_List[i];
	        }
	    }
	   me->Nb_Max_Obj = j;
	  }


	case GET_GRAPH :  /*| get graph */

           status = nd$get_internal_graph(p_initial = me->Obj_List,
                                         nb_initial = me->Nb_Max_Obj);
           as$status(action = RET_STATUS);

           /*| Define now template list and feet list */

	   status = om$send(msg = message COm_crdef.realloc_template
							 (me->Nb_Max_Obj),
	   		    targetid = my_id); 
	   as$status(action = RET_STATUS);

	   status = om$send(msg = message COm_crdef.realloc_feet
							 (me->Nb_Max_Obj),
	   		    targetid = my_id); 
	   as$status(action = RET_STATUS);

	   me->Nb_Max_Feet = 0;
	   me->Nb_Max_Temp = 0;
	   ct = me->Temp_Name;
	   cf = me->Feet_Name;
	   error = 0;
	   for(invisible = 0; invisible<2 ; invisible++)
	    {
	    for(i=0 ; i<me->Nb_Max_Obj ; i++)
             {
	      if(invisible != (1 && (me->Obj_Info[i] & ND_INVISIBLE))) continue;
	      el_type = me->Obj_Info[i] & ~ND_INVISIBLE;

	      if(el_type == (ND_ROOT|ND_BODY))
	       {
	        nd$get_type(p_object = me->Obj_List+i,
			    nb_obj   = 1,
			    p_type = &el_type);
		el_type= el_type & (ND_ROOT|ND_BODY);
	       }
	      else if(el_type == (ND_ROOT|ND_BODY|ND_TEMPLATE_AND_FEET))
					 el_type = ND_ROOT | ND_BODY;
	      else if(el_type & ND_ROOT) el_type = ND_ROOT;
	      else if(el_type & ND_BODY) el_type = ND_BODY;
	      else { error = 1; break;}

	      /* Get the possible type of the template */

	      status = om$send(msg = message NDnode.NDget_parent_type(&msg,
				     &rst.type,
				     rst.var.macro_st.name),
                         targetid = me->Obj_List[i].objid,
                         targetos = me->Obj_List[i].osnum);
	      if(!(msg&status&1)) rst.type = other_generic;
	       
	      /* If the template is an expression get its value */

	      if(rst.type & parameter_generic)
	       {
                status = om$send(msg = message NDnode.NDgive_structure(&msg,
                                        &rst, &me->ModuleInfo),
                         targetid = me->Obj_List[i].objid,
                         targetos = me->Obj_List[i].osnum);
                as$status(action = RET_STATUS);
	       }

	      if(el_type & ND_ROOT)
	       {
	        me->Temp_List[me->Nb_Max_Temp] = me->Obj_List[i];
                me->Temp_Value[me->Nb_Max_Temp] = rst;
		if(invisible) me->Temp_Fixed[me->Nb_Max_Temp] = 1;
		else me->Temp_Fixed[me->Nb_Max_Temp] = 0;
		COm_generate_name(ct,"INPUT",macro_MAX_CHAR,me->Nb_Max_Temp,
                                me->Temp_Value[me->Nb_Max_Temp].type,
				me->Temp_List+me->Nb_Max_Temp);
		me->Nb_Max_Temp++;
	        ct += macro_MAX_CHAR;
	       }
	      if(el_type & ND_BODY)
	       {
	        me->Feet_List [me->Nb_Max_Feet] = me->Obj_List[i];
	        me->Feet_Removed [me->Nb_Max_Feet] = 0;

		if(invisible) *cf = '\0';
	        else COm_generate_name(cf,"OUTPUT",macro_MAX_CHAR,me->Nb_Max_Feet,
				  rst.type, me->Feet_List+me->Nb_Max_Feet);
	        me->Feet_Type[me->Nb_Max_Feet] = rst.type;
	        cf += macro_MAX_CHAR;
	        me->Nb_Max_Feet ++;
	       }
	     }
	    }
	  if(error)
	     {
	      me->action = ERR;
              me->Entry_Request = NOENT;
	      break;
	     }

	  if(COm_crdef_form_ptr)
	    {
	     status = om$send(msg = message COm_crdef.write_form
						           (COm_crdef_form_ptr),
			      targetid = my_id);
	     as$status();
	    }

	
        case LOC_OBJ :    /*| loc obj */
	   if(me->template_type == (ND_ROOT | ND_BODY))
	      {
               me->attr.owner_action = LC_RIGID_OWNER
			  | LC_HANDLES | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED
                                     | LC_FLEX_COMP | LC_FLEX_OWNER;
	       ex$message(msgnumb = AS_P_TempOrFeet,
			  buff = temp_prompt);
	      }

	   else if(me->template_type == ND_ROOT)
	      {
    	       me->attr.owner_action = LC_RIGID_COMP| LC_RIGID_OWNER 
			  | LC_HANDLES | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED
                       	  	     | LC_FLEX_COMP | LC_FLEX_OWNER;
	       ex$message(msgnumb = AS_P_Temp,
			  buff = temp_prompt);
	      }
	   else if(me->template_type == 
				     (ND_ROOT | ND_BODY | ND_TEMPLATE_AND_FEET))
	      {
	       ex$message(msgnumb = AS_P_TempAndFeet,
			  buff = temp_prompt);
    	       me->attr.owner_action = LC_RIGID_COMP| LC_RIGID_OWNER 
			  | LC_HANDLES | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED
                       	  	     | LC_FLEX_COMP | LC_FLEX_OWNER;
	      }
	   else return OM_W_ABORT;

	   if(me->Nb_Max_Obj)
	    {
	     ex$message(msgnumb = AS_P_IdNextTemp,type = "%s",
			var = `temp_prompt`, buff = me->loc_prompt);
	    }
	   else
	    {
	     ex$message(msgnumb = AS_P_IdFirstTemp,type = "%s",
			var = `temp_prompt`, buff = me->loc_prompt);
	    }
	
	   ex$message(buff = me->acc_prompt,msgnumb = AS_P_AccNextObj);
	   me->Entry_Request = PARENT;
	   break;

	case LOC_FORM :  /*| wait form modification */
	  
            if(me->mytype == 0) ex$message(msgnumb = AS_P_MdMcDefForm);
	    if(me->macro_name[0] =='\0' && COm_crdef_form_ptr)
	      {
      		FIfld_pos_cursor(COm_crdef_form_ptr,MACRO_NAME,0,0,0,0,0,0);
	      }
	    me->Entry_Request = POINT;
	    break;
          

	case CREATE_MACRO :   /*| grap print */

          me->Entry_Request = PARENT;

        /* Control name */

	  error = 0;
	  if(me->macro_name[0] == '\0')
	    {ex$message(msgnumb = AS_S_NamCoNotDef);error = 1;}
	  if(!error)
	    {
	     if(strlen(me->macro_name)+1 >= macro_MAX_CHAR)
    	      {
               ex$message(msgnumb = AS_S_NamLen);
               me->macro_name[0] = '\0';
	       error = 1;
	      }
	    }
	  if(!error)
            {status = ac$find_macro_defn(action =  ACfind_no_load,
					 macro_name = me->macro_name,
					 p_macro_defn_id = &macro);
	     if(status&1)
	      {ex$message(msgnumb =AS_S_ConsExist);
	       error = 1;}
            }
		
	  if(error) {me->Entry_Request = NOENT;
		     me->action = LOC_FORM; 
		     break;}
	 

	  if(me->mytype == 0){ ex$message(msgnumb = AS_S_CreaPro); }

 
          if(me->Nb_Max_Temp == 0)
          {
            ex$message( msgnumb = AS_E_NoObjPr);
            me->action = RESTART;
            me->Entry_Request = NOENT;
            break;
          }

	 /* Control if some feet removed should not be kept as invisible 
	    elements because they are needed by some other */

       do{
	 feet_reintegrated = 0;
	 for(i=0;i<me->Nb_Max_Feet;i++)
	  {
	   if(me->Feet_Removed[i]) continue;
	   status = om$send(msg = message NDnode.NDselect_copy(&msg,0,
			 me->Obj_List,me->Obj_Info,me->Nb_Max_Obj,&nb_selected),
			    targetid = me->Feet_List[i].objid,
			    targetos = me->Feet_List[i].osnum);
	   as$status(action=RET_STATUS);
	   if(nb_selected == 1 &&
	      me->Obj_List[0].objid == me->Feet_List[i].objid &&
	      me->Obj_List[0].osnum == me->Feet_List[i].osnum )  continue;

	   for(j=0;j<nb_selected;j++)
	    {
	     c = me->Feet_Name;
	     for(k=0;k<me->Nb_Max_Feet;k++)
	      {
	       if(me->Obj_List[j].objid == me->Feet_List[k].objid &&
	          me->Obj_List[j].osnum == me->Feet_List[k].osnum &&
		  me->Feet_Removed[k])
		 { feet_reintegrated = 1;
		   me->Feet_Removed[k] = 0;
		   *c = '\0';
		   break;
		 }
	       c += macro_MAX_CHAR;
	      }
            }
	   }
	  } while (feet_reintegrated);
	   

          def_mode = ACcant_place_sym|ACminimal_graph;

	  /* save macro library after creation of default parameter and not */
	  /* before							    */
	  { extern int ACauto_save;
	    int save_save;
	    struct sup *dup;
	    struct stemp *dtemp;
	    struct myfeet *myfeet;
	    struct GRid *reorder_template=NULL, *reorder_feet=NULL;
	    struct GRid construct_dir;
            char lib_name[80];

	  save_save = ACauto_save;
	  ACauto_save = 0;

	  /* create "sup" "xdup" and "myfeet" structure */
	  
	  dup = NULL; dtemp = NULL; myfeet = NULL;
	  if(me->Nb_Max_Temp)
	   {
   	    dup         = (struct sup  *)
                  om$malloc( size=(me->Nb_Max_Temp*sizeof(struct sup )) );
    	    dtemp       = (struct stemp  *)
                  om$malloc( size=(me->Nb_Max_Temp*sizeof(struct stemp )) );
	    reorder_template = (struct GRid *)
                  om$malloc( size=(me->Nb_Max_Temp*sizeof(struct GRid )) );
			
    	    if(!dup || !dtemp) return OM_W_ABORT;
	   }

	  if(me->Nb_Max_Feet)
	   {
    	    myfeet      = (struct myfeet *)om$malloc(
                                size=me->Nb_Max_Feet*sizeof(struct myfeet));
	    if(!myfeet) return OM_W_ABORT;
	   }


/*
   Store template making sure that template with fix value are at the end of 
   the list 
*/

	  ii =0;
	  for(invisible=0; invisible<2 ; invisible++)
	  {
	   c = me->Temp_Name;
	   for(i=0;i<me->Nb_Max_Temp;i++,c+=macro_MAX_CHAR)
	   {
	    if(me->Temp_Fixed[i] != invisible) continue;
	    if(!invisible) strcpy(dup[ii].prompt,c);
	    else	   dup[ii].prompt[0] = '\0';
	    dup[ii].type = me->Temp_Value[i].type;
	    if(me->Temp_Value[i].type & (macro_generic|class_generic))
	     strcpy(dup[ii].up_scan,me->Temp_Value[i].var.macro_st.name);
	    else
    	     strcpy(dup[ii].up_scan,".");

	    dtemp[ii].type = me->Temp_Value[i].type;
    	    strcpy(dtemp[ii].down_scan,".");
    	    if(!invisible) strcpy(dtemp[ii].name,c);
	    else dtemp[ii].name[0] = '\0';
    	    dtemp[ii].back=ii;
	    reorder_template[ii++] = me->Temp_List[i];
	   }
	  }

/*
   Store feet making sure that ffet with fix value are at the end of 
   the list 
*/
	  reorder_feet = (struct GRid *) om$malloc
				(size = me->Nb_Max_Feet*sizeof(struct GRid));
	  if(!reorder_feet) return OM_W_ABORT;
	  real_feet_num = 0;
	  for(invisible = 0; invisible < 2 ; invisible ++)
	  {
	   c = me->Feet_Name;
	   for(i=0;i<me->Nb_Max_Feet;i++, c+= macro_MAX_CHAR)
	    {
	     if(me->Feet_Removed[i]) continue;
	     if(invisible != (*c == '\0')) continue; 
    	     strcpy(myfeet[real_feet_num].name,c);
	     reorder_feet[real_feet_num++] = me->Feet_List[i];
	    }
	  }
	  
/* create the macro */

            status = om$construct(classid = OPP_ACmacro_defn_class_id,
				  msg = message ACmacro_defn.ACbuild_min_macro
						 ((int *)&msg, def_mode, 
						 me->macro_name,
				 	me->Nb_Max_Temp,reorder_template,dup,
					me->Nb_Max_Temp,dtemp,
			 	 	real_feet_num,myfeet,reorder_feet,
                                	NULL_GRID,&me->ModuleInfo),
				  osnum = AC_construct_id.osnum,
                            	  p_objid= &macro.objid);
            macro.osnum = AC_construct_id.osnum;
	    if(!(msg&1)) status = OM_W_ABORT;
	    as$status(action = RET_STATUS);

	    status = ac$add_macro_name( osnum           = macro.osnum,
                                	macro_name      = me->macro_name,
                                	macro_defn_id   = macro.objid );


	  /* Create now default template */

	  for(i=0,ii=0;i<me->Nb_Max_Temp;i++)
	  {
	   if(!me->Temp_Fixed[i]) me->Temp_Value[ii++] = me->Temp_Value[i];
	  }
	  ac$create_def_temp(search_option = me->hdr_def,
			     search_path = me->search_path,
			     symbology = me->hdr_symb,
			     hdr_type = me->hdr_type,
			     hdr_scroll = me->hdr_scroll,
			     macro = &macro, 
			     def_col = &macro_def,
			     def_occ = &def_occ,
			     temp_val = me->Temp_Value,
			     temp_grid = reorder_template,
			     feet_grid = reorder_feet);

	  if(dup) om$dealloc(ptr = dup);
	  if(dtemp) om$dealloc(ptr = dtemp);
	  if(myfeet) om$dealloc(ptr = myfeet);
	  if(reorder_template) om$dealloc(ptr = reorder_template);
	  if(reorder_feet)     om$dealloc(ptr = reorder_feet);

	  ACauto_save = save_save;

	  ac$construct_wd(mode = AC_INQ,
	  		  dir = &construct_dir,
			  name = lib_name,
			  name_size = 80);
	  if(ACauto_save && construct_dir.osnum != me->ModuleInfo.md_id.osnum)
	   { ac$save_wd();
	    ex$message(msgnumb = AS_S_MacWri,type = "%s%s",
		       var = `me->macro_name,lib_name`);
	   }
	  else
	   {
	    ex$message(msgnumb = AS_S_MacCrea,type = "%s%s",
		       var = `me->macro_name,lib_name`);
	   }
	  FIg_set_state(COm_crdef_form_ptr,FORM_EXEC,0);
	 }
 

	  /* restart the command */
 

	  me->action = RESTART;
	  me->Entry_Request = NOENT;
	  break;
	
      }   /* end switch (me->state) */


    switch( me->Entry_Request)
    {
     case POINT :  /*| PROMPT */
          token = GRget_token(&status,TokenList,&input_mask,&grevent1,
                	      &event_size,&resp,response_data);
          break;

     case PARENT :  /*| parent */
  	  token = ASget_parent (&msg,TokenList,&grevent1,&grevent2,&locate_mask,
                                &input_mask, &event_size, &display_flag,&resp,
                                response_data,me->loc_prompt,me->acc_prompt,
                                me->reloc_prompt, &me->attr,&me->locate_stack,
                                obj_generic,&me->located_obj,&context,&rst);
                                
            input_grid = me->located_obj;

            status = EQfind_loop_elmts ( input_grid, cyc_grid, &cyc_count );
            as$status(action = RET_STATUS);
                       
            if (cyc_count)
            {
              ex$message(msgnumb = AS_E_MacroLoop);
              me->action = LOC_OBJ;
              me->state = WAIT_OBJ;
	      me->Entry_Request = NOENT;
            } 
            else 
              if (resp == STRING)
                if(di$is_regexp ( regexp = response_data ) && me->state == WAIT_OBJ)
                {
	          me->action = REG_EXP;
	          me->state = WAIT_OBJ;
	          me->Entry_Request = NOENT;
	        }

           break;


     case NOENT :  /*| Noent */
          break;

    }/* end of switch */

/* new action and new state */
	
     if(me->Entry_Request != NOENT)
      {
       me->action = (IGRint) Action[   me->state ][ token ];
       me->state =  (IGRint) NewState[ me->state ][ token ];
      }
  /*"token %d me->action %d me->state %d\n",token,me->action,me->state*/

    } while(me->Entry_Request == NOENT || TokenList[token] != GR_UNKNOWN_TYPE);

    *response = resp;
    /*"response %d\n",*response */

    return( OM_S_SUCCESS);

}   /*  end execute method */

method realloc_template(int nb_template)
{
 long status;
 int previous_size;

  previous_size = om$dimension_of(varray = me->Temp_List);
  if(nb_template > previous_size)
   {
     previous_size = 20*(nb_template/20 +1);
                status = om$vla_set_dimension(varray = me->Temp_List,
                                                   size = previous_size);
                as$status(action = RET_STATUS);
                status = om$vla_set_dimension(varray = me->Temp_Value,
                                                  size = previous_size);
                as$status(action = RET_STATUS);
                status = om$vla_set_dimension(varray = me->Temp_Name,
                                           size = previous_size*macro_MAX_CHAR);
                as$status(action = RET_STATUS);
                status = om$vla_set_dimension(varray = me->Temp_Fixed,
                                           size = previous_size);
                as$status(action = RET_STATUS);
   }
  return OM_S_SUCCESS;
}

method realloc_feet(int nb_feet)
{
 long status;
 int previous_size;

  previous_size = om$dimension_of(varray = me->Feet_List);
  if(nb_feet > previous_size)
   {
     previous_size = 20*(nb_feet/20 +1);
             status = om$vla_set_dimension(varray = me->Feet_List,
                                           size = previous_size);
             as$status(action = RET_STATUS);

             status = om$vla_set_dimension(varray = me->Feet_Type,
                                           size = previous_size);
             as$status(action = RET_STATUS);

             status = om$vla_set_dimension(varray = me->Feet_Removed,
                                           size = previous_size);
             as$status(action = RET_STATUS);


             status = om$vla_set_dimension(varray = me->Feet_Name,
                                         size = previous_size*macro_MAX_CHAR);
             as$status(action = RET_STATUS);
   }
  return OM_S_SUCCESS;
}

method realloc_obj(int nb_obj)
{
 long status;
 int previous_size;

  previous_size = om$dimension_of(varray = me->Obj_List);
  if(nb_obj > previous_size)
   {
     previous_size = 20*(nb_obj/20 +1);
             status = om$vla_set_dimension(varray = me->Obj_List,
                                           size = previous_size);
             as$status(action = RET_STATUS);

             status = om$vla_set_dimension(varray = me->Obj_Info,
                                           size = previous_size);
             as$status(action = RET_STATUS);

   }
  return OM_S_SUCCESS;
}
end implementation COm_crdef;
