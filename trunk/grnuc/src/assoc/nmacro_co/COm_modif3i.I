/*
     jla  23_sep_86 : Design date
     jla  04-nov-86 : Associative implementation
*/

class implementation COm_modif;

#include <stdio.h>
#include "coparadef.h"
#include "expression.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "msmacros.h"
#include "ASmessages.h"
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
#include "ACattrib.h"

#define  AS_DEBUG  1


from ACmacro_defn import ACgive_upscan,ACtake_template;
from ACdiowner import ACmod_attribute, ACadd_attribute_by_type,ACrem_attribute;
from NDmacro import ACgive_structure;
from GRgraphics import GRdelete;
from GRvg import GRgetname;

%safe
static IGRint TokenList[] =
 		      {
			STRING,
			GR_UNKNOWN_TYPE ,
		      };


static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = {

/*            ****************** TOKENS ***********
   Old State  *    STRING  , UNKNOWN */

/* WAIT_DEF   */ { WAIT_MOD, WAIT_DEF },
/* WAIT_MOD   */ { WAIT_MOD, WAIT_MOD }};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = {

/*            *************TOKENS ********************
   Old State  *     STRING     , UNKNOWN */

/* WAIT_DEF   */ { STO_NAME    , LOC_MAC   }, 
/* WAIT_MOD   */ { LOC_FORM    , LOC_FORM  }};
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
    IGRlong     	input_mask;     /* mask for GRgetevent */
    IGRlong     	msg;            /* function return code */
    struct GRevent 	grevent1;  /* event returned by GRgetevent */
    IGRint 		resp;
    IGRint 		i,j;
    IGRint 		token=0;
    struct ret_struct rst;
    int dummy;
    OMuint nb_comp;

    struct GRid opt;
    char dummy_post_placement[80];
    struct GRid dummy_def_hdr;

    extern ACauto_save;
    char lib_name[80];
    struct GRid construct_dir;

    char opt_name[DI_PATH_MAX];
    char *c, *c1, *strrchr();
   
    status = OM_S_SUCCESS;
    if(!me->form_ptr) return OM_S_SUCCESS;

    input_mask  = GRm_STRING | GRm_RESET ; 

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
	   me->state = WAIT_DEF;
	   me->action= LOC_MAC;
	   me->Nb_Max_Temp = 0;
	   me->Nb_Max_Opt = 0;
	   me->Entry_Request = NOENT;
	   me->macro_name[0] = '\0';
	   me->def_name[0] = '\0';
	   me->search_path[0] = '\0';
	   if(me->form_ptr) 
	    {
	     status = om$send(msg = message COm_modif.write_form (),
			      targetid = my_id); 
	     as$status();
	    }
	   break;


        case LOC_MAC :    /*| loc obj */
	   ex$message(msgnumb = AS_P_KeyMacDefMod);
	   me->Entry_Request = POINT; 
	   break;

	case STO_NAME :
	   strcpy(me->macro_name,response_data) ;

	case STO_MAC :   /*| sto_obj */

	    c = strrchr(me->macro_name,'$');
	    if(c)
	    {
	     strcpy(me->def_name,me->macro_name);
	     strcpy(me->initial_def_name,me->macro_name);
	     *c = '\0';
	    }
            status = ac$find_macro_defn( action	= ACfind_load,
		       	    	    macro_name  = me->macro_name,
		            	    p_macro_defn_id 	= &me->macro_id );

            if (IF_NULL_OBJID(me->macro_id.objid))
               {  
                 ex$message( field = 2, msgnumb = AS_S_MacNotFnd );
                 me->Entry_Request=NOENT;
	         me->state=WAIT_DEF;
	         me->action=LOC_MAC;
	         break;
               }
        
	    /*| Take the description of the macro */

	    status = om$send(msg = message ACmacro_defn.ACgive_upscan
		             (&me->Nb_Max_Temp,&dummy,&me->dup),
	                   targetid = me->macro_id.objid, 
			   targetos = me->macro_id.osnum );
	    as$status(msg = "Unable to get macro Temp_Desc");


	    /* Get default parameter if any */

	    if(!c)
             {
	      char tmp_name[DI_PATH_MAX];
	      COm_get_option_grid (&me->macro_id,&me->def_id,tmp_name);
	      c = strrchr(tmp_name,':');
	      if(c) c++;
	      else c = tmp_name;
	      strcpy(me->initial_def_name,c);
	      strcpy(me->def_name,c);
	     }
	    else
	     { 
	      char tmp_name[DI_PATH_MAX];
   	      di$give_pathname(osnum = me->macro_id.osnum,
                           pathname = tmp_name);

	      c = strrchr(me->def_name,':');
	      if(c) c++;
	      else c = me->def_name;

   	      sprintf(tmp_name,"%s:constructs:%s",tmp_name,c);

		
	      me->def_id.objid = NULL_OBJID;
	      status =  di$translate(objname = tmp_name,
			   	p_objid = &me->def_id.objid,
			   	p_osnum = &me->def_id.osnum);
	       
	     }


	    /* Get placement options like symbology, level ... */

	    if(me->def_id.objid != NULL_OBJID)
	    COm_get_options_bis(&me->macro_id,&me->def_id,
		   &me->hdr_symb,&me->hdr_scroll,&me->hdr_type,
		   &me->hdr_def,me->search_path,dummy_post_placement,
		   &dummy_def_hdr,
		   &me->ModuleInfo);

	    /* Get default values */

	    status = om$send(msg = message COm_modif.realloc_template
						(me->Nb_Max_Temp),
			     targetid = my_id);
	    for(i=0;i<me->Nb_Max_Temp;i++)
	     {
	      if(me->dup[i].type & parameter_generic)
	       {
		status = om$send(msg = message NDmacro.ACgive_structure
				((int *)&msg,NULL,me->dup[i].prompt,
				 me->Temp_Value+i,
				 &me->ModuleInfo),
				 targetid = me->def_id.objid,
				 targetos = me->def_id.osnum);
		if(!(status&msg&1))
		 {
		  me->Temp_Value[i].var.root_pm_st.value = 0;
		  if(me->dup[i].type == text_type)
		    me->Temp_Value[i].var.text_st.text_string[0] ='\0';
		 }
	       }
	      me->Temp_Value[i].type = me->dup[i].type;
	     }

	    /* get other options */

	    me->Nb_Max_Opt = 0;
  	    for(i=0;i<10000;i++)
   	     {
	      status = om$send(msg = message COm_modif.realloc_opt
					(me->Nb_Max_Opt+1),
			       targetid = my_id);

    	      status = COm_is_optional(&me->def_id,i,&opt,opt_name,
			     me->Opt_Value+me->Nb_Max_Opt,
			     me->dup,me->Nb_Max_Temp,&me->ModuleInfo);
     	      if(!(status&1)) break;
    	      if(opt.objid == NULL_OBJID) continue;

    	      c = strrchr(opt_name,':');
	      if(c) c++;
	      else c = opt_name;
	      strncpy(me->Opt_Name + me->Nb_Max_Opt*OPT_LEN,c,OPT_LEN); 
	      me->Opt_Name[(me->Nb_Max_Opt+1)*OPT_LEN -1] = '\0';
	      me->Nb_Max_Opt++;
	    }
	      
	    /* write the form */
	    status = om$send(msg = message COm_modif.write_form(),
			     targetid = my_id);


	case LOC_FORM :
	   ex$message(msgnumb = AS_P_ModMacDef);
	   break;

	case MODIFY :   /*| grap print */
	    if(strcmp(me->def_name,me->initial_def_name))
	     { 
	       /* Make sure that the name is a full tree name */
	      
	       status = om$send(msg= message GRvg.GRgetname
					(&msg,me->macro_name),
				targetid = me->macro_id.objid,
				targetos = me->macro_id.osnum);
	       c = strrchr(me->macro_name,':');
	       if(c) c++;
	       else  c = me->macro_name;
	       c1 = strrchr(me->def_name,':');
	       if(c1) c1++;
	       else   c1 = me->def_name; 
	       strcpy(c,c1);
	       COm_create_def_box
			       (me->macro_name,me->macro_id.osnum,&me->def_id);
	     }

	      /* Create or modify now default template and placement option */

	      ACmodify_def_temp(me->hdr_def,me->search_path,me->hdr_symb,
                  	     me->hdr_type,me->hdr_scroll,
                  	     &me->macro_id,&me->def_id,me->Temp_Value);

	  /* Delete other options that are no longer there */

	    status = om$get_channel_count(objid = me->def_id.objid,
					  osnum = me->def_id.osnum,
					  p_chanselect = &AS_to_comp,
					  count = &nb_comp);
	    if(!(status&1)) nb_comp = 0;
  	    for(i=nb_comp-1;i>=0;i--)
   	     {
    	      status = COm_is_optional(&me->def_id,i,&opt,opt_name,
			     &rst,
			     me->dup,me->Nb_Max_Temp,&me->ModuleInfo);
     	      if(!(status&1)) break;
    	      if(opt.objid == NULL_OBJID) continue;
    	      c = strrchr(opt_name,':');
	      if(c) c++;
	      else c = opt_name;

	      for(j=0;j<me->Nb_Max_Opt;j++)
	       {if(!strcmp(c,me->Opt_Name+j*OPT_LEN)) break;}

	      if(j>=me->Nb_Max_Opt)
	       { /*" deleting %s\n",opt_name */
		 status = om$send(msg = message ACdiowner.ACrem_attribute
							(&msg,c),
				  targetid = me->def_id.objid,
				  targetos = me->def_id.osnum);
		 as$status();
	       }
	     }

	   /* add or modify now new attrib */
	   for(i=0;i<me->Nb_Max_Opt;i++)
	    {
             status=COm_mod_or_add_attribute(me->Opt_Name+i*OPT_LEN,
					     me->Opt_Value+i,&me->def_id);
	    }
	    

	  /* save the modification */

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
	  FIg_set_state(me->form_ptr,FORM_EXEC,0);

	  /* restart the command */
 

	  me->action = RESTART;
	  me->Entry_Request = NOENT;
	  break;
	
      }   /* end switch (me->action) */


    switch( me->Entry_Request)
    {
     case POINT :  /*| PROMPT */
          token = GRget_token(&status,TokenList,&input_mask,&grevent1,
                	      &event_size,&resp,response_data);
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

  previous_size = om$dimension_of(varray = me->Temp_Value);
  if(nb_template > previous_size)
   {
     previous_size = 20*(nb_template/20 +1);
                status = om$vla_set_dimension(varray = me->Temp_Value,
                                                  size = previous_size);
                as$status(action = RET_STATUS);
   }
  return OM_S_SUCCESS;
}

ACmodify_def_temp(search_option,search_path,symbology,
                  hdr_type,hdr_scroll,
                  macro,def_temp,temp_value)
enum ACm_poss_def_par search_option;
char *search_path;
int symbology;
enum ACm_poss_hdr hdr_type;
enum ACm_poss_scroll hdr_scroll;
struct GRid *macro,*def_temp;
struct ret_struct *temp_value;
{
 long status;
 int i,Nb_Max_Temp,dum;
 struct sup *dup;
 struct ret_struct rst;
 
 /* Retrieve macro definition and its template description */

 status = om$send(msg = message ACmacro_defn.ACgive_upscan
                             (&Nb_Max_Temp,&dum,&dup),
                  senderid = NULL_OBJID,
                  targetid = macro->objid,
                  targetos = macro->osnum );
 as$status(msg = "Unable to get macro Temp_Desc",action = RET_STATUS);


 /* edit default values */

   for(i=0 ; i<Nb_Max_Temp ; i=i+1)
    { 
     /*"tem %d type %x\n",i,temp_value[i].type*/
     if(temp_value[i].type & dup[i].type & parameter_generic)
      {
       /*"Modify the attributes to the owner %d\n",def_temp->objid*/
       status=COm_mod_or_add_attribute(dup[i].prompt,temp_value+i,def_temp);
        as$status();
      }
     }

  if(search_option == USER_SPECIFIED)
   {
    /*" add search path >>%s<<\n",search_path */
    strcpy(rst.var.text_st.text_string,search_path);
    rst.type = text_type;
    status=COm_mod_or_add_attribute("~~search_path",&rst, def_temp);
    as$status();
   }

  /*"sym %d scroll %d type %d\n",symbology,hdr_scroll,hdr_type*/
  rst.var.root_pm_st.value = symbology + (hdr_scroll<<4) + (hdr_type<<6);
  rst.type = double_type;
  status=COm_mod_or_add_attribute("~~symbology",&rst,def_temp);
  as$status();
  return OM_S_SUCCESS;
}

COm_mod_or_add_attribute(name,temp_value,box)
char *name;
struct ret_struct *temp_value;
struct GRid *box;
{
long status,msg;
char syntax[80];
int att_type;

     if(temp_value->type & parameter_generic)
      {
       if(temp_value->type == double_type)
         {
          sprintf(syntax,"%20.9lf",temp_value->var.root_pm_st.value);
	  att_type = AC_ATTRIB_DOUBLE;
	 }
       else
         {
	  strcpy(syntax,temp_value->var.text_st.text_string);
	  att_type = AC_ATTRIB_TEXT;
         }
	
       status = om$send(msg      = message ACdiowner.ACmod_attribute
                                   (&msg,name,syntax),
		      senderid = NULL_OBJID,
  	              targetid = box->objid,
                      targetos = box->osnum);
        as$status();

        if(!(status&msg&1))
       status = om$send(msg      = message ACdiowner.ACadd_attribute_by_type
                                   (&msg,att_type,name,syntax),
		      senderid = NULL_OBJID,
  	              targetid = box->objid,
                      targetos = box->osnum);
      }
 if(status&msg&1) return OM_S_SUCCESS;
 else		  return OM_W_ABORT;
}

method realloc_opt(int nb_opt)
{
 long status;
 int previous_size;

  previous_size = om$dimension_of(varray = me->Opt_Value);
  if(nb_opt > previous_size)
   {
     previous_size = 20*(nb_opt/20 +1);
     status = om$vla_set_dimension(varray = me->Opt_Value,
                                   size = previous_size);
     as$status(action = RET_STATUS);

     status = om$vla_set_dimension(varray = me->Opt_Name,
                                   size = previous_size*OPT_LEN);
     as$status(action = RET_STATUS);
   }
  return OM_S_SUCCESS;
}
end implementation COm_modif;
