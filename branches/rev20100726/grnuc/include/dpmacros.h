
	/*
	 *
	 *  This set of macros defines the user interface to the 
	 *  display subsystem.  This include file is dependent on 
	 *  the following include files:
	 *
	 *	igrdef.h
	 *	dpdef.h
	 * 
	 */

	 
#ifndef dpmacros_include
#define dpmacros_include


#omdef  dp$dynamics
                (  dyn_fun,
                   information=NULL,
                   flags=0)

DPdynamics(dyn_fun,information,flags,NULL,NULL)

#endomdef


#omdef  dp$display
                (  msg,
                   osnum = OM_Gw_current_OS,
                   objid = NULL_OBJID,
                   mode = GRbd,
                   num_elem = 1,
                   buffer ^ 
                   oids, 
                   alt_symb = NULL,
                   mtx_type=NULL, 
                   matrix=NULL,
		   view_ind = FALSE,
		   view_ind_type = ROTATION_IND,
		   view_ind_point = NULL)



#if om$specified(buffer)

    DPdisbybuf((msg), (osnum), (objid), (mode), (num_elem), (buffer),
		(view_ind),(view_ind_type),(view_ind_point))

#else

#if om$specified(mtx_type) && om$specified(matrix)

    DPdisbyoid((msg), (osnum), (objid), (mode), (num_elem), 
                (oids), (mtx_type), (matrix),(alt_symb), 0)


#else

#if !om$specified(mtx_type) && !om$specified(matrix) && !om$specified(num_elem)

        

    DPdisbyoid((msg), (osnum), (objid), (mode), (num_elem),  
                (oids), (mtx_type), (matrix), (alt_symb), 1)


#else

#if !om$specified(mtx_type) && !om$specified(matrix)

#omerror "mtx_type and matrix will not default when num_elem is specified"

#else

#if om$specified(mtx_type)

#omerror  "If mtx_type is specified,  then matrix has to be specified"

#else

#omerror  "If matrix is specified,  then mtx_type has to be specified"

#endif
#endif
#endif
#endif
#endif



#endomdef


#omdef  dp$dispelem(    msg, 
                        buffer, 
                        mode, 
                        dp_info)
                        

DPelem((msg), (buffer), (mode), (dp_info))

#endomdef

#omdef  dp$set_view_ind(	type = ROTATION_IND, 
                        	point, 
                        	dp_info,
                        	old)
                        

DPsetviewind((type), (point), (dp_info),(old))

#endomdef


#omdef  dp$reset_view_ind(     	dp_info,
                        	old)
                        

DPresetviewind((dp_info),(old))

#endomdef

#omdef	dp$reset_frames(msg)

DPreset_frames(msg)

#endomdef

#omdef	dp$start_frame(	msg,
			static_frame = FALSE,
			frame_no = DPADD_TO_END,
			load_frame = TRUE,
			feedback = FALSE,
			feedback_buf = NULL,
			feedback_size = 0,
			apparent_stroke_scale = 1.0,
			gragad_id,
			gragad_osnum,
			frame_id,
			frame_osnum)


DPstart_frame(msg,static_frame,frame_no,load_frame,feedback,feedback_buf,
		feedback_size,apparent_stroke_scale,gragad_id,gragad_osnum,
		frame_id,frame_osnum)

#endomdef

#omdef	dp$end_frame(	msg,
			fb_buf_status = NULL,
			disp_buf_status = NULL,
			buffer_size = NULL,
			frame_id,
			frame_osnum)

DPend_frame(msg,buffer_size,fb_buf_status,disp_buf_status,frame_id,frame_osnum)

#endomdef

#omdef	dp$load_frame(	msg,
			static_frame = FALSE,
			frame_no = DPADD_TO_END,
			buffer,
			buffer_size)

DPload_frame(msg,static_frame,frame_no,buffer,buffer_size)

#endomdef


#omdef	dp$display_frames(	msg,
				start_frame = 0,
				relative_frame = 0,
				number_of_frames = DPALL_FRAMES,
				number_of_cycles = 1,
				direction = DPFORWARD,
				erase = TRUE,
				zoom_factor = DPDEF_ZOOM_FACTOR,
				pan_factor = DPDEF_PAN_FACTOR,
				max_rotate_factor = DPDEF_MAX_ROTATE_FACTOR,
				gragad_id,
				gragad_osnum)


DPdisplay_frames(msg,start_frame,relative_frame,number_of_frames,number_of_cycles,
		 direction,erase,zoom_factor,pan_factor,max_rotate_factor,
		 gragad_id,gragad_osnum, NULL, (IGRchar *)NULL)

#endomdef

#omdef	dp$display2_frames(	msg,
				start_frame = 0,
				relative_frame = 0,
				number_of_frames = DPALL_FRAMES,
				number_of_cycles = 1,
				direction = DPFORWARD,
				erase = TRUE,
				zoom_factor = DPDEF_ZOOM_FACTOR,
				pan_factor = DPDEF_PAN_FACTOR,
				max_rotate_factor = DPDEF_MAX_ROTATE_FACTOR,
				gragad_id,
				gragad_osnum,
				func_ptr = NULL,
				func_parm = NULL)


DPdisplay_frames(msg,start_frame,relative_frame,number_of_frames,number_of_cycles,
		 direction,erase,zoom_factor,pan_factor,max_rotate_factor,
		 gragad_id,gragad_osnum,func_ptr,func_parm)
#endomdef

#omdef  dp$build_dis_buffer(	buffer, 
				tag = NULL_OBJID, 
				type = IGRBC, 
				flags = 0, 
				range = NULL, 
				level = NULL, 
				display_att, 
				ele_spec_att = NULL, 
				geometry,
				u_bound_att = NULL,
				v_bound_att = NULL,
				u_num_bound_att = 0,
				v_num_bound_att = 0,
				u_bound_att_indices = NULL,
				v_bound_att_indices = NULL,
				mdenv_info = NULL )
				
 
    DPbuildbuf((buffer), (tag), (type), (flags), (range), (level), 
	     (display_att), (ele_spec_att), (geometry),(u_bound_att),
	     (v_bound_att),(u_num_bound_att),(v_num_bound_att),
	     (u_bound_att_indices),(v_bound_att_indices),(mdenv_info))

	
#endomdef

#define DPbuildbuf(buf,tg,typ,flg,rng,lvl,disatt,eleatt,geom,uba,vba,unba,vnba,ubai,vbai,mdi) \
		   (buf)->tag = tg; \
		   (buf)->type = typ; \
		   (buf)->flags = flg; \
		   (buf)->range = rng; \
		   (buf)->level = lvl; \
		   (buf)->dis_att = disatt; \
		   (buf)->ele_spec_att.null = (char *) eleatt; \
		   (buf)->geometry.polyline = (struct IGRpolyline *) geom; \
		   (buf)->u_bound_att = uba; \
		   (buf)->v_bound_att = vba; \
		   (buf)->u_num_bound_att = unba; \
		   (buf)->v_num_bound_att = vnba; \
		   (buf)->u_bound_att_indices = ubai; \
		   (buf)->v_bound_att_indices = vbai; \
		   (buf)->mdenv_info = mdi;

#omdef dp$calc_gragad_info 
		      (	msg,
			osnum=-1,
			gragad_name="" ^
			gragad_objid=NULL_OBJID)

  DPcalinfo( msg,osnum,gragad_name,gragad_objid)

#endomdef


#omdef  dp$get_char_under
                (  msg,
		   lbsys, 
		   txt_ele, 
		   osnum= OM_Gw_current_OS, 
		   mod_objid = NULL_OBJID, 
                   which_char,
		   which_point = 1,
		   horizontal = TRUE,
                   point1, 
		   point2)

DPunderine(msg, lbsys, txt_ele, osnum, mod_objid, which_char, which_point,
	   horizontal,point1, point2)

#endomdef

#omdef  dp$get_closest_char
                (  msg,
		   lbsys, 
		   txt_ele, 
		   osnum= OM_Gw_current_OS, 
		   mod_objid = NULL_OBJID, 
		   point,		   
                   which_char)


DPclosestchar(msg, lbsys, txt_ele, osnum, mod_objid, point, which_char)

#endomdef

#omdef dp$get_gragad_id(msg,
			mod_GRid=NULL,
			name, 
			array_size=32,
			total_num=NULL,
			numberofids, 
			found_GRids,
			type_gragad=ALL_TYPES,
			search_priority="regviews")
/*			

arguments	Input/Output	Description

IGRlong *msg		O

struct GRid *mod_GRid 	I	the object id & object space of the module

IGRchar *name		I	the graphic gadget's name

IGRint array_size   	I      	the number of array elements you have 
				allocated in found_GRids.
				
IGRint  *total_num  	O  	the number of graphic gadgets that meet 
				the name specifications.
				
IGRint *numberofids 	O 	the number of GRids returned.  If array_size is
				large enough to accomadate the total number 
				of ids found, then numberofids and total_num 
				will be	equal.
				
struct GRid *found_GRids  O	the graphic gadgets' GRids

IGRint type_gragad	I	the type of graphic gadgets' you wish to
				get - ex. IGE_GG | ACTIVE_GG   IGEgragad
				and active graphic gadgets
IGRchar *search_priority I				
*/

    DPgetggid(msg,mod_GRid,name,array_size,total_num,numberofids,found_GRids,type_gragad, search_priority)

#endomdef


#omdef dp$inq_set_gragad ( msg,
			   inq0_set1=0,
       			   calc_info=0,
			   update=0,
			   osnum=0xFFFF,
			   gragad_name="" ^
			   gragad_objid=NULL_OBJID,
			   which_error,
			   var_list)

/* PLEASE NOTE:  The arguments calc_info and update have been added
		to this macro and should only be used if you are
		setting instance data.  These are actually flags to indicate
		whether the methods DPcal and DPupdate should be called.
		If you set these flags, it will save you from having to
		make the calls yourself.
		NOTE:  DPcal should NOT be called if the gragad is 
		       not active.
		When instance data is changed, transformation matrices 
		usually need to be recalculated by calling DPcal.  
		DPcal will be called if you set the flag
		calc_info to 1, or you can use the macro 
		dp$calc_gragad_info to call DPcal.           */

#if om$specified ( gragad_name )
    DPsi_gg_name ( msg, inq0_set1, which_error, var_list, osnum, gragad_name,
			calc_info,update)
#else
    DPsetinqgragad ( msg, inq0_set1, which_error, var_list,osnum, gragad_objid,
			calc_info,update)
#endif

#endomdef

#omdef  dp$inq_levels
		(  msg,
		   num_of_levels,
		   levels,
		   on_off_flag = 1,
		   gragad_objid,
		   gragad_osnum)
		   
DPinq_level(msg,num_of_levels,levels,on_off_flag,gragad_objid,gragad_osnum)

#endomdef
		   
#omdef  dp$levels_on_off
                (  msg,
		   levels = NULL ^ 
		   levels_mask = NULL, 
		   num_of_levels = 0,
		   on_off_flag = 1,
		   update = TRUE,
		   osnum= OM_Gw_current_OS, 
		   mod_objid = NULL_OBJID,
		   objid = NULL_OBJID)

#if om$specified(levels) && !om$specified(num_of_levels)

#omerror  "If levels is specified,  then num_levels has to be specified"

#else
#if om$specified(objid) && om$specified(mod_objid)

#omerror  "Cannot specify both objid and mod_obijd"
#else

DPlevel((msg), (levels), (num_of_levels),(levels_mask),(on_off_flag),(update),
				(mod_objid),(objid),(osnum))
#endif
#endif
#endomdef

#omdef  dp$gen_update
                (  msg,
		   range = NULL,
		   mode = GRbd,
		   erase = TRUE,
		   osnum= OM_Gw_current_OS, 
		   mod_objid = NULL_OBJID,
		   objid = NULL_OBJID)

#if om$specified(objid) && om$specified(mod_objid)

#omerror  "Cannot specify both objid and mod_obijd"
#else

DPgenupdate((msg), (range), (mode),(erase),(mod_objid),(objid),(osnum))
#endif

#endomdef

#omdef  dp$update
                (  msg,
		   range = NULL,
		   osnum= OM_Gw_current_OS, 
		   objid = NULL_OBJID)


DPmacupdate((msg), (range), (objid),(osnum))


#endomdef
/* the macro dp$get_savvwmgr_id no longer exists since the saved view manager
	no longer exists
*/

#omdef dp$total_num_saved_vw   (msg,
				total_num,
				osnum = NULL)
/* 	IGRlong *total_num the total number of saved views in that os 
	GRspacenum *osnum the os
*/

    DPtotal_num_svw(msg,total_num,osnum)

#endomdef

#omdef dp$get_saved_vw_id(msg,
			osnum=0xFFFF,
			name, 
			numberofids, 
			total_num=NULL,  
			array_size=40, 
			found_GRids)
/*
	IGRlong *msg
	GRspacenum osnum	
	IGRchar *name the saved view name for whose objid you are seeking
	IGRlong *numberofids	
	IGRlong *total_num	
	IGRlong array_size 
	struct GRid *found_GRids
*/

				
     DPgetvwid(msg,name,array_size,total_num,numberofids,found_GRids,osnum)

#endomdef

#omdef  dp$savvw_cons(msg,osnum=NULL,vw_name=NULL,gg_id=NULL,in_flags=0,struct=NULL,descript=NULL,
			origin=NULL)
			
/* The argument savvw_mgr_id no longer exists since the saved view manager
	was found to be unnecessary with IGRdir now available.
	GRspacenum *osnum the os you wish to construct in
	IGRchar *vw_name this is the name that will be associated with the 
	saved view.  If it is not specified, a default name will be chosen
	based on the following information.
		If gg_id is specified, then the name associated with that 
		graphic gadget will be the one used.
		If struct is specified with the structure DPsavevw the name
		in that structure will be used.
		If struct is specified with the structure DPgra_gad or 
		gragad_inst you must specify a name or the macro will fail.
		
	struct GRid *gg_id is the graphic gadget that you wish to have a saved
	view constructed like. However, you can specify struct instead of
	gg_id which is a structure either DPgra_gad or DPsavevw containing 
	values that will be used in constructing the saved view.
	PLEASE NOTE - If you decide to use struct both of these structures
	may change drastically in the next release.
	IGRshort in_flags specifics the type of struct - 
		GG_STRUCT for DPgra_gad
		SV_STRUCT for DPsave_vw
		GGI_STRUCT for gragad_inst
	IGRchar *struct a structure as explained above.
	IGRchar *descript a description that you wish to have stored with the
	saved view.  This is stored in a variable length array.
	IGRdouble *origin if specified this is a point that will be used as 
	the view's origin rather than the one that is currently stored in the
	specified structure or graphic gadget.
*/

#if (!om$specified(gg_id) && !om$specified(struct))

#omerror "Either a graphic gadget id or a structure must be specified"

#else
#if (om$specified(struct) && !om$specified(in_flags))

#omerror "If struct is specified then in_flags must be specified"

#else
	DPsavevw_cons(msg,osnum,vw_name,gg_id,in_flags,struct,descript,origin)
#endif
#endif	
#endomdef


#omdef dp$inq_set_saved_view ( msg,
			   inq0_set1=0,
			   osnum=0xFFFF,
			   vw_name="" ^
			   vw_objid=NULL_OBJID,
			   which_error,
			   var_list)
/*
        IGRlong *msg;          return message status  

        IGRchar inq0_set1;     indicates if you wish to set a value in
                                the view's instance data or if you wish
                                to inquire a value. (set = 1 inquire = 0)
	GRspacenum osnum
	
	IGRchar *vw_name
	
	GRobjid vw_objid 
	
        IGRlong *which_error	-  if an error occurs with one of the 
                                variables which_error will contain the #define
                                in var that matches the one causing the error
				NOTE - do not check which_error unless an 
				error is indicated by msg or the returned 
				status
				
        struct  var_list *var_list   -  list of variables to get 
*/

#if om$specified ( vw_name )
    DPsi_savvw_name( msg, inq0_set1, which_error, var_list, osnum,vw_name)
#else
    DPsetinqsavvw ( msg, inq0_set1, which_error, var_list,osnum, vw_objid)
#endif

#endomdef


#omdef  dp$erase_hilite
                (  msg,
		   osnum= OM_Gw_current_OS, 
		   objid = NULL_OBJID)


DPerase_hilite((msg), (objid),(osnum))


#endomdef


#omdef  dp$inter_clip_range
                (  msg,
		   old_range,
		   range,
		   dp_info)

DPintr_clp_rng((msg), (old_range),(range),(dp_info))


#endomdef


#omdef  dp$reset_clip_range
                (  msg,
		   old_range,
		   dp_info)

DPreset_clp_rng((msg), (old_range),(dp_info))


#endomdef

#omdef  dp$levels_number_to_name
                (  msg,
		   one_or_all_flag = NULL,
		   number, 
		   ptr_to_next = NULL,
		   ret_num_lev = NULL,
		   size_name_buffer,
		   name,
		   osnum= OM_Gw_current_OS, 
		   mod_objid = NULL_OBJID,
		   objid = NULL_OBJID)

#if om$equal(one_or_all_flag,1) && !om$specified(ptr_to_next)

#omerror  "If levels is specified,  then num_levels has to be specified"

#else
#if om$specified(objid) && om$specified(mod_objid)

#omerror  "Cannot specify both objid and mod_obijd"
#else

DPlev_num_to_name((msg), (one_or_all_flag), (number),(ptr_to_next),
	(ret_num_lev),(size_name_buffer),(name),(mod_objid),(objid),(osnum))

#endif
#endif
#endomdef

#omdef  dp$levels_name_to_number
                (  msg,
		   name,
		   number, 
		   osnum= OM_Gw_current_OS, 
		   mod_objid = NULL_OBJID,
		   objid = NULL_OBJID)

#if om$specified(objid) && om$specified(mod_objid)

#omerror  "Cannot specify both objid and mod_obijd"
#else

DPlevel_to_number((msg), (name), (number),
			(mod_objid),(objid),(osnum))

#endif
#endomdef

#define DPset_levels(old_levels,new_levels,dp_info)  { IGRint i;    \
			for (i=0 ; i<(((DP_NUM_OF_LEVELS - 1) /  \
			     (sizeof(IGRint) * 8)) + 1); i++)	\
			{					\
			   old_levels[i] = dp_info->gragad->levels[i]; \
			   dp_info->gragad->levels[i] = new_levels[i];	\
			}						\
			   }

#define DPreset_levels(old_levels,dp_info)  { IGRint i;    \
			for (i=0 ; i<(((DP_NUM_OF_LEVELS - 1) /  \
			     (sizeof(IGRint)* 8)) + 1); i++)	\
			{					\
			   dp_info->gragad->levels[i] = old_levels[i];	\
			}						\
			   }

#define DPlevel_on(level,dp_info) (DPlevel_check(level,dp_info->gragad->levels))

#define DPlevel_check(level,level_mask) (((1 << (level % 32)) & \
			level_mask[level >> 5]) ? 1: 0)
			
#define DPret_gpipe_id(dp_info)  (dp_info->gragad->gpipe_id)

#define DPret_view_objid(dp_info)	 (dp_info->view_objid)

#define DPret_view_osnum(dp_info)	 (dp_info->view_osnum)

#define DPis_wireframe(dp_info)  ((dp_info->is_hidden_line == 0) ? 1 :0)

#define DPis_fit(dp_info)	(dp_info->is_fit)

#omdef dp$view_vol  (	msg, 
			in_flags = WORLD_COOR | SETIN, 
			ret_flags = NULL, 
			gg_id, 
			origin = NULL, 
			rotation = NULL, 
			vw_vol = NULL, 
			display_depths = NULL, 
			active_z = NULL, 			
			defaults_vol = NULL, 
			def_dis_depths = NULL, 
			new_vw_vol = NULL, 
			new_display_depths = NULL,
			new_active_z = NULL,
			new_coor_vol = NULL, 			
			update = FALSE )
			
DPviewvol (msg, in_flags, ret_flags, gg_id, origin, rotation, vw_vol,
display_depths, active_z, defaults_vol, def_dis_depths, new_vw_vol, new_display_depths, 
new_active_z, new_coor_vol, (IGRboolean) update )

#endomdef

#omdef dp$set_persp   ( msg, 
			gg_id, 
			in_flags = DP_SET | DP_STD_DEFAULTS, 
			ret_flags = NULL,
			vrp=NULL, 
			vpn=NULL, 
			vup=NULL, 
			eye_pt=NULL, 
			coi = NULL, 
			vw_angle = NULL, 
			near = NULL, 
			far = NULL, 
			fence_pts = NULL,
			r_vrp = NULL, 
			r_vpn = NULL, 
			r_vup = NULL, 
			r_eye_pt = NULL, 
			r_coi = NULL, 
			r_vw_angle = NULL, 
			r_near = NULL, 
			r_far = NULL,
			z_scrn_dist = NULL,
			tilt = NULL)
		
#if om$specified(z_scrn_dist) || om$specified(tilt) || om$specified(fence_pts)

	DPcompersp(msg, gg_id, in_flags, ret_flags, vrp, vpn, vup, eye_pt, 
	coi, vw_angle, near, far, fence_pts, r_vrp, r_vpn, r_vup, 
		r_eye_pt, r_coi, r_vw_angle, r_near, r_far,z_scrn_dist,tilt)

#else

		
	DPsetpersp (msg, gg_id, in_flags, ret_flags, vrp, vpn, vup, eye_pt, 
	coi, vw_angle, near, far, r_vrp, r_vpn, r_vup, 
		r_eye_pt, r_coi, r_vw_angle, r_near, r_far)
#endif

#endomdef

#omdef dp$un_persp   ( msg, 
			gg_id)
			
	DPunpersp (msg, gg_id)
#endomdef

#omdef dp$cal_wldvw_mtx ( msg, 
			in_flags = DPRIGHT_VIEW,
			origin,
			rotation,
			wldvw_mtx,
			vwwld_mtx = NULL)

	DPwld_to_vw_mtx(msg,in_flags,origin,rotation,wldvw_mtx,vwwld_mtx)	

#endomdef

#omdef dp$find_defaultvw( msg,
			  flag = 0,
			  osnum, 
			  objid)

/*  To find the default view's objid  

Argument List

IGRlong *msg	(IN) return message
IGRlong flag 	(IN) This flag will be used as a bit mask to allow several 
			options but currently it has only one meaning, 
			whether the view should be construted if it does not 
			already exist.  To indicate that construction is 
			desired, use the #define DPCONST_VW found in dedef.h.
GRspacenum osnum (IN) object space number
GRobjid *objid	(OUT) the default view's objid

*/		
	DPfind_defaultvw(msg, flag,osnum,objid)
	
#endomdef

#omdef dp$vw_dir_names ( msg, in_flags = 0, osnum, objid, type, sub_dir, name )
/*
ONLY those who subclass from IGEgragad or IGEsavedvw should be using this
macro.
This macro will add or change view names.  If the specified directories
do not exist, they will be constructed.  The directory hierarchy currently
exists as follows         views
		regviews	savedviews
	GRviews  *** ***	GRsavedviews *** ***

You should use #defines provided in dpdef.h rather than these directory names.
Only IGEgragads should exist in the directory GRviews.  If you subclass from
IGEgragad, you should create a new directory under regviews for your class,
and I would suggest that you protect it.
If you subclass from IGEsavedvw, you should create a new directory under 
savedviews for your class.  

Argument List

IGRlong *msg		(IN) return message
IGRlong in_flags	(IN) This flag will be used as a bit mask 
				to allow several options.
				DP_PROTECTION this indicates that your 
				sub_dir will be given protection when it is 
				constructed.  This flag should also be set
				when you add or change names in this protected
				directory.
				
				DPCHG_VW_NAME  this indicates that you wish to
				change a view name rather than add a name.

GRspacenum osnum	(IN) The object space to construct in.
GRobjid objid		(IN) The objid of the object whose name you wish 
				to add or change.
IGRchar *type		(IN) Either the #define for the directory name 
				regviews or savedviews.  This is the general
				type of object.
IGRchar *sub_dir	(IN) The subdirectory at the third level, such as 
				GRviews.
IGRchar *name		(IN) The view name. (the new one)

The return code is an int.  Possible errors include 
DPDUPLICNM - This indicates that the name you have chosen already exists down
		from the second level directory (type) that you have indicated.
		Example, nothing under regviews should have the same name, but
		a saved view can have the same name as an object under regviews.
		
other errors should not occur under "normal" circumstances, however, directory
and group errors are possible.
*/

DPadd_vw_name_dir (msg,in_flags,osnum,objid,type,sub_dir,name)

#endomdef

#omdef dp$chg_vw_names ( msg, in_flags = 0, osnum, chg_list, num_in_list,
			type, sub_dir = NULL )
/*
This macro will change existing view names.  If no change has occurred in the
name, an error does not occur.  

Please reference the directory hierarchy as explained for dp$vw_dir_names.

Argument List

IGRlong *msg		(IN) return message
IGRlong in_flags	(IN) This flag will be used as a bit mask 
				to allow several options.
				DP_PROTECTION this indicates that your 
				sub_dir is protected.  
GRspacenum osnum	(IN) The object space the view are located in.

struct EXlstcol *list 	(IN) this structure contains an objid and the name
				you want associated with that objid.  A
				status is also there.  If the over all
				return status for the macro is bad then,
				you may want to check the status stored with
				each objid.  The names that were successfully
				changed will have list.stat set to ***, and 
				possible errors (all of which can be checked
				using !(list.stat & 1)) include ***.

IGRlong num_in_list	(IN) The number of saved view names you are passing
				for chg_list (the number of elements in the 
				array).
IGRchar *type		(IN) Either the #define for the directory name 
				regviews or savedviews.  This is the general
				type of object.
IGRchar *sub_dir	(IN) The subdirectory at the third level, such as 
				GRviews.  If a NULL is passed, the subdirectory
				where the objid is found will be are used
				when the new name is added.  If a subdirectory
				is passed the objid will be in this new 
				directory.

The return code is an int.  Possible errors include 
DPDUPLICNM - This indicates that the name you have chosen already exists down
		from the second level directory (type) that you have indicated.
		Example, nothing under regviews should have the same name, but
		a saved view can have the same name as an object under regviews.
		
other errors should not occur under "normal" circumstances, however, directory
and group errors are possible.
*/

DPchg_vw_names(msg,in_flags,osnum,chg_list,num_in_list,type,sub_dir)

#endomdef


#omdef  dp$inq_display_tolerance( pixel_toler )

/*
This macro will inquire the display tolerance (in pixels)

The parameters are:

   IGRint *pixel_toler - the current value of the display tolerance
*/

DPinq_display_tolerance( (pixel_toler) )

#endomdef

#omdef  dp$set_display_tolerance( pixel_toler )

/*
This macro will set the display tolerance (in pixels)

The parameters are:

   IGRint pixel_toler - the new value of the display tolerance
*/

DPset_display_tolerance( (pixel_toler) )

#endomdef

#endif
