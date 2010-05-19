/* $Id: SMPtCmbrNtf.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */
 
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/smsurf/cmd / SMPtCmbrNtf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: SMPtCmbrNtf.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *      Initial import to CVS
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
# Revision 1.2  1996/04/17  15:00:28  pinnacle
# Replaced: smframe/cmd/SMModNotif.I for:  by ksundar for vds.240
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

  /*               SMPtCmbrNtf.I                    */
  /*   Methods  and functions for SMPtCamber        */ 
  /*   Methods for the CO                           */
  /*   Pascale Lacroix  (ISDC)			    */
  /*   Creation date July-92                        */
   
  class implementation SMCmdPtCmbr;
   
  
 
#include "VDmem.h"  
  
  
#define AS_DEBUG	1
  
#define SLDEF	 	519
#define ERASE_F2	521
 
#define MAX_TEMP	2
#define MAX_PT		50
  
  
  extern GRclassid 	OPP_SMPtCamber_class_id,OPP_ACrg_collect_class_id,
			OPP_SMframe_class_id;
  
  from ACrg_collect	import	ACadd_list_attribute,ACget_named_attribute;
  from GRgraphics	import GRdelete;
  from NDnode		import NDchg_state,NDget_objects;
  from GRvg		import GRputsymb, GRputname;
  from ACncpx		import ACmplace;

 
 
 /* ----------------------------------------------------------------- */ 
  
 method FormOn(long *sts)
 {
  *sts = OM_S_SUCCESS;
 
  (void)SMVA_enable(me->forms[0].form_ptr,14, 	OCC_NAME,
						COORDINATE,
  						CS_NAME,
  						ORIENT,
  						SYMETRY,
  						PTDEF_B,
  						EXTENSION,
  						HIGHT,
  						EXT_X1,
  						EXT_X2,
  						FI_RESET,
  						FI_EXECUTE,
  						FI_ACCEPT,
  						LOAD);
  		
  return OM_S_SUCCESS;
  
 } 

 /* ----------------------------------------------------------------- */ 
  
 method FormOf(long *sts)
 {
  *sts = OM_S_SUCCESS;
 
  (void)SMVA_disable(me->forms[0].form_ptr,14, 	OCC_NAME,
						COORDINATE,
  						CS_NAME,
  						ORIENT,
  						SYMETRY,
  						PTDEF_B,
  						EXTENSION,
  						HIGHT,
  						EXT_X1,
  						EXT_X2,
  						FI_RESET,
  						FI_EXECUTE,
  						FI_ACCEPT,
  						LOAD);

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
  int			i, stat, count;
  char			name[MAX_CHAR];
  long			test,msg;
  struct GRid		*roots;
  struct ACrg_coll	attr;
 
  *sts = OM_S_SUCCESS;
 
  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
  dp$erase_hilite(msg = &msg);
  roots = NULL;
  _FREE(me->z_pos);
  _FREE(me->y_pos);
  	
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
  
  /* Get the z_axis */
  strcpy(attr.name,"z_axis");
 
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
  me->z_axis = attr.desc.value.att_txt[0];
 
 
  /* Get the symetry */
 
  strcpy(attr.name,"symetry");
  stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
 							&attr),
                         targetid= roots[1].objid,
                         targetos= roots[1].osnum);
  if(!(stat & msg & 1)) goto wrapup ;
  me->symetry = (int)attr.desc.value.att_exp;
 
 
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
 
  /* Get the nb_pt */
 
  strcpy(attr.name,"nb_pt");
  stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
 							&attr),
                         targetid= roots[1].objid,
                         targetos= roots[1].osnum);
  if(!(stat & msg & 1)) goto wrapup ;
  me->nb_pt = (int)attr.desc.value.att_exp;
 
  if(me->nb_pt == 0) {
	ex$message(msgnumb = SM_S_NoPosDef);
 	goto wrapup;
  }
  me->z_pos = _MALLOC(me->nb_pt,IGRdouble);
  if(me->z_pos == NULL){
 	printf("ERROR Bad Allocation\n");
 	goto wrapup; 
  }
  me->y_pos = _MALLOC(me->nb_pt,IGRdouble);
  if(me->y_pos == NULL){
 	printf("ERROR Bad Allocation\n");
 	goto wrapup; 
  }
 
  /* Get the z_pos and y_pos*/
  for(i=0;i<me->nb_pt;i++){
 	sprintf(attr.name,"%s%d","z_pos",i);
  	stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
 							&attr),
                         targetid= roots[1].objid,
                         targetos= roots[1].osnum);
  	if(!(stat & msg & 1)) goto wrapup ;
  	me->z_pos[i] = attr.desc.value.att_exp ;
 	SMConvDistIntExt(me->z_pos[i], &me->z_pos[i], me->ModuleInfo.md_id.osnum);
 
 	sprintf(attr.name,"%s%d","y_pos",i);
  	stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
 							&attr),
                         targetid= roots[1].objid,
                         targetos= roots[1].osnum);
  	if(!(stat & msg & 1)) goto wrapup ;
  	me->y_pos[i] = attr.desc.value.att_exp;
 	SMConvDistIntExt(me->y_pos[i], &me->y_pos[i], me->ModuleInfo.md_id.osnum);
 
  }
 
 vd$get_name( name = me->def_name, obj = &me->macro_id);
 
  if(me->mytype == MODIFY) {
  		strcpy(me->old_def_name,me->def_name);
  		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->old_def_name);
  		me->old_coord = me->coord;
 		me->old_macro_id = me->macro_id;
  		me->old_dir_axis = me->dir_axis;
  		me->old_z_axis = me->z_axis;
  		me->old_extension = me->extension;
  		me->old_symetry = me->symetry;
  		me->old_nb_pt = me->nb_pt;
  		me->old_ext_x1 = me->ext_x1;
  		me->old_ext_x2 = me->ext_x2;
  		me->old_reverse = me->reverse;
  		_FREE(me->old_z_pos);
  		_FREE(me->old_y_pos);
  		if(me->old_nb_pt == 0) {
 			ex$message(msgnumb = SM_S_NoPosDef);
 			goto wrapup;
  		}
  		me->old_z_pos = 
		   _MALLOC(me->old_nb_pt,IGRdouble);
  		if(me->old_z_pos == NULL){
 			printf("ERROR Bad Allocation\n");
 			goto wrapup; 
  		}
  		me->old_y_pos = 
		    _MALLOC(me->old_nb_pt,IGRdouble);
  		if(me->old_y_pos == NULL){
 			printf("ERROR Bad Allocation\n");
 			goto wrapup; 
  		}
 		for(i=0;i<me->old_nb_pt;i++){
 			me->old_z_pos[i] = me->z_pos[i] ;
 			me->old_y_pos[i] = me->y_pos[i] ;
 		}
  }
  else {
  	(void)GetDefName("SMPtCamber_0",me->def_name);
  	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  }
 
 vd$get_name( name = name, obj = &me->coord);
 if(name[0] == '\0') {
  	/* try get name on the graphic object */
  	vd$get_name( name = name,  obj = &me->go_cs );
 	if(name[0] == '\0') strcpy(name, "defined");  
 }
 FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
  

  if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"hull range +10%");
  else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"bounded by hull");
  else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"User Extend");
 
  FIfld_set_value(me->forms[0].form_ptr, HIGHT, 0, 0,
                                me->z_pos[0], FALSE);
  if(me->extension == 2){ 
      		om$send(msg = message SMCmdPtCmbr.GadgOn(&test),
 			 	targetid = my_id);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_x1,FALSE);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_x2,FALSE);
  }
  else 
      		om$send(msg = message SMCmdPtCmbr.GadgOf(&test),
 			 	targetid = my_id);
 
  if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
  else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);

  if(me->symetry) FIg_set_state_off(me->forms[0].form_ptr, SYMETRY);
  else FIg_set_state_on(me->forms[0].form_ptr, SYMETRY);
  om$send(msg = message  SMCmdPtCmbr.DispAll(GRhhd),
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
  int		i;
  char		name[MAX_CHAR];
  long		test,msg;
 
  *sts = OM_S_SUCCESS;
  dp$erase_hilite(msg = &msg);
 
  FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
 
  if(me->mytype != MODIFY) {
 	/* get active ship cs */
 
	me->coord.objid = NULL_OBJID;
	me->go_cs.objid = NULL_OBJID;
	name[0] = '\0';

        if(SMGetDefCs(TRUE,(struct GRid *)NULL,(IGRshort *)NULL,&me->go_cs,
               &me->coord,&me->cs_env,(IGRboolean *)NULL)
                && me->coord.objid != NULL_OBJID){
                vd$get_name( name = name, obj = &me->coord);
                if(name[0] == '\0') {
                        /* try get name on the graphic object */
                        vd$get_name(name = name, obj = &me->go_cs);
                        if(name[0] == '\0') strcpy(name, "defined");
                }
        }
	FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
 		
  	me->dir_axis = 'x';
  	me->z_axis = 'z';
  	me->extension = 0;
  	me->ext_x1 = 0.;
  	me->ext_x2 = 0.;
 	me->def_name[0] = '\0';
 	me->reverse = 0;
 	me->symetry = 1;
 	me->nb_pt = 0;
  	_FREE(me->z_pos);
  	_FREE(me->y_pos);
 
 	(void)GetDefName("SMPtCamber_0",me->def_name);
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
  	me->z_axis = me->old_z_axis;
  	me->extension = me->old_extension;
  	me->ext_x1 = me->old_ext_x1;
  	me->ext_x2 = me->old_ext_x2;
 	me->reverse = me->old_reverse;
 	me->symetry = me->old_symetry;
 	me->nb_pt = me->old_nb_pt;
  	_FREE(me->z_pos);
  	_FREE(me->y_pos);
 
  	me->z_pos = 
	    _MALLOC(me->nb_pt,IGRdouble);
  	if(me->z_pos == NULL){
 		printf("ERROR Bad Allocation\n");
 		goto wrapup; 
  	}
  	me->y_pos = 
	     _MALLOC(me->nb_pt,IGRdouble);
  	if(me->y_pos == NULL){
 		printf("ERROR Bad Allocation\n");
 		goto wrapup; 
  	}
  	for(i=0;i<me->nb_pt;i++){
 			me->z_pos[i] = me->old_z_pos[i] ;
 			me->y_pos[i] = me->old_y_pos[i] ;
 	}
  	FIfld_set_value(me->forms[0].form_ptr, HIGHT, 0, 0,
                                me->z_pos[0], FALSE);
 	strcpy(me->def_name, me->old_def_name);
  	vd$get_name( name = name, obj = &me->coord);
 	if(name[0] == '\0') {
  		/* try get name on the graphic object */
  		vd$get_name( name = name, obj = &me->go_cs );
 		if(name[0] == '\0') strcpy(name, "defined");  
 	}
  	FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
  		
  	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);

 	
  }
  
  if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"hull range +10%");
  else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"bounded by hull");
  else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"User Extend");
 
  if(me->extension == 2){ 
      		om$send(msg = message SMCmdPtCmbr.GadgOn(&test),
 			 	targetid = my_id);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_x1,FALSE);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_x2,FALSE);
  }
  else 
      		om$send(msg = message SMCmdPtCmbr.GadgOf(&test),
 			 	targetid = my_id);
 
  if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
  else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 		
  if(me->symetry) FIg_set_state_off(me->forms[0].form_ptr, SYMETRY);
  else FIg_set_state_on(me->forms[0].form_ptr, SYMETRY);
  
  if(me->mytype == MODIFY) om$send(msg = message  SMCmdPtCmbr.DispAll(GRhhd),
                      			targetid = my_id);
   				
 return OM_S_SUCCESS;

 wrapup:
 *sts = OM_E_ABORT;
 return OM_S_SUCCESS;
 }
 
 
 
 /* ----------------------------------------------------------------- */ 
 /* 
 /* Reset the Gadgets of the form and init instances
 /*
 /**/
 
 method clear_form(long *sts )
{
   long	msg, test;
   
  	
   	*sts = OM_S_SUCCESS;
   	dp$erase_hilite(msg = &msg);
 
 
 
 	/* get active ship cs */
 
  	me->dir_axis = 'x';
  	me->z_axis = 'z';
  	me->extension = 0;
  	me->symetry = 1;
  	me->nb_pt = 0;
  	me->ext_x1 = 0.;
  	me->ext_x2 = 0.;
 	me->def_name[0] = '\0';
 	me->reverse = 0;
  	_FREE(me->z_pos);
  	_FREE(me->y_pos);
 
	FIfld_set_value(me->forms[0].form_ptr, HIGHT, 0, 0,
                                0, FALSE);
   	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
  	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,"");
   	FIg_set_text(me->forms[0].form_ptr,CS_NAME,"");
 	FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 	FIg_set_state_off(me->forms[0].form_ptr, SYMETRY);
 	if(me->mytype == MODIFY) FIg_erase(me->forms[0].form_ptr, LOAD);
 
      	om$send(msg = message SMCmdPtCmbr.GadgOf(&test),
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

  int 			i, k, nb_roots, sel_flag, 
  			nb_att, r_pos, stat, state;
  long			sizebuf, nret, test,  msg;
  struct GRid 		mac, roots[2];
  struct GRsymbology	symb;
  struct ACrg_coll	ACrg[2*MAX_PT+8];
  IGRdouble		ext_x1, ext_x2, z_pos, y_pos;
 
 *sts = OM_S_SUCCESS;
  	
 nb_roots = 2;

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
					(IGRdouble *)NULL, (IGRdouble *)NULL),
			 	targetid = my_id);

 as$status(sts = stat);
 if(!(stat & test & 1)){
     	printf("ERROR  SMCmdSurf.GetInfoFrmForm\n"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }
 if(me->nb_pt > MAX_PT) {
		ex$message(msgnumb = SM_S_TooPtDef);
  		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"ERROR, too much pts defined");
  		*sts =  OM_E_ABORT;
  		goto quit;
 }
 if(me->nb_pt == 0) {
		ex$message(msgnumb = SM_S_NoPosDef);
  		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"ERROR, No pts defined");
  		*sts =  OM_E_ABORT;
  		goto quit;
 }


 if(me->z_pos != NULL && me->y_pos != NULL){
  		FIfld_get_value(me->forms[0].form_ptr, HIGHT, 0, 0, &me->z_pos[0], 
  			&sel_flag, &r_pos);
  		me->y_pos[0] = 0.;
 }

 FIg_get_state(me->forms[0].form_ptr, SYMETRY, &state);
 if(state) me->symetry = 0;
 else me->symetry = 1;

 /* place the macro */

 if(me->mytype == PLACE){ 
  	mac.objid = NULL_OBJID;
  	mac.osnum = me->ModuleInfo.md_id.osnum;
 
  	stat = om$construct(classid = OPP_SMPtCamber_class_id,
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

 strcpy(ACrg[1].name,"z_axis");
 ACrg[1].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[1].desc.value.att_txt,&me->z_axis,ATTR_TXT)[ATTR_TXT -1] = '\0';


 strcpy(ACrg[2].name,"symetry");
 ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[2].desc.value.att_exp = (IGRdouble) me->symetry;

 strcpy(ACrg[3].name,"extension");
 ACrg[3].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[3].desc.value.att_exp = (IGRdouble) me->extension;


 strcpy(ACrg[4].name,"reverse");
 ACrg[4].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[4].desc.value.att_exp = (IGRdouble) me->reverse;


 strcpy(ACrg[5].name,"ext_x1");
 ACrg[5].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[5].desc.value.att_exp = ext_x1;

 strcpy(ACrg[6].name,"ext_x2");
 ACrg[6].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[6].desc.value.att_exp = ext_x2;

 strcpy(ACrg[7].name,"nb_pt");
 ACrg[7].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[7].desc.value.att_exp = (IGRdouble) me->nb_pt;

 k=8;
 for(i=0;i<me->nb_pt;i++){
	SMConvDistExtInt(me->z_pos[i], &z_pos, me->ModuleInfo.md_id.osnum);
	sprintf(ACrg[k].name,"%s%d","z_pos",i);
  	ACrg[k].desc.type = AC_ATTRIB_DOUBLE;
  	ACrg[k].desc.value.att_exp = (IGRdouble) z_pos;
	k++;

	SMConvDistExtInt(me->y_pos[i], &y_pos, me->ModuleInfo.md_id.osnum);
	sprintf(ACrg[k].name,"%s%d","y_pos",i);
  	ACrg[k].desc.type = AC_ATTRIB_DOUBLE;
  	ACrg[k].desc.value.att_exp = (IGRdouble) y_pos;
	k++;
 }

 nb_att = 2*me->nb_pt +8;

 if(me->mytype == PLACE){
  			 
  	roots[1].osnum = me->ModuleInfo.md_id.osnum;

  	stat = om$construct(	classid = OPP_ACrg_collect_class_id,
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
        if(!(stat & 1)){
 			printf("ERROR as$make_source\n");
 			*sts = OM_E_ABORT;
 			goto quit;
        } 

	/* place macro */
			
	stat = om$send(msg = message ACncpx.ACmplace
                   			((IGRint *)&msg,ACcant_place_sym,0,
                    			"SMPtCamber",nb_roots, roots,&me->ModuleInfo),
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

  	if(!(stat & msg & 1)){
        			printf("erreur GRvg.GRputsymb\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
  	}

 }
 else{
  			 
	/* modify macro */

	stat = om$send(msg = message SMCmdPtCmbr.SMmodif_mac
						(nb_att, ACrg, nb_roots, roots),
			 		targetid = my_id);
 	if(!(stat & 1)){
 				printf("ERROR  SMCmdPtCmbr.SMmodif_mac\n");
  				*sts =  OM_E_ABORT;
  				goto quit;
 	}

 }



 

quit:
 if(!(*sts&1)){
 	if(me->mytype == MODIFY) {ex$message(msgnumb = SM_S_ModFail);}
 		
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
 		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Modify Successfull");
		ex$message(msgnumb = SM_S_ModSucc);
  		strcpy(me->old_def_name,me->def_name);
  		me->old_coord = me->coord;
 		me->old_macro_id = me->macro_id;
  		me->old_dir_axis = me->dir_axis;
  		me->old_z_axis = me->z_axis;
  		me->old_extension = me->extension;
  		me->old_symetry = me->symetry;
  		me->old_nb_pt = me->nb_pt;
  		me->old_ext_x1 = me->ext_x1;
  		me->old_ext_x2 = me->ext_x2;
  		me->old_reverse = me->reverse;
  		_FREE(me->old_z_pos);
  		_FREE(me->old_y_pos);
  		if(me->old_nb_pt == 0) {
  			FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"ERROR No z_pos Defined");
 			ex$message(msgnumb = SM_S_NoPosDef);
 			goto wrapup;
  		}
  		me->old_z_pos = 
		   _MALLOC(me->old_nb_pt,IGRdouble);
  		if(me->old_z_pos == NULL){
 			printf("ERROR Bad Allocation\n");
 			goto wrapup; 
  		}
  		me->old_y_pos = 
		    _MALLOC(me->old_nb_pt,IGRdouble);
  		if(me->old_y_pos == NULL){
 			printf("ERROR Bad Allocation\n");
 			goto wrapup; 
  		}
 		for(i=0;i<me->old_nb_pt;i++){
 			me->old_z_pos[i] = me->z_pos[i] ;
 			me->old_y_pos[i] = me->y_pos[i] ;
 		}
 	}
 	else 	{
 		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Successfull");
		ex$message(msgnumb = SM_S_PlSucc);
  		(void)GetDefName("SMPtCamber_0",me->def_name);
  		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 	}
  }

wrapup:  

  return OM_S_SUCCESS;
}


 /* ----------------------------------------------------------------- */ 
 /*
 /* Get the info from the form 2 
 /* 
 /**/
  
method savedef(long *sts )
{
int		i, stat, num_rows, sel_flag, r_pos;
char		text[MAX_CHAR];

  *sts = OM_S_SUCCESS;
  _FREE(me->z_pos);
  _FREE(me->y_pos);

  stat = FIfld_get_num_rows(me->forms[1].form_ptr,DEF_FIELD, &num_rows);
  if(stat != FI_SUCCESS) {
                printf("error FIfld_get_num_rows: %d\n",stat);
                *sts = OM_E_ABORT;
                return OM_S_SUCCESS;
  }

  /* delete rows with no text */

  for(i=0;i<num_rows;i++){
	FIfld_get_text(me->forms[1].form_ptr, DEF_FIELD, i, 0, MAX_CHAR, text,
                        &sel_flag, &r_pos);
	if(text[0] == '\0') {
		FIfld_pos_cursor(me->forms[1].form_ptr,DEF_FIELD,
					(i-1),0,0,0,0,0);
		stat = FIfld_delete_rows(me->forms[1].form_ptr,DEF_FIELD,
                                        	i,1);
		if(stat != FI_SUCCESS){
			printf("error FIfld_delete_rows: %d\n",stat);
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
		}
		i--;
		num_rows--;
		continue;
	}
	FIfld_get_text(me->forms[1].form_ptr, DEF_FIELD, i, 1, MAX_CHAR, text,
                        &sel_flag, &r_pos);
	if(text[0] == '\0') {
		FIfld_pos_cursor(me->forms[1].form_ptr,DEF_FIELD,
					(i-1),0,0,0,0,0);
		stat = FIfld_delete_rows(me->forms[1].form_ptr,DEF_FIELD,
                                        	i,1);
		if(stat != FI_SUCCESS){
			printf("error FIfld_delete_rows: %d\n",stat);
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
		}
		i--;
		num_rows--;
		continue;
	}
  }
  stat = FIfld_get_num_rows(me->forms[1].form_ptr,DEF_FIELD, &num_rows);
  if(stat != FI_SUCCESS) {
                printf("error FIfld_get_num_rows: %d\n",stat);
                *sts = OM_E_ABORT;
                return OM_S_SUCCESS;
  }
  me->nb_pt = num_rows + 1;
  me->z_pos = _MALLOC(me->nb_pt,IGRdouble);
  if(me->z_pos == NULL){
 		printf("ERROR Bad Allocation\n");
 		*sts = OM_E_ABORT;
 		goto wrapup; 
  }
  me->y_pos = _MALLOC(me->nb_pt,IGRdouble);
  if(me->y_pos == NULL){
 		printf("ERROR Bad Allocation\n");
 		*sts = OM_E_ABORT;
 		goto wrapup;
  }

  for(i=0;i<num_rows;i++){
	FIfld_get_text(me->forms[1].form_ptr, DEF_FIELD, i, 0, MAX_CHAR, text,
                        &sel_flag, &r_pos);
	sscanf(text,"%lf",&me->z_pos[i+1]);
	FIfld_get_text(me->forms[1].form_ptr, DEF_FIELD, i, 1, MAX_CHAR, text,
                        &sel_flag, &r_pos);
	sscanf(text,"%lf",&me->y_pos[i+1]);
  }  

  /* y_pos must be in increasing order */

  for(i=0;i<num_rows-1;i++){
     if(me->y_pos[i+1] <= 0 || me->y_pos[i+1] >= me->y_pos[i+2]){
		 FIg_set_text(me->forms[1].form_ptr,FI_MSG_FIELD,"y must be in increasing order");
                *sts = OM_E_ABORT;
                return OM_S_SUCCESS;
     }
  }  
wrapup:
  return OM_S_SUCCESS;

}
 
 /* ----------------------------------------------------------------- */ 
 /*
 /* reset the form 2 
 /* 
 /**/
  
method resetdef(long *sts )
{
int		i, stat, num_rows;

  *sts = OM_S_SUCCESS;

(void)SMVA_enable(me->forms[1].form_ptr,5, FI_ACCEPT, FI_EXECUTE, FI_RESET, DEL_ROW, 
						INSERT_ROW); 

FIg_set_state_off(me->forms[1].form_ptr,INSERT_ROW);
FIg_set_state_off(me->forms[1].form_ptr,DEL_ROW);
FIg_set_text(me->forms[1].form_ptr,FI_MSG_FIELD,"");

stat = FIfld_get_num_rows(me->forms[1].form_ptr,DEF_FIELD, &num_rows);
if(stat != FI_SUCCESS) {
	printf("error FIfld_get_num_rows: %d\n",stat);
	*sts = OM_E_ABORT;
	return OM_S_SUCCESS;
}
if(num_rows){
	stat = FIfld_delete_rows(me->forms[1].form_ptr,DEF_FIELD,
                                        0,num_rows);
	if(stat != FI_SUCCESS){
		printf("error FIfld_delete_rows: %d\n",stat);
		*sts = OM_E_ABORT;
		return OM_S_SUCCESS;
	}
}

if(me->nb_pt){
	for(i=0;i<me->nb_pt-1;i++){
		FIfld_set_value(me->forms[1].form_ptr, DEF_FIELD, i, 0,
                                me->z_pos[i+1], FALSE);
		FIfld_set_value(me->forms[1].form_ptr, DEF_FIELD, i, 1,
                                me->y_pos[i+1], FALSE);

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




end implementation SMCmdPtCmbr;



