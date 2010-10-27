/* $Id: SMLgBkNtf.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / SMLgBkNtf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMLgBkNtf.I,v $
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
# Revision 1.2  1996/03/18  10:56:48  pinnacle
# Replaced: SMCmdSurf.S for:  by ksundar for vds.240
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

  /*               SMLgBkNtf.I                    */
  /*   Methods  and functions for SMLongBk        */ 
  /*   Methods for the CO                         */
  /*   Pascale Lacroix  (ISDC)			  */
  /*   Creation date Nov-92                       */
   
class implementation SMCmdLgBk;
#include <math.h>  
  
#define AS_DEBUG	1
  
#define INV_LOC		521
 
#define MAX_TEMP	4
  
  
  extern GRclassid 	OPP_SMLongBk_class_id,OPP_ACrg_collect_class_id,
  			OPP_SMframe_class_id;
  
  from ACrg_collect	import ACadd_list_attribute,ACget_named_attribute;
  from GRgraphics	import GRdelete, GRdisplay;
  from NDnode		import NDconnect, NDdisconnect,NDchg_state, NDget_objects;
  from NDmacro		import ACreturn_foot;
  from ASnode		import ASreturn_go;
  from GRvg		import GRputsymb, GRputname;
  from ACncpx		import ACmplace;
  from SMframe		import SMgive_rel_position;


 
/* ----------------------------------------------------------------- */
/*
/* hilite the located objects 
/*
/**/


method DispAll(enum   GRdpmode mode)
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

if(me->frame1.obj_id.objid != NULL_OBJID){

        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->frame1.obj_id.objid,
                        targetos = me->frame1.obj_id.osnum );

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
if(me->frame2.obj_id.objid != NULL_OBJID){

        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->frame2.obj_id.objid,
                        targetos = me->frame2.obj_id.osnum );

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
 if(me->frame1.obj_id.objid != NULL_OBJID &&
        ! ( om$is_objid_valid( osnum = me->frame1.obj_id.osnum,
                               objid = me->frame1.obj_id.objid)&1) ){
	ex$message(msgnumb = SM_E_ErFrmDel);
        me->state = _terminate;
        return OM_S_SUCCESS;
 }
 if(me->frame2.obj_id.objid != NULL_OBJID &&
        ! ( om$is_objid_valid( osnum = me->frame2.obj_id.osnum,
                               objid = me->frame2.obj_id.objid)&1) ){
	ex$message(msgnumb = SM_E_ErFrmDel);
        me->state = _terminate;
        return OM_S_SUCCESS;
 }
        
return OM_S_SUCCESS;

}
 /* ----------------------------------------------------------------- */ 
 /*
 /* store the frame1
 /*
 /**/
  
 method store_frame1(long *sts)
{
  char			name[MAX_CHAR];
  int			status;
  long			msg;
  struct GRid           currentModule ;
  struct GRlc_info      obj;
  enum 	 GRdpmode 	mode;
  OMuword		classid;

  *sts = OM_S_SUCCESS;
 
   dp$erase_hilite(msg = &msg);
   mode = GRhe;
   ex$get_cur_mod( id      = &currentModule.objid,
                osnum   = &currentModule.osnum ) ;

   if(me->frame1.obj_id.objid != NULL_OBJID){
        status = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->frame1.obj_id.objid,
                        targetos = me->frame1.obj_id.osnum );

        status = om$send(msg     = message GRgraphics.GRdisplay(
                                sts,
                                &obj.module_info.md_env.matrix_type,
                                obj.module_info.md_env.matrix,
                                &mode,
                                &currentModule ),
                targetid= obj.located_obj.objid,
                targetos= obj.located_obj.osnum ) ;

	as$status();
   }
   me->frame1.obj_id = me->event1.located_object[0].located_obj;

   /* Retrieve the name of the frame1 system */

   status = as$make_source(go_grid = me->frame1.obj_id,
                           mod_env = &me->event1.located_object[0].module_info,
                           as_os   = me->ModuleInfo.md_id.osnum,
                           as_grid = &me->frame1.obj_id);
   as$status();
   if(!(status&1)){*sts = OM_E_ABORT; return OM_S_SUCCESS;}
   me->frame1.mod_env = me->event1.located_object[0].module_info;


   om$get_classid( objid  = me->frame1.obj_id.objid,
   		   osnum  = me->frame1.obj_id.osnum,
   		   p_classid = &classid);
   if( om$is_ancestry_valid( superclassid = OPP_SMframe_class_id,
   			     subclassid   = classid) != OM_S_SUCCESS){
   	status = om$send(msg = message NDmacro.ACreturn_foot(
                                          &msg,
                                          "",
                                          &me->frame1.obj_id,
                                          &me->frame1.mod_env.md_env.matrix_type,
                                          me->frame1.mod_env.md_env.matrix
                                                          ),
                      targetid = me->frame1.obj_id.objid,
                      targetos = me->frame1.obj_id.osnum
   	);
   }
 
   name[0] = '\0';
   vd$get_name(name = name, obj = &(me->frame1.obj_id) );
   if(name[0] == '\0') strcpy(name,"defined");

   /* verify the frame is on the axis x of the given cs */

   status = om$send(msg = message SMCmdLgBk.verif_frame(&msg,
						      &me->frame1 ),
 			 	targetid = my_id);

   if(!(status & msg & 1)) {
		me->frame1.obj_id.objid = NULL_OBJID;
   		FIg_set_text(me->forms[0].form_ptr,FR_NAME,"");
		*sts = INV_LOC;
  		om$send(msg = message  SMCmdLgBk.DispAll(GRhhd),
                      targetid = my_id);
		return OM_S_SUCCESS;
   }      

  om$send(msg = message  SMCmdLgBk.DispAll(GRhhd),
                      targetid = my_id);

   FIg_set_text(me->forms[0].form_ptr,FR_NAME,name);
 
  return OM_S_SUCCESS;
}


 /* ----------------------------------------------------------------- */ 
 /*
 /* store the frame2
 /*
 /**/
  
 method store_frame2(long *sts)
{
  char			name[MAX_CHAR];
  int			status;
  long			msg;
  struct GRid           currentModule ;
  struct GRlc_info      obj;
  enum 	 GRdpmode 	mode;
  OMuword		classid;

  *sts = OM_S_SUCCESS;
   dp$erase_hilite(msg = &msg);
 
   mode = GRhe;
   ex$get_cur_mod( id      = &currentModule.objid,
                osnum   = &currentModule.osnum ) ;
   if(me->frame2.obj_id.objid != NULL_OBJID){
        status = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->frame2.obj_id.objid,
                        targetos = me->frame2.obj_id.osnum );

        status = om$send(msg     = message GRgraphics.GRdisplay(
                                sts,
                                &obj.module_info.md_env.matrix_type,
                                obj.module_info.md_env.matrix,
                                &mode,
                                &currentModule ),
                targetid= obj.located_obj.objid,
                targetos= obj.located_obj.osnum ) ;

	as$status();
   }
   me->frame2.obj_id = me->event1.located_object[0].located_obj;

   /* Retrieve the name of the frame2 */

   status = as$make_source(go_grid = me->frame2.obj_id,
                           mod_env = &me->event1.located_object[0].module_info,
                           as_os   = me->ModuleInfo.md_id.osnum,
                           as_grid = &me->frame2.obj_id);
   as$status();
   if(!(status&1)){*sts = OM_E_ABORT; return OM_S_SUCCESS;}
   me->frame2.mod_env = me->event1.located_object[0].module_info;

   om$get_classid( objid  = me->frame2.obj_id.objid,
   		   osnum  = me->frame2.obj_id.osnum,
   		   p_classid = &classid);
   if( om$is_ancestry_valid( superclassid = OPP_SMframe_class_id,
   			     subclassid   = classid) != OM_S_SUCCESS){
   	status = om$send(msg = message NDmacro.ACreturn_foot(
                                          &msg,
                                          "",
                                          &me->frame2.obj_id,
                                          &me->frame2.mod_env.md_env.matrix_type,
                                          me->frame2.mod_env.md_env.matrix
                                                          ),
                      targetid = me->frame2.obj_id.objid,
                      targetos = me->frame2.obj_id.osnum
   	);
   }
 
   name[0] = '\0';
   vd$get_name( name = name, obj = &me->frame2.obj_id );
   if(name[0] == '\0') strcpy(name,"defined");

   /* verify the frame is on the axis x of the given cs */

   status = om$send(msg = message SMCmdLgBk.verif_frame(&msg,
						      &me->frame2 ),
 			 	targetid = my_id);

   if(!(status & msg & 1)) {
		me->frame2.obj_id.objid = NULL_OBJID;
   		FIg_set_text(me->forms[0].form_ptr,TO_NAME,"");
		*sts = INV_LOC;
  		om$send(msg = message  SMCmdLgBk.DispAll(GRhhd),
                      targetid = my_id);
		return OM_S_SUCCESS;
   }      

  om$send(msg = message  SMCmdLgBk.DispAll(GRhhd),
                      targetid = my_id);
   FIg_set_text(me->forms[0].form_ptr,TO_NAME,name);
 
 
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
  long			test,msg;
  struct GRid		*roots;
  struct ACrg_coll	attr;
  OMuword		classid;
 
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
  if(!(stat & 1)){
  		printf("ERROR retrieve roots of the macro \n");         
  		*sts = OM_E_ABORT;
 		goto wrapup;
  }
 
  /* Get the coord syst */
 
  me->coord = roots[0];

  stat = GetEnvFrObj( &roots[0], &me->cs_env, &me->go_cs);
  if(!(stat & 1)){
  		printf("ERROR GetEnvFrObj \n");         
  		*sts = OM_E_ABORT;
 		goto wrapup;
  }


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
  
  /* Get the x_axis */
  strcpy(attr.name,"x_axis");
 
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
  me->x_axis = attr.desc.value.att_txt[0];
 
 
  /* Get the y_pos1 */
 
  strcpy(attr.name,"y_pos1");
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
  me->y_pos1 = attr.desc.value.att_exp;
  SMConvDistIntExt(me->y_pos1, &me->y_pos1, me->ModuleInfo.md_id.osnum);

  /* Get the y_pos2 */
 
  strcpy(attr.name,"y_pos2");
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
  me->y_pos2 = attr.desc.value.att_exp;
  SMConvDistIntExt(me->y_pos2, &me->y_pos2, me->ModuleInfo.md_id.osnum);
 
  /* Get the fr_dx */
 
  strcpy(attr.name,"fr_dx");
  stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
 							&attr),
                         targetid= roots[1].objid,
                         targetos= roots[1].osnum);
  if(!(stat & msg & 1)) goto wrapup ;
  me->fr_dx = attr.desc.value.att_exp;
  SMConvDistIntExt(me->fr_dx, &me->fr_dx, me->ModuleInfo.md_id.osnum);

  /* Get the to_dx */
 
  strcpy(attr.name,"to_dx");
  stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
 							&attr),
                         targetid= roots[1].objid,
                         targetos= roots[1].osnum);
  if(!(stat & msg & 1)) goto wrapup ;
  me->to_dx = attr.desc.value.att_exp;
  SMConvDistIntExt(me->to_dx, &me->to_dx, me->ModuleInfo.md_id.osnum);
 
 
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
 
  /* Get the frame1 */
 
  me->frame1.obj_id = roots[2];
  stat = GetEnvFrObj( &me->frame1.obj_id, &me->frame1.mod_env, NULL);
  if(!(stat & 1)){
  	printf("ERROR GetEnvFrObj \n");         
  	*sts = OM_E_ABORT;
 	goto wrapup;
  }
  om$get_classid( objid  = me->frame1.obj_id.objid,
   		   osnum  = me->frame1.obj_id.osnum,
   		   p_classid = &classid);
  if( om$is_ancestry_valid( superclassid = OPP_SMframe_class_id,
   			     subclassid   = classid) != OM_S_SUCCESS){
   		stat = om$send(msg = message NDmacro.ACreturn_foot(
                                          &msg,
                                          "",
                                          &me->frame1.obj_id,
                                          &me->frame1.mod_env.md_env.matrix_type,
                                          me->frame1.mod_env.md_env.matrix
                                                          ),
                      targetid = me->frame1.obj_id.objid,
                      targetos = me->frame1.obj_id.osnum
   		);
  }

  /* Get the frame2 */
 
  me->frame2.obj_id = roots[3];
  stat = GetEnvFrObj( &me->frame2.obj_id, &me->frame2.mod_env, NULL);
  if(!(stat & 1)){
  	printf("ERROR GetEnvFrObj \n");         
  	*sts = OM_E_ABORT;
 	goto wrapup;
  }
  om$get_classid( objid  = me->frame2.obj_id.objid,
   		   osnum  = me->frame2.obj_id.osnum,
   		   p_classid = &classid);
  if( om$is_ancestry_valid( superclassid = OPP_SMframe_class_id,
   			     subclassid   = classid) != OM_S_SUCCESS){
   		stat = om$send(msg = message NDmacro.ACreturn_foot(
                                          &msg,
                                          "",
                                          &me->frame2.obj_id,
                                          &me->frame2.mod_env.md_env.matrix_type,
                                          me->frame2.mod_env.md_env.matrix
                                                          ),
                      targetid = me->frame2.obj_id.objid,
                      targetos = me->frame2.obj_id.osnum
   		);
  }

 vd$get_name(name = me->def_name, obj = &me->macro_id);
 
 
  if(me->mytype == MODIFY) {
  		strcpy(me->old_def_name,me->def_name);
  		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->old_def_name);
 		me->old_macro_id = me->macro_id;
  		me->old_coord = me->coord;
  		me->old_dir_axis = me->dir_axis;
  		me->old_x_axis = me->x_axis;
  		me->old_y_pos1 = me->y_pos1;
  		me->old_y_pos2 = me->y_pos2;
  		me->old_extension = me->extension;
  		me->old_fr_dx = me->fr_dx;
  		me->old_to_dx = me->to_dx;
  		me->old_ext_x1 = me->ext_x1;
  		me->old_ext_x2 = me->ext_x2;
  		me->old_ext_z1 = me->ext_z1;
  		me->old_ext_z2 = me->ext_z2;
  		me->old_reverse = me->reverse;
		me->old_frame1 = me->frame1;
		me->old_frame2 = me->frame2;
  }
  else {
  	(void)GetDefName("SMLongBk_0",me->def_name);
  	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  }
 
 vd$get_name(name = name, obj = &me->coord);
 if(name[0] == '\0') {
  	/* try get name on the graphic object */
  	vd$get_name(name = name, obj = &me->go_cs );
 	if(name[0] == '\0') strcpy(name, "defined");  
 }
 FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
  
  vd$get_name(name = name, obj =&me->frame1.obj_id);
  if(name[0] == '\0') strcpy(name, "defined");  
  FIg_set_text(me->forms[0].form_ptr, FR_NAME,name);

  vd$get_name(name = name, obj = &me->frame2.obj_id);
  if(name[0] == '\0') strcpy(name, "defined");  
  FIg_set_text(me->forms[0].form_ptr, TO_NAME,name);

  sprintf(name,"%g",me->y_pos1);
  FIg_set_text(me->forms[0].form_ptr,Y_POS1 ,name);

  sprintf(name,"%g",me->y_pos2);
  FIg_set_text(me->forms[0].form_ptr,Y_POS2 ,name);
 
  if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"hull range +10%");
  else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"bounded by hull");
  else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"User Extend");
 
  if(me->extension == 2){ 
      		om$send(msg = message SMCmdLgBk.GadgOn(&test),
 			 	targetid = my_id);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_x1,FALSE);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_x2,FALSE);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_Z1,0,0,me->ext_z1,FALSE);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_Z2,0,0,me->ext_z2,FALSE);
  }
  else 
      		om$send(msg = message SMCmdLgBk.GadgOf(&test),
 			 	targetid = my_id);
 
  if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
  else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);

  FIfld_set_value(me->forms[0].form_ptr,FR_DX,0,0,me->fr_dx,FALSE);
  FIfld_set_value(me->forms[0].form_ptr,TO_DX,0,0,me->to_dx,FALSE);
  om$send(msg = message  SMCmdLgBk.DispAll(GRhhd),
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
                vd$get_name(name = name, obj = &me->coord);
                if(name[0] == '\0') {
                        /* try get name on the graphic object */
                        vd$get_name(name = name, obj = &me->go_cs );
                        if(name[0] == '\0') strcpy(name, "defined");
                }
        }
        FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
	
	me->frame1.obj_id.objid = NULL_OBJID;
	me->frame2.obj_id.objid = NULL_OBJID;
  	me->dir_axis = 'z';
  	me->x_axis = 'x';
  	me->y_pos1 = 0.;
  	me->y_pos2 = 0.;
  	me->extension = 0;
  	me->ext_x1 = 0.;
  	me->ext_x2 = 0.;
  	me->ext_z1 = 0.;
  	me->ext_z2 = 0.;
 	me->def_name[0] = '\0';
 	me->reverse = 0;
 	me->fr_dx = 0.;
 	me->to_dx = 0.;
 
  	FIg_set_text(me->forms[0].form_ptr, FR_NAME,"");
  	FIg_set_text(me->forms[0].form_ptr, TO_NAME,"");

 	(void)GetDefName("SMLongBk0",me->def_name);
  	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  }
  else {
 
 	me->macro_id = me->old_macro_id ;
	me->frame1 = me->old_frame1;
	me->frame2 = me->old_frame2;
  	me->coord = me->old_coord ;
   	if( !(GetEnvFrObj( &me->coord, &me->cs_env, &me->go_cs) & 1)){
   		printf("ERROR GetEnvFrObj \n");
		return OM_E_ABORT;
   	}
  	me->dir_axis = me->old_dir_axis ;
  	me->x_axis = me->old_x_axis;
  	me->y_pos1 = me->old_y_pos1;
  	me->y_pos2 = me->old_y_pos2;
  	me->extension = me->old_extension;
  	me->ext_x1 = me->old_ext_x1;
  	me->ext_x2 = me->old_ext_x2;
  	me->ext_z1 = me->old_ext_z1;
  	me->ext_z2 = me->old_ext_z2;
 	me->reverse = me->old_reverse;
 	me->fr_dx = me->old_fr_dx;
 	me->to_dx = me->old_to_dx;
 	strcpy(me->def_name, me->old_def_name);

 	vd$get_name(name = name, obj = &me->coord);
 	if(name[0] == '\0') {
  		/* try get name on the graphic object */
  		vd$get_name(name = name, obj = &me->go_cs );
 		if(name[0] == '\0') strcpy(name, "defined");  
 	}
  	FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);

  	vd$get_name(name = name, obj = &me->frame1.obj_id);
  	if(name[0] == '\0') strcpy(name, "defined");  
  	FIg_set_text(me->forms[0].form_ptr, FR_NAME,name);
  		
  	vd$get_name(name = name, obj = &me->frame2.obj_id);
  	if(name[0] == '\0') strcpy(name, "defined");  
  	FIg_set_text(me->forms[0].form_ptr, TO_NAME,name);
  		
  	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
 		
 	
  }
  
  sprintf(name,"%g",me->y_pos1);
  FIg_set_text(me->forms[0].form_ptr,Y_POS1 ,name);

  sprintf(name,"%g",me->y_pos2);
  FIg_set_text(me->forms[0].form_ptr,Y_POS2 ,name);

  if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"hull range +10%");
  else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"bounded by hull");
  else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
  					"User Extend");
 
  if(me->extension == 2){ 
      		om$send(msg = message SMCmdLgBk.GadgOn(&test),
 			 	targetid = my_id);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_x1,FALSE);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_x2,FALSE);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_Z1,0,0,me->ext_z1,FALSE);
  		FIfld_set_value(me->forms[0].form_ptr,EXT_Z2,0,0,me->ext_z2,FALSE);
  }
  else 
      		om$send(msg = message SMCmdLgBk.GadgOf(&test),
 			 	targetid = my_id);
 
  if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
  else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 		
  FIfld_set_value(me->forms[0].form_ptr,FR_DX,0,0,me->fr_dx,FALSE);
  FIfld_set_value(me->forms[0].form_ptr,TO_DX,0,0,me->to_dx,FALSE);

  if(me->mytype == MODIFY) om$send(msg = message  SMCmdLgBk.DispAll(GRhhd),
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
 
 
 

  	me->dir_axis = 'z';
  	me->x_axis = 'x';
  	me->y_pos1 = 0.;
  	me->y_pos2 = 0.;
  	me->extension = 0;
  	me->fr_dx = 0.;
  	me->to_dx = 0.;
  	me->ext_x1 = 0.;
  	me->ext_x2 = 0.;
  	me->ext_z1 = 0.;
  	me->ext_z2 = 0.;
 	me->def_name[0] = '\0';
 	me->reverse = 0;
	me->frame1.obj_id.objid = NULL_OBJID;
	me->frame2.obj_id.objid = NULL_OBJID;
 
   	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
  	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,"");
   	FIg_set_text(me->forms[0].form_ptr,Y_POS1,"");
   	FIg_set_text(me->forms[0].form_ptr,Y_POS2,"");
   	FIg_set_text(me->forms[0].form_ptr,CS_NAME,"");
   	FIg_set_text(me->forms[0].form_ptr,FR_NAME,"");
   	FIg_set_text(me->forms[0].form_ptr,TO_NAME,"");
 	FIg_set_state_off(me->forms[0].form_ptr, ORIENT);

  	FIfld_set_value(me->forms[0].form_ptr,FR_DX,0,0,me->fr_dx,FALSE);
  	FIfld_set_value(me->forms[0].form_ptr,TO_DX,0,0,me->to_dx,FALSE);

 	if(me->mytype == MODIFY) FIg_erase(me->forms[0].form_ptr, LOAD);
 
      	om$send(msg = message SMCmdLgBk.GadgOf(&test),
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
 int 			nb_roots, sel_flag, nb_att, r_pos, stat;
 char 			text[MAX_CHAR];
 long			test,sizebuf, nret, msg;
 struct GRid 		mac, roots[4];
 struct GRsymbology	symb;
 struct ACrg_coll	ACrg[12];
 IGRdouble		pos1, pos2, ext_x1, ext_x2, ext_z1, ext_z2,fr_dx, 
			to_dx, y_pos1,y_pos2;


 *sts = OM_S_SUCCESS;

 nb_roots = 4;
 nb_att = 12;
 	
 mac.objid = NULL_OBJID;
 mac.osnum = me->ModuleInfo.md_id.osnum;

 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
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
					&ext_z1, &ext_z2),
			 	targetid = my_id);

 as$status(sts = stat);
 if(!(stat & test & 1)){
     	printf("ERROR  SMCmdSurf.GetInfoFrmForm\n"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }
 if(me->frame1.obj_id.objid == NULL_OBJID || 
			me->frame2.obj_id.objid  == NULL_OBJID ){
 		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
  			"ERROR,Frames must be defined");
		*sts =  OM_E_ABORT; 
		goto quit;
 }	

 /* verif_frame */
	
 stat = om$send(msg = message SMCmdLgBk.verif_frame(&msg,
						      &me->frame1 ),
 			 	targetid = my_id);
 if(!(stat & msg & 1)) {
   	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 		"Invalid Frame");
	*sts = OM_E_ABORT;
	goto quit;
 } 
 stat = om$send(msg = message SMCmdLgBk.verif_frame(&msg,
						      &me->frame2 ),
 			 	targetid = my_id);
 if(!(stat & msg & 1)) {
   		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 		"Invalid Frame");
		*sts = OM_E_ABORT;
		goto quit;
 }

 stat = om$send(msg = message SMframe.SMgive_rel_position(&msg,
                                                  &pos1),
                       senderid = NULL_OBJID,
                       targetid = me->frame1.obj_id.objid,
                       targetos = me->frame1.obj_id.osnum );
 as$status(sts = stat);
 if(!(stat & msg & 1)){
     	printf("ERROR SMgive_rel_position\n"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }
 stat = om$send(msg = message SMframe.SMgive_rel_position(&msg,
                                                  &pos2),
                       senderid = NULL_OBJID,
                       targetid = me->frame2.obj_id.objid,
                       targetos = me->frame2.obj_id.osnum );
 as$status(sts = stat);
 if(!(stat & msg & 1)){
     	printf("ERROR SMgive_rel_position\n"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }
  	
 if(pos2 <= pos1){
 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
     			"ERROR, to frame must be greater than from frame"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }

 FIfld_get_value(me->forms[0].form_ptr, FR_DX, 0, 0, &me->fr_dx, 
  			&sel_flag, &r_pos);
 SMConvDistExtInt(me->fr_dx, &fr_dx, me->ModuleInfo.md_id.osnum);

 FIfld_get_value(me->forms[0].form_ptr, TO_DX, 0, 0, &me->to_dx, 
  			&sel_flag, &r_pos);
 SMConvDistExtInt(me->to_dx, &to_dx, me->ModuleInfo.md_id.osnum);

 FIg_get_text(me->forms[0].form_ptr, Y_POS1, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->y_pos1);
 else me->y_pos1 = 0.;
 SMConvDistExtInt(me->y_pos1, &y_pos1, me->ModuleInfo.md_id.osnum);

 FIg_get_text(me->forms[0].form_ptr, Y_POS2, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->y_pos2);
 else me->y_pos2 = 0.;
 SMConvDistExtInt(me->y_pos2, &y_pos2, me->ModuleInfo.md_id.osnum);

 if(fabs(y_pos2-y_pos1) < 1e-4){
 	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
     			"ERROR, Y1 and Y2 must be different"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }
  	
 /* place the macro */

 if(me->mytype == PLACE){ 
  	mac.objid = NULL_OBJID;
  	mac.osnum = me->ModuleInfo.md_id.osnum;
 
  	stat = om$construct(classid = OPP_SMLongBk_class_id,
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

 strcpy(ACrg[1].name,"x_axis");
 ACrg[1].desc.type = AC_ATTRIB_TEXT;
 strncpy(ACrg[1].desc.value.att_txt,&me->x_axis,ATTR_TXT)[ATTR_TXT -1] = '\0';

 strcpy(ACrg[2].name,"y_pos1");
 ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[2].desc.value.att_exp = y_pos1;

 strcpy(ACrg[3].name,"y_pos2");
 ACrg[3].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[3].desc.value.att_exp = y_pos2;

 strcpy(ACrg[4].name,"fr_dx");
 ACrg[4].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[4].desc.value.att_exp = fr_dx;

 strcpy(ACrg[5].name,"to_dx");
 ACrg[5].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[5].desc.value.att_exp = to_dx;

 strcpy(ACrg[6].name,"extension");
 ACrg[6].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[6].desc.value.att_exp = (IGRdouble) me->extension;

 strcpy(ACrg[7].name,"reverse");
 ACrg[7].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[7].desc.value.att_exp = (IGRdouble) me->reverse;

 strcpy(ACrg[8].name,"ext_x1");
 ACrg[8].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[8].desc.value.att_exp = ext_x1;

 strcpy(ACrg[9].name,"ext_x2");
 ACrg[9].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[9].desc.value.att_exp = ext_x2;

 strcpy(ACrg[10].name,"ext_z1");
 ACrg[10].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[10].desc.value.att_exp = ext_z1;

 strcpy(ACrg[11].name,"ext_z2");
 ACrg[11].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[11].desc.value.att_exp = ext_z2;


 stat = as$make_source(
      				go_grid = me->frame1.obj_id,
 			     	mod_env = &me->frame1.mod_env,
 			     	as_os   = me->ModuleInfo.md_id.osnum,
 			     	as_grid = &roots[2]);
 as$status(sts = stat);
 if(!(stat & 1))
           { 
  		printf("ERROR as$make_source\n");
  		*sts = OM_E_ABORT;
  		goto quit;
           } 
 stat = as$make_source(
      				go_grid = me->frame2.obj_id,
 			     	mod_env = &me->frame2.mod_env,
 			     	as_os   = me->ModuleInfo.md_id.osnum,
 			     	as_grid = &roots[3]);
 as$status(sts = stat);
 if(!(stat & 1))
           { 
  		printf("ERROR as$make_source\n");
  		*sts = OM_E_ABORT;
  		goto quit;
           } 

 if(me->mytype == PLACE){
  			 
	/* place macro */
			
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
        if(!(stat & 1))
          	{ 
 			printf("ERROR as$make_source\n");
 			*sts = OM_E_ABORT;
 			goto quit;
          	} 
	stat = om$send(msg = message ACncpx.ACmplace
                   			((IGRint *)&msg,ACcant_place_sym,0,
                    			"SMLongBk",nb_roots, roots,&me->ModuleInfo),
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

	stat = om$send(msg = message SMCmdLgBk.SMmodif_mac
						(nb_att, ACrg, nb_roots, roots),
			 		targetid = my_id);
 	if(!(stat & 1)){
 			printf("ERROR  SMCmdLgBk.SMmodif_mac\n");
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
  		strcpy(me->old_def_name,me->def_name);
 		me->old_macro_id = me->macro_id;
  		me->old_coord = me->coord;
  		me->old_dir_axis = me->dir_axis;
  		me->old_x_axis = me->x_axis;
  		me->old_y_pos1 = me->y_pos1;
  		me->old_y_pos2 = me->y_pos2;
  		me->old_extension = me->extension;
  		me->old_fr_dx = me->fr_dx;
  		me->old_to_dx = me->to_dx;
  		me->old_ext_x1 = me->ext_x1;
  		me->old_ext_x2 = me->ext_x2;
  		me->old_ext_z1 = me->ext_z1;
  		me->old_ext_z2 = me->ext_z2;
  		me->old_reverse = me->reverse;
		me->old_frame1 = me->frame1;
		me->old_frame2 = me->frame2;
 		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Modify Successfull");
		ex$message(msgnumb = SM_S_ModSucc);
 	}
 	else 	{
 		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Successfull");
		ex$message(msgnumb = SM_S_PlSucc);
  		(void)GetDefName("SMLongBk_0",me->def_name);
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
 struct GRid 		original, *old_roots;
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
 if(me->frame1.obj_id.objid != me->old_frame1.obj_id.objid ||
 	me->frame1.obj_id.osnum != me->old_frame1.obj_id.osnum || 
	me->frame2.obj_id.objid != me->old_frame2.obj_id.objid ||
 	me->frame2.obj_id.osnum != me->old_frame2.obj_id.osnum){
	put_batch = TRUE;
  	stat = om$send(msg = message NDnode.NDdisconnect
		      (2, &old_roots[2]),
                   		senderid = NULL_OBJID,
                   		targetid = me->macro_id.objid,
                   		targetos = me->macro_id.osnum );
  	as$status(sts = stat);
  	if(!(stat & 1)){
		printf("Erreur NDnode.NDdisconnect\n");
		return OM_E_ABORT;
  	}
  	NDduplicate_root(2, &new[2]);
  	original.objid = NULL_OBJID;
  	stat = om$send(msg = message NDnode.NDconnect
		      (2, &new[2], original, ND_ADD),
                   		senderid = NULL_OBJID,
                   		targetid = me->macro_id.objid,
                   		targetos = me->macro_id.osnum );

  	as$status(sts = stat);
  	if(!(stat & 1)){
		printf("Erreur NDnode.NDconnect\n");
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


end implementation SMCmdLgBk;



