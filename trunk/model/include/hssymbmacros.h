
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:58 $
$Locker:  $
*/

#ifndef hssybmmacros_include

#define hssymbmacros_include
/********************************************************************

  
	This macros is dependent on the following include files:

		"igrtypedef.h"
		"OMminimum.h"

********************************************************************/

/*--------------------------- hs$add_symb_entry ---------------------------------

Abstract:	This macro will add a symbology entry.  It is to be called
		any time a graphic object is created.

  WARNING:	When the object is deleted, you MUST call the macro
		hs$delete_symb_entry



Arguments:

  Input

    struct HSrender_bundle       *entry	        the display attribute structure to add
    unsigned char                *app_entry	the display attribute structure to add
                                                caller must allocate the 
                                                required memory

    GRobjid		mod_id		the module id - if not specified it
					defaults to the current module id

    GRspacenum		mod_osnum	the module osnum


  Output

    IGRlong		*msg		return message
                                    	    - MSSUCC     if success
                                    	    - MSFAIL	 if failure

    IGRint		*index		the index cooresponding the
					display attribute passed in

Return Status:

	TRUE -	Success
	FALSE -	Failure


-----------------------------------------------------------------------------*/


#omdef	hs$add_symb_entry(	msg,
				entry,
				app_entry,
				index,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)
				
	HSaddbundentry(msg,entry,app_entry,index,mod_id,mod_osnum)
	
#endomdef


/*--------------------------- hs$change_symb_entry ---------------------------------

Abstract:	This macro will delete and old symbology and add a new one.  This 
		macros should be used when changing an object symbology.



Arguments:

  Input

    IGRint		old_index	the index to be deleted

    struct HSrender_bundle	     *entry	the display attribute structure to add
    unsigned char                    *app_entry	the display attribute structure to add
                                                 caller must allocate the memory required.

    GRobjid		mod_id		the module id - if not specified it
					defaults to the current module id

    GRspacenum		mod_osnum	the module osnum

  Output

    IGRlong		*msg		return message
                                    	    - MSSUCC     if success
                                    	    - MSFAIL	 if failure

    IGRint		*new_index	the index cooresponding the  
					display attribute passed in

Return Status:

	TRUE -	Success
	FALSE -	Failure


-----------------------------------------------------------------------------*/

#omdef	hs$change_symb_entry(	msg,
				old_index,
				entry,
				app_entry,
				new_index,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)
				
	HSchgbundentry(msg,old_index,entry,app_entry,new_index,mod_id,mod_osnum)
	
#endomdef

/*--------------------------- hs$delete_symb_entry ---------------------------------

Abstract:	This macro will delete a symbology entry.  It is to be called
		any time a graphic object is created.



Arguments:

  Input


    IGRint		index		the index to be deleted

    GRobjid		mod_id		the module id - if not specified it
					defaults to the current module id

    GRspacenum		mod_osnum	the module osnum


  Output

    IGRlong		*msg		return message
                                    	    - MSSUCC     if success
                                    	    - MSFAIL	 if failure


Return Status:

	TRUE -	Success
	FALSE -	Failure


-----------------------------------------------------------------------------*/

#omdef	hs$delete_symb_entry(	msg,
				index,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)

	HSdelbundentry(msg,index,mod_id,mod_osnum)
	
#endomdef


/*--------------------------- hs$retrieve_symb_entry ---------------------------------

Abstract:	This macro will retrieve a symbology entry when given its
		cooresponding index.



Arguments:

  Input

    IGRint		index		the index of the entry to retrieve

    GRobjid		mod_id		the module id - if not specified it
					defaults to the current module id

    GRspacenum		mod_osnum	the module osnum


  Output

    IGRlong		*msg		return message
                                    	    - MSSUCC     if success
                                    	    - MSFAIL	 if failure


    struct HSrender_bundle	*entry		the display attribute structure 
                                                cooresponding
					        to the index passed in
    unsigned char               *app_entry	the display attribute structure 
                                                cooresponding
					        to the index passed in
                                                caller must allocate the 
                                                required memory.

Return Status:

	TRUE -	Success
	FALSE -	Failure


-----------------------------------------------------------------------------*/

#omdef	hs$retrieve_symb_entry(	msg,
				index,
				entry,
				app_entry,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)

	HSretbundentry(msg,index,entry,app_entry,mod_id,mod_osnum)
	
#endomdef

/*--hs$create_symb_entry----------------------------------------------*/

#omdef hs$create_symb_entry(msg,
			    index,
			    entry,
			    app_entry,
			    mod_id = NULL_OBJID,
                            mod_osnum = OM_Gw_current_OS)

        HScrebundentry(msg,entry,app_entry,index,mod_id,mod_osnum)

#endomdef



/*--- hs$get_rendering_bundles -----------------------------------------------------*/

/*
	This macro gets the active rendering bundles
	
	Parameters:
	
	   *rend_bundle       - struct HSrender_bundle, NULL if not desired
	   *extra_rend_bundle - unsigned char, NULL if not desired

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$get_rendering_bundles( rend_bundle = NULL,
	                         extra_rend_bundle = NULL )

	HSdpb_get_rendering_bundles( rend_bundle, extra_rend_bundle );
#endomdef


/*--- hs$set_rendering_bundles -----------------------------------------------------*/

/*
	This macro sets the active rendering bundles
	
	Parameters:
	
	   *rend_bundle       - struct HSrender_bundle, NULL if not to be set
	   *extra_rend_bundle - unsigned char, NULL if not to be set

	Return Values:
	
	   0 - success
	   1 - failure
*/

#omdef hs$set_rendering_bundles( rend_bundle = NULL,
	                         extra_rend_bundle = NULL )

	HSdpb_set_rendering_bundles( rend_bundle, extra_rend_bundle );
#endomdef


/*--------------------------- hs$redefine_app_entry ---------------------------------

Abstract:	This macro will redefine the Application (I/Design)
                bundle  (esp the size ).



Arguments:

  Input

    IGRchar             *entry		this caracter string contains the new size of each entry
                                        followed by the values the new parameters will take.

    GRobjid		mod_id		the module id - if not specified it
					defaults to the current module id

    GRspacenum		mod_osnum	the module osnum


  Output

    IGRlong		*msg		return message
                                    	    - MSSUCC     if success
                                    	    - MSFAIL	 if failure


Return Status:

	TRUE -	Success
	FALSE -	Failure


-----------------------------------------------------------------------------*/

#omdef	hs$redefine_app_entry(	msg,
				entry,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)

	HSappredefinesymb(msg,entry,mod_id,mod_osnum)
	
#endomdef


/*--------------------------- hs$redefine_app_entry ---------------------------------

Abstract:	This macro returns the size of each entry in the 
                application bundle.



Arguments:

  Input

    GRobjid		mod_id		the module id - if not specified it
					defaults to the current module id

    GRspacenum		mod_osnum	the module osnum


  Output

    IGRlong		*msg		return message
                                    	    - MSSUCC     if success
                                    	    - MSFAIL	 if failure

    IGRint              *size           The size of each entry in the application bundle


Return Status:

	TRUE -	Success
	FALSE -	Failure


-----------------------------------------------------------------------------*/

#omdef	hs$get_app_entry_size(	msg,
				size,
                                active =0,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)

	HSapp_getentrysize_symb(msg,size,active,mod_id,mod_osnum)
	
#endomdef

/*--------------------------- hs$get_app_num_fields ---------------------------------

Abstract:	This macro returns the number of fields in the
                application bundle.



Arguments:

  Input

    GRobjid		mod_id		the module id - if not specified it
					defaults to the current module id

    GRspacenum		mod_osnum	the module osnum


  Output

    IGRlong		*msg		return message
                                    	    - MSSUCC     if success
                                    	    - MSFAIL	 if failure

    IGRint              *num_fields           Number of fields


Return Status:

	TRUE -	Success
	FALSE -	Failure


-----------------------------------------------------------------------------*/

#omdef	hs$get_app_num_fields(	msg,
				num_fields,
				mod_id = NULL_OBJID,
				mod_osnum = OM_Gw_current_OS)

	HSapp_getnumfields_symb(msg,num_fields,mod_id,mod_osnum)
	
#endomdef




#endif
