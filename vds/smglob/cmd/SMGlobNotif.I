/* $Id: SMGlobNotif.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smglob/cmd / SMGlobNotif.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMGlobNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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
# Revision 1.2  1995/11/29  13:54:26  pinnacle
# Replaced: ./smglob/cmd/SMGlobNotif.I for:  by ksundar for vds.240
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
      File           SMGlobNotif.I
      Creation Date  July 92   
      Author         Jean Jasinczuk
  
      History
      Revision       September  92 Change in the Gadget
                    4  February 93 All attributes are not needed.
                    18 February 93 Remove specific attributes from database.
		    9 April     93 Compile for 2.2
		    23 June     93 Dehilite hull when locate an another hull
*/
  
class implementation SMCmdGlob;

#define AS_DEBUG       1
 
#include <stdlib.h>
#include "VDDbDef.h"
#include "UOMdef.h"
#include "vdsmacros.h"

#include "AS_status.h"

from GRvg   import GRgetname ;
from ACncpx import ACmplace;            
from SMglob import SMcreate,SMModify,SMGetConnected;
from SMmgr  import SMGetState,SMSetState,SMChgState,SMGetAtt,SMAddAtt,
                   SMGetAttTxt,SMSetAttTxt;


extern void SMVA_set_default_text(),SMVA_set_text();
extern void SMVA_set_default_value(),SMVA_set_value();


/* ------------------   init_glob_acrg -------------------------- */
/* Initialise a ACrg collection for global with the name and type */

static void init_glob_attr(ACrg)
struct ACrg_coll ACrg[];  /* [O] The ACrg collection to init */
{
  strcpy(ACrg[I_FLG].name,S_FLAG_STATE);
  ACrg[I_FLG].desc.type = AC_ATTRIB_TEXT;
 
  strcpy(ACrg[I_AOO].name,S_AREA_OP);
  ACrg[I_AOO].desc.type = AC_ATTRIB_TEXT;
 
  strcpy(ACrg[I_LPP].name,S_LPP);
  ACrg[I_LPP].desc.type = AC_ATTRIB_DOUBLE;
 
  strcpy(ACrg[I_BMO].name,S_MOULD_BREADTH);
  ACrg[I_BMO].desc.type = AC_ATTRIB_DOUBLE;
 
  strcpy(ACrg[I_DMO].name,S_MOULD_DEPTH);
  ACrg[I_DMO].desc.type = AC_ATTRIB_DOUBLE;
 
  strcpy(ACrg[I_LOA].name,S_OVERALL_LENGTH);
  ACrg[I_LOA].desc.type = AC_ATTRIB_DOUBLE;
 
  strcpy(ACrg[I_DDE].name,S_DESIGN_DRAFT);
  ACrg[I_DDE].desc.type = AC_ATTRIB_DOUBLE; 
    
  strcpy(ACrg[I_SHE].name,S_SHELL_PLATING);
  ACrg[I_SHE].desc.type = AC_ATTRIB_DOUBLE;
 
  strcpy(ACrg[I_KEE].name, S_KEEL_PLATING);
  ACrg[I_KEE].desc.type = AC_ATTRIB_DOUBLE;

  strcpy(ACrg[I_DIR].name, S_MAIN_DIR);
  ACrg[I_DIR].desc.type = AC_ATTRIB_TEXT;

  strcpy(ACrg[I_SIDE].name, S_SIDE);
  ACrg[I_SIDE].desc.type = AC_ATTRIB_TEXT;
}

/* -------------------- ret_an_save ----------------------------------- */
/* Retrieve and eventually save a row in the G_ATTRIB field in the form */

static int ret_and_save(form,label,ACrg,need,field_name)
Form form;               /* The form ptr              [I] */
int label;               /* The gadget label           [I] */
struct ACrg_coll *ACrg; /* The ACrg collection of the attribute  [O] */ 
int need;               /* 1 If the attribute is need 0 else     [I]  */
char *field_name;       /* The name of the field to control      [I] */
{
  char   buf_text[ATTR_TXT];
  char   err_msg[45];
  int    text_length;
  int    sel,pos;
  double val_db;

  buf_text[0] = '\0'; 
  FIfld_get_text_length(form,label,0,0,&text_length);
  if(text_length >= ATTR_TXT -1)
   {
     ex$message(msgnumb = SM_E_GlTooMuch, buff = err_msg,
		type = "%s",var = `field_name`);
     FIg_set_text(form,FI_MSG_FIELD,err_msg);
     FIfld_set_text(form,label,0,0,"",0);
     return 0;
   } 

  FIfld_get_text(form,label,0,0,ATTR_TXT-1,(unsigned char*)buf_text,&sel,&pos);
  if(buf_text[0] == 0 && need)
   {
     ex$message(msgnumb = SM_E_GlNeedValue, buff = err_msg,
		type = "%s",var = `field_name`);
     FIg_set_text(form,FI_MSG_FIELD,err_msg);
     return 0;
   } 

  switch(ACrg->desc.type)
   {
   case AC_ATTRIB_TEXT :
     strcpy(ACrg->desc.value.att_txt,buf_text);
     break;
   case AC_ATTRIB_DOUBLE :
     if(buf_text[0] == 0) val_db = NO_VALUE;
     else if(!SMget_double(form,label,0,0,&val_db))
      {
	ex$message(msgnumb = SM_E_GlBadValue, buff = err_msg,
		   type = "%s",var = `field_name`);
	FIg_set_text(form,FI_MSG_FIELD,err_msg);
	return 0;
      }
     ACrg->desc.value.att_exp = val_db; 
     break;
   default:
     return 0;
   }
    
  return 1;
}


/* ------------------ control_double_value -------------------- */
/* Given a double gadget control value in the gadget            */
/* check it's correct                                           */ 

static int control_double_value(form,label,field_name)
Form form;          /* The form ptr              [I] */
int label;          /* The selected gadget       [I] */
char *field_name;   /* The name of the field to control [I] */  
{
  char   err_msg[80];
  double db;
  char   buf_text[ATTR_TXT];
  int    sel,pos;

  buf_text[0] = '\0';
  FIfld_get_text(form,label,0,0,ATTR_TXT-1,(unsigned char*)buf_text,&sel,&pos);
  if(buf_text[0] == '\0') return 1;

  if(!SMget_double(form,label,0,0,&db))
   {
     ex$message(msgnumb = SM_E_GlBadValue, buff = err_msg,
		type = "%s",var = `field_name`);
     FIg_set_text(form,FI_MSG_FIELD,err_msg);
     FIg_set_text(form,label,"");
     return 0;
   } 
  else
    return 1;
}

/* ------------------ static void gener_def_name -------------------- */
/* Gener a default name for a hull consedering preceding default name */

static void gener_def_name(global,nb_hull,name)
struct globname *global; /* [O] Array of the glob objects found */
int nb_hull;             /* [I] Number of existing hull  */
IGRchar *name;           /* [O] Generate name */
{
  int i = 1,j;

  do
   {
     sprintf(name,"defined_%d",i);
     for(j = 0; j < nb_hull; j++)
      {
	if(strcmp(global[j].name,name) == 0)
	 {
	   i++;
	   break;
	 }
      }
   }while( j != nb_hull);
}

/* ------------------ static void set_hull_names ------------------ */
/* Retreive hull name or gener a default name for hull             */  

static void set_hull_names(global,nb_hull)
struct globname *global; /* [O] Array of the glob objects found */
int nb_hull;             /* [I] Number of existing hull  */
{
  IGRlong status,msg;
  char    name[DI_PATH_MAX];
  int     i,j;

  for(i=0;i<nb_hull;i++)
   {
     name[0] = '\0';
     if(global[i].hull.objid != NULL_OBJID) 
       vd$get_name(name = name, obj = &(global[i].hull));
     if(name[0] != '\0') goto assign_name;
      
     if(global[i].glob.objid != NULL_OBJID)
      {
	status = om$send(msg = message SMmgr.SMGetAttTxt
			 (&msg,"default_name",name,(IGRshort *)NULL),
			 senderid = NULL_OBJID,
			 targetid = global[i].glob.objid, 
			 targetos = global[i].glob.osnum);
	if(!(status & msg & 1)) name[0] = '\0';
	else
	 {
	   /* Verify if name not already exists */
	   for(j = 0; j < i; j++)
	     if(strcmp(global[j].name,name) == 0)
	      {
		/* Name exists, gener another name */
		name[0] = '\0';
		break;
	      }
	 }
      }
     if(name[0] == '\0') gener_def_name(global,i,name);
      
   assign_name:
     strncpy(global[i].name,name,ATTR_TXT)[ATTR_TXT -1] = '\0';
   }
}

/* ----------------------- method form_notification ---------------------- */

method form_notification (int form_label; int gadget_label ; double value ;
			  char * form_ptr)
{
  long sts;
  int  status = OM_S_SUCCESS;
  int  fore;

  if ( form_ptr == NULL )
   {
     /*| no form_ptr set */
     return( OM_E_INVARG ); 
   }
  
  FIg_set_text(form_ptr,FI_MSG_FIELD, "");
  
  switch( gadget_label )
   {
   case FI_ACCEPT:
     om$send(msg = message SMCmdGlob.save_all(&sts),
	     targetid = my_id);
     
     FIg_set_state_off(form_ptr,FI_ACCEPT);
     if(sts == OM_S_SUCCESS || sts == OM_E_ABORT )
       _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_EXECUTE:
     om$send(msg = message SMCmdGlob.save_all(&sts),
	     targetid = my_id);

     FIg_set_state_off(form_ptr,FI_EXECUTE);
     
     if(sts == OM_S_SUCCESS)
      {
	char name_frm[DI_PATH_MAX],name_cs[DI_PATH_MAX];

	/* Put CS, frame name and hull name as default */
	SMGetSplitName(&me->act_frm.obj_id,name_frm);
	SMGetSplitName(&me->act_cs.obj_id,name_cs);

	SMVA_set_default_text(me->forms[0].form_ptr,3,
			      G_HULL_LIST,me->act_glob.name,
			      G_FRM,name_frm,
	                      G_CS,name_cs);

	/* Put all parameters in the form and set them as default value */
	om$send(msg = message SMCmdGlob.put_attr_in_form(&sts,TRUE),
		targetid = my_id);
	
      }
     break;
     
   case FI_CANCEL :
     _put_response(resp = TERMINATE);
     goto quit;
     
   case FI_RESET :
     om$send(msg = message SMCmdGlob.reset_all(&sts),
	     targetid = my_id);
     break;
     
   case G_ID_CS:
     _put_response(resp = IDENTIFY_CS);
     break;

   case G_ID_FRM:
     _put_response(resp = IDENTIFY_FRAME);
     break;

   case  G_ID_HULL:
     /* Dehilite old active global hull (Jean : Change 6/23/93) */
     if(me->act_glob.hull.objid != NULL_OBJID)
       dp$display(msg = &sts, oids = &me->act_glob.hull, mode = GRhe);
     _put_response(resp = IDENTIFY_HULL);
     break;

     
   case G_HULL_LIST:
     om$send(msg = message SMCmdGlob.select_hull_list(&sts),
	     targetid = my_id);
     break;
  
   case G_DIR:
     FIg_get_state(me->forms[0].form_ptr,G_DIR,&fore);
     if(fore) FIg_set_text(me->forms[0].form_ptr,G_SIDE,"portside");
     else     FIg_set_text(me->forms[0].form_ptr,G_SIDE,"starboard"); 
     break;

   case G_LPP:
     control_double_value(me->forms[0].form_ptr,G_LPP,GS_LPP);break;
   case G_BMO:
     control_double_value(me->forms[0].form_ptr,G_BMO,GS_BMO);break;
   case G_DMO:
     control_double_value(me->forms[0].form_ptr,G_DMO,GS_DMO);break;
   case G_LOA:
     control_double_value(me->forms[0].form_ptr,G_LOA,GS_LOA);break;
   case G_DDE:
     control_double_value(me->forms[0].form_ptr,G_DDE,GS_DDE);break;
   case G_SHE:
      control_double_value(me->forms[0].form_ptr,G_SHE,GS_SHE);break;
   case G_KEE:
     control_double_value(me->forms[0].form_ptr,G_KEE,GS_KEE);break;
   }
  
 quit: return OM_S_SUCCESS;
}


/*----------------------- method init_all --------------------------------- */
/*                  Method call when state start                            */

method init_all(long *sts)
{
  IGRlong           msg;
  int               i,j,ind_actif;
  IGRboolean        already_exists;
  IGRlong           status = OM_S_SUCCESS,msgnumb;
  char              name[DI_PATH_MAX];
  struct SMObjList  list;
  struct GRid       cs,frm_syst,hull,tmp_obj;
  struct GRmd_env   frm_env,obj_env;
  IGRshort          state,four;
  short             flag = 1, num_defaults = 1;
  GRIOalias_name    alias_name[UOM_K_MAX_DEFS];
  struct VDSproject proj_att;
  char              proj_nb[80],proj_rev[80];
  IGRint	    prj_units;

  list.list       = NULL;
  list.nb_objects = 0;
  me->nb_hull     = 0;
  me->new_act_cs.obj_id.objid  = me->act_cs.obj_id.objid  = NULL_OBJID;
  me->new_act_frm.obj_id.objid = me->act_frm.obj_id.objid = NULL_OBJID;
  me->act_glob.glob.objid      = NULL_OBJID;
  me->act_glob.glob.osnum      = me->ModuleInfo.md_id.osnum;
  ind_actif 	  = -1;

  status = uom$get_default_units(msg           = &msg,
				 table_name    = GRIO_DISTANCE,
				 flag          = &flag,
				 num_defaults  = &num_defaults,
				 default_units = alias_name,
				 osnum         = me->ModuleInfo.md_id.osnum);
  if(status & 1) strcpy(me->save_unit,alias_name[0]);
  else uom$report_error(msg = status);

  FIg_set_text(me->forms[0].form_ptr,G_UNIT,me->save_unit);
  FIfld_set_default_text(me->forms[0].form_ptr,G_UNIT,0,0,me->save_unit,0);
     
  /* Blank all gadget */
  SMVA_set_default_text(me->forms[0].form_ptr,9,
			G_PRJ,"", G_TIT,"",
			G_LPP,"", G_BMO,"", G_DMO,"", G_LOA,"",
			G_DDE,"", G_SHE,"", G_KEE,"");
  /* Put value AFT and STARBOARD as default */
  SMVA_set_default_state(me->forms[0].form_ptr,1,G_DIR,0);
  SMVA_set_default_text(me->forms[0].form_ptr,1,G_SIDE,"starboard");

  /* Search project number and attributes */
  if(VDGetProjectNumRev(proj_nb,proj_rev,&prj_units) &&
     VdsSetProjectData(proj_nb,proj_rev,&proj_att, &msgnumb))
   {
     SMVA_set_default_text(me->forms[0].form_ptr,2,
			   G_PRJ,proj_att.prj_number,
			   G_TIT,proj_att.prj_name);
   }

  /* Search global datas in current file */

  status = SM$CritSel(msg     = &msg,
		      type    = SM_SHIP_ATT,
		      options = SM_REF_FILE,
		      list    = &list);
  if(!(status & msg & 1))
   {
     printf("Problem SM$CritSel\n");
     goto wrapup;
   }

  if( list.nb_objects > om$dimension_of(varray = me->global) )
    om$vla_set_dimension(varray = me->global,size = list.nb_objects);

  /* Put all the list of hull in the G_HULL_LIST . Retrieve active hull */
  for(i=0; i<list.nb_objects; i++)
   {
     already_exists = FALSE;

     /* Verify if object doesn't already exists          */
     /* (possible because multiple reference attachement) */
     for(j=0;j<i;j++)
       if(list.list[i].obj_id.objid == list.list[j].obj_id.objid &&
	  list.list[i].obj_id.osnum == list.list[j].obj_id.osnum)
	 already_exists = TRUE;

     if(already_exists) continue;

     /* Found the objects connected with the global data */
     status = om$send(msg = message SMglob.SMGetConnected
		      (&msg,&cs,&frm_syst,&frm_env,&hull),
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum);
     if(!(status & msg & 1))
      { printf("Warning, one global data not connected\n"); continue; } 
   
     /* Copy glob data parameter in buffer */
     me->global[i].glob     = list.list[i].obj_id;
  
     /* Retrieves module env of hull by combining with global data */ 
     if(!GetEnvFrObj(&hull,&obj_env,&tmp_obj)) goto wrapup;

     me->global[i].hull  = hull;
     four = 4;
     MAmulmx(&msg,&four,&four,&four,list.list[i].mod_env.md_env.matrix,
	     obj_env.md_env.matrix,me->global[i].hull_env.md_env.matrix);
     MAtypemx(&msg,me->global[i].hull_env.md_env.matrix,
	      &me->global[i].hull_env.md_env.matrix_type);
     me->global[i].hull_env.md_id = obj_env.md_id;
     
     /* Put the name in the list (and put it as default) */
   
     me->nb_hull++;

     /* If it's the active hull, recover all the parameters and display */
     /* them in the form */

     status = om$send(msg = message SMmgr.SMGetState(&state),
		      targetid = list.list[i].obj_id.objid,
		      targetos = list.list[i].obj_id.osnum); 
     as$status();
     
     if(state & SM_ACT)
      {
	if(ind_actif != -1 &&
	   list.list[ind_actif].obj_id.osnum == me->ModuleInfo.md_id.osnum &&
	   list.list[i].obj_id.osnum != me->ModuleInfo.md_id.osnum)
	  continue;

	ind_actif = i;

	/* Retreives module env of cs */
	if(!GetEnvFrObj(&cs,&obj_env,&me->act_cs.obj_id))
	  goto wrapup;
	
	four = 4;
	MAmulmx(&msg,&four,&four,&four,list.list[i].mod_env.md_env.matrix,
		obj_env.md_env.matrix,me->act_cs.mod_env.md_env.matrix);
	MAtypemx(&msg,me->act_cs.mod_env.md_env.matrix,
		 &me->act_cs.mod_env.md_env.matrix_type);
	me->act_cs.mod_env.md_id = obj_env.md_id;

	me->new_act_cs.obj_id  = me->act_cs.obj_id ;
	me->new_act_cs.mod_env = me->act_cs.mod_env;

	/* Affect active hull : active hull is affect with graphic object */
	me->act_glob.glob     = list.list[i].obj_id;
	me->act_glob.hull_env = me->global[i].hull_env;
	if(!GetEnvFrObj(&hull,(struct GRmd_env *)NULL,&me->act_glob.hull))
	  goto wrapup;
	
	/* Remember active frame system */
	me->new_act_frm.obj_id  = me->act_frm.obj_id  = frm_syst;
	four = 4;
	MAmulmx(&msg,&four,&four,&four,list.list[i].mod_env.md_env.matrix,
		frm_env.md_env.matrix,me->act_frm.mod_env.md_env.matrix);
	MAtypemx(&msg,me->act_frm.mod_env.md_env.matrix,
		 &me->act_frm.mod_env.md_env.matrix_type);
	me->act_frm.mod_env.md_id = frm_env.md_id;
	me->new_act_frm.mod_env = me->act_frm.mod_env;

	/* Get split name of global data */
	SMGetSplitName(&me->act_frm.obj_id,name);
	SMVA_set_default_text(me->forms[0].form_ptr,1,G_FRM,name);

	init_glob_attr(me->ACrg);
	status = om$send(msg = message SMglob.SMGetAtt
			 (&msg,NB_GLOB_ATTRIB - 2,me->ACrg,NULL),
			 targetid = me->act_glob.glob.objid,
			 targetos = me->act_glob.glob.osnum);
	if(!(status & msg & 1))
	 {
	   printf("Fatal error, can't get active hull parameters\n");
	   goto wrapup;
	 }
	
	/* Special case  S_MAIN_DIR and S_SIDE because add later */
	status = om$send(msg = message SMglob.SMGetAtt
			 (&msg,2,&me->ACrg[I_DIR],NULL),
			 targetid = me->act_glob.glob.objid,
			 targetos = me->act_glob.glob.osnum);
	if(!(status & msg & 1))
	 {
	   strcpy(me->ACrg[I_DIR].desc.value.att_txt,"aft");
	   strcpy(me->ACrg[I_SIDE].desc.value.att_txt,"starboard");
	 }
	
	/* Put all parameters in the form and set them as default value */
	om$send(msg = message SMCmdGlob.put_attr_in_form(sts,TRUE),
		targetid = my_id);
	
      } /*if(state & SM_ACT) */ 
   } /* for(i=0;i<list.nb_objects;i++) */

  /* Gener all hull names and put all hull names in form */
  set_hull_names(&me->global[0],me->nb_hull);
  for(i=0;i<me->nb_hull;i++)
   {
     VDfld_set_list_text(me->forms[0].form_ptr,G_HULL_LIST,i,0,
			 me->global[i].name,0);
     FIfld_set_list_default_text(me->forms[0].form_ptr,G_HULL_LIST,i,0,
				 me->global[i].name,0);
   }
  
  /* Put active hull name at top of list of hulls */
  if(ind_actif != -1)
   {
     strncpy(me->act_glob.name,
	     me->global[ind_actif].name,ATTR_TXT)[ATTR_TXT -1] = '\0';
     SMVA_set_default_text(me->forms[0].form_ptr,1,G_HULL_LIST,
			   me->act_glob.name);
   }

  /* No active cs defined : default is EMS active cs */
  if(me->act_cs.obj_id.objid == NULL_OBJID)
   {
     me->act_cs.mod_env = me->ModuleInfo; 
     me->act_cs.obj_id.osnum = me->ModuleInfo.md_id.osnum;
     status = cs$get_active_info(msg   = &msg,
				 osnum = me->act_cs.obj_id.osnum,
				 objid = &me->act_cs.obj_id.objid);
     as$status(sts = (status & msg));
     me->new_act_cs.obj_id  = me->act_cs.obj_id;
     me->new_act_cs.mod_env = me->act_cs.mod_env;
   }

  /* Get name of active cs and put him in the form as default*/
  if(me->act_cs.obj_id.objid != NULL_OBJID)
   {
     SMGetSplitName(&me->act_cs.obj_id,name);
     SMVA_set_default_text(me->forms[0].form_ptr,1,G_CS,name);
   }

  if(list.nb_objects > 0 && list.list != NULL)
    free(list.list);
  *sts = MSSUCC;
  return OM_S_SUCCESS;

   wrapup:
     if(list.nb_objects > 0 && list.list != NULL)
       free(list.list);
     me->state = _terminate;
     *sts = OM_E_ABORT;
     return OM_I_STOP_SENDING;
}

/* --------------------- method reset_all --------------------- */

method reset_all(long *sts)
{
  int i;
  int sel_flag,r_pos;

  /* Default value have been put by FIfld_set_default */
  /* The name of the default active hull was put at begin of command */
  /* Get this default name in gadget and assign hull as active       */
  FIfld_get_text(me->forms[0].form_ptr,G_HULL_LIST,0,0,
		 ATTR_TXT,(unsigned char*)me->act_glob.name,&sel_flag,&r_pos);
  me->act_glob.name[ATTR_TXT -1] = '\0';
  for(i=0;i<me->nb_hull;i++)
    if(strcmp(me->act_glob.name,me->global[i].name) == 0)
     {
       me->act_glob.glob     = me->global[i].glob;
       me->act_glob.hull     = me->global[i].hull;
       me->act_glob.hull_env = me->global[i].hull_env;
     }
  if(me->act_cs.obj_id.objid != NULL_OBJID)
   {
     me->new_act_cs.obj_id  = me->act_cs.obj_id;
     me->new_act_cs.mod_env = me->act_cs.mod_env;
   }
  me->new_act_frm = me->act_frm;

  if(me->act_glob.glob.osnum != me->ModuleInfo.md_id.osnum)
    SMVA_disable(me->forms[0].form_ptr,2,FI_ACCEPT,FI_EXECUTE);
  else
    SMVA_enable(me->forms[0].form_ptr,2,FI_ACCEPT,FI_EXECUTE);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/* ------------------------- method save_all ----------------------- */
/* Method use when FI_ACCEPT or FI_EXECUTE selected in the main_form */

method save_all(long *sts)
{
  IGRlong status = OM_S_SUCCESS;
  char    err_msg[80];
  int     i,fore;
  
  if(me->nb_hull <= 0)
   {
     ex$message(msgnumb = SM_E_GlNoActHull, buff = err_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,err_msg);
     goto wrapup;
   }

  /* Retreive the attributes in the form and put them in buffer */  
  if(   !ret_and_save(me->forms[0].form_ptr,G_LPP, &me->ACrg[I_LPP], 1,GS_LPP)
     || !ret_and_save(me->forms[0].form_ptr,G_BMO, &me->ACrg[I_BMO], 0,GS_BMO)
     || !ret_and_save(me->forms[0].form_ptr,G_DMO, &me->ACrg[I_DMO], 0,GS_DMO)
     || !ret_and_save(me->forms[0].form_ptr,G_LOA, &me->ACrg[I_LOA], 0,GS_LOA)
     || !ret_and_save(me->forms[0].form_ptr,G_DDE, &me->ACrg[I_DDE], 0,GS_DDE)
     || !ret_and_save(me->forms[0].form_ptr,G_SHE, &me->ACrg[I_SHE], 0,GS_SHE)
     || !ret_and_save(me->forms[0].form_ptr,G_KEE, &me->ACrg[I_KEE], 0,GS_KEE)
     )
     goto wrapup;

  /* HARD CODING of FLG state and AOO */
  strcpy(me->ACrg[I_FLG].desc.value.att_txt,"10");
  strcpy(me->ACrg[I_AOO].desc.value.att_txt,"0");

  /* Found MAIN_DIR attribute . Set SIDE too */
  FIg_get_state(me->forms[0].form_ptr,G_DIR,&fore);
  if(fore) 
    {
      strcpy(me->ACrg[I_DIR].desc.value.att_txt,"fore");
      strcpy(me->ACrg[I_SIDE].desc.value.att_txt,"portside");
    }
  else   
    {
      strcpy(me->ACrg[I_DIR].desc.value.att_txt,"aft"); 
      strcpy(me->ACrg[I_SIDE].desc.value.att_txt,"starboard");
    }

  /* Made some convertion */
  /* Warning: I Explicitly use order of the attributes here */
  for( i= I_LPP; i <= I_KEE; i++)
   {
     if(me->ACrg[i].desc.value.att_exp != NO_VALUE)
       SMConvDistExtInt(me->ACrg[i].desc.value.att_exp,
			&me->ACrg[i].desc.value.att_exp,
			me->ModuleInfo.md_id.osnum);
   }

  if(me->new_act_cs.obj_id.objid == NULL_OBJID)
   {
     ex$message(msgnumb = SM_E_GlNoActCs, buff = err_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,err_msg);
     goto wrapup;
   }
  
  if(me->new_act_frm.obj_id.objid == NULL_OBJID)
   {
     ex$message(msgnumb = SM_E_GlNoActFrm, buff = err_msg);
     FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,err_msg);
     goto wrapup;
   }
  
  status = om$send(msg = message SMCmdGlob.modif_glob_data( sts ),
		   targetid = my_id);
  if(!(status & *sts & 1)) goto wrapup;
  
  /* Change state of active frame system */
  if( me->new_act_frm.obj_id.objid != me->act_frm.obj_id.objid ||
      me->new_act_frm.obj_id.osnum != me->act_frm.obj_id.osnum) 
   {
     if(me->act_frm.obj_id.objid != NULL_OBJID)
      {
	status = om$send(msg = message SMmgr.SMChgState
			 (SM_ACT,~SM_ACT),
			 targetid = me->act_frm.obj_id.objid, 
			 targetos = me->act_frm.obj_id.osnum);
	as$status(action = RET_STATUS);
       }	

     status = om$send(msg = message SMmgr.SMChgState
		      (SM_ACT,SM_ACT),
		      targetid = me->new_act_frm.obj_id.objid, 
		      targetos = me->new_act_frm.obj_id.osnum);
     as$status(action = RET_STATUS);
   }

  me->act_frm = me->new_act_frm;
  me->act_cs  = me->new_act_cs;
  
  *sts = OM_S_SUCCESS;
  goto quit;
  
 wrapup:
  *sts = OM_W_ABORT;
  
 quit:    return OM_S_SUCCESS;  
}   

/*-------------------  method control_new_hull ----------------------- */
/* Used when a new_hull is located . Put it in the list if not already */
/* in this list. The me->act_hull is also assign                       */
/* The new located hull becomes the default hull                       */

method control_new_hull(long *sts)
{
  struct GRmd_env md_env;
  IGRchar         name[DI_PATH_MAX],err_msg[80];
  int             i;
  struct GRid     loc_hull,tmp_obj;
  
  /* retrieve objid of the hull */
  loc_hull = me->event1.located_object[0].located_obj;
  md_env   = me->event1.located_object[0].module_info;
  
  /* If the new  hull is in the list, return */
  for(i=0;i<me->nb_hull;i++)
   {
     if(!GetEnvFrObj(&me->global[i].hull,(struct GRmd_env *)NULL,&tmp_obj))
       tmp_obj = me->global[i].hull;
     if(tmp_obj.objid == loc_hull.objid && tmp_obj.osnum == loc_hull.osnum)
      {
	ex$message(msgnumb = SM_I_GlHullAlRd, buff = err_msg);
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,err_msg);
	*sts = OM_S_SUCCESS; return OM_S_SUCCESS;
      }
   }
  
  /* Put my name in the list as the future active list */
  name[0] = '\0';
  vd$get_name(name = name, obj = &(me->global[i].hull));
  if(name[0] == '\0')
    gener_def_name(&me->global[0],me->nb_hull,name);
  
  /* The new  hull is not in  the list, so initialise a new glob data */
  if((me->nb_hull + 1) > om$dimension_of(varray = me->global))
    om$vla_set_dimension(varray = me->global,size = me->nb_hull + 5);
  
  me->act_glob.hull_env   = md_env;
  me->act_glob.glob.objid = NULL_OBJID;
  me->act_glob.glob.osnum = me->ModuleInfo.md_id.osnum;
  me->act_glob.hull       = loc_hull;
  strncpy(me->act_glob.name,name,ATTR_TXT)[ATTR_TXT -1] = '\0'; 
  
  /* Put the new hull in list */
  me->global[me->nb_hull].glob.objid = NULL_OBJID;
  me->global[me->nb_hull].glob.osnum = me->ModuleInfo.md_id.osnum;
  me->global[me->nb_hull].hull       = loc_hull;  
  me->global[me->nb_hull].hull_env   = me->act_glob.hull_env;
  
  strncpy(me->global[me->nb_hull].name,name,ATTR_TXT)[ATTR_TXT -1] = '\0';
  
  /* Put the name in the list text and remember as default name */
  VDfld_set_list_text(me->forms[0].form_ptr,G_HULL_LIST,me->nb_hull,0,name,0);  
  FIfld_set_list_default_text(me->forms[0].form_ptr,G_HULL_LIST,
			      me->nb_hull,0,name,0);
  me->nb_hull++;
  
  /* Put the name as current actif and default actif */
  SMVA_set_default_text(me->forms[0].form_ptr,1,G_HULL_LIST,name);
  
  /* Initialise an empty ACrg */
  init_glob_attr(me->ACrg);
 
  /* Enable save gadgets */
  SMVA_enable(me->forms[0].form_ptr,2,FI_ACCEPT,FI_EXECUTE);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}  

/* -------------------- method modif_glob_data ------------------------- */
/* Create global data if not exits  (and assign field in act_glob)       */
/* Set all paramater of Global data                                      */
/* Unset the SM_ACT of the old  hull and remember the objid of current   */
/* Also Change depandancy between old and new hull if needed             */

method modif_glob_data( long *sts )
{
  IGRlong         msg,status;
  struct GRid     old_act_hull,old_act_context,act_context;
  struct GRid     as_cs,as_hull,mac;
  struct GRmd_env old_act_env;
  int             i,sel_flag,r_pos;
  IGRshort        state;
  
  /*      Change parametrer of active global data       */
  status = as$make_source(go_grid = me->new_act_cs.obj_id,
			  mod_env = &me->new_act_cs.mod_env,
			  as_grid = &as_cs);
  as$status(action = RET_STATUS);
  
  status = as$make_source(go_grid = me->act_glob.hull,
			  mod_env = &me->act_glob.hull_env,
			  as_grid = &as_hull);
  as$status(action = RET_STATUS);
  
  /* If the Global Collection doesn't exists, create it */
  if(me->act_glob.glob.objid == NULL_OBJID)
   {
     mac.osnum = me->ModuleInfo.md_id.osnum;
     status = om$construct(classid = OPP_SMglob_class_id,
			   osnum   = mac.osnum,
			   p_objid = &mac.objid);
     as$status( action = RET_STATUS );
     
     status = om$send(msg = message SMglob.SMcreate
		      (&msg,&as_cs,&me->new_act_frm.obj_id,
		       &me->new_act_frm.mod_env,&as_hull,me->ACrg),  
		      targetid = mac.objid, 
		      targetos = mac.osnum);
     as$status(sts = (status & msg),action = RET_STATUS);

     status = om$send(msg = message SMmgr.SMSetState(SM_NEW | SM_ACT),
		      targetid = mac.objid ,targetos = mac.osnum);
     as$status(action = RET_STATUS);
     
     me->act_glob.glob = mac; 
   }
  else   /* Simply modify attributes */
   {
     struct GRid *pt_frm_obj;
     struct GRmd_env *pt_frm_env;
     
     if(me->new_act_frm.obj_id.objid != me->act_frm.obj_id.objid ||
	me->new_act_frm.obj_id.osnum != me->act_frm.obj_id.osnum)
      {
	pt_frm_obj = &me->new_act_frm.obj_id;
	pt_frm_env = &me->new_act_frm.mod_env;
      }
     else
      {
	pt_frm_obj = NULL;
	pt_frm_env = NULL;
      }
     
     status = om$send(msg = message SMglob.SMModify
		      (&msg,&as_cs,pt_frm_obj,pt_frm_env,&as_hull,me->ACrg), 
		      targetid = me->act_glob.glob.objid, 
		      targetos = me->act_glob.glob.osnum);
     as$status(sts = (status & msg),action = RET_STATUS);
     
     status = om$send(msg = message SMmgr.SMChgState
		      (SM_STATE | SM_ACT, SM_MOD | SM_ACT),
		      targetid = me->act_glob.glob.objid,
		      targetos = me->act_glob.glob.osnum);
     as$status(action = RET_STATUS);
   }

  FIfld_get_text(me->forms[0].form_ptr,G_HULL_LIST,0,0,
		 ATTR_TXT,(unsigned char*)me->act_glob.name,&sel_flag,&r_pos);
  me->act_glob.name[ATTR_TXT -1] = '\0';

  status = om$send(msg = message SMmgr.SMSetAttTxt
		   (&msg,"default_name",me->act_glob.name,(IGRshort)0),
		   targetid = me->act_glob.glob.objid,
		   targetos = me->act_glob.glob.osnum);
  as$status(sts = (status & msg));
  
  old_act_hull.objid = NULL_OBJID;
  
  /* Deactivate other hull */
  for(i=0;i<me->nb_hull;i++)
    if(strcmp(me->act_glob.name,me->global[i].name) == 0)
      me->global[i].glob = me->act_glob.glob;
    else
      if(me->global[i].glob.objid != NULL_OBJID)
       {
	 status = om$send(msg      = message SMmgr.SMGetState(&state),
			  targetid = me->global[i].glob.objid,
			  targetos = me->global[i].glob.osnum); 
	 as$status();
	 if(state & SM_ACT)
	  {
	    old_act_hull  = me->global[i].hull;
	    old_act_env   = me->global[i].hull_env;
	    status = om$send(msg = message SMmgr.SMChgState
			     (SM_ACT,~SM_ACT),
			     targetid = me->global[i].glob.objid,
			     targetos = me->global[i].glob.osnum);
	    as$status(); 
	  }
       }
  
  if(old_act_hull.objid != NULL_OBJID &&
     (old_act_hull.objid != me->act_glob.hull.objid ||
      old_act_hull.osnum != me->act_glob.hull.osnum))
   {
     status= GRfindcontext(&msg,&me->act_glob.hull_env.md_env.matrix_type,
			   me->act_glob.hull_env.md_env.matrix,
			   &me->act_glob.hull_env.md_id.osnum,
			   &act_context);
     if(!(status & msg & 1)) act_context.objid = NULL_OBJID;
     
     status= GRfindcontext(&msg,&old_act_env.md_env.matrix_type,
			   old_act_env.md_env.matrix,
			   &old_act_env.md_id.osnum,
			   &old_act_context);
     if(!(status & msg & 1)) old_act_context.objid = NULL_OBJID;
     
     /* Called change of depandancy */
     if(!SMchange_hull(&me->act_glob.hull,&act_context,
		       &old_act_hull,&old_act_context))
      {
	printf("Error change depandancy from hull %d to hull %d\n",
	       me->act_glob.hull,old_act_hull);
	goto wrapup;
      }
   }
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
  
 wrapup:
  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;
}

/* ------------------ method put_attr_in_form -------------------- */
/* Put the global attributes of the ACrg in the form               */
/* It convert from internal unit to external one                   */
/* If def is TRUE put the attributes as default value too          */  

method put_attr_in_form(long *sts; IGRshort def)
{
  void         (*func_txt)(),(*func_db)();
  int          i,j;
  char         *side;
  IGRboolean   fore;
  static short db_gadgets[] = {G_LPP,G_BMO,G_DMO,G_LOA,G_DDE,G_SHE,G_KEE};
  
  if(def)  /* Put value and default value */
   {
     func_txt = SMVA_set_default_text;
     func_db  = SMVA_set_default_value;
   }
  else /* Put value only */
   {
     func_txt = SMVA_set_text;
     func_db  = SMVA_set_value;
   }
  
  /* Made some convertion */
  /* Warning: I Explicitly use order of the attributes here */
  j = 0;
  for( i= I_LPP; i <= I_KEE; i++)
   {
     if(me->ACrg[i].desc.value.att_exp != NO_VALUE)
      {
	SMConvDistIntExt( me->ACrg[i].desc.value.att_exp,
			 &me->ACrg[i].desc.value.att_exp,
			 me->ModuleInfo.md_id.osnum);
	(*func_db)(me->forms[0].form_ptr,1,db_gadgets[j],
		   me->ACrg[i].desc.value.att_exp);
      }
     else
       (*func_txt)(me->forms[0].form_ptr,1,db_gadgets[j],"");
     j++;
   }
  
  /* Put aft and starboard as default value */
  fore = FALSE;
  side = "starboard";
  if(strcmp(me->ACrg[I_DIR].desc.value.att_txt,"fore") == 0)
   {fore = TRUE; side = "portside";}
  
  FIg_set_state(me->forms[0].form_ptr,G_DIR,fore);
  FIg_set_text(me->forms[0].form_ptr,G_SIDE,side);
  if(def)
   {
     FIg_set_default_value(me->forms[0].form_ptr,G_DIR,fore);
     FIfld_set_default_text(me->forms[0].form_ptr,G_SIDE,0,0,side,0);
   }
  
  if(me->act_glob.glob.osnum != me->ModuleInfo.md_id.osnum)
    SMVA_disable(me->forms[0].form_ptr,2,FI_ACCEPT,FI_EXECUTE);
  else
    SMVA_enable(me->forms[0].form_ptr,2,FI_ACCEPT,FI_EXECUTE);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}


/* ------------------- method select_hull_list ----------------------------  */
/*         Method called when user select hull list                          */
/*       It assign the me->act_glob with the selected hull                   */
/* It call function to display parameters of the selected hull in the form   */

method select_hull_list(long *sts)
{
  IGRchar active_name[ATTR_TXT];
  int     i,sel_flag,r_pos;
  IGRlong status,msg;

  /* Found which hull is selected */
  FIfld_get_text(me->forms[0].form_ptr,G_HULL_LIST,0,0,
		 ATTR_TXT,(unsigned char*)active_name,&sel_flag,&r_pos);
  active_name[ATTR_TXT -1] = '\0';
  
  /* No change of name, do nothing */
  if(strcmp(active_name,me->act_glob.name) == 0)
    goto quit;
  
  for(i = 0; i < me->nb_hull; i++)  
    if(strcmp(active_name,me->global[i].name) == 0)
     {
       /* Dehilite old active global hull */
       if(me->act_glob.hull.objid != NULL_OBJID)
	 dp$display(msg = &msg, oids = &me->act_glob.hull, mode = GRhe);
       me->act_glob.glob     = me->global[i].glob;
       me->act_glob.hull     = me->global[i].hull;
       me->act_glob.hull_env = me->global[i].hull_env;
       strcpy(me->act_glob.name,me->global[i].name);
       init_glob_attr(me->ACrg);

       if(me->act_glob.glob.objid != NULL_OBJID)/* Global data exists for hull */
	{
	  status = om$send(msg = message SMglob.SMGetAtt
			   (&msg,NB_GLOB_ATTRIB,me->ACrg,NULL),
			   targetid = me->act_glob.glob.objid,
			   targetos = me->act_glob.glob.osnum);
	  as$status(sts = (status & msg),action = RET_STATUS);

	  om$send(msg = message SMCmdGlob.put_attr_in_form(sts,FALSE),
		  targetid = my_id);
	}
      
       if(me->act_glob.glob.osnum != me->ModuleInfo.md_id.osnum)
	 SMVA_disable(me->forms[0].form_ptr,2,FI_ACCEPT,FI_EXECUTE);
       else
	 SMVA_enable(me->forms[0].form_ptr,2,FI_ACCEPT,FI_EXECUTE); 
     }

  if(me->act_glob.hull.objid != NULL_OBJID)
    dp$display(msg = &msg, oids = &me->act_glob.hull, mode = GRhhd);
   
 quit:
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

end implementation SMCmdGlob;


