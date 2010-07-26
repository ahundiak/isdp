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

	 
#ifndef dpezmac_include
#define dpezmac_include




#omdef dp$get_window_id(msg,
			mod_GRid=NULL,
			name, 
			array_size=32,
			total_num=NULL,
			numberofids, 
			found_GRids)
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

*/

    DPgetggid(msg,mod_GRid,name,array_size,total_num,numberofids,found_GRids,
              ALL_TYPES, "regviews")

#endomdef




#omdef dp$inq_window_info( msg,
			   osnum=-1,
			   window_name="" ^
			   window_objid=NULL_OBJID,
			   view_origin=NULL,
		           view_rotation=NULL,
			   vw_volume=NULL,
			   wld_volume=NULL,
                           act_z=NULL,
                           world_to_view=NULL)
/*
 Arguments               Input/Output         Description
 IGRlong *msg               O
 
 GRspacenum osnum           I                 Object space number of the 
					      window you want to query.

 char *window_name          I                 Name of the window


 GRobjid  window_objid      I                 Object id of the window you 
   					      want to query.

 IGRdouble *view_origin     O                 View Origin.


 IGRdouble *view_rotation   O                 4x4 IGR standard view rotation 
					      matrix


 IGRdouble *vw_volume       O                 View volume  



 IGRdouble *wld_volume      O                 World volume.



 IGRdouble *act_z           O                Active z in viewing coordinate 
                                             system


 IGRdouble *world_to_view   O                World to viewport tranformation
					     matrix.
*/


#if om$specified ( window_name )
    DP_inq_win_nam ( msg, osnum,window_name,view_origin,view_rotation,vw_volume,
                     wld_volume,act_z,world_to_view)
#else
    DP_inq_win_oid ( msg, osnum,window_objid,view_origin,view_rotation,vw_volume,
                     wld_volume,act_z,world_to_view)
#endif
#endomdef

		   








#omdef  dp$inq_window_levels
		(  msg,
		   num_of_levels,
		   levels,
		   on_off_flag = 1,
		   window_objid,
		   window_osnum)



/*		   
arguments       	Input/Output	           Description
IGRlong *msg               O
 
 
IGRint *num_of_levels      I                       The number of available
                                                   shorts in levels
                           O                       The number of levels 
						   returned.  If not enough
						   space is allocated, this 
						   contains the number of levels
        					   needed.

IGRshort *levels           O                       An array of shorts that 
					           holds levels. If there is not
						   enough space allocated, no
				                   levels are returned.

IGRint  on_off_flag        I                       1-Retrun the levels that are
                                                     on.
                                                   0-Return the levels that are
						     off.

GRobjid window_objid       I                       Object id of the window that 
                                                   you want to query.  


GRspacenum window_osnum    I                       Object spacenum of the window
                                                   that you want to query.


*/
 



DPinq_level(msg,num_of_levels,levels,on_off_flag,window_objid,window_osnum)

#endomdef
		   







#omdef  dp$levels_on_off
                (  msg,
		   levels = NULL ^ 
		   levels_mask = NULL, 
		   num_of_levels = 0,
		   on_off_flag = 1,
		   update = TRUE,
		   osnum= -1, 
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









#omdef  dp$update
                (  msg,
		   range = NULL,
		   osnum= -1, 
		   objid = NULL_OBJID)


DPmacupdate((msg), (range), (objid),(osnum))


#endomdef








#omdef  dp$savvw_cons(msg,osnum=NULL,vw_name=NULL,gg_id=NULL^window_id=NULL,in_flags=0,struct=NULL,descript=NULL,
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

#if (!(om$specified(gg_id)||om$specified(window_id)) && !om$specified(struct))

#omerror "Either a graphic gadget id or a structure must be specified"

#else
#if (om$specified(struct) && !om$specified(in_flags))

#omerror "If struct is specified then in_flags must be specified"

#else
#if(om$specified(gg_id))     
	DPsavevw_cons(msg,osnum,vw_name,gg_id,in_flags,struct,descript,origin)
#else
	DPsavevw_cons(msg,osnum,vw_name,window_id,in_flags,struct,descript,origin)
#endif
#endif	
#endif
#endomdef









#omdef dp$inquire_saved_view ( msg,
			   osnum=-1,
			   vw_name="" ^
			   vw_objid=NULL_OBJID,
                           sav_vw_name=NULL,
			   descript=NULL,
			   size_descript=NULL,
			   view_type=NULL)
/*

	IGRlong *msg;	        return message			
        IGRchar inq0_set1;     indicates if you wish to set a value in
                                the view's instance data or if you wish
                                to inquire a value. (set = 1 inquire = 0)
	GRspacenum osnum
	
	IGRchar *vw_name
	
	GRobjid vw_objid 
	
        struct  var_list *var_list   -  list of variables to get 
*/

#if om$specified ( vw_name )
    dpinq_sd_vwname( msg, osnum,vw_name,sav_vw_name,descript,
                     size_descript,view_type)
#else
    dpinq_sd_vwoid ( msg, osnum,vw_objid,sav_vw_name,descript,
                     size_descript,view_type)
#endif

#endomdef

#endif




