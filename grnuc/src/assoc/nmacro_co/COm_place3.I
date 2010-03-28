class implementation COm_place;

#include "OMmacros.h"
#include "coparadef.h"
#include "coparamac.h"
#include "ci.h"
#include "ciexecmacros.h"
#define  PATH_MAX 256
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "DImacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "msmacros.h"
#include "ASmessages.h"
#include "asdef.h"
#include "asmacros.h"
#include "FI.h"
#include "nd.h"
#include "nddef.h"
#include "ndmacros.h"
#include "expression.h"
#include "expmacros.h"
#include "asbox.h"
#include "dpmacros.h"
#include "ACrg_collect.h"


#include "lcdef.h"
#include "lcmacros.h"

#include "acdef.h"
#include "acmacros.h"
#include "acrepdef.h"
#include "acrepmacros.h"

#include "ctype.h" /* for isdigit */

#define exp_grap 0x03
#define exp_symb 0x02
#define exp_drop 0x01
#define exp_cons 0x00
#define sym_sym  0x12
#define ci_cons  0x20
#define ci_sym   0x22
#define ci_grap  0x23

#define ACkeep_variable_template 1024


#define AS_DEBUG

from GRgraphics 	import GRdisplay,GRdelete;
from ACmacro_defn    	import ACgive_upscan;
from ACexpand      	import ACmplace;
from ACsym     		import ACmplace;
from ACconst     	import ACmplace_from_def;
from ACcpx 		import ACdrop,find_macro;
from ci_macro           import init;
from GRvg		import GRputname,GRgetname;
from IGRdir 		import dump;
from NDmacro		import ACgive_structure,ACtest_consumed,ACreturn_foot;
from NDnode		import NDconnect,NDgive_structure,
			       NDget_objects,NDchg_state,ASreturn_go;
from expression		import list,NDset_value;
from ACcpx_defn		import ACgive_name;
from IGRdir 		import translate;
from ci			import is_entry_point,set_value;
from ACncpx 		import ACget_rep,ACput_rep,ACget_STATE;
from FIdirform          import update;
from ACpretend		import ACpconnect;





extern GRclassid OPP_ci_mac_def_class_id,
		 OPP_ACncpx_class_id,
		 OPP_ASsource_class_id,
		 OPP_ACpretend_class_id;


/* STATIC DECLARATIONS */

%safe
static IGRint TokenList[] =
  {
  RESET,                     /* when the user click the reset buttom          */
  GR_UNKNOWN_TYPE,           /* when the user make an UNKNOWN TYPE command    */
  LOC_PARENT,                /* when the user locate a parent                 */
  LOC_PARAM                  /* when the user locate a PARAM                  */
  };

static enum possible_states NewState[NUM_STATES][NUM_TOKENS] = 
  {
               /*****************************************************/
               /*                  TOKENS                           */
/****************---------------------------------------------------*/
/*  Old State   *     RESET    , GR_UNKNOWN , LOC_PARENT, LOC_PARAM */
/*------------------------------------------------------------------*/
/*   WAIT_MAC   */{   WAIT_MAC ,  WAIT_MAC  ,   WAIT_TEM, WAIT_TEM},
/*------------------------------------------------------------------*/
/*   WAIT_TEM   */{   WAIT_TEM ,  WAIT_TEM  ,   WAIT_TEM, WAIT_TEM},
/*------------------------------------------------------------------*/
/*   WAIT_ELI   */{   WAIT_TEM ,  WAIT_TEM  ,   WAIT_TEM, WAIT_TEM},
/*------------------------------------------------------------------*/
/*   FULL_DEF   */{   WAIT_TEM ,  WAIT_TEM  ,   WAIT_TEM, WAIT_TEM},
/*------------------------------------------------------------------*/
/*   WAIT_LOA   */{   WAIT_TEM ,  WAIT_LOA  ,   WAIT_TEM, WAIT_TEM}
/*------------------------------------------------------------------*/
};


static enum possible_actions Action[NUM_STATES][NUM_TOKENS] = 
  {
               /*****************************************************/
               /*                  TOKENS                           */
/****************---------------------------------------------------*/
/*  Old State   *     RESET     , GR_UNKNOWN, LOC_PARENT, LOC_PARAM */
/*------------------------------------------------------------------*/
/*   WAIT_MAC   */{  PRO_MAC    ,   PRO_MAC ,  STO_OCC  ,  STO_MAC },
/*------------------------------------------------------------------*/
/*   WAIT_TEM   */{  END_TEMP   ,   PRO_TEMP,  STO_TEMP , STO_TEMP },
/*------------------------------------------------------------------*/
/*   WAIT_ELI   */{  STO_ELI    ,   STO_ELI ,  STO_ELI  , STO_ELI  },
/*------------------------------------------------------------------*/
/*   FULL_DEF   */{ CREATE_MACRO, CHOSE_TEMP,  PRO_TEMP , PRO_TEMP},
/*------------------------------------------------------------------*/
/*   WAIT_LOA   */{  REM_LOAD   , PRO_LOAD  ,  STO_OCC  , REM_LOAD}
/*------------------------------------------------------------------*/
};

%endsafe


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                                   execute                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute ( int  *response; char *response_data; int  pos )

{
  IGRlong    		status,  Input_Mask, Locate_Mask, Display_Flag;
  IGRint     		Size, Token=0; 
  IGRdouble  		Param;  
  struct GRevent      	Event_Ac, Event_Loc;   
  struct GRid         	Object_GRid, Context_GRid;
  IGRint 		i=0,j;
  struct ret_struct  	obj_struct;
  IGRlong     		msg;        
  int 			nb_obj;
  char *c,*strrchr();

  struct ret_struct rst;
  GRclassid obj_class; 
  struct GRid *set_obj;
  struct GRid other_def,other_occ,dummy;
  int ideb_rep;
  int len;
  int nb_temp_occ=0,nb_temp_other;
  int i_occ;
  OMuint nb_set;
  OM_S_CHANSELECT his_chan;
  char *specific_param;
  int found;
  int param_type;
  IGRshort exp_rc;

  if(!me->form_ptr)
   {
    *response = TERMINATE;
    return OM_S_SUCCESS;
   }

  status = om$make_chanselect(p_chanselect = &his_chan,
			      channame = "GRgrset.to_owners");
  as$status(action = RET_STATUS);


  /*| Initialization for the Locate of an event */

  Size = sizeof(struct GRevent);
  Locate_Mask = GRm_DATA | GRm_RESET;
  Input_Mask  = GRm_DATA | GRm_RESET;
  Display_Flag = ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;

  /* Verify if ACpath has been initialize */

  ac$construct_path(mode = AC_INQ,
                   path_len = &len);
  if(!len)
  {
   ex$message(msgnumb = AS_F_NoLLib);
   *response = TERMINATE;
   return OM_S_SUCCESS;
  }

  do 
  {
    switch (me->action)
    {
      case NIL :
        /*| Does not make anything */
        break;


      default :
        /*| Unexpected case */

      case ERR_M : 
        /*| When an error occurs */
        ex$message( field = 2, msgnumb = AS_E_InvDefRest );

      case REM_LOAD: /*| Just change the state of the -load template- button */
	FIg_set_state(me->form_ptr,LOAD_TEMPLATE,0);
 
      case PRO_LOAD : /*| Locate a macro for modification or to load template */

      case PRO_MAC  : /*| prepar to get a macro name */

        /*| Reinitialize instances and form if any */

	if(me->user_form_ptr)
         {
	  FIf_delete(me->user_form_ptr); 
	  me->user_form_ptr = NULL;
         }

        if(me->def_hdr.objid!=NULL_OBJID && me->def_window.objid!=NULL_OBJID)
         {
	  ACerase_macro
	    (&me->def_hdr,&me->def_id,me->dup,me->Nb_Max_Temp,&me->def_gragad);
         }

  	me->macro_name[0] = 0;
  	me->hdr_name[0] = 0;
	me->temp_name[0] = 0;
  	me->Nb_Max_Temp = 0;
	me->macro_type = mac_exp;
	me->post_placement[0] = '\0';
	me->rep = AC_NO_REP;
        me->def_hdr.objid = NULL_OBJID;
	me->set_index = -1;

        status=om$send(msg = message COm_place.write_form(),
                    targetid = my_id);

	if((me->mytype&1) || me->action == PRO_LOAD)
	 {
	  status = om$send(msg = message COm_place.pro_occ(),
			   targetid = my_id);
	  me->state = WAIT_LOA;
	 }
	else
	 {
	  status = om$send(msg = message COm_place.prompt_macro(),
			   targetid = my_id);
	 }
	break;

      case STO_LOAD : /*| store template obtain by the button load template */
	return OM_W_ABORT;

      case STO_OCC : /*| STORE occurence LOCATED (modify macro or load temp */
	me->hdr = Object_GRid;
	FIg_set_state(me->form_ptr,LOAD_TEMPLATE,0);

        status=om$send(msg = message Root.wild_disconnect(me->located_chansel),
                       targetid = my_id);

	if(!(obj_struct.type & set_generic))
	 {
	  set_obj = &Object_GRid;
	  nb_obj = 1;
          me->set_index = -1;
	 }
	else me->set_index = nb_obj;

        om$get_classid( osnum = set_obj[0].osnum,
			objid =set_obj[0].objid,
			p_classid = &obj_class );

/* get macro name */
        status = om$send(msg = message ACcpx.find_macro(&me->macro_id),
                         targetid = set_obj[0].objid,
                         targetos = set_obj[0].osnum);
	as$status(action = RET_STATUS);


        status = om$send(msg = message ACcpx_defn.ACgive_name(&c),
                         targetid = me->macro_id.objid,
                         targetos = me->macro_id.osnum);
	as$status(action = RET_STATUS);
	strcpy(me->macro_name,c);

        status = om$send(msg = message ACmacro_defn.ACgive_upscan
		             (&me->Nb_Max_Temp,&me->def_properties,&me->dup),
	                   targetid = me->macro_id.objid, 
			   targetos = me->macro_id.osnum );

	/* Does this macro occurence has representation ? */

        status = om$send(msg = message ACncpx.ACget_rep(&me->rep),
                         targetid = set_obj[0].objid,
                         targetos = set_obj[0].osnum);
	if(!(status&1)) me->rep = AC_NO_REP;

	if(me->rep & (AC_DEP_REP | AC_FREE_REP))
         { ideb_rep = 1;
	   me->Temp_List[0].objid = NULL_OBJID;
           me->Temp_Value[0].var.root_pm_st.value =
					 me->rep & ~(AC_DEP_REP | AC_FREE_REP);
           me->Temp_Value[0].type = double_type;
	   ac$get_rep_col(col = me->Temp_Elig);
	 }
	else
	 { 
	   me->rep = 0;
           ideb_rep = 0;
	 }

/* Get maximum template number for located macro */

	nb_temp_occ = -1;
        for(i=0, j=0;i<nb_obj;i++)
	{
          status = om$send(msg = message ACcpx.find_macro(&other_def),
                         targetid = set_obj[i].objid,
                         targetos = set_obj[i].osnum);
	  if(!(status&1) ||
	     me->macro_id.objid != other_def.objid ||
	     me->macro_id.osnum != other_def.osnum ) continue;
	
	  
          status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,
			     NULL,0,NULL,0,0,&nb_temp_other),
                         targetid = set_obj[i].objid,
                         targetos = set_obj[i].osnum);
	  as$status(action = RET_STATUS);
	  
	  if(nb_temp_occ < nb_temp_other)
           {
	    nb_temp_occ = nb_temp_other;
	    other_occ = set_obj[i];
	   }

	  set_obj[j++] = set_obj[i];
	}
        nb_obj = j;

	nb_temp_occ += ideb_rep;

	status = om$send(msg = message COm_place.realloc_template(nb_temp_occ),
			 targetid = my_id);
	
        status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,
			     me->Temp_List+ideb_rep,nb_temp_occ,NULL,
                             0,OM_K_MAXINT,&nb_temp_other),
                         targetid = other_occ.objid,
                         targetos = other_occ.osnum);

          for(i=ideb_rep;i<nb_temp_occ;i++)
	   {
	    status = om$send(msg = message NDnode.NDgive_structure(&msg,
					&rst,&me->ModuleInfo),
                         targetid = me->Temp_List[i].objid,
                         targetos = me->Temp_List[i].osnum);

	    /* allow modify macro even if the macro has lost its template */

	    if(status&msg&1)
	    {
             me->Temp_Value[i].type = rst.type;
	     if(rst.type == double_type)
                me->Temp_Value[i].var.root_pm_st.value=rst.var.root_pm_st.value;
	     else if(rst.type == text_type)
                strcpy(me->Temp_Value[i].var.text_st.text_string,
		       rst.var.text_st.text_string);
	    }
	   else
	    {
	     me->Temp_Value[i].type = me->dup[i].type;
	     if(me->Temp_Value[i].type == double_type) 
	       me->Temp_Value[i].var.root_pm_st.value = 0;
	     if(me->Temp_Value[i].type == text_type) 
	       me->Temp_Value[i].var.text_st.text_string[0] = '\0';
	     }

	   me->Temp_Elig[i].objid = NULL_OBJID;
	   if(me->mytype&1 && nb_obj>1) me->Temp_List[i].objid = NULL_OBJID;
	  }

        if(om$is_ancestry_valid(subclassid = obj_class ,
                       superclassid = OPP_ACncpx_class_id ) == OM_S_SUCCESS)
	     me->hdr_type = HDR_CONS;
	else me->hdr_type = HDR_SYMB;

      /* Initialze names */

      
      me->hdr_name[0] = '\0';
      for(i=0;i<nb_obj;i++)
       {
	char tmp_name[PATH_MAX];
	status = om$send(msg = message GRvg.GRgetname(&msg,tmp_name),
			 targetid = set_obj[i].objid,
			 targetos = set_obj[i].osnum);
        if(status&msg&1)
 	 {
          c = strrchr(tmp_name,':');
          if(c) strncat(me->hdr_name,c+1,PATH_MAX-strlen(me->hdr_name)); 
	  else  strncat(me->hdr_name,tmp_name,PATH_MAX-strlen(me->hdr_name));
         }
	if(i<nb_obj-1 && strlen(me->hdr_name) < PATH_MAX-1)
						       strcat(me->hdr_name,",");
       }
      me->hdr_name[PATH_MAX-1] = '\0';

      status = om$send(msg =  message Root.connect(
	       				me->located_chansel, OM_K_MAXINT,
				        me->hdr.objid, me->hdr.osnum,
	       				his_chan, nb_temp_occ),
				targetid = my_id);

      case STO_MAC : /*| STORE the MACRO LOCATED */

      /* erase old user form if any */
      if(me->user_form_ptr)
       { FIf_delete(me->user_form_ptr);
	 me->user_form_ptr = NULL;
       }

      /* Erase old definition if it was displayed */

      if(me->def_hdr.objid != NULL_OBJID && me->def_window.objid != NULL_OBJID)
       {
	ACerase_macro
	    (&me->def_hdr,&me->def_id,me->dup,me->Nb_Max_Temp,&me->def_gragad);
       }
/*| Store the name and objid of the macro definition */

       ex$get_cur_mod(osnum = &me->hdr.osnum);

/* Does a user specify a specific name for default parameters ? */
       strcpy(me->def_name,me->macro_name);
       specific_param = strrchr(me->macro_name,'$');
       if(specific_param) *specific_param = '\0';
       else strcat(me->def_name,"$def");

       status = om$send(msg = message COm_place.get_macro_defn(&found),
			targetid = my_id);
       as$status(action = RET_STATUS);
       if(!found)
           {  
             me->Entry_Request=NOTHING;
	     me->state=WAIT_MAC;
	     me->action=PRO_MAC;
	     break;
           }

/*| Allocate enought space for template */

       status=om$send(msg = message COm_place.realloc_template(me->Nb_Max_Temp),
		      targetid = my_id);
       as$status(action = RET_STATUS);

/* Initialize template type and template id */
    for(i=0;i<me->Nb_Max_Temp;i++)
      {
       if(me->dup[i].type & (macro_generic|class_generic)) 
	       strcpy(me->Temp_Value[i].var.macro_st.name,me->dup[i].up_scan);
      }

     if(me->action != STO_OCC) nb_temp_occ = 0;
     if(!(me->mytype&1))
      {
       for(i=0;i<me->Nb_Max_Temp;i++)
	 {
	  if(i>=nb_temp_occ)
	   {
	    me->Temp_Value[i].type = me->dup[i].type;
	    if(me->Temp_Value[i].type == double_type) 
	       me->Temp_Value[i].var.root_pm_st.value = 0;
	    if(me->Temp_Value[i].type == text_type) 
	       me->Temp_Value[i].var.text_st.text_string[0] = '\0';
	    me->Temp_List[i].objid = NULL_OBJID;
	   }
	  me->Temp_Elig[i].objid = NULL_OBJID;
	 }
      }

/*| Does the macro support representation management ? */

      if(me->mytype&1 || strcmp(me->dup[0].prompt,TEMP_REP_NAME))
       {
	 me->index_to_locate=0; /*| no or modify */
       }
      else
       {
	 me->index_to_locate=1; /*| yes and place */
	 /* Get the collection with possible representation */
	 /* Get active representation */
         {
	  char NVrep;
          struct GRsymbology 	symb;
	  ac$get_def_NVrep(prep=&NVrep,esymb=&symb);
	  if(!NVrep) NVrep = AC_3D_REP;
	  ac$get_rep_col(col = me->Temp_Elig);
	  me->rep = NVrep;
	  me->Temp_Value[0].var.root_pm_st.value = me->rep;
	  /*"return %d %d\n",me->Temp_Elig[0].objid,me->Temp_Elig[0].osnum */
         }
       }

/* Is there is a variable number of template */

       me->Nb_Max_Var_Temp = me->Nb_Max_Temp;
       me->Nb_Min_Var_Temp = me->Nb_Max_Temp;
      

       if(me->def_properties&ACvariable_template)
         {
          if(me->mytype&1)
	  {
	   /*| Modify does not allow for now adding template */
	   me->Nb_Max_Var_Temp=me->Nb_Min_Var_Temp=me->Nb_Max_Temp=nb_temp_occ;
          }
	  else
	  {
	   int len;
           char cc;
	   /*| Find the minimum set of template */
           len = strlen(me->dup[me->Nb_Max_Var_Temp-1].prompt);
           cc = me->dup[me->Nb_Max_Var_Temp-1].prompt[len-1];
	   if(cc >= '0' && cc <= '9')
            { len--;
              cc = me->dup[me->Nb_Max_Var_Temp-1].prompt[len-1];
	      if(cc >= '0' && cc <= '9') len--;
            }
	   for(i = me->Nb_Max_Var_Temp-2; i>=0 ; i--)
	   {
	    if(strncmp(me->dup[i].prompt,
	 	      me->dup[me->Nb_Max_Var_Temp-1].prompt,len)) break;
            cc = me->dup[i].prompt[len]; if(cc < '0' && cc > '9') break;
           }
	   me->Nb_Max_Temp = i+2;
	   if(nb_temp_occ > i+2) me->Nb_Max_Temp = nb_temp_occ+1;
           me->Nb_Min_Var_Temp = i+2;
          }
	 }

/*"max %d max_var %d\n",me->Nb_Max_Temp,me->Nb_Max_Var_Temp */

      /* disconnect template if any */

      status = om$send(msg = message Root.range_disconnect
			     (me->located_chansel,0,me->Nb_Max_Var_Temp-1),
		       targetid = my_id);
      as$status();


      /* Get placement option and generate name for occurence  */

      if(!(me->mytype&1))
       {
        status = om$send(msg = message COm_place.get_placement_option
					(me->def_name),
		         targetid = my_id);

        status = om$send(msg = message COm_place.generate_hdr_name(),
                       targetid = my_id);
        as$status(action = RET_STATUS);
       }

      /* Delete if necessary previous window */

      if(me->def_window.objid != NULL_OBJID)
   	{
	 if(  me->def_window.osnum != me->def_hdr.osnum
	    ||me->def_hdr.objid == NULL_OBJID)
	  {
	   status = om$send(msg = message Root.delete(1),
                   	    targetid = me->def_window.objid,
                    	    targetos = me->def_window.osnum);
   	   as$status();
	   me->def_window.objid = NULL_OBJID;
	  }
	}

       /* Create if necessary a new window */
       
     if(   me->def_hdr.objid != NULL_OBJID
        && me->def_window.objid == NULL_OBJID 
        && me->def_hdr.osnum != me->ModuleInfo.md_id.osnum)
      {
       int screen,xsize,ysize,xor,yor;
       FIf_get_screen(me->form_ptr,&screen);
       FIf_get_size(me->form_ptr,&xsize,&ysize);
       FIf_get_location(me->form_ptr,&xor,&yor);
       ACcreate_window(me->def_hdr.osnum,&me->def_window,&me->def_gragad,
		       screen,xor,yor+ysize,483,360-ysize+15);
      }

       /* Display if necessary new macro definition */
     if(me->def_hdr.objid != NULL_OBJID && me->def_window.objid != NULL_OBJID)
       ACdisplay_macro
	    (&me->def_hdr,&me->def_id,me->dup,me->Nb_Max_Temp,&me->def_gragad);


   case STO_DEF:
 /* Store default template definition from macro library or search directory */

  if(me->action != STO_OCC && !(me->mytype&1))
    {
     status = om$send(msg = message COm_place.get_default_template(),
		      targetid = my_id);
     as$status(action = RET_STATUS);
    }

/*| Display macro template */

    status = om$send(msg = message COm_place.write_form(),
		    targetid = my_id);

    me->action = CHOSE_TEMP;
    me->state = WAIT_TEM;
    me->Entry_Request = NOTHING;
    break;

   case END_TEMP : /*| END_TEMP */
    i = -1;
    if(  (me->Nb_Min_Var_Temp != me->Nb_Max_Var_Temp)
       &&(me->index_to_locate == me->Nb_Max_Temp-1))
     {
      for(i=0;i<me->Nb_Max_Temp;i++)
       {
        if(me->Temp_List[i].objid != NULL_OBJID) continue;
        if (!(me->dup[i].type & parameter_generic) ||
             (me->dup[i].type == ~0)) break;
       }
     }
    if(i < me->Nb_Min_Var_Temp)
     {
      me->action = NEXT_TEMP;
      me->Entry_Request = NOTHING;
     }
    else
     {
      me->action = CREATE_MACRO;
      me->Nb_Max_Temp = i; 
      me->Entry_Request = NOTHING;
     }
    break;

   case STO_ELI : /*| Store a selected eligible value */
   {
    int row,col,sel,pos;
    char text[80];
    FIfld_get_active_row(me->form_ptr,ELIGIBLE_LIST,&row,&col);
    FIfld_get_text(me->form_ptr,ELIGIBLE_LIST,row,0,80,text,&sel,&pos);
    FIg_erase(me->form_ptr,ELIGIBLE_LIST);
    FIg_enable(me->form_ptr,TEMPLATE_LIST);
    /*" Active row is %d %s\n",row,text */
    status = om$send(msg = message NDmacro.ACgive_structure((int *)&msg,NULL,
					text,&obj_struct,&me->ModuleInfo),
		     targetid = me->Temp_Elig[me->index_to_locate].objid,
		     targetos = me->Temp_Elig[me->index_to_locate].osnum);
    if(status&msg&1)
     {
      me->Temp_Value[me->index_to_locate].type = obj_struct.type;
      me->Temp_Value[me->index_to_locate].var.root_pm_st.value = 
						obj_struct.var.root_pm_st.value;

     }

    /* Redisplay the entire form */
    status = om$send(msg = message COm_place.write_form(),
		     targetid = my_id);
    as$status();
    
    me->Entry_Request = NOTHING;
    me->action = NEXT_TEMP;
    break;
   }
    
        
   case STO_TEMP : /*| Store the template */
	me->Temp_List[me->index_to_locate] = Object_GRid;
	me->Temp_Value[me->index_to_locate].type = obj_struct.type;
	if(obj_struct.type & parameter_generic)
	   me->Temp_Value[me->index_to_locate].var= obj_struct.var;

	/* Connect new template on channel  */

	 status = om$get_objid_at_index(index = me->index_to_locate,
				      p_chanselect = &me->located_chansel,
				      objid = my_id,
				      osnumaddr = &dummy.osnum,
				      objidaddr = &dummy.objid);
	if(status&1)
	 {
          status = om$send(msg = message Root.range_disconnect
				(me->located_chansel,
				 me->index_to_locate,me->index_to_locate),
		               targetid = my_id);
          as$status();
	 }

	status = om$send(msg =  message Root.connect(
					me->located_chansel, OM_K_MAXINT,
				        Object_GRid.objid, Object_GRid.osnum,
	       				his_chan, me->index_to_locate),
				targetid = my_id);

       /* redisplay corresponding line in the form */

	status = om$send(msg = message COm_place.write_template
					     (&Object_GRid,me->index_to_locate),
			 targetid = my_id);


   case NEXT_TEMP : /*| Locate next template */
	me->index_to_locate++;

   case CHOSE_TEMP : /*| Which one is the next template to select */

      /*" hdr_scroll %d\n",me->hdr_scroll*/
        switch(me->hdr_scroll)
         {
          case FULL_SCROLL :
	    i=me->index_to_locate;
	    break;

          case GEOM_SCROLL :
            /*"me->index_to_locate\n",me->index_to_locate */
	    for(i=me->index_to_locate;i<me->Nb_Max_Temp;i++)
	      {
               if(!(me->dup[i].type & parameter_generic) ||
                   (me->dup[i].type == ~0)) break;
	      }
	    break;

	  case NUM_SCROLL :
	    for(i=me->index_to_locate;i<me->Nb_Max_Temp;i++)
	      {
               if((me->dup[i].type & parameter_generic) ||
                  (me->dup[i].type != ~0)) break;
	      }
	    break;
         }
	/*"i %d tot %d\n",i,me->Nb_Max_Temp */
	me->index_to_locate = i;

        if(   (me->index_to_locate>=me->Nb_Max_Temp)
	    &&(me->Nb_Min_Var_Temp != me->Nb_Max_Var_Temp)
	    &&(me->Nb_Max_Temp     < me->Nb_Max_Var_Temp))
           {
	    /*| Prompt to locate following additional template */
	    me->index_to_locate = me->Nb_Max_Temp;
            if(!(me->def_properties&ACkeep_variable_template))
	     {
	      me->Temp_List[me->index_to_locate].objid = NULL_OBJID;
	      me->Temp_Value[me->index_to_locate].var.root_pm_st.value= 0;
	     }
	    me->Nb_Max_Temp++;

	      status = om$send(msg = message COm_place.write_template
							    (me->Temp_List+i,i),
			       targetid = my_id);
	   }

        if(me->index_to_locate>=me->Nb_Max_Temp)
	 {
	  /*|Go back to first template or ready to place */
	  if(me->rep) ideb_rep = 1;
	  else 	      ideb_rep = 0;
          for(i=ideb_rep;i<me->Nb_Max_Temp;i++)
            {
             if(me->Temp_List[i].objid != NULL_OBJID) continue;
             if (!(me->dup[i].type & parameter_generic) ||
                  (me->dup[i].type == ~0)) break;
	    }
	  
	  if(i<me->Nb_Max_Temp && !(me->mytype&1))
           {
            /*| go back in template list */
	    me->Entry_Request = NOTHING;
	    me->action = CHOSE_TEMP;
	    me->index_to_locate = 0;
	    break;
	   }
	  else
	   {
	    /*| Have all the template */
            me->Entry_Request = PROMPT;
	    me->state = FULL_DEF;

            FIfld_set_select(me->form_ptr,TEMPLATE_LIST,-1,0,TRUE);
            FIfld_set_select(me->form_ptr,TEMPLATE_LIST,-1,1,TRUE);
            FIfld_set_select(me->form_ptr,TEMPLATE_LIST,-1,2,TRUE);

	    UI_status("");
	    if(me->mytype&1)
	      {ex$message( msgnumb = AS_P_MdPlPaFo);}
	    else
	      {status = om$send(msg = message COm_place.generate_hdr_name(),
			       targetid = my_id);
	       ex$message( msgnumb = AS_P_MdOcPaFo);}
            break;
	   }
         }

      case PRO_TEMP : 
	status = om$send(msg = message COm_place.pro_template(),
			 targetid = my_id);
        break;


      case CREATE_MACRO : /*" create macro with %d temp\n",me->Nb_Max_Temp */
        FIg_set_state(me->form_ptr,FORM_EXEC,1);
	if(me->mytype&1) {ex$message(msgnumb = AS_S_MdOcPro);}
	else             {ex$message(msgnumb = AS_S_PlOcPro);}

	/* Loop on the object in fence */

	for(i_occ = 0; i_occ<1 || i_occ < me->set_index ; i_occ ++)
	 {
	  /* 
             Take if necessary template from fence or generate it if missing
	     and verify if not consumed
	  */

	  status = om$send(msg = message COm_place.gen_missing_temp(&msg,i_occ),
			 targetid = my_id);
	  if(!(msg&1)) continue;
	
	  /* Verify representation consistency of parent */ 

	  status = om$send(msg = message COm_place.verify_temp_rep(&msg),
			 targetid = my_id);
	  if(!(msg&1)) continue;

	  /* Place or modify the construction */

	  if(me->mytype&1)
	   {
            status = om$send(msg = message COm_place.modify_macro(&msg),
			     targetid = my_id);
	   }
	  else 
	   {
     	    status = om$send(msg = message COm_place.generate_hdr_name(),
		      	     targetid = my_id);
            status = om$send(msg = message COm_place.place_macro(),
			 targetid = my_id);
     	    /*| Automatic name generation for next occurences */

     	    status = om$send(msg = message COm_place.generate_hdr_name(),
		      	     targetid = my_id);
     	    as$status();
	   }

	  /* remove consumed element */
	   
	   status = om$send(msg = message COm_place.rem_consumed_temp(i_occ),
			 targetid = my_id);

         }
 	 ex$message(msgnumb =  AS_S_ToutBon);

	/* Remove now consumed elements from template list */

	status = om$send(msg = message COm_place.rem_consumed_temp(-1),
			 targetid = my_id);
	 
	/* retrieve set Grid instead of its member */
	for(i=0;i<me->Nb_Max_Temp;i++)
	 {
	  status = om$get_objid_at_index(index = i,
				      p_chanselect = &me->located_chansel,
				      objid = my_id,
				      osnumaddr = &dummy.osnum,
				      objidaddr = &dummy.objid);
	  if(status&1) me->Temp_List[i] = dummy;
	 }
	/* Continue the command */
   	me->Entry_Request = NOTHING;
	if(me->mytype&1)
	 {
	  me->action = PRO_MAC;
	  me->state  = WAIT_MAC;
	 }
	else
	 {
	  me->index_to_locate = 0;
	  me->action = CHOSE_TEMP;
	  me->state = WAIT_TEM;
	 }

        FIg_set_state(me->form_ptr,FORM_EXEC,0);
 	break;

    }/* end switch (me->action) */
 
   /*" Entry_Request -->%d bef switch\n", me->Entry_Request */

    switch (me->Entry_Request)
    {
      case PROMPT :  /*| PROMPT */
        Token = GRget_token(&status,TokenList,&Input_Mask,&Event_Ac,
                &Size,response,response_data);
	/* Trick to go to STO_MAC */
	if(*response == STRING && me->state == WAIT_MAC)
	  {
	   strcpy(me->macro_name,response_data);
	   for(Token = 0; TokenList[Token] != LOC_PARAM ; Token++);
	  }
	break;

      case PARENT :  /*| POINT */
        if(me->Obj_Generic&other_generic) me->Obj_Generic |= debug_type;
        if(me->Obj_Generic&curve_generic) me->Obj_Generic |=
					     line_generic|conic_generic;


/*"Obj_generic %x\n",me->Obj_Generic */
	Token = as$get_parent(event1 = &Event_Loc, event2 = &Event_Ac,
			      type_generic = me->Obj_Generic,
			      macro_name = me->Obj_Name,
			      returned_obj = &Object_GRid,
			      returned_context = &Context_GRid,
			      returned_struct = &obj_struct,
			      display_flag = Display_Flag);

         /* If the user as selected a graphic set
            - get the list of selected objects
	    - verify that the nmber of located elements is compatlble with
	      already located sets if any
         */

         if(TokenList[Token] == LOC_PARENT)
           {
	    as$start_fence(set = &Object_GRid,
			   nb_obj = &nb_obj, p_obj = &set_obj,
			   response = response, response_data = response_data,
			   macro_name = me->Obj_Name,
			   type_generic = me->Obj_Generic);

	    if(nb_obj > 1 && me->set_index >= 0 && nb_obj != me->set_index)
	      {
               status = om$get_channel_count(objid = my_id,
                                            p_chanselect = &me->located_chansel,
                                            count = &nb_set);
	       if(nb_set>1) nb_obj = 0;
	       else 
		{
	 	 status = om$get_objid_at_index(index = me->index_to_locate,
				      p_chanselect = &me->located_chansel,
				      objid = my_id,
				      osnumaddr = &dummy.osnum,
				      objidaddr = &dummy.objid);
		 if(!(status&1)) nb_obj = 0;
		}
	       if(nb_obj == 0)
	        { ex$message(msgnumb = AS_S_BadNum); }
	      }

	    if(nb_obj <= 0)
               {
                /* fence has not been accepted or nothing inside */
	        for(Token=0 ; TokenList[Token] != GR_UNKNOWN_TYPE ; Token++);
		break;
               }

	    if(!(obj_struct.type&set_generic))
             {
	      as$make_source(go_grid = Object_GRid,
			 context_grid = Context_GRid,
			 as_os = me->ModuleInfo.md_id.osnum,
			 as_grid = &Object_GRid);
             }
	    else
	     {
	      me->set_index = nb_obj;
	     }
	    break;
	   }
	 else if(!(me->Obj_Generic&parameter_generic) || *response != STRING) 
									  break;

	 /* jla may 93 : when the requested parent is for example 
	    point | parameter, try to get it as a double value if the
	    initial locate fails */
	{
	 long len = strlen(response_data)+1;
         status = ex$putque(msg = &msg, response = response,
                            byte = &len , buffer = response_data);
	 param_type = double_type;
	}


      case PARAM :  /*| PARAM */
	if(me->Entry_Request == PARAM) param_type = me->Obj_Generic;
        Token = ASget_all_param (
		&status,			TokenList, 
		&Event_Loc, 			&Event_Ac,
                &Locate_Mask, 			&Input_Mask, 
		&Size, 				&Display_Flag,
                response, 				response_data, 
		me->loc_prompt,          me->acc_prompt, 
		me->reloc_prompt,        &me->attr, 
		&me->locate_stack,	 param_type,
	        &Object_GRid, &Param);

        /* The function NDset_value is called when it is required to scale
           the input value by the scale factor */

        if( me->scale_flag == 1 && TokenList[Token] == LOC_PARAM &&
            ACcheck_expression_name(response_data) )
         {
          Param = me->scale_fact*Param ;
          status = om$send(msg = message expression.NDset_value
                                 (NULL,Param,&me->ModuleInfo,&exp_rc),
                           targetid = Object_GRid.objid,
                           targetos = Object_GRid.osnum);
          as$status(action = RET_STATUS);
         } 

	/* To avoid problem with fence and with text expression */
	if(TokenList[Token] == LOC_PARAM)
	 {
	  status = om$send(msg = message NDnode.NDgive_structure
				(&msg,&obj_struct,&me->ModuleInfo),
			   targetid = Object_GRid.objid,
			   targetos = Object_GRid.osnum);
	  as$status(action = RET_STATUS);
	 }
	break;

      case NOTHING : /*| NOTHING */
	break;

    }/* switch (me->Entry_Request) */

    if (me->Entry_Request != NOTHING)
    {
      me->action = (IGRint) Action   [me->state][Token];
      me->state  = (IGRint) NewState [me->state][Token];
/*      FIg_erase(me->form_ptr,ERROR_BOX); */
    }
  /*" action %d state %d\n",me->action,me->state    */
  }while(me->Entry_Request == NOTHING || (TokenList[Token] != GR_UNKNOWN_TYPE));
  /*" response %d status %d \n", *response, status */

  return(OM_S_SUCCESS);
}

/* This method is called to place the defined macro */

method place_macro()
{
 IGRlong status,msg;
 int i, construction, suc, prop,temp_name_len;

 struct GRid go;
 char template_name[PATH_MAX];
 GRclassid obj_class, objclass;
 struct NDcp_struct cp_info;
 short active_level;
 struct IGRdisplay active_display;
 char dir_name[PATH_MAX];
 enum GRdpmode dpmode = GRbd;

 extern GRclassid OPP_ACcond_def_class_id;

/* Which type of construction needs to be performed */

  construction = (me->macro_type*16)|me->hdr_type;
  suc = MSSUCC;
  cp_info.list = NULL;

  /* get active symbology and directory */

     status = om$send(msg = message COm_place.get_active_symb
				(&active_level,&active_display,dir_name),
		      targetid = my_id);
     as$status(action = RET_STATUS);

  om$get_classid( osnum = me->macro_id.osnum,
		  objid = me->macro_id.objid,
		  p_classid = &objclass );

  if (om$is_ancestry_valid(subclassid = objclass,
                         superclassid = OPP_ACcond_def_class_id ) == OM_S_SUCCESS)
  {
	COm_get_condit_def_hdr( &msg, &me->macro_id, &me->def_hdr, 
				me->Nb_Max_Temp, me->Temp_List,
				&me->ModuleInfo);
  }

  switch(construction)
   {
    case sym_sym :
     status = om$construct( classname = "ACsym",
			    osnum = me->hdr.osnum, 
			    p_objid= &me->hdr.objid );
     as$status( action = RET_STATUS );
     status = om$send( msg      = message ACsym.ACmplace(&suc,
				       AChdr_nodisplay,
				       me->macro_name, 
		                       me->Nb_Max_Temp,
                                       me->Temp_List,
				       &me->ModuleInfo ),
		      targetid = me->hdr.objid,
 		      targetos = me->hdr.osnum );
     as$status();
     break;


    case exp_cons : 
    case exp_symb :
    case exp_grap :

     if(construction == exp_cons || construction == exp_grap)
	       status =   om$construct(	classname = "ACconst",
					osnum = me->hdr.osnum, 
					p_objid= &me->hdr.objid );
     else
	       status =   om$construct(	classname = "ACheader",
					osnum = me->hdr.osnum, 
					p_objid= &me->hdr.objid );
    as$status( action = RET_STATUS );

    status = om$send( msg = message ACconst.ACmplace_from_def(&suc,
				       AChdr_nodisplay,me->rep, me->macro_name, 
		                       me->Nb_Max_Temp, me->Temp_List,
				       &me->def_hdr, &me->ModuleInfo ),
		      targetid = me->hdr.objid,
 		      targetos = me->hdr.osnum );
    as$status();
    break;


   case exp_drop:
    status =   om$construct(classname = "ACexpand",
			    osnum     = me->hdr.osnum, 
			    p_objid   = &me->hdr.objid );
    as$status( action = RET_STATUS );

    status = om$send(msg = message ACexpand.ACmplace(&suc,0,
					  me->macro_name, me->Nb_Max_Temp,
                                      me->Temp_List, &cp_info, &me->ModuleInfo),
	             targetid = me->hdr.objid,
 		     targetos = me->hdr.osnum );
    as$status();
    break;

   case ci_sym:
    status = om$construct(classname = "ACci_header",
			      osnum = me->hdr.osnum, 
			      p_objid= &me->hdr.objid );
    as$status( action = RET_STATUS );

    status = om$send( msg = message ACconst.ACmplace_from_def(&suc,
                                       AChdr_nodisplay,me->rep, me->macro_name,
                                       me->Nb_Max_Temp, me->Temp_List,
                                       &me->def_hdr, &me->ModuleInfo ),
                      targetid = me->hdr.objid,
                      targetos = me->hdr.osnum );
    as$status();
    break;

   case ci_cons:
   case ci_grap:
    status = om$construct(classname = "nci_macro",
			    osnum = me->hdr.osnum, 
			    p_objid= &me->hdr.objid );
    as$status( action = RET_STATUS );
    prop = AChdr_nodisplay;
    status = om$send( msg = message ci_macro.init(&suc, prop, me->macro_name,
			     me->Nb_Max_Temp, me->Temp_List,0, &me->ModuleInfo),
		      targetid = me->hdr.objid,
 		      targetos = me->hdr.osnum );
    as$status();
    break;
   }

/* Delete occurence if error at placement */

  if(!(status&suc&1))
   {
    OM_S_OBJID save_md;
    save_md = me->ModuleInfo.md_id.objid;
    me->ModuleInfo.md_id.objid = NULL_OBJID;
    status = om$send(msg = message GRgraphics.GRdelete
				       ((IGRlong *) &suc,&me->ModuleInfo),
		     targetid = me->hdr.objid,
		     targetos = me->hdr.osnum );
    ex$message(msgnumb = AS_S_PlaFail);
    me->ModuleInfo.md_id.objid = save_md;
    return OM_W_ABORT;
   }

  if(me->hdr_type != HDR_DROP)
    {
       if(me->hdr_symb) COmchg_var_symb(me->hdr_symb,&me->hdr,
			            active_level,&active_display,
				    &me->ModuleInfo);
    }

  /*" Is there a post placement ppl defined --> %s ?\n",me->post_placement */

  if(me->hdr_type != HDR_DROP && me->post_placement[0])
   {
    int ci_entry;
    OM_S_OBJID file_id;

    ci_entry = 0;
	
    status = ci$load(file_name = me->post_placement,
		 file_id   = &file_id,
		 load = LOAD);

    if(status&1) status = om$send(msg = message ci.is_entry_point
						   (&ci_entry,"post_placement"),
                    		  targetid = file_id ,
                    		  targetos = OM_Gw_TransOSnum_0);
    as$status ( );

    if(ci_entry&1) 
     {
      status = om$send(msg = message ci.set_value ((int *)&msg, "MACRO_ID",
				(char *)&me->hdr , sizeof(struct GRid)),
                       targetid = file_id,
                       targetos = OM_Gw_TransOSnum_0);
      as$status ( );

      status = om$send(msg = message ci.set_value ((int *)&msg, "MOD_ENV",
			      (char *)&me->ModuleInfo ,sizeof(struct GRmd_env)),
                       targetid = file_id,
                       targetos = OM_Gw_TransOSnum_0);
      as$status ( );

      if(status&1) status = ci$run( file_id = &file_id,
				    entry = "post_placement");
      as$status ( );
     }
   }

     if(me->hdr_type != HDR_DROP)
      {
       status = om$send( msg = message GRgraphics.GRdisplay
                                         (&msg,
                                          &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                          &dpmode,
                                          &me->ModuleInfo.md_id),
		       targetid = me->hdr.objid,
		       targetos = me->hdr.osnum);
      }

     /* Drop it if requested */

     if(me->hdr_type == HDR_GRAPHIC)
      {
       status = om$send(msg     = message  ACcpx.ACdrop(&me->ModuleInfo ),
	                targetid = me->hdr.objid,
 			targetos = me->hdr.osnum );
       as$status( );
      }
     else if(me->hdr_type == HDR_DROP)
      {
       struct GRid obj_to_display;
       obj_to_display.osnum = me->ModuleInfo.md_id.osnum;
       for(i=0 ; i<cp_info.nb_obj ; i++)
	 {
	  if(!(cp_info.list[i].position & ND_BODY)) continue;
          obj_to_display.objid = cp_info.list[i].clone;
	  if(me->hdr_symb) COmchg_var_symb(me->hdr_symb,&obj_to_display,
			            active_level,&active_display,
				    &me->ModuleInfo);
	  status = om$send(msg = message GRgraphics.GRdisplay
                                         (&msg,
                                          &me->ModuleInfo.md_env.matrix_type,
                                          me->ModuleInfo.md_env.matrix,
                                          &dpmode,
                                          &me->ModuleInfo.md_id),
		       	   targetid = obj_to_display.objid,
		           targetos = obj_to_display.osnum);
/*     	  as$status(); */
	 }
	if(cp_info.list != NULL)
			{om$dealloc(ptr = cp_info.list); cp_info.list = NULL;}

        status = om$send(msg     = message  ACcpx.ACdrop(&me->ModuleInfo ),
	                targetid = me->hdr.objid,
 			targetos = me->hdr.osnum );
       as$status( );
      }

 /* Give it a name if it does not already have one */

   if(me->hdr_type != HDR_GRAPHIC && me->hdr_name[0] != '\0' && dir_name[0] != '\0')
    {
     char tmp_name[PATH_MAX];
     tmp_name[0] = '\0';
     status=om$send(msg = message  GRvg.GRgetname(&msg,tmp_name),
                    targetid = me->hdr.objid,
                    targetos = me->hdr.osnum);

     if(!(msg&1) || tmp_name[0] == '\0')
      {
       sprintf(tmp_name,"%s:%s",dir_name,me->hdr_name);
       status=om$send(msg = message  GRvg.GRputname(&msg,tmp_name),
                    targetid = me->hdr.objid,
                    targetos = me->hdr.osnum);
      }


/* Give a name to the template */

   if( me->temp_name[0] == '\0' )
    {
     /*| Does not name template */
    }
   else
    {
      
     di$pwd(dirname = template_name); /* di$add_name does not work with  */
				      /* relative name if diff os !!!!!! */
     if(me->temp_name[0] != '.')
      {
       strcat(template_name,":temp_");
       strcat(template_name,me->hdr_name);
       status = di$mkdir(dirname =template_name);
      }
     else
      {
       /* name in current directory */
       status = 1;
      }

     strcat(template_name,":");
     temp_name_len = strlen(template_name);
     if(status&1)
       {
        for(i = 0; i<me->Nb_Max_Temp; i++)
        {
	 strcpy(template_name+temp_name_len,me->dup[i].prompt);

	 /*"adding name %s\n",template_name */
	 go = me->Temp_List[i];
         om$get_classid(objid = go.objid,
                        osnum = go.osnum,
                        p_classid = &obj_class);

	 if(om$is_ancestry_valid(superclassid = OPP_ASsource_class_id,
				      subclassid = obj_class) == OM_S_SUCCESS)
	  {
	   status = om$send(msg = message NDnode.ASreturn_go(&go,NULL,NULL),
			    targetid = me->Temp_List[i].objid,
			    targetos = me->Temp_List[i].osnum);
 	   if(go.osnum != me->Temp_List[i].osnum) continue;
           om$get_classid(objid = go.objid,
                          osnum = go.osnum,
                          p_classid = &obj_class);
	  }

	 if(om$is_ancestry_valid(superclassid = OPP_GRvg_class_id,
				 subclassid = obj_class) == OM_S_SUCCESS) 
	  {
	   /*"to go %d %d\n",go.objid,go.osnum */
           status = om$send(msg = message GRvg.GRputname(&msg, template_name),
                          targetid = go.objid,
                          targetos = go.osnum);
	   as$status();
	   if(!(msg&1)) di$report_error(sts = msg);

	  }
	 
	 else if(om$is_ancestry_valid(superclassid = OPP_expression_class_id,
				      subclassid = obj_class) == OM_S_SUCCESS)
	  {
	   /*" to expression %d %d\n",go.objid,go.osnum */
           status = di$add_name(objname = template_name,
                              objid = go.objid,
                              osnum = go.osnum);
	   if(!(status&1)) di$report_error(sts = status);

	  }
	 else 
          { printf("Cant not name %d %d\n",me->Temp_List[i].objid,
					   me->Temp_List[i].osnum);
          }
	}
       }
      }

    }
return OM_S_SUCCESS;
}

method generate_hdr_name()
{
 IGRlong status,msg;
 char *c,*c1,*strrchr();
 int i;
 struct GRid Object_GRid;
 char tmp_name[PATH_MAX];
 short dummy_level;
 struct IGRdisplay dummy_display;
 
  /*| Automatic name generation for occurences */

 if(me->hdr_name[0] == '\0') return OM_S_SUCCESS;

 status = om$send(msg = message COm_place.get_active_symb(&dummy_level,
					&dummy_display,tmp_name),
		  targetid = my_id);
 if(!(status&1)) tmp_name[0] = '\0';
 sprintf(tmp_name,"%s:%s",tmp_name,me->hdr_name);

/* 
   searchs if an object with that name already exists 
*/

 msg = di$translate(objname = tmp_name,
                    p_objid = &Object_GRid.objid,
                    p_osnum = &Object_GRid.osnum );

 if( msg == DIR_S_SUCCESS)
  {
  /* if the name is name_##, find pointer to the suffix */ 

  c = strrchr(tmp_name,'_');

  if(c != NULL)
   {
    i = strtol(c+1,&c1,10);
    if(*c1 != '\0') c = NULL;
   }

  if(c == NULL) c = tmp_name + strlen(tmp_name);

  /* find correct suffix */

  for(i=0;i<1000;i++)
   {
    if(i<100) sprintf(c,"_%02d",i);
    else      sprintf(c,"_%03d",i);
    /*" hdr_name %s\n",me->hdr_name*/
    msg = di$translate(objname = tmp_name,
                       p_objid = &Object_GRid.objid,
                       p_osnum = &Object_GRid.osnum );
    if( msg != DIR_S_SUCCESS) break;
   }

  /* generate name + suffix */

  if(i>=1000) me->hdr_name[0] = '\0';
  else
   { c = strrchr(tmp_name,':');
     if(c == NULL) c = tmp_name;
     else c++;
     strcpy(me->hdr_name,c);
   }
 }

/* Write the name on the form */

 if(me->form_names_ptr) 
  COm_display_names(me->form_names_ptr,me->hdr_name, me->temp_name);

 return OM_S_SUCCESS;
  
}

/* 
   This method retrieves placement option of the macro,
   as they have been stored in the macro library.

	Sudha	09/02/94    Change mess[80] to mess[PATH_MAX] -fix TR# 119417986
			    when the macro name is too large including the path
			    during the place macro when the macro name is keyed
                            in this is resulting in abort. 
*/

method get_placement_option(char *def_name)
{
 char *c, *strrchr();
 long status,loc_msg;
 struct ret_struct obj_struct;
 char mess[PATH_MAX];/* TR#119417986 - change mess size from 80 to PATH_MAX */
 int i,j;
 char form_name[PATH_MAX];
 struct ACrg_coll *list_att = NULL;
 int generic_inter,nb_att;
 extern COm_user_place_router();
 int *ptr=NULL,g_type;

 

/* Get directory with placement option */

 me->def_id.objid = NULL_OBJID;

 if(def_name != NULL && def_name[0] != '\0')
  {
   c = strrchr(def_name,':');
   if(c) c++;
   else c = def_name;
   di$give_pathname(osnum = me->macro_id.osnum,
		    pathname = mess);
   
   sprintf(mess,"%s:constructs:%s",mess,c);
   di$translate(objname = mess,
		p_objid = &me->def_id.objid,
		p_osnum = &me->def_id.osnum);
  }

 if(me->def_id.objid == NULL_OBJID)
   COm_get_option_grid(&me->macro_id,&me->def_id,NULL);

/* Get placement options like symbology, level ... */

   COm_get_options_bis(&me->macro_id,&me->def_id,
		   &me->hdr_symb,&me->hdr_scroll,&me->hdr_type,
		   &me->hdr_def,me->search_path,me->post_placement,
		   &me->def_hdr,
		   &me->ModuleInfo);
   /*"Def_hdr %d %d\n",me->def_hdr.objid,me->def_hdr.osnum */

    if(me->macro_type == mac_exp)
      {
           if(me->def_properties&ACno_symbol && me->hdr_type == HDR_SYMB)
                                                        me->hdr_type = HDR_CONS;

           if(me->def_properties&ACno_construct && me->hdr_type == HDR_CONS)
                                                        me->hdr_type = HDR_DROP;

           if(me->def_properties&ACno_drop && me->hdr_type == HDR_DROP)
                                                        me->hdr_type = HDR_CONS;
       }

/*| Get name generation template for occurences */

 status = loc_msg = MSFAIL;
 if(me->def_id.objid != NULL_OBJID)
  {
   status = om$send(msg = message NDmacro.ACgive_structure((int *)&loc_msg,NULL,
				     "~~hdr_name",&obj_struct,&me->ModuleInfo),
		     targetid = me->def_id.objid,
		     targetos = me->def_id.osnum);
   if(status&loc_msg&1)
     {if(obj_struct.type == text_type) 
	strcpy(me->hdr_name,obj_struct.var.text_st.text_string);
      else loc_msg = MSFAIL;
     }
  }

 
 if(!(status&loc_msg&1))
  {
   c = strrchr(me->macro_name,':');
   if(c == NULL) c=me->macro_name;
   else c = c+1;
   strcpy(me->hdr_name,c);
   strcat(me->hdr_name,"_00");
  }


/*| get user form description if any and store gadget label  */
 
  list_att = (struct ACrg_coll *) 
	      om$malloc(size = me->Nb_Max_Var_Temp *sizeof(struct ACrg_coll));

  ac$get_def_interface( rc = &loc_msg,
                        def_name = me->macro_name,
			form_name = form_name,
                        generic_inter = &generic_inter,
                        len_list = me->Nb_Max_Temp,
                        list_att = list_att,
                        count_att = &nb_att);

  if(form_name[0] != '\0')
   {
    /*" user form is %s\n",form_name */
    FIf_new(me->form_ptr,form_name,COm_user_place_router,&me->user_form_ptr);
    if(!me->user_form_ptr)
     {
      ex$message(msgnumb = AS_S_CntFinF,type = "%s",
		 var = `form_name`);
     }
    else
     {
      FIf_display(me->user_form_ptr);
      FIf_set_cmd_oid_os( me->user_form_ptr, my_id, OM_Gw_current_OS );

      for(i=0;i<me->Nb_Max_Var_Temp;i++)
       {
        for(j=0;j<nb_att;j++)
        {
         if(strcmp(me->dup[i].prompt,list_att[j].name) == 0)
 	  {
	  /* " gadget %d for temp %d\n",list_att[j]/desc/value/att_exp,i */
          /* trick to store gadget number in an hole of ret_struct */
	  ptr = (int *)  (me->Temp_Value+i);
          ptr[1]  = list_att[j].desc.value.att_exp;
	  break;
	  }
        }
	if(j >= nb_att)
	 {
	  ex$message(msgnumb = AS_S_CntFinG,type = "%s",
		     var = `me->dup[i].prompt`);
	 }
	else 
	 {
	  status = FIg_get_type(me->user_form_ptr,ptr[1],&g_type);
	  if(status!=FI_SUCCESS || (g_type!=FI_FIELD && g_type!=FI_MULTI_COL))
	   {
	    ptr[1] = 0;
	    ex$message(msgnumb = AS_S_InvG,type = "%s",
		       var = `me->dup[i].prompt`);
	   }
	 }
       }
      }
   }

   if(list_att) om$dealloc(ptr = list_att);

   return OM_S_SUCCESS;
}

/*
   This method initializes default templates,
   either from values stored in the macro library, or if a search path has
   been initialized from the contents of this directory
*/

method get_default_template()
{
 IGRlong msg,status;
 char default_dir[PATH_MAX];
 struct GRid def_dir;
 int i,ideb_rep;
 struct ret_struct rst;
 struct GRid template;
 

/*| Find directory name from search path */
     
/*"search_path %s hdr_def %d\n",me->search_path,me->hdr_def */

 def_dir.objid = NULL_OBJID;

 if(me->hdr_def != NO_OPTION)
  {
   if(me->hdr_def == IN_MACRO_LIB)
    {
     /*| default parameter in macro library */
      def_dir = me->def_id;
    }

   else if(me->hdr_def == USER_SPECIFIED)
    {
     /*| default parameter in user defined directory */
     if(me->search_path[0] == ':') 
      {
       di$give_pathname(osnum = me->ModuleInfo.md_id.osnum,
			pathname = default_dir);
       strcat(default_dir,me->search_path);
      }
     else
      {
       di$pwd(dirname = default_dir);
       if(me->search_path[0] != '.')
	 {strcat(default_dir,":"); strcat(default_dir,me->search_path);}
       else if(me->search_path[1] == ':') 
	 {strcat(default_dir,me->search_path+1);}
       }
     
     /*"global name path %s\n",default_dir*/

      msg = di$translate( objname =  default_dir,
			   p_objid = &def_dir.objid,
			   p_osnum = &def_dir.osnum);
      if(!(msg&1)) def_dir.objid = NULL_OBJID;
    }
  }
  /*"def_dir %d %d\n",def_dir.objid,def_dir.osnum */

/*| Initialize default template from default parameter box */
/*  For each template, find if there is a member with a matching name */

   if(me->rep) ideb_rep = 1;
   else	  ideb_rep = 0;
   /*"ideb %d max_temp %d\n",ideb_rep,me->Nb_Max_Temp */
   for(i=ideb_rep;i<me->Nb_Max_Temp;i=i+1)
    {
     me->Temp_List[i].objid = NULL_OBJID;
     msg = status = OM_W_ABORT;

     if(def_dir.objid != NULL_OBJID)
      {
       /*| Search first in user defined path */
       status = om$send(msg=message IGRdir.translate((DIint *)&msg, 
					       me->dup[i].prompt,
                                               0,NULL,&template.objid),
                      targetid = def_dir.objid,
                      targetos = def_dir.osnum );
       as$status();
       template.osnum = def_dir.osnum;
      }
     if(msg&status&1)
      {
       /*| control its type */
       status = NDctl_parent_type(&msg,me->dup[i].type,me->dup[i].up_scan,
				  &template,&me->ModuleInfo);
      }

     if( !(msg&status&1)
	&& me->def_id.objid != NULL_OBJID
	&& me->def_id.objid != def_dir.objid)
      {
       /*| if not found, search in macro library parameter box if not the same*/
       status = om$send(msg=message IGRdir.translate((DIint *)&msg,
                                               me->dup[i].prompt,
                                               0,NULL,&template.objid),
                      targetid = me->def_id.objid,
                      targetos = me->def_id.osnum );
       template.osnum = me->def_id.osnum;
       as$status();

       if(msg&status&1)
        {
         /*| control its type */
         status = NDctl_parent_type(&msg,me->dup[i].type,me->dup[i].up_scan,
				    &template,&me->ModuleInfo);
        }
      }

/* If the template has been found, get its value or create a source on it */

     if(status&msg&1)
      {
       if(me->dup[i].type&parameter_generic)
        {
         /*| expression, get its value */
       
         status = om$send(msg = message NDnode.NDgive_structure(&msg,
                                                          &rst,&me->ModuleInfo),
                        targetid = template.objid,
                        targetos = template.osnum);
         if(rst.type == double_type) 
	 {
	  if((me->dup[i].type & double_type) == double_type)
	   {
     	    if(template.osnum == me->ModuleInfo.md_id.osnum)
	    					    me->Temp_List[i] = template;
	    me->Temp_Value[i].var.root_pm_st.value= rst.var.root_pm_st.value;
	    me->Temp_Value[i].type= double_type;
	   }
	 }
         else if(rst.type == text_type)
	 {
	  if((me->dup[i].type & text_type) == text_type)
	   {
            if(template.osnum == me->ModuleInfo.md_id.osnum)
	    					    me->Temp_List[i] = template;
	    strcpy(me->Temp_Value[i].var.text_st.text_string,
				 rst.var.text_st.text_string);
	    me->Temp_Value[i].type= text_type;
	   }
	 }
      }
     else if(template.osnum == me->ModuleInfo.md_id.osnum)
      {
       as$make_source(go_grid = template,
		      as_os = me->ModuleInfo.md_id.osnum,
		      as_grid = me->Temp_List+i);
      }
    }
   /*"Temp_List[%d] %d %d\n",i,me->Temp_List[i].objid,me->Temp_List[i].osnum */
  }
 return OM_S_SUCCESS;
}
method prompt_macro()
{
  ex$message(msgnumb = AS_P_EnMcNm);
  me->Entry_Request=PROMPT;
  return OM_S_SUCCESS;
}

method get_macro_defn(int *found)
{
 long status;
 GRclassid obj_class;
 extern GRclassid OPP_ACcond_def_class_id;

 *found = 0;

 status = ac$find_macro_defn( action	= ACfind_load,
		       	      macro_name  = me->macro_name,
		              p_macro_defn_id 	= &me->macro_id );

 if (IF_NULL_OBJID(me->macro_id.objid))
  { ex$message(msgnumb = AS_S_MacNotFnd ); return OM_S_SUCCESS; }

        
/*| Take the description of the macro */

 status = om$send(msg = message ACmacro_defn.ACgive_upscan
		             (&me->Nb_Max_Temp,&me->def_properties,&me->dup),
	                   targetid = me->macro_id.objid, 
			   targetos = me->macro_id.osnum );
 as$status(action = RET_STATUS);

/* Control if it can be placed */

 if((me->def_properties&ACwith_instances) && !(me->mytype&1))
    { ex$message(msgnumb = AS_S_McSpe); return OM_S_SUCCESS; }

/* Get definition type */

  om$get_classid( osnum = me->macro_id.osnum,
		  objid =me->macro_id.objid,
		  p_classid = &obj_class );
/* To not place condit in drop mode */

  if(om$is_ancestry_valid(subclassid = obj_class ,
                       superclassid = OPP_ACcond_def_class_id ) == OM_S_SUCCESS)
   {
    me->def_properties = me->def_properties | ACno_drop;
   }

  if(om$is_ancestry_valid(subclassid = obj_class ,
                       superclassid = OPP_ci_mac_def_class_id ) == OM_S_SUCCESS)
	  {
	   me->macro_type = mac_ci;
	   if(me->hdr_type != HDR_CONS && me->hdr_type != HDR_SYMB )
              me->hdr_type = HDR_CONS;
	  }
  else if(me->def_properties&ACcant_place_sym)
	  {
	   me->macro_type = mac_exp;
           if(me->def_properties&ACno_symbol && me->hdr_type == HDR_SYMB)
						        me->hdr_type = HDR_CONS;

           if(me->def_properties&ACno_construct && me->hdr_type == HDR_CONS) 
						        me->hdr_type = HDR_DROP;

	   if(me->def_properties&ACno_drop && me->hdr_type == HDR_DROP)
	 						me->hdr_type = HDR_CONS;
	  }
  else
	  { /*| Initialize for sym */
	   me->macro_type = mac_sym;
	   me->hdr_type = HDR_SYMB;
	  }

  *found = 1;
  return OM_S_SUCCESS;
}

method pro_occ()
{
 me->attr.properties = LC_DP_ONLY | LC_LC_ONLY | LC_WRITE_ONLY;
 me->attr.owner_action =  LC_RIGID_OWNER
                        | LC_FLEX_COMP | LC_FLEX_OWNER;

 me->Obj_Generic = macro_generic;
 strcpy(me->Obj_Name,"*");
 ex$message(buff = me->loc_prompt, msgnumb = AS_P_LcMcOc);
 me->Entry_Request=PARENT;
 if(me->mytype&1) me->Obj_Generic |= set_generic;
 return OM_S_SUCCESS;

}

method pro_template()
{
 IGRlong status,msg;
 struct GRmd_env lib_env;
 enum GRdpmode dpmode;
 int first,last;
 int nb_obj,i_obj,count,index;
 struct GRid *set_obj,template;
 int *label;


	/*| PRepar to LOCATE a PARENT */
        me->attr.properties = LC_DP_ONLY |  LC_LC_ONLY | LC_RW;

        me->attr.owner_action = LC_RIGID_COMP
                          | LC_RIGID_OWNER | LC_FLEX_COMP
                          | LC_FLEX_OWNER  | LC_REF_OBJECTS 
			  | LC_HANDLES | LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;


	/* Hilight in the form */
        if(!me->user_form_ptr)
	  {/* Verify that the corresponding line is displayed */

	   FIfld_get_row_offset(me->form_ptr,TEMPLATE_LIST,&first);
	   if(me->index_to_locate < first)
	    {
	     FIfld_set_active_row(me->form_ptr,TEMPLATE_LIST,
                            me->index_to_locate,0);
	    }
	   FIfld_get_num_vis_rows(me->form_ptr,TEMPLATE_LIST,&last);
	   if(me->index_to_locate > first+last-1)
	    {
	     FIfld_set_active_row(me->form_ptr,TEMPLATE_LIST,
                            me->index_to_locate,last-1);
	    }

	   /*"select row %d\n",me->index_to_locate */

           FIfld_set_select(me->form_ptr,TEMPLATE_LIST,
			    me->index_to_locate,0,TRUE);
           FIfld_set_select(me->form_ptr,TEMPLATE_LIST,
			    me->index_to_locate,1,TRUE);
           FIfld_set_select(me->form_ptr,TEMPLATE_LIST,
			    me->index_to_locate,2,TRUE);
          }
	else
	  {
	   for(index = 0; index< me->Nb_Max_Var_Temp; index++)
	    {
	     label =(int *) (me->Temp_Value + index);
	     if(label[1])
             FIfld_set_select(me->user_form_ptr,label[1],0,0,FALSE);
	    }
	   label =(int *) (me->Temp_Value + me->index_to_locate);
           FIfld_set_select(me->user_form_ptr,label[1],0,0,TRUE);
	  }

	   if(me->Temp_List[me->index_to_locate].objid == NULL_OBJID)
             {ex$message(buff = me->loc_prompt, msgnumb = AS_P_IdHiTem);}
	   else
             {ex$message(buff = me->loc_prompt, msgnumb = AS_P_IdReHiTem);}


	/*| Display in macro library */

	if(me->def_id.objid != NULL_OBJID && me->def_window.objid != NULL_OBJID)
	  {
	   dp$erase_hilite(msg = &msg,
			   osnum = me->def_window.osnum,
			   objid = me->def_window.objid);
	   status = om$send(msg = message NDmacro.ACreturn_foot (&msg,
		       me->dup[me->index_to_locate].prompt,&template,NULL,NULL),
			    targetid = me->def_id.objid,
			    targetos = me->def_id.osnum);
	   if(status&1 && msg)
	   ACbuild_env(template.osnum,&lib_env);
	   dpmode = GRhdo;
	   status = om$send(msg = message GRgraphics.GRdisplay( &msg,
                                                    &lib_env.md_env.matrix_type,
                                                    lib_env.md_env.matrix,
                                                    &dpmode,
                                                    &lib_env.md_id ),
			    targetid = template.objid,
			    targetos = template.osnum);
	  }
	

        /*| Display previous position */

	dp$erase_hilite(msg = &msg);
	if(me->Temp_List[me->index_to_locate].objid != NULL_OBJID)
	 {
	  COm_hilite_elem(me->Temp_List+me->index_to_locate,
			  me->dup[me->index_to_locate].type,
			  GRhdo,&me->ModuleInfo);
         }

        /* If modification hilight corresponding occurence template */

	index = me->index_to_locate;
	if(me->rep) index--;
	if(me->mytype&1 && index >= 0)
	 {
          as$start_fence(set = &me->hdr,
                 nb_obj = &nb_obj, p_obj = &set_obj,
                 type_generic = macro_generic,
                 macro_name = me->macro_name);

	  for(i_obj=0;i_obj<nb_obj;i_obj++)
	   {
	    status=om$send(msg = message NDnode.NDget_objects(ND_ROOT,&template,
			 1,NULL,index,index,&count),
			   targetid = set_obj[i_obj].objid,
			   targetos = set_obj[i_obj].osnum);
	    COm_hilite_elem(&template, me->dup[me->index_to_locate].type,
                            GRhdo,&me->ModuleInfo);
           }
	 }


        /* Select the Entry Request */
        /*" Elig %d\n",me->Temp_Elig[me->index_to_locate].objid */

	
	if(me->Temp_Elig[me->index_to_locate].objid != NULL_OBJID)
         {
	  COm_display_elig(me->form_ptr,NULL,ELIGIBLE_LIST,
			   me->Temp_Elig+me->index_to_locate,
			   me->Temp_Value+me->index_to_locate);
          me->Entry_Request=PROMPT;
	  me->state = WAIT_ELI;
	  ex$message(msgnumb = AS_P_SelEli);
         }
        else
         {
	  me->state = WAIT_TEM;
	  if(!(me->dup[me->index_to_locate].type &  ~(double_type | text_type)))
	   {
            me->Entry_Request=PARAM;
            me->Obj_Generic=me->dup[me->index_to_locate].type;
	   }
          else
          { 
            me->Entry_Request=PARENT;
            me->Obj_Generic=me->dup[me->index_to_locate].type;
	    if(me->Obj_Generic & (class_generic | macro_generic))
	     {
	      if(strcmp
		(me->dup[me->index_to_locate].up_scan,".")==0||
		me->dup[me->index_to_locate].up_scan[0]=='\0')
	         strcpy(me->Obj_Name,"*");
	       
	      else
	         strcpy(me->Obj_Name,me->dup[me->index_to_locate].up_scan);
	     }
	    if(me->Obj_Generic == 0) me->Obj_Generic = ~0;
            me->Obj_Generic |= set_generic;
          }

         }
return OM_S_SUCCESS;
}
/* Realloc vlas to store template definition */

method realloc_template(int nb_template)
{
 long status;
 int previous_size;

 previous_size = om$dimension_of(varray = me->Temp_List);
 if(previous_size>=nb_template) return OM_S_SUCCESS;
 
 status = om$vla_set_dimension(varray = me->Temp_List,
                               size = nb_template);
 as$status(action = RET_STATUS);

 status = om$vla_set_dimension(varray = me->Temp_Elig,
                               size = nb_template);
 as$status(action = RET_STATUS);
 status = om$vla_set_dimension(varray = me->Temp_Value,
                               size = nb_template);
 as$status(action = RET_STATUS);

 return OM_S_SUCCESS;
}

method modify_macro(long *msg)
{
 int i_temp,nb_temp_occ,ideb_rep,cn_type;
 long status;
 struct GRid *temp_occ = NULL;
 int macro_state;

 /* Don't modify macro if marked as "root macro*/

 status = om$send(msg = message ACncpx.ACget_STATE(&macro_state),
                  targetid = me->hdr.objid,
                  targetos = me->hdr.osnum);
 if(status == OM_S_SUCCESS && macro_state&ncpx_root) return OM_S_SUCCESS;


 /* representation shit */

 if(me->rep) ideb_rep = 1;
 else 	ideb_rep = 0;

 /* Retrieve macro template */
	
 temp_occ = (struct GRid *) om$malloc (size =
                   sizeof(struct GRid)*om$dimension_of(varray = me->Temp_List));

 status = om$send(msg = message NDnode.NDget_objects(ND_ROOT,
                             temp_occ,OM_K_MAXINT,NULL,
                             0,OM_K_MAXINT,&nb_temp_occ),
                       targetid = me->hdr.objid,
                       targetos = me->hdr.osnum);

 /* Replace template modified by the user */

 for(i_temp = 0 ; i_temp < nb_temp_occ ; i_temp++)
  {
   if(me->Temp_List[i_temp+ideb_rep].objid != NULL_OBJID)
                              temp_occ[i_temp] = me->Temp_List[i_temp+ideb_rep];
  }


 /* Verify that it does not create a loop in the dependent graph */

 if(nd$dep_exist(l_root = &me->hdr,
		    nb_root = 1,
		    l_tip = temp_occ,
		    nb_tip =nb_temp_occ))
   {
    *msg = AS_E_Loop;
    goto wrapup;
   }

 /* It template duplicated, replace them by pretend */

 status =  NDduplicate_root(nb_temp_occ,temp_occ);
 as$status(action = RET_STATUS);

 /* Change parent connection */

    status = om$send(msg = message NDnode.NDconnect
            (nb_temp_occ,temp_occ,NULL_GRID,ND_FULL),
                     targetid = me->hdr.objid,
                     targetos = me->hdr.osnum );
    as$status();

 /* Change if necessary representation */

    if(me->rep & AC_FREE_REP) 
      {status = om$send(msg = message ACncpx.ACput_rep(me->rep,~0),
                     targetid = me->hdr.objid,
                     targetos = me->hdr.osnum );
       as$status();
      }

 /* wait batch to update element and dependency */

    cn_type = ND_COMP;
    nd$wait_batch(type = GR_GEOM_POSTED,
                  l_object = &me->hdr,
                  l_obj_info = &cn_type,
                  nb_obj   = 1);

  wrapup :
  if(temp_occ) om$dealloc(ptr = temp_occ);
  return OM_S_SUCCESS;
}
method gen_missing_temp(long *msg;int i_occ)
{
 long status;
 int i,ideb_rep,nb_obj;
 struct GRid fence,*set_obj;
 int Obj_Generic;
 char *macro_name,tmp_name[2];

 /* The template could have been
    - directly located
    - located by fence
    - or need to be created from default value
 */
 
  *msg = MSSUCC;
  if(me->rep) ideb_rep = 1;
  else 	      ideb_rep = 0;

  for(i=ideb_rep;i<me->Nb_Max_Temp;i++)
   {
    /* does the template exist */

    if(me->Temp_List[i].objid != NULL_OBJID)
     {
      status = om$get_objid_at_index 
		  (objid = my_id,
		   p_chanselect = &me->located_chansel,
		   index = i,
		   osnumaddr = &fence.osnum,
		   objidaddr = &fence.objid);
      if(status&1)
       {
        Obj_Generic=me->dup[i].type;
        if(Obj_Generic&other_generic) Obj_Generic |= debug_type;
        if(Obj_Generic&curve_generic) Obj_Generic |= line_generic|conic_generic;

	macro_name = me->dup[i].up_scan;
	if(!strcmp(macro_name,"."))
	 {
	  macro_name = tmp_name;
	  strcpy(macro_name,"*");
	 }

        as$start_fence(set = &fence ,
		       nb_obj = &nb_obj, p_obj = &set_obj,
		       make_source = TRUE, 
		       macro_name = macro_name,
		       type_generic = Obj_Generic);
	
	if(nb_obj > 0)
	 {/*| Template is in a fence */
	   if(nb_obj<i_occ) *msg = MSFAIL;
           else me->Temp_List[i] = set_obj[i_occ];
	 }
       }
     }
    else if(me->mytype&1)
     {
       /*| This template has not been modified during a modify macro */
       continue;
     }
    
    else if(me->dup[i].type & parameter_generic) 
     {
      /* This template must be created for default value */
      if(me->Temp_Value[i].type ==  text_type)
       {
        status = exp$create(exp_name = NULL,
                         exp_syntax = me->Temp_Value[i].var.text_st.text_string,
                         osnum = me->ModuleInfo.md_id.osnum,
                         p_exp_id = &me->Temp_List[i].objid,
			 type_rq = EXP_TEXT);
       }
      else
       {
        status = exp$create(exp_name = NULL,
                          exp_value = me->Temp_Value[i].var.root_pm_st.value,
                          osnum = me->ModuleInfo.md_id.osnum,
                          p_exp_id = &me->Temp_List[i].objid,
			  type_rq = EXP_DOUBLE);
       }
      me->Temp_List[i].osnum = me->ModuleInfo.md_id.osnum;
      if(!(status&1))
       {
        *msg = MSFAIL;
        me->Temp_List[i].objid = NULL_OBJID;
       }
      else
       {
        status = om$send(msg = message NDnode.NDchg_state
                                              (ND_DEL_NO_CH | ND_WAIT_DEL,
                                               ND_DEL_NO_CH | ND_WAIT_DEL),
                        targetid = me->Temp_List[i].objid,
                        targetos = me->Temp_List[i].osnum);
        as$status();
       }
     }
    else 
     { /*| Template not fully define */
       *msg = MSFAIL;
     }

    if(!(*msg&1)) break;
   }

 /* It template duplicated, replace them by pretend */

 if(!(me->mytype&1) && (*msg&1))
  {
   status =  NDduplicate_root(me->Nb_Max_Temp,me->Temp_List);
   as$status(action = RET_STATUS);
  }

 /* For modification, retrieve modified macro */

 if(me->mytype&1)
  {
   status = om$get_objid_at_index (objid = my_id,
		   p_chanselect = &me->located_chansel,
		   index = me->Nb_Max_Temp,
		   osnumaddr = &fence.osnum,
		   objidaddr = &fence.objid);
   if(status&1)
    {
     as$start_fence(set = &fence ,
		  nb_obj = &nb_obj, p_obj = &set_obj,
		  type_generic = macro_generic,
		  macro_name = me->macro_name);
     if(nb_obj<i_occ) *msg = MSFAIL;
     else me->hdr = set_obj[i_occ];
    }
  }

 return OM_S_SUCCESS;
}

method verify_temp_rep(long *msg)
{
 long status,new_rep;
  /* If representation, verify that parents representation are compatible */

  if( me->rep)
   {
    /*| Verify representation template consistency */
    status = ac$compute_rep_value(initial_rep = 0,
				  p_root = me->Temp_List,
				  nb_root = me->Nb_Max_Temp,
				  resulting_rep = &new_rep);
    /*"new_rep %x\n",new_rep */

    if(new_rep&AC_ERROR_REP) 
     {
      ex$message(msgnumb = AS_E_ParRep); 
      *msg = MSFAIL;
      return OM_S_SUCCESS;
     }
    else if(new_rep&AC_DEP_REP)
     {
      me->rep = new_rep;
     }
    else
     {
      me->rep = me->Temp_Value[0].var.root_pm_st.value;
      me->rep =  AC_FREE_REP | me->rep & ~AC_DEP_REP;
     }
   }
  /*"rep %d\n", me->rep */
  *msg = MSSUCC;
  return OM_S_SUCCESS;
}

/*
   Remove consumed template from template list 
   - if i_occ >= 0 it's during placement loop on element in fence
   - if i_icc <0   it's after
*/


method rem_consumed_temp(int i_occ)
{
    long status;
    IGRlong  is_consumed;
    int someone_is_consumed = 0;
    int i;
    struct GRid dummy;

    for(i=0;i<me->Nb_Max_Temp;i++)
     {
      status = om$send(msg = message NDmacro.ACtest_consumed(&is_consumed),
			  targetid = me->Temp_List[i].objid,
			  targetos = me->Temp_List[i].osnum);

      if((status&1) && is_consumed && i_occ >= 0)
	{
         /* Is the consumed object in a fence ? */
	 status = om$get_objid_at_index(index = i,
				      p_chanselect = &me->located_chansel,
				      objid = my_id,
				      osnumaddr = &dummy.osnum,
				      objidaddr = &dummy.objid);
	 if(!(status&1)) me->Temp_List[i].objid = NULL_OBJID;
	}
      else if((status&1) && is_consumed )
       {
	 someone_is_consumed = 1 ;
	 me->Temp_List[i].objid = NULL_OBJID;
       }
     }
    if(someone_is_consumed)
     {
      status=om$send(msg = message COm_place.write_form(),
		     targetid = my_id);
     }
  return OM_S_SUCCESS;
}

/* If some template is duplicated, replace it by a pretend */
NDduplicate_root(nb_root,root)
int nb_root;
struct GRid *root;
{
 int i,j;
 long status;

 for(i=0;i<nb_root;i++)
  { 
   if(root[i].objid == NULL_OBJID) continue;
   for(j=i+1;j<nb_root;j++)
    {
     if(  root[i].objid != root[j].objid
	||root[i].osnum != root[j].osnum) continue;

     status = om$construct(classid = OPP_ACpretend_class_id,
			   osnum   = root[j].osnum,
			   p_objid = &root[j].objid,
			   msg = message ACpretend.ACpconnect(1,root[j],"."));
     as$status(action = RET_STATUS);
     break;
    }
  }
 return OM_S_SUCCESS;
}

#argsused
COm_place_get_active_symb (dup,Temp_List,Nb_Max_Temp,def_id,
			   active_level,active_display,dir_name,md_env)
struct sup *dup;
struct GRid *Temp_List,*def_id;
int Nb_Max_Temp;
short *active_level;
struct IGRdisplay *active_display;
struct GRmd_env *md_env;
char *dir_name;
{
 GRspacenum dir_os;

 /* Is the operation type and the operand defined */

 ASget_active_symb(active_level,active_display);

 di$pwd(p_osnum = &dir_os,
	dirname = dir_name);
 if(dir_os != md_env->md_id.osnum) dir_name[0] = '\0';

 return OM_S_SUCCESS;
}

method get_active_symb
	(short *active_level;struct IGRdisplay *active_display; char *dir_name)
{
/* To be able to overide it in VDS to get symb from active path */
COm_place_get_active_symb (me->dup,me->Temp_List,me->Nb_Max_Temp,&me->def_id,
			   active_level,active_display,dir_name,
			   &me->ModuleInfo);
return OM_S_SUCCESS;

}
end implementation COm_place;
