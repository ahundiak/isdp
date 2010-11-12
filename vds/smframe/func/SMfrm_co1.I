/* $Id: SMfrm_co1.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smframe/func / SMfrm_co1.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMfrm_co1.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.4  1998/02/09  17:43:10  pinnacle
# Replaced: smframe/func/SMfrm_co1.I for:  by azuurhou for vds
#
# Revision 1.3  1997/12/02  09:23:58  pinnacle
# Replaced: smframe/func/SMfrm_co1.I for:  by ksundar for vds
#
# Revision 1.2  1997/06/23  06:09:52  pinnacle
# Replaced: smframe/func/SMfrm_co1.I for:  by ksundar for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/09/27  15:39:34  pinnacle
# Replaced: smframe/func/SMfrm_co1.I for:  by ksundar for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.4  1996/05/08  04:49:50  pinnacle
# Replaced: smframe/func/SMfrm_co1.I for:  by ksundar for vds.240
#
# Revision 1.3  1996/03/22  14:21:50  pinnacle
# Replaced: vdlocate/cmd/VDS_LOCATE.sl for:  by ksundar for vds.240
#
# Revision 1.2  1996/03/21  06:31:56  pinnacle
# Replaced: smframe/func/SMfrm_co1.I for:  by rgade for vds.240
#
# Revision 1.1  1996/02/24  21:58:40  pinnacle
# Created: smframe/func/SMfrm_co1.I by v240_int for vds.240
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	05/07/96	Sundar		Called VDltrim, VDrtrim, VDspace
 *					for TR: 179601862
 *	06/18/97	Sundar		Modified function SMFrmFindOneComponent
 *					for CR:179528227
 *	12/02/97	Sundar		Modified the methods save_all &
 *					form_notifiction for the CR:179309743.
 * -------------------------------------------------------------------*/

/*               SMfrm_co1.I                    */
/*   Methods  and functions for SMCmdPlMdFr    */ 
/*   Methods for the main form                  */
/*   Jean Jasinczuk				*/
/*   26-Dec-91                                  */
 
class implementation SMCmdPlMdFr;
 
#define AS_DEBUG	1
 
#include "AS_status.h"

extern GRclassid OPP_EMSplane_class_id;
extern GRclassid OPP_SMfrm_syst_class_id;
extern GRclassid OPP_ACcpx_class_id;

from GRvg	import GRgetname; 
from GRgencs    import GRget_cs_info;
from NDnode     import NDget_objects; 
from ACcpx      import find_macro;
from ACcpx_defn import ACgive_name; 
from ASnode     import ASreturn_go;
from SMfrm_syst import SMfind_frame_objid;
from SMframe    import SMfind_frm_syst;
from SMfrm_syst import SMfind_all_frame;

#define MAX_VALUE_FROM_FIELD 999999
#define MIN_VALUE_FROM_FIELD -999999


/* Retreive the parents of a frame */
static int SMFrmRetrieveRoots(obj,roots)
struct GRid *obj;    /* [I]  The frame which root are ask */
struct GRid *roots;  /* [O]  The roots                    */
{
  IGRlong status;
  struct GRid	macro_def;
  char *mac_name;
  int count;

  status = om$send(msg = message ACcpx.find_macro(&macro_def),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum );
  if(status != OM_S_SUCCESS) return 0;
  
  status = om$send(msg = message ACcpx_defn.ACgive_name(&mac_name),
		   senderid = NULL_OBJID,
		   targetid = macro_def.objid,
		   targetos = macro_def.osnum );
  if(status != OM_S_SUCCESS) return 0;
  
  if(strncmp(mac_name,"SMFrPln",7) !=0 ) return 0;
  
  status = om$send(msg = message NDnode.NDget_objects
		   (ND_ROOT,roots,4,NULL,0,3,&count),
		   senderid = NULL_OBJID,
		   targetid = obj->objid,
		   targetos = obj->osnum );
  if(status != OM_S_SUCCESS || count != 4) return 0;

  return 1;
}

/* Find a frame in the frame system represent by owner */
static SMFrmFindOneComponent(owner,name,oneframe)
struct GRid *owner;       /* The frame system GRid [I] */
char        *name;        /* The name of the frame system (or null) (I/O)) */
struct GRid *oneframe;    /* GRid of one frame [O]*/
{
  IGRint low_num;
  IGRlong status,msg;
  char ownername[DI_PATH_MAX];

  if(name == NULL)
   {
     status = om$send(msg = message GRvg.GRgetname
		      (&msg,ownername),
		      senderid = NULL_OBJID,
		      targetid = owner->objid,
		      targetos = owner->osnum);
     if(!(status & msg & 1))
      {
	printf("Error getting the name of frame system\n");
	return 0;
      }
   }
  else
    strcpy(ownername,name);

  /* Get the GRid of the lowest frame; SUNDAR for CR:179528227  */
   status = om$send(msg = message SMfrm_syst.SMfind_all_frame
		(&msg,NULL,NULL,NULL,&low_num,NULL),
		senderid = NULL_OBJID,
		targetid = owner->objid,
		targetos = owner->osnum);

   status = om$send(msg = message SMfrm_syst.SMfind_frame_objid
		    (&msg,low_num,oneframe),
		    senderid = NULL_OBJID,
		    targetid = owner->objid,
		    targetos = owner->osnum);
  if(!(status & msg & 1))
    return 0;
  else
    return 1;
}

/*Display a double field which appeared  when his associate gadget is selected*/ 

static int display_double_field(
Form   form,          /* [I] Form pointer where the field must appear      */
int    label,         /* [I] Label of gadget to display		           */
double default_value, /* [I] The value to place in the field (or NO_VALUE) */  
IGRchar *unit         /* [I] Unit to display the value                     */
)
{
  int test;
  double ext_value;
  
  if(form == NULL) return ERRO;
  
  test = FIg_display(form,label);
  
  if(test != FI_SUCCESS) return ERRO;
  
  test = FIfld_pos_cursor(form,label,0 ,0,0, 0, 0, 0);
  if(test != FI_SUCCESS) return ERRO;
  
  if(default_value == NO_VALUE || default_value == NO_REV_DIST)
    FIg_set_text(form,label,"");
  else
   {
     SMfr_convert_int_unit(default_value,unit,&ext_value);
     FIg_set_value(form,label,ext_value);
   }

  return SUCC;
}

/* Change the state to enable disable of the 3 button for orientation */
static void change_state_orient(form,state)
Form form;            /* [I] Pointer to the main form             */
int state;            /* [I] TRUE for enable, FALSE for disable   */
{
  if(state == FALSE)
   {   
     FIg_disable(form,X_BUTTON);
     FIg_disable(form,Y_BUTTON);
     FIg_disable(form,Z_BUTTON);
   }
  else
   {
     FIg_enable(form,X_BUTTON);
     FIg_enable(form,Y_BUTTON);
     FIg_enable(form,Z_BUTTON); 
   }
}

/* Change the gadget state of the main form */

static int main_change_state_gadget(form,change_state,command_type,coord_type)
Form form;   		/* [I] The pointer to the main form        */
int  change_state;      /* [I] TRUE = enable FALSE = disable       */
int  command_type;      /* [I] The command type (PLACE or MODIFY)  */ 
int  coord_type;        /* [I]  CLASS_PLANE or CLASS_CS            */
{
  static int main_table[] = {
    FI_ACCEPT, FI_RESET,FI_EXECUTE,NAME_TOGGLE,CS_BUTTON,SECTION_BUTTON,
    NAME_FIELD, ORIENTATION_TOGGLE, 
    REVERSE_TOGGLE, REVERSE_VALUE_FIELD, REGULAR_LIST,
    REGULAR_VALUE_FIELD, REGULAR_LIST, REGULAR_VALUE_FIELD,REINFORCED_LIST,
    REINFORCED_VALUE_FIELD, OFFSET_FIELD, JUSTIF1_FIELD,JUSTIF2_FIELD,N1_BUTTON,
    C1_BUTTON, P1_BUTTON, N2_BUTTON, C2_BUTTON, P2_BUTTON, ANNOTATION_FIELD,
    FRAME_NAMES_BUTTON,-1};

  int i ;
  
  if(form == NULL) return 0;
  
  /* Particular traitement for LOADC_BUTTON witch is not always enable */
  if(command_type == PLACE)
    if(change_state == TRUE)
      FIg_enable(form,LOADC_BUTTON);
    else 
      FIg_disable(form,LOADC_BUTTON);
  
  /* Particular traitement for X_BUTTON , Y_BUTTON, Z_BUTTON */
  switch(coord_type)
   {
   case CLASS_PLANE:
     change_state_orient(form,FALSE);
     break;
   case CLASS_CS :
     change_state_orient(form,change_state);
     break;
     default : printf("Erreur in the class of cs\n");
   }  
  
  i = 0;
  while(main_table[i] != -1)
   {
     if(change_state == FALSE)
       FIg_disable(form,main_table[i]);
     else
       FIg_enable(form,main_table[i]);
     i++;
   }
  return 1;
}

/* change default name considering annotation */
/* The param_buf->annotation_field is suppossed to contains the new annot */

static void change_default_name(form,old_annot,param_buf,axis)
Form    form;                         /* [I] pointer to main form */
char    *old_annot;                   /* [I] Preceding annotation in the field */
struct  main_param_buffer *param_buf; /* [I] param_buffer where info are store */
char    axis;                         /* The axis of the frame system */
{
  int old_len,new_len;
  int i,num_def;
  struct GRid tmp_obj;
  IGRlong status;

  old_len = strlen(old_annot);
  new_len = strlen(param_buf->annotation_field);
  if(strncmp(old_annot,param_buf->name_fr,old_len) == 0)
   {
     if((param_buf->name_fr[old_len] == 'x' ||
	 param_buf->name_fr[old_len] == 'y' ||
	 param_buf->name_fr[old_len] == 'z') &&
	(param_buf->name_fr[old_len+1] == '\0' ||
	 sscanf(&param_buf->name_fr[old_len+1],"%d",&num_def)))
      {
	strcpy(param_buf->name_fr,param_buf->annotation_field);
	param_buf->name_fr[new_len] = axis;
	param_buf->name_fr[new_len+1] = '\0';
	status = di$translate(objname = param_buf->name_fr,
			      p_objid = &tmp_obj.objid);
	if(status == DIR_S_SUCCESS)
	  for(i=1;i<1000;i++)
	   {
	     sprintf(&param_buf->name_fr[new_len+1],"%d",i);
	     status = di$translate(objname = param_buf->name_fr,
				   p_objid = &tmp_obj.objid);
	     if(status != DIR_S_SUCCESS) break;
	   }
	FIg_set_text(form,NAME_FIELD,param_buf->name_fr);
      }
   }
}


/* Set the axis */
static void fr_set_axis(form,param_buf,ax1,ax2,ax3,cmd_type)
Form   form;                         /* [I] a pointer to the main form  */
struct main_param_buffer *param_buf; /* [I] the param_buffer            */
char   ax1,ax2,ax3;                  /* [I] ax1 is the axe selected     */
int    cmd_type;                     /* [I] The type of the command     */
{
  char str[4];
 
  param_buf->axis = ax1;
  str[0] = ax2; str[1] = '\0';
  FIg_set_text(form,JUSTIF1_FIELD,str);
  str[0] = ax3;
  FIg_set_text(form,JUSTIF2_FIELD,str);

  /* Set default name if a default name was in form */
  if(cmd_type == PLACE)
    change_default_name(form,param_buf->annotation_field,param_buf,ax1);
  
  switch(ax1) 
   {
   case 'x' :
     FIg_set_state_off(form,Y_BUTTON); 
     FIg_set_state_off(form,Z_BUTTON);
     FIg_set_state_on(form,X_BUTTON);
     break;
   case 'y' :
     FIg_set_state_off(form,X_BUTTON); 
     FIg_set_state_off(form,Z_BUTTON);
     FIg_set_state_on(form,Y_BUTTON);
     break;
   case 'z' :
     FIg_set_state_off(form,X_BUTTON); 
     FIg_set_state_off(form,Y_BUTTON);
     FIg_set_state_on(form,Z_BUTTON);
     break;
   } 
}

/* Test the coherence of the main paramater */
/* Return 1 if OK else 0 */

static int test_main_parameter(form,owner,param_buf,command_type)
Form                     form;        /* [I] pointer to main form */
struct GRid              *owner;     /* [I] Id of frame system   */
struct main_param_buffer *param_buf; /* [I] param_buffer where info are store */ 
int                      command_type; /* [I] PLACE or MODIFY */
{
  char my_msg[MY_MSG_LEN];

  FIg_get_text(form,NAME_FIELD,param_buf->name_fr);
  VDltrim(param_buf->name_fr);
  VDrtrim(param_buf->name_fr);
  if ( VDspace(param_buf->name_fr) ){
        FIg_set_text(form,FI_MSG_FIELD, "Name should not contain blanks");
                return 0;
  }
  if(param_buf->name_fr[0] == '\0')
   {
     ex$message( msgnumb = SM_I_FrNeedName, buff = my_msg); 
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return 0;
   }

  /* Jean 6/25/93 : Verify that name is not already existing */
  /* even in MODIFY COMMAND*/
  if(!SMCanChgElemName(owner,param_buf->name_fr))
   {
     ex$message( msgnumb = SM_I_FrSameName, buff = my_msg); 
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     return 0;
   }
  
  if(param_buf->reverse_toggle && param_buf->reverse_field < 0 )
   {
     ex$message( msgnumb = SM_I_FrNeedPos, buff = my_msg); 
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     display_double_field(form,REVERSE_VALUE_FIELD,NO_VALUE,param_buf->unit);
     return 0;
   }
  
  if(!strcmp(param_buf->regular_list,EMS_STRING) &&
     param_buf->regular_field <= 0)
   {
     ex$message( msgnumb = SM_I_FrNeedReg, buff = my_msg); 
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     display_double_field(form,REGULAR_VALUE_FIELD,NO_VALUE,param_buf->unit);
     return 0;
   }
  
  if(!strcmp(param_buf->reinforced_list,EMS_STRING) &&
     param_buf->reinforced_field <= 0)
   {
     ex$message( msgnumb = SM_I_FrNeedReinf, buff = my_msg); 
     FIg_set_text(form,FI_MSG_FIELD,my_msg);
     display_double_field(form,REINFORCED_VALUE_FIELD,NO_VALUE,param_buf->unit);
     return 0; 
   }
  return 1;
}     


/* Save the value for plane size in fonction of the type_list */

static void get_plane_size(type_list,value_field,ret_value)
IGRchar   *type_list;          /* [I] Small,Regular,Large,user             */
IGRdouble value_field;         /* [I] The value in the corresponding field */
IGRdouble *ret_value;          /* [O] The value return                     */
{
  if(strcmp(type_list,"Small") == 0) *ret_value = -1.0;
  else if(strcmp(type_list,"Regular") == 0) *ret_value = 0.0;
  else if(strcmp(type_list,"Large") == 0) *ret_value = -2.0;
  else
    *ret_value = value_field;
}

/* Fonction of value in the list_label put the value in field_label */

static void put_plane_size(last_value,list_str,field_value) 
IGRdouble  last_value;    /* [I] The last value save */
IGRchar    *list_str;     /* [O] String in the corresponding list */
IGRdouble  *field_value;  /* [O] Value return for the field      */
{
  switch((int)last_value)
   {
   case 0 : strcpy(list_str,"Regular");
     *field_value = NO_VALUE;
     break; 
   case -1 : strcpy(list_str,"Small");
     *field_value = NO_VALUE;
     break; 
   case -2 : strcpy(list_str,"Large");
     *field_value = NO_VALUE;
     break; 
     default   : strcpy(list_str,"Ems");
     *field_value = last_value;
   }
}

/* Given the objid of the cs return the cs_name */

static int retrieve_coord_syst_name(cs_obj,cs_name)
struct GRid *cs_obj;      /* [I] The objid of the cs       */                
char         *cs_name;    /* [O] The split name of the cs  */
{
  char comp_name[DI_PATH_MAX];
  IGRlong status,msg; 
  
  cs_name[0] =   '\0';
  comp_name[0] = '\0';
  
  status = om$send(msg = message GRvg.GRgetname(&msg,comp_name),
		   senderid = NULL_OBJID,
		   targetid = cs_obj->objid,
		   targetos = cs_obj->osnum);
  
  
  if(status != OM_S_SUCCESS || strcmp(comp_name,"") == 0)
    strcpy(cs_name,"defined");
  else
    di$split(pathname = comp_name, name = cs_name);  
  return 1;
}

/*       This fonction redisplay double field in main form        */

static void refresh_main_double_field(
Form                      form,      /* [I] Pointer to the form               */
struct main_param_buffer *param_buf, /* [I] param_buffer where info are store */
IGRchar                  *unit       /* [I] unit to display all this gadget   */
)
{
  /* Erase or display the gadget who depands from toggle */
  if(!param_buf->reverse_toggle)
    FIg_erase(form,REVERSE_VALUE_FIELD); 
  else
    display_double_field(form,REVERSE_VALUE_FIELD,param_buf->reverse_field,unit);
  
  if(strcmp(param_buf->regular_list,EMS_STRING))
    FIg_erase(form,REGULAR_VALUE_FIELD);
  else
    display_double_field(form,REGULAR_VALUE_FIELD,param_buf->regular_field,unit);
  
  if(strcmp(param_buf->reinforced_list,EMS_STRING))
    FIg_erase(form,REINFORCED_VALUE_FIELD);
  else
    display_double_field(form,REINFORCED_VALUE_FIELD,
			 param_buf->reinforced_field,unit);
  
  display_double_field(form,OFFSET_FIELD,param_buf->offset_field,unit);
}


/* This function refresh the lowest,highest ,nb_frame nb_sect field 
   in the main form */
void refresh_low_high(form,lowest,highest,nb_frame,nb_sect)
Form   form;                 /* [I] a pointer to the main form     */
IGRint lowest;               /* [I] the value of the lowest field  */
IGRint highest;              /* [I] the value of the highest field */
IGRint nb_frame;             /* [I] the number of frame            */
IGRint nb_sect;              /* [I] the number of section          */
{
  double total;
  
  if(lowest < MAX_VALUE_FROM_FIELD)    
    FIg_set_value(form,LOWEST_FRAME_FIELD,(double)lowest);
  else 
    FIg_set_value(form,LOWEST_FRAME_FIELD,0.0);       
  
  if(highest > MIN_VALUE_FROM_FIELD)
    FIg_set_value(form,HIGHEST_FRAME_FIELD,(double)highest);
  else
    FIg_set_value(form,HIGHEST_FRAME_FIELD,0.0);    
  
  
  if(nb_frame == (MIN_VALUE_FROM_FIELD - MAX_VALUE_FROM_FIELD + 1))
    total = 0.0;
  else total = (double) nb_frame ;
  
  FIg_set_value(form,TOTAL_FIELD,total );
  
  FIg_set_value(form,NB_SECTION_FIELD,(double)nb_sect);
}      

/* This function compute the lowest highest and nb_frame frame */

search_low_high(lowest,highest,nb_frame,nb_section,sections)
IGRint            *lowest;	    /* [O] the value of the lowest  */ 
IGRint            *highest;         /* [O] the value of the highest */
IGRint            *nb_frame;        /* [O] the number of frame      */
IGRint            nb_section;       /* [I] the number of sections   */
struct sect_info  *sections;        /* [I] the sections table       */
{
  IGRint low,high;
  int i;
  
  low = MAX_VALUE_FROM_FIELD;
  high = MIN_VALUE_FROM_FIELD;
  i = 0;
  while( i < nb_section)
   {
     if(sections[i].fr < low) low = sections[i].fr;
     if(sections[i].to > high) high = sections[i].to;
     i++;       
   }
  *lowest = low;
  *highest = high; 
  *nb_frame = high - low + 1;
  return 1;
}


/* This fonction verify if the object is the a frame system (owner) or
/* if it's a special frame */
/* Return 2 if old frame system */ 
/* Return 1 if OK else 0 */

SMIsFrameObj(obj,roots,owner,name_fr)
struct GRid *obj;       /* [I] The object to verify it's a frame macro  */
struct GRid *roots;     /* [O] The roots of the frame macro (must be allocated)*/
struct GRid *owner;     /* [O] The owner of the frame system 		*/
char        *name_fr;   /* [O] The name of the frame system  		*/
{
  IGRlong status,msg;
  struct GRid oneframe;
  short old_frame_syst = FALSE;
  char path_name_fr[DI_PATH_MAX];

    /* If it is an owner, find one component frame */
  if(SMIsKindOf(obj,OPP_SMfrm_syst_class_id))
   {
     owner->objid = obj->objid;
     owner->osnum = obj->osnum;
     if(!SMFrmFindOneComponent(owner,(char *)NULL,&oneframe))
      {
	printf("Strange error, no frame found in frame system\n");
	return 0;
      }
   }
  else
    if(SMIsKindOf(obj,OPP_SMframe_class_id))
      /* It's a particular frame, retrieve his owner */
     {
       owner->objid = NULL_OBJID;
       name_fr[0]   = '\0';
       oneframe.objid = obj->objid;
       oneframe.osnum = obj->osnum;
       
       /* Is there an owner eligible */
       
       status = om$send(msg = message SMframe.SMfind_frm_syst(&msg,owner),
			senderid = NULL_OBJID,
			targetid = obj->objid,
			targetos = obj->osnum);
       if(!(status & msg & 1))
	{
	  printf("Warning, It's an old frame system\n");
	  old_frame_syst = TRUE;
	}
     }
    else return 0; /* Not a frame system */

  
  if(owner->objid != NULL_OBJID)
   {
     status = om$send(msg = message GRvg.GRgetname(&msg,path_name_fr),
		      senderid = NULL_OBJID,
		      targetid = owner->objid,
		      targetos = owner->osnum);
     if(!(status & msg &1))
      {
	printf("Erreur retrieving frame system name\n");
	return 0;
      }
     di$split(pathname = path_name_fr,
	      name     = name_fr);
   }

  if(!SMFrmRetrieveRoots(&oneframe,roots))
   {printf("Erreur retrieve roots of frm_syst\n"); return 0;}

  if(old_frame_syst) return 2 ;else return 1;
}

method form_notification (int form_label; int gadget_label ; double value ;
                           char * form_ptr)
{
  int    status = OM_S_SUCCESS;
  long   msg;
  char   my_msg[MY_MSG_LEN];
  int    sel_flag,r_pos;
  int    row,pos,col;
  double ext_value;
  char   dummy_str[ATTR_TXT * NB_CUT_STR];
  char   old_annot[10];
  int    test;
  
  int mode;
  
  if ( form_ptr == NULL )
   {
     /*| no form_ptr set */
     return( OM_E_INVARG ); 
   }
  
  
  FIg_set_text(me->forms[MAIN].form_ptr,FI_MSG_FIELD,"");
  FIg_set_text(me->forms[SECTION].form_ptr,FI_MSG_FIELD,"");
  
  if( form_ptr == me->forms[MAIN].form_ptr ) 
   {
     
     switch( gadget_label )
      {
      case FI_ACCEPT :
	status = om$send(msg = message SMCmdPlMdFr.save_all(&msg),
			 targetid = my_id);
	
	if(status != OM_S_SUCCESS || msg != SUCC)    
	 { 
	   FIg_set_state_off(me->forms[MAIN].form_ptr,FI_ACCEPT);
	   goto quit;
	 }   
        _put_response(resp = TERMINATE);
	goto quit;
	
      case FI_CANCEL : 
        _put_response(resp = TERMINATE);
        break;
	
      case FI_RESET :
	me->param_buf = me->old_param_buf;
	
	SMResetSectForm(me->forms[SECTION].form_ptr,me->forms[MAIN].form_ptr,
			me->old_sect_info,me->first_sect_info,me->sect_dist,
			&me->old_nb_sect,me->first_nb_sect,&me->old_frame_str,
			me->is_def_num,me->is_def_dist,
			me->param_buf.unit,me->old_param_buf.unit);
	
	for(row = 0; row < me->old_nb_sect; row++)
	  me->new_sect_info[row] = me->old_sect_info[row];
	me->new_nb_sect = me->old_nb_sect; 
	
        
        status = om$send(msg = message SMCmdPlMdFr.refresh_main_form(&msg),
			 targetid = my_id);
	
	if(status != OM_S_SUCCESS || msg != SUCC)   
         {
	   printf("Probleme displaying main form\n"); 
	   _put_response(resp = TERMINATE);
	   goto quit;
         }   
	break;
	
      case FI_EXECUTE :
	status = om$send(msg = message SMCmdPlMdFr.save_all(&msg),
			 targetid = my_id);
	/* Added for TR:179601559 */
	{
		IGRlong sts;
	if (!SMFillFrmDefInfo(&me->list[2],NB_MAX_SECTION,&me->first_frame))
		goto quit;
 
	om$send(msg = message SMCmdPlMdFr.reinit_all(&sts,MODIFY),
			targetid = my_id);
	if (!(sts & 1)) goto quit;
 
	}
	/* Added */
	
	if(status != OM_S_SUCCESS || msg != SUCC)
	 {
	   FIg_set_state_off(me->forms[MAIN].form_ptr,FI_EXECUTE);
	   goto quit;
	 }
	switch(me->mytype)
	 {
	 case PLACE:
	   ex$message(msgnumb = SM_M_FrPlace);
	   /* Jean 6/23/93 : Reinit form after placing */
	   om$send(msg = message SMCmdPlMdFr.reinit_all(&msg,PLACE),
		   targetid = my_id);
	   if(!(msg & 1)) goto quit;  
	   break;

	 case MODIFY:
	   ex$message(msgnumb = SM_M_FrModify);
	   FIg_set_state_off(me->forms[MAIN].form_ptr,FI_EXECUTE);
           /* Commented for TR#179601151 -Ravi 03/20/96 */
	   /* Jean 6/23/93 : allow to relocate a new frame system  
	   _put_response(resp = RELOCATE_FRAME);  */
	   break;
	 }
	FIg_set_state_off(me->forms[MAIN].form_ptr,FI_EXECUTE);
	break;
	
      case LOADC_BUTTON : 
	main_change_state_gadget(me->forms[MAIN].form_ptr,FALSE,
				 me->mytype,me->param_buf.class_cs);
	_put_response( resp = LOADC );
	goto quit;

      case NAME_FIELD :
	{
           char name[80];
           FIg_get_text(me->forms[0].form_ptr,NAME_FIELD,name);
           VDltrim(name);
           VDrtrim(name);
           if ( VDspace(name) )
                FIg_set_text(me->forms[MAIN].form_ptr,FI_MSG_FIELD,
                        "Name should not contain blanks");
           else
                strcpy(me->param_buf.name_fr,name);
        }
	/*
	FIg_get_text(me->forms[0].form_ptr,NAME_FIELD,me->param_buf.name_fr);
	*/
        break;
	
      case CS_BUTTON :
       {
	 IGRlong test;
	 
	 /* Desactivate all the gadget */
	 main_change_state_gadget(me->forms[MAIN].form_ptr,FALSE,
				  me->mytype,me->param_buf.class_cs);
	 
	 /* Higlight the old active coordinate system*/
	 
	 status = dp$display(msg = &test, oids = &me->param_buf.cs,mode = GRhd);
	 if(status != TRUE || test != MSSUCC)
	   printf("Can't higlight the coordinate system\n");
         
	 _put_response(resp = COORDINATE); 
	 break;
       } 
	
      case FRAME_NAMES_BUTTON :

	main_change_state_gadget(me->forms[MAIN].form_ptr,FALSE,
                                 me->mytype, me->param_buf.class_cs);
   	{
		int xsec, ysec;
     		int xmain,ymain,hmain,wmain; /* Main form position */
 
     		/* Where is the main form parameter */
     		FIf_get_location(me->forms[MAIN].form_ptr,&xmain,&ymain);
     		FIf_get_size(me->forms[MAIN].form_ptr,&hmain,&wmain);
 
     		xsec = xmain + wmain + 10 ;
     		ysec = ymain;
     		FIf_set_location(me->forms[NAMES].form_ptr,xsec,ysec);
   	}
	if ( me->param_buf.name_toggle ){
                FIfld_set_text(me->forms[NAMES].form_ptr, DEFAULT_FR_NAME,
                                0, 2, "Distance", FALSE);
        } else {
                FIfld_set_text(me->forms[NAMES].form_ptr, DEFAULT_FR_NAME,
                                0, 2, "Number", FALSE);
        }
        FIfld_set_text(me->forms[NAMES].form_ptr, DEFAULT_FR_NAME,
                                0, 1, me->param_buf.annotation_field, FALSE);
	{
     		om$send(msg = message SMCmdPlMdFr.SMSetNmFrm(
				me->forms[NAMES].form_ptr),targetid = my_id);
		as$status();
   	}
	FIf_display( me->forms[NAMES].form_ptr );

	break;

      case SECTION_BUTTON :
	main_change_state_gadget(me->forms[MAIN].form_ptr,FALSE,
				 me->mytype, me->param_buf.class_cs);
	
	/* The unit we are working while form section is displayed   */
	/* is me->sect_unit. The unit is in me->param_buf.unit. */
	strcpy(me->sect_unit,me->param_buf.unit);

	SMRefreshSectionForm(me->forms[SECTION].form_ptr,
			     me->forms[MAIN].form_ptr,
			     me->new_sect_info,me->sect_dist,
			     me->new_nb_sect,&me->old_frame_str,
			     me->is_def_num,me->is_def_dist,
			     &me->xsec,&me->ysec,me->sect_unit);
	
	_put_response(resp = DISPLAY_SECTION);
	break;  
	
	
      case X_BUTTON :
	fr_set_axis(form_ptr,&me->param_buf,'x','y','z',me->mytype);
	break;
      case Y_BUTTON :
	fr_set_axis(form_ptr,&me->param_buf,'y','z','x',me->mytype);
	break;
      case Z_BUTTON :
	fr_set_axis(form_ptr,&me->param_buf,'z','x','y',me->mytype);
	break;                 
	
	/* Jean 20 July 93 : new gadget for type name of frame */
      case NAME_TOGGLE:
	FIg_get_state(form_ptr,NAME_TOGGLE, &me->param_buf.name_toggle);
	if ( me->param_buf.name_toggle ){
		FIfld_set_text(me->forms[NAMES].form_ptr, DEFAULT_FR_NAME,
                                0, 2, "Distance", FALSE);
	} else {
		FIfld_set_text(me->forms[NAMES].form_ptr, DEFAULT_FR_NAME,
                                0, 2, "Number", FALSE);
	}
	break;  

      case ORIENTATION_TOGGLE :
	FIg_get_state(form_ptr,ORIENTATION_TOGGLE,&me->param_buf.orient_toggle);
	break;                    
	
      case REVERSE_TOGGLE :
	FIg_get_state(form_ptr,REVERSE_TOGGLE,&me->param_buf.reverse_toggle);
	if(me->param_buf.reverse_toggle)
          display_double_field(form_ptr,REVERSE_VALUE_FIELD,NO_VALUE,
			       me->param_buf.unit);
	else /*Reverse Toggle is No*/ 
	 {
           me->param_buf.reverse_field = NO_REV_DIST;
           FIg_erase(form_ptr,REVERSE_VALUE_FIELD);
	 }
        break;
	
      case REVERSE_VALUE_FIELD :
	FIg_get_value(form_ptr,REVERSE_VALUE_FIELD,&ext_value);
	if(ext_value < 0.0)
	 {
	   ex$message( msgnumb = SM_I_FrNeedPos, buff = my_msg);
	   FIg_set_text(form_ptr,FI_MSG_FIELD,my_msg);
	   me->param_buf.reverse_field = NO_REV_DIST;
	   display_double_field(form_ptr,REVERSE_VALUE_FIELD,NO_VALUE,
				me->param_buf.unit);
	 }
	else 
	  SMfr_convert_unit_int(ext_value,me->param_buf.unit,
				&me->param_buf.reverse_field);
	break; 
	
      case REGULAR_LIST : 
	FIg_get_text(form_ptr,REGULAR_LIST,me->param_buf.regular_list);
	if(strcmp(me->param_buf.regular_list,EMS_STRING) == 0)
	 {
	   test = display_double_field(form_ptr,REGULAR_VALUE_FIELD,NO_VALUE,
				       me->param_buf.unit);
	   
	   if(test != SUCC)
	    {
	      printf("error display_double_field in main form\n"); 
	      _put_response(resp = TERMINATE);
	      goto quit;      
	    }
	 }
	else 
	 {
	   me->param_buf.regular_field = NO_VALUE;
	   /*"Regular list is %s\n",me->param_buf.regular_list*/
	   FIg_erase(form_ptr,REGULAR_VALUE_FIELD);
	 }
	break;

      case REGULAR_VALUE_FIELD : 
	FIg_get_value(form_ptr,REGULAR_VALUE_FIELD,&ext_value);
	if(ext_value <= 0.0)
	 {
	   ex$message( msgnumb = SM_I_FrNeedPos, buff = my_msg);
	   FIg_set_text(form_ptr,FI_MSG_FIELD,my_msg);
	   me->param_buf.regular_field = NO_REV_DIST;
	   display_double_field(form_ptr,REGULAR_VALUE_FIELD,NO_VALUE,
				me->param_buf.unit);
	 }
	else
	  SMfr_convert_unit_int(ext_value,me->param_buf.unit,
				&me->param_buf.regular_field);
	break; 
	
      case REINFORCED_LIST : 
	FIg_get_text(form_ptr,REINFORCED_LIST,me->param_buf.reinforced_list);
	if(strcmp(me->param_buf.reinforced_list,EMS_STRING) == 0)
         {
	   test = display_double_field(form_ptr,REINFORCED_VALUE_FIELD, NO_VALUE,
				       me->param_buf.unit);
	   if(test != SUCC)
            {
	      printf("error display field in main form\n"); 
	      _put_response(resp = TERMINATE);
	      goto quit;      
            }
	 }
	else 
	 {
	   me->param_buf.reinforced_field = NO_VALUE;
	   /*"Reinforced list is %s\n",me->param_buf.reinforced_list*/
	   FIg_erase(form_ptr,REINFORCED_VALUE_FIELD);
	 }
	break;
      case REINFORCED_VALUE_FIELD : 
	FIg_get_value(form_ptr,REINFORCED_VALUE_FIELD,&ext_value);
	if(ext_value <= 0.0)
	 {
	   ex$message( msgnumb = SM_I_FrNeedPos, buff = my_msg);
	   FIg_set_text(form_ptr,FI_MSG_FIELD,my_msg);
	   me->param_buf.reinforced_field = NO_REV_DIST;
           
	   display_double_field(form_ptr,REINFORCED_VALUE_FIELD,NO_VALUE,
				me->param_buf.unit);
	 }
	else
	  SMfr_convert_unit_int(ext_value,me->param_buf.unit,
				&me->param_buf.reinforced_field);
	break;
	
      case OFFSET_FIELD :
	FIg_get_value(form_ptr,OFFSET_FIELD,&ext_value);
	SMfr_convert_unit_int(ext_value,me->param_buf.unit,
			      &me->param_buf.offset_field);
	break;
	
      case N1_BUTTON : 
	me->param_buf.justification[0] = 'N';
	break; 
      case C1_BUTTON : 
	me->param_buf.justification[0] = 'C';
	break;
      case P1_BUTTON : 
	me->param_buf.justification[0] = 'P';
	break; 
      case N2_BUTTON : 
	me->param_buf.justification[1] = 'N';
	break; 
      case C2_BUTTON : 
	me->param_buf.justification[1] = 'C';
	break;
      case P2_BUTTON : 
	me->param_buf.justification[1] = 'P';
	break; 
      case ANNOTATION_FIELD :
	strcpy(old_annot,me->param_buf.annotation_field);
	FIfld_get_text(me->forms[MAIN].form_ptr,ANNOTATION_FIELD,0,0,
		       	9,(unsigned char*)me->param_buf.annotation_field,
			&sel_flag,&r_pos);
	me->param_buf.annotation_field[9] = '\0';
	FIfld_set_text(me->forms[NAMES].form_ptr, DEFAULT_FR_NAME, 
				0, 1, me->param_buf.annotation_field, FALSE);
	if(me->mytype == PLACE)
	  change_default_name(me->forms[MAIN].form_ptr,
			      old_annot,&me->param_buf,me->param_buf.axis);
	break;
      } /* END switch ( gadget_label ) */
   } /* if MAIN FORM */	
  
  else if( form_ptr == me->forms[SECTION].form_ptr)
   { 
     switch ( gadget_label )
      {
      case FI_ACCEPT:
	if(SMSaveSections(form_ptr, me->new_sect_info,me->old_sect_info,
			  me->sect_dist,me->new_nb_sect,&me->old_nb_sect,
			  &me->old_frame_str,me->is_def_num,me->is_def_dist,
			  me->param_buf.unit,me->sect_unit))
	 {
	   main_change_state_gadget(me->forms[MAIN].form_ptr,TRUE,
				    me->mytype,me->param_buf.class_cs);
	   FIg_set_state_off(form_ptr,FI_ACCEPT);
	   FIg_set_state_off(me->forms[MAIN].form_ptr,SECTION_BUTTON);
	   if ( me->new_nb_sect != 0)
		FIg_enable(me->forms[MAIN].form_ptr,FRAME_NAMES_BUTTON);
	   else
		FIg_disable(me->forms[MAIN].form_ptr,FRAME_NAMES_BUTTON);
	   _put_response(resp = ERASE_SECTION);
	 }
	FIg_set_state_off(form_ptr,FI_ACCEPT);
        break;
	
      case FI_EXECUTE :
	SMSaveSections(form_ptr, me->new_sect_info,me->old_sect_info,
		       me->sect_dist,me->new_nb_sect,&me->old_nb_sect,
		       &me->old_frame_str,me->is_def_num,me->is_def_dist,
		       me->param_buf.unit,me->sect_unit);
	FIg_set_state_off(form_ptr,FI_EXECUTE);
	break; 
	
      case FI_CANCEL:
	SMResetSectForm(me->forms[SECTION].form_ptr,me->forms[MAIN].form_ptr,
			me->new_sect_info,me->old_sect_info,me->sect_dist,
			&me->new_nb_sect,me->old_nb_sect,&me->old_frame_str,
			me->is_def_num,me->is_def_dist,
			me->sect_unit,me->param_buf.unit);
	
	refresh_main_double_field(me->forms[0].form_ptr,&me->param_buf,
				  me->param_buf.unit);
	main_change_state_gadget(me->forms[MAIN].form_ptr,TRUE,
                                 me->mytype,me->param_buf.class_cs);
        FIg_set_state_off(me->forms[MAIN].form_ptr,SECTION_BUTTON);
	if ( me->new_nb_sect != 0)
                FIg_enable(me->forms[MAIN].form_ptr,FRAME_NAMES_BUTTON);
           else 
                FIg_disable(me->forms[MAIN].form_ptr,FRAME_NAMES_BUTTON);
         _put_response(resp = ERASE_SECTION);
        break;		
	
	
      case FI_RESET:
	strcpy(me->param_buf.unit,me->old_param_buf.unit);
	SMResetSectForm(me->forms[SECTION].form_ptr,me->forms[MAIN].form_ptr,
			me->new_sect_info,me->old_sect_info,me->sect_dist,
			&me->new_nb_sect,me->old_nb_sect,&me->old_frame_str,
			me->is_def_num,me->is_def_dist,
			me->sect_unit,me->param_buf.unit);
	refresh_main_double_field(me->forms[0].form_ptr,&me->param_buf,
				  me->param_buf.unit);
	
	FIg_set_state_off(form_ptr,SECTION_FIELD);
	FIg_set_state_off(form_ptr,FI_CANCEL);
	break;         
	
      case SECTION_FIELD :
	FIfld_get_mode(form_ptr,SECTION_FIELD,OFFSET,&mode);
	FIfld_get_active_row(form_ptr,SECTION_FIELD, &row,&pos);
	
	if(mode == FI_INSERT)   /* User want introduce a data */
	 {
	   FIg_set_text(form_ptr,FI_MSG_FIELD,"");
	   FImcf_get_active_col(form_ptr,SECTION_FIELD,&col,&pos);
	  
	   switch(col)
	    {
	    case FROM : 
	      SMselect_from_field(form_ptr,me->forms[MAIN].form_ptr,
				  me->new_sect_info,&me->new_nb_sect,
				  row,me->is_def_num);
	      break;
	      
	    case TO :
	      SMselect_to_field(form_ptr,me->forms[MAIN].form_ptr,
				me->new_sect_info,&me->new_nb_sect,
				row,me->is_def_num);
	      break;
	      
	    case SPACING:
	      SMselect_spacing_field(form_ptr,me->forms[MAIN].form_ptr,
				     me->new_sect_info,&me->new_nb_sect,
				     row,me->is_def_num,me->sect_unit);
	      break;
	    case OFFSET: 
	      SMselect_offset_field(form_ptr,me->new_sect_info,row);
	      break;
	    case X1:
	      SMselect_X1_field(form_ptr,me->sect_dist,&me->new_nb_sect,
				row,me->is_def_dist,me->sect_unit);
	      break;
	    case X2:
	      SMselect_X2_field(form_ptr,me->sect_dist,&me->new_nb_sect,
				row,me->is_def_dist,me->sect_unit);
	      break;
	    case NUMBER:
	      SMselect_number_field(form_ptr,me->sect_dist,&me->new_nb_sect,
				    me->new_sect_info,
				    row,me->is_def_dist);
	      break;
	    }
	 }
	else  /* User want delete or insert a section */
	 { 
	   int num_rows;
	   int state = FALSE;
	   long msg_number = 0;

	   FIfld_get_num_rows(form_ptr,SECTION_FIELD,&num_rows);
	   for(row = 0; row < num_rows; row++)
	    {
	      FIfld_get_select(form_ptr,SECTION_FIELD,row,0,&sel_flag);
	      if(sel_flag) break;
	    }
	   if(sel_flag)  /* One row is selected */
	    {
	      /* Find if we are on insert or delete row */
	     FIg_get_state(form_ptr,DEL_BUTTON,&state);
	     if(state)  msg_number = SM_I_FrValDel;
	     else
	      {
		FIg_get_state(form_ptr,INSERT_BUTTON,&state);
		if(state) msg_number = SM_I_FrValIns ;
	      }
	   }   /* if(sel_flag) */
	 
	   else /* First select row */
	    {
	      FIg_get_state(form_ptr,DEL_BUTTON,&state);
	      if(state) msg_number = SM_I_FrSelDelRow;
	      else
	       {
		 FIg_get_state(form_ptr,INSERT_BUTTON,&state);
		 if(state) msg_number = SM_I_FrSelInsRow ;
	       }
	    }
	   if(state)
	    {
	      ex$message( msgnumb = msg_number, buff = my_msg);
	      FIg_set_text(form_ptr,FI_MSG_FIELD,my_msg);
	    }
	 }
	break;
	
      case REVERSE_FIELD :
	SMselect_rev_field(form_ptr,dummy_str); /* Doesn't need to save now */
	break;

      case UNIT_FIELD:
	if(SMselect_unit(form_ptr,
			 me->new_sect_info,me->sect_dist,me->new_nb_sect,
			 me->is_def_num,me->is_def_dist,
			 me->sect_unit))
	  refresh_main_double_field(me->forms[0].form_ptr,&me->param_buf,
				    me->sect_unit);
	break;
		      
      case REINF_FIELD :
	SMselect_reinf_field(form_ptr,dummy_str); /* Doesn't need to save now */
	break;
                
      case DEL_BUTTON:
	SMselect_delete_section(form_ptr,me->forms[MAIN].form_ptr,
			      me->new_sect_info,me->sect_dist,
			      &me->new_nb_sect,
			      me->is_def_num,me->is_def_dist);
	break;  

      case  INSERT_BUTTON:
	SMselect_insert_section(form_ptr,
				me->new_sect_info,me->sect_dist,
				&me->new_nb_sect,
				me->is_def_num,me->is_def_dist);
	break;

      case MODE_TOGGLE:
	SMselect_mode_toggle(form_ptr,me->new_sect_info,me->sect_dist,
			     me->is_def_num,me->is_def_dist,
			     me->new_nb_sect,me->sect_unit);
	break;
	
      } /* END switch ( gadget_label ) */
   }  /* END if form_ptr = SECTION */   
   else if ( form_ptr == me->forms[NAMES].form_ptr ){
	IGRint i;
 
	switch ( gadget_label ){
                case FI_ACCEPT :
 
			compute_nb_nm_sect(me->new_nm_sect_info, 
					me->is_def_name, 
					&me->new_nb_nm_sect);
			/* 
                        for (i=0; i<me->new_nb_nm_sect; i++){
                                printf ("%d-%d, %s, %d\n",
                                        me->new_nm_sect_info[i].fr,
                                        me->new_nm_sect_info[i].to,
                                        me->new_nm_sect_info[i].name,
                                        me->new_nm_sect_info[i].dorn);
                        }
                        */

			/* if ( me->new_nb_nm_sect == 0){
				FIg_set_text(form_ptr,MESSAGE_NAME,
					"No Name Section Defined");
			} else */{

				
			   status=om$send(msg=message SMCmdPlMdFr.SMReSetNmFrm(
					form_ptr, FI_ACCEPT),
                                targetid=my_id);
                           as$status();

                       	   main_change_state_gadget(me->forms[MAIN].form_ptr,
			   TRUE, me->mytype,me->param_buf.class_cs);
                           FIg_set_state_off(form_ptr,FI_ACCEPT);
                           FIg_set_state_off(me->forms[MAIN].form_ptr,
                                        FRAME_NAMES_BUTTON);
                           FIf_erase(form_ptr);
			}
 
                break;
 
                case FI_EXECUTE :
                        status=om$send(msg = message SMCmdPlMdFr.SMReSetNmFrm(
                                form_ptr, FI_EXECUTE),
                                targetid=my_id);
                        as$status();
                        FIg_set_state_off(form_ptr,FI_EXECUTE);
                break;
 
                case FI_CANCEL :
                        status=om$send(msg = message SMCmdPlMdFr.SMReSetNmFrm(
                                form_ptr, FI_CANCEL),
                                targetid=my_id);
                        as$status();
                        main_change_state_gadget(me->forms[MAIN].form_ptr,TRUE,
                                 me->mytype,me->param_buf.class_cs);
                        FIg_set_state_off(me->forms[MAIN].form_ptr,
                                        FRAME_NAMES_BUTTON);
                        FIf_erase(form_ptr);
 
                break;
 
                case FI_RESET :
                        status=om$send(msg = message SMCmdPlMdFr.SMReSetNmFrm(
                                form_ptr, FI_RESET),
                                targetid=my_id);
                        as$status();
                        FIg_set_state_off(form_ptr,FRAME_NO_NAME);
                        FIg_set_state_off(form_ptr,FI_CANCEL);
 
                break;
 
                case FRAME_NO_NAME :
 
                        status=om$send(msg = message SMCmdPlMdFr.SMProcFrmNmFld(
                                form_ptr),
                                targetid=my_id);
                        as$status();
 
                break;
 
        }

   } /* END if form_ptr = NAMES */
 quit:
  return OM_S_SUCCESS;
}

 /* Method to control and retrieve information when a frame system or frame */
 /* has been located.                                                       */
method control_frame( long *sts )
{
 
  struct GRid framelocate;
  int         test;
  
  dp$erase_hilite(msg = sts);  
  
  /* Enable all the gadget if form is displayed ( call by LOADC_BUTTON ) */
  FIf_is_displayed(me->forms[MAIN].form_ptr,&test);
  if(test)
   { 
     FIg_set_state_off(me->forms[MAIN].form_ptr,LOADC_BUTTON);
     main_change_state_gadget(me->forms[MAIN].form_ptr,TRUE,
			      me->mytype,me->param_buf.class_cs);
   }
  
  framelocate = me->event1.located_object[0].located_obj;

  /* verify it's a frame */
  switch(SMIsFrameObj(&framelocate,me->list,&me->owner,me->param_buf.name_fr))
   {
   case 0:
     *sts = MY_ERROR;
     goto quit;
   case 1:
     break;
   case 2:
     *sts = OLD_FRAME_SYSTEM;
     goto quit;
   }

  me->first_frame.sect_info = me->first_sect_info;
  me->first_frame.nm_sect_info = me->first_nm_sect_info;
  
  /* Retrieve the information for the frame_def structure */
  if(!SMFillFrmDefInfo(&me->list[2],NB_MAX_SECTION,&me->first_frame))
   {
    *sts = OM_E_ABORT;
     goto quit;
   }

	/* 
        {
                int i;
                for (i=0; i<me->first_frame.nb_nm_sect; i++){
                        printf ("%d-%d, %s, %d\n",
                                me->first_frame.nm_sect_info[i].fr,
                                me->first_frame.nm_sect_info[i].to,
                                me->first_frame.nm_sect_info[i].name,
                                me->first_frame.nm_sect_info[i].dorn);
                }
        }
        */
	

  om$send(msg = message SMCmdPlMdFr.reinit_all(sts,MODIFY),targetid = my_id);
  if(!(*sts & 1)) { *sts = OM_E_ABORT; goto quit; }
  
  *sts = SUCC;

 quit:
  return OM_S_SUCCESS;
}

/* Refresh all the gadgets for the main form :
   the buffer and the visualisation correspond each other */

method refresh_main_form( long *sts )
{
  int low,high,nb_frame;

  FIg_set_text(me->forms[MAIN].form_ptr,NAME_FIELD,me->param_buf.name_fr);
     
  /* First refresh all gadget */
  switch(me->param_buf.axis)
   {
   case 'x' :
     fr_set_axis(me->forms[MAIN].form_ptr,&me->param_buf,'x','y','z',me->mytype);
     break;
   case 'y' :
     fr_set_axis(me->forms[MAIN].form_ptr,&me->param_buf,'y','z','x',me->mytype);
     break;
   case 'z' :
     fr_set_axis(me->forms[MAIN].form_ptr,&me->param_buf,'z','x','y',me->mytype);
     break; 
   }
  
  /* Disable x and y if cs is a plane */
  switch(me->param_buf.class_cs)
   {
   case CLASS_PLANE :
     change_state_orient(me->forms[MAIN].form_ptr,FALSE);    
     break;
   case CLASS_CS :
     change_state_orient(me->forms[MAIN].form_ptr,TRUE); 
     break;
   } 
  
  if(me->mytype == PLACE)
    FIg_enable(me->forms[MAIN].form_ptr,LOADC_BUTTON);
  else
    FIg_disable(me->forms[MAIN].form_ptr,LOADC_BUTTON);
  
  
  FIg_set_text(me->forms[MAIN].form_ptr,CS_FIELD,me->param_buf.name_cs);
  FIg_set_text(me->forms[MAIN].form_ptr,NAME_FIELD,me->param_buf.name_fr);   

  /* Jean 20 July 93 : add name toggle */
  FIg_set_state(me->forms[MAIN].form_ptr,NAME_TOGGLE,
		me->param_buf.name_toggle);
  FIg_set_state(me->forms[MAIN].form_ptr,ORIENTATION_TOGGLE,
		me->param_buf.orient_toggle); 
  FIg_set_state(me->forms[MAIN].form_ptr,REVERSE_TOGGLE,
		me->param_buf.reverse_toggle);
  FIg_set_text(me->forms[MAIN].form_ptr,REGULAR_LIST,
	       me->param_buf.regular_list);
  FIg_set_text(me->forms[MAIN].form_ptr,REINFORCED_LIST,
	       me->param_buf.reinforced_list); 
  FIg_set_text(me->forms[MAIN].form_ptr,ANNOTATION_FIELD,
	       me->param_buf.annotation_field);
  
  FIg_set_state_off(me->forms[MAIN].form_ptr,N1_BUTTON);
  FIg_set_state_off(me->forms[MAIN].form_ptr,C1_BUTTON);
  FIg_set_state_off(me->forms[MAIN].form_ptr,P1_BUTTON);
  FIg_set_state_off(me->forms[MAIN].form_ptr,N2_BUTTON);
  FIg_set_state_off(me->forms[MAIN].form_ptr,C2_BUTTON);
  FIg_set_state_off(me->forms[MAIN].form_ptr,P2_BUTTON);
  
  switch( me->param_buf.justification[0] )
   {
   case 'N' : FIg_set_state_on(me->forms[MAIN].form_ptr,N1_BUTTON);
     break;
   case 'C' : FIg_set_state_on(me->forms[MAIN].form_ptr,C1_BUTTON);
     break;
   case 'P' : FIg_set_state_on(me->forms[MAIN].form_ptr,P1_BUTTON);
     break;
   }
  switch( me->param_buf.justification[1] )
   {
   case 'N' : FIg_set_state_on(me->forms[MAIN].form_ptr,N2_BUTTON);
     break;
   case 'C' : FIg_set_state_on(me->forms[MAIN].form_ptr,C2_BUTTON);
     break;
   case 'P' : FIg_set_state_on(me->forms[MAIN].form_ptr,P2_BUTTON);
     break;
   }
  
  /* Refresh the gadget for number of section */     
  FIg_set_value(me->forms[MAIN].form_ptr,NB_SECTION_FIELD,
		(double)me->new_nb_sect);
  
  refresh_main_double_field(me->forms[0].form_ptr,&me->param_buf,
			    me->param_buf.unit);

  /* Update lowest and highest and total field */
  search_low_high(&low,&high,&nb_frame,me->new_nb_sect,
		  me->new_sect_info);
  refresh_low_high(me->forms[MAIN].form_ptr,low,high,nb_frame,me->new_nb_sect);
  
  *sts = SUCC; 
  return OM_S_SUCCESS;
}


/* Init all the parameter for the main form */

method init_param_buf( long *sts ; int type_init )
{
  int         dummy,i;
  long        status = OM_S_SUCCESS;
  struct GRid go_cs;
  IGRshort    mat_type;
  IGRdouble   matrix[16];
  struct GRid tmp_obj;
  IGRlong     msg;
  short       flag = 0, num_defaults = 1;

  switch(type_init)
   {
   case PLACE :
     me->owner.objid = NULL_OBJID;
     me->old_param_buf.axis = 'x';	
     me->old_param_buf.reverse_toggle = 0;

     /* Generated annotation axis as default name */
     me->old_param_buf.name_fr[0] = 'F';
     me->old_param_buf.name_fr[1] = 'x';
     me->old_param_buf.name_fr[2] = '\0';
     status = di$translate(objname =  me->old_param_buf.name_fr,
			   p_objid = &tmp_obj.objid);
     if(status == DIR_S_SUCCESS)
       for(i=1;i<1000;i++)
	{
	  sprintf(&me->old_param_buf.name_fr[2],"%d",i);
	  status = di$translate(objname =  me->old_param_buf.name_fr,
				p_objid = &tmp_obj.objid);
	  if(status != DIR_S_SUCCESS) break;
	}
     
     /* Filled default field */
     strcpy(me->old_param_buf.regular_list,"Regular");
     strcpy(me->old_param_buf.reinforced_list,"Large");
     strcpy(me->old_param_buf.annotation_field,"F");
     me->old_param_buf.justification[0] = 'C';
     me->old_param_buf.justification[1] = 'C';
     me->old_param_buf.orient_toggle = 1;
     me->old_param_buf.offset_field = 0.0;
     me->old_param_buf.name_toggle  = 0;
     me->old_param_buf.reverse_field =  NO_REV_DIST ;
     me->old_param_buf.reinforced_field = NO_VALUE;
     me->old_param_buf.regular_field = NO_VALUE;
     
     /* Get current active coordinate system */
     ex$get_cur_mod(osnum = &me->old_param_buf.cs.osnum);
     status = cs$get_active_info( msg = sts,
				 osnum = me->old_param_buf.cs.osnum,
				 objid = &me->old_param_buf.cs.objid,
				 namebuf_size = DI_PATH_MAX,
				 name = me->old_param_buf.name_cs,
				 namebytes_ret = &dummy);
     
     as$status(action = RET_STATUS);
     me->old_param_buf.class_cs = CLASS_CS;        
     
     /*"cs objid is %d\n",me->old_param_buf.cs.objid*/
     if(!strcmp(me->old_param_buf.name_cs,""))
       strcpy(me->old_param_buf.name_cs,"defined");
     else
      {
	char cs_name[DI_PATH_MAX];
	
	di$split(pathname = me->old_param_buf.name_cs,
		 name     = cs_name);  
	strcpy(me->old_param_buf.name_cs,cs_name);
      }        
     
     FIg_set_text(me->forms[MAIN].form_ptr,CS_FIELD,me->old_param_buf.name_cs);
     
     as$make_source(go_grid = me->old_param_buf.cs,
		    mod_env = &me->ModuleInfo,
		    as_os   = me->ModuleInfo.md_id.osnum,
		    as_grid = &me->old_param_buf.cs);

     /* Jean 20 July 93 Get default unit for distance */
     co$get_default_units(msg           = &msg,
			  table_name    = GRIO_DISTANCE,
			  osnum         = me->ModuleInfo.md_id.osnum,
			  flag          = &flag,
			  num_defaults  = &num_defaults,
			  default_units = me->old_param_buf.unit);

     me->param_buf = me->old_param_buf;
     
     *sts = SUCC;
     break;
     
   case MODIFY :
     
     /* Assign the param buffer */ 
     me->param_buf.axis = me->first_frame.main_info.axis ;
     me->param_buf.orient_toggle = me->first_frame.main_info.orient == 'P' ? 1 : 0;
     me->param_buf.name_toggle =
       me->first_frame.main_info.name_type == NAME_BY_DIST ? 1 : 0;
     me->param_buf.justification[0] =  me->first_frame.main_info.justif[0];
     me->param_buf.justification[1] =  me->first_frame.main_info.justif[1];
     
     strcpy(me->param_buf.annotation_field,me->first_frame.main_info.annot);
     strcpy(me->param_buf.unit,me->first_frame.main_info.unit);

     if( me->first_frame.main_info.rev_dist == NO_REV_DIST )
      {
	me->param_buf.reverse_toggle = FALSE;
	me->param_buf.reverse_field = NO_REV_DIST;
      }    
     else
      {
	me->param_buf.reverse_toggle = TRUE;
	me->param_buf.reverse_field = me->first_frame.main_info.rev_dist;
      }
     
     /* Fill the two buffer for the plane size */ 
     put_plane_size(me->first_frame.main_info.plane_size,
		    me->param_buf.regular_list,
		    &me->param_buf.regular_field);
     
     put_plane_size(me->first_frame.main_info.reinf_size,
		    me->param_buf.reinforced_list,
		    &me->param_buf.reinforced_field);
     
     /* Fill the offset distance */                      
     me->param_buf.offset_field = me->first_frame.main_info.offset_dist;
     
     /* Retrieve coordinate system */ 
     me->param_buf.cs =  me->list[0];
     
     /* Retrieve the name of the coordinate system or the plane system */
     retrieve_coord_syst_name(&me->param_buf.cs,me->param_buf.name_cs);
     
     FIg_set_text(me->forms[MAIN].form_ptr,CS_FIELD,me->param_buf.name_cs);
     
     /* Search if it is a plane or a coord_syst */    
     status = om$send(msg = message ASnode.ASreturn_go
		      (&go_cs,&mat_type,matrix),
		      targetid = me->param_buf.cs.objid,
		      targetos = me->param_buf.cs.osnum);
     
     as$status(action = RET_STATUS);
     
     if(SMIsKindOf(&go_cs,OPP_EMSplane_class_id))
      { 
        /* It is a plane  */
	me->param_buf.class_cs = CLASS_PLANE; 
	fr_set_axis(me->forms[MAIN].form_ptr,&me->param_buf,'z','x','y',me->mytype);
      }
     else  me->param_buf.class_cs = CLASS_CS;
     
     
     /* Now assign the save buffer */
     me->old_param_buf = me->param_buf;
     
     *sts = SUCC;    
     break;
   }   
  
  return OM_S_SUCCESS;
}

/* Find the locate coordinate system and  retrieve his name */
method coord_syst( long *sts )
{
  int  status = OM_S_SUCCESS;
  long msg;
    
  me->param_buf.cs.objid = me->event1.located_object[0].located_obj.objid;
  me->param_buf.cs.osnum = me->event1.located_object[0].located_obj.osnum;
  
  status = as$make_source(go_grid = me->param_buf.cs,
			  mod_env = &me->event1.located_object[0].module_info,
			  as_os   = me->ModuleInfo.md_id.osnum,
			  as_grid = &me->param_buf.cs);
  as$status(action = RET_STATUS);
  
  
  /* Retrieve the name of the coordinate system */
  retrieve_coord_syst_name(&me->param_buf.cs,me->param_buf.name_cs);  
  
  FIg_set_text(me->forms[MAIN].form_ptr,CS_FIELD,me->param_buf.name_cs);
  
  /* Find the class of coordinate system (EMSplane or GRgencs) */      
  if(SMIsKindOf(&me->event1.located_object[0].located_obj,OPP_EMSplane_class_id))
    {
      me->param_buf.class_cs = CLASS_PLANE; 
      fr_set_axis(me->forms[MAIN].form_ptr,&me->param_buf,'z','x','y',me->mytype); 
      change_state_orient(me->forms[MAIN].form_ptr,FALSE);
    }
  else
   {
     me->param_buf.class_cs = CLASS_CS;
     change_state_orient(me->forms[MAIN].form_ptr,TRUE);
   }
  
  /* Return to the normal state */
  om$send(msg = message SMCmdPlMdFr.make_selectable(&msg),
	  targetid = my_id); 
  
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* When quit the coordinate system research , restablish a "normal" state */  
method make_selectable( long *sts )
{
  dp$erase_hilite(msg = sts);
  FIg_set_state_off(me->forms[MAIN].form_ptr,CS_BUTTON);
  FIg_set_state_off(me->forms[MAIN].form_ptr,LOADC_BUTTON);
  main_change_state_gadget(me->forms[MAIN].form_ptr,TRUE,
			   me->mytype,me->param_buf.class_cs);
  
  *sts = SUCC;
  return OM_S_SUCCESS;
}

/*        Save the main parameters and the sections                */
/*        Call the place or modify function                        */
 
method save_all(long *sts )
{
  char             my_msg[MY_MSG_LEN];
  int              low,high,nb_frame;
  struct frame_def save_frame;  /* Pass to VDPlace */
 
  if(!test_main_parameter(me->forms[MAIN].form_ptr,&me->owner,
			  &me->param_buf,me->mytype))
   {
     *sts = ERRO;
     goto quit;
   }
  
  if(me->new_nb_sect <= 0)
   {
     ex$message( msgnumb = SM_I_FrNoSectDef, buff = my_msg); 
     FIg_set_text(me->forms[MAIN].form_ptr,FI_MSG_FIELD,my_msg);
     *sts = ERRO;
     goto quit;
   }
  
  if(me->mytype == MODIFY)
   {
     search_low_high(&low,&high,&nb_frame,me->new_nb_sect,
		     me->new_sect_info);
     if(me->first_nb_frame != nb_frame)
      {
	ex$message( msgnumb = SM_I_FrModNb, buff = my_msg);
	FIg_set_text(me->forms[MAIN].form_ptr,FI_MSG_FIELD,my_msg);
	*sts = ERRO;
	goto quit;
      }
   }
    
  save_frame.sect_info =  me->new_sect_info;
  save_frame.nb_sect = me->new_nb_sect;
    
	// printf ("me->new_nb_nm_sect=%d\n", me->new_nb_nm_sect);
  save_frame.nm_sect_info =  me->new_nm_sect_info;
  save_frame.nb_nm_sect = me->new_nb_nm_sect;
  save_frame.main_info.name_type = me->param_buf.name_toggle;
	

  /* Copy global paramater */
  save_frame.main_info.axis = me->param_buf.axis;
  
  save_frame.main_info.orient = me->param_buf.orient_toggle ? 'P' : 'N';
  save_frame.main_info.justif[0] = me->param_buf.justification[0];
  save_frame.main_info.justif[1] = me->param_buf.justification[1];
  strcpy(save_frame.main_info.annot,me->param_buf.annotation_field);
  
  if(me->param_buf.reverse_toggle)
    save_frame.main_info.rev_dist = me->param_buf.reverse_field;
  else
    save_frame.main_info.rev_dist = NO_REV_DIST;
  
  get_plane_size(me->param_buf.regular_list,
		 me->param_buf.regular_field,
		 &save_frame.main_info.plane_size);
  
  get_plane_size(me->param_buf.reinforced_list,
		 me->param_buf.reinforced_field,
		 &save_frame.main_info.reinf_size);
  
  save_frame.main_info.offset_dist = me->param_buf.offset_field;
  
  /* Save the string for reverse and reinforced */ 
  strcpy(save_frame.main_info.reinfstr,me->old_frame_str.reinf);
  strcpy(save_frame.main_info.revstr,me->old_frame_str.rev);


  strcpy(save_frame.main_info.unit,me->param_buf.unit);
  save_frame.main_info.name_type
    = me->param_buf.name_toggle ? NAME_BY_DIST : NAME_BY_NUMBER; 

  switch(me->mytype)
   {
     int bad_frame; /* bad frame number if fail somewhere .. */
   
   case PLACE:
     if(SMPlaceFrame(me->param_buf.name_fr,&me->param_buf.cs,
		     &save_frame, &bad_frame) != 1)
      {
        ex$message( msgnumb = SM_E_FrBadDefFr, buff = my_msg,
		   type = "%d",var = `bad_frame`);
	
        FIg_set_text(me->forms[MAIN].form_ptr,FI_MSG_FIELD,my_msg);
	*sts = MY_ERROR; 
	goto quit;
      }
#if 0 /* Change 24 June 93 : Now blank form in form notification instead of leaving old parameter */
     else
      {
        /* Now save the parameter as old parameter */
        me->old_param_buf    = me->param_buf;
        me->first_nb_sect = me->new_nb_sect;
        for(i = 0 ; i < NB_MAX_SECTION ; i++)
	  me->first_sect_info[i] = me->new_sect_info[i];
	strcpy(me->first_frame.main_info.reinfstr,
	       save_frame.main_info.reinfstr);
	strcpy(me->first_frame.main_info.revstr,
	       save_frame.main_info.revstr);
      }    
#endif

     break;
     
   case MODIFY:
     
	/* 
	{
		int i;
                for (i=0; i<me->first_frame.nb_nm_sect; i++){
                        printf ("%d-%d, %s, %d\n",
                                me->first_frame.nm_sect_info[i].fr,
                                me->first_frame.nm_sect_info[i].to,
                                me->first_frame.nm_sect_info[i].name,
                                me->first_frame.nm_sect_info[i].dorn);
                }
	}
        */
     if(SMModFrame(me->param_buf.name_fr,&me->owner,
		   &me->list[0],&me->param_buf.cs,
		   &me->list[2],&me->list[3],
		   &me->first_frame,&save_frame,&bad_frame) != 1)
      {
        ex$message( msgnumb = SM_E_FrBadDefFr, buff = my_msg,
		   type = "%d", var = `bad_frame`);
        FIg_set_text(me->forms[MAIN].form_ptr,FI_MSG_FIELD,my_msg);
        *sts = MY_ERROR;
        goto quit;
      }
#if 0 /* Change 24 June 93 : Now relocate instead of leaving old parameter */
     else 
      {
   	/* Save the parameter as old parameter */
   	me->old_param_buf = me->param_buf;
        me->first_nb_sect = me->new_nb_sect;
        for(i = 0 ; i < NB_MAX_SECTION ; i++)
	  me->first_sect_info[i] = me->new_sect_info[i];
	
   	/* the old section become the same as new */   	  
   	me->first_frame = save_frame;
   	
   	/* Be careful with pointer ! */
   	me->first_frame.sect_info = me->first_sect_info; 

	strcpy(me->first_frame.main_info.reinfstr,
	       save_frame.main_info.reinfstr);
	strcpy(me->first_frame.main_info.revstr,
	       save_frame.main_info.revstr);
	
      }
#endif     
     break; 
   }
  *sts = SUCC;
  
 quit:
  return OM_S_SUCCESS;
  
}

end implementation SMCmdPlMdFr;
