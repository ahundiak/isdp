/* $Id: SMTrCrBkNtf.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / SMTrCrBkNtf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMTrCrBkNtf.I,v $
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

 /*               SMTrCrBkNtf.I                    */
 /*   Methods  and functions for SMTrCrgtBk        */ 
 /*   Methods for the CO                           */
 /*   Pascale Lacroix  (ISDC)			   */
 /*   Creation date July-92                        */
  
class implementation SMCmdTrCrBk;
  
 
 
#define AS_DEBUG	1
 
#define LOAD_PT		519

 
 
 extern GRclassid 	OPP_SMTrCrgtBk_class_id,OPP_SMcoll_class_id,
			OPP_SMframe_class_id;
 
 from ACrg_collect	import	ACadd_list_attribute,ACget_named_attribute;
 from GRgraphics	import GRdelete,GRdisplay;
 from NDnode		import NDchange_connect,NDchg_state, NDget_objects;
 from ASnode		import ASreturn_go;
 from GRvg		import GRputsymb, GRputname;
 from ACncpx		import ACmplace;
 
/* ----------------------------------------------------------------- */
/*
/* hilite the located objects 
/*
/**/


method DispAll(enum GRdpmode mode)
{
int                     stat;
long			msg;
struct GRid             currentModule ;
struct GRlc_info        obj;


ex$get_cur_mod( id      = &currentModule.objid,
                osnum   = &currentModule.osnum ) ;

stat = om$send(msg = message SMCmdSurf.DispAll(mode),
			 		targetid = my_id,
					mode = OM_e_wrt_message);
if(!(stat & 1)) printf("ERROR  hilite the cs\n");

if(me->point.obj_id.objid != NULL_OBJID){

        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->point.obj_id.objid,
                        targetos = me->point.obj_id.osnum );

        stat = om$send(msg     = message GRgraphics.GRdisplay(
                                &msg,
                                &obj.module_info.md_env.matrix_type,
                                obj.module_info.md_env.matrix,
                                &mode,
                                &currentModule ),
                targetid= obj.located_obj.objid,
                targetos= obj.located_obj.osnum ) ;
	as$status(sts = stat);
}

return OM_S_SUCCESS;

}

/* ----------------------------------------------------------------- */
/*
/* verify about the deleted object
/*
/**/


method verify_obj(long *sts)
{

 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdSurf.verify_obj(sts),
			 		targetid = my_id,
					mode = OM_e_wrt_message);
 if(me->point.obj_id.objid != NULL_OBJID &&
        ! ( om$is_objid_valid( osnum = me->point.obj_id.osnum,
                               objid = me->point.obj_id.objid)&1) ){
	ex$message(msgnumb = SM_E_ErPtDel);
        me->state = _terminate;
        return OM_S_SUCCESS;
 }
return OM_S_SUCCESS;

}


/* ----------------------------------------------------------------- */ 
/*
/* store the located object in instance 
/*
/**/
 
method store_point(long *sts)
{
 int		status;

 *sts = OM_S_SUCCESS;

  me->point.obj_id = me->event1.located_object[0].located_obj;
  status = as$make_source(go_grid = me->point.obj_id,
                          mod_env = &me->event1.located_object[0].module_info,
                          as_os   = me->ModuleInfo.md_id.osnum,
                          as_grid = &me->point.obj_id);
  as$status(action = RET_STATUS);
  me->point.mod_env = me->event1.located_object[0].module_info;



 return OM_S_SUCCESS;
}


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
 long			msg, test;
 struct GRid		*roots;
 struct ACrg_coll	attr;

 *sts = OM_S_SUCCESS;

 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
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

 /* Get the point */

  stat = GetEnvFrObj( &roots[2], &me->point.mod_env, NULL);
  if(!(stat & 1)){
  		printf("ERROR GetEnvFrObj \n");         
  		*sts = OM_E_ABORT;
 		goto wrapup;
  }

 me->point.obj_id = roots[2];

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
 
 /* Get the y_axis */
 strcpy(attr.name,"y_axis");

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
 me->y_axis = attr.desc.value.att_txt[0];

 /* Get the period */

 strcpy(attr.name,"period");
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
 me->period = attr.desc.value.att_exp;
 SMConvDistIntExt(me->period, &me->period, me->ModuleInfo.md_id.osnum);

 /* Get the hight */

 strcpy(attr.name,"hight");
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
 me->hight = attr.desc.value.att_exp;
 SMConvDistIntExt(me->hight, &me->hight, me->ModuleInfo.md_id.osnum);

 /* Get the len1 */

 strcpy(attr.name,"len1");
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
 me->len1 = attr.desc.value.att_exp;
 SMConvDistIntExt(me->len1, &me->len1, me->ModuleInfo.md_id.osnum);

 /* Get the len2 */

 strcpy(attr.name,"len2");
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
 me->len2 = attr.desc.value.att_exp;
 SMConvDistIntExt(me->len2, &me->len2, me->ModuleInfo.md_id.osnum);

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

 /* Get the ext_z1 */

 strcpy(attr.name,"ext_z1");
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
 me->ext_z1 = attr.desc.value.att_exp;
 SMConvDistIntExt(me->ext_z1, &me->ext_z1, me->ModuleInfo.md_id.osnum);

 /* Get the ext_z2 */

 strcpy(attr.name,"ext_z2");
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
 me->ext_z2 = attr.desc.value.att_exp;
 SMConvDistIntExt(me->ext_z2, &me->ext_z2, me->ModuleInfo.md_id.osnum);


 vd$get_name(name = me->def_name, obj = &me->macro_id);


 if(me->mytype == MODIFY) {
 		strcpy(me->old_def_name,me->def_name);
 		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->old_def_name);
 		me->old_macro_id = me->macro_id;
 		me->old_coord = me->coord;
 		me->old_point = me->point;
 		me->old_dir_axis = me->dir_axis;
 		me->old_y_axis = me->y_axis;
 		me->old_hight = me->hight;
 		me->old_len1 = me->len1;
 		me->old_len2 = me->len2;
 		me->old_period = me->period;
 		me->old_extension = me->extension;
 		me->old_ext_z1 = me->ext_z1;
 		me->old_ext_z2 = me->ext_z2;
 		me->old_ext_y1 = me->ext_y1;
 		me->old_ext_y2 = me->ext_y2;
 		me->old_reverse = me->reverse;
 }
 else {
 	(void)GetDefName("SMTrCrgtBk_0",me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 }

 vd$get_name(name = name, obj = &me->coord);
 if(name[0] == '\0') {
  	/* try get name on the graphic object */
  	vd$get_name(name = name, obj = &me->go_cs );
 	if(name[0] == '\0') strcpy(name, "defined");  
 }
 FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
 
 sprintf(name,"%g",me->hight);
 FIg_set_text(me->forms[0].form_ptr,HIGHT ,name);

 sprintf(name,"%g",me->len1);
 FIg_set_text(me->forms[0].form_ptr,LEN1 ,name);

 sprintf(name,"%g",me->len2);
 FIg_set_text(me->forms[0].form_ptr,LEN2 ,name);

 sprintf(name,"%g",me->period);
 FIg_set_text(me->forms[0].form_ptr,PERIOD ,name);

 if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"hull range +10%");
 else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"bounded by hull");
 else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"User Extend");

 if(me->extension == 2){ 
     		om$send(msg = message SMCmdTrCrBk.GadgOn(&test),
			 	targetid = my_id);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_y1,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_y2,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_Z1,0,0,me->ext_z1,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_Z2,0,0,me->ext_z2,FALSE);
 }
 else 
     		om$send(msg = message SMCmdTrCrBk.GadgOf(&test),
			 	targetid = my_id);

 if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
 else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 om$send(msg = message  SMCmdTrCrBk.DispAll(GRhhd),
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
 char		name[MAX_CHAR];
 long		msg, test;
  
 *sts = OM_S_SUCCESS;
 dp$erase_hilite(msg = &msg);

 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");

 if(me->mytype != MODIFY) {
	/* get active ship cs */

	me->coord.objid = NULL_OBJID;
	me->go_cs.objid = NULL_OBJID;

        name[0] = '\0';
        if(SMGetDefCs(TRUE,(struct GRid *)NULL,(IGRshort *)NULL,&me->go_cs,
               &me->coord,&me->cs_env,(IGRboolean *)NULL)
                && me->coord.objid != NULL_OBJID){
                vd$get_name(name = name, obj = &me->coord);
                if(name[0] == '\0') {
                        /* try get name on the graphic object */
                        vd$get_name(name = name, obj = &me->go_cs);
                        if(name[0] == '\0') strcpy(name, "defined");
                }
        }
	FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
		
 	me->point.obj_id.objid = NULL_OBJID;
 	me->dir_axis = 'z';
 	me->y_axis = 'y';
 	me->hight = 0.;
 	me->len1 = 0.;
 	me->len2 = 0.;
 	me->period = 0;
 	me->extension = 0;
 	me->ext_z1 = 0.;
 	me->ext_z2 = 0.;
 	me->ext_y1 = 0.;
 	me->ext_y2 = 0.;
	me->def_name[0] = '\0';
	me->reverse = 0;

	(void)GetDefName("SMTrCrgtBk_0",me->def_name);
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 }
 else {

 	me->macro_id = me->old_macro_id ;
 	me->point = me->old_point ;
 	me->coord = me->old_coord ;
   	if( !(GetEnvFrObj( &me->coord, &me->cs_env, &me->go_cs) & 1)){
   		printf("ERROR GetEnvFrObj\n ");
		return OM_E_ABORT;
   	}
 	me->dir_axis = me->old_dir_axis ;
 	me->y_axis = me->old_y_axis;
 	me->hight = me->old_hight;
 	me->len1 = me->old_len1;
 	me->len2 = me->old_len2;
 	me->period = me->old_period;
 	me->extension = me->old_extension;
 	me->ext_z1 = me->old_ext_z1;
 	me->ext_z2 = me->old_ext_z2;
 	me->ext_y1 = me->old_ext_y1;
 	me->ext_y2 = me->old_ext_y2;
	me->reverse = me->old_reverse;
	strcpy(me->def_name, me->old_def_name);
  	vd$get_name(name = name, obj = &me->coord);
 	if(name[0] == '\0') {
  		/* try get name on the graphic object */
  		vd$get_name(name = name, obj = &me->go_cs );
 		if(name[0] == '\0') strcpy(name, "defined");  
 	}
 	FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
 		
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
		
	
 }
 
 sprintf(name,"%g",me->hight);
 FIg_set_text(me->forms[0].form_ptr,HIGHT ,name);

 sprintf(name,"%g",me->period);
 FIg_set_text(me->forms[0].form_ptr,PERIOD ,name);

 sprintf(name,"%g",me->len1);
 FIg_set_text(me->forms[0].form_ptr,LEN1 ,name);

 sprintf(name,"%g",me->len2);
 FIg_set_text(me->forms[0].form_ptr,LEN2 ,name);

 if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"hull range +10%");
 else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"bounded by hull");
 else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
 					"User Extend");

 if(me->extension == 2){ 
     		om$send(msg = message SMCmdTrCrBk.GadgOn(&test),
			 	targetid = my_id);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_y1,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_y2,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_Z1,0,0,me->ext_z1,FALSE);
 		FIfld_set_value(me->forms[0].form_ptr,EXT_Z2,0,0,me->ext_z2,FALSE);
 }
 else 
     		om$send(msg = message SMCmdTrCrBk.GadgOf(&test),
			 	targetid = my_id);

 if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
 else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
		
  if(me->mytype == MODIFY) om$send(msg = message  SMCmdTrCrBk.DispAll(GRhhd),
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
  long	test,msg;
  
 	
  	*sts = OM_S_SUCCESS;
  	dp$erase_hilite(msg = &msg);




 	me->dir_axis = 'z';
 	me->y_axis = 'y';
 	me->hight = 0.;
 	me->period = 0;
 	me->extension = 0;
 	me->len1 = 0.;
 	me->len2 = 0.;
 	me->ext_z1 = 0.;
 	me->ext_z2 = 0.;
	
 	me->ext_y1 = 0.;
 	me->ext_y2 = 0.;
	me->def_name[0] = '\0';
	me->reverse = 0;

  	FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
 	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,"");
  	FIg_set_text(me->forms[0].form_ptr,PERIOD,"");
  	FIg_set_text(me->forms[0].form_ptr,HIGHT,"");
  	FIg_set_text(me->forms[0].form_ptr,LEN1,"");
  	FIg_set_text(me->forms[0].form_ptr,LEN2,"");
  	FIg_set_text(me->forms[0].form_ptr,CS_NAME,"");
	if(me->mytype == MODIFY) FIg_erase(me->forms[0].form_ptr, LOAD);

     	om$send(msg = message SMCmdTrCrBk.GadgOf(&test),
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
 int 			nb_roots, nb_att, stat;
 char 			text[MAX_CHAR];
 long			sizebuf, nret, test, msg;
 struct GRid 		mac, roots[3];
 struct GRsymbology	symb;
 struct ACrg_coll	ACrg[12];
 IGRdouble		ext_z1, ext_z2,  ext_y1, ext_y2, period, hight, len1, 
			len2;
			
 *sts = OM_S_SUCCESS;

 nb_roots = 3;
 nb_att = 12;  	

 FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"");
 
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

 stat = om$send(msg = message SMCmdSurf.GetInfoFrmForm(&test, &ext_y1, &ext_y2,
					&ext_z1, &ext_z2),
			 	targetid = my_id);

 as$status(sts = stat);
 if(!(stat & test & 1)){
     	printf("ERROR  SMCmdSurf.GetInfoFrmForm\n"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }

 if(me->point.obj_id.objid == NULL_OBJID){
		ex$message( msgnumb = SM_S_ErPtNtDf);
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"ERROR, point not defined");
		*sts =  OM_E_ABORT; 
		goto quit;
 }


 FIg_get_text(me->forms[0].form_ptr,PERIOD, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->period);
 else me->period = 0.;

 SMConvDistExtInt(me->period, &period, me->ModuleInfo.md_id.osnum);


 FIg_get_text(me->forms[0].form_ptr,HIGHT, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->hight);
 else me->hight = 0.;
 SMConvDistExtInt(me->hight, &hight, me->ModuleInfo.md_id.osnum);

 FIg_get_text(me->forms[0].form_ptr,LEN1, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->len1);
 else me->len1 = 0.;


 SMConvDistExtInt(me->len1, &len1, me->ModuleInfo.md_id.osnum);
 if(me->len1 < 1e-6 ){
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Invalid len1");
		ex$message(msgnumb = SM_S_LenPos);
		*sts =  OM_E_ABORT; 
		goto quit;
 }

 FIg_get_text(me->forms[0].form_ptr,LEN2, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->len2);
 else me->len2 = 0.;


 SMConvDistExtInt(me->len2, &len2, me->ModuleInfo.md_id.osnum);

 if(me->len2 < 1e-6 ){
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Invalid len2");
		ex$message( msgnumb = SM_S_LenPos);
		*sts =  OM_E_ABORT; 
		goto quit;
 }

 if(me->period < 1e-6 || 
		(me->period < me->len1 || me->period < me->len2)){
  		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Invalid period");
		ex$message(msgnumb = SM_S_InvPrd);
		*sts =  OM_E_ABORT; 
		goto quit;
 }
 /* place the macro */

 if(me->mytype == PLACE){ 
  		mac.objid = NULL_OBJID;
  		mac.osnum = me->ModuleInfo.md_id.osnum;
 
  		stat = om$construct(classid = OPP_SMTrCrgtBk_class_id,
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

 stat = as$make_source(
     				go_grid = me->point.obj_id,
			     	mod_env = &me->point.mod_env,
			     	as_os   = me->ModuleInfo.md_id.osnum,
			     	as_grid = &roots[2]);
 as$status(sts = stat);
 if(!(stat & 1)){
 		printf("ERROR as$make_source\n");
 		*sts = OM_E_ABORT;
 		goto quit;
 } 

 /* Construct the ACrg_collect */

 strcpy(ACrg[0].name,"dir_axis");
 ACrg[0].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[0].desc.value.att_txt,&me->dir_axis,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[1].name,"y_axis");
 ACrg[1].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[1].desc.value.att_txt,&me->y_axis,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[2].name,"hight");
 ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[2].desc.value.att_exp = hight;

 strcpy(ACrg[3].name,"period");
 ACrg[3].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[3].desc.value.att_exp = period;

 strcpy(ACrg[4].name,"len1");
 ACrg[4].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[4].desc.value.att_exp = len1;

 strcpy(ACrg[5].name,"len2");
 ACrg[5].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[5].desc.value.att_exp = len2;

 strcpy(ACrg[6].name,"extension");
 ACrg[6].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[6].desc.value.att_exp = (IGRdouble) me->extension;

 strcpy(ACrg[7].name,"reverse");
 ACrg[7].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[7].desc.value.att_exp = (IGRdouble) me->reverse;

 strcpy(ACrg[8].name,"ext_y1");
 ACrg[8].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[8].desc.value.att_exp = ext_y1;

 strcpy(ACrg[9].name,"ext_y2");
 ACrg[9].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[9].desc.value.att_exp = ext_y2;

 strcpy(ACrg[10].name,"ext_z1");
 ACrg[10].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[10].desc.value.att_exp = ext_z1;

 strcpy(ACrg[11].name,"ext_z2");
 ACrg[11].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[11].desc.value.att_exp = ext_z2;


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
                   (&msg,12,ACrg),
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
                    			"SMTrCrgtBk",nb_roots, roots,&me->ModuleInfo),
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

		stat = om$send(msg = message SMCmdTrCrBk.SMmodif_mac
						(nb_att, ACrg, nb_roots, roots),
			 		targetid = my_id);
 		if(!(stat & 1)){
 				printf("ERROR  SMCmdTrCrBk.SMmodif_mac\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
 		}

 }



 

quit:
 if(!(*sts&1)){
 	if(me->mytype == MODIFY) {ex$message( msgnumb = SM_S_ModFail);}
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
 		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Modify Successfull");
		ex$message(msgnumb = SM_S_ModSucc);
 		strcpy(me->old_def_name,me->def_name);
 		me->old_macro_id = me->macro_id;
 		me->old_coord = me->coord;
 		me->old_point = me->point;
 		me->old_dir_axis = me->dir_axis;
 		me->old_y_axis = me->y_axis;
 		me->old_hight = me->hight;
 		me->old_len1 = me->len1;
 		me->old_len2 = me->len2;
 		me->old_period = me->period;
 		me->old_extension = me->extension;
 		me->old_ext_z1 = me->ext_z1;
 		me->old_ext_z2 = me->ext_z2;
 		me->old_ext_y1 = me->ext_y1;
 		me->old_ext_y2 = me->ext_y2;
 		me->old_reverse = me->reverse;
 	}
 	else 	{
 		FIg_set_text(me->forms[0].form_ptr,MESSAGE_FIELD,"Place Successfull");
		ex$message(msgnumb = SM_S_PlSucc);
  		(void)GetDefName("SMTrCrgtBk_0",me->def_name);
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


 if(me->point.obj_id.objid != me->old_point.obj_id.objid ||
 	me->point.obj_id.osnum != me->old_point.obj_id.osnum){

 	put_batch = TRUE;
 	stat = om$send(msg = message NDnode.NDchange_connect
		      (1, &old_roots[2], &new[2]),
                   		senderid = NULL_OBJID,
                   		targetid = me->macro_id.objid,
                   		targetos = me->macro_id.osnum );
  	as$status(sts = stat);
  	if(!(stat & 1)){
		printf("Erreur NDnode.NDchange_connect\n");
		return OM_E_ABORT;
  	}
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

end implementation SMCmdTrCrBk;



