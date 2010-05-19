/* $Id: SMCcCmbrNtf.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / SMCcCmbrNtf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCcCmbrNtf.I,v $
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

 /*               SMCcCmbrNtf.I                    */
 /*   Methods  and functions for SMCcCamber        */ 
 /*   Methods for the CO                           */
 /*   Pascale Lacroix  (ISDC)			   */
 /*   Creation date July-92                        */
  
class implementation SMCmdCcCmbr;
  
#define AS_DEBUG	1
 
extern GRclassid 	OPP_SMCcCamber_class_id,OPP_SMcoll_class_id;
 
from ACrg_collect	import	ACadd_list_attribute,ACget_named_attribute;
from GRgraphics		import GRdelete;
from NDnode		import NDchg_state, NDget_objects;
from GRvg		import GRputsymb, GRputname;
from ACncpx		import ACmplace;




/* ----------------------------------------------------------------- */ 
/*
/* store the located occurence of the macro (for modify or locate from
/* occurence) and fill the info in the form
/*
/**/

 
method store_occ(long *sts)
{
 int			stat, count;
 char			name[MAX_CHAR];
 long			test, msg;
 struct GRid		*roots;
 struct ACrg_coll	attr;

 *sts = OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 dp$erase_hilite(msg = &msg);
 roots = NULL;
 	
 me->macro_id = me->event1.located_object[0].located_obj;

 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&roots,0,OM_K_MAXINT,&count),
                   senderid = NULL_OBJID,
                   targetid = me->macro_id.objid,
                   targetos = me->macro_id.osnum );
 as$status(sts = stat);
 if(stat != OM_S_SUCCESS ){
 		printf("ERROR retrieve roots of the macro \n");         
 		*sts = OM_E_ABORT;
		goto wrapup;
 }

 /* Get the coord syst */

  stat = GetEnvFrObj( &roots[0], &me->cs_env, &me->go_cs);
  if(!(stat & 1)){
  		printf("ERROR GetEnvFrObj \n");         
  		*sts = OM_E_ABORT;
 		goto wrapup;
  }

 me->coord = roots[0];

 /* Get the dir_axis */

 strcpy(attr.name,"dir_axis");
 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)) {
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->dir_axis = attr.desc.value.att_txt[0];
 
 /* Get the rot_axis */
 strcpy(attr.name,"rot_axis");

 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->rot_axis = attr.desc.value.att_txt[0];

 /* Get the radius */

 strcpy(attr.name,"radius");
 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->radius = attr.desc.value.att_exp;
 SMConvDistIntExt(me->radius, &me->radius, me->ModuleInfo.md_id.osnum);

 /* Get the z_pos */

 strcpy(attr.name,"z_pos");
 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->z_pos = attr.desc.value.att_exp;
 SMConvDistIntExt(me->z_pos, &me->z_pos, me->ModuleInfo.md_id.osnum);

 /* Get the extension */

 strcpy(attr.name,"extension");
 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->extension = (int)attr.desc.value.att_exp;

 /* Get the reverse */

 strcpy(attr.name,"reverse");
 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->reverse = (int)attr.desc.value.att_exp;

 /* Get the ext_y1 */

 strcpy(attr.name,"ext_y1");
 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->ext_y1 = attr.desc.value.att_exp;
 SMConvDistIntExt(me->ext_y1, &me->ext_y1, me->ModuleInfo.md_id.osnum);

 /* Get the ext_y2 */

 strcpy(attr.name,"ext_y2");
 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->ext_y2 = attr.desc.value.att_exp;
 SMConvDistIntExt(me->ext_y2, &me->ext_y2, me->ModuleInfo.md_id.osnum);

 /* Get the ext_x1 */

 strcpy(attr.name,"ext_x1");
 stat= om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->ext_x1 = attr.desc.value.att_exp;
 SMConvDistIntExt(me->ext_x1, &me->ext_x1, me->ModuleInfo.md_id.osnum);

 /* Get the ext_x2 */

 strcpy(attr.name,"ext_x2");
 stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, &attr),
	                senderid = NULL_OBJID,
                        targetid= roots[1].objid,
                        targetos= roots[1].osnum);
 as$status(sts = stat);
 if(!(stat & msg & 1)){
 	printf("ERROR ACget_named_attribute\n");         
 	*sts = OM_E_ABORT;
	goto wrapup;
 }
 me->ext_x2 = attr.desc.value.att_exp;
 SMConvDistIntExt(me->ext_x2, &me->ext_x2, me->ModuleInfo.md_id.osnum);


 vd$get_name(name = me->def_name, obj = &(me->macro_id));


 if(me->mytype == MODIFY) {
 		strcpy(me->old_def_name,me->def_name);
 		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->old_def_name);
 		me->old_macro_id = me->macro_id;
 		me->old_coord = me->coord;
 		me->old_dir_axis = me->dir_axis;
 		me->old_rot_axis = me->rot_axis;
 		me->old_z_pos = me->z_pos;
 		me->old_radius = me->radius;
 		me->old_extension = me->extension;
 		me->old_ext_x1 = me->ext_x1;
 		me->old_ext_x2 = me->ext_x2;
 		me->old_ext_y1 = me->ext_y1;
 		me->old_ext_y2 = me->ext_y2;
 		me->old_reverse = me->reverse;
 }
 else {
 	(void)GetDefName("SMCcCamber_0",me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 }
 vd$get_name(name=name, obj=&(me->coord));
 if(name[0] == '\0') {
  	/* try get name on the graphic object */
  	vd$get_name(name = name, obj= &(me->go_cs) );
 	if(name[0] == '\0') strcpy(name, "defined");  
 }
 FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
 
 sprintf(name,"%g",me->z_pos);
 FIg_set_text(me->forms[0].form_ptr,CENTER ,name);

 if(me->radius != -1) sprintf(name,"%g",me->radius);
 else name[0] = '\0';
 FIg_set_text(me->forms[0].form_ptr,RADIUS ,name);
 if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"hull range +10%");
 else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"bounded by hull");
 else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"User Extend");

 if(me->extension == 2){ 
     		om$send(msg = message SMCmdCcCmbr.GadgOn(&test),
			 	targetid = my_id);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_Y1,0,0,me->ext_y1,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_Y2,0,0,me->ext_y2,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_x1,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_x2,FALSE);
 }
 else 
     		om$send(msg = message SMCmdCcCmbr.GadgOf(&test),
			 	targetid = my_id);

 if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
 else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 om$send(msg = message  SMCmdCcCmbr.DispAll(GRhhd),
                      targetid = my_id);

wrapup:
  return OM_S_SUCCESS;

} 

/* ----------------------------------------------------------------- */ 
/*
/* reinit all instances, reinit form, set all default prompts and 
/* template types of the macro 
/*
/**/
 
method reset_all(long *sts)
{
 long 		test;
 char		name[MAX_CHAR];
 long		msg;
  
 *sts = OM_S_SUCCESS;
 dp$erase_hilite(msg = &msg);

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");

 if(me->mytype != MODIFY) {
	/* get active ship cs */

	me->coord.objid = NULL_OBJID;
	me->go_cs.objid = NULL_OBJID;

        SMGetDefCs(TRUE,(struct GRid *)NULL,(IGRshort *)NULL,&me->go_cs,
               &me->coord,&me->cs_env,(IGRboolean *)NULL);

 	me->dir_axis = 'x';
 	me->rot_axis = 'z';
 	me->z_pos = 0.;
 	me->radius = -1;
 	me->extension = 0;
 	me->ext_x1 = 0.;
 	me->ext_x2 = 0.;
 	me->ext_y1 = 0.;
 	me->ext_y2 = 0.;
	me->def_name[0] = '\0';
	me->reverse = 0;

	(void)GetDefName("SMCcCamber_0",me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 }
 else {

 	me->macro_id = me->old_macro_id ;
 	me->coord = me->old_coord ;
   	if( !(GetEnvFrObj( &me->coord, &me->cs_env, &me->go_cs) & 1)){
   		printf("ERROR GetEnvFrObj \n");
		return OM_E_ABORT;
   	}
	
 	me->dir_axis = me->old_dir_axis ;
 	me->rot_axis = me->old_rot_axis;
 	me->z_pos = me->old_z_pos;
 	me->radius = me->old_radius;
 	me->extension = me->old_extension;
 	me->ext_x1 = me->old_ext_x1;
 	me->ext_x2 = me->old_ext_x2;
 	me->ext_y1 = me->old_ext_y1;
 	me->ext_y2 = me->old_ext_y2;
	me->reverse = me->old_reverse;
	strcpy(me->def_name, me->old_def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
		
	
 }
 name[0] = '\0';
 if(me->coord.objid != NULL_OBJID){
 	vd$get_name(name = name, obj = &(me->coord));
 	if(name[0] == '\0') {
		/* try get name on the graphic object */
		vd$get_name(name = name, obj = &(me->go_cs) );
		if(name[0] == '\0') strcpy(name, "defined");
 	}
 }
 FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
 sprintf(name,"%g",me->z_pos);
 FIg_set_text(me->forms[0].form_ptr,CENTER ,name);
 if(me->radius != -1) sprintf(name,"%g",me->radius);
 else name[0] = '\0';
 FIg_set_text(me->forms[0].form_ptr,RADIUS ,name);
 if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"hull range +10%");
 else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"bounded by hull");
 else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"User Extend");

 if(me->extension == 2){ 
     		om$send(msg = message SMCmdCcCmbr.GadgOn(&test),
			 	targetid = my_id);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_Y1,0,0,me->ext_y1,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_Y2,0,0,me->ext_y2,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_x1,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_x2,FALSE);
 }
 else 
     		om$send(msg = message SMCmdCcCmbr.GadgOf(&test),
			 	targetid = my_id);

 if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
 else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
		
 if(me->mytype == MODIFY) om$send(msg = message  SMCmdCcCmbr.DispAll(GRhhd),
                      			targetid = my_id);
  				
return OM_S_SUCCESS;

}



/* ----------------------------------------------------------------- */ 
/* 
/* Reset the Gadgets of the form and init instances
/*
/**/

method clear_form( long *sts )
{
  
  long	msg,test;
  
 	
  	*sts = OM_S_SUCCESS;
  	dp$erase_hilite(msg = &msg);


 	me->dir_axis = 'x';
 	me->rot_axis = 'z';
 	me->z_pos = 0.;
 	me->radius = -1;
 	me->extension = 0;
 	me->ext_x1 = 0.;
 	me->ext_x2 = 0.;
	
 	me->ext_y1 = 0.;
 	me->ext_y2 = 0.;
	me->def_name[0] = '\0';
	me->reverse = 0;

  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,"");
  	FIg_set_text(me->forms[0].form_ptr,RADIUS,"");
  	FIg_set_text(me->forms[0].form_ptr,CENTER,"");
  	FIg_set_text(me->forms[0].form_ptr,CS_NAME,"");
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,"");

	if(me->mytype == MODIFY) FIg_erase(me->forms[0].form_ptr, LOAD);

     	om$send(msg = message SMCmdCcCmbr.GadgOf(&test),
			 	targetid = my_id);
 	FIg_set_state_off(me->forms[0].form_ptr, ORIENT);

return OM_S_SUCCESS;
}

/* ----------------------------------------------------------------- */ 
/*
/* Get the info from the form to place or modify the macro
/* 
/**/
 
method save_all(long *sts )
{
 int 			nb_att, nb_roots, stat;
 char 			text[MAX_CHAR];
 long			test, sizebuf, nret, msg;
 struct GRid 		mac, roots[2];
 struct GRsymbology	symb;
 struct ACrg_coll	ACrg[10];
 IGRdouble		ext_x1, ext_x2, ext_y1, ext_y2, radius, z_pos;
  
 *sts = OM_S_SUCCESS;
  
 nb_roots = 2;	
 nb_att = 10;

 mac.objid = NULL_OBJID;
 mac.osnum = me->ModuleInfo.md_id.osnum;

 sizebuf = sizeof(struct IGRdisplay);
 gr$get_active_display(	msg    = &msg, 
			sizbuf = &sizebuf,
                        buffer = &symb.display_attr, 
			nret   = &nret);

 sizebuf = sizeof(IGRshort);
 gr$get_active_level(	msg     = &msg, 
			sizbuf  = &sizebuf,
                      	buffer  = &symb.level,   
			nret    = &nret);
 
  
 stat = om$send(msg = message SMCmdSurf.GetInfoFrmForm(&test, &ext_x1, &ext_x2,
					&ext_y1, &ext_y2),
			 	targetid = my_id);

 as$status(sts = stat);
 if(!(stat & test & 1)){
     	printf("ERROR  SMCmdSurf.GetInfoFrmForm\n"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }
 FIg_get_text(me->forms[0].form_ptr,RADIUS, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->radius);
 else me->radius = -1;

 if(me->radius < 1e-6){
		ex$message(msgnumb = SM_E_ErInvRad);
  		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Invalid radius");
		*sts =  OM_E_ABORT; 
		goto quit;

 }
 SMConvDistExtInt(me->radius, &radius, me->ModuleInfo.md_id.osnum);
	
 FIg_get_text(me->forms[0].form_ptr,CENTER, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->z_pos);
 else me->z_pos = 0.;

 SMConvDistExtInt(me->z_pos, &z_pos, me->ModuleInfo.md_id.osnum);

 /* place the macro */

 if(me->mytype == PLACE){ 
  	mac.objid = NULL_OBJID;
  	mac.osnum = me->ModuleInfo.md_id.osnum;
 
  	stat = om$construct(classid = OPP_SMCcCamber_class_id,
                           	osnum   = mac.osnum,
                           	p_objid = &mac.objid );
	as$status(sts = stat);
  	if(!(stat & 1)){
     		printf("erreur creating macro\n"); 
		*sts =  OM_E_ABORT; 
		goto quit;
  	}
  			
 }

 roots[0] = me->coord;

 /* Construct the ACrg_collect */

 strcpy(ACrg[0].name,"dir_axis");
 ACrg[0].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[0].desc.value.att_txt,&me->dir_axis,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[1].name,"rot_axis");
 ACrg[1].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[1].desc.value.att_txt,&me->rot_axis,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[2].name,"z_pos");
 ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[2].desc.value.att_exp = z_pos;

 strcpy(ACrg[3].name,"radius");
 ACrg[3].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[3].desc.value.att_exp = radius;

 strcpy(ACrg[4].name,"extension");
 ACrg[4].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[4].desc.value.att_exp = (IGRdouble) me->extension;

 strcpy(ACrg[5].name,"reverse");
 ACrg[5].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[5].desc.value.att_exp = (IGRdouble) me->reverse;

 strcpy(ACrg[6].name,"ext_y1");
 ACrg[6].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[6].desc.value.att_exp = ext_y1;

 strcpy(ACrg[7].name,"ext_y2");
 ACrg[7].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[7].desc.value.att_exp = ext_y2;

 strcpy(ACrg[8].name,"ext_x1");
 ACrg[8].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[8].desc.value.att_exp = ext_x1;

 strcpy(ACrg[9].name,"ext_x2");
 ACrg[9].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[9].desc.value.att_exp = ext_x2;


 if(me->mytype == PLACE){
  			 
  	roots[1].osnum = me->ModuleInfo.md_id.osnum;

  	stat = om$construct(	classid = OPP_SMcoll_class_id,
                        	osnum   = roots[1].osnum,
                        	p_objid = &roots[1].objid);
	as$status(sts = stat);
			if(!(stat&1)){
  			printf("ERROR creating ACrg_collect\n");
  			*sts =  OM_E_ABORT;
  			goto quit;
  	}
  	stat = om$send(msg = message NDnode.NDchg_state(
  						ND_DEL_NO_CH | ND_WAIT_DEL,
  						ND_DEL_NO_CH | ND_WAIT_DEL),

		   	targetid = roots[1].objid,
		   	targetos = roots[1].osnum);

	as$status(sts = stat);
  	if(!(stat & 1)){
			printf("ERROR NDnode.NDchg_state\n"); 
  			*sts =  OM_E_ABORT;
  			goto quit;
  	}
  	stat = om$send(msg = message ACrg_collect.ACadd_list_attribute
                   	(&msg,nb_att,ACrg),
                   	targetid = roots[1].objid,
                   	targetos = roots[1].osnum);
	as$status(sts = stat);
	if(!(stat&msg&1)){
  			printf("ERROR creating ACadd_list_attribute\n");
  			*sts =  OM_E_ABORT;
  			goto quit;
  	}
  		
     	stat = as$make_source(
     				go_grid = roots[1],
			     	mod_env = &me->ModuleInfo,
			     	as_os   = me->ModuleInfo.md_id.osnum,
			     	as_grid = &roots[1]);
     	as$status(sts = stat);
        if(!(stat & 1))
          	{ 
 			printf("ERROR as$make_source\n");
 			*sts = OM_E_ABORT;
 			goto quit;
          	} 
	/* place macro */
			
	stat = om$send(msg = message ACncpx.ACmplace
                   			((IGRint *)&msg,ACcant_place_sym,0,
                    			"SMCcCamber",nb_roots, roots,&me->ModuleInfo),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);


	as$status(sts = stat);
  	if(!(stat & msg & 1)){
        			printf("erreur place macro\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
  	}
			
	stat = om$send(msg = message GRvg.GRputname
                   			(&msg, me->def_name),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);

	as$status(sts = stat);
  	if(!(stat & msg & 1)){
        	printf("erreur GRvg.GRputname\n");
  		*sts =  OM_E_ABORT;
  		goto quit;
  	}
			
	/* put active symbology */
		
	stat = om$send(msg = message GRvg.GRputsymb
                   			(&msg, &symb),
				senderid = NULL_OBJID,
                   		targetid = mac.objid,
		      		targetos = mac.osnum);

	as$status(sts = stat);
  	if(!(stat & msg & 1)){
        	printf("erreur GRvg.GRputsymb\n");
  		*sts =  OM_E_ABORT;
  		goto quit;
  	}
 }
 else{
  			 
	/* modify macro */

	stat = om$send(msg = message SMCmdCcCmbr.SMmodif_mac
						(nb_att, ACrg, nb_roots, roots),
			 		targetid = my_id);
 	if(!(stat & 1)){
 		printf("ERROR  SMCmdCcCmbr.SMmodif_mac\n");
  		*sts =  OM_E_ABORT;
  		goto quit;
 	}

 }



 

quit:
 if(!(*sts&1)){
 	if(me->mytype == MODIFY) {
		ex$message(msgnumb = SM_S_ModFail);
	}
 	else 	{
 		if(mac.objid != NULL_OBJID){
 			stat = om$send(msg = message GRgraphics.GRdelete(&msg, &me->ModuleInfo),
 		             targetid = mac.objid,targetos = mac.osnum);
 			as$status(sts = stat);
 			if(!(stat&msg&1))printf("ERROR delete macro\n");
 			mac.objid = NULL_OBJID;
 		}
		ex$message(msgnumb = SM_S_PlFail);
 	}
  }
  else{
 	if(me->mytype == MODIFY){ 
 		strcpy(me->old_def_name,me->def_name);
 		me->old_macro_id = me->macro_id;
 		me->old_coord = me->coord;
 		me->old_dir_axis = me->dir_axis;
 		me->old_rot_axis = me->rot_axis;
 		me->old_z_pos = me->z_pos;
 		me->old_radius = me->radius;
 		me->old_extension = me->extension;
 		me->old_ext_x1 = me->ext_x1;
 		me->old_ext_x2 = me->ext_x2;
 		me->old_ext_y1 = me->ext_y1;
 		me->old_ext_y2 = me->ext_y2;
 		me->old_reverse = me->reverse;
 	   
 		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Modify Successfull");
		ex$message(msgnumb = SM_S_ModSucc);
 	}
 	else 	{
 		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Successfull");
		ex$message(msgnumb = SM_S_PlSucc);
  		(void)GetDefName("SMCcCamber_0",me->def_name);
  		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 	}
  }
  
  return OM_S_SUCCESS;
}


/* ----------------------------------------------------------------- */ 
/*
/* modify the macro
/* 
/**/

method SMmodif_mac(int nb_att; struct ACrg_coll *ACrg; int nb_new; struct GRid  *new)
{
 int			stat, cn_type,wait_batch, oldnb_roots;
 struct GRid 		*old_roots;
 IGRboolean		put_batch = FALSE;
 
 old_roots = NULL;
 oldnb_roots = 0;

 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&old_roots,0,OM_K_MAXINT,
					&oldnb_roots),
	senderid = NULL_OBJID,
	targetid = me->macro_id.objid,
	targetos = me->macro_id.osnum );
 as$status(sts = stat);
 if(stat != OM_S_SUCCESS ){
 	printf("ERROR retrieve roots of the macro \n");         
	return OM_E_ABORT;
 }

 stat = om$send(msg = message SMCmdSurf.SMMdCsAtt(&old_roots[0], &old_roots[1],
				nb_att, ACrg, nb_new, new, &put_batch),
			 	targetid = my_id,
				mode = OM_e_wrt_message);

 as$status(sts = stat);
 if(!(stat & 1)){
     	printf("ERROR  SMCmdSurf.SMMdCsAtt\n"); 
	return OM_E_ABORT; 
 }


 if(put_batch){

     	cn_type    = 1; /* recompute the object */
     	stat = nd$wait_batch(
     				type  = GR_GEOM_POSTED,
                            	l_object   = & me->macro_id,
                            	l_obj_info = &cn_type,
                            	nb_obj     = 1);

     	nd$mod_batch(	request = ND_INQ,
     			p_ret_mode = &wait_batch);

     	if(wait_batch == ND_DEFER) {
     		/* Nothing to do */
		return OM_E_ABORT;
	}
     	nd$exec_batch(mode = ND_DISP_ROOT|ND_DISP_BODY);
 }

return OM_S_SUCCESS ;
}

end implementation SMCmdCcCmbr;



