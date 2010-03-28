class implementation COm_condit;

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
#include "nddef.h"
#include "ndmacros.h"


#define AS_DEBUG
from expression import list;
from ACmacro_defn import ACgive_name,ACgive_upscan,ACgive_feet_desc;
from NDmacro import ACgive_structure,ACreturn_foot;

extern char *COm_condit_form_ptr;

method write_form (char *fp)
{
int status;
int col,row,row_temp,row_feet,nb_col;

/*" Display each construction %d\n",me->nb_macros */

/*  FImcf_set_num_cols(fp,MACRO_NAME,me->nb_macros);
/*  FImcf_set_num_cols(fp,COND_VALUE,me->nb_macros);
/*  FImcf_set_num_cols(fp,MACRO_TEMP,me->nb_macros);
/*  FImcf_set_num_cols(fp,MACRO_FEET,me->nb_macros);
/***/
/*| avant loop */

  for(col=0;col<me->nb_macros;col++)
    {
     status = om$send(msg = message COm_condit.write_macro(fp,col,0),
		      targetid = my_id);
    }

/* Erase the other colomn */
  FImcf_get_num_cols(fp,MACRO_NAME,&nb_col);
  FIfld_get_num_rows(fp,MACRO_TEMP,&row_temp);
  FIfld_get_num_rows(fp,MACRO_FEET,&row_feet);
  for(col=me->nb_macros;col<nb_col;col++)
   {
     FIfld_set_text(fp,MACRO_NAME,0,col,"",FALSE);
     FIfld_set_text(fp,COND_VALUE,0,col,"",FALSE);
     for(row=0;row<row_temp;row++)
	{
         FIfld_set_text(fp,MACRO_TEMP,row,col,"",FALSE);
	}
     for(row=0;row<row_feet;row++)
	{
         FIfld_set_text(fp,MACRO_FEET,row,col,"",FALSE);
	}
   }

/* Display condit */

  status = om$send(msg = message COm_condit.write_condit(fp),
		   targetid = my_id);
     
return(OM_S_SUCCESS);
}

method write_condit(char *fp)
{
 int i_temp,i_feet,row;
 char *c;
 char text[80];

 /*"condit name %s\n",me->condit_name*/
 FIfld_set_text(fp,CONDIT_NAME,0,0,me->condit_name,FALSE);

 c = me->Temp_Name;
 row = 0; 
 
 for(i_temp=0 ; i_temp<me->Nb_Max_Temp ; i_temp++,c+=macro_MAX_CHAR)
   {
    /*"i_temp %d used %d name %s\n",i_temp,me->Temp_Used[i_temp],c*/
    if(me->Temp_Used[i_temp] > 0)
     {
      /*"template type %d\n",me->Temp_Value[i_temp].type */
      if(me->Temp_Value[i_temp].type == double_type)
         {
      	  sprintf(text,"%g",me->Temp_Value[i_temp].var.root_pm_st.value);
	  /*"value %lf\n",me->Temp_Value[i_temp].var.root_pm_st.value*/
	 }
      else if(me->Temp_Value[i_temp].type == text_type)
      	        strcpy(text,me->Temp_Value[i_temp].var.text_st.text_string);
      else text[0] = '\0';
      FIfld_set_text(fp,CONDIT_TEMP,row,0,c,FALSE);
      FIfld_set_text(fp,CONDIT_TEMP,row++,1,text,FALSE);
     }
    else
     {
      FIfld_set_text(fp,CONDIT_TEMP,row,0,"",FALSE);
      FIfld_set_text(fp,CONDIT_TEMP,row++,1,"",FALSE);
     }

  if(me->Nb_Max_Temp>0) 
    FIfld_set_text(fp,CONDIT_COND_TEMP,0,0,me->Temp_Name,FALSE);
    
      
   }

 FIfld_set_num_rows(fp,CONDIT_TEMP,row);

 c = me->Feet_Name;
 for(i_feet=0 ; i_feet<me->Nb_Max_Feet ; i_feet++,c+=macro_MAX_CHAR)
   {
    FIfld_set_text(fp,CONDIT_FEET,i_feet,0,c,FALSE);
   }
 FIfld_set_num_rows(fp,CONDIT_FEET,me->Nb_Max_Feet);

return(OM_S_SUCCESS);
}

method write_macro(char *fp;int col;int add_it)
{
int status,msg,previous_size;
int row;
char text[80];
char *c;
char *macro_name;

int feet_num,temp_num,i_feet,i_temp,real_index;
int index;
struct myfeet *feet_desc;
struct sup  *temp_desc;
struct GRid default_id;
int dummy;

     /* Print macro name */
     status = om$send(msg = message ACmacro_defn.ACgive_name(&macro_name),
		      targetid = me->macro[col].objid,
		      targetos = me->macro[col].osnum);
     as$status(action = RET_STATUS);
     FIfld_set_text(fp,MACRO_NAME,0,col,macro_name,FALSE);

     /*" Print condition value %d\n",me->value[col].type */

     ACprint_condition(me->value+col,text);

     FIfld_set_text(fp,COND_VALUE,0,col,text,FALSE);
     

     /* Print macro template */
     status = om$send(msg = message ACmacro_defn.ACgive_upscan
					(&temp_num,&dummy,&temp_desc),
		      targetid = me->macro[col].objid,
		      targetos = me->macro[col].osnum);
     as$status(action = RET_STATUS);

   /* reserve space for default template */
     if(add_it)
      {
       /*| initialize space for default template */
       me->first_temp_def[me->nb_macros] = me->num_default;
       me->nb_temp_def[me->nb_macros] = temp_num;
       previous_size = om$dimension_of(varray = me->Temp_Def);
       if(me->num_default + temp_num >= previous_size-1)
        {
         previous_size = me->num_default + temp_num;
         status = om$vla_set_dimension(varray = me->Temp_Def,
				     size = previous_size);
	}

        /*| get default template directory if any */

	COm_get_option_grid(me->macro+col,&default_id,NULL);
      }

     index = me->first_temp_def[col];
     for(i_temp=0;i_temp<temp_num;i_temp++,index++)
       {
	struct ret_struct def_rst;

	/* Initialize default value */
	if(add_it)
	 {
	  def_rst.type = temp_desc[i_temp].type;
	  if(def_rst.type == double_type)
				def_rst.var.root_pm_st.value = 0;
	  else if(def_rst.type == text_type)
				def_rst.var.text_st.text_string[0] = '\0';
	  if(default_id.objid != NULL_OBJID)
	  {
	   status = om$send(msg = message NDmacro.ACgive_structure
					(&msg,&dummy,temp_desc[i_temp].prompt,
					 &def_rst,&me->ModuleInfo),
			    targetid = default_id.objid,
			    targetos = default_id.osnum);
	   /*^if(def_rst.type == double_type)
	       printf("def_value %lf\n",def_rst.var.root_pm_st.value);
	   */
	
	  }
					
	 }
	/*" find matching conditional template %s %d\n",temp_desc[i_temp].prompt,temp_desc[i_temp].type */
	status = om$send(msg = message COm_condit.find_template
		     (temp_desc[i_temp].prompt,&def_rst,add_it,&real_index),
				  targetid = my_id);
        /*"real_index %d\n",real_index*/
        if(real_index<0) return (OM_W_ABORT);
	row = real_index;

	/* Initialize template index */
        if(add_it)
         {
          me->Temp_Def[me->num_default].index = real_index;
          me->Temp_Def[me->num_default++].type = 0;
         }

	/*| Print also default value if necessary */

	 strcpy(text,temp_desc[i_temp].prompt);
	 c = text+strlen(text);
	 if(me->Temp_Def[index].type == ACTEMP_NUM)
           {
	    /*"%d num\n"*/
	    sprintf(c,"=%lf",me->Temp_Def[index].value.dbl);
	   }
	  else if(me->Temp_Def[index].type == ACTEMP_STRING)
           {
	    /*"%d string %s\n",row,me->Temp_Def[index].value.str*/
	    *c='=';
	    strcpy(c+1,me->Temp_Def[index].value.str);
	   }
         FIfld_set_text(fp,MACRO_TEMP,row,col,text,FALSE);
       }

     /* Print macro feet */
     status = om$send(msg = message ACmacro_defn.ACgive_feet_desc
					(&feet_num,&feet_desc),
		      targetid = me->macro[col].objid,
		      targetos = me->macro[col].osnum);
     for(i_feet=0;i_feet<feet_num;i_feet++)
       {
	/* find matching conditional feet */
	status = om$send(msg = message COm_condit.find_feet
				     (feet_desc[i_feet].name,add_it,&row),
			 targetid = my_id);
	if(row<0) return(OM_W_ABORT);
        FIfld_set_text(fp,MACRO_FEET,row,col,feet_desc[i_feet].name,FALSE);
       }

return(OM_S_SUCCESS);
}

method find_template(char *name;struct ret_struct *rst; int add_it,*real_index) 
{
 int i,index,previous_size,status;
 char *c;

/*" Try to find the name %s type %d  add %d\n",name,rst->type,add_it */

 c= me->Temp_Name;
 index = 0;
 for(i=0 ; i<me->Nb_Max_Temp ; i++,c+=macro_MAX_CHAR)
   {
    if (strncmp(c,name,macro_MAX_CHAR) == 0)
       {
	me->Temp_Used[i] += add_it;
	*real_index = i;
	break;
       }
    if(me->Temp_Used[i]) index++;
   }

/*| Add it if possible */

 if(i>=me->Nb_Max_Temp) 
 {
  if(add_it)
  {
   previous_size = om$dimension_of(varray = me->Temp_Used);
     if(me->Nb_Max_Temp >= previous_size-1)
      {
       previous_size += 5;
       status = om$vla_set_dimension(varray = me->Temp_Name,
				     size = previous_size*macro_MAX_CHAR);
       status = om$vla_set_dimension(varray = me->Temp_Used,
				     size = previous_size);
       status = om$vla_set_dimension(varray = me->Temp_Value,
				     size = previous_size);
      }
   strncpy(me->Temp_Name+me->Nb_Max_Temp*macro_MAX_CHAR,name,macro_MAX_CHAR);
   me->Temp_Name[me->Nb_Max_Temp*macro_MAX_CHAR+macro_MAX_CHAR-1] = '\0';
  
   me->Temp_Value[me->Nb_Max_Temp] = *rst;
   me->Temp_Used[me->Nb_Max_Temp] = 1;
   *real_index = me->Nb_Max_Temp;
   me->Nb_Max_Temp += 1;
  }
  else *real_index = -1;
 }


/*"real_temp %d  used %d\n",*real_index,me->Temp_Used[*real_index] */

 return OM_S_SUCCESS;
}

method find_feet(char *name; int add_it, *visible_index) 
{
 int i,previous_size,status;
 char *c;
 

/*" Try to find feet %s\n",name */

 c= me->Feet_Name;
 for(i=0 ; i<me->Nb_Max_Feet ; i++,c+=macro_MAX_CHAR)
   {
    if (strncmp(c,name,macro_MAX_CHAR) == 0)
      { *visible_index = i; break; }
   }

/* add it if possible */

 if(i>= me->Nb_Max_Feet)
  {
   if(add_it)
    {
     previous_size = om$dimension_of(varray = me->Feet_Defid);
     if(me->Nb_Max_Feet >= previous_size-1)
      {
       previous_size += 5;
       status = om$vla_set_dimension(varray = me->Feet_Name,
                                     size = previous_size*macro_MAX_CHAR);
       status = om$vla_set_dimension(varray = me->Feet_Defid,
                                     size = previous_size);
       status = om$vla_set_dimension(varray = me->Feet_Firstm,
                                     size = previous_size);
       as$status(action=RET_STATUS);

      }
     /* store information about the new added foot */
     strncpy(me->Feet_Name+me->Nb_Max_Feet*macro_MAX_CHAR,name,macro_MAX_CHAR);
     me->Feet_Name[me->Nb_Max_Feet*macro_MAX_CHAR+macro_MAX_CHAR-1] = '\0';

     /* jla jan 93 : store from which macro the foot comes and also its id
        in the corresponding default occurence
     */

    me->Feet_Firstm[me->Nb_Max_Feet] = me->nb_macros;

    {
     int symb;
     long loc_msg;
     enum ACm_poss_hdr hdr_type;
     enum ACm_poss_scroll hdr_scroll;
     enum ACm_poss_def_par hdr_def;
     char search_path[DI_PATH_MAX],post_placement[DI_PATH_MAX];
     struct GRid def_occ,foot_grid;

     def_occ.objid = NULL_OBJID;
     COm_get_options(me->macro+me->nb_macros,&symb,&hdr_scroll,&hdr_type,
		&hdr_def,search_path,post_placement,&def_occ,&me->ModuleInfo);
     if(def_occ.objid != NULL_OBJID)
      {
       status = om$send(msg = message NDmacro.ACreturn_foot(&loc_msg,name,
				&foot_grid,NULL,NULL),
		  	targetid = def_occ.objid,
		  	targetos = def_occ.osnum);
       if(status&loc_msg&1) 
		 me->Feet_Defid[me->Nb_Max_Feet] = foot_grid.objid; 
       else      me->Feet_Defid[me->Nb_Max_Feet] = NULL_OBJID;
      }
    }

     *visible_index  = me->Nb_Max_Feet;
     me->Nb_Max_Feet += 1;
    }
   else *visible_index = -1;
  }
/*"visible index %d\n",*visible_index*/
 return OM_S_SUCCESS;
}

ACprint_condition(condition,text)
struct ACcond_val *condition;
char *text;
{
 char *c = NULL;

 text[0] = '\0';
 if(condition->type == ACCOND_STRING) strcpy(text,condition->value.str);

 else if(condition->type & ACCOND_NUM)
   {
    if(condition->type == ACCOND_EQUAL)
      { c=text;}
    else if(condition->type == ACCOND_LESS)
      { text[0] = '<';c = text+1;}
    else if(condition->type == ACCOND_LESS_OR_EQ)
      { text[0] = '<'; text[1] = '='; c = text+2;}
    sprintf(c,"%lf",condition->value.dbl);
   }
 return 1;
}

end implementation COm_condit;
