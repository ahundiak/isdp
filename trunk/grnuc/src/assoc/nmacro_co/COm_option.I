class implementation COm_place;

#include "nddef.h"
#include "OMmacros.h"
#include "coparadef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "expmacros.h"
#include "ASmessages.h"
#include "madef.h"
#include "ACattrib.h"
#include "asbox.h"
#include "ACcondit.h"
#include "grerr.h"
#include "acmacros.h"


#define AS_DEBUG

#define ATT_FORM_NAME   "~~form_name"
#define ATT_TEMP_LIST   "~~temp_list"

from GRvg    import GRchglevel,GRchgcolor,GRchgweight,GRchgstyle,GRgetsymb;
from NDmacro import ACgive_structure,ACreturn_foot,ACcopy_to_Groot;
from GR3dpoint import GRaltconstruct;
from ACdiowner import ACcreate,ACadd_component,ACadd_attribute_by_type,
		      ACadd_component_with_name;
from NDnode  import NDgive_structure, ASreturn_go, NDchg_state;
from ACmacro_defn       import ACgive_upscan,ACcreate_default;
from ACcond_def         import ACgive_condit_desc, ACfind_rep;
from    ACrg_collect    import  ACset_list_attribute;
from    ACrg_collect    import  AClist_attribute;
from    ACdiowner       import  ACrem_attribute;
from    ACdiowner       import  ACmod_attribute;
from GRvg import GRgetname;

char *strrchr();

extern GRclassid OPP_ACcond_def_class_id, OPP_ASsource_class_id,
		 OPP_ACncpx_class_id,OPP_ACheader_class_id;

%safe
struct ACdef_param ACglobal_create ={0,FULL_SCROLL,HDR_CONS,IN_MACRO_LIB,
				    {'\0'},{'\0'}};
struct ACdef_param ACglobal_place = {0,FULL_SCROLL,HDR_CONS,IN_MACRO_LIB,
				    {'\0'},{'\0'}};
%endsafe


/* Get from the form the symbology to modify */

COm_get_form_options(fp,macro_type,symb,hdr_scroll,hdr_type,hdr_def,search_path,		     ACglobal)

char *fp;
int macro_type;
int *symb;
enum ACm_poss_scroll *hdr_scroll;
enum ACm_poss_hdr *hdr_type;
enum ACm_poss_def_par *hdr_def;
char *search_path;
struct ACdef_param *ACglobal;
/*.COm_get_form_options*/
{
 int state;
 int new,sel,pos;
 char text[80];
 int num_rows,irow;
 int layer_option;

/* Symbology */

 new = 0;

/* layer option was */
 layer_option = *symb & (CHG_LAYER | INCR_LAYER); 
 FIfld_get_list_num_rows(fp,LAYER,0,&num_rows);

 for(irow=0;irow<num_rows;irow++)
   {
    FIfld_get_list_select(fp,LAYER,irow,0,&sel);
    /*"irow %d sel %d\n",irow,sel*/
    if(sel)
     {     if(irow ==0) layer_option = 0;
      else if(irow ==1) layer_option = CHG_LAYER;
      else if(irow ==2) layer_option = INCR_LAYER;
      break;
     }
    }
 new = new | layer_option;

 FIg_get_state(fp,COLOR,&state);
 if(state) new = new | CHG_COLOR;

 FIg_get_state(fp,WEIGHT,&state);
 if(state) new = new | CHG_WEIGHT;

 FIg_get_state(fp,STYLE,&state);
 if(state) new = new | CHG_STYLE;

/* support only or delete if no children */

 FIg_get_state(fp,DONT_MVRT,&state);
 if(state) new |= CHG_DONT_MVRT;

 FIg_get_state(fp,DEL_NO_CH,&state);
 if(state) new |= CHG_DEL_NO_CH;
 
 if(*symb != new && ACglobal != NULL) ACglobal->symb = new;
 *symb = new;

/*"symb %d\n",*symb */
 

/*" Scrolling option was %d\n",*hdr_scroll */
 
 FIfld_get_list_num_rows(fp,SCROLLING,0,&num_rows);
 for(new=0;new<num_rows;new++)
   {
    FIfld_get_list_select(fp,SCROLLING,new,0,&sel);
    /*"new %d sel %d\n",new,sel*/
    if(sel) break;
   }
 if(!sel) new = *hdr_scroll;
 if(sel && new != *hdr_scroll && ACglobal != NULL)
	 ACglobal->hdr_scroll = (enum ACm_poss_scroll) new;
 *hdr_scroll = (enum ACm_poss_scroll) new;   /*" hdr_scroll %d\n",new */

/*| Ocurrence type */
 FIfld_get_list_num_rows(fp,OCC_TYPE,0,&num_rows);
 for(new=0;new<num_rows;new++)
   {
    FIfld_get_list_select(fp,OCC_TYPE,new,0,&sel);
    if(sel) break;
   }
 if(!sel) new = *hdr_type;

/* Check if this option is valid */
 
  {
   int old;
   old = *hdr_type;
   if(macro_type == mac_cant_change) {}

   else if(macro_type == mac_not_def) *hdr_type = (enum ACm_poss_hdr) new; 

   else if(macro_type == mac_sym)  *hdr_type = HDR_SYMB;

   else if(macro_type == mac_exp)
          {*hdr_type = (enum ACm_poss_hdr) new;}

   else if(macro_type == mac_ci)
          {if(new == HDR_CONS || new == HDR_SYMB || new == HDR_GRAPHIC)
					*hdr_type = (enum ACm_poss_hdr) new;}

   if(*hdr_type != old && ACglobal != NULL) ACglobal->hdr_type = *hdr_type;

/* Update the form with valid option */
   FIfld_get_list_text(fp,OCC_TYPE,*hdr_type,0,80,text,&sel);
   FIfld_set_list_select(fp,OCC_TYPE,*hdr_type,0,TRUE);
   FIfld_set_text(fp,OCC_TYPE,0,0,text,TRUE);
  }


/*| search path */

 FIfld_get_text(fp,SEARCHDIR,0,0,79,search_path,&sel,&pos);
 FIfld_get_list_num_rows(fp,SEARCHDIR,0,&num_rows);

 for(new=0;new<num_rows;new++)
   {
    FIfld_get_list_text(fp,SEARCHDIR,new,0,80,text,&sel);
    if(strcmp(search_path,text) == 0) break;
   }
 if(new >= num_rows) new  = USER_SPECIFIED;

 if(new != *hdr_def && ACglobal != NULL)
			        ACglobal->hdr_def = (enum ACm_poss_def_par) new;
 *hdr_def = (enum ACm_poss_def_par) new;

 if(*hdr_def == USER_SPECIFIED)
   if(ACglobal != NULL) strcpy(ACglobal->search_path,search_path);

 return(1);
}

/* Set in the form the symbology to modify */

COm_set_form_options(fp,symb,hdr_scroll,hdr_type,hdr_def,search_path)
char *fp;
int symb;
enum ACm_poss_hdr hdr_type;
enum ACm_poss_scroll hdr_scroll;
enum ACm_poss_def_par hdr_def;
char *search_path;
/*.COm_set_form_options*/
{
 int state,sel;
 char text[80];
 int layer_option;

 /* Symbology */

 layer_option = 0;
 if(symb&CHG_LAYER)  layer_option = 1;
 if(symb&INCR_LAYER) layer_option = 2;
 FIfld_get_list_text(fp,LAYER,layer_option,0,80,text,&sel);
 /*" layer %d %s \n",layer_option,text */
 FIfld_set_text(fp,LAYER,0,0,text,TRUE);

 if(symb&CHG_COLOR) state = 1;
 else		    state = 0;
 FIg_set_state(fp,COLOR,state);

 if(symb&CHG_WEIGHT) state = 1;
 else		     state = 0;
 FIg_set_state(fp,WEIGHT,state);

 if(symb&CHG_STYLE) state = 1;
 else		    state = 0;
 FIg_set_state(fp,STYLE,state);

 if(symb&CHG_DONT_MVRT) state = 1;
 else			state = 0;
 FIg_set_state(fp,DONT_MVRT,state);

 if(symb&CHG_DEL_NO_CH) state = 1;
 else			state = 0;
 FIg_set_state(fp,DEL_NO_CH,state);

 
 FIfld_get_list_text(fp,SCROLLING,hdr_scroll,0,80,text,&sel);
 /*" scroll mode %d %s \n",hdr_scroll,text */
 FIfld_set_text(fp,SCROLLING,0,0,text,TRUE);
 FIfld_set_list_select(fp,SCROLLING,hdr_scroll,0,TRUE);


 FIfld_get_list_text(fp,OCC_TYPE,hdr_type,0,80,text,&sel);
 /*" occurence type %d %s \n",hdr_type,text */
 FIfld_set_text(fp,OCC_TYPE,0,0,text,TRUE);
 FIfld_set_list_select(fp,OCC_TYPE,hdr_type,0,TRUE);

 /*search path */
 if(hdr_def != USER_SPECIFIED)
  {
   FIfld_get_list_text(fp,SEARCHDIR,hdr_def,0,80,text,&sel);
   FIfld_set_list_select(fp,SEARCHDIR,hdr_def,0,TRUE);
   search_path = text;
  }
   FIfld_set_text(fp,SEARCHDIR,0,0,search_path,TRUE);
 return(1);
}

ACrecursive_incr_layer(hdr,active_level)
struct GRid *hdr;
short active_level;
{
 long status,msg;
 struct GRid component;
 short level;
 struct GRsymbology obj_symb;
 int index;
 GRclassid obj_class;


 status = OM_S_SUCCESS;
 index = 0;
 om$get_classid(objid = hdr->objid,
		osnum = hdr->osnum,
		p_classid = &obj_class);

 if(om$is_ancestry_valid(superclassid = OPP_ACncpx_class_id,
			 subclassid   = obj_class) == OM_S_SUCCESS &&
    om$is_ancestry_valid(superclassid = OPP_ACheader_class_id,
			 subclassid   = obj_class) != OM_S_SUCCESS)
   {
    while(om$get_objid_at_index(objid = hdr->objid, osnum = hdr->osnum,
				p_chanselect = &AS_to_comp,
				index = index++,
				objidaddr= &component.objid,
				osnumaddr= &component.osnum) == OM_S_SUCCESS)
      {
       status = ACrecursive_incr_layer(&component,active_level);
      }  
    }
  else
    {
      status = om$send(msg = message GRvg.GRgetsymb(&msg,&obj_symb),
                      targetid = hdr->objid,
                      targetos = hdr->osnum,
                      senderid = NULL_OBJID);
      if(status&1 && msg == MSSUCC)
        {
         level = active_level+obj_symb.level;
	 if(level > HI_LAYER) level = HI_LAYER;
         status = om$send(msg = message GRvg.GRchglevel(&msg,&level),
                          targetid = hdr->objid,
                          targetos = hdr->osnum,
                          senderid = NULL_OBJID);
	}
     }

 return status;
}

/* to support old function call */

COmchg_symb(symb,hdr,md_env)
int symb;
struct GRid *hdr;
struct GRmd_env *md_env;
{
 short active_level;
 struct IGRdisplay active_display;
 long status;

 ASget_active_symb(&active_level,&active_display);

 status = COmchg_var_symb(symb,hdr,active_level,&active_display,md_env);
 return status;
}

#argsused
COmchg_var_symb(symb,hdr,active_level,active_display,md_env)
int symb;
struct GRid *hdr;
short active_level;
struct IGRdisplay *active_display;
struct GRmd_env *md_env;
{
 long status,msg;

/*" symb %d\n",symb */

 if(symb&CHG_LAYER)
  {
   status = om$send(msg = message GRvg.GRchglevel(&msg,&active_level),
		  senderid = NULL_OBJID,
		  targetid = hdr->objid,
		  targetos = hdr->osnum);
  }

 if(symb&INCR_LAYER)
  {
   status = ACrecursive_incr_layer(hdr,active_level);
  }

 if(symb&CHG_COLOR)
  {
   status = om$send(msg = message GRvg.GRchgcolor
			 (&msg,0,&active_display->color),
		  senderid = NULL_OBJID,
                  targetid = hdr->objid,
                  targetos = hdr->osnum);
  }

 if(symb&CHG_WEIGHT)
  {
   status = om$send(msg =message GRvg.GRchgweight(&msg,&active_display->weight),
		  senderid = NULL_OBJID,
                  targetid = hdr->objid,
                  targetos = hdr->osnum);
  }

 if(symb&CHG_STYLE)
  {
   status = om$send(msg = message GRvg.GRchgstyle(&msg,&active_display->style),
		  senderid = NULL_OBJID,
                  targetid = hdr->objid,
                  targetos = hdr->osnum);
  }

 if(symb&(CHG_DONT_MVRT|CHG_DEL_NO_CH))
  {
   char new_state;
   new_state = 0;
   if(symb&CHG_DONT_MVRT) new_state |= ND_DONT_MVRT;
   if(symb&CHG_DEL_NO_CH) new_state |= ND_DEL_NO_CH;
   status = om$send(msg = message NDnode.NDchg_state(new_state,new_state),
		  senderid = NULL_OBJID,
                  targetid = hdr->objid,
                  targetos = hdr->osnum);
  }


 return(1);
}

/* Get option GRid from macro GRid */

COm_get_option_grid(macro,def_id,arg_def_name)
struct GRid *macro,*def_id;
char *arg_def_name;
/*. COm_get_option_grid */
{
 char *c;
 int status;
 char def_name[DI_PATH_MAX];

  /*"macro %d %d\n",macro->objid,macro->osnum */

  def_id->objid = NULL_OBJID;
  def_name[0] = '\0';
  
  status = di$untranslate(objid = macro->objid,
			  osnum = macro->osnum,
			  objname = def_name);
  /*" macro_name %s\n",def_name */
  if(status&1)
   {
    c = strrchr(def_name,'$'); 
    if(c == NULL) c = def_name + strlen(def_name);

    strcpy(c,"$def");
 
    /*" def_name %s\n",def_name */
    
    status = di$translate(objname = def_name,
			p_objid = &def_id->objid,
			p_osnum = &def_id->osnum);
    if(!(status&1)){ def_id->objid = NULL_OBJID; def_name[0] = '\0'; }
   }

   if(arg_def_name) strcpy(arg_def_name,def_name);
/*" %d %d %s\n",def_id->objid,def_id->osnum,def_name */
  return(status);
}

/* Return from default parameter box options corresponding to the macro */

COm_get_options(macro,symb,hdr_scroll,hdr_type,hdr_def,search_path,
		post_placement,def_occ,md_env)
struct GRid *macro;
int *symb;
enum ACm_poss_hdr *hdr_type;
enum ACm_poss_scroll *hdr_scroll;
enum ACm_poss_def_par *hdr_def;
char *search_path,*post_placement;
struct GRid *def_occ;
struct GRmd_env *md_env;
/*.COm_get_options*/
{
 struct GRid def_id;

/* Get default parameter box */

COm_get_option_grid(macro,&def_id, (char *) NULL);

if(def_id.objid == NULL_OBJID)
{
 /*| no default found */
 *hdr_def = NO_OPTION;
 return(OM_S_SUCCESS);
}

else return( COm_get_options_bis(macro,&def_id,
			symb,hdr_scroll,hdr_type,hdr_def,search_path,
			post_placement,def_occ,md_env));

}

/* return options asociated to macro + options box ( we can have several
   optons box for the same macro */

COm_get_options_bis(macro,def_id,symb,hdr_scroll,hdr_type,hdr_def,search_path,
		post_placement,def_occ,md_env)
struct GRid *macro,*def_id;
int *symb;
enum ACm_poss_hdr *hdr_type;
enum ACm_poss_scroll *hdr_scroll;
enum ACm_poss_def_par *hdr_def;
char *search_path,*post_placement;
struct GRid *def_occ;
struct GRmd_env *md_env;
{
 IGRlong status,msg;
 struct ret_struct rst;
 GRclassid obj_class;

/* search path */

  status = om$send(msg = message NDmacro.ACgive_structure((int *)&msg,NULL,
                                      "~~search_path",&rst,md_env),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);
  if((status&msg&1) && rst.type == text_type)
   {
    strcpy(search_path,rst.var.text_st.text_string);
    *hdr_def = USER_SPECIFIED;
    /*"search_path %s\n",search_path */
   }
  else
   {
    /*| in macro lib */
    *hdr_def = IN_MACRO_LIB;
    status = om$send(msg = message GRvg.GRgetname(&msg,search_path),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);
   }

/* post placement ppl */

  status = om$send(msg = message NDmacro.ACgive_structure((int *)&msg,NULL,
                                      "~~post_placement",&rst,md_env),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);
  if((status&msg&1) && rst.type == text_type)
   {
    strcpy(post_placement,rst.var.text_st.text_string);
    /*"post_placement %s\n",post_placement */
   }
  else
   {
    post_placement[0] = '\0';
   }

/* Symbology */

  status = om$send(msg = message NDmacro.ACgive_structure((int *)&msg,NULL,
                                      "~~symbology",&rst,md_env),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);
  if(status&msg&1)
   {
    *symb = (int) rst.var.root_pm_st.value &
	    (CHG_LAYER | CHG_COLOR | CHG_WEIGHT | CHG_STYLE | INCR_LAYER |
	     CHG_DONT_MVRT | CHG_DEL_NO_CH);

    *hdr_scroll = (enum ACm_poss_scroll)
				((((int) rst.var.root_pm_st.value) >> 4) & 0x3);
    *hdr_type = (enum ACm_poss_hdr)
				((((int) rst.var.root_pm_st.value) >> 6) & 0x3);
   }

/* default occurence */

/*
   For conditional take the default occurence of the first macro in the
   condition
   modif jla feb 93, if not found directly in the condit option box
*/

  status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                      "~~occurence",def_occ,NULL,NULL),
		   senderid = NULL_OBJID,
                   targetid = def_id->objid,
                   targetos = def_id->osnum);

  if (!(msg&1))
  {
   status = om$get_classid(objid = macro->objid, osnum = macro->osnum,
			  p_classid = &obj_class);
   if(om$is_ancestry_valid(superclassid = OPP_ACcond_def_class_id,
			  subclassid = obj_class) == OM_S_SUCCESS)
   {
    int num_condit,i_condit,num_default;
    struct ACcond_descrip *condit_desc;
    struct ACcond_temp *temp_default;
    struct GRid macro1,def_id1;
    status = om$send(msg = message ACcond_def.ACgive_condit_desc(&num_condit,
				&condit_desc,&num_default,&temp_default),
		     senderid = NULL_OBJID,
                     targetid = macro->objid, targetos = macro->osnum);
    if(!(status&1)) num_condit = 0;
    for(i_condit=0 ; i_condit<num_condit ; i_condit++)
     {
      status = ac$find_macro_defn(action = ACfind_no_load,
			 macro_name = condit_desc[i_condit].konst,
                         p_macro_defn_id = &macro1);
      if(!(status&1)) continue;
      
      COm_get_option_grid(&macro1,&def_id1,(char *) NULL);

      if(def_id1.objid != NULL_OBJID)
       {
        status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                      "~~occurence",def_occ,NULL,NULL),
		   senderid = NULL_OBJID,
                   targetid = def_id1.objid,
                   targetos = def_id1.osnum);
        if(msg&1) break;
       }
     }
   }
  }

/* remove jla jan 93 */
/* else
/*   {
/*   status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
/*                                      "~~occurence",def_occ,NULL,NULL),
/*		   senderid = NULL_OBJID,
/*                   targetid = def_id->objid,
/*                   targetos = def_id->osnum);
/*  }
/*******/

if(!(msg&1))
   {
    struct GRid def_id1;
    /* This could be an aternative option box without default occurence */
    COm_get_option_grid(macro,&def_id1,(char *) NULL);
    if(def_id1.objid != def_id->objid)
      status = om$send(msg = message NDmacro.ACreturn_foot(&msg,
                                      "~~occurence",def_occ,NULL,NULL),
		   senderid = NULL_OBJID,
                   targetid = def_id1.objid,
                   targetos = def_id1.osnum);
   }
 if(!(msg&1)) def_occ->objid = NULL_OBJID;

/*"default occurence %d %d\n",def_occ->objid,def_occ->osnum*/

 return(OM_S_SUCCESS);
}

ACcreate_def_temp(search_option,search_path,symbology,
		  hdr_type,hdr_scroll,
		  macro,temp_val,temp_grid,feet_grid,
		  def_col,def_occ)
enum ACm_poss_def_par search_option;
char *search_path;
int symbology;
enum ACm_poss_hdr hdr_type;
enum ACm_poss_scroll hdr_scroll;
struct GRid *macro,*temp_grid,*feet_grid;
struct ret_struct *temp_val; 
struct GRid *def_col,*def_occ;
/*.ACcreate_def_temp*/
{
 long status,msg;
 int i;
 char syntax[80];
 int Nb_Max_Temp,dum;
 struct sup *dup;
 char def_name[DI_PATH_MAX];
 char *c;
 struct GRmd_env md_env,fr_env;
 struct GRid def_temp;
 int att_type;

 if(search_option == NO_OPTION) return OM_S_SUCCESS;

 /* Retrieve macro definition and its template description */

 status = om$send(msg = message ACmacro_defn.ACgive_upscan
                             (&Nb_Max_Temp,&dum,&dup),
		  senderid = NULL_OBJID,
                  targetid = macro->objid,
                  targetos = macro->osnum );
 as$status(msg = "Unable to get macro Temp_Desc",action = RET_STATUS);


 /* Create default parameter name from macro name */

 status = di$untranslate(objid = macro->objid,
                         osnum = macro->osnum,
                         objname = def_name);
 /*"macro_name >>%s<< status %d\n",def_name,status*/


 c = strrchr(def_name,'$');
 if(c != NULL) strcpy(c,"$def");
 else strcat(def_name,"$def");

 /*"def_name >>%s<< status %d\n",def_name,status*/
 status = ac$find_macro_defn(action =  ACfind_no_load,
                             macro_name = def_name,
                             p_macro_defn_id = def_col);
 if(status&1)
  {
   /*| Default definition already exist !!! */
   return(OM_W_ABORT);
  }

 /* Initialize md_env for macro lib */

 md_env.md_id.objid = NULL_OBJID;
 md_env.md_id.osnum = macro->osnum;
 md_env.md_env.matrix_type = MAIDMX;
 MAidmx(&msg,md_env.md_env.matrix);

 fr_env = md_env;
 if(temp_grid) fr_env.md_id.osnum = temp_grid->osnum;
 else if(feet_grid) fr_env.md_id.osnum = feet_grid->osnum;



 switch(search_option)
  {
   default: /*| !!!!!!! */
   case NO_OPTION : /*| That is all folks !! */
     break;

   case IN_MACRO_LIB :
   case USER_SPECIFIED :
 
 /* create diowner to store options */
   status = COm_create_def_box(def_name,macro->osnum,def_col);
   as$status(action = RET_STATUS);

   /*| create default value for expression template */
   for(i=0 ; i<Nb_Max_Temp ; i=i+1)
    { 
     /*"tem %d type %x\n",i,temp_val[i].type*/
  if(temp_grid)
   {
    status = om$send(msg = message NDmacro.ACcopy_to_Groot
				(&msg,ND_TO_DEF_TEMP,&fr_env,&md_env,&def_temp),
                     senderid = NULL_OBJID,
		     targetid = temp_grid[i].objid, 
		     targetos = temp_grid[i].osnum);
    if((status&msg&1) && (def_temp.objid != NULL_OBJID))
     {
      GRclassid target_cl;
      om$get_classid(objid=def_temp.objid,
                     osnum=def_temp.osnum,
                      p_classid = &target_cl);

      if(om$is_ancestry_valid(subclassid =target_cl ,
                          superclassid = OPP_ASsource_class_id) == OM_S_SUCCESS)
      {
       status = om$send( msg = message NDnode.ASreturn_go( &def_temp,
                                NULL,NULL),
		  senderid = NULL_OBJID,
                  targetid = def_temp.objid ,
                  targetos = def_temp.osnum);
       as$status ( action = RET_STATUS );
      }

      status = om$send(msg = message ACdiowner.ACadd_component_with_name
					(&msg,&def_temp,dup[i].prompt),
                      senderid = NULL_OBJID,
                      targetid = def_col->objid,
                      targetos = def_col->osnum);
      as$status();
     }
    }
   else if (temp_val)
    {
     if(temp_val[i].type & dup[i].type & parameter_generic)
      {
       /*"Add the attributes to the owner %d\n",def_col->objid*/

       if(temp_val[i].type == double_type)
         {
          /*"%d double %lf\n",i,temp_val[i].var.root_pm_st.value*/
          sprintf(syntax,"%20.9lf",temp_val[i].var.root_pm_st.value);
	  att_type = AC_ATTRIB_DOUBLE;
	 }
       else
         {
	  strcpy(syntax,temp_val[i].var.text_st.text_string);
	  att_type = AC_ATTRIB_TEXT;
          /*"name %s syntax %s\n",dup[i].prompt,syntax */
         }
	
       status = om$send(msg      = message ACdiowner.ACadd_attribute_by_type
                                   (&msg,att_type,dup[i].prompt,syntax),
		      senderid = NULL_OBJID,
  	              targetid = def_col->objid,
                      targetos = def_col->osnum);
        as$status();
      }
     }
    }

  if(search_option == USER_SPECIFIED)
   {
    /*" add search path >>%s<<\n",search_path */
    status = om$send(msg      = message ACdiowner.ACadd_attribute_by_type
                                   (&msg,AC_ATTRIB_TEXT,
				    "~~search_path",search_path),
                      senderid = NULL_OBJID,
                      targetid = def_col->objid,
                      targetos = def_col->osnum);
    as$status();
   }

  /*"sym %d scroll %d type %d\n",symbology,hdr_scroll,hdr_type*/
  sprintf(syntax,"%10d",symbology + (hdr_scroll<<4) + (hdr_type<<6));
  /*"syntax >>%s<<\n",syntax*/
  status = om$send(msg      = message ACdiowner.ACadd_attribute_by_type
                                   (&msg,AC_ATTRIB_DOUBLE,"~~symbology",syntax),
                      senderid = NULL_OBJID,
                      targetid = def_col->objid,
                      targetos = def_col->osnum);
  as$status();

  /* Create default occurence */

  if(def_occ)
   {
      status = om$send(msg = message ACmacro_defn.ACcreate_default
				((int *)&msg,macro->osnum,feet_grid,def_occ),
                     senderid = NULL_OBJID,
		     targetid = macro->objid,
		     targetos = macro->osnum);

    /*"def_occ %d %d\n",def_occ->objid,def_occ->osnum*/
    if(status&msg&1)
     {
      status = om$send(msg = message ACdiowner.ACadd_component_with_name
					(&msg,def_occ,"~~occurence"),
                      senderid = NULL_OBJID,
                      targetid = def_col->objid,
                      targetos = def_col->osnum);
      as$status();
    }
   }

 }
 return OM_S_SUCCESS;
}

/* ******************* ACset_def_interface() **************************	*/

ACset_def_interface( rc, mac_name, form_name, nb_att, list_att )

IGRlong			*rc;
IGRchar			*mac_name;
IGRchar			*form_name;
IGRint			nb_att;
struct	ACrg_coll	*list_att;

/*.ACset_def_interface*/
{

IGRlong		sts, msg;
IGRchar		def_name[DI_PATH_MAX];
struct	GRid	def_col;
struct	GRid	temp_box;


	/*| initialization */
	*rc	= MSFAIL;

	sprintf( def_name, "%s$def", mac_name );
	/*" def_name : %s\n", def_name */

	def_col.objid	= NULL_OBJID;
	sts = ac$find_macro_defn(	action		=  ACfind_no_load,
					macro_name	= def_name,
					p_macro_defn_id = &def_col );
	as$status( sts = sts, msg = "not default object create for the definition",
			action	= RET_STATUS );
	/*" def_col : %d/%d\n", def_col.objid, def_col.osnum */

	/*| add/modify form_name */
	if( form_name == NULL ){

		sts = om$send(	msg	 = message ACdiowner.ACrem_attribute
						( &msg, ATT_FORM_NAME ),
				targetid = def_col.objid,
				targetos = def_col.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );

	} else {

		sts = om$send(	msg	 = message ACdiowner.ACadd_attribute_by_type(
					&msg,
					AC_ATTRIB_TEXT,
					ATT_FORM_NAME,
					form_name ),
				targetid = def_col.objid,
				targetos = def_col.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );

		sts = om$send(	msg	 = message ACdiowner.ACmod_attribute(
					&msg,
					ATT_FORM_NAME,
					form_name ),
				targetid = def_col.objid,
				targetos = def_col.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );
	  }

	/*| find existing temp box */
	temp_box.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&msg,
					ATT_TEMP_LIST,
					&temp_box,
					NULL,
					NULL ),
			targetid = def_col.objid,
			targetos = def_col.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );

	if( temp_box.objid == NULL_OBJID || !( msg&1 ) ){

		/*| create the box temp */
		temp_box.osnum	= def_col.osnum;
		sts = om$construct(	classname	= "ACrg_collect",
					osnum		= temp_box.osnum,
					p_objid		= &temp_box.objid );
		as$status( sts = sts, action = RET_STATUS );

		/*| add box temp on def */
		sts = om$send(	msg	 = message ACdiowner.ACadd_component_with_name(
						&msg,
						&temp_box,
						ATT_TEMP_LIST ),
				targetid = def_col.objid,
				targetos = def_col.osnum,
				senderid = NULL_OBJID );
		as$status( sts = sts );
	}

	/*" temp_box : %d/%d\n", temp_box.objid, temp_box.osnum */
	/*| set new values in box temp */
	sts = om$send(	msg	 = message ACrg_collect.ACset_list_attribute(
						&msg,
						nb_att,
						list_att ),
			targetid = temp_box.objid,
			targetos = temp_box.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts, action = RET_STATUS );

	*rc	= MSSUCC;

return	OM_S_SUCCESS;
}


/* ******************* ACget_def_interface() **************************	*/

ACget_def_interface( rc, mac_name, generic_inter, 
			form_name, len_list, list_att, count_att )

IGRlong			*rc;
IGRchar			*mac_name;
IGRint			*generic_inter;
IGRchar			*form_name;
IGRint			len_list;
struct	ACrg_coll	*list_att;
IGRint			*count_att;

/*.ACget_def_interface*/
{
IGRlong		sts, msg;
IGRchar		def_name[DI_PATH_MAX];
struct	GRid	def_col;
struct	GRid	temp_box;
IGRint		dir_index;
struct	ret_struct	form_st;


	/*| initialization */
	*generic_inter	= ~0;
	if( rc != NULL )		*rc		= MSFAIL;
	if( count_att != NULL )		*count_att	= 0;
	if( form_name != NULL )		form_name[0]	= '\0';

	sprintf( def_name, "%s$def", mac_name );
	/*" def_name : %s\n", def_name */

	def_col.objid	= NULL_OBJID;
	sts = ac$find_macro_defn(	action		= ACfind_no_load,
					macro_name	= def_name,
					p_macro_defn_id = &def_col );
        if(!(sts&1)) return OM_S_SUCCESS;

	/*| find form attribut */
	dir_index = -1;
	sts = om$send(	msg	 = message NDmacro.ACgive_structure(
					(int *) &msg,
					&dir_index,
					ATT_FORM_NAME,
					&form_st,
					NULL ),
			targetid = def_col.objid,
			targetos = def_col.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );
	if( ! (sts & msg & 1))	return	OM_S_SUCCESS;

	/*| user interface is modify */
	*generic_inter	= 0;

	if( form_name != NULL )
		strcpy( form_name, form_st.var.text_st.text_string );

	/* get list of template */
	temp_box.objid	= NULL_OBJID;
	sts = om$send(	msg	 = message NDmacro.ACreturn_foot(
					&msg,
					ATT_TEMP_LIST,
					&temp_box,
					NULL,
					NULL ),
			targetid = def_col.objid,
			targetos = def_col.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts, action = RET_STATUS );

	/*" get info on temp in box : %d/%d\n", temp_box.objid, temp_box.osnum */
	sts = om$send(	msg	 = message ACrg_collect.AClist_attribute(
					&msg,
					len_list,
					list_att, 
					count_att ),
			targetid = temp_box.objid,
			targetos = temp_box.osnum,
			senderid = NULL_OBJID );
	as$status( sts = sts );

	if( rc != NULL )	*rc	= MSSUCC;

return	OM_S_SUCCESS;
}

COm_create_def_box(def_name,osnum,def_temp)
char *def_name;
GRspacenum osnum;
struct GRid *def_temp;
{

 struct GRmd_env md_env;
 struct GRvg_construct cnst_list;
 long status,msg;
 double point[3];
 struct IGRpolyline geom_l;
 long cnst_lis_msg;
 struct IGRdisplay      Active_display;
 IGRshort               Active_level;
 struct GRid dummy;

 /* Initialize md_env for macro lib */

 md_env.md_id.objid = NULL_OBJID;
 md_env.md_id.osnum = osnum;
 md_env.md_env.matrix_type = MAIDMX;
 MAidmx(&msg,md_env.md_env.matrix);


 /*| create a dummy point */

 ASget_active_symb(&Active_level,&Active_display);
 cnst_list.msg = &cnst_lis_msg;        
 cnst_list.env_info = &md_env;
 cnst_list.display = &Active_display;
 cnst_list.geometry = 0; 
 cnst_list.newflag = FALSE;
 cnst_list.level = Active_level;
 cnst_list.properties = GRIS_LOCATABLE | GRIS_DISPLAYABLE;
 cnst_list.class_attr = NULL;
 cnst_list.name = NULL;

 geom_l.num_points = 1;
 geom_l.points = point;
 cnst_list.geometry = (char *) &geom_l;

 point[0] = 0;
 point[1] = 0;
 point[2] = 0;

 dummy.osnum = osnum;
 status = om$construct(classname = "GR3dpoint",
		       osnum = dummy.osnum,
		       p_objid = &dummy.objid);
 as$status();

 status = om$send( msg = message GR3dpoint.GRaltconstruct( &cnst_list ),
		   senderid = NULL_OBJID,
		   targetos = dummy.osnum,
                   targetid = dummy.objid);
 as$status();

/*"dummy %d %d\n",dummy.objid,dummy.osnum*/

 def_temp->osnum = osnum;
 status = om$construct(classname = "ACdiowner",
		       osnum = def_temp->osnum,
		       p_objid = &def_temp->objid);
 as$status();

 status = om$send (msg      = message ACdiowner.ACcreate(&msg,def_name),
		   senderid = NULL_OBJID,
                   targetid = def_temp->objid,
                   targetos = def_temp->osnum);
 as$status();

 /*"def_temp->d %s\n",def_temp->objid,def_name */

 status = om$send (msg  = message ACdiowner.ACadd_component(&msg,&dummy),
		   senderid = NULL_OBJID,
	           targetid = def_temp->objid,
                   targetos = def_temp->osnum);
 as$status();
 return 1;
}

COm_get_condit_def_hdr(msg, macro_id, def_hdr, num_temp, temp_list, md_env)
IGRlong			*msg;
struct GRid		*macro_id, *def_hdr;
IGRint			num_temp;
struct GRid		*temp_list;
struct GRmd_env 	*md_env;
{
 IGRint		active_index;
 IGRlong	status = OM_S_SUCCESS;

 struct GRid 		sym, rep_id, def_id, def_occ;

if( num_temp == 0 || temp_list == NULL ){ return (OM_S_SUCCESS); }

 rep_id.objid = NULL_OBJID;
 status = om$send(msg = message ACcond_def.ACfind_rep(msg, 
				                      num_temp,
						      sym, 
                                                      temp_list,
                                                      &rep_id,
						      &active_index,
				                      md_env),
	           senderid = NULL_OBJID,
                   targetid = macro_id->objid,
	           targetos = macro_id->osnum);
 as$status(action = RET_STATUS);

 if ( rep_id.objid != NULL_OBJID ) 
 {
     COm_get_option_grid(&rep_id,&def_id,(char *) NULL);

     def_occ.objid = NULL_OBJID;

     if(def_id.objid != NULL_OBJID)
     {
            status = om$send(msg = message NDmacro.ACreturn_foot(msg,
                                			        "~~occurence",
								&def_occ,
								NULL,
								NULL),
		             senderid = NULL_OBJID,
                             targetid = def_id.objid,
                             targetos = def_id.osnum);
            as$status(action = RET_STATUS);

	    if ( def_occ.objid != NULL_OBJID ) {
		def_hdr->objid = def_occ.objid;
		def_hdr->osnum = def_occ.osnum;
	    }
       }
  }
  return(1);
}

end implementation COm_place;
