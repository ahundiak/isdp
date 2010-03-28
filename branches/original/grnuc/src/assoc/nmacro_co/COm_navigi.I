class implementation COm_navig;

#include "OMmacros.h"
#include "AS_status.h"
#include "exmacros.h"
#include "macro.h"
#include "nddef.h"
#include "acdef.h"
#include "acmacros.h"
#include "ASmessages.h"
#include "grmsg.h"
#include "coparadef.h"
#include "asdef.h"
#include "asbox.h"
#include "asmacros.h"
#include "griomacros.h"
#include "dpmacros.h"
#include "madef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "ACdyn_col.h"
#include <alloca.h>

from NDnode     import NDgive_structure,NDs_compute_node,NDget_objects;
from NDmacro    import ACreturn_foot;
from ACcpx      import find_macro;
from ACcpx_defn import ACgive_name;
from ACmacro_defn import ACgive_upscan,ACgive_feet_desc;
from expression import list;
from ACpretend  import ACgive_downscan;
from ASnode	import ASreturn_go;
from ACrg_collect import AClist_attribute;

extern GRclassid OPP_ACcpx_class_id, OPP_ACpretend_class_id,
		 OPP_expression_class_id, OPP_text_exp_class_id,
		 OPP_ASsourcein_class_id,
		 OPP_ASsource_class_id,
		 OPP_ACpretendin_class_id,
		 OPP_NDnode_class_id,
		 OPP_ACrg_collect_class_id;




#define AS_DEBUG

%safe
static char *COm_navig_form_ptr   = NULL;

static int x_memo = -1,
       y_memo = -1,
       s_memo = -1;

static OM_S_OBJID navig_id = (OM_S_OBJID) ~0;
%endsafe

/*
History
  ???             mm/dd/yy             initial spec & wrote it
  elp             01/06/93             port to NT
  msm             03/05/93             Fixed the form to display selected 
                                       element correctly on the form.
                                       TR # 119301870
  gvk		  08/16/93	       Handle cases where objects connected
				       on the pretend's channel does not have 
				       a owner. Navigate was failing for case. 
  satya           07/25/95             Fixed a logical error - TR# 119525940
  satya           11/03/95             Fixed a VDS problem. It is fixed by 
                                       flipping the search for children
                                       and parents There should be no 
                                       difference whether we look for parents 
                                       or children first to the rest of the 
                                       functionality. 
  
*/

/*****************************

  Force a command to be active

*****************************/

COm_make_command_active(cmd,osnum)
OM_S_OBJID cmd;
GRspacenum osnum;
{
 OM_S_CHANSELECT chan1,chan2;
 OM_S_OBJECT_LINKAGE cmd_server;
 int resp;
 long size;
 char data[1];
 long status,msg;
 OMuint count,my_index;
/* find command server and my index on command server */

   my_index = 0;
   status = om$make_chanselect(channame = "super_cmd.cmd",
		     	       p_chanselect = &chan1);
   as$status(action = RET_STATUS);

   status = om$get_channel_objects(objid = cmd,
				 osnum = osnum,
                                 p_chanselect = &chan1,
				 list = &cmd_server,
				 size = 1,
				 count = &count);
   as$status(action = RET_STATUS);

   status = om$make_chanselect(channame = "cmdserver.cmdstack",
		     	       p_chanselect = &chan2);
   as$status(action = RET_STATUS);

   status = om$get_index(objid_c = cmd_server.S_objid,
			 osnum_c   = cmd_server.osnum,
                         p_chanselect = &chan2,
			 objid   = cmd,
			 osnum2 =  osnum,
			 indexaddr = &my_index);
   as$status(action = RET_STATUS);

   status = om$get_channel_count(objid = cmd_server.S_objid,
			 	 osnum = cmd_server.osnum,
                         	 p_chanselect = &chan2,
				 count = &count);
  if(my_index == count-1)
    {/*| already active */ return OM_S_SUCCESS;}

  else if(my_index<count-1)
    {/*| change channel order */
     status = om$send(msg = message Root.disconnect(chan2,cmd,osnum,chan1),
		      senderid = NULL_OBJID,
		      targetid = cmd_server.S_objid,
		      targetos = cmd_server.osnum);
     as$status(action = RET_STATUS);

     status = om$send(msg = message Root.connect
					(chan2,count-2,cmd,osnum,chan1,count-2),
		      senderid = NULL_OBJID,
		      targetid = cmd_server.S_objid,
		      targetos = cmd_server.osnum);
     as$status(action = RET_STATUS);
    }
  
  /*| Put swap command on the stack */
  
    resp= TOGGLE_COMMAND;
    data[0] = 0;
    size = 1;
    status = ex$putque(msg = &msg,response = &resp,
		       byte = &size, buffer = data);

 return OM_S_SUCCESS;
}
/******************************************************************************

   Interface function between C-form and CO

******************************************************************************/
COm_navig_router(f_label,g_label,value,fp)
int f_label,g_label;
double value;
char *fp;
/*.COm_navig_router*/
{
 struct GRid cmd_obj;
 long status;

 FIf_get_cmd_oid_os(fp,&cmd_obj.objid,&cmd_obj.osnum);
 /*" cmd_obj %d %d\n",cmd_obj.objid,cmd_obj.osnum */
 if(cmd_obj.objid == NULL_OBJID)
  {
   return OM_W_ABORT;
  }
 else
  {
   status = om$send(msg = message COm_navig.form_notification
                                    (f_label,g_label,value,fp),
                  senderid = NULL_OBJID,
                  targetid = cmd_obj.objid,
                  targetos = cmd_obj.osnum);
  if(!status&1)
   {
     FIf_erase(COm_navig_form_ptr);
     FIf_delete(COm_navig_form_ptr);
     COm_navig_form_ptr = NULL;
     as$status()
   }
  }
 return(1);
}

method form_notification (int f_label, g_label;double value;char *fp)
{
 int row,pos,sel;
 char text[80];
 struct ret_struct rst;
 long status,msg;

 switch(g_label)
  {

   case FORM_ABORT :
   if(me->stacked == 1)
    {
     /* Just delete the form when the command is stacked */
     FIf_get_location(COm_navig_form_ptr,&x_memo,&y_memo);
     FIf_get_screen(COm_navig_form_ptr,&s_memo);
     FIf_erase(COm_navig_form_ptr);
     FIf_delete(COm_navig_form_ptr);
     COm_navig_form_ptr = NULL;
     me->stacked = 2;
    }
   else if(me->stacked == 0)
    {
     int resp;
     long size;
     char data[1];
     /* Just to force restart of execute */
     resp= TERMINATE;
     size = 1;
     data[0] = 0;
     status = ex$putque(msg = &msg,response = &resp,
		        byte = &size, buffer = data);
    }
   break;

   case FORM_RESTART :
       /* Ask the user to locate another element to navigate from */
       me->n_selected = 0;
       me->n_successors = 0;
       me->n_feet = 0;
       me->n_ancestors = 0;
       me->active_type = -1;
       me->active.obj_id.objid = NULL_OBJID;
       FIfld_set_num_rows(fp,SELECTED_LIST,0);
       FIfld_set_num_rows(fp,SUCCESSORS_LIST,0);
       FIfld_set_num_rows(fp,ANCESTORS_LIST,0);
       FIfld_set_num_rows(fp,FEET_LIST,0);
       FIg_erase(fp,EVENT_TEXT);
       FIg_erase(fp,SELECT_TEXT);
       FIg_disable(fp,NAVIGATE);
       FIg_disable(fp,EVENT);
       FIg_erase(fp,FEET_TEXT);
       FIg_erase(fp,FEET_LIST);

       if(me->stacked == 0)
        {
	 int resp;
         long size;
	 char data[1];
	 /* Just to force restart of execute */
    	 resp= RESET;
         size = 1;
    	 data[0] = 0;
    	 status = ex$putque(msg = &msg,response = &resp,
		            byte = &size, buffer = data);
        }
       else if (me->stacked == 1)
        {
         /* Make the command navigate graph active by puting in on top of the
            command stack 
         */
	 COm_make_command_active(my_id,OM_Gw_current_OS);
        }
       break;

   case SELECTED_LIST :
   case SUCCESSORS_LIST :
   case FEET_LIST :
   case ANCESTORS_LIST :
      /* get element info */
      FIfld_get_active_row(fp,g_label,&row,&pos);
      FIfld_get_text(fp,g_label,row,0,80,text,&sel,&pos); 
  
      /* Put it as active element */

      if     (g_label == SELECTED_LIST)   me->active = me->selected[row];
      else if(g_label == SUCCESSORS_LIST) me->active = me->successors[row];
      else if(g_label == FEET_LIST)       me->active = me->feet[row];
      else if(g_label == ANCESTORS_LIST)  me->active = me->ancestors[row];

      /* Erase other active element if any */
      if(g_label != SELECTED_LIST)
       {
        FIfld_get_active_row(fp,SELECTED_LIST,&row,&pos);
	FIfld_set_select    (fp,SELECTED_LIST,row,0,FALSE);
       }
      if(g_label != SUCCESSORS_LIST)
       {
        FIfld_get_active_row(fp,SUCCESSORS_LIST,&row,&pos);
	FIfld_set_select    (fp,SUCCESSORS_LIST,row,0,FALSE);
       }
      if(g_label != FEET_LIST)
       {
        FIfld_get_active_row(fp,FEET_LIST,&row,&pos);
	FIfld_set_select    (fp,FEET_LIST,row,0,FALSE);
       }
      if(g_label != ANCESTORS_LIST)
       {
        FIfld_get_active_row(fp,ANCESTORS_LIST,&row,&pos);
	FIfld_set_select    (fp,ANCESTORS_LIST,row,0,FALSE);
       }

      me->active_type = g_label;
      FIg_erase(fp,SELECT_TEXT);
      FIg_display(fp,EVENT_TEXT);
      FIg_enable(fp,NAVIGATE);
      FIg_enable(fp,EVENT);

      /* Hilight it */
      status = om$send(msg = message NDnode.NDgive_structure
					(&msg,&rst,&me->active.mod_env),
                 senderid = NULL_OBJID,
                 targetid = me->active.obj_id.objid,
                 targetos = me->active.obj_id.osnum);
      if(!(status&1)) rst.type = ~0;

      dp$erase_hilite(msg = &msg);
      COm_hilite_elem(&me->active,rst.type,GRhdo,&me->ModuleInfo);
      break;

   case NAVIGATE :
      /* navigate from active element*/
      if(me->active.obj_id.objid != NULL_OBJID)
       {
	/* Build selected list */
	status = om$send(msg = message COm_navig.navigate(fp),
			 targetid = my_id);
       }
      break;

   case EVENT :
      /* Put the active element on the queue */
      if(me->active.obj_id.objid != NULL_OBJID)
       {
        ASputobj(&msg,me->active.obj_id.objid,me->active.obj_id.osnum,
			&me->active.mod_env);
       }
      break;
   
 }
 return OM_S_SUCCESS;
}

method init (int type; char *string_ptr )
{
 int FORM = 0;
 long status;

 status = om$send(msg = message COpara.init(type,string_ptr),
                  targetid = my_id,
                  mode = OM_e_wrt_message);
 as$status(action = RET_STATUS);


 /* Initialize form */

 if(COm_navig_form_ptr != NULL)
  {
   me->stacked = 2;
   return OM_W_ABORT; /* one command is enought */
  }


 FIf_new( FORM, "ASNavigate", COm_navig_router, &COm_navig_form_ptr);
 FIf_set_cmd_oid_os( COm_navig_form_ptr, my_id, OM_Gw_current_OS );
 FIg_disable(COm_navig_form_ptr,NAVIGATE);
 FIg_disable(COm_navig_form_ptr,EVENT);
 FIg_erase(COm_navig_form_ptr,FEET_TEXT);
 FIg_erase(COm_navig_form_ptr,FEET_LIST);


 /* Initialize instances */

 me->n_selected = 0;
 me->n_successors = 0;
 me->n_feet = 0;
 me->n_ancestors = 0;
 me->active.obj_id.objid = NULL_OBJID;
 me->active_type = -1;

 if(COm_navig_form_ptr != NULL)
  {
   if(x_memo != -1)
     {
       FIf_set_location(COm_navig_form_ptr,x_memo,y_memo);
#if ! defined( NT )
       FIf_set_screen(COm_navig_form_ptr,s_memo);
#endif
     }
   FIf_display(COm_navig_form_ptr);
  }
 navig_id = my_id;

 return(OM_S_SUCCESS);
  
}

method wakeup(int n)
{
 long status;

  ex$message( msgnumb = AC_M_ASNvPdGr);
  status = om$send(msg = message COpara.wakeup(n), targetid = my_id,
                  mode = OM_e_wrt_message);
  if(me->stacked == 1) me->stacked = 0;
  return status;
}

method execute ( int *response;
                 char *response_data;
                 int  pos)
{
 long status,msg;
 OM_S_CHANSELECT chan;
 OM_S_OBJECT_LINKAGE cmd_server;
 OMuint my_index;
 OMuint nb;
 struct GRevent event;

/* if command has been delete from delete button on form --> exit */

 if(!(COm_navig_form_ptr) || me->stacked == 2)
  { *response = TERMINATE; return OM_S_SUCCESS;} 

/* If no object located, get one */
 if(me->active.obj_id.objid == NULL_OBJID) 
  {
   status = om$send(msg = message COm_navig.locate_elem(response,response_data),
		    targetid = my_id);
   if(me->active.obj_id.objid == NULL_OBJID)
    {/*| command interupted */ return OM_S_SUCCESS;}
   
  }

   /*| an object has been located, make the command not active if possible */

   my_index = 0;
   status = om$make_chanselect(channame = "super_cmd.cmd",
		     	       p_chanselect = &chan);
   as$status();

   if(status&1)
    {
     status = om$get_channel_objects(objid = my_id,
                                 p_chanselect = &chan,
				 list = &cmd_server,
				 size = 1,
				 count = &nb);
     as$status();
    }

   if(status&1)
    {
     status = om$make_chanselect(channame = "cmdserver.cmdstack",
		     	       p_chanselect = &chan);
     as$status();
    }

   if(status&1)
    {
     status = om$get_index(objid_c = cmd_server.S_objid,
			 osnum_c   = cmd_server.osnum,
                         p_chanselect = &chan,
			 objid   = my_id,
			 osnum2 =  OM_Gw_current_OS,
			 indexaddr = &my_index);
     as$status();
    }
   /*"my_index %d\n",my_index */

   if(my_index != 0)
     {*response = TOGGLE_COMMAND;return OM_S_SUCCESS;}
   else		
     {co$getevent(msg = &msg,
		  event_mask = GRm_DATA,
		  event = &event,
		  msgnum = AS_P_NvGrFR,
		  response = response,
		  response_data = response_data,
		  mode = EX_LINE_MODE);
      return OM_S_SUCCESS;
     }
}

method super_cmd.sleep(int n)
{
 if(me->stacked == 0) me->stacked = 1;
 return OM_S_SUCCESS;
}

%safe
int GRnavigate_locate_rigid_comps = 0;
%endsafe

method locate_elem(int *resp;char *response_data)
{
 static int TokenList[2] = {
                        GR_UNKNOWN_TYPE ,
                        LOC_PARENT
                      };

 struct GRevent event1,event2;
 long msg,status,
   locate_mask  = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP,
   input_mask   = GRm_DATA | GRm_STRING | GRm_RESET | GRm_BACK_UP,
   display_flag = ELEM_HILIGHT | ALL_WINDOWS | NO_PROJ_ACCEPT_POINT;

 int token,
   obj_generic = 0xffffffff,
   size = sizeof (struct GRevent);

 struct ret_struct rst;
 struct GRid context,located_obj;

   me->attr.properties   = LC_DP_ONLY | LC_LC_ONLY | LC_RW;

   me->attr.owner_action = LC_RIGID_OWNER
                        | LC_FLEX_COMP | LC_FLEX_OWNER 
			| LC_REF_OBJECTS
                        | LC_HANDLES
			| LC_ASSOCIATIVE | LC_EXTERN_CONSTRAINED;

   ex$message(buff = me->loc_prompt, msgnumb = GR_P_IdEle);
   ex$message(buff = me->acc_prompt, msgnumb = AS_P_AccRej);
   ex$message( buff =  me->reloc_prompt, msgnumb = AS_E_EleNotFound);

   GRnavigate_locate_rigid_comps = 1;

   token = ASget_parent (&msg,TokenList,&event1,&event2,&locate_mask,
                         &input_mask, &size, &display_flag,resp,
                         response_data,me->loc_prompt,me->acc_prompt,
                         me->reloc_prompt, &me->attr,&me->locate_stack,
                         obj_generic,&located_obj,&context,&rst);

   GRnavigate_locate_rigid_comps = 0;

   if(TokenList[token] == LOC_PARENT)
    {
     /* navigate from located object */
     as$make_source(go_grid  = located_obj,
		    as_os = located_obj.osnum,
		    as_grid = &me->active);
     me->active.mod_env = event1.located_object[0].module_info; 
     status = om$send(msg = message COm_navig.navigate(COm_navig_form_ptr),
		      targetid = my_id);
    }
 return OM_S_SUCCESS;
}

 
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                          function ASformat_par                             */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#define LENGTH_MAX_NAME     80 /* Maximum length for a name                   */
#define LENGTH_MAX_FORMULA 128 /* Maximum length for a formula                */
extern OMuword OPP_GRgraphics_class_id;
from GRgraphics import GRgetobjinfo;

ASformat_par(template_name, object ,format)
  char         *template_name;
  struct GRobj_env  *object;  /* IN    object to format                       */
  char         *format;       /* IN    Contain of the element                 */
  /*.ASformat_par*/
  {
  GRclassid             obj_classid;
  IGRint  		status;
  IGRchar 		name [LENGTH_MAX_NAME];
  IGRchar 		*macro_name;
  IGRchar 		formula[LENGTH_MAX_FORMULA];
  IGRchar 		*p_formula;
  struct GRid mdef;

  if(template_name)
   {
    strcpy(format,template_name);
    strcat(format,":");
   }
  else format[0] = '\0';
     


  status = om$get_classid
             (objid     = object->obj_id.objid,
              osnum     = object->obj_id.osnum,
              p_classid = &obj_classid );
  as$status(action = RET_STATUS);

  status=om$get_classname
           (objid     = object->obj_id.objid,
            osnum     = object->obj_id.osnum,
            classname = name );
  as$status(action = RET_STATUS);


  if(om$is_ancestry_valid(subclassid    = obj_classid,
                           superclassid = OPP_ACcpx_class_id) == OM_S_SUCCESS)
    {
    /*| Macro */

    status = om$send
               (msg          = message ACcpx.find_macro( &mdef),
		senderid     = NULL_OBJID,
                targetid     = object->obj_id.objid,
                targetos     = object->obj_id.osnum);
    as$status( action = RET_STATUS );
                
    status = om$send
               (msg          = message ACcpx_defn.ACgive_name( &macro_name ),
		senderid     = NULL_OBJID,
                targetid     = mdef.objid,
                targetos     = mdef.osnum);
    as$status( action = RET_STATUS );
    strcat(name,": ");
    strcat(name,macro_name);
    /*" macro_name %s\n",macro_name  */  
    }
  else if(om$is_ancestry_valid(subclassid   = obj_classid,
                               superclassid = OPP_expression_class_id)
							       == OM_S_SUCCESS)
    {
    /*| Expression*/

    name[4]=0;
    status = om$send
               (msg      = message expression.list(formula),
		senderid = NULL_OBJID,
                targetos = object->obj_id.osnum,
                targetid = object->obj_id.objid );
    strcat(name," = ");
    p_formula = formula;
    while(p_formula[0]==' ')p_formula++;
    strncat(name,p_formula,LENGTH_MAX_NAME-strlen(name));
    name[LENGTH_MAX_NAME-1] = '\0';
    /*" exp name %s\n",p_formula  */  
    }
  else if(om$is_ancestry_valid(subclassid   = obj_classid,
                        superclassid = OPP_ACpretend_class_id) == OM_S_SUCCESS)
    {
    /*| Pretend */

    status = om$send
               (msg      = message ACpretend.ACgive_downscan(formula),
		senderid = NULL_OBJID,
                targetos = object->obj_id.osnum,
                targetid = object->obj_id.objid);
    strcat(name,": ");
    strcat(name,formula);
    }   
  else if(om$is_ancestry_valid(subclassid   = obj_classid,
                         superclassid = OPP_text_exp_class_id) == OM_S_SUCCESS)
    {
    /*| Text */
    }
  else if(om$is_ancestry_valid(subclassid   = obj_classid,
                         superclassid = OPP_GRgraphics_class_id) == OM_S_SUCCESS)
    {
    /*| Graphics Object - output the same identifier as Locate*/

     IGRlong locmsg;
     struct GRobj_info junk;

     strcpy(junk.type,"");
     status = om$send(msg = message GRgraphics.GRgetobjinfo(&locmsg, &junk), 
		senderid = NULL_OBJID,
                targetos = object->obj_id.osnum,
                targetid = object->obj_id.objid);
     /* TR# 119525940 -- Fixed the logical error by replacing & will && */
     if ((1&status&locmsg) && strlen(junk.type))
       /* Copy LENGTH_MAX_NAME characters from junk.type into name.
       */
       strncpy(name, junk.type, LENGTH_MAX_NAME);
    }
   
   strcat(format,name);
   return (TRUE);
}/* end of function ASformat_par */

method navigate(char *fp)
{
 int i,previous_size,new_n_feet;
 long status,msg;
 char text[360];
 int is_macro,is_rg_col;
 GRclassid classid;
 struct GRid macro_def;
 struct sup *l_upsc;
 struct myfeet *l_feet;
 int nb_upsc,dummy_upsc;
 struct GRid *ll_temp;
 OM_S_OBJECT_LINKAGE   *child;
 int	index;
 OMuint	count;
 GRclassid 		obj_class;

 struct	GRid		my_go, my_as;
 struct	GRmd_env	my_env;
 struct	GRmd_env	*list_env;
 IGRdouble	inv_mat[16];
 short		four = 4;

 child = NULL;
 list_env = NULL;

 /* Can we navigate on such an element */

	/*" navigate with %d/%d \n", me->active.obj_id.objid, me->active.obj_id.osnum */

  status = om$get_classid (osnum = me->active.obj_id.osnum,
                           objid = me->active.obj_id.objid,
              		   p_classid = &classid);
  if(om$is_ancestry_valid(subclassid = classid,
			  superclassid = OPP_NDnode_class_id) != OM_S_SUCCESS)
   {/*| can not navigate on such an element */
    return OM_S_SUCCESS;
   }

	/*" active module : %d/%d\n", me->active.mod_env.md_id.objid, me->active.mod_env.md_id.osnum */
	/*" active env type : %d\n", me->active.mod_env.md_env.matrix_type */
/*^
	for( i=0; i<16; i++ )
		printf(" mat[%d] : %f\n", i, me->active.mod_env.md_env.matrix[i] );
*/

 /* Build selected list */

 if(me->active_type == SELECTED_LIST)
  {
   for(i=0;i<me->n_selected;i++)
    {
     if(   me->active.obj_id.objid == me->selected[i].obj_id.objid
	&& me->active.obj_id.osnum == me->selected[i].obj_id.osnum) break;
    }
   me->n_selected = i;
   FIfld_set_num_rows(fp,SELECTED_LIST,me->n_selected+1);
  }
 else
  {
   previous_size = om$dimension_of(varray = me->selected);
   if(previous_size <= me->n_selected)
    {
     status =om$vla_set_dimension(varray = me->selected,
				 size = 10*(1+me->n_selected/10));
     as$status( );
    }

   ASformat_par ((char *) NULL,&me->active,text);
   FIfld_set_text(fp,SELECTED_LIST,me->n_selected,0,text,FALSE);
   FIfld_set_active_row (fp, SELECTED_LIST, me->n_selected, 0);
   me->selected[me->n_selected] = me->active;
   me->n_selected += 1;
  }


/* Is the located object a macro ? */

  is_macro = 0;
  is_rg_col = 0;

  if(om$is_ancestry_valid(subclassid = classid,
			  superclassid = OPP_ACcpx_class_id) == OM_S_SUCCESS)
   {
    is_macro = 1;  
    /*| Find the macro definition */
    status = om$send (msg      = message ACcpx.find_macro(&macro_def),
                  targetid = me->active.obj_id.objid,
                  targetos = me->active.obj_id.osnum);
    as$status(action = RET_VALUE);
   }

  else if(om$is_ancestry_valid(subclassid = classid,
		  superclassid = OPP_ACrg_collect_class_id) == OM_S_SUCCESS)
   {
    is_rg_col = 1;
   }

/* Build ancestry  list */

 if(is_macro)
  {
   status = om$send (msg      = message ACmacro_defn.ACgive_upscan
                                 (&nb_upsc,&dummy_upsc,&l_upsc),
                     targetid = macro_def.objid,
                     targetos = macro_def.osnum);
  }

  /* Get and store the ancestors */

  if(om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_ASsourcein_class_id) == OM_S_SUCCESS &&
	om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_ACpretendin_class_id) != OM_S_SUCCESS ){

	my_env = me->active.mod_env;
	status = om$send( msg = message ASnode.ASreturn_go
				( &my_go, &my_env.md_env.matrix_type, 
						my_env.md_env.matrix ),
        	            targetid = me->active.obj_id.objid,
	        	    targetos = me->active.obj_id.osnum);
	as$status();
	/*" my_go : %d/%d\n", my_go.objid, my_go.osnum */

	/*| get corresponding source */
	as$make_source(	go_grid	= my_go,
			as_os	= my_go.osnum,
			as_grid = &my_as );
	/*" my_as : %d/%d\n", my_as.objid, my_as.osnum */

	my_env.md_id.osnum	 = my_go.osnum;
	me->n_ancestors	 = 1;
	ll_temp = &my_as;

   } else if( om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_ACpretendin_class_id) == OM_S_SUCCESS ){

	my_env = me->active.mod_env;
	status = om$send( msg = message ASnode.ASreturn_go
				( &my_go, &my_env.md_env.matrix_type, 
						my_env.md_env.matrix ),
                    targetid = me->active.obj_id.objid,
	       	    targetos = me->active.obj_id.osnum);
	as$status();
	/*" my_go : %d/%d\n", my_go.objid, my_go.osnum */

	ASget_as_owner( &my_go, &my_as );
	/*" my_as : %d/%d\n", my_as.objid, my_as.osnum */

	/*TR#119421382, if no owner present need to display myself -gvk*/  
	if(my_as.objid == NULL_OBJID)
		my_as = my_go;


	my_env.md_id.osnum	 = my_go.osnum;
	me->n_ancestors	 = 1;
	ll_temp = &my_as;

     } else {

	  my_env = me->active.mod_env;
	  status = om$send (msg = message NDnode.NDget_objects(ND_ROOT|ND_IN_BUF,NULL
				    ,0,&ll_temp,0,OM_K_MAXINT,&me->n_ancestors),
        	            targetid = me->active.obj_id.objid,
	        	    targetos = me->active.obj_id.osnum);
	  as$status(action = RET_VALUE);
    }

  previous_size = om$dimension_of(varray = me->ancestors);
   if(previous_size <= me->n_ancestors)
    {
     status =om$vla_set_dimension(varray = me->ancestors,
				 size = 10*(1+me->n_ancestors/10));
	as$status( );
    }

  for(i=0;i<me->n_ancestors;i++){
	me->ancestors[i].obj_id  = ll_temp[i];
	me->ancestors[i].mod_env = my_env;
  }

  /* Now fill the form */

  for(i=0;i<me->n_ancestors;i++)
   {
    if(!is_macro)
      ASformat_par ((char *) NULL,me->ancestors+i,text);
    else
      ASformat_par (l_upsc[i].prompt,me->ancestors+i,text);
    FIfld_set_text(fp,ANCESTORS_LIST,i,0,text,FALSE);
   }
   FIfld_set_num_rows(fp,ANCESTORS_LIST,me->n_ancestors);


/* Feet now */

  if(is_macro)
   {
    status = om$send (msg = message ACmacro_defn.ACgive_feet_desc
                                 (&me->n_feet,&l_feet),
                  targetid = macro_def.objid,
                  targetos = macro_def.osnum);
    as$status(action = RET_VALUE);

    previous_size = om$dimension_of(varray = me->feet);
    if(previous_size <= me->n_feet)
     {
      status =om$vla_set_dimension(varray = me->feet,
				 size = 10*(1+me->n_feet/10));
     }
  
    FIg_display(fp,FEET_LIST);
    FIg_display(fp,FEET_TEXT);
    for(i= 0,new_n_feet = 0; i< me->n_feet; i++)
      {
	me->feet[new_n_feet].mod_env = me->active.mod_env;
       status = om$send(msg = message NDmacro.ACreturn_foot(&msg,l_feet[i].name,
					&me->feet[new_n_feet].obj_id,NULL,NULL),
                          targetid = me->active.obj_id.objid,
	            	  targetos = me->active.obj_id.osnum);
        if((msg == 0) || (msg == temp_miss_foot)) continue;
	if( me->feet[new_n_feet].obj_id.objid == NULL_OBJID )	continue;

       ASformat_par(l_feet[i].name,me->feet+new_n_feet,text);
       FIfld_set_text(fp,FEET_LIST,new_n_feet,0,text,FALSE);
       new_n_feet ++;
      }
    me->n_feet = new_n_feet;
    FIfld_set_num_rows(fp,FEET_LIST,me->n_feet);
  }
 else if(is_rg_col)
  {
   struct ACrg_coll *list_att;
   me->n_feet = 0;
   status = om$send(msg = message ACrg_collect.AClist_attribute
				 (&msg,0,NULL,&me->n_feet),
                          targetid = me->active.obj_id.objid,
	            	  targetos = me->active.obj_id.osnum);
   if(status&msg&1 && me->n_feet>0)
   {
    previous_size = om$dimension_of(varray = me->feet);
    if(previous_size <= me->n_feet)
     {
      status =om$vla_set_dimension(varray = me->feet,
				 size = 10*(1+me->n_feet/10));
     }
     for(i=0;i<me->n_feet;i++) me->feet[i].obj_id.objid = NULL_OBJID;
     list_att = (struct ACrg_coll *)alloca(me->n_feet*sizeof(struct ACrg_coll));
     if(list_att == NULL) return OM_W_ABORT;

     status = om$send(msg = message ACrg_collect.AClist_attribute
				 (&msg,me->n_feet,list_att,&me->n_feet),
                          targetid = me->active.obj_id.objid,
	            	  targetos = me->active.obj_id.osnum);

    FIg_display(fp,FEET_LIST);
    FIg_display(fp,FEET_TEXT);
    for(i= 0,new_n_feet = 0; i< me->n_feet; i++)
      {
	me->feet[new_n_feet].mod_env = me->active.mod_env;
       status = om$send(msg = message NDmacro.ACreturn_foot
					(&msg,list_att[i].name,
					&me->feet[new_n_feet].obj_id,NULL,NULL),
                          targetid = me->active.obj_id.objid,
	            	  targetos = me->active.obj_id.osnum);
        if(msg == temp_miss_foot) continue;
	if( me->feet[new_n_feet].obj_id.objid == NULL_OBJID )	continue;

       ASformat_par(list_att[i].name,me->feet+new_n_feet,text);
       FIfld_set_text(fp,FEET_LIST,new_n_feet,0,text,FALSE);
       new_n_feet ++;
      }
    me->n_feet = new_n_feet;
    }
   else me->n_feet = 0;
   FIfld_set_num_rows(fp,FEET_LIST,me->n_feet);
  }
 else
  {
   me->n_feet = 0;
   FIfld_set_num_rows(fp,FEET_LIST,0);
   FIg_erase(fp,FEET_TEXT);
   FIg_erase(fp,FEET_LIST);
  
  }/*** Feet processing ends here ***/


  /* Get and store the successors in the current OS --  Successor starts */

  status = om$send (msg  = message NDnode.NDget_objects(ND_CHILDREN|ND_IN_BUF,
                        NULL,0,&ll_temp,0,OM_K_MAXINT,&me->n_successors),
                    targetid = me->active.obj_id.objid,
	            targetos = me->active.obj_id.osnum);
  as$status(action = RET_VALUE);

   if(om$dimension_of(varray = me->successors) < me->n_successors)
    {
     status =om$vla_set_dimension(varray = me->successors,
				 size = 10*(1+me->n_successors/10));
     as$status(action = RET_STATUS );
    }
  for(i=0;i<me->n_successors;i++)
    {
     me->successors[i].obj_id  = ll_temp[i];
     me->successors[i].mod_env = me->active.mod_env;
    }

  /*| get now successors in other os */

  if(om$is_ancestry_valid(subclassid = classid,
		superclassid = OPP_ASsourcein_class_id) != OM_S_SUCCESS)
   { my_go = me->active.obj_id;
     status = om$send(msg = message NDmacro.ACreturn_foot(&msg,"",&my_go,
					NULL,NULL), 
        	            targetid = me->active.obj_id.objid,
	        	    targetos = me->active.obj_id.osnum);

      /* get all object on notify channel */

      status = om$get_channel_count(objid = my_go.objid,
					osnum	= my_go.osnum,
					p_chanselect = &AS_notification,
					count = &count);
      if(!(status&1)) count = 0;

      if( count )
       {
	child =(OM_S_OBJECT_LINKAGE *) alloca
					(count * sizeof(OM_S_OBJECT_LINKAGE));
	if(!child) return OM_W_ABORT;

         if(om$dimension_of(varray = me->successors) < me->n_successors+count)
          {
           status =om$vla_set_dimension(varray = me->successors,
				 size = 10*(1+(me->n_successors+count)/10));
	   as$status(action = RET_STATUS);
	  }

        status = om$get_channel_objects( objid = my_go.objid,
					osnum	= my_go.osnum,
					p_chanselect = &AS_notification,
					list = child,
					size = count,
					count = &count );

        /* only keep assoc */
  
	for(index=0; index<count; index++)
	  {
	   status = om$get_classid(osnum = child[index].osnum, 
      			       	   objid = child[index].S_objid, 
			           p_classid = &obj_class );

	   if(om$is_ancestry_valid( subclassid = obj_class,
		superclassid = OPP_ASsourcein_class_id)!=OM_S_SUCCESS) continue;

	   me->successors[me->n_successors].obj_id.objid = child[index].S_objid;
	   me->successors[me->n_successors].obj_id.osnum = child[index].osnum;

	   /*| manip matrix */
	   status = om$send( msg = message ASnode.ASreturn_go
				( &my_go, &my_env.md_env.matrix_type, 
						my_env.md_env.matrix ),
                    targetid = child[index].S_objid,
	       	    targetos = child[index].osnum );
	   as$status();

	   if(my_env.md_env.matrix_type != MAIDMX)
	    {
	     MAinvmx(&msg, &four,  my_env.md_env.matrix, inv_mat);
	     MAmulmx(&msg, &four, &four, &four,
			me->active.mod_env.md_env.matrix, inv_mat,
			me->successors[me->n_successors].mod_env.md_env.matrix);

	     MAtypemx(&msg,
		         me->successors[me->n_successors].mod_env.md_env.matrix,
		&me->successors[me->n_successors].mod_env.md_env.matrix_type );
	    }
	   else
            {
	     me->successors[me->n_successors].mod_env = me->active.mod_env;
	    }

	   me->successors[me->n_successors].mod_env.md_id.objid = NULL_OBJID;
	   me->successors[me->n_successors].mod_env.md_id.osnum = 
			 	 me->successors[me->n_successors].obj_id.osnum;
	   me->n_successors++;
	  }
       }
  }

/* Now give them a name */
  for(i= 0; i< me->n_successors; i++)
    {
     ASformat_par((char *)NULL,me->successors+i,text);
     FIfld_set_text(fp,SUCCESSORS_LIST,i,0,text,FALSE);
    }
   FIfld_set_num_rows(fp,SUCCESSORS_LIST,me->n_successors);
/*** Successor ends here ****/
 /*
    navigate and event button can not be used as long as an element as not 
    been selected 
 */

 FIg_erase(fp,EVENT_TEXT);
 FIg_display(fp,SELECT_TEXT);
 FIg_disable(fp,NAVIGATE);
 FIg_disable(fp,EVENT);
 return OM_S_SUCCESS;

}


method write_form()
{
 return OM_S_SUCCESS;
 
}

method delete(int n)
{
 int status;
 navig_id = NULL_OBJID;
/*
   delete the form and make the notification pointer point to the previous
   command object if any
*/
 

 if(COm_navig_form_ptr && me->stacked != 2)
  {
     FIf_get_location(COm_navig_form_ptr,&x_memo,&y_memo);
     FIf_get_screen(COm_navig_form_ptr,&s_memo);
     /*" get s_memo %d\n",s_memo */
     FIf_erase(COm_navig_form_ptr);
     FIf_delete(COm_navig_form_ptr);
     COm_navig_form_ptr = NULL;
  }
 status = om$send(msg = message COpara.delete(n),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
 return(status);
}


end implementation COm_navig;
