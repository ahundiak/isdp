class implementation COm_condit;

#include "msmacros.h"
#include "ASmessages.h"
#include <stdio.h>
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


from NDnode   import NDgive_structure;
from ACcond_def import ACtake_template,ACtake_feet,ACtake_condit;
from ACmacro_defn import ACgive_upscan;
from ACdiowner import ACadd_component_with_name;
from ACncpx import ACload_macro, ACchange_feet;
from GRgraphics import GRcopy;

extern char *COm_condit_form_ptr;

extern GRclassid OPP_ACcond_def_class_id, OPP_ACsymb_hold_class_id;


%safe
static IGRint TokenList[] =
 		      {
			RESET,
			STRING,
			GR_UNKNOWN_TYPE 
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*              ****************** TOKENS *****************
   Old State    *    RESET      , DATA        , UNKNOWN   */

/* WAIT_MACRO   */ { WAIT_NAME  , WAIT_VALUE  , WAIT_MACRO   },
/* WAIT_VALUE   */ { WAIT_MACRO , WAIT_MACRO  , WAIT_VALUE   },
/* WAIT_NAME    */ { WAIT_NAME  , WAIT_CONDIT , WAIT_NAME    },
/* WAIT_CONDIT  */ { WAIT_NAME  , FULL_DEF    , WAIT_CONDIT  },
/* WAIT_DEF_TEMP*/ { FULL_DEF   , FULL_DEF    , WAIT_DEF_TEMP},
/* FULL_DEF     */ { FULL_DEF   , FULL_DEF    , FULL_DEF     }};



static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {
/*              ****************** TOKENS *****************
   Old State    *    RESET       , DATA        , UNKNOWN   */

/* WAIT_MACRO   */ { GET_NAME    , STO_MACRO   , GET_MACRO   },
/* WAIT_VALUE   */ { GET_MACRO   , STO_VALUE   , GET_VALUE   },
/* WAIT_NAME    */ { GET_NAME    , STO_NAME    , GET_NAME    },
/* WAIT_CONDIT  */ { GET_CONDIT  , STO_CONDIT  , GET_CONDIT  },
/* WAIT_DEF_TEMP*/ { WAIT        , STO_DEF_TEMP, GET_DEF_TEMP},
/* FULL_DEF     */ { WAIT        , WAIT        , WAIT        }};

%endsafe


/* decode condition value */

COm_decode(syntax,value)
char *syntax;
struct ACcond_val *value;
{
 int ok;
 char *c;

 ok= sscanf(syntax,"%lf", &value->value.dbl);
	   if(ok)
	    {
	     /*| condition is = */
             value->type = ACCOND_EQUAL;
	    }
	   else
	    {
	     /* remove leading blank */
	     c = syntax;
	     while(*c==' ' && *c != '\0') c++;
	     /*"c %c\n",*c*/
	     if(*c == '=')
	      {
	       c++;
	       if(*c == '=') c++;
               value->type = ACCOND_EQUAL;
               ok= sscanf(c,"%lf", &value->value.dbl);
	      }
	     else if(*c == '<')
	      {
	       c++;
	       if(*c == '=')
		{
		 /*| condition is <= */
		 c++;
                 value->type = ACCOND_LESS_OR_EQ;
		}
	       else
		{
		 /*| condition is < */
                 value->type = ACCOND_LESS;
		}
               ok= sscanf(c,"%lf",&value->value.dbl);
	      }
	     if(!ok)
		{
		 /*| condition is string */
		 strcpy(value->value.str,c);
                 value->type = ACCOND_STRING;
		}
	     }
 return 1;
}

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             execute                              */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
    IGRint      	status;         /* routine return status */
    IGRint      	size;     /* size of GRevent buffer (struct GRevent) */
    IGRlong     	input_mask;     /* mask for GRgetevent */
    struct GRevent 	grevent1;  /* event returned by GRgetevent */
    IGRint 		resp;
    struct ret_struct 	rst;                                 
    IGRint 		i,j;
    IGRint 		token = 0;
    IGRint 		previous_size;
    struct GRid macro_def,def_col,def_occ;
    int error;
    char lib_name[80];
    struct stemp *temp_desc;
    struct sup *up_desc;
    char *c;
    int real_index;
    int index1,index2;
    double value;
    int already_defined;
    int type;
    int max_dis_col;


   
    *response = TERMINATE;
    if(!COm_condit_form_ptr) return OM_S_SUCCESS;

    size = sizeof (struct GRevent);
    input_mask  = GRm_STRING | GRm_RESET | GRm_BACK_UP; 

    /*
     *  loop until exit condition occurs
     */

   do
    {
      switch (me->action)
      {       
	 case NIL :     /*| nil */
	   break;

	 case ERR :    /*| err  */
	   ex$message( msgnumb = AS_E_InvDefRest);


	 case RESTART : /*| restart */
	   me->state = 	WAIT_MACRO;
	   me->action=  GET_MACRO;
	   me->nb_macros = 0;
	   me->Entry_Request = NOENT;
	   me->condit_name[0] = '\0';
	   rst.type = text_type;
	   rst.var.text_st.text_string[0] = '\0';
	   status = om$send(msg = message COm_condit.find_template
			          ("",&rst,1,&real_index),
			    targetid = my_id);
	   as$status();
	   me->Nb_Max_Temp = 1;
	   me->Temp_Name[0] = '\0';
	   me->Nb_Max_Feet = 0;
	   me->num_default = 0;

	   if(COm_condit_form_ptr) 
	    {
	     FIg_disable(COm_condit_form_ptr,MACRO_NAME);
	     FIg_disable(COm_condit_form_ptr,COND_VALUE);
	     FIg_disable(COm_condit_form_ptr,MACRO_TEMP);
	     FIg_disable(COm_condit_form_ptr,MACRO_FEET);
	     FIg_disable(COm_condit_form_ptr,CONDIT_NAME);
	     FIg_disable(COm_condit_form_ptr,CONDIT_COND_TEMP);
	     FIg_disable(COm_condit_form_ptr,CONDIT_TEMP);
	     FIg_disable(COm_condit_form_ptr,CONDIT_FEET);
	     status = om$send(msg = message COm_condit.write_form
							  (COm_condit_form_ptr),
			      targetid = my_id); 
	     as$status();
	    }
	   break;

	case GET_MACRO :
	   ex$message(msgnumb = AS_P_MacCondi);
	   me->Entry_Request = POINT;
	   break;

	case STO_MACRO :

	   /* Realloc some memory if necessary */

	   previous_size = om$dimension_of(varray = me->macro);
	   if(me->nb_macros >= previous_size -1)
	    { previous_size += 5;
	      status = om$vla_set_dimension(varray = me->macro,
					    size = previous_size);
	      as$status(action=RET_STATUS);
	      status = om$vla_set_dimension(varray = me->value,
					    size = previous_size);
	      as$status(action=RET_STATUS);
	      status = om$vla_set_dimension(varray = me->first_temp_def,
					    size = previous_size);
	      status = om$vla_set_dimension(varray = me->nb_temp_def,
					    size = previous_size);
	      as$status(action=RET_STATUS);
	     }

	   /* Modify number of row in the form if necessary */

	   FImcf_get_num_cols(COm_condit_form_ptr,MACRO_NAME,&previous_size);
	   /*"avant nb cols %d\n",previous_size */

	   if(previous_size <= me->nb_macros)
	    {
	     FImcf_set_num_cols(COm_condit_form_ptr,MACRO_NAME,me->nb_macros+1);
	     FIg_activate(COm_condit_form_ptr,MACRO_NAME);

	     FImcf_set_num_cols(COm_condit_form_ptr,COND_VALUE,me->nb_macros+1);
	     FIg_activate(COm_condit_form_ptr,COND_VALUE);

	     FImcf_set_num_cols(COm_condit_form_ptr,MACRO_TEMP,me->nb_macros+1);
	     FIg_activate(COm_condit_form_ptr,MACRO_TEMP);

	     FImcf_set_num_cols(COm_condit_form_ptr,MACRO_FEET,me->nb_macros+1);
	     FIg_activate(COm_condit_form_ptr,MACRO_FEET);
            }
	   FImcf_get_num_cols(COm_condit_form_ptr,MACRO_NAME,&previous_size);
	   /*"apres nb cols %d\n",previous_size */
/*^	  { int first,nb;
	   FImcf_get_view_data(COm_condit_form_ptr,MACRO_NAME,&first,&nb);
	   printf("first %d nb %d\n",first,nb);
          }  */

	   /* Display the added macro in the form */

	   FImcf_get_num_vis_cols(COm_condit_form_ptr,MACRO_NAME,&max_dis_col);
	   if(me->nb_macros>max_dis_col-1)
	    {
	     FImcf_set_active_col(COm_condit_form_ptr,MACRO_NAME,
				me->nb_macros,max_dis_col-1);
	     FImcf_set_num_vis_cols(COm_condit_form_ptr,MACRO_NAME,max_dis_col);
	     FIg_display(COm_condit_form_ptr,MACRO_NAME);
	     FImcf_set_active_col(COm_condit_form_ptr,COND_VALUE,
				me->nb_macros,max_dis_col-1);
	     FImcf_set_num_vis_cols(COm_condit_form_ptr,COND_VALUE,max_dis_col);
	     FIg_display(COm_condit_form_ptr,COND_VALUE);
	     FImcf_set_active_col(COm_condit_form_ptr,MACRO_TEMP,
				me->nb_macros,max_dis_col-1);
	     FImcf_set_num_vis_cols(COm_condit_form_ptr,MACRO_TEMP,max_dis_col);
	     FIg_display(COm_condit_form_ptr,MACRO_TEMP);
	     FImcf_set_active_col(COm_condit_form_ptr,MACRO_FEET,
				me->nb_macros,max_dis_col-1);
	     FImcf_set_num_vis_cols(COm_condit_form_ptr,MACRO_FEET,max_dis_col);
	     FIg_display(COm_condit_form_ptr,MACRO_FEET);
	    }

/*^	  { int first,nb;
	   FImcf_get_view_data(COm_condit_form_ptr,MACRO_NAME,&first,&nb);
	   printf("first %d nb %d\n",first,nb);
          }  */

	   
	   me->macro[me->nb_macros].objid = NULL_OBJID;
           status = ac$find_macro_defn( action      = ACfind_load,
                                    macro_name  = grevent1.event.keyin,
                                    p_macro_defn_id = me->macro+me->nb_macros );

           if (IF_NULL_OBJID(me->macro[me->nb_macros].objid))
             {
               ex$message( field = 2, msgnumb = AS_S_MacNotFnd );
               me->Entry_Request=NOENT;
               me->state=WAIT_MACRO;
               me->action=GET_MACRO;
               break;
             }
           else
            /*
             * Code added 03/06/92 by Prasad and Jimmy to prevent conditionals
             * from being created with macros that contain associative solids.
	     * This is done by preventing macros that can be placed in
	     * drop mode only.
             */
             {
               int         dummy,
                           tmp_num;
               struct sup *tmp_desc;

               status = om$send(msg = message ACmacro_defn.ACgive_upscan
                                      (&tmp_num,&dummy,&tmp_desc),
                                targetid = me->macro[me->nb_macros].objid,
                                targetos = me->macro[me->nb_macros].osnum);
               as$status(action = RET_STATUS);

               if (dummy & ACno_construct)
                 {
                   ex$message( field = 2, msgnumb = AS_S_InvNam );
                   me->Entry_Request=NOENT;
                   me->state=WAIT_MACRO;
                   me->action=GET_MACRO;
                   break;
                 }
             }


	     /* Add necessary template and feet in macro description +
		display corresponding col */

	   me->value[me->nb_macros].type = 0;
	   status = om$send(msg = message COm_condit.write_macro
					(COm_condit_form_ptr,me->nb_macros,1),
			      targetid = my_id); 
	   me->nb_macros += 1;
	   status = om$send(msg = message COm_condit.write_condit
					(COm_condit_form_ptr),
			      targetid = my_id); 
	   as$status();

	case GET_VALUE :   /*| Get condition value */
	   ex$message(msgnumb = AS_P_ValCondi);
	   me->Entry_Request = POINT;
	   break;

	case STO_VALUE :   /*| Store condition value */
           COm_decode(grevent1.event.keyin,me->value+me->nb_macros-1);

           /* If first construction redefine value and type of the           */
	   /* parameter that define the condition			     */
	   if(me->nb_macros == 1)
	    {
	     if(me->value[0].type & ACCOND_NUM)
	       {
	        me->Temp_Value[0].type = double_type;
		me->Temp_Value[0].var.root_pm_st.value = me->value[0].value.dbl;
	       }
	     else
	       {
	        me->Temp_Value[0].type = text_type;
		strcpy(me->Temp_Value[0].var.text_st.text_string,
		       me->value[0].value.str);
	       }
	
	    }


	   status = om$send(msg = message COm_condit.write_macro
					(COm_condit_form_ptr,me->nb_macros-1,0),
			      targetid = my_id); 
	   me->action = GET_MACRO;
           me->Entry_Request=NOENT;
	   break;

	case GET_NAME : /*| get_name */
	   ex$message(msgnumb = AS_P_NamCondi);
	   break;
	case STO_NAME : /*| sto_name */
	   strncpy(me->condit_name,grevent1.event.keyin,macro_MAX_CHAR);
	   me->condit_name[macro_MAX_CHAR-1] = '\0';
	   status = om$send(msg = message COm_condit.write_condit
					(COm_condit_form_ptr),
			      targetid = my_id); 
	   as$status();

	case GET_CONDIT : /*| get_condit */
	   ex$message(msgnumb = AS_P_NamCondiTemp);
	   break;

	case STO_CONDIT : /*| sto_condit */
	   strncpy(me->Temp_Name,grevent1.event.keyin,macro_MAX_CHAR);
	   me->Temp_Name[macro_MAX_CHAR-1] = '\0';
	   status = om$send(msg = message COm_condit.write_condit
					(COm_condit_form_ptr),
			      targetid = my_id); 
	   as$status();

	case WAIT : /*| wait */
	   ex$message(msgnumb = AS_P_ModCondi);
	   FIg_enable(COm_condit_form_ptr,COND_VALUE);
	   FIg_enable(COm_condit_form_ptr,MACRO_TEMP);
	   FIg_enable(COm_condit_form_ptr,CONDIT_NAME);
	   FIg_enable(COm_condit_form_ptr,CONDIT_TEMP);
	   FIg_enable(COm_condit_form_ptr,CONDIT_COND_TEMP);
           me->Entry_Request=POINT;
	   break;

	case GET_DEF_TEMP : /*| get_def_temp */
	   ex$message(msgnumb = AS_P_DefCondi);
           me->Entry_Request=POINT;
	   break;

	case STO_DEF_TEMP : /*| sto_def_temp */
	   i = me->first_temp_def[me->active_macro] + me->active_template;
	   already_defined = me->Temp_Def[i].type;
	   /*"default value store in %d\n",i*/
	   if(grevent1.event.keyin[0] == '\0')
	    {
	     /*| default value suppressed */
	     me->Temp_Def[i].type = 0;
	     if(already_defined)
	      if(!already_defined) me->Temp_Used[me->Temp_Def[i].index] += 1;
	     
	    }
           else if(sscanf(grevent1.event.keyin,"%lf", &value) == 1)
            {
	     /*| numeric value */
  	      me->Temp_Def[i].type = ACCOND_NUM;
	      me->Temp_Def[i].value.dbl = value;
	      if(!already_defined) me->Temp_Used[me->Temp_Def[i].index] -= 1;
	     }
	   else
	     {
	      /*" string %s\n",grevent1.event.keyin */
	      strncpy(me->Temp_Def[i].value.str,grevent1.event.keyin,
		      macro_MAX_CHAR-1);
	      me->Temp_Def[i].value.str[macro_MAX_CHAR-1] = '\0';
	      /*"def %s\n",me->Temp_Def[i].value.str */
  	      me->Temp_Def[i].type = ACCOND_STRING;
	      if(!already_defined) me->Temp_Used[me->Temp_Def[i].index] -= 1;

	     }
	   
	   status = om$send(msg = message COm_condit.write_form
							  (COm_condit_form_ptr),
			    targetid = my_id);
	   me->Entry_Request = NOENT;
	   me->action = WAIT;
	   break;
		
	case CREATE_CONDIT :   /*| create condit */

        /* Control name */

	  error = 0;
	  if(me->condit_name[0] == '\0')
	    {ex$message(msgnumb = AS_S_NamCoNotDef);error = 1;}
	  else
            {status = ac$find_macro_defn(action =  ACfind_no_load,
					 macro_name = me->condit_name,
					 p_macro_defn_id = &macro_def);
	     if(status&1)
	      {ex$message(msgnumb =AS_S_ConsExist);
	       error = 1;}
            }

	 /*| Control condition type consistency */
	  type = 0;
	  for(i=0;i<me->nb_macros;i++)
	   {
	    /*"type[%d] = %d\n",i,me->value[i].type */
	    type = type | me->value[i].type;
	   }

	 /*" global type is %x\n",type */

	  if((type&(ACCOND_STRING | ACCOND_NUM))==(ACCOND_STRING | ACCOND_NUM))
	    {
	     ex$message(msgnumb = AS_E_IncVal);
	     error = 1;
	    }
	  else if(type & ACCOND_NUM)
	     me->Temp_Value[0].type = double_type;
	     
	   
	  else if(type & ACCOND_STRING)
	    {
	     me->Temp_Value[0].type = text_type;
	    }

	  /*"type[0] is %x\n",type */

          /* Control that all the macros are in the same OS */
	    
	  ac$construct_wd(mode = AC_INQ,
			  name = lib_name,
			  dir = &macro_def,
			  name_size = 80);

          for(i=0;i<me->nb_macros;i++)
           {
	    if(me->macro[i].osnum != macro_def.osnum)
	     {
	      ex$message(msgnumb = AS_E_MacSameOs);
	      error = 1;
	      break;
             }
           }
		
	  if(error) {me->Entry_Request = NOENT;
		     me->action = WAIT; 
                     FIg_set_state(COm_condit_form_ptr,FORM_EXEC,0);
		     break;}

          { extern int ACauto_save;
            int save_save;

          save_save = ACauto_save;
          ACauto_save = 0;

	  status = om$construct(classid = OPP_ACcond_def_class_id,
				osnum =  macro_def.osnum,
				p_objid = &macro_def.objid);
          as$status(action = RET_STATUS);

	  up_desc = (struct sup *)
			 om$malloc(size = me->Nb_Max_Temp*sizeof(struct sup));
          if(up_desc == NULL) return(OM_W_ABORT);

	  temp_desc = (struct stemp *)
			 om$malloc(size = me->Nb_Max_Temp*sizeof(struct stemp));

          if(temp_desc == NULL) return(OM_W_ABORT);

	  /* Initialize template of the conditional */

	  c = me->Temp_Name;
	  j = 0;
	  for(i=0;i<me->Nb_Max_Temp;i++)
	   {
	    if(me->Temp_Used[i])
	     {
	      strncpy(up_desc[j].prompt,c,macro_MAX_CHAR-1);
	      up_desc[j].prompt[macro_MAX_CHAR-1] = '\0';
	      strcpy(up_desc[j].up_scan,".");
	      up_desc[j].type = me->Temp_Value[i].type;

	      strncpy(temp_desc[j].name,c,macro_MAX_CHAR-1);
	      temp_desc[j].name[macro_MAX_CHAR-1] = '\0';
	      strcpy(temp_desc[j].down_scan,".");
	      temp_desc[j].back = j;
	      temp_desc[j].type = me->Temp_Value[i].type;
	      j++;
	     }
	    c += macro_MAX_CHAR;
           }
	  me->Nb_Max_Temp = j;
	 
	  status = om$send(msg = message ACcond_def.ACtake_template
				 (me->Nb_Max_Temp,up_desc,
				  me->Nb_Max_Temp,temp_desc),
			   targetid = macro_def.objid,
			   targetos = macro_def.osnum);
          as$status(action = RET_STATUS);

	  om$dealloc(ptr = up_desc);
	  om$dealloc(ptr = temp_desc);


	  /* feet description now */

	 { int index;
	  status = om$send(msg = message ACcond_def.ACtake_feet
				      (me->Nb_Max_Feet,me->Feet_Name,&index),
			   targetid = macro_def.objid,
			   targetos = macro_def.osnum);
          as$status(action = RET_STATUS);
         }
		


          /* condition description and default value now */

	  /* compress default value array */
          index1 = index2 = 0;
	  for(i=0;i<me->nb_macros;i++)
           {
            /*"compress def %d index1 %d index2 %d\n",i,index1,index2*/
	    me->first_temp_def[i] = index2;
	    for(j=0;j<me->nb_temp_def[i];j++,index1++)
	      {
	       if(me->Temp_Def[index1].type)
		 {
		  me->Temp_Def[index2] = me->Temp_Def[index1];
		  me->Temp_Def[index2++].index = j;
		 }
	      }
	    me->nb_temp_def[i] = index2 - me->first_temp_def[i];
	    /*"nb_def %d\n",me->nb_temp_def[i] */
           }

  	  status = om$send(msg = message ACcond_def.ACtake_condit
			     (me->condit_name,me->nb_macros,me->macro,me->value,
			      me->nb_temp_def,me->Temp_Def),
			   targetid = macro_def.objid,
			   targetos = macro_def.osnum);
          as$status(action = RET_STATUS);


          /* Create now default template if any */

          ac$create_def_temp(search_option = me->hdr_def,
                             search_path = me->search_path,
                             symbology = me->hdr_symb,
                             hdr_type = me->hdr_type,
                             hdr_scroll = me->hdr_scroll,
                             macro = &macro_def,
                             def_col = &def_col,
                             temp_val = me->Temp_Value);

	 /* jla jan 93 : create a default occurence containing the feet of the
	    first construction entriing the macro plus elements to store 
	    symbology of feet coming from following occurences 
	    a good part of it should go in the method ACcreate_default of the
	    class ACcond_def. But dynamics load ......
	 */

	 {
	  long loc_msg;
	  struct GRid mac_def_foot,*clone_list,def_mac;
	  extern IGRboolean ASbroadcast_in_progress;
	  extern GRclassid OPP_ACconst_class_id; /*OPP_GRvg_class_id; */
	  IGRboolean br_save;
	  struct GRmd_env lib_env;

	  clone_list = (struct GRid *) om$malloc
				   (size = me->Nb_Max_Feet*sizeof(struct GRid));
	  if(!clone_list) return OM_W_ABORT;
	  ACbuild_env(macro_def.osnum,&lib_env);
	  lib_env.md_id.objid = NULL_OBJID;

	  br_save = ASbroadcast_in_progress;
	  ASbroadcast_in_progress = TRUE;
	  for(i=0;i<me->Nb_Max_Feet;i++) 
	    { 

	      mac_def_foot.objid = me->Feet_Defid[i];
	      mac_def_foot.osnum = macro_def.osnum;
	      clone_list[i].osnum = macro_def.osnum;

	      if(mac_def_foot.objid == NULL_OBJID)
				clone_list[i].objid = NULL_OBJID;
	      else if (me->Feet_Firstm[i] == 0)
	       {
		status = om$send(msg = message GRgraphics.GRcopy
				(&loc_msg,&lib_env,&lib_env,
				 &clone_list[i].objid),
				targetid = mac_def_foot.objid,
				targetos = mac_def_foot.osnum); 
	       }
	      else
	       {
		status = om$construct(classid = OPP_ACsymb_hold_class_id,
				      osnum = mac_def_foot.osnum,
				      p_objid = &clone_list[i].objid);
		if(status&1) ACtrans_symb(mac_def_foot,clone_list[i]);
		else clone_list[i].objid = NULL_OBJID;
	       }
	       
	    }
	  ASbroadcast_in_progress = br_save;


	  /* create the occurence */

	  status = om$construct(osnum = def_col.osnum,
		       classid = OPP_ACconst_class_id,
		       p_objid = &def_mac.objid);
	  def_mac.osnum = macro_def.osnum;
	  as$status(action = RET_STATUS);

 	  status = om$send(msg = message ACncpx.ACload_macro(macro_def),
		  	   targetid = def_mac.objid,
		  	   targetos = def_mac.osnum);
 	  status = om$send(msg = message ACncpx.ACchange_feet
					(me->Nb_Max_Feet,clone_list,
					 &me->ModuleInfo),
		  	   targetid = def_mac.objid,
		  	   targetos = def_mac.osnum);
 	  as$status();

          status = om$send(msg = message ACdiowner.ACadd_component_with_name
					(&loc_msg,&def_mac,"~~occurence"),
                      senderid = NULL_OBJID,
                      targetid = def_col.objid,
                      targetos = def_col.osnum);
          as$status();
	  if(clone_list) om$dealloc(ptr = clone_list);
	 }


          /* Tell the user that the macro has been created and where */
          ACauto_save = save_save;

          if(ACauto_save && macro_def.osnum != me->ModuleInfo.md_id.osnum)
           { ac$save_wd();
            ex$message(msgnumb = AS_S_MacWri,type = "%s%s",
                       var = `me->condit_name,lib_name`);
           }
          else
           {
            ex$message(msgnumb = AS_S_MacCrea,type = "%s%s",
                       var = `me->condit_name,lib_name`);
           }
         }
	 

          FIg_set_state(COm_condit_form_ptr,FORM_EXEC,0);
	  me->action = RESTART;
	  me->Entry_Request = NOENT;

          break;
	
      }   /* end switch (me->state) */


    switch( me->Entry_Request)
    {
     case POINT :  /*| PROMPT */
          token = GRget_token(&status,TokenList,&input_mask,&grevent1,
                	      &size,&resp,response_data);
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

end implementation COm_condit;
