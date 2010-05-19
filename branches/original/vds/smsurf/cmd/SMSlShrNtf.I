/* $Id: SMSlShrNtf.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/cmd / SMSlShrNtf.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSlShrNtf.I,v $
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

  /*               SMSlShrNtf.I                    */
  /*   Methods  and functions for SMSlSheer        */ 
  /*   Methods for the CO                          */
  /*   Pascale Lacroix  (ISDC)			   */
  /*   Creation date July-92                       */
   
  class implementation SMCmdSlShr;
   
  
  
  
  
#define AS_DEBUG	1
  
#define SLNEW	 	519
#define ERASE_F2	521
#define LOAD_FRAME	523
#define LOAD_DEPFR	525
#define INV_LOC		527
#define DEF_FORM	529
#define SLOLD	 	531

#define MAX_TEMP	53
#define MAX_PT		50
  
  
  extern GRclassid 	OPP_SMSlSheer_class_id,OPP_ACrg_collect_class_id,
  			OPP_SMframe_class_id,OPP_ACpretend_class_id;
  
  from ACrg_collect	import	ACadd_list_attribute,ACget_named_attribute;
  from GRgraphics	import 	GRdelete, GRdisplay;
  from NDnode		import 	NDdisconnect, NDchg_state, 
				NDconnect, NDget_objects;
  from NDmacro		import 	ACreturn_foot;
  from ASnode		import 	ASreturn_go;
  from GRvg		import 	GRputsymb, GRputname;
  from ACncpx		import 	ACmplace;

  from SMframe		import	SMgive_rel_position;


 
/* ----------------------------------------------------------------- */
/*
/* hilite the located objects 
/*
/**/


method DispAll(enum   GRdpmode mode)
{
int                     i, stat;
long			msg;
struct GRid             currentModule ;
struct GRlc_info        obj;


ex$get_cur_mod( id      = &currentModule.objid,
                osnum   = &currentModule.osnum ) ;

stat = om$send(msg = message SMCmdSurf.DispAll(mode),
			 		targetid = my_id,
					mode = OM_e_wrt_message);
if(!(stat & 1)){
 	printf("ERROR  hilite the cs\n");
}

if(me->dep_frame.obj_id.objid != NULL_OBJID){

        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->dep_frame.obj_id.objid,
                        targetos = me->dep_frame.obj_id.osnum );

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
for(i=0;i<me->nb_wrk;i++){
   if(me->frame[i].frame.obj_id.objid != NULL_OBJID){
        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->frame[i].frame.obj_id.objid,
                        targetos = me->frame[i].frame.obj_id.osnum );

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
   if(me->wrk_frame[i].frame.obj_id.objid != NULL_OBJID){
        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->wrk_frame[i].frame.obj_id.objid,
                        targetos = me->wrk_frame[i].frame.obj_id.osnum );

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
 int    i;

 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdSurf.verify_obj(sts),
			 		targetid = my_id,
					mode = OM_e_wrt_message);

 if(me->dep_frame.obj_id.objid != NULL_OBJID &&
        ! ( om$is_objid_valid( osnum = me->dep_frame.obj_id.osnum,
                               objid = me->dep_frame.obj_id.objid)&1) ){
        ex$message(msgnumb = SM_E_ErFrmDel);
        me->state = _terminate;
        return OM_S_SUCCESS;
 }
 for(i=0;i<MAX_PT;i++){
   if(me->frame[i].frame.obj_id.objid != NULL_OBJID &&
        ! ( om$is_objid_valid( osnum = me->frame[i].frame.obj_id.osnum,
                               objid = me->frame[i].frame.obj_id.objid)&1) ){
        ex$message(msgnumb = SM_E_ErFrmDel);
        me->state = _terminate;
        return OM_S_SUCCESS;
   }
   if(me->wrk_frame[i].frame.obj_id.objid != NULL_OBJID &&
        ! ( om$is_objid_valid( osnum = me->wrk_frame[i].frame.obj_id.osnum,
                               objid = me->wrk_frame[i].frame.obj_id.objid)&1) ){
        ex$message(msgnumb = SM_E_ErFrmDel);
        me->state = _terminate;
        return OM_S_SUCCESS;
   }

 }        
return OM_S_SUCCESS;

}


 /* ----------------------------------------------------------------- */ 
 /*
 /* store the dep_frame
 /*
 /**/
  
 method store_dep_frame(long *sts)
{
  char			name[MAX_CHAR];
  int			status;
  long			msg;
  struct GRid           currentModule ;
  struct GRlc_info      obj;
  struct GRobj_env	tmp;
  enum 	 GRdpmode 	mode;
  OMuword		classid;

  *sts = OM_S_SUCCESS;
   dp$erase_hilite(msg = &msg);
 
   FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
   mode = GRhe;
   ex$get_cur_mod( id      = &currentModule.objid,
                osnum   = &currentModule.osnum ) ;

   if(me->dep_frame.obj_id.objid != NULL_OBJID){
        status = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->dep_frame.obj_id.objid,
                        targetos = me->dep_frame.obj_id.osnum );

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
   tmp.obj_id = me->event1.located_object[0].located_obj;

   /* Retrieve the name of the dep_frame system */

   status = as$make_source(go_grid = tmp.obj_id,
                           mod_env = &me->event1.located_object[0].module_info,
                           as_os   = me->ModuleInfo.md_id.osnum,
                           as_grid = &tmp.obj_id);
   as$status();
   if(!(status&1)){*sts = OM_E_ABORT; return OM_S_SUCCESS;}
   tmp.mod_env = me->event1.located_object[0].module_info;

   om$get_classid( objid  = tmp.obj_id.objid,
   		   osnum  = tmp.obj_id.osnum,
   		   p_classid = &classid);
   if( om$is_ancestry_valid( superclassid = OPP_SMframe_class_id,
   			     subclassid   = classid) != OM_S_SUCCESS){
   	status = om$send(msg = message NDmacro.ACreturn_foot(
                                          &msg,
                                          "",
                                          &tmp.obj_id,
                                          &tmp.mod_env.md_env.matrix_type,
                                          tmp.mod_env.md_env.matrix
                                                          ),
                      targetid = tmp.obj_id.objid,
                      targetos = tmp.obj_id.osnum
   	);
   }
 

   /* verify the frame is on the axis x of the given cs */

   status = om$send(msg = message SMCmdSlShr.verif_frame(&msg,
						      &tmp),
 			 	targetid = my_id);
   if(!(status & msg & 1)) {
   		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 		"Invalid Frame");
		*sts = INV_LOC;
   		om$send(msg = message  SMCmdSlShr.DispAll(GRhhd),
                      			targetid = my_id);
		return OM_S_SUCCESS;
   }      
   name[0] = '\0';
   vd$get_name(name = name, obj = &tmp.obj_id );
   if(name[0] == '\0') strcpy(name,"defined");


   me->dep_frame = tmp;
   FIg_set_text(me->forms[0].form_ptr,FR_NAME,name);

   om$send(msg = message  SMCmdSlShr.DispAll(GRhhd),
                      			targetid = my_id);
 
  return OM_S_SUCCESS;
}



 /* ----------------------------------------------------------------- */ 
 /*
 /* store the frames
 /*
 /**/
  
 method store_frame(long *sts)
{
  char			name[MAX_CHAR];
  int			status;
  long			msg;
  IGRdouble		pos1, pos2;
  struct def_slope	tmp;
  OMuword		classid;

  *sts = OM_S_SUCCESS;
 
   dp$erase_hilite(msg = &msg);
   FIg_set_text(me->forms[1].form_ptr,FI_MSG_FIELD,"");
   tmp.frame.obj_id = me->event1.located_object[0].located_obj;
   /* Retrieve the name of the frame system */


   status = as$make_source(go_grid = tmp.frame.obj_id,
                           mod_env = &me->event1.located_object[0].module_info,
                           as_os   = me->ModuleInfo.md_id.osnum,
                           as_grid = &tmp.frame.obj_id);
   as$status();
   if(!(status&1)){*sts = OM_E_ABORT; return OM_S_SUCCESS;}
   tmp.frame.mod_env = me->event1.located_object[0].module_info;

   om$get_classid( objid  = tmp.frame.obj_id.objid,
   		   osnum  = tmp.frame.obj_id.osnum,
   		   p_classid = &classid);
   if( om$is_ancestry_valid( superclassid = OPP_SMframe_class_id,
   			     subclassid   = classid) != OM_S_SUCCESS){
   	status = om$send(msg = message NDmacro.ACreturn_foot(
                                          &msg,
                                          "",
                                          &tmp.frame.obj_id,
                                          &tmp.frame.mod_env.md_env.matrix_type,
                                          tmp.frame.mod_env.md_env.matrix
                                                          ),
                      targetid = tmp.frame.obj_id.objid,
                      targetos = tmp.frame.obj_id.osnum
   	);
   }


   /* verify the frame is on the axis x of the given cs */

   status = om$send(msg = message SMCmdSlShr.verif_frame(&msg,
						      &tmp.frame ),
 			 	targetid = my_id);
   if(!(status & msg & 1)) {
   		FIg_set_text(me->forms[1].form_ptr,FI_MSG_FIELD,
 		"Invalid Frame");
		*sts = INV_LOC;
   		FIfld_set_text(me->forms[1].form_ptr,DEF_FIELD,
			me->nb_wrk,1,"", FALSE);
   		om$send(msg = message  SMCmdSlShr.DispAll(GRhhd),
                      targetid = my_id);
		return OM_S_SUCCESS;
   }      

   /* verif the position */

   if(me->nb_wrk == 0){
         	status = om$send(msg = message SMframe.SMgive_rel_position(&msg,
                                                  &pos1),
                       senderid = NULL_OBJID,
                       targetid = me->dep_frame.obj_id.objid,
                       targetos = me->dep_frame.obj_id.osnum );
 		as$status();
		if(!(status & msg & 1)){
			FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
			"ERROR SMgive_rel_position");
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
		}
         	status = om$send(msg = message SMframe.SMgive_rel_position(&msg,
                                                  &pos2),
                       senderid = NULL_OBJID,
                       targetid = tmp.frame.obj_id.objid,
                       targetos = tmp.frame.obj_id.osnum );
 		as$status();
		if(!(status & msg & 1)){
			FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
			"ERROR SMgive_rel_position");
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
		}
		if(pos2 <= pos1){
			ex$message(msgnumb = SM_S_FrDfCsOrd);
			FIg_set_text(me->forms[1].form_ptr, FI_MSG_FIELD, 
				"Invalid Frame");
			*sts = INV_LOC;
   			om$send(msg = message  SMCmdSlShr.DispAll(GRhhd),
                      		targetid = my_id);
			return OM_S_SUCCESS;
		}
   }
   else{
         	status = om$send(msg = message SMframe.SMgive_rel_position(&msg,
                                                  &pos1),
                       senderid = NULL_OBJID,
                       targetid = me->wrk_frame[me->nb_wrk-1].frame.obj_id.objid,
                       targetos = me->wrk_frame[me->nb_wrk-1].frame.obj_id.osnum );
 		as$status();
		if(!(status & msg & 1)){
			FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
			"ERROR SMgive_rel_position");
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
		}
         	status = om$send(msg = message SMframe.SMgive_rel_position(&msg,
                                                  &pos2),
                       senderid = NULL_OBJID,
                       targetid = tmp.frame.obj_id.objid,
                       targetos = tmp.frame.obj_id.osnum );
 		as$status();
		if(!(status & msg & 1)){
			FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
			"ERROR SMgive_rel_position");
			*sts = OM_E_ABORT;
			return OM_S_SUCCESS;
		}
		if(pos2 <= pos1){
			ex$message(msgnumb = SM_S_FrDfCsOrd);
			FIg_set_text(me->forms[1].form_ptr, FI_MSG_FIELD, 
				"Invalid Frame");
			*sts = INV_LOC;
   			om$send(msg = message  SMCmdSlShr.DispAll(GRhhd),
                      		targetid = my_id);
			return OM_S_SUCCESS;
		}
   }

   vd$get_name(name = name, obj = &(tmp.frame.obj_id ));
   if(name[0] == '\0') strcpy(name,"defined");

   me->wrk_frame[me->nb_wrk] = tmp;
   FIfld_set_text(me->forms[1].form_ptr,DEF_FIELD,me->nb_wrk,1,name, FALSE);
   me->nb_wrk ++;
   om$send(msg = message  SMCmdSlShr.DispAll(GRhhd),
                      targetid = my_id);

  return OM_S_SUCCESS;
}


  /* ----------------------------------------------------------------- */ 
   
  method FormOn(int *sts)
  {
   *sts = OM_S_SUCCESS;
  
   (void)SMVA_enable(me->forms[0].form_ptr,16, 	OCC_NAME,
 						COORDINATE,
   						CS_NAME,
   						ORIENT,
   						FR_DX,
   						FR_FRAME,
   						HIGHT,
   						PTDEF_B,
   						EXTENSION,
   						EXT_X1,
   						EXT_X2,
   						EXT_Y1,
   						EXT_Y2,
   						FI_RESET,
   						FI_EXECUTE,
   						FI_ACCEPT,
   						LOAD);
   		
   return OM_S_SUCCESS;
   
  } 
 
  /* ----------------------------------------------------------------- */ 
   
  method FormOf(int *sts)
  {
   *sts = OM_S_SUCCESS;
  
   (void)SMVA_disable(me->forms[0].form_ptr,16, OCC_NAME,
 						COORDINATE,
   						CS_NAME,
   						ORIENT,
   						FR_DX,
   						FR_FRAME,
   						HIGHT,
   						PTDEF_B,
   						EXTENSION,
   						EXT_X1,
   						EXT_X2,
   						EXT_Y1,
   						EXT_Y2,
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
   long			test, msg;
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
   if(stat != OM_S_SUCCESS ){
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
  
   /* Get the dep_dx */
  
   strcpy(attr.name,"dep_dx");
   stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
  							&attr),
                          targetid= roots[1].objid,
                          targetos= roots[1].osnum);
   if(!(stat & msg & 1)) goto wrapup ;
   me->dep_dx = attr.desc.value.att_exp;
   SMConvDistIntExt(me->dep_dx, &me->dep_dx, me->ModuleInfo.md_id.osnum);
  
  
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
  
  
  
   /* Get the ext_y1 */
  
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

   /* Get the ext_y1 */
  
   strcpy(attr.name,"ext_y1");
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
  
   /* Get the nb_sl */
  
   strcpy(attr.name,"nb_sl");
   stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
  							&attr),
                          targetid= roots[1].objid,
                          targetos= roots[1].osnum);
   if(!(stat & msg & 1)) goto wrapup ;
   me->nb_sl = (int)attr.desc.value.att_exp;
  
   if(me->nb_sl == 0) {
  	ex$message(msgnumb = SM_S_NoSlDef);
  	goto wrapup;
   }
  
   /* Get the slope and dx*/
 
   for(i=0;i<me->nb_sl;i++){
 
  	sprintf(attr.name,"%s%d","slope",i);
   	stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
  							&attr),
                          targetid= roots[1].objid,
                          targetos= roots[1].osnum);
   	if(!(stat & msg & 1)) goto wrapup ;
   	me->frame[i].slope = attr.desc.value.att_exp *100;
  
  	sprintf(attr.name,"%s%d","dx",i);
   	stat = om$send(msg = message ACrg_collect.ACget_named_attribute(&msg, 
  							&attr),
                          targetid= roots[1].objid,
                          targetos= roots[1].osnum);
   	if(!(stat & msg & 1)) goto wrapup ;
   	me->frame[i].dx = attr.desc.value.att_exp;
 	SMConvDistIntExt(me->frame[i].dx, &me->frame[i].dx, me->ModuleInfo.md_id.osnum);
 
   	me->frame[i].frame.obj_id = roots[i+3]; 
   	stat = GetEnvFrObj( &roots[3+i], &me->frame[i].frame.mod_env, NULL);
    	as$status(sts = stat);
   	if(!(stat & 1)){
   		printf("ERROR GetEnvFrObj \n");         
   		*sts = OM_E_ABORT;
  		goto wrapup;
   	}
   	om$get_classid( objid  = me->frame[i].frame.obj_id.objid,
   		   osnum  = me->frame[i].frame.obj_id.osnum,
   		   p_classid = &classid);
   	if( om$is_ancestry_valid( superclassid = OPP_SMframe_class_id,
   			     subclassid   = classid) != OM_S_SUCCESS){
   		stat = om$send(msg = message NDmacro.ACreturn_foot(
                                          &msg,
                                          "",
                                          &me->frame[i].frame.obj_id,
                                          &me->frame[i].frame.mod_env.md_env.matrix_type,
                                          me->frame[i].frame.mod_env.md_env.matrix
                                                          ),
                      targetid = me->frame[i].frame.obj_id.objid,
                      targetos = me->frame[i].frame.obj_id.osnum
   		);
   	}
  
   }
  
   vd$get_name(name = me->def_name, obj = &me->macro_id);

   me->dep_frame.obj_id = roots[2]; 
   stat = GetEnvFrObj( &roots[2], &me->dep_frame.mod_env, NULL);
   if(!(stat & 1)){
   		printf("ERROR GetEnvFrObj \n");         
   		*sts = OM_E_ABORT;
  		goto wrapup;
   }
   om$get_classid( objid  = me->dep_frame.obj_id.objid,
   		   osnum  = me->dep_frame.obj_id.osnum,
   		   p_classid = &classid);
   if( om$is_ancestry_valid( superclassid = OPP_SMframe_class_id,
   			     subclassid   = classid) != OM_S_SUCCESS){
   		stat = om$send(msg = message NDmacro.ACreturn_foot(
                                          &msg,
                                          "",
                                          &me->dep_frame.obj_id,
                                          &me->dep_frame.mod_env.md_env.matrix_type,
                                          me->dep_frame.mod_env.md_env.matrix
                                                          ),
                      targetid = me->dep_frame.obj_id.objid,
                      targetos = me->dep_frame.obj_id.osnum
   		);
   }
  
  
   if(me->mytype == MODIFY) {
   		strcpy(me->old_def_name,me->def_name);
   		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->old_def_name);
 		me->old_macro_id = me->macro_id;
   		me->old_coord = me->coord;
   		me->old_z_pos = me->z_pos;
   		me->old_extension = me->extension;
   		me->old_dep_dx = me->dep_dx;
   		me->old_dep_frame = me->dep_frame;
   		me->old_nb_sl = me->nb_sl;
   		me->old_ext_x1 = me->ext_x1;
   		me->old_ext_x2 = me->ext_x2;
   		me->old_ext_y1 = me->ext_y1;
   		me->old_ext_y2 = me->ext_y2;
   		me->old_reverse = me->reverse;
  		for(i=0;i<me->old_nb_sl;i++)
 			me->old_frame[i] = me->frame[i];
   }
   else {
   	(void)GetDefName("SMSlSheer_0",me->def_name);
   	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
   }
  
   me->nb_wrk = me->nb_sl;
   for(i=0;i<me->nb_sl;i++) me->wrk_frame[i] = me->frame[i];
 
   vd$get_name(name = name, obj = &me->coord);
   if(name[0] == '\0') {
  	/* try get name on the graphic object */
  	vd$get_name(name = name, obj = &me->go_cs );
 	if(name[0] == '\0') strcpy(name, "defined");  
   }
   FIg_set_text(me->forms[0].form_ptr, CS_NAME,name);
 
   vd$get_name(name = name, obj = &(me->dep_frame.obj_id));
   if(name[0] == '\0') {
  	/* try get name on the graphic object */
  	vd$get_name(name = name, obj = &me->go_cs );
 	if(name[0] == '\0') strcpy(name, "defined");  
   }
   if(name[0] == '\0') strcpy(name,"defined");
   FIg_set_text(me->forms[0].form_ptr,FR_NAME,name);
 
 
   sprintf(name,"%g",me->z_pos);
   FIg_set_text(me->forms[0].form_ptr,HIGHT ,name);
  
   if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
   					"hull range +10%");
   else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
   					"bounded by hull");
   else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
   					"User Extend");
  
   if(me->extension == 2){ 
       		om$send(msg = message SMCmdSlShr.GadgOn(&test),
  			 	targetid = my_id);
   		FIfld_set_value(me->forms[0].form_ptr,EXT_Y1,0,0,me->ext_y1,FALSE);
   		FIfld_set_value(me->forms[0].form_ptr,EXT_Y2,0,0,me->ext_y2,FALSE);
   		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_x1,FALSE);
   		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_x2,FALSE);
   }
   else 
       		om$send(msg = message SMCmdSlShr.GadgOf(&test),
  			 	targetid = my_id);
  
   
   if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
   else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
 
   FIfld_set_value(me->forms[0].form_ptr,FR_DX,0,0,me->dep_dx,FALSE);
   om$send(msg = message  SMCmdSlShr.DispAll(GRhhd),
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

        SMGetDefCs(TRUE,(struct GRid *)NULL,(IGRshort *)NULL,&me->go_cs,
               &me->coord,&me->cs_env,(IGRboolean *)NULL);

 	me->dep_frame.obj_id.objid = NULL_OBJID;
   	me->z_pos = 0.;
   	me->extension = 0;
   	me->ext_y1 = 0.;
   	me->ext_y2 = 0.;
   	me->ext_x1 = 0.;
   	me->ext_x2 = 0.;
  	me->def_name[0] = '\0';
  	me->reverse = 0;
  	me->dep_dx = 0.;
  	me->nb_sl = 0;
  	me->nb_wrk = 0;
 
 	
 	for(i=0;i<MAX_PT;i++){
 		me->frame[i].dx =0.;
 		me->old_frame[i].dx =0.;
 		me->frame[i].slope =0.;
 		me->old_frame[i].slope =0.;
 		me->frame[i].frame.obj_id.objid = NULL_OBJID;
 		me->wrk_frame[i].frame.obj_id.objid = NULL_OBJID;
 		me->old_frame[i].frame.obj_id.objid = NULL_OBJID;
 	}
  
  	(void)GetDefName("SMSlSheer_0",me->def_name);
   	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
   }
   else {
  
   	me->coord = me->old_coord ;
   	if( !(GetEnvFrObj( &me->coord, &me->cs_env, &me->go_cs) & 1)){
   		printf("ERROR GetEnvFrObj \n");
		goto wrapup;
   	}
 	me->macro_id = me->old_macro_id ;
   	me->z_pos = me->old_z_pos;
   	me->extension = me->old_extension;
   	me->ext_y1 = me->old_ext_y1;
   	me->ext_y2 = me->old_ext_y2;
   	me->ext_x1 = me->old_ext_x1;
   	me->ext_x2 = me->old_ext_x2;
  	me->reverse = me->old_reverse;
  	me->dep_dx = me->old_dep_dx;
  	me->nb_sl = me->nb_wrk = me->old_nb_sl;
  	me->dep_frame = me->old_dep_frame;
   	for(i=0;i<me->nb_sl;i++) me->frame[i] = me->old_frame[i];
   	for(i=0;i<me->nb_sl;i++) me->wrk_frame[i] = me->old_frame[i];
  	strcpy(me->def_name, me->old_def_name);
   		
   	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  		
  	
   }
   
   vd$get_name(name = name, obj = &me->coord);
   if(name[0] == '\0') {
  	/* try get name on the graphic object */
  	vd$get_name(name = name, obj = &me->go_cs );
 	if(name[0] == '\0') strcpy(name, "defined");  
   }
   FIg_set_text(me->forms[0].form_ptr,CS_NAME,name);
 
   if(me->dep_frame.obj_id.objid != NULL_OBJID){
   	vd$get_name(name = name, obj = &(me->dep_frame.obj_id));
   	if(name[0] == '\0') strcpy(name,"defined");
   	FIg_set_text(me->forms[0].form_ptr,FR_NAME,name);
   }
   else FIg_set_text(me->forms[0].form_ptr,FR_NAME,"");
 
 
   sprintf(name,"%g",me->z_pos);
   FIg_set_text(me->forms[0].form_ptr,HIGHT ,name);
   if(me->extension == 0)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
   					"hull range +10%");
   else if(me->extension == 1)  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
   					"bounded by hull");
   else  FIg_set_text(me->forms[0].form_ptr, EXTENSION,
   					"User Extend");
  
   if(me->extension == 2){ 
       		om$send(msg = message SMCmdSlShr.GadgOn(&test),
  			 	targetid = my_id);
   		FIfld_set_value(me->forms[0].form_ptr,EXT_Y1,0,0,me->ext_y1,FALSE);
   		FIfld_set_value(me->forms[0].form_ptr,EXT_Y2,0,0,me->ext_y2,FALSE);
   		FIfld_set_value(me->forms[0].form_ptr,EXT_X1,0,0,me->ext_x1,FALSE);
   		FIfld_set_value(me->forms[0].form_ptr,EXT_X2,0,0,me->ext_x2,FALSE);
   }
   else 
       		om$send(msg = message SMCmdSlShr.GadgOf(&test),
  			 	targetid = my_id);
  
   if(me->reverse) FIg_set_state_on(me->forms[0].form_ptr, ORIENT);
   else FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
  		
   FIfld_set_value(me->forms[0].form_ptr,FR_DX,0,0,me->dep_dx,FALSE);
   
   if(me->mytype == MODIFY) om$send(msg = message  SMCmdSlShr.DispAll(GRhhd),
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
  
method clear_form( long *sts )
{
    long	test,msg;
    
   	
    	*sts = OM_S_SUCCESS;
    	dp$erase_hilite(msg = &msg);
  
  
  
  
   	me->z_pos = 0.;
   	me->extension = 0;
   	me->dep_dx = 0.;
   	me->nb_sl = 0;
   	me->nb_wrk = 0;
   	me->ext_y1 = 0.;
   	me->ext_y2 = 0.;
   	me->ext_x1 = 0.;
   	me->ext_x2 = 0.;
  	me->def_name[0] = '\0';
  	me->reverse = 0;
  
    	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
   	FIg_set_text(me->forms[0].form_ptr,OCC_NAME,"");
    	FIg_set_text(me->forms[0].form_ptr,HIGHT,"");
    	FIg_set_text(me->forms[0].form_ptr,CS_NAME,"");
    	FIg_set_text(me->forms[0].form_ptr,FR_NAME,"");
  	FIg_set_state_off(me->forms[0].form_ptr, ORIENT);
   	FIfld_set_value(me->forms[0].form_ptr,FR_DX,0,0,me->dep_dx,FALSE);
  	if(me->mytype == MODIFY) FIg_erase(me->forms[0].form_ptr, LOAD);
  
       	om$send(msg = message SMCmdSlShr.GadgOf(&test),
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
 int 			i, k, nb_roots,sel_flag, nb_att, r_pos, stat;
 char 			text[MAX_CHAR];
 long			sizebuf, test, nret, msg;
 IGRdouble		pos1, pos2;
 struct GRid 		mac, roots[MAX_PT+3];
 struct GRsymbology	symb;
 struct ACrg_coll	ACrg[2*MAX_PT+9];
 IGRdouble		val,ext_x1, ext_x2,ext_y1, ext_y2, dep_dx, z_pos, dx;

 *sts = OM_S_SUCCESS;
   	
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
 
 FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"");
  
 stat = om$send(msg = message SMCmdSurf.GetInfoFrmForm(&test, &ext_x1, &ext_x2,
					&ext_y1, &ext_y2),
			 	targetid = my_id);

 as$status(sts = stat);
 if(!(stat & test & 1)){
     	printf("ERROR  SMCmdSurf.GetInfoFrmForm\n"); 
	*sts =  OM_E_ABORT; 
	goto quit;
 }

 if(me->nb_sl > MAX_PT) {
	ex$message(msgnumb = SM_S_TooSlDef);
  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
			"ERROR, too much slopes defined");
   	*sts =  OM_E_ABORT;
   	goto quit;
 }
 if(me->nb_sl == 0) {
	ex$message(msgnumb = SM_S_NoSlDef);
  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
			"ERROR, No slopes defined");
   	*sts =  OM_E_ABORT;
   	goto quit;
 }
 if(me->dep_frame.obj_id.objid == NULL_OBJID){
     	ex$message(msgnumb = SM_S_FFrNotDef);
  	FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
			"ERROR, from frame not defined");
	*sts =  OM_E_ABORT; 
	goto quit;
 }

 /* verif_frame */
	
 stat = om$send(msg = message SMCmdSlShr.verif_frame(&msg,
						      &me->dep_frame ),
 			 	targetid = my_id);
   	if(!(stat & msg & 1)) {
   		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 		"Invalid Frame");
		*sts = OM_E_ABORT;
		goto quit;
 } 
   	
 for(i=0;i<me->nb_sl;i++){
   	stat = om$send(msg = message SMCmdSlShr.verif_frame(&msg,
						      &me->frame[i].frame ),
 			 	targetid = my_id);
   	if(!(stat & msg & 1)) {
   		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,
 			"Invalid Frame");
		*sts = OM_E_ABORT;
		goto quit;
   	} 
 }			
 if(me->frame[0].frame.obj_id.objid != NULL_OBJID){
         	stat = om$send(msg = message SMframe.SMgive_rel_position(&msg,
                                                  &pos1),
                       senderid = NULL_OBJID,
                       targetid = me->dep_frame.obj_id.objid,
                       targetos = me->dep_frame.obj_id.osnum );
 		as$status(sts = stat);
		if(!(stat & msg & 1)){
			FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
			"ERROR SMgive_rel_position");
			*sts = OM_E_ABORT;
			goto quit;
		}
         	stat = om$send(msg = message SMframe.SMgive_rel_position(&msg,
                                                  &pos2),
                       senderid = NULL_OBJID,
                       targetid = me->frame[0].frame.obj_id.objid,
                       targetos = me->frame[0].frame.obj_id.osnum );
 		as$status(sts = stat);
		if(!(stat & msg & 1)){
			FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
			"ERROR SMgive_rel_position");
			*sts = OM_E_ABORT;
			goto quit;
		}
		if(pos2 <= pos1){
			ex$message(msgnumb = SM_S_FrDfCsOrd);
			FIg_set_text(me->forms[0].form_ptr, FI_MSG_FIELD, 
				"Invalid Frames");
			*sts = OM_E_ABORT;
			goto quit;
		}
 }
 
 FIfld_get_value(me->forms[0].form_ptr, FR_DX, 0, 0, &me->dep_dx, 
   			&sel_flag, &r_pos);
 
 SMConvDistExtInt(me->dep_dx, &dep_dx, me->ModuleInfo.md_id.osnum);

 FIg_get_text(me->forms[0].form_ptr, HIGHT, text);
 if(text[0] != '\0') sscanf(text,"%lf",&me->z_pos);
 else me->z_pos = 0.;
 SMConvDistExtInt(me->z_pos, &z_pos, me->ModuleInfo.md_id.osnum);
 
 /* place the macro */
 
 if(me->mytype == PLACE){ 
   	mac.objid = NULL_OBJID;
   	mac.osnum = me->ModuleInfo.md_id.osnum;
  
   	stat = om$construct(classid = OPP_SMSlSheer_class_id,
                            	osnum   = mac.osnum,
                            	p_objid = &mac.objid );
	as$status(sts = stat);
   	if(!(stat & 1)){
      		printf("erreur creating macro\n"); 
 		*sts =  OM_E_ABORT; 
 		goto quit;
   	}
   			
 }
 nb_roots = me->nb_sl+3;
 roots[0] = me->coord;
 
 /* Construct the ACrg_collect */
 
 
 strcpy(ACrg[0].name,"z_pos");
 ACrg[0].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[0].desc.value.att_exp = z_pos;
 
 strcpy(ACrg[1].name,"dep_dx");
 ACrg[1].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[1].desc.value.att_exp = dep_dx;
 
 strcpy(ACrg[2].name,"extension");
 ACrg[2].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[2].desc.value.att_exp = (IGRdouble) me->extension;
 
 
 strcpy(ACrg[3].name,"reverse");
 ACrg[3].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[3].desc.value.att_exp = (IGRdouble) me->reverse;
 
 
 strcpy(ACrg[4].name,"ext_x1");
 ACrg[4].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[4].desc.value.att_exp = ext_x1;
 
 strcpy(ACrg[5].name,"ext_x2");
 ACrg[5].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[5].desc.value.att_exp = ext_x2;

 strcpy(ACrg[6].name,"ext_y1");
 ACrg[6].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[6].desc.value.att_exp = ext_y1;
 
 strcpy(ACrg[7].name,"ext_y2");
 ACrg[7].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[7].desc.value.att_exp = ext_y2;
 
 strcpy(ACrg[8].name,"nb_sl");
 ACrg[8].desc.type = AC_ATTRIB_DOUBLE;
 ACrg[8].desc.value.att_exp = (IGRdouble) me->nb_sl;
 
 k=9;
 for(i=0;i<me->nb_sl;i++){
 	sprintf(ACrg[k].name,"%s%d","slope",i);
   	ACrg[k].desc.type = AC_ATTRIB_DOUBLE;
	val = me->frame[i].slope/100;
   	ACrg[k].desc.value.att_exp = (IGRdouble) val;
 	k++;
 
	SMConvDistExtInt(me->frame[i].dx, &dx, me->ModuleInfo.md_id.osnum);
 	sprintf(ACrg[k].name,"%s%d","dx",i);
   	ACrg[k].desc.type = AC_ATTRIB_DOUBLE;
   	ACrg[k].desc.value.att_exp = (IGRdouble) dx;
 	k++;
 }
 
 nb_att = 2*me->nb_sl +9;
 stat = as$make_source(
      				go_grid = me->dep_frame.obj_id,
 			     	mod_env = &me->dep_frame.mod_env,
 			     	as_os   = me->ModuleInfo.md_id.osnum,
 			     	as_grid = &roots[2]);
 as$status(sts = stat);
 if(!(stat & 1)){ 
  	printf("ERROR as$make_source\n");
  	*sts = OM_E_ABORT;
  	goto quit;
 } 
 for(i=0;i<me->nb_sl;i++){
      	stat = as$make_source(
      				go_grid = me->frame[i].frame.obj_id,
 			     	mod_env = &me->frame[i].frame.mod_env,
 			     	as_os   = me->ModuleInfo.md_id.osnum,
 			     	as_grid = &roots[3+i]);
      	as$status(sts = stat);
        if(!(stat & 1)){
  			printf("ERROR as$make_source\n");
  			*sts = OM_E_ABORT;
  			goto quit;
        } 
 }
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
                     			"SMSlSheer",nb_roots, roots,&me->ModuleInfo),
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
 
	stat = om$send(msg = message SMCmdSlShr.SMmodif_mac
						(nb_att, ACrg, nb_roots, roots),
			 		targetid = my_id);
 	if(!(stat & 1)){
 			printf("ERROR  SMCmdSlShr.SMmodif_mac\n");
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
 		me->old_macro_id = me->macro_id;
   		me->old_coord = me->coord;
   		me->old_z_pos = me->z_pos;
   		me->old_extension = me->extension;
   		me->old_dep_dx = me->dep_dx;
   		me->old_dep_frame = me->dep_frame;
   		me->old_nb_sl = me->nb_sl;
   		me->old_ext_x1 = me->ext_x1;
   		me->old_ext_x2 = me->ext_x2;
   		me->old_ext_y1 = me->ext_y1;
   		me->old_ext_y2 = me->ext_y2;
   		me->old_reverse = me->reverse;
  		for(i=0;i<me->old_nb_sl;i++)
 			me->old_frame[i] = me->frame[i];
  	}
  	else 	{
  		FIg_set_text(me->forms[0].form_ptr,FI_MSG_FIELD,"Place Successfull");
 		ex$message(msgnumb = SM_S_PlSucc);
  		(void)GetDefName("SMSlSheer_0",me->def_name);
   		FIg_set_text(me->forms[0].form_ptr,OCC_NAME,me->def_name);
  	}
 }
   
   return OM_S_SUCCESS;
}
 
  /* ----------------------------------------------------------------- */ 
 method cleardef(long *sts )
{
 int			 i,stat, num_rows;
 long			 msg;
 struct GRlc_info        obj;
 struct GRid             currentModule ;
 enum   GRdpmode 	 mode;

 mode = GRhe;
 ex$get_cur_mod( id      = &currentModule.objid,
                osnum   = &currentModule.osnum ) ;

 for(i=0;i<me->nb_wrk;i++){
   if(me->wrk_frame[i].frame.obj_id.objid != NULL_OBJID){
        stat = om$send( msg = message ASnode.ASreturn_go(
                                          &obj.located_obj,
                                          &obj.module_info.md_env.matrix_type,
                                          obj.module_info.md_env.matrix),
                        senderid = NULL_OBJID,
                        targetid = me->wrk_frame[i].frame.obj_id.objid,
                        targetos = me->wrk_frame[i].frame.obj_id.osnum );

        stat = om$send(msg     = message GRgraphics.GRdisplay(
                                sts,
                                &obj.module_info.md_env.matrix_type,
                                obj.module_info.md_env.matrix,
                                &mode,
                                &currentModule ),
                targetid= obj.located_obj.objid,
                targetos= obj.located_obj.osnum ) ;
	as$status(sts = stat);
	me->wrk_frame[i].frame.obj_id.objid = NULL_OBJID;
   }
 }
 om$send(msg = message SMCmdSlShr.set_single_select_mode(&msg,
					me->forms[1].form_ptr, DEF_FIELD,3),
  			 	targetid = my_id);
 stat = FIfld_get_num_rows(me->forms[1].form_ptr,DEF_FIELD, &num_rows);
 if(stat != FI_SUCCESS) {
                 printf("error FIfld_get_num_rows: %d\n",stat);
                 *sts = OM_E_ABORT;
                 return OM_S_SUCCESS;
 }
 if(num_rows){
 	stat = FIfld_delete_rows(me->forms[1].form_ptr,DEF_FIELD,0,num_rows);
 	if(stat != FI_SUCCESS){
 			printf("error FIfld_delete_rows: %d\n",stat);
 			*sts = OM_E_ABORT;
 			return OM_S_SUCCESS;
 	}
 }
 me->nb_wrk = 0;
 return OM_S_SUCCESS;
 
}
  /* ----------------------------------------------------------------- */ 
  /*
  /* Get the info from the form 2 
  /* 
  /**/
   
method savedef(long *sts )
{
 int		i, sel_flag, r_pos;
 char		text[MAX_CHAR];
 
   *sts = OM_S_SUCCESS;
 
   for(i=0;i<me->nb_wrk;i++){
   	FIfld_get_text(me->forms[1].form_ptr, DEF_FIELD, i, 0, 
			MAX_CHAR, text, &sel_flag, &r_pos);
 	if(text[0] != '\0') sscanf(text,"%lf",&me->wrk_frame[i].slope);
	else {
		FIg_set_text(me->forms[1].form_ptr, FI_MSG_FIELD, 
			"All slope must be defined");
		*sts = OM_E_ABORT;
		goto wrapup;
	}
   	FIfld_get_text(me->forms[1].form_ptr, DEF_FIELD, i, 2, 
			MAX_CHAR,text, &sel_flag, &r_pos);
 	if(text[0] != '\0') sscanf(text,"%lf",&me->wrk_frame[i].dx);
	else {
		FIg_set_text(me->forms[1].form_ptr, FI_MSG_FIELD, 
			"All dx must be defined ");
		*sts = OM_E_ABORT;
		goto wrapup;
	}
   }
   me->nb_sl = me->nb_wrk;
   for(i=0;i<me->nb_sl;i++) me->frame[i] = me->wrk_frame[i];
 
 
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
 long		test;
 char		name[MAX_CHAR];
  

 *sts = OM_S_SUCCESS;

 om$send(msg = message SMCmdSlShr.set_single_select_mode(&test,
					me->forms[1].form_ptr, DEF_FIELD,3),
  			 	targetid = my_id);


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
 
 if(me->nb_sl){
 	for(i=0;i<me->nb_sl;i++){
   		sprintf(name,"%g",me->frame[i].slope);
 		FIfld_set_text(me->forms[1].form_ptr, DEF_FIELD, i, 0,
                                 name, FALSE);
   		vd$get_name(name = name, obj = &(me->frame[i].frame.obj_id));
    		if(name[0] == '\0') strcpy(name,"defined");
    		FIfld_set_text(me->forms[1].form_ptr,DEF_FIELD,i,1,name, FALSE);
   		sprintf(name,"%g",me->frame[i].dx);
 		FIfld_set_text(me->forms[1].form_ptr, DEF_FIELD, i, 2,
                                 name, FALSE);
 
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
 int			i, nb_temp, cn_type,wait_batch, oldnb_roots, stat;
 struct GRid 		original, *old_roots;
 IGRboolean		discon,put_batch = FALSE;
   
 old_roots = NULL;
 oldnb_roots = 0;

 
 stat = om$send(msg = message NDnode.NDget_objects
                   (ND_ROOT | ND_IN_BUF,NULL,0,&old_roots,0,OM_K_MAXINT,
					&oldnb_roots),
	senderid = NULL_OBJID,
	targetid = me->macro_id.objid,
	targetos = me->macro_id.osnum );
 as$status(sts = stat);
 if(stat != OM_S_SUCCESS || oldnb_roots > MAX_TEMP ){
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

 discon = FALSE;
  
 if( oldnb_roots != nb_new) discon = TRUE;
 i = 2;
 while(discon == FALSE && i<oldnb_roots && i< nb_new ){
  		if(old_roots[i].objid != new[i].objid ||
  		   old_roots[i].osnum != new[i].osnum)
  		   	discon = TRUE;
  		i++;	   
 }

  if(discon){ 
	put_batch = TRUE;
        nb_temp = oldnb_roots - 2;
  	stat = om$send(msg = message NDnode.NDdisconnect
		      (nb_temp, &old_roots[2]),
                   		senderid = NULL_OBJID,
                   		targetid = me->macro_id.objid,
                   		targetos = me->macro_id.osnum );
  	as$status(sts = stat);
  	if(!(stat & 1)){
		printf("Erreur NDnode.NDdisconnect\n");
		return OM_E_ABORT;
  	}
        nb_temp = nb_new - 2;
  	NDduplicate_root(nb_temp, &new[2]);
  	original.objid = NULL_OBJID;
  	stat = om$send(msg = message NDnode.NDconnect
		      (nb_temp, &new[2], original, ND_ADD),
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

 
 end implementation SMCmdSlShr;
 
 
 
 
