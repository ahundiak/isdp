/* $Id: SMStrSfNotif.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */
/* -------------------------------------------------------------------------
/* I/VDS
 *
 * File:	smstrsf/SMSfNotif.I
 *
 * Description:	
 *
 *	This file contains methods and functions for the SMCmdStrSf command
 *	object.
 *
 * Dependencies:
 *	VDCmdAttMgr	Management of the attributes in the form
 *	VDCmdPart	Management of the part selection in the form
 *
 * Revision History:
 *	$Log: SMStrSfNotif.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
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
# Revision 1.4  1996/01/23  06:38:58  pinnacle
# Replaced: smstrsf/cmd/SMStrSfNotif.I for:  by rgade for vds.240
#
# Revision 1.3  1996/01/19  05:51:42  pinnacle
# Replaced: smstrsf/cmd/SMStrSfNotif.I for:  by rgade for vds.240
#
# Revision 1.2  1995/09/25  22:53:34  pinnacle
# Replaced: smstrsf/cmd/SMStrSfNotif.I for:  by sundar for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	02/01/93	Jean Jasinczuk: 	Creation Date.
 *	05/01/94	P. Lacroix :	Subclass SMCmdStrSf from VDCmdAttMgr
 *			and VDCmdPart instead of SMCoDb that has been removed.
 *      01/19/96	Ravi		Default calculation flag set ON. 	
 * -------------------------------------------------------------------------
 */

class implementation SMCmdStrSf;

#define DEBUG          1
#define AS_DEBUG       1

#include "AS_status.h"

%safe
#include "VX_FIproto.h"
%endsafe

from ACdb_info import ACset_db_info;            
from NDmacro   import ACreturn_foot;            
from SMmgr     import SMGetShortName,SMGetAttDbl,SMGetAttTxt;
from SMMainSf  import SMcreate,SMGetParameters,SMModify;

extern GRclassid OPP_SMMainSf_class_id;
extern SMSetCalMnSfFlg(), SMGetCalMnSfFlg();




/*+mo
 -------------------------------------------------------------------------
  Overridden Message

	form_notification from CEO

  Abstract

 CEO.form_notification is called whenever a I/Forms form is given input     
 by the user.  It is analogous to super_cmd.form_input(); however, no input 
 is present in the "value" argument if the gadget type is a field.  See the 
 I/Forms Forms documentation about querying a form's gadgets to get their   
 values.                                                                    


  Arguments

  int    	form_label;  	label of form which received user  input 
  int    	gadget_label;   gadget label  which received user  input 
  double 	value;          value of gadget ( or field row # )       
  char 		* form_ptr ;    ptr to I/Forms form which received input 


 -------------------------------------------------------------------------
-mo*/

method form_notification (int form_label; int gadget_label ; double value ;
			  char * form_ptr)
{
  int         status = OM_S_SUCCESS;
  long	      sts;
  IGRboolean  CurCalFlg;
  int	      retval;

  if ( form_ptr == NULL ) return( OM_E_INVARG ); 
  
  FIg_set_text(form_ptr,FI_MSG_FIELD, "");
  /* set the calculation flag to ON if the  expression does't exist */
  retval = SMGetCalMnSfFlg(&CurCalFlg);  
  if ( retval == CALFLAG_NOTCREATED  )  SMSetCalMnSfFlg(1); 
  
  switch( gadget_label )
   {
   case G_SEARCH:
   case G_MINUS:
   case G_PLUS:  
   case G_RESET:
   case G_NUM_PART: 

     om$send(msg = message VDCmdPart.form_notification
	     (form_label, gadget_label,value,form_ptr),
	     targetid = my_id,
	     mode = OM_e_wrt_message);
     break;

   case FI_RESET :
   case FI_ACCEPT :
   case FI_CANCEL :
     om$send(msg = message VDS_LOCATE.form_notification
             (form_label, gadget_label,value,form_ptr),
             targetid = my_id,
             mode = OM_e_wrt_message);
     break;

   case FI_EXECUTE :
     status = om$send(msg = message SMCmdStrSf.save_all(&sts),
             targetid = my_id);

     FIg_set_state_off(me->forms[0].form_ptr,FI_EXECUTE);
     if( (me->mytype % 2) == 1 /* Means we are in modify command */
	&& sts == OM_S_SUCCESS)
       		_put_response(resp = RELOCATE_OBJ);

     break;

   case G_USER_ATT:
     /* Display form attributes for the surface */

     me->old_form_state = me->form_state;
     me->form_state = DYN_LIST;
     _put_response(resp = BEGIN_ATTR_FORM);
     goto quit;

   case G_STATIC_TOG:
     me->old_form_state = me->form_state;
     om$send(msg = message SMCmdStrSf.VDSelectTog(&sts),
	     targetid = my_id);
     break;

   case G_DEL_ATT:
   case G_ATT_LIST:
            om$send(msg = message VDCmdAttMgr.form_notification
             (form_label, gadget_label,value,form_ptr),
             targetid = my_id,
             mode = OM_e_wrt_message);

    break;

   case G_READ_PDU:
     _put_response(resp = READ_FROM_PDU);
     break;

   case G_DATA_SEL:
     me->old_form_state = me->form_state;
     me->form_state = DB_SELECT;
     _put_response(resp = BEGIN_DATA_SEL);
     break;

   case G_LOAD:
     _put_response(resp = LOAD_DATA_SEL);
     break;


   case G_NAME:
   case G_DESCRIP:	
     break;

/*
   case G_CALFLAG:
	FIg_get_state( form_ptr,G_CALFLAG, &flag );
        
   	SMGetCalMnSfFlg(&CurCalFlg);
        if( flag ) {
            if(CurCalFlg != TRUE) 
		SMSetCalMnSfFlg(1);
        }
        else
        {
            if(CurCalFlg == TRUE)
                SMSetCalMnSfFlg(0);
        }
        break;
*/

   case G_GEOM_INFO:
     /* Display form for geometry */
     me->old_form_state = me->form_state;
     me->form_state = GEOM_INFO;
     _put_response(resp = BEGIN_GEOM_FORM);
     break;
     
  
   case G_LOCATE_SURF:
     me->old_form_state = me->form_state;
     me->form_state = EMPTY_STATE;
     _put_response(resp = LOCATE_SURF);
     break;
   }
  
 quit: return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------
  Public Message init_form_new_surf

  Abstract
	
	It initialise the form for a new surface.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method init_form_new_surf( long *sts )
{
  int 	type;

  *sts = OM_S_SUCCESS;

  /* No surface defined */

  me->surf_id.objid  = NULL_OBJID;
  me->sel_surf.objid = NULL_OBJID;
  
   /* Copy attributes */

  memcpy(me->work_att,me->save_att, me->save_nb_att * sizeof(struct ACrg_coll));
  memcpy(me->work_att_type,me->save_att_type,me->save_nb_att* sizeof(IGRshort));
  me->work_nb_att =  me->save_nb_att;

  /* Put main parameters in form */ 

  om$send(msg = message SMCmdStrSf.put_surf_att_in_form(sts),
	  targetid = my_id);
  as$status(sts = (*sts),action = GOTO_VALUE,value = wrapup);
  
  /* Put user attribut in form */

  type = me->form_state == DYN_LIST ? 1 : 0;
  om$send(msg = message SMCmdStrSf.VDSetRgAtt(sts),
	     targetid = my_id);
  om$send(msg = message SMCmdStrSf.VDSetAttList(sts, type),
	     targetid = my_id);

  *sts = MSSUCC;
  return OM_S_SUCCESS;

 wrapup:

  *sts = OM_E_ABORT;
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message control_main_surf

  Abstract
	
	It displays all the parameters for the located surface and fills 
	the instances with the info.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method control_main_surf( long *sts )
{
  IGRlong             msg,status;
  struct GRid         as_surf;
  int                 i,j, type;
  static char *NeedAtt[] = {
    "name", "surftype", "descript", "density", "tightness", "consume", NULL};
  

  *sts = OM_S_SUCCESS;

  me->sel_surf.objid = NULL_OBJID;
  
  /* Get list of parameters */
  status = om$send( msg = message SMMainSf.SMGetParameters
		   (&msg,&me->save_nb_att,me->save_att,me->save_att_type,
		    &as_surf),
		   targetid = me->surf_id.objid,
		   targetos = me->surf_id.osnum);
  if(!(status & msg & 1))
   {printf("Error get parameters for surface id %d \n",me->surf_id.objid);
    goto wrapup;}

  /* Jean 18 August 93 */
  /* For static attributes, check if Needed (SM_STATIC_ATT) or not    */
  /* This is done because this info is lost for database attributes */
  for(i = 0; i < me->save_nb_att; i++)
   {
     j = 0;
     if(!(me->save_att_type[i] & SM_STATIC_ATT)) continue;
     while(NeedAtt[j])
     {
       if(!strcmp(NeedAtt[j],me->save_att[i].name))
        {me->save_att_type[i] = SM_STATIC_ATT | SM_SYST_ATT; break;}
       j++;
     }
     if(!NeedAtt[j]) /* attributes is user */
       me->save_att_type[i] = SM_STATIC_ATT | SM_USER_ATT;
   }

  /* Retrieve module env and graphical surface object */
  GetEnvFrObj(&as_surf,&me->surf_env,&me->sel_surf);

#ifdef JJ_DEBUG     
   print_all_attr(me->save_att,me->save_att_type,me->save_nb_att);
#endif

  /* Copy attributes */
  memcpy(me->work_att,me->save_att, me->save_nb_att * sizeof(struct ACrg_coll));
  memcpy(me->work_att_type,me->save_att_type,me->save_nb_att * sizeof(IGRshort));
  me->work_nb_att =  me->save_nb_att;
 
  /* Put main parameters in form */ 
  om$send(msg = message SMCmdStrSf.put_surf_att_in_form(sts),
	  targetid = my_id);
  
  /* Put user attribut in form */
   
  type = me->form_state == DYN_LIST ? 1 : 0;
  om$send(msg = message SMCmdStrSf.VDSetRgAtt(sts),
	     targetid = my_id);
  om$send(msg = message SMCmdStrSf.VDSetAttList(sts, type),
	     targetid = my_id);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;

 wrapup:
  *sts = OM_E_ABORT;
   return OM_S_SUCCESS;

} 


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	reset_all from VDS_LOCATE

  Abstract
	That method is called at the FI_RESET.
	It basically reset the form and the instances.

	It has been overriden in order to take into account the state of
	the form.
	
  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/


method reset_all( long *sts )
{
  *sts = OM_S_SUCCESS;

  if(me->form_state == DB_SELECT)
   {
     om$send(msg = message SMCmdStrSf.chg_state_select_db(sts,TRUE),
	     targetid = my_id);
     goto control_form;
   }

  switch(me->mytype)
   {
   case  PLACE:
     om$send(msg = message SMCmdStrSf.init_form_new_surf(sts),
	     targetid = my_id);
     if(!(*sts & 1)) return OM_S_SUCCESS;
     break;
   case MODIFY:
     om$send(msg = message SMCmdStrSf.control_main_surf(sts),
	     targetid = my_id);
     if(!(*sts & 1)) return OM_S_SUCCESS;
     break;
   }

 control_form:
  om$send(msg = message SMCmdStrSf.empty_form_state(sts),
	  targetid = my_id);
  om$send(msg = message SMCmdStrSf.control_form_state(sts),
	  targetid = my_id);

  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}


/*+mo
 -------------------------------------------------------------------------
  Overridden Message
	save_all from VDS_LOCATE

  Abstract
	That method is called at the FI_EXECUTE and FI_ACCEPT.

	At this level, it retrieves all the parameters in the form and
	call the appropriate place or modify method.
	
  Arguments
	long 		     *sts	O	Completion code

  Status/Return Code
      status == OM_S_SUCCESS   always

 -------------------------------------------------------------------------
-mo*/

method save_all( long *sts )
{
  IGRlong 	   msg,status;
  IGRlong 	   msgcode;   
  char 	  	   name_surf[ATTR_TXT],val_text[ATTR_TXT];
  char   	   my_msg[80];
  int     	   i,sel,pos,type,state;
  double  	   val_db;
  struct GRid 	   sel_surf;
  IGRshort 	   sm_type;
  
  static char *surf_attr[] = {"descript","tightness","density","surftype",NULL};
 
  static int num_gadget[] = {G_DESCRIP,G_TIGHTNESS,G_DENS,G_TYPE };
  
  *sts = OM_S_SUCCESS;

  msgcode = 0;

  /* Reinitialze me->surf_id in case of place */
  if(me->mytype == PLACE) me->surf_id.objid = NULL_OBJID;

  /* Verify we have at least one parent surface */
  if( me->sel_surf.objid == NULL_OBJID )
     { msgcode = SM_E_CmNoSurf; goto wrapup; }

  as$make_source(go_grid = me->sel_surf,
		 mod_env = &me->surf_env,
		 as_grid = &sel_surf);

  /* Retrieve Surface Name */
  name_surf[0] = '\0';
  FIfld_get_text(me->forms[0].form_ptr,G_NAME,0,0,ATTR_TXT,
		 (unsigned char *)name_surf,&sel,&pos); 
  name_surf[ATTR_TXT - 1] = '\0';
  if(name_surf[0] == '\0')  
   { msgcode = SM_E_CmSurfName; goto wrapup; }
  else
   {
     if(!SMCanChgElemName(&me->surf_id,name_surf))
      { msgcode = SM_E_CmNamEx; goto wrapup ; }
	
     SMSetAttr("name",me->work_att,me->work_att_type,&me->work_nb_att,
	      AC_ATTRIB_TEXT,0.0,name_surf,
	      SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
   }
  
  /* Retrieve surfaces attributes */
  i = 0;
  while(surf_attr[i])
   {
     /* Get type of attributes : if not exists don't set attributes */
     if(!SMGetAttr(surf_attr[i],me->save_att,me->save_att_type,me->save_nb_att,
		  &type,(IGRdouble *)NULL,(char *)NULL,&sm_type))
       continue;

     switch(type)
      {
      case  AC_ATTRIB_TEXT:
	val_text[0] = '\0';
	FIfld_get_text(me->forms[0].form_ptr,num_gadget[i],0,0,ATTR_TXT,
		       (unsigned char *)val_text,&sel,&pos);
	val_text[ATTR_TXT - 1] = '\0';
	SMSetAttr(surf_attr[i],me->work_att,me->work_att_type,&me->work_nb_att,
		 AC_ATTRIB_TEXT,0.0,val_text,sm_type,SM_MAX_CO_ATTR );
	break;
	
      case  AC_ATTRIB_DOUBLE:
	if(!SMget_double(me->forms[0].form_ptr,num_gadget[i],0,0,&val_db) ||
	   val_db < 0.0)
	  val_db = 0.0;
	
	SMSetAttr(surf_attr[i],me->work_att,me->work_att_type,&me->work_nb_att,
		 AC_ATTRIB_DOUBLE,val_db,(char *)NULL,sm_type,SM_MAX_CO_ATTR );
	break;
      }
     i++;
   }
  
  /* Jean : 28 July 93 Add consume */
  FIg_get_state(me->forms[0].form_ptr,G_CONSUME,&state);
  SMSetAttr("consume",me->work_att,me->work_att_type,&me->work_nb_att,
	    AC_ATTRIB_DOUBLE,(double)state,
	    (char *)NULL,SM_DYNAMIC_ATT | SM_SYST_ATT,SM_MAX_CO_ATTR );
    

  /* Get all user attributes */

  if(me->form_state == DYN_LIST)
   {
     om$send(msg = message SMCmdStrSf.VDSaveListDyn(sts, my_msg),
	     targetid = my_id);
     if(!(*sts & 1)) {
	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,my_msg);
	goto wrapup;
     }
   }
 
#ifdef JJ_DEBUG
     print_all_attr(me->work_att,me->work_att_type,me->work_nb_att);
#endif  
  switch(me->mytype)
   {
   case PLACE: 

     me->surf_id.osnum = me->ModuleInfo.md_id.osnum;
     status = om$construct(classid = OPP_SMMainSf_class_id,
			   osnum   = me->surf_id.osnum,
			   p_objid = &me->surf_id.objid );
     if(!(status & 1))
      {printf("erreur creating macro\n"); goto wrapup; }

     status = om$send( msg = message SMMainSf.SMcreate
		      (&msg,
		       me->work_nb_att,me->work_att,me->work_att_type,
		       &sel_surf),
		      targetid = me->surf_id.objid,
		      targetos = me->surf_id.osnum);
     if (!(status & msg & 1))
      { msgcode = SM_E_CmBadSurfPl; goto wrapup; }

     /* Display geom info after placing surface */
     me->old_form_state = me->form_state;
     me->form_state     =  GEOM_INFO; 
     om$send(msg = message SMCmdStrSf.control_form_state(sts),targetid = my_id);
     om$send(msg = message SMCmdStrSf.put_geom_info(sts),targetid = my_id);

     status = om$send(msg = message ACdb_info.ACset_db_info(&msg,&me->db_info),
		      targetid = me->surf_id.objid,
		      targetos = me->surf_id.osnum);
     as$status(sts = (status & msg));

     strcpy(me->old_name,name_surf); /* Save preceding name to increment */
     break;
     
   case MODIFY: 
     status = om$send( msg = message SMMainSf.SMModify
		      (&msg,
		       me->work_nb_att,me->work_att,me->work_att_type,
		       &sel_surf),
		      targetid = me->surf_id.objid,
		      targetos = me->surf_id.osnum);
     if (!(status & msg & 1))
      { msgcode = SM_E_CmBadSurfMd; goto wrapup; }

     SMVA_set_default_text(me->forms[0].form_ptr,4,
			   G_NAME,"",
			   G_DESCRIP,"",
			   G_AREA,"",
			   G_DENS,""
			   );
     break;
   }

  /* Blank all value too */

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

/*+me
 -------------------------------------------------------------------------
  Public Message add_locate_surface

  Abstract
	
     Add surface(s) located by the users.
     The last selected surfaces becomes the current surface               .

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method add_locate_surface( long *sts )
{
  IGRlong           status,msg;
  struct GRid       old_surf;
 
  *sts = OM_S_SUCCESS;

  old_surf = me->sel_surf ;
  
  me->surf_env = me->event1.located_object[0].module_info;

  /* It can be a pretend */
  status = om$send(msg = message NDmacro.ACreturn_foot
		   (&msg,"",&me->sel_surf,NULL,NULL),
		   targetid = me->event1.located_object[0].located_obj.objid,
		   targetos = me->event1.located_object[0].located_obj.osnum);
  if(!(status & msg & 1))
    me->sel_surf = me->event1.located_object[0].located_obj;
    

  if(old_surf.objid != me->sel_surf.objid  ||
     old_surf.osnum != me->sel_surf.osnum)
    dp$display(msg = &msg, oids = &old_surf,mode = GRhe);  

  dp$display(msg = &msg,oids = &me->sel_surf,mode = GRhhd);
     
  *sts = MSSUCC;
  return OM_S_SUCCESS;
}


/*+me
 -------------------------------------------------------------------------
  Public Message put_surf_att_in_form

  Abstract
	Retrieve main parameters for a surface and display them in form.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method put_surf_att_in_form(long *sts)
{			   
  char        val_txt[ATTR_TXT];
  IGRdouble   val_db;
  int         i;
  IGRshort    sm_type;
  int         attr_type;

#define NB_COMP_TEXT_ATT 6

  static char *text_attr[] = {"name","descript","tightness","density",
				"surftype",NULL};
  static int text_gadget[] = {G_NAME,G_DESCRIP,G_TIGHTNESS,G_DENS,G_TYPE };

  *sts = OM_S_SUCCESS;

  /* Retrieve all attributes */
  i = 0;
  while(text_attr[i])
   {
     if(!SMGetAttr(text_attr[i],me->work_att,me->work_att_type,me->work_nb_att,
		   &attr_type,&val_db,val_txt,&sm_type))
      {
	val_txt[0] = '\0';
	attr_type = AC_ATTRIB_TEXT;
	sm_type = SM_USER_ATT | SM_DYNAMIC_ATT;
      }

     /* Attribute is tightness or surftype */
     if(strcmp(text_attr[i],"tightness") == 0 ||
	strcmp(text_attr[i],"surftype") == 0)
       SMput_alternate_gadget(me->forms[0].form_ptr,text_gadget[i],
			      sm_type,val_txt);
     else /* All other attributes */
      {
	if(i == 0  /* name attribut */ &&
	   me->mytype == PLACE         &&
	   (sm_type & SM_DYNAMIC_ATT) &&
	   me->old_name[0] != '\0'    &&
	   val_txt[0] == '\0') 
	  GetDefName(me->old_name,val_txt);

	if(attr_type == AC_ATTRIB_DOUBLE) sprintf(val_txt,"%-9.6g",val_db);
	
	SMVA_set_default_text(me->forms[0].form_ptr,1,text_gadget[i],val_txt); 
	if(sm_type & SM_STATIC_ATT)
	  FIfld_set_mode(me->forms[0].form_ptr,text_gadget[i],0,FI_REVIEW);
	else
	  FIfld_set_mode(me->forms[0].form_ptr,text_gadget[i],0,FI_APPEND);
      }
     i++;
   }

  /* Jean : 28-July-93 Set toggle consumme or not */
  if(!SMGetAttr("consume",me->work_att,me->work_att_type,me->work_nb_att,
		&attr_type,&val_db,(IGRchar *)NULL,&sm_type))
    val_db =0.0;

  FIg_set_state(me->forms[0].form_ptr,G_CONSUME,(int)val_db);
     

  /* Put geometric information in form */
  om$send(msg = message SMCmdStrSf.put_geom_info(sts),targetid = my_id);
  
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}

/*+me
 -------------------------------------------------------------------------
  Public Message put_geom_info

  Abstract
	Get all geometrical info from me->work_att and put them 
	in the form.

  Arguments
	long	*sts		O 	completion code.

  Status/Return Code
      status == OM_S_SUCCESS    always


 -------------------------------------------------------------------------
-me*/

method put_geom_info(long *sts)
{
  int        i;
  char       val_txt[ATTR_TXT];
  IGRdouble  val_db;
  IGRshort   sm_type;
  IGRlong    status,msg;

  static char *geom_attr[]   = {
    "area",
    "cog_x","cog_y","cog_z",
    "weight"};				  

  static int gadget_num[] = {
    G_AREA,
    G_COG_X,G_COG_Y,G_COG_Z,G_WEIGHT}; 
  
  *sts = OM_S_SUCCESS;

  for(i=0;i<5;i++)
   {
     sm_type = -1;

     if(me->surf_id.objid != NULL_OBJID)
      {
	/* Ask the main surface for its values */
	status = om$send(msg = message SMmgr.SMGetAttDbl
			 (&msg, geom_attr[i], &val_db,NULL), 
			 targetid = me->surf_id.objid,
			 targetos = me->surf_id.osnum);
	if(!(status & msg & 1)) {msg = MSFAIL;}
      }
     else msg = MSFAIL;
     
     if(msg & 1) /* A Value was retrieve : convert */
      {
	switch(i)
	 {
	 case 0:                        /* an area */
	   if(val_db <= 0.0) val_txt[0] = '\0';
	   else
	    {
	      SMConvSurfIntExt(val_db,&val_db,me->ModuleInfo.md_id.osnum);
	      sprintf(val_txt,"%-9.6g",val_db);
	    }
	   break;

	 case 1: case 2: case 3:         /* center of gravity */
	   SMConvDistIntExt(val_db,&val_db,me->ModuleInfo.md_id.osnum);
	   sprintf(val_txt,"%-9.6g",val_db);
	   break;
	 case 4:                       /* Weight */
	   sprintf(val_txt,"%-9.6g",val_db);
	   break;
	 }
      }
     else val_txt[0] = '\0';

     SMVA_set_default_text(me->forms[0].form_ptr,1,gadget_num[i],val_txt);
     if(sm_type != -1)
       if(sm_type & SM_STATIC_ATT)
	 FIfld_set_mode(me->forms[0].form_ptr,gadget_num[i],0,FI_REVIEW);
       else
	 FIfld_set_mode(me->forms[0].form_ptr,gadget_num[i],0,FI_APPEND);
   }
  *sts = OM_S_SUCCESS;
  return OM_S_SUCCESS;
}
   
/* ------------------- some debug functions --------------------------  */

#ifdef JJ_DEBUG
/* Method for debug : print an attribute */
static int print_attr(ACrg,sm_type)
struct ACrg_coll *ACrg;
IGRshort sm_type; 
{
  printf("Name <%s>",ACrg->name);
  
  switch((ACrg->desc).type)
   {
   case AC_ATTRIB_TEXT :
     printf(" value <%s> type <%x>\n",(ACrg->desc).value.att_txt, sm_type);
     break;
   case  AC_ATTRIB_DOUBLE :
     printf(" value <%lf> type <%x>\n",(ACrg->desc).value.att_exp,sm_type);
     break;
     default : printf(" value unknown\n");
   }
  return 1; 
}


/* print all attribute of a collection */
static int print_all_attr(ACrg,sm_type,nb_attr)
struct ACrg_coll *ACrg;
IGRshort *sm_type;
int nb_attr;
{
  int i;

  for(i=0;i<nb_attr;i++)
    print_attr(&ACrg[i],sm_type[i]);
  return 1;
}
 

#endif

end implementation SMCmdStrSf;






