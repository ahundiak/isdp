class implementation EMAdatpln;

#include "EMSopt.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "exdef.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "nddef.h"

#define TOL 0.000001

from EMSdatplnmgr import EMmanage_datum_entry,
                         EMget_info,
                         EMactivate,
			 EMget_datums;

from ACpretdef import	 ACfind_parent;

from expression import NDgive_value;

from IGRdir 	import	translate;

/* **************************************************************************
 * Description
 * This is the recomputation/placement function which creates associative 
 * reference planes from a coordinate system. 
 *
 * Notes
 *  Upon exit the completion code will be one of the following:
 *  EMS_S_Success : If all goes well
 *  EMS_E_Fail : If there is failure of sorts
 *  EMS_E_InvalidArg: If the function does not get one parent that it is 
 *                    expecting.
 *
 * Arguments
 * EMmsg : I/O : Completion code.
 * options : I   : This is set to EMSasconst_recompute if the function is being
 *                 in a recompuation scenario
 * old_objid : I : Objid of the old object during recomputation. Is set to 
 *                 NULL_OBJID during placement.
 * new_objid : I : Objid of the new object that is to replace the old object
 * num_parents : I : Number of parents. This function is only expecting one
 *                   parent (i.e the coordinate system)
 * parent_info : I : Information about parents
 * recomp_info : I : This function expects recomputation information to be
 *                   stored and interprets the same as follows:
 *                   0: Reference plane parallel to xy of the coordinate system
 *                   1: Reference plane parallel to yz of the coordinate system
 *                   2: Reference plane parallel to zx of the coordinate system
 * construct_list : I : Construction information
 * mod_new_id : O : This function sets the mod_new_id to be equal to new_objid
 *                  if successful else it sets to NULL_OBJID.
 *
 * WARNING:
 *  Do not change the name of this function. If you do then you need to provide
 *  an on the fly converter for taking care of objects that have been created.
 * 
 * History
 *  Creation : PP : 11/25/92
 ********************************************************************** */

 

IGRint EFrefpln_from_cs(EMmsg, options, old_objid, new_objid,num_parents,
                        parent_info, recomp_info, construct_list, mod_new_id)
IGRlong *EMmsg;
IGRuint options;
GRobjid old_objid;
GRobjid new_objid;
IGRint num_parents;
IGRchar *parent_info;
IGRchar *recomp_info;
struct GRvg_construct *construct_list;
GRobjid *mod_new_id;
{
 IGRlong status,msg_loc;
 IGRchar type;
 IGRuint root_count;
 IGRuint root_type;
 IGRdouble *xptr, *yptr, *zptr, def_size;
 IGRvector xdir, ydir, zdir;
 IGRpoint origin;
 OMuword cnstr_os;
 union EMSparent_info roots;
 IGRlong EFreplace_old_with_new();
 IGRdouble EFget_default_reference_plane_size();

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;
 msg_loc = EMS_S_Success;

 root_count = num_parents;
/*
 * This function gets the default reference plane size. 
 */

 def_size = EFget_default_reference_plane_size();

 if (root_count != 1)
 {
  *EMmsg = EMS_E_InvalidArg;
  goto wrapup;
 }

 root_type = EMSlcinfo;
 cnstr_os = construct_list->env_info->md_id.osnum;

/*
 * This message gets the real parents.
 */

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg,NULL,
                   root_count, parent_info, &root_type,&roots),
                   senderid = new_objid,
                   targetid = new_objid);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail,wrapup);


 EFget_orientation_from_parent(&msg_loc,
           &roots.lc_info.located_obj,
           &roots.lc_info.module_info,
           xdir,
           ydir,
           zdir,
           origin);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail,wrapup);
  
 type = (IGRchar )*recomp_info;

 if (type == 0) /* Plane parallel to xy of the coordinate system */
 {
  xptr = xdir;
  yptr = ydir;
  zptr = zdir;
 }
 else if (type == 1) /* Plane parallel to yz of the coordinate system */
 {
  xptr = ydir; 
  yptr = zdir; 
  zptr = xdir;
 }
 else if (type == 2) /* Plane parallel to xz of the coordinate system */
 {
  /* 
   * SRH : 8/4/93 : corrected values of yptr for TR # 119300851 in 
   *                version  2.4.0.10 of MODEL.
   */
  xptr = xdir;
  yptr = zdir;
  zptr = ydir;

 }
 else if (type == 3) /* Planes created prior to version 2.2  */
 {
  /* 
   * Sudha : 07/18/94 : change from xz to zx fix for TR# 119418487
   */
  xptr = zdir;
  yptr = xdir;
  zptr = ydir;
 }

/*
 * This message stores the x, y and z information about the reference plane
 * in the instance data.
 */

 status = om$send (msg = message EMSdatpln.EMput_pln_info (&msg_loc,
                         EMS_OPT_SET_EXTERNAL_CONSTRAINT,
                         construct_list->env_info,
                         xptr,
                         yptr,
                         zptr, /* arg ignored by EMput_pln_info method */
                         origin,
                         NULL),
                   senderid = NULL_OBJID,
                   targetid = new_objid,
                   targetos = cnstr_os);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

/*
 * This message creates the handle for the reference plane 
 */

 status = om$send (msg = message EMSdatpln.EMcreate_resize_handle(&msg_loc,
                         EMS_OPT_DISPLAY_HANDLE,
                         construct_list->env_info,
                         construct_list,
                         def_size,
                         def_size,
                         NULL),
                   senderid = NULL_OBJID,
                   targetid = new_objid,
                   targetos = cnstr_os);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

/*
 * This function determines if the old reference plane was active and if so
 * makes sure that the new reference is active too.
 */

 status = EFreplace_old_with_new(&msg_loc, construct_list->env_info,old_objid, 
                         new_objid);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
 *mod_new_id = new_objid;

wrapup:
 return (status);
}

/*
 * Description
 * This is the placement function that gets called from the command. This
 * creates reference planes parallel to an input coordinate system and
 * activates the reference plane that is parallel to the xy of the coordinate
 * system.
 *
 * Arguments
 *  EMmsg : I/O : Completion code
 *  options : I : If set to EMSasconst_notassociative then a non-associative
 *                reference planes will get constructed.
 *  cs_info : I : Input coordinate system
 *  construct_list : I : Construction information
 *  res_id   : O : Three reference planes parallel to the xy, yz and zx of the
 *                 input coordinate system. The caller is expected to pass an
 *                 array capable of holding 3 object ids.
 *
 * Notes
 *  Upon exit the completion code will be:
 *    EMS_S_Success : If all goes well
 *    EMS_E_Fail    : If there is some form of failure
 *
 * History
 *  Creation : PP : 11/25/92
 *********************************************************************** */


IGRlong EFcreate_ref_plane_from_cs(EMmsg, 
                                   options, 
                                   cs_info,
                                   construct_list, 
                                   res_id)
IGRlong *EMmsg;
IGRuint options;
struct GRlc_info *cs_info;
struct GRvg_construct *construct_list;
OM_S_OBJID *res_id;
{
 OMuword constros;
 IGRint num_parents = 1,i;
 IGRlong status;
 struct EMSobject_info list;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 for (i=0;i<3;i++)
  res_id[i] = NULL_OBJID;

 list.grid = cs_info->located_obj;
 list.env =  cs_info->module_info;
 num_parents = 1;
 constros = construct_list->env_info->md_id.osnum;
  
 for (i=0;i<3;i++)
 {
  IGRchar charstuff;

  OM_S_OBJID new_objid;

  status = om$construct(classid = OPP_EMAdatpln_class_id,
                       p_objid = &res_id[i],
                       osnum = constros);
  EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, wrapup);

  charstuff = i;
  status = om$send (msg = message EMSassoc.EMinit_associative_function(EMmsg,
                         NULL,num_parents,&list,"EFrefpln_from_cs",
                         sizeof (IGRchar),(IGRchar *) &charstuff,construct_list, 
                         &new_objid),
                   senderid = NULL_OBJID,
                   targetid = res_id[i],
                   targetos = constros);
  EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  res_id[i] = new_objid;

  if (i == 0)
  {
   OM_S_OBJID mgrid;
   OMuword mgros;
   
   status = ems$get_datum_plane_mgr(msg = EMmsg,
                                   osnum = &constros,
                                   mgrid = &mgrid,
                                   mgros = &mgros);
   if (!(1&status&*EMmsg)) goto wrapup;

   status = om$send (msg = message EMSdatplnmgr.EMactivate(EMmsg,NULL,
                           &res_id[0],NULL),
                     senderid = NULL_OBJID,
                     targetid = mgrid,
                     targetos = mgros);
   if (!(1&status&*EMmsg)) goto wrapup;
  }

  if (options & EMSasconst_notassociative)
  {
   struct GRid src_GRid;
   src_GRid.objid = NULL_OBJID;
   status = om$send (msg = message NDnode.NDmove_to_root(EMmsg,
                          &src_GRid, construct_list->env_info),
                    senderid = new_objid,
                    targetid = new_objid,
                    targetos = constros);
   if (1&status&*EMmsg)
    res_id[i] = src_GRid.objid;
   else
   {
    *EMmsg = EMS_E_Fail;
    goto wrapup;
   }
  }
 }

wrapup:
 if (!(1&status&*EMmsg))
 {
  IGRlong l_msg;

  for (i=0;i<3;i++)
  {
   if (res_id[i] != NULL_OBJID)
   {
     om$send (msg = message GRgraphics.GRdelete(&l_msg,
                  construct_list->env_info),
            senderid = NULL_OBJID,
            targetid = res_id[i],
            targetos = constros);
     res_id[i] = NULL_OBJID;
   }
  }
 }
 return (status);
}

IGRlong EFreplace_old_with_new(EMmsg, md_env,old_objid, new_objid)
IGRlong *EMmsg;
struct GRmd_env *md_env;
OM_S_OBJID old_objid;
OM_S_OBJID new_objid;
{
 IGRlong msg_loc,status;
 OM_S_OBJID mgrid;
 OMuword mgros, cnstr_os;

 status = OM_S_SUCCESS;
 msg_loc = EMS_S_Success;
 *EMmsg = EMS_S_Success;

 cnstr_os = md_env->md_id.osnum;

 status = ems$get_datum_plane_mgr(msg = &msg_loc,
                                  osnum = &cnstr_os,
                                  mgrid = &mgrid,
                                  mgros = &mgros);
 if (!(1&status&msg_loc)) goto wrapup;

 status = om$send (msg = message EMSdatplnmgr.EMmanage_datum_entry(&msg_loc,
                         EMS_OPT_ADD,new_objid),
                   senderid = NULL_OBJID,
                   targetid = mgrid,
                   targetos = mgros);
 EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

 if (old_objid != NULL_OBJID)
 {
  IGRshort action;
  IGRshort old_props = 0, new_props = 0;
  OM_S_OBJID active_datum;
  OM_S_CHANSELECT to_comps;

  EMmake_chanselect (GRcmpowner_to_components, &to_comps);

  status = om$send (msg = message GRgraphics.GRgetprops(&msg_loc,
                           &old_props),
                     p_chanselect = &to_comps,
                     senderid = old_objid);
  if (!(1&status&msg_loc))
  {
   status = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success; 
   old_props = 0;
  }

  status = om$send (msg = message EMSdatplnmgr.EMget_info(&msg_loc,NULL,NULL,
                        NULL, &active_datum,NULL),
                    senderid = NULL_OBJID,
                    targetid = mgrid,
                    targetos = mgros);
  EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);

  if ((active_datum == old_objid) &&
       (!(ex$is_invis(mod_osnum = cnstr_os)))) 
  {
    status = om$send (msg = message EMSdatplnmgr.EMactivate(&msg_loc,
                          NULL, &new_objid, NULL),
                      senderid = NULL_OBJID,
                      targetid = mgrid,
                      targetos = mgros);
    EMerr_hndlr(!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
   }


   new_props = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
   if ((old_props & GRIS_DISPLAYABLE) &&
       (old_props & GRIS_LOCATABLE))
    action = 1;
   else
    action = 0;

   status = om$send (msg = message GRgraphics.GRchgprops(&msg_loc, &action,
                          &new_props),
                     p_chanselect = &to_comps,
                     senderid = new_objid);
   EMerr_hndlr (!(1&status&msg_loc), *EMmsg, EMS_E_Fail, wrapup);
  }

wrapup:
 return (status);
}

IGRdouble EFget_default_reference_plane_size()
{
 IGRdouble def_size;
 IGRlong status;
 OM_S_OBJID expid;
 OMuword expos;

 status = OM_S_SUCCESS;

 status = di$translate(objname="def_refpln_size",
                       p_objid = &expid,
                       p_osnum = &expos);
 if (status == DIR_S_SUCCESS)
 {
  status = om$send (msg = message expression.NDgive_value(&def_size),
                          senderid = NULL_OBJID,
                          targetid = expid,
                          targetos = expos);
 }
 else
  def_size = 5;

 return (def_size);
}

/* 	20/sep/94	Sudha	Fix TR# 119418487 - added validation code for
				reference planes to check its orientation
				and correct it if it is a pre 2.2 
*/

EMvalidate_refplane()
{
   IGRchar 		*recomp_info, type1, macrolib_path[DI_PATH_MAX];
   IGRuint 		type, modify_rep_type, num_parents, info_size,
			num, index;
   IGRint 		i, j, datum_count;
   IGRlong 		sts, msg_loc, NumberOfBytes, BytesReceived;
   IGRvector 		xdir, ydir, zdir;
   IGRdouble 		xptr[3], yptr[3], zptr[3], optr[3];
   IGRpoint 		origin;

   struct GRid 		*datums_GRid, datpln_mgrid, dummy_grid, ret_grid,
			construct, macro_defn_grid;

   OM_S_CHANSELECT      father, children;
   OM_S_OBJECT_LINKAGE  *parents = NULL, *list = NULL;

   struct GRmd_env      module_info, parent_env;

   extern OMuword       OPP_ACpretdef_class_id, OPP_ASsource_class_id,
			OPP_ACmacro_defn_class_id;

   datums_GRid = NULL;
   sts = msg_loc = OM_S_SUCCESS;

   /******************  PLEASE MAKE SURE NOT TO USE i AS INDEX INCASE YOU
	ARE MODIFYING THIS FILE , IT IS ALREADY BEING USED *************/

   sts = ems$get_datum_plane_mgr (msg = &msg_loc,
			          mgrid = &datpln_mgrid.objid,
			          mgros = &datpln_mgrid.osnum);
   if (!(1&sts&msg_loc)) goto wrapup;

   sts = om$send (msg = message EMSdatplnmgr.EMget_datums (&msg_loc,
			   EMS_OPT_OFF_DATUMS | EMS_OPT_ON_DATUMS |
                           EMS_OPT_HIDDEN_DATUMS | EMS_OPT_BASE_DATUMS,
			   &datum_count, (struct GRid *)NULL),
		  senderid = NULL_OBJID,
		  targetid = datpln_mgrid.objid,
		  targetos = datpln_mgrid.osnum);

   if ( !(1 & sts & msg_loc) ) goto wrapup;

   if (datum_count)
      datums_GRid = (struct GRid *) malloc(datum_count*sizeof (struct GRid));

   if (datums_GRid == NULL)
     goto wrapup;

   sts = om$send (msg = message EMSdatplnmgr.EMget_datums (&msg_loc,
			   EMS_OPT_OFF_DATUMS | EMS_OPT_ON_DATUMS |
                           EMS_OPT_HIDDEN_DATUMS | EMS_OPT_BASE_DATUMS,
			   &datum_count, datums_GRid),
		  senderid = NULL_OBJID,
                  targetid = datpln_mgrid.objid,
		  targetos = datpln_mgrid.osnum);
   if ( !( 1 & sts & msg_loc ) ) goto wrapup;

   EMmake_chanselect (NDfather_father, &father);
   EMmake_chanselect (NDchildren_children, &children);

   NumberOfBytes = sizeof(module_info);
   gr$get_module_env( msg = &msg_loc,
		      sizbuf = &NumberOfBytes,
		      buffer = &module_info,
		      nret = &BytesReceived);

   for ( i = 0; i < datum_count; i++ )
   {

     sts = om$get_channel_count (objid = datums_GRid[i].objid,
                                 osnum = datums_GRid[i].osnum,
                                 p_chanselect = &father, 
                                 count = (OMuint *) &num_parents);
     if ( !( 1 & sts ) ) goto wrapup;     

     if (num_parents)
     {
        parents = (OM_S_OBJECT_LINKAGE *) alloca(num_parents * 
                                                 sizeof(OM_S_OBJECT_LINKAGE));
	if ( !parents )
            goto wrapup;
     } else
        continue;

     sts =  om$get_channel_objects (objid = datums_GRid[i].objid, 
                           	    osnum = datums_GRid[i].osnum,
                          	    p_chanselect = &father,
                          	    count = (OMuint *) &num_parents,
                                    size = num_parents,
                                    list = parents);

     for ( j = 0; j < num_parents; j ++ ) {

       if ( (! EFisAncestryValid(&msg_loc, parents[j].S_objid, parents[j].osnum,
			      OPP_ACpretend_class_id, 0)) &&
   	    (! EFisAncestryValid(&msg_loc, parents[j].S_objid, parents[j].osnum,
			      OPP_ASsource_class_id, 0)) )
	 continue;


       if (EFisAncestryValid(&msg_loc, parents[j].S_objid, parents[j].osnum,
			      OPP_ASsource_class_id, 0)) {
          /* get return go */
          sts = om$send(msg = message NDnode.ASreturn_go(&dummy_grid,NULL,NULL),
     		        senderid = NULL_OBJID,
                        targetid = parents[j].S_objid,
                        targetos = parents[j].osnum);
          if( !(sts&1) ) {
	       dummy_grid.objid = parents[j].S_objid;
	       dummy_grid.osnum = parents[j].osnum;
          }
       } else {  /* parent is ACpretdef */
	
	  /* get the corresponding macro defn id */
	  num = 0;
          sts = om$get_objid_at_index (objid = parents[j].S_objid,
                                       osnum = parents[j].osnum,
                                       p_chanselect = &children, 
                                       index = 0,
				       objidaddr = &macro_defn_grid.objid,
				       osnumaddr = &macro_defn_grid.osnum);

          if (EFisAncestryValid(&msg_loc, macro_defn_grid.objid, 
				macro_defn_grid.osnum, OPP_ACmacro_defn_class_id, 0)) 
	  {
		/* 
		 * get the index of ACpretdef on ACmacro_defn NDfather channel
		 */
		sts = om$get_index( objid_c = macro_defn_grid.objid,
				    osnum_c = macro_defn_grid.osnum,
				    p_chanselect = &father,
				    objid = parents[j].S_objid,
				    osnum2 = parents[j].osnum,
				    indexaddr = &index);


		EMget_real_parent_from_macro(&macro_defn_grid, 
					     &dummy_grid, 
					     &index);

       };

     };

       EFget_orientation_from_parent( &msg_loc,
				     &dummy_grid,
				     &module_info,
				     xdir,
				     ydir,
				     zdir,
				     origin);

       sts = om$send ( msg = message EMSdatpln.EMget_pln_info (&msg_loc,
							     NULL,
							     NULL,
							     xptr,
							     yptr,
							     zptr,
							     optr,
							     NULL),
		      senderid = NULL_OBJID,
		      targetid = datums_GRid[i].objid,
		      targetos = datums_GRid[i].osnum);

       sts = om$send(msg = message EMSassoc.EMget_info(&msg_loc,
						     NULL,
						     &type,
						     &info_size,
						     NULL),
  		     senderid = NULL_OBJID,
		     targetid = datums_GRid[i].objid,
		     targetos = datums_GRid[i].osnum);

       if(info_size >16 && type == 255)
       {
	   recomp_info = (IGRchar *) stackalloc(info_size);
	   if ( !recomp_info )
	     goto wrapup;
	 
	   sts = om$send(msg = message EMSassoc.EMget_info(&msg_loc,
					      NULL,
					      &type,
					      &info_size,
					      &recomp_info),
			 senderid = NULL_OBJID,
			 targetid = datums_GRid[i].objid,
			 targetos = datums_GRid[i].osnum);

	   if ( strcmp(recomp_info,"EFrefpln_from_cs") )
	     continue;

	   type1 = recomp_info[17];

	   if(type1 == 2 && (EMcheck_axis(xptr,yptr,zptr,xdir,zdir,ydir)==0)) 
	   {
	     recomp_info[17] = 3;
	     modify_rep_type = TRUE;

	     sts = om$send(msg = message EMSassoc.EMput_info(&msg_loc,
							     NULL,
							     type,
							     info_size,
							     recomp_info),
		           senderid = NULL_OBJID,
			   targetid = datums_GRid[i].objid,
			   targetos = datums_GRid[i].osnum);
	   }
     
	 }
     }

   }
   wrapup :
     if ( datums_GRid != NULL )
       free(datums_GRid);
     return(sts);
}


EMget_real_parent_from_macro(macro_id, parent_grid, index_num)
struct GRid	*macro_id, *parent_grid;
int		*index_num;
{
  int 		i_lines, nb_lines, num_lines;
  long		status,msg;
  char 		dir_name[DI_PATH_MAX], macro_defn_path[DI_PATH_MAX],
		temp_path[DI_PATH_MAX], **lines = NULL, **temp_names = NULL;
  struct GRid 	macro, dummy;

  /*| Get contents of selected macro library */

  parent_grid->objid = NULL_OBJID;
  parent_grid->osnum = macro_id->osnum;

  status = di$give_pathname ( osnum =  macro_id->osnum,
                              pathname =  dir_name);

  strcat(dir_name,":constructs:*");

  status = di$ls( regexp = dir_name ,
		  options = NULL,
               	  lines = &lines ,
                  ptr = &nb_lines);

  if(nb_lines == 0) return(OM_S_SUCCESS);

  for(i_lines=0;i_lines<nb_lines;i_lines=i_lines+1)
  {
     /* Get information about macro */
     di$translate(objname = lines[i_lines],
	          osnum = macro_id->osnum,
	          p_objid = &macro.objid,
	          p_osnum = &macro.osnum);

     if ( ( macro_id->objid == macro.objid ) &&
	  ( macro_id->osnum == macro.osnum ) )
     {	
	/* Get macro template */
        strcpy(macro_defn_path, lines[i_lines]);
        strcat(macro_defn_path,"$def:*");

	status = di$ls( regexp = macro_defn_path,
		        options = NULL,
               	        lines = &temp_names,
                        ptr = &num_lines);

	/**  di$ls will have current directory also as one of its lines (first)
	     so to get the right template use index+1 and not index */

	if ( (*index_num +1) < num_lines ) {

	  /* translate the indexed object */
	  strcpy(temp_path, temp_names[*index_num + 1]);

	  status = di$translate( objname = temp_path,
			         osnum = macro.osnum,
				 p_objid = &dummy.objid,
				 p_osnum = &dummy.osnum);
	  if ( status != DIR_S_SUCCESS ) 
	     continue;

	  parent_grid->objid = dummy.objid;
	  parent_grid->osnum = dummy.osnum;

	  goto cleanup;
        }
     } else 
	continue;
  };

cleanup:
  if(lines != NULL && nb_lines != 0)
    di$free(lines = lines, count = nb_lines);

  if(temp_names != NULL && num_lines != 0)
    di$free(lines = temp_names, count = num_lines);

   return(1);

} /* end function */

extern double	fabs();

EMcheck_axis(xptr, yptr, zptr, xdir, ydir, zdir)
IGRdouble  *xptr, *yptr, *zptr;
IGRvector  xdir, ydir, zdir;
{
  IGRint i;
  IGRboolean is_match=FALSE;


  for(i=0; i< 3; i=i+1) {

     if( (xptr[i] < (xdir[i]+TOL) && xptr[i] > (xdir[i]-TOL) ) &&    
         (yptr[i] < (ydir[i]+TOL) && yptr[i] > (ydir[i]-TOL) ) && 
         ( fabs(zptr[i]) < ( fabs(zdir[i]) + TOL ) && fabs(zptr[i]) > ( fabs(zdir[i]) - TOL ) ) )
    	     is_match = TRUE;
     else {
  	     is_match = FALSE;
	     break;
     }
  };
  return(is_match);
}

end implementation EMAdatpln;

