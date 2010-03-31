
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

class implementation HSapp;

#include <stdio.h>

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "exmacros.h"
#include "igr.h"
#include "gr.h"

#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"


#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSappredefinesymb( IGRlong *msg,
				  IGRchar *entry,
				  GRobjid mod_id,
			       GRspacenum mod_osnum )
#else
	IGRint HSappredefinesymb(msg,entry,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRchar		*entry;
	GRobjid		mod_id;
	GRspacenum		mod_osnum;
#endif

/*

NAME
     HSappredefinesymb

KEYWORD
     Bundle Tables

DESCRIPTION
     This function redefines the entry size of the application bundle in the
     bundle tables. ( This function is primarily used by I/Design to redefine
     their entries). The first four bytes of entry contains the new size. 
     Followed by the size is four bytes of padding.  
     The size of entry should be new_size - old_size + 8. The remaining 
     (new_size - old_size) bytes in entry are used to pad the copied app entries
     in the bundle tables.

PARAMETERS
     msg       (OUT) - Errors messages are returned
     entry     (IN)  - Contans the new entry size and the new padding
     mod_id    (IN)  - Module id. 
     mod_osnum (IN)  - Module object space number 

 GLOBALS USED
     none

 RETURN VALUES
     1 success
     0 Failure
 
 FUNCTIONS CALLED
     HSget_appsymb_entry
     HSapp.redefine_app_entry

 HISTORY
 
     02/01/92 Shridar Subramanian

*/ 
     



    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		app_id;


	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
          modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}

        /* Retrieve the object id of the Application bundle table */

	HSget_appsymb_id(modid,modos,&app_id);
 

	status = om$send ( msg =  message HSapp.redefine_app_entry(*msg,entry),
			   senderid = NULL_OBJID,
			   targetid = app_id,
			   targetos = modos);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	   om$report_error(sts = status);
#endif
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);
 }


#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSapp_getentrysize_symb( IGRlong *msg,
					 IGRint *size,
					 IGRint active,
					GRobjid mod_id,
				     GRspacenum mod_osnum )
#else
IGRint HSapp_getentrysize_symb(msg,size,active,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint 		*size;
	IGRint          active;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

/*

NAME
     HSapp_getentrysize_symb

KEYWORD
     Bundle Tables

DESCRIPTION
     This function returns the current size of the application bundle
     table entry. (All application bundle entries are of the smae size).


PARAMETERS
     msg       (OUT) - Errors messages are returned
     size      (OUT) - size of the application bundle entry.
     active    (IN)  - Currently size is 0 if active is true as there 
                       are no active application bundles.
     mod_id    (IN)  - Module id. 
     mod_osnum (IN)  - Module object space number 

 GLOBALS USED
     none

 RETURN VALUES
     1 success
     0 Failure
 
 FUNCTIONS CALLED
     HSget_appsymb_entry
     HSapp.get_app_entry_size

 HISTORY
 
     02/01/92 Shridar Subramanian

*/ 

    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		app_id;


	*size = 0;

	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
          modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}


        /* Retrieves the object id of the application bundle */

	HSget_appsymb_id(modid,modos,&app_id);
 
        if (active )
            *size = 0;
        else
	    status = om$send ( msg =  message HSapp.get_app_entry_size(*msg,size),
	        		   senderid = NULL_OBJID,
	        		   targetid = app_id,
	        		   targetos = modos);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	   om$report_error(sts = status);
#endif
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);
 }



#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSapp_getnumfields_symb( IGRlong *msg,
					 IGRint *num_fields,
					GRobjid mod_id,
				     GRspacenum mod_osnum )
#else
	IGRint HSapp_getnumfields_symb(msg,num_fields,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint		*num_fields;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

/*

NAME
     HSapp_getnumfields_symb

KEYWORD
     Bundle Tables

DESCRIPTION
     This function returns the number of fields in each application
     bundle table entry.


PARAMETERS
     msg       (OUT) - Errors messages are returned
     num_fields(OUT) - Number of fields in each application bundle
     mod_id    (IN)  - Module id. 
     mod_osnum (IN)  - Module object space number 

 GLOBALS USED
     none

 RETURN VALUES
     1 success
     0 Failure
 
 FUNCTIONS CALLED
     HSget_appsymb_entry
     HSapp.get_app_num_fields

 HISTORY
 
     02/01/92 Shridar Subramanian

*/ 


    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		app_id;


	if (mod_id == NULL_OBJID)
	{
          ex$get_modid(mod_osnum = mod_osnum,mod_id = &modid);
          modos = mod_osnum;
	}
	else
	{
	   modid = mod_id;
	   modos = mod_osnum;
	}

        /* Retrieve the object id of the application bundle */

	HSget_appsymb_id(modid,modos,&app_id);
 
	status = om$send ( msg =  message HSapp.get_app_num_fields(*msg,num_fields),
	        		   senderid = NULL_OBJID,
	        		   targetid = app_id,
	        		   targetos = modos);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	   om$report_error(sts = status);
#endif
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);
}


end implementation HSapp;
