
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hstex_mac_include

#define hstex_mac_include
/********************************************************************

  
	This macros is dependent on the following include files:

		"igrtypedef.h"
		"OMminimum.h"

********************************************************************/

/*--------------------------- hs$add_texture_file---------------------------


-----------------------------------------------------------------------------*/


#omdef	hs$add_texture_file(    filename,
                                active,
                                index,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)
				
	HSadd_texture_filename(filename, active, index,mod_id,mod_osnum)
	
#endomdef


#omdef  hs$add_ref_ct(
                                index,
                                mod_id = NULL_OBJID,
                                mod_osnum = OM_Gw_current_OS)

        HSadd_texture_ref_ct(index,mod_id,mod_osnum)

#endomdef


#omdef  hs$review_texture_file(filename,
                                ref_ct, 
                                first_time,
                                mod_id = NULL_OBJID,
                                mod_osnum = OM_Gw_current_OS)

        HSrev_texture_file(filename, ref_ct, first_time,mod_id,mod_osnum)

#endomdef


#omdef  hs$delete_texture_file(index,
                                mod_id = NULL_OBJID,
                                mod_osnum = OM_Gw_current_OS)


        HSdel_texture_file(index, mod_id,mod_osnum)

#endomdef


#omdef  hs$inquire_texture_file(filename,
                                status,
                                mod_id = NULL_OBJID,
                                mod_osnum = OM_Gw_current_OS)


        HSinq_texture_file(filename, status, mod_id,mod_osnum)

#endomdef


#omdef  hs$retrieve_texture_file(index,
		                filename,
                                mod_id = NULL_OBJID,
                                mod_osnum = OM_Gw_current_OS)


        HSret_texture_file(index, filename, mod_id,mod_osnum)

#endomdef

#omdef  hs$validate_texture_index(index,
                                valid_index,
                                mod_id = NULL_OBJID,
                                mod_osnum = OM_Gw_current_OS)


        HStex_validate_index(index, valid_index, mod_id,mod_osnum)

#endomdef



#endif
