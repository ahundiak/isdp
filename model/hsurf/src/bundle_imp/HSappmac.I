
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

class implementation HStable;

#include <stdio.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "exmacros.h"

#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"

static IGRint HSapp_symb_id[266];
%safe
static IGRint	first_time = 1 ;
%endsafe

#if defined(__STDC__) || defined(__cplusplus)
	void HSinit_appsymb_id(void)
#else
	void HSinit_appsymb_id()
#endif

/*
NAME
    HSinit_appsymb_id

KEYWORD
    Bundle Tables

DESCRIPTION
    Initializes the HSapp_symb_id (object id <=> os number ) array.

PARAMETERS
    none

GLOBALS USED
    none

HISTORY
    --/--/91 Shridar Subramanian

*/

{
    IGRint i;

	for (i=0; i < 266; i++)
	{
	    HSapp_symb_id[i] = NULL_OBJID;
	}
}

#if defined(__STDC__) || defined(__cplusplus)
	void HSset_appsymb_id( GRobjid objid,
			    GRspacenum osnum )
#else
	void HSset_appsymb_id(objid, osnum)
	GRobjid objid;
	GRspacenum osnum;
#endif

/*
NAME
    HSset_appsymb_id

KEYWORD
    Bundle Tables

DESCRIPTION
    Set a particular element (osnum )  of HSapp_symb_id to objid.

PARAMETERS
    objid  (IN) - object id
    osnum  (IN) - osnum 

GLOBALS USED
    none

HISTORY
    --/--/91 Shridar Subramanian

*/

{
    HSapp_symb_id[osnum] = objid;
}

#if defined(__STDC__) || defined(__cplusplus)
	void HSreset_appsymb_id( GRspacenum osnum )
#else
	void HSreset_appsymb_id(osnum)
	GRspacenum osnum;
#endif

/*
NAME
    HSreset_appsymb_id

KEYWORD
    Bundle Tables

DESCRIPTION
    Resets a particular element (osnum )  of HSapp_symb_id. 

PARAMETERS
    osnum  (IN) - osnum 

GLOBALS USED
    none

HISTORY
    --/--/91 Shridar Subramanian

*/

{

   HSapp_symb_id[osnum] = NULL_OBJID;
}
   
     
	
/*
IGRint HSdefentry(msg,num_fields,sizes,offsets,mod_id,mod_osnum)

   IGRlong		*msg;
   short		num_fields;
   short		*sizes;
   short		*offsets;
   GRobjid		mod_id;
   GRspacenum		mod_osnum; */

/*
NAME
    HSdefentry

KEYWORD
    Bundle Tables

DESCRIPTION
    Determines the object id of the application bindle object and 
    send a message to that object to define the application entry

PARAMETERS
    msg        (OUT) - Any error messages
    num_fields (IN)  - Number of fields in each application bundle entry
    sizes      (IN)  - Array of sizes. Represents the size of each
                       field in an application bundle entry.
    offsets    (IN)  - Array of offsets. Each entry in this array 
                       represents the offset of the corresponding field
                       in the entry.
    mod_id     (IN)  - Object id of the module
    mod_osnum  (IN)  - Object space number of the module object.
   

GLOBALS USED
    none

RETURN VALUES
    0 failure
    1 success

HISTORY
    --/--/91 Shridar Subramanian

*/

/*    {

      IGRint 		status;
      GRobjid		modid;
      GRspacenum	modos;
      GRobjid		symb_id;

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

	HSget_grsymb_id(modid,modos,&symb_id);

 

	status = om$send ( msg = message HStable.define_entry(msg,num_fields,
					 sizes,offsets),
			   senderid = NULL_OBJID,
			   targetid = symb_id,
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
*/


#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSappaddsymb( IGRlong *msg,
			     IGRchar *entry,
			      IGRint *index,
			     GRobjid mod_id,
			  GRspacenum mod_osnum )
#else
	IGRint HSappaddsymb(msg,entry,index,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRchar		*entry;
	IGRint		*index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

/*
NAME
    HSappaddsymb

KEYWORD
    Bundle Tables

DESCRIPTION
    Determines the object id of the application bundle object and 
    send a message to that object to add the application entry

PARAMETERS
    msg        (OUT) - Any error messages
    entry      (IN)  - entry to be added to the application bundle table
                       First four bytes represents the size of the entry
                       followed by 4 bytes of pad, followed by the 
                       actual entry
    index      (OUT) - The index of the added entry
    mod_id     (IN)  - Object id of the module
    mod_osnum  (IN)  - Object space number of the module object.
   

GLOBALS USED
    none

RETURN VALUES
    0 failure
    1 success

HISTORY
    --/--/91 Shridar Subramanian

*/
    {

      int 		status;
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

	HSget_appsymb_id(modid,modos,&app_id);

	status = om$send ( msg =  message HStable.add_entry(msg,entry,0,index),
			   senderid = NULL_OBJID,
			   targetid = app_id,
			   targetos = modos);

	if (!status)
	{
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);

   }

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSappcreasymb( IGRlong *msg,
			      IGRchar *entry,
			       IGRint *index,
			      GRobjid mod_id,
			   GRspacenum mod_osnum )
#else
	IGRint HSappcreasymb(msg,entry,index,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRchar		*entry;
	IGRint		*index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

/*
NAME
    HSappcreasymb

KEYWORD
    Bundle Tables

DESCRIPTION
    Determines the object id of the application bundle object and 
    send a message to that object to create the application entry

PARAMETERS
    msg        (OUT) - Any error messages
    entry      (IN)  - entry to be created to the application bundle table
                       First four bytes represents the size of the entry
                       followed by 4 bytes of pad, followed by the 
                       actual entry
    index      (OUT) - The index of the created entry
    mod_id     (IN)  - Object id of the module
    mod_osnum  (IN)  - Object space number of the module object.
   

GLOBALS USED
    none

RETURN VALUES
    0 failure
    1 success

HISTORY
    --/--/91 Shridar Subramanian

*/
    {

      int 		status;
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

	HSget_appsymb_id(modid,modos,&app_id);

	status = om$send ( msg =  message HStable.create_entry(msg,entry,0,index),
			   senderid = NULL_OBJID,
			   targetid = app_id,
			   targetos = modos);

	if (!status)
	{
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);

   }




#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSappretsymb( IGRlong *msg,
			       IGRint index,
			      IGRchar *entry,
			      GRobjid mod_id,
			   GRspacenum mod_osnum )
#else
	IGRint	HSappretsymb(msg,index,entry,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint		index;
	IGRchar		*entry;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

/*
NAME
    HSappretsymb

KEYWORD
    Bundle Tables

DESCRIPTION
    Determines the object id of the application bundle object and 
    send a message to that object to retrieve the application entry

PARAMETERS
    msg        (OUT) - Any error messages
    entry      (OUT) - entry retrieved from the application bundle table
    index      (IN)  - The index of the entry to retrieved
    mod_id     (IN)  - Object id of the module
    mod_osnum  (IN)  - Object space number of the module object.
   

GLOBALS USED
    none

RETURN VALUES
    0 failure
    1 success

HISTORY
    --/--/91 Shridar Subramanian

*/
    {

      int 		status;
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

	HSget_appsymb_id(modid,modos,&app_id);

	status = om$send ( msg =  message HStable.retrieve_entry(msg,index,entry),
		   senderid = NULL_OBJID,
		   targetid = app_id,
		   targetos = modos);

	if (!status)
	{
	   status = FALSE;
	}
 	else
	{
	   status = TRUE;
	}

	
    	return(status);

   }

#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSappdelsymb( IGRlong *msg,
			       IGRint index,
			      GRobjid mod_id,
			      GRspacenum mod_osnum )
#else
	IGRint	HSappdelsymb(msg,index,mod_id,mod_osnum)
	
	IGRlong		*msg;
	IGRint		index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif

/*
NAME
    HSappdelsymb

KEYWORD
    Bundle Tables

DESCRIPTION
    Determines the object id of the application bundle object and 
    send a message to that object to delete the application entry

PARAMETERS
    msg        (OUT) - Any error messages
    index      (IN)  - The index of the entry to deleted
    mod_id     (IN)  - Object id of the module
    mod_osnum  (IN)  - Object space number of the module object.
   

GLOBALS USED
    none

RETURN VALUES
    0 failure
    1 success

HISTORY
    --/--/91 Shridar Subramanian

*/
    {

      int 		status;
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

	HSget_appsymb_id(modid,modos,&app_id);

	status = om$send ( msg = message   HStable.delete_entry(msg,index,0),
		   senderid = NULL_OBJID,
		   targetid = app_id,
		   targetos = modos);

	if (!status)
	{
	   status = FALSE;
	}
 	else
	{
	   status = TRUE;
	}

	
    	return(status);

   }

#if defined(__STDC__) || defined(__cplusplus)
	IGRint HSappchgsymb( IGRlong *msg,
			      IGRint old_index,
			     IGRchar *entry,
			      IGRint *new_index,
			     GRobjid mod_id,
			  GRspacenum mod_osnum )
#else
	IGRint HSappchgsymb(msg,old_index,entry,new_index,mod_id,mod_osnum)

	IGRlong		*msg;
	IGRint		old_index;
	IGRchar		*entry;
	IGRint		*new_index;
	GRobjid		mod_id;
	GRspacenum	mod_osnum;
#endif
/*
NAME
    HSappchgsymb

KEYWORD
    Bundle Tables

DESCRIPTION
    Determines the object id of the application bundle object and 
    send a message to that object to change the application entry

PARAMETERS
    msg        (OUT) - Any error messages
    old_index  (IN)  - The index of the entry to changed
    entry      (IN)  - The new entry to replace the old entry
    new_index  (OUT) - The index of the new entry
    mod_id     (IN)  - Object id of the module
    mod_osnum  (IN)  - Object space number of the module object.
   

GLOBALS USED
    none

RETURN VALUES
    0 failure
    1 success

HISTORY
    --/--/91 Shridar Subramanian

*/
    {

      int 		status;
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

	HSget_appsymb_id(modid,modos,&app_id);
 

	status = om$send ( msg =  message HStable.change_entry(msg,old_index,entry,0,new_index),
			   senderid = NULL_OBJID,
			   targetid = app_id,
			   targetos = modos);

	if (! status)
	{
	   status = FALSE;
	}
	else
	{
	   status = TRUE;
	}

    	return(status);

   }


#if defined(__STDC__) || defined(__cplusplus)
	IGRint	HSget_appsymb_id( GRobjid modid,
			       GRspacenum modos,
				  GRobjid *app_id )
#else
	IGRint	HSget_appsymb_id(modid,modos,app_id)

	GRobjid	modid;
	GRspacenum	modos;
	GRobjid	*app_id;
#endif

/*
NAME
    HSget_appsymb_id

KEYWORD
    Bundle Tables

DESCRIPTION
    This function is used to determine the object id of the 
    application bundle.

PARAMETERS
    modid     (IN)  - Object id of the module
    modos     (IN)  - Object space number of the module object.
    app_id    (IN)  - Object id of the application bundle.
   

GLOBALS USED
    none

RETURN VALUES
    0 failure
    1 success

HISTORY
    --/--/91 Shridar Subramanian

*/
    {

     IGRint	status = OM_S_SUCCESS;
     GRspacenum	appsymb_os;

	if (HSapp_symb_id[modos] == NULL_OBJID || first_time)
	{
	    if (first_time)
	    {
		first_time = FALSE;
		HSinit_appsymb_id();
	    }

	    status = ex$get_super(mod_id = modid,
                          mod_osnum = modos,
                          super_name = "HSAPP",
                          create = TRUE,
                          super_class = "HSapp",
                          super_id = app_id,
                          super_osnum = &appsymb_os);

	    HSapp_symb_id[modos] = *app_id;
	}
	else
	{
	    *app_id = HSapp_symb_id[modos];
	}

    return(status);

  }   


end implementation HStable;
