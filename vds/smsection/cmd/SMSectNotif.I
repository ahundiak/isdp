/* $Id: SMSectNotif.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/cmd / SMSectNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSectNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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
# Revision 1.2  1996/05/27  05:32:58  pinnacle
# Replaced: smsection/cmd/SMSectNotif.I for:  by apazhani for vds.240
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

/* 
    File             SMSectNotif.I;
    Creation Date    October 92
    Auteur           Jean Jasinczuk (ISDC)
    
    Methods  and functions for SMCmdSect.S ;

    History
*/

class implementation SMCmdSect;

#define DEBUG          1
#define AS_DEBUG       1
/* #define JJ_DEBUG       1   */

#include "madef.h"  
#include "AS_status.h"

#define INCR 50
#define SAVE_TO_WORK 1
#define WORK_TO_SAVE 2

from SMsection import SMSectGetCal,SMSectSetCal,ACmplace;            
from NDnode import NDdisplay;            
from SMcomp import SMGetCalSect;            
from SMframe import GRgetname,SMfind_frame_num;            
from NDmacro import ACreturn_foot;  

extern GRclassid OPP_SMsection_class_id;
extern GRclassid OPP_GRlinear_class_id;

%safe
static void erase_frame_list();
static void FIset_axis();
static int FIget_axis();
static int find_compart();
static void place_frame_in_form();
%endsafe

#ifdef JJ_DEBUG
%safe
static void debug_param();
%endsafe
#endif

/* --------------- void FIset_axis --------------- */
 
static void FIset_axis(form,ax1)
Form form;         /* [I] a pointer to the  form  */
char ax1;          /* [I] ax1 is axis to set      */
{
 switch(ax1) 
   {
   case 'x' :
     FIg_set_state_off(form,G_Y_AXIS); 
     FIg_set_state_off(form,G_Z_AXIS);
     FIg_set_state_on(form,G_X_AXIS);
     break;
   case 'y' :
     FIg_set_state_off(form,G_X_AXIS); 
     FIg_set_state_off(form,G_Z_AXIS);
     FIg_set_state_on(form,G_Y_AXIS);
     break;
   case 'z' :
     FIg_set_state_off(form,G_X_AXIS); 
     FIg_set_state_off(form,G_Y_AXIS);
     FIg_set_state_on(form,G_Z_AXIS);
     break;
   } 
}

/* --------------- int FIget_axis --------------- */

static int FIget_axis(form,axis)
Form form;       /* [I] a pointer to the  form  */
char *axis;	 /* [O] ax1 is axis to get      */
{
  int state;

  FIg_get_state(form,G_X_AXIS,&state);
  if(state) {*axis = 'x'; return 1;}
  FIg_get_state(form,G_Y_AXIS,&state);
  if(state) {*axis = 'y' ; return 1;}
  FIg_get_state(form,G_Z_AXIS,&state);
  if(state) {*axis = 'z' ; return 1;}

  return 0;
}

/* ------------------ static void ret_from_pretend ------------------ */
/* From a pretend, retreive object and module env                     */

static void ret_from_pretend(pretend,object,mod_env)
struct GRid     *pretend;        /* [I] */
struct GRid     *object;         /* [O] */
struct GRmd_env *mod_env;        /* [O] */  
{
  IGRlong status,msg;

  status = om$send(msg = message NDmacro.ACreturn_foot
		   (&msg,"",object,
		    &mod_env->md_env.matrix_type,
		    mod_env->md_env.matrix),
		   senderid = NULL_OBJID,
		   targetid = pretend->objid,
		   targetos = pretend->osnum);
  if(!(status & msg & 1))
   {
     mod_env->md_env.matrix_type =  MAIDMX;
     MAidmx(&msg,mod_env->md_env.matrix);
   }
  
  mod_env->md_id.osnum   = object->osnum;
  ex$get_modid(mod_osnum = mod_env->md_id.osnum,
	       mod_id    = &mod_env->md_id.objid);

}


/* --------------- static int find_compart ----------------------------- */
/* Find the index in the comp list of the given section given name or id */
/* Return 0 if not found */

static int find_compart(comp_list,nb_comp,id,sect_ind)
struct GRid  comp_list[];   /* [I] the list of compart */
int          nb_comp;       /* [I] Number of compart */
struct GRid  *id;           /* [I] Id of the section (or NULL) */
int          *sect_ind;     /* [O] The index of the section in the table */
{
  int i;

  if(nb_comp == 0) return 0;

  if(id != NULL)
    for(i=0; i<nb_comp; i++)
      if(id->objid == comp_list[i].objid &&
	 id->osnum == comp_list[i].osnum)
       {
	 if(sect_ind) *sect_ind = i;
	 return 1;
       }

  return 0; /* Section not found if here */
}

/* ------------------ static int erase_frame_list ------------------ */
/* Reinit the gadget for frame locate, the number of frame and the   */
/* grid's of located frames. Erase display                           */
  
static void erase_frame_list(form,frame,nb_frame)
Form        form;            /* [I] Pointer to the form */
struct GRid frame[];         /* [O] Frame array to reinit */
int         *nb_frame;       /* [O] nb_frame reinit to 0 */
{
  int i,row,col;

  for(i = 0; i < 2*SM_MAX_PARTS; i++)
    frame[i].objid = NULL_OBJID;
  *nb_frame = 0;
  for(row = 0; row < SM_MAX_PARTS; row++)
    for(col = 0; col <= 4; col++)
      FIfld_set_text(form,G_SECT_LIST,row,col,"",FALSE);
}

/* --------------- static void place_frame_in_form --------------- */
/* Place attribute of a section from buffer to G_SECT_LIST in form       */

static void place_frame_in_form(form,frame,Info,row,type)
Form              form;     /* [I] Pointer to the form */
struct GRid       *frame;   /* [I] Frame to place in the form */
struct SMSectInfo *Info;    /* [I] If NULL means it's new frame */
int               row;      /* [I] Row number in the gadget */
int               type;     /* [I] G_FROM_FRAME or G_TO_FRAME */
{
  IGRchar name[256];
  double  val_db;

  SMGetSplitName(frame,name);
  if(strncmp(name,"defined",7) == 0)
   {printf("Error get frame name objid = %d\n",frame->objid);}
  switch(type)
   {
   case G_FROM_FRAME:
     FIfld_set_text(form,G_SECT_LIST,row,0,name,FALSE);
     if(Info)
       SMConvDistIntExt(Info->att.usr[row].FrDx,&val_db,frame->osnum);
     else
       val_db = 0.0;
     FIfld_set_value(form,G_SECT_LIST,row,1,val_db ,FALSE);
   
     break;
 
   case G_TO_FRAME:
     FIfld_set_text(form,G_SECT_LIST,row,2,name,FALSE);
     if(Info)
       SMConvDistIntExt(Info->att.usr[row].ToDx,&val_db,frame->osnum);
     else
       val_db = 0.0;
     FIfld_set_value(form,G_SECT_LIST,row,3, val_db, FALSE);
     FIfld_set_value(form,G_SECT_LIST,row,4,
		     Info ? Info->att.usr[row].NbSect : 3.0, FALSE);
     break;
   } 
}

/* ------------------- method form_notification -------------------- */

method form_notification (int form_label; int gadget_label ; double value ;
			  char * form_ptr)
{
  int status = OM_S_SUCCESS;
  long sts;
  
  if ( form_ptr == NULL ) return( OM_E_INVARG ); 
  
  FIg_set_text(form_ptr,FI_MSG_FIELD, "");
  
  switch( gadget_label )
   {
   case FI_ACCEPT :
     om$send(msg = message SMCmdSect.save_all(&sts),
	     targetid = my_id);
     
     FIg_set_state_off(form_ptr,FI_ACCEPT);
     if(sts == OM_S_SUCCESS)
       _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_EXECUTE :
     om$send(msg = message SMCmdSect.save_all(&sts),
	     targetid = my_id);
     
     FIg_set_state_off(form_ptr,FI_EXECUTE);
     if(sts == OM_S_SUCCESS)
       _put_response(resp = RELOCATE_OBJ);
     goto quit;
     
   case FI_CANCEL :
     _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_RESET :
     om$send(msg = message SMCmdSect.reset_all(&sts),
	     targetid = my_id);
     goto quit;
     
   case G_MODE_LIST:
     om$send(msg = message SMCmdSect.mode_list(&sts),
	     targetid = my_id);
     break;
     
   case G_COMP:
     _put_response( resp = LOCATE_COMP ); 
     break;
     
   case G_LOCATE_FR:
     erase_frame_list(me->forms[0].form_ptr,me->work_frame,&me->work_nb_frame);
     _put_response( resp = LOCATE_FR);
     break;
   }
  
 quit: return OM_S_SUCCESS;
}

/* -------------- method init_form_new_sect ------------------  */
/*     This method initialize the form for a new Section        */

method init_form_new_sect( long * sts )
{
  /* No Section */
  me->save_info.mode   = SM_SECT_SGL;
  me->save_info.NbPart = 1;
  me->save_info.axis   = 'x';
  me->save_info.EndOffset = 0.1;
  me->save_info.att.sgl.NbSect = 3;

  me->work_info = me->save_info;

  me->save_nb_comp = me->work_nb_comp = 0;
  me->save_nb_frame = me->work_nb_frame = 0;
  FIg_set_text(me->forms[0].form_ptr,G_COMP_NAME,"");

  om$send(msg = message SMCmdSect.toggle_mode( sts ,SM_SECT_SGL),
	  targetid = my_id);
  FIg_set_text(me->forms[0].form_ptr,G_MODE_LIST,"Single Part");

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* ------------------- method control_sect ------------------------ */
/*         Method call after locate of a section                    */
/* It put all attributes in the form and retrieve all the templates */

method control_sect( long * sts )
{
  IGRlong     msg,status;
  struct GRid cs;
  int         i;
 
  /* Get the parameters for calculation section */
  status = om$send(msg = message SMsection.SMSectGetCal
		   (&msg, &cs, &me->save_comp[0],
		    &me->save_nb_frame,me->save_frame,&me->save_info),
		   targetid = me->sect_id.objid,
		   targetos = me->sect_id.osnum);
  as$status(sts = (status & msg),action = GOTO_VALUE,value = wrapup);

  ret_from_pretend(&me->save_comp[0],&me->save_comp[0],
		   &me->save_comp_env[0]);

  /* Frame can be a pretend , retreive real frame */
  for(i = 0; i < me->save_nb_frame; i++)
    ret_from_pretend(&me->save_frame[i],&me->save_frame[i],
		     &me->save_frame_env[i]);
	
  /* A compartment is defined for the section ! */
  me->save_nb_comp = 1;

  erase_frame_list(me->forms[0].form_ptr,me->work_frame,&me->work_nb_frame);

  om$send(msg = message SMCmdSect.put_sect_param( sts ), targetid = my_id);
  as$status(sts = *sts,action = GOTO_VALUE,value = wrapup);
  
  om$send(msg = message SMCmdSect.copy_param( sts , SAVE_TO_WORK),
	  targetid = my_id);
 
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;

 wrapup:
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;

} 

/* -------------------- method SMplace_sect ------------------------- */
/*           Construct and place the section macro                    */

method place_sect( long * sts ) 
{
  IGRint          status;
  IGRint	  rc;
  struct GRid     mac;
  int             i;
  struct GRid     TEMP[3 + 2 * SM_MAX_PARTS]; /* Template of the sect area */
  int             nb_temps;
  IGRlong         msgcode;
  int             cn_type;
  char            my_msg[80];
  
  msgcode   = 0;
  mac.objid = NULL_OBJID;
  nb_temps  = 3;

  /* Get the active CS */
  status = SMGetDefCs(TRUE,                   /* Don't take EMS cs */
		      (struct GRid *)NULL,     /* Connected with Db not needed */
		      (IGRshort *)NULL,        /* State not used */ 
		      (struct GRid *)NULL,     /* Graphic object not important */
		      &TEMP[1],                /* Associative cs is template 1 */
		      (struct GRmd_env *)NULL, /* No mod env */
		      (IGRboolean *)NULL);     /* No flag needed */
 
  if(!status || TEMP[1].objid == NULL_OBJID)
   { msgcode = SM_E_ScNoActCs; goto wrapup;}

  switch(me->save_info.mode)
   {
   case SM_SECT_SGL:
     nb_temps = 3;
     break;

   case SM_SECT_USER:
     nb_temps =  3 + me->save_nb_frame;
     for(i = 0; i < me->save_nb_frame; i++)
       as$make_source(go_grid = me->save_frame[i],
		      mod_env = &me->save_frame_env[i],
		      as_grid = &TEMP[3+i]);
     break;

   case SM_SECT_AUTO:
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
		  "Not yet implemented Auto Mode\n");
     goto wrapup;
   }

  /* Place calculation section for each compartment */
  for(i = 0; i < me->save_nb_comp; i++)
   {
     as$make_source(go_grid = me->save_comp[i],
		    mod_env = &me->save_comp_env[i],
		    as_grid = &TEMP[2]);
    
#ifdef JJ_DEBUG
     debug_param(&me->save_info,me->save_comp,me->save_nb_comp,
		 &TEMP[3],me->save_nb_frame);
#endif
   
     /* If there are some duplicated objects, create intermediate pretend */
     NDduplicate_root(nb_temps, TEMP);
    
     /* Construct the section */
     mac.osnum = me->ModuleInfo.md_id.osnum;
     status = om$construct(classid = OPP_SMsection_class_id,
			   osnum   = mac.osnum,
			   p_objid = &mac.objid );
     as$status(action = GOTO_VALUE, value = wrapup);
       
     status = om$send( msg = message SMsection.ACmplace
		      (&rc, AChdr_nodisplay | AChdr_nocompute,
		       0,"SMsection",0, NULL, &me->ModuleInfo),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     as$status(sts = (status & rc),action = GOTO_VALUE,value = wrapup);
     
     status = om$send( msg = message SMsection.SMSectSetCal
		      (sts, &TEMP[1],&TEMP[2], 
		       me->save_nb_frame, &TEMP[3],&me->save_info),
		      targetid = mac.objid,
		      targetos = mac.osnum);
     as$status(sts = (status & *sts),action = GOTO_VALUE, value = wrapup);
   
     cn_type    = ND_COMP; /* recompute the object */
     nd$wait_batch(type  = GR_GEOM_POSTED,
		   l_object   = &mac,
		   l_obj_info = &cn_type,
		   nb_obj     = 1);
   }

  *sts = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:
  
  if(mac.objid != NULL_OBJID)
   {
     om$send(msg = message Root.delete(0),
	     targetid = mac.objid,targetos = mac.osnum);
   }  

  if(msgcode != 0)
   {
     ex$message( msgnumb = msgcode,buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
   }

  *sts = MSFAIL;
  return OM_S_SUCCESS;
}

/* -------------------- method SMmodif_sect ------------------------------  */
/* It modify the sect area macro with the new parameter saved in the form   */

method modif_sect( long * sts )
{
  IGRlong           loc_msg;
  int               status;
  int               i,put_batch,wait_batch,cn_type, cs_ch, fr_ch;
  struct GRid       new_cs, go_cs, cs,compart;
  struct SMSectInfo Info;
  struct GRid       frame[2 * SM_MAX_PARTS];
  IGRlong           msgcode;
  int               nb_frame;
  char              my_msg[80];

  put_batch = FALSE;
  msgcode   = 0;

  /* Get the active CS */
  cs_ch = fr_ch = 0;

  status = SMGetDefCs(TRUE,                   /* Don't take EMS cs */
		      (struct GRid *)NULL,     /* Connected with Db not needed */
		      (IGRshort *)NULL,        /* State not used */ 
		      &go_cs,     
		      &new_cs,                /* Associative cs is template 1 */
		      (struct GRmd_env *)NULL, /* No mod env */
		      (IGRboolean *)NULL);     /* No flag needed */
 
  if(!status || new_cs.objid == NULL_OBJID)
   { msgcode = SM_E_ScNoActCs; goto wrapup;}

  /* Retrieve cs of the calculation section */

  status = om$send(msg = message SMsection.SMSectGetCal
		   (&loc_msg, &cs, NULL, &nb_frame,frame,&Info),
		   targetid = me->sect_id.objid,
		   targetos = me->sect_id.osnum);
  if(!(status & loc_msg & 1))
   {printf("Can't retrieve parameters of section\n"); goto wrapup;}
  



  /* Frame can be a pretend , retreive real frame */
  for(i = 0; i < nb_frame; i++)
   {
     om$send(msg = message NDmacro.ACreturn_foot
	     (&loc_msg,"",&frame[i],NULL,NULL),
	     targetid = frame[i].objid,
	     targetos = frame[i].osnum);
   }

  /* Search if some parameters have been modified */
  
  if(Info.mode != me->save_info.mode) put_batch = TRUE;
  else
   if(new_cs.objid != cs.objid || new_cs.osnum != cs.osnum) {
			put_batch = TRUE;
			cs_ch = 1;
   }
   else
    if(Info.NbPart != me->save_info.NbPart) put_batch = TRUE;
    else
      if(Info.axis != me->save_info.axis) put_batch = TRUE;
      else
	if(Info.EndOffset != me->save_info.EndOffset) put_batch = TRUE;
	else
	  switch(me->save_info.mode)
	   {
	   case SM_SECT_SGL:
	     if(Info.att.sgl.NbSect != me->save_info.att.sgl.NbSect)
	       put_batch = TRUE;
	     break;
	     
	   case SM_SECT_USER:


	     for(i=0;i<me->save_info.NbPart;i++)
	       if(Info.att.usr[i].FrDx != me->save_info.att.usr[i].FrDx ||
		  Info.att.usr[i].ToDx != me->save_info.att.usr[i].ToDx ||
		  Info.att.usr[i].NbSect != me->save_info.att.usr[i].NbSect)
		{ put_batch = TRUE; break; }
	     
	     if(put_batch == FALSE) /* compare list of frame */
	       for(i=0;i<me->save_nb_frame;i++)
		 if(me->save_frame[i].objid != frame[i].objid ||
		    me->save_frame[i].osnum != frame[i].osnum)
		  { fr_ch = 1; put_batch = TRUE; break; }
	     
	     break;
	     
	   case SM_SECT_AUTO:
	     break;
	   }

  if(cs_ch && !fr_ch){
	/* must verify that the frames are on x axis of the cs */
	
	for(i=0;i<me->save_nb_frame;i++){
  	    if(!verif_frame(&go_cs, &me->ModuleInfo, &me->save_frame[i] )){
   			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
		  		"Invalid Frame");
			goto wrapup; 
		}

	}

  }
  
  if(put_batch)
   {

     /* Make source for compartment */
     as$make_source(go_grid = me->save_comp[0],
		    mod_env = &me->save_comp_env[0],
		    as_grid = &compart);

     nb_frame = me->save_nb_frame;
     for(i = 0; i < me->save_nb_frame; i++)
       as$make_source(go_grid = me->save_frame[i],
		      mod_env = &me->save_frame_env[i],
		      as_grid = &frame[i]);

     /* If there are some duplicated objects, create intermediate pretend */
     NDduplicate_root(nb_frame,frame);

#ifdef JJ_DEBUG
  debug_param(&me->save_info,me->save_comp,me->save_nb_comp,frame,nb_frame);
#endif 

     /* Put all parameters of the calculation section */
     status = om$send(msg = message SMsection.SMSectSetCal
		      (&loc_msg, &new_cs, &compart,
		       nb_frame,frame,&me->save_info),
		      targetid = me->sect_id.objid,
		      targetos = me->sect_id.osnum);
     as$status(sts = (status & loc_msg),action = GOTO_VALUE,value = wrapup);
     
     cn_type    = ND_COMP; /* recompute the object */
     nd$wait_batch(type       = GR_GEOM_POSTED,
		   l_object   = &me->sect_id,
		   l_obj_info = &cn_type,
		   nb_obj     = 1);
     
     nd$mod_batch(request = ND_INQ,p_ret_mode = &wait_batch);
     
     if(wait_batch != ND_DEFER) /* Else Nothing to do */
       nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
   }
  
  
  *sts = MSSUCC;
  return OM_S_SUCCESS;
  
 wrapup:
  if(msgcode != 0)
   {
     ex$message( msgnumb = msgcode,buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
   }

  *sts = MSFAIL;
  return OM_S_SUCCESS;
}


/* ------------------- method save_all --------------------------------------- */
/*               Method called when user selected save                         */
/* It found all parameter in the form and call the appropriate place or modify */

method save_all( long * sts )
{
  IGRlong   msg,status;
  IGRlong   msgcode;   
  IGRchar   my_msg[80],tmp[80];
  IGRdouble val_db;
  int       row,sel_flag,r_pos;

  msgcode = 0;

  if(me->work_nb_comp <= 0)
   { msgcode = SM_E_ScNoLocComp; goto wrapup; }

  FIg_get_text(me->forms[0].form_ptr,G_MODE_LIST,tmp);
  if(strncmp(tmp,"Single",6) == 0)
   {
     me->work_info.mode = SM_SECT_SGL;
     FIg_get_value(me->forms[0].form_ptr,G_NB_SECT,&val_db);
     me->work_info.att.sgl.NbSect = (int)val_db;
     me->work_info.NbPart = 1;
     me->work_nb_frame = 0;
     if(me->work_info.att.sgl.NbSect % 2 == 0 ||
	me->work_info.att.sgl.NbSect < 3)
       { msgcode = SM_E_ScNoOdd ; goto wrapup;}
   }
  else
    if(strncmp(tmp,"Multi",5) == 0)
     {
       me->work_info.mode = SM_SECT_USER;
       if(me->work_nb_frame == 0 || me->work_nb_frame % 2 != 0)
	{ msgcode = SM_E_ScNoFrame; goto wrapup;}

       if(me->work_nb_frame % 2 != 0)
	{ msgcode = SM_E_ScBadNbFr; goto wrapup;}
       
       me->work_info.NbPart = me->work_nb_frame / 2; 

       for(row = 0; row < me->work_info.NbPart ; row++)
	{
	  FIfld_get_value(me->forms[0].form_ptr,G_SECT_LIST,row,1,
			  &val_db,&sel_flag,&r_pos);
	  SMConvDistExtInt(val_db,&me->work_info.att.usr[row].FrDx,
			   me->work_frame[0].osnum);
	  
	  FIfld_get_value(me->forms[0].form_ptr,G_SECT_LIST,row,3,
			  &val_db,&sel_flag,&r_pos);
	  SMConvDistExtInt(val_db,&me->work_info.att.usr[row].ToDx,
			   me->work_frame[0].osnum);
	  
	  if(row > 0){

		/* verif that FrDx is > ToDx of the previous row to
		   avoid overlapping of the sections */

		if(me->work_info.att.usr[row-1].ToDx > me->work_info.att.usr[row].FrDx){
			sprintf(my_msg,"%s%d","Bad Fr Dx row #",row);
	     		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	     		goto wrapup;
		}	  
	  }
	  FIfld_get_value(me->forms[0].form_ptr,G_SECT_LIST,row,4,
			  &val_db,&sel_flag,&r_pos);
	  me->work_info.att.usr[row].NbSect = (int)val_db;

	  /* we allow to have parts with no section (in the middle)
	     to avoid to have bad intersection if the solid is a union of a 
	     2 disjoint solids 
          */

	  if(me->work_info.att.usr[row].NbSect != 0 || row == 0 || row == me->work_info.NbPart-1)
	  if(me->work_info.att.usr[row].NbSect % 2 == 0 ||
	     me->work_info.att.usr[row].NbSect <= 0)
	   { ex$message( msgnumb = SM_E_ScBadNbSect, buff = my_msg,
			type = "%d" , var = `row`);
	     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	     goto wrapup; 
	   }
       }
     }
    else
     {
       FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
		    "Not yet implemented Auto Mode\n");
       goto wrapup;
     }

  FIget_axis(me->forms[0].form_ptr,&me->work_info.axis);
  FIg_get_value(me->forms[0].form_ptr,G_END_OFFSET,&me->work_info.EndOffset);
  SMConvDistExtInt(me->work_info.EndOffset,&me->work_info.EndOffset,
		   me->ModuleInfo.md_id.osnum);
  
  /* copy the save  of the section */
  om$send(msg = message SMCmdSect.copy_param( sts, WORK_TO_SAVE ),
	  targetid = my_id);

  switch(me->mytype)
   {
   case PLACE: 
     status = om$send( msg = message SMCmdSect.place_sect(&msg),
		      targetid = my_id);
     if (!(status & msg & 1))
      { ex$message(msgnumb = SM_E_ScBadPl); goto wrapup; }
     break;

   case MODIFY: 
     status = om$send( msg = message SMCmdSect.modif_sect(&msg),
		      targetid = my_id);
     if (!(status & msg & 1))
      { ex$message( msgnumb = SM_E_ScBadMd); goto wrapup; }
     break;
   }

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
  
 wrapup:
  if(msgcode != 0)
   {
     ex$message( msgnumb = msgcode, buff = my_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
   }
  
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;
}

/* -------------------- method reset_all ----------------------------------- */
/* This method copy the save list of sections to the work list of section    */
/* It also place all section in the list and clear the attribute list gadget */

method reset_all( long * sts )
{
  /* KLUDGE : TEMPORARY NO AXIS */
  SMVA_disable(me->forms[0].form_ptr,3,G_X_AXIS,G_Y_AXIS,G_Z_AXIS);

  if(me->mytype == MODIFY)
    FIg_disable(me->forms[0].form_ptr,G_COMP);

  erase_frame_list(me->forms[0].form_ptr,me->work_frame,&me->work_nb_frame);
  om$send(msg = message SMCmdSect.copy_param( sts , SAVE_TO_WORK),
	  targetid = my_id);

  om$send(msg = message SMCmdSect.put_sect_param( sts ), targetid = my_id);
  if(!(*sts & 1)) {*sts = OM_E_ABORT; return OM_S_SUCCESS;} 

  om$send(msg = message SMCmdSect.erase_hilite( sts ), targetid = my_id);
  om$send(msg = message SMCmdSect.hilite_half( sts ), targetid = my_id);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}  

/* -------------------- method mode_list ---------------------------- */
/*             Method call when list mode selected                    */

method mode_list( long * sts )
{
  char tmp[80];

  FIg_get_text(me->forms[0].form_ptr,G_MODE_LIST,tmp);

  if(strncmp(tmp,"Single",6) == 0)
   {
     om$send(msg = message SMCmdSect.toggle_mode( sts ,SM_SECT_SGL),
	     targetid = my_id);
     me->work_info.mode = SM_SECT_SGL;
   }
  else
    if(strncmp(tmp,"Multi",5) == 0)
     {
       om$send(msg = message SMCmdSect.toggle_mode( sts ,SM_SECT_USER),
	       targetid = my_id); 
       me->work_info.mode = SM_SECT_USER;
     }
    else
     {
       FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
		    "Not yet implemented Auto Mode\n");
       *sts = OM_E_ABORT;  return OM_S_SUCCESS;
     } 
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}
     
/* -------------------- method add_locate_compart -------------------- */
/*                   Add compart(s) located by the users               */
/* The last selected sections becomes the current section              */

method add_locate_comp( long * sts )
{
  IGRlong           msg;
  int               status;
  int               nb_obj,nb_add,i;
  struct GRobj_env *LocatedObjects;
  struct GRid       CalSect;
  IGRchar           name[256];

  nb_add = 0;
  nb_obj = 0;
  
  LocatedObjects = NULL;
  as$start_fence(set= &me->event1.located_object[0].located_obj,
                 set_env = &me->event1.located_object[0].module_info,
                 nb_obj = &nb_obj,
                 p_obj_env = &LocatedObjects, 
                 response = me->response, 
                 response_data = me->response_data);
  if(nb_obj == 0)
   {*sts = NO_OBJ_LOCATED; goto quit;}
  
  /* Control the new compart */
  for(i = 0; i < nb_obj ; i++)
   {
      /* Be wise with locate by name */
     if(!SMIsKindOf(&LocatedObjects[i].obj_id,OPP_SMcomp_class_id)) 
       continue;

     CalSect.objid = NULL_OBJID;
     /* Verify if section not already defined for this compartment */
     status = om$send(msg = message SMcomp.SMGetCalSect
		      (&msg,&CalSect,NULL),
		      targetid = LocatedObjects[i].obj_id.objid,
		      targetos = LocatedObjects[i].obj_id.osnum);
     if(CalSect.objid != NULL_OBJID)
      {ex$message(msgnumb = SM_I_ScAlrDef);goto next_loop;}

     /* If compartment already in the list for section , ignore it */
     if(find_compart(&me->work_comp[0],me->work_nb_comp,
		     &LocatedObjects[i].obj_id,(int *)NULL))
       goto next_loop;
     
     if(me->work_nb_comp + nb_add + 1 > om$dimension_of( varray = me->work_comp))
      {
	om$vla_set_dimension(varray = me->work_comp,
			     size = me->work_nb_comp+nb_add+INCR);
	om$vla_set_dimension(varray = me->work_comp_env,
			     size = me->work_nb_comp+nb_add+INCR);
      }
     me->work_comp[me->work_nb_comp + nb_add]     = LocatedObjects[i].obj_id;
     me->work_comp_env[me->work_nb_comp + nb_add] = LocatedObjects[i].mod_env;
     nb_add++;

   next_loop:
     status = om$send(msg = message NDnode.NDdisplay(0, GRhe, &me->ModuleInfo),
		      targetid = LocatedObjects[i].obj_id.objid,
		      targetos = LocatedObjects[i].obj_id.osnum);
     as$status(action = CONTINUE,
	       msg = "Warning cannot dehilight located compart")
     }
  ASend_fence();
		 
  if(nb_add == 0) {*sts = NO_OBJ_LOCATED; goto quit;}
 
  me->work_nb_comp += nb_add;

  if(me->work_nb_comp == 1 && nb_add == 1)
   {
     SMGetSplitName(&me->work_comp[0],name);
     FIg_set_text(me->forms[0].form_ptr,G_COMP_NAME,name);
   }
  else
    FIg_set_text(me->forms[0].form_ptr,G_COMP_NAME,"defined");
  
  *sts = OM_S_SUCCESS;

 quit:
  return OM_S_SUCCESS;
}

/*-------------------- method put_sect_param ------------------ */
/*  Put all paramters of a section  in the form                 */
/*  The buffer for the parameter use are "save_"                */

method put_sect_param( long * sts )
{
  int       i;
  char      name[256];
  IGRdouble val_db;
  
  SMConvDistIntExt(me->save_info.EndOffset,&val_db,me->ModuleInfo.md_id.osnum);
  FIg_set_value(me->forms[0].form_ptr,G_END_OFFSET,val_db);
 
  /* Axis is only an x axis */
  FIset_axis(me->forms[0].form_ptr,me->save_info.axis);

  switch(me->save_info.mode)
   {
   case SM_SECT_SGL:
     om$send(msg = message SMCmdSect.toggle_mode( sts ,SM_SECT_SGL),
	     targetid = my_id);
     FIg_set_value(me->forms[0].form_ptr,G_NB_SECT,
		   (double)me->save_info.att.sgl.NbSect);
     break;

   case SM_SECT_USER:
     om$send(msg = message SMCmdSect.toggle_mode( sts ,SM_SECT_USER),
	     targetid = my_id);
     for(i = 0; i < me->save_nb_frame; i++)
      {
	if(i % 2 == 0)
	  place_frame_in_form(me->forms[0].form_ptr,&me->save_frame[i],
			      &me->save_info,i / 2,G_FROM_FRAME);
	else
	  place_frame_in_form(me->forms[0].form_ptr,&me->save_frame[i],
			      &me->save_info, i / 2,G_TO_FRAME);
      }
     break;

   case SM_SECT_AUTO:
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
		  "Not yet implemented automatic sections");
     goto wrapup;
   }  

  /* Set the name of the compartment */
  
  name[0] = '\0';
  if(me->save_nb_comp == 1)
    SMGetSplitName(&me->save_comp[0],name);
  else
    if(me->save_nb_comp > 0) strcpy(name,"defined");

  FIg_set_text(me->forms[0].form_ptr,G_COMP_NAME,name);


  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;

 wrapup:
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;
} 

/* -------------------- method copy_param ---------------------- */
/* Copy me->save_.. to me->work_ or vice versa depanding on flag */ 

method copy_param( long * sts ; int flag )
{
  int i;

  switch(flag)
   {
   case WORK_TO_SAVE:
     me->save_info = me->work_info;

     me->save_nb_comp = me->work_nb_comp;
     
     if(me->save_nb_comp > om$dimension_of( varray = me->save_comp))
      {
	om$vla_set_dimension(varray = me->save_comp,    size = me->save_nb_comp);
	om$vla_set_dimension(varray = me->save_comp_env,size = me->save_nb_comp);
      }
     
     for(i = 0; i < me->save_nb_comp; i++)
      {
	me->save_comp[i]     = me->work_comp[i];
	me->save_comp_env[i] = me->work_comp_env[i];
      }

     me->save_nb_frame = me->work_nb_frame;
     for(i=0;i<me->work_nb_frame; i++)
      {
	me->save_frame[i]     = me->work_frame[i];
	me->save_frame_env[i] = me->work_frame_env[i];
      }
     break;

   case SAVE_TO_WORK:
     me->work_info = me->save_info ;

     me->work_nb_comp = me->save_nb_comp ;

     if(me->work_nb_comp > om$dimension_of( varray = me->work_comp))
      {
	om$vla_set_dimension(varray = me->work_comp,    size = me->work_nb_comp);
	om$vla_set_dimension(varray = me->work_comp_env,size = me->work_nb_comp);
      }
     for(i=0; i < me->save_nb_comp; i++)
      {
	me->work_comp[i]     = me->save_comp[i];
	me->work_comp_env[i] = me->save_comp_env[i];
      }

     me->work_nb_frame = me->save_nb_frame;
     for(i = 0; i < me->work_nb_frame; i++)
      {
	me->work_frame[i]     = me->save_frame[i];
	me->work_frame_env[i] = me->save_frame_env[i];
      }
     break;
   }
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* -------------------- method add_locate_frame --------------------*/
/* Add a frame to the list of frame and fill the form with the new  */
/* located frame                                                    */

method add_locate_frame( long * sts )
{
  struct GRid     my_cs,as_cs, frame;
  struct GRmd_env frame_env, cs_env;
  IGRlong         status,msg;
  IGRint          cur_fr_num,prec_fr_num;
  
  frame     = me->event1.located_object[0].located_obj;
  frame_env = me->event1.located_object[0].module_info;
  
  /* Get the active CS */

  status = SMGetDefCs(TRUE,                   /* Don't take EMS cs */
		      (struct GRid *)NULL,     /* Connected with Db not needed */
		      (IGRshort *)NULL,        /* State not used */ 
		      &my_cs,    
		      &as_cs,              
		      &cs_env,
		      (IGRboolean *)NULL);     /* No flag needed */
  /* verify that the frame system is on the x axis of the cs */

  if(!verif_frame(&my_cs, &me->ModuleInfo, &frame))
   { *sts = NO_OBJ_LOCATED; goto wrapup; }

  if(me->work_nb_frame >= 2 * SM_MAX_PARTS)
   {*sts = TOO_MUCH_OBJECT ; goto wrapup; }
  
  if(me->work_nb_frame == 0)
   {
     me->work_frame[me->work_nb_frame]     = frame;
     me->work_frame_env[me->work_nb_frame] = frame_env;
     me->work_nb_frame++;
     place_frame_in_form(me->forms[0].form_ptr,&frame,
			 (struct SMSectInfo *)NULL,0,G_FROM_FRAME);
   }
  else
   {
     /* Control new frame number is greater than preceding */
     status = om$send(msg = message SMframe.SMfind_frame_num
		      (&msg, &prec_fr_num),
		      targetid = me->work_frame[me->work_nb_frame - 1].objid,
		      targetos = me->work_frame[me->work_nb_frame - 1].osnum);
     as$status(sts = (status & msg),action = RET_VALUE);
     
     status = om$send(msg = message SMframe.SMfind_frame_num
		      (&msg, &cur_fr_num),
		      targetid = frame.objid,
		      targetos = frame.osnum);
     as$status(sts = (status & msg));
     
     if(prec_fr_num >= cur_fr_num)
      { *sts = NO_OBJ_LOCATED; goto wrapup; }
     
     if(me->work_nb_frame == 1)
      {
	me->work_frame[me->work_nb_frame]     = frame;
	me->work_frame_env[me->work_nb_frame] = frame_env;
	me->work_nb_frame++;
	place_frame_in_form(me->forms[0].form_ptr,&frame,
			    (struct SMSectInfo *)NULL,0,G_TO_FRAME);
      }
     else
      {
	/* In this case put the preceding frame as from and located as to fr */
	me->work_frame[me->work_nb_frame] =
	  me->work_frame[me->work_nb_frame - 1];
	me->work_frame_env[me->work_nb_frame] =
	  me->work_frame_env[me->work_nb_frame - 1];
	place_frame_in_form(me->forms[0].form_ptr,
			    &me->work_frame[me->work_nb_frame - 1],
			    (struct SMSectInfo *)NULL,
			    me->work_nb_frame / 2,G_FROM_FRAME);
	
	me->work_frame[me->work_nb_frame + 1] = frame;
	me->work_frame_env[me->work_nb_frame + 1] = frame_env;
	place_frame_in_form(me->forms[0].form_ptr, &frame,
			    (struct SMSectInfo *)NULL,
			    me->work_nb_frame / 2,G_TO_FRAME);
	me->work_nb_frame += 2;
      }
   }
  
  status = om$send(msg = message NDnode.NDdisplay(0, GRhhd, &me->ModuleInfo),
		   targetid = frame.objid,
		   targetos = frame.osnum);
  as$status(action = CONTINUE,
	    msg = "Warning cannot hilight located frame");
   
  FIfld_set_max_num_rows(me->forms[0].form_ptr,G_SECT_LIST,
			 me->work_nb_frame / 2 );
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;

wrapup:

  status = om$send(msg = message NDnode.NDdisplay(0, GRhe, &me->ModuleInfo),
		   targetid = frame.objid,
		   targetos = frame.osnum);
  as$status(action = CONTINUE,
	    msg = "Warning cannot erase hilight located frame");

  return OM_S_SUCCESS;

}


#ifdef JJ_DEBUG
static void debug_param(Info,comp_id,nb_comp,frame,nb_frame)
struct SMSectInfo *Info;
struct GRid comp_id[];
int nb_comp;
struct GRid frame[];
int nb_frame;
{
  int k;
 
  printf("Info : EndOffset = %g NbPart = %d\n",
	 Info->EndOffset,Info->NbPart);
  for(k=0;k<nb_comp;k++)
    printf("Comp_id %d\n",comp_id[k].objid);
  switch(Info->mode)
   {
   case SM_SECT_SGL:
     printf("Nb_sect = %d \n",Info->att.sgl.NbSect);
     break;
   case SM_SECT_USER:
     for(k=0;k<Info->NbPart;k++)
       printf("Section %d From %g To %g NbSect %d\n",k,
	      Info->att.usr[k].FrDx,Info->att.usr[k].ToDx,
	      Info->att.usr[k].NbSect);
     for(k=0; k<nb_frame; k++)
       printf("frame[%d] = %d %d\n",k,frame[k].objid,frame[k].osnum);
     break;
   }
}
#endif 


end implementation SMCmdSect;







