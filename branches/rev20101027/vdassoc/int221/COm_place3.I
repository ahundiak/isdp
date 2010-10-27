/* $Id: COm_place3.I,v 1.1.1.1 2001/01/04 21:07:42 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdassoc/int221 / COm_place3.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: COm_place3.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:42  cvs
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
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

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
from expression		import list;
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
	   }
	 break;

      case PARAM :  /*| PARAM */
        Token = ASget_all_param (
		&status,			TokenList, 
		&Event_Loc, 			&Event_Ac,
                &Locate_Mask, 			&Input_Mask, 
		&Size, 				&Display_Flag,
                response, 				response_data, 
		me->loc_prompt,          me->acc_prompt, 
		me->reloc_prompt,        &me->attr, 
		&me->locate_stack,	 me->Obj_Generic,
	        &Object_GRid, &Param);
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
end implementation COm_place;
