
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

class implementation HSapp;

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "gr.h"

#include "msdef.h"
#include "exmacros.h"
#include "igrdp.h"

#include "hstabdef.h"
#include "hssymb.h"
#include "hstabmacros.h"
#include "hssymbmacros.h"
#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"

method  super_construct()

/*

NAME 
    super_construct

KEYWORD
    Bundle Tables

DESCRIPTION
    This method defines the application bundle entry, and this is done when 
    the object is created.

PARAMETERS
    none

GLOBALS USED
    none

RETURN VALUES
    none

HISTORY

    --/--/91 Shridar Subramanian
*/

{
   IGRint	status = TRUE;
   IGRlong	msg;
   IGRshort	num_fields;
   IGRshort	sizes[18];
   IGRshort	offsets[18];

  /* set up sizes and offsets for regular symbology		*/
	sizes[0] = 0;

	offsets[0] = 0;

	num_fields =  0;

  /* define entry for regular symbology			*/

	status = om$send (	mode = OM_e_wrt_message,
				msg =  message HStable.define_entry(&msg,num_fields,sizes,
								   offsets),
				senderid = my_id,
	   			targetid = my_id);
	 
	return(status);

}


method	add_entry( IGRlong   *msg; IGRchar *entry;  IGRint flags; IGRint *index)

/*

NAME 
    add_entry

KEYWORD
    Bundle Tables

DESCRIPTION
    This method adds en entry to the application bundle table
     If the size of the input bundle does not match the application
    bundle size specification or if the size is such that the 
    data is not aligned properly, an error is returned.

PARAMETERS
    msg      (OUT)  - Any error messages are returned.
    entry    (IN)   - The entry to be added to the bundle table.
                      First four bytes represent the entry size.

    flags    (IN)   - 
    index    (OUT)  - Index of the new entry in the bundle table.

GLOBALS USED
    none

RETURN VALUES
    0     success
    -1    size does not match
    -2    improper alignment
HISTORY

    --/--/91 Shridar Subramanian
*/

{

    IGRint	status = TRUE;
    IGRint      size;

	*msg = MSSUCC;

  /* send add to regular symbology object		*/

        size = *((int *) entry);
        if (size ! = ME.HStable->entry_size)
        {
            *index = -1;
            return(-1);
        }
        if (size % 8)
        {
            *index = -1;
            return(-2); 
        }
	status = om$send ( mode = OM_e_wrt_message,
			   msg = message  HStable.add_entry(msg,&entry[8], 0, index),
			   senderid = my_id,
			   targetid = my_id);



	return(status);
}


method	 create_entry(IGRlong *msg; IGRchar *entry; IGRint flags; IGRint *index)
/*

NAME 
    create_entry

KEYWORD
    Bundle Tables

DESCRIPTION
    This method creates an entry in the application bundle table
     If the size of the input bundle does not match the application
    bundle size specification or if the size is such that the 
    data is not aligned properly, an error is returned.
    The reference count associated with a bundle is not incremented
    when a create_entry is performed.

PARAMETERS
    msg      (OUT)  - Any error messages are returned.
    entry    (IN)   - The entry to be create in the bundle table.
                      First four bytes represent the entry size.

    flags    (IN)   - 
    index    (OUT)  - Index of the new entry in the bundle table.

GLOBALS USED
    none

RETURN VALUES
    0     success
    -1    size does not match
    -2    improper alignment
HISTORY

    --/--/91 Shridar Subramanian

*/
{

    IGRint	status = TRUE;
    IGRint      size;

	*msg = MSSUCC;



  /* send create to regular symbology object		*/

        size = *((int *) entry);
        if (size ! = ME.HStable->entry_size)
        {
            *index = -1;
            return(-1);
        }
        if (size % 8)
        {
            *index = -1;
            return(-2); 
        }
	status = om$send ( mode = OM_e_wrt_message,
			   msg = message  HStable.create_entry(msg,&entry[8], flags, index),
			   senderid = my_id,
			   targetid = my_id);

  /* set up HSsymb structure that needs to be created	*/

	return(status);
}



method	retrieve_entry(
IGRlong *msg; 
IGRint index; 
IGRchar *entry)

/*

NAME 
    retrieve_entry

KEYWORD
    Bundle Tables

DESCRIPTION
    This method retrieves the bundle entry corresponding to the
    index passed in.
PARAMETERS
    msg      (OUT)  - Any error messages are returned.
    entry    (OUT)  - The retrived entry is returned in this.
                      First four bytes represent the entry size.

    index    (IN)   - Index of the entry to be retrieved.

GLOBALS USED
    none

RETURN VALUES
    0     success
HISTORY

    --/--/91 Shridar Subramanian

*/

{

    IGRint	status = TRUE;
    char        *temp_ptr;

                    /* 8 bytes for the size and some unused chars */
    temp_ptr = (char *)malloc(ME.HStable->entry_size + 8);
 
    *((int *)temp_ptr) = ME.HStable->entry_size; 
    *((int *)&temp_ptr[4]) = 0;

  /* make sure entry has been defined					*/

    status = om$send(mode = OM_e_wrt_message,
                     msg = message HStable.retrieve_entry (msg,index, &temp_ptr[8]),
		     senderid = my_id,
 		     targetid = my_id);
    memcpy(entry,temp_ptr,(ME.HStable->entry_size + 8));

	
    free(temp_ptr);
	return(status);
}

method	delete_entry(
IGRlong *msg; 
IGRint index; 
IGRint flags)

/*

NAME 
    delete_entry

KEYWORD
    Bundle Tables

DESCRIPTION
    This method deletes the bundle entry corresponding to the
    index passed in.
PARAMETERS
    msg      (OUT)  - Any error messages are returned.
    flags    (IN)   - 
    index    (IN)   - Index of the entry to be deleted.

GLOBALS USED
    none

RETURN VALUES
    0     success
HISTORY

    --/--/91 Shridar Subramanian

*/
{

    IGRint	status = TRUE;

  /* make sure entry has been defined					*/


		    status = om$send (	mode = OM_e_wrt_message,
						msg = message  HStable.delete_entry(msg,index,
										   0),
						senderid = my_id,
						targetid = my_id);

  /* delete application entry					*/

	return(status);
}



method wake_up()

/*
NAME 
    wake_up

KEYWORD
    Bundle Tables

DESCRIPTION
    This method sets up the object_id os_number array. Also it
    deletes any old I/Design bundles. ( I/Design bundles that were 
    created according to the old bundle table design, i.e. I/Design
    bundles consisting of 7 fields. This is  to incorporate 
    a late change in design). 
PARAMETERS
    none
GLOBALS USED
    none

RETURN VALUES
    none
HISTORY

    --/--/91 Shridar Subramanian
    02/02/92 Shridar Subramanian
             Modified to handle the new I/Design specifications.

*/
{

    IGRint	status = TRUE;

extern void	HSinit_appsymb_id();
/*extern void     HSset_appsymb_id();*/

	status = om$send( mode = OM_e_wrt_message,
			  msg =  message HStable.wake_up(),
			  senderid = my_id,
			  targetid = my_id);

	if (!( 1 & status))
	{
#ifdef DEBUG
    	    om$report_error(sts = status);
#endif
	    goto wrapup;
	}


	if (!ex$is_temp_wakeup())
	{
	    HSinit_appsymb_id();
	}
 
        HSset_appsymb_id(my_id, OM_Gw_current_OS);

/*

The following portion of the code destroys all I/Design tables if they
are of the old type 

*/


 if (ME.HStable->num_fields==7)
 {
     ME.HStable->entry_size = 0;
     ME.HStable->num_fields = 0;
     ME.HStable->field_sizes[0] = 0;
     ME.HStable->offsets[0]  = 0;
     ME.HStable->num_entries = 0;
     ME.HStable->num_links[0] = -1;
     ((int *)ME.HStable->entries)[0]   |= HSENTRY_DELETED;
 }
  if ( ME.HStable->entry_size == 0 ) 
  {
      ME.HStable->new_entry_ptr = NULL;
  }
     

      




wrapup:

	return(status);
}


/* undef sleep so OPP won't give an error because sleep() is also */
/* a function defined in stdlib.h                                 */
%undef sleep

method sleep(int temp_sleep)

/*
NAME 
    sleep

KEYWORD
    Bundle Tables

DESCRIPTION
    This method resets  the object_id os_number array.
PARAMETERS
    none
GLOBALS USED
    none

RETURN VALUES
    none
HISTORY

    --/--/91 Shridar Subramanian

*/
{
/*extern  void HSreset_appsymb_id();*/

    HSreset_appsymb_id(OM_Gw_current_OS);
    
    if ( ME.HStable->entry_size == 0 )
    {
        ME.HStable->new_entry_ptr = NULL;
    }

return(OM_S_SUCCESS);
}

method get_app_entry_size (IGRlong msg; int *size)

/*
NAME 
    get_app_entry_size

KEYWORD
    Bundle Tables

DESCRIPTION
    This method returns the size of an entry in the application bundle
    table
PARAMETERS
    msg    (OUT) - Any messages to be returned
    size   (OUT) - The size of an application bundle entry. 
GLOBALS USED
    none

HISTORY

    --/--/91 Shridar Subramanian

*/
{
 
   *size = ME.HStable->entry_size;

   return(OM_S_SUCCESS);
   
}

method get_app_num_fields (IGRlong msg; int *num_fields)

/*
NAME 
    get_app_num_fields

KEYWORD
    Bundle Tables

DESCRIPTION
    This method returns the number of fields in an entry in the 
    application bundle table
PARAMETERS
    msg        (OUT) - Any messages to be returned
    num_fields (OUT) - The number of fields.
GLOBALS USED
    none

HISTORY

    --/--/91 Shridar Subramanian

*/
{
 
   *num_fields = ME.HStable->num_fields;

   return(OM_S_SUCCESS);
   
}

method redefine_app_entry (IGRlong msg; char *app_entry)

/*
NAME 
    redefine_app_entry

KEYWORD
    Bundle Tables

DESCRIPTION
    This method redefines the application bundle entries.
    (Usually this implies a change in the size of each entry in 
    the application bundle table. Therefore the caller is also 
    expected to pass in the additional padding to be used in 
    each of the existing entries).
PARAMETERS
    msg        (OUT) - Any messages to be returned
    app_entry  (OUT) - Contains the new size and the additional
                       padding for each entry.
                       ---- ---- ---... ...------
                       size pad  additional padding for each entry
                       (Each - represents a byte)
GLOBALS USED
    none

HISTORY

    02/02/92 Shridar Subramanian

*/
{
    IGRint      new_size,i,new_storage_size,old_storage_size;
    IGRchar     *ptr,*temp_ptr,*old_ptr,*app_new_val;

    new_size = *((int *)app_entry);
    if (ME.HStable->new_entry_ptr)
    {
        om$dealloc(ptr = ME.HStable->new_entry_ptr);
        ME.HStable->new_entry_ptr = NULL;
    }
 
    ME.HStable->new_entry_ptr = om$malloc( size = new_size);
    if (new_size  > ME.HStable->field_sizes[0])
    {
	    app_new_val = &app_entry[8];
	    ME.HStable->num_fields = 1;
	    ME.HStable->field_sizes[0] = new_size;
	    ME.HStable->offsets[0]    = 0;

	    
	    old_storage_size =  ME.HStable->entry_size  + 4;
	    new_storage_size = new_size  + 4;

	    ptr = (char *) malloc(ME.HStable->num_entries * new_storage_size );
	    temp_ptr = ptr;
	    old_ptr = ME.HStable->entries;
	    for (i=0;i<ME.HStable->num_entries;i++)
	    {
		 memcpy(temp_ptr,old_ptr,old_storage_size);
		 temp_ptr += old_storage_size;
		 old_ptr +=  old_storage_size;
		 memcpy(temp_ptr,app_new_val,(new_size - ME.HStable->entry_size));
		 temp_ptr += (new_size - ME.HStable->entry_size);

	     }
	     ME.HStable->entry_size = new_size;
	     om$vla_set_dimension(varray = ME.HStable->entries, size = ME.HStable->num_entries * new_storage_size);
	     memcpy(ME.HStable->entries,ptr,ME.HStable->num_entries * new_storage_size);
	 
     }
     return(OM_S_SUCCESS);
  
}

    
     
     


method debug()

/*
NAME 
    debug

KEYWORD
    Bundle Tables

DESCRIPTION
    This method prints out the contents of each entry in the application
    bundle table. It does not try to interpret the fields, but instead
    prints them out as characters
PARAMETERS
    none
GLOBALS USED
    none

HISTORY

    02/02/92 Shridar Subramanian

*/
{

    int	i,j,k;
    int	int_temp;
    int	storage_size;
    int	inst_entry_size;
    IGRchar	*inst_entry_ptr;
    double   double_temp;
    float    float_temp;
    IGRchar     *temp_ptr;




	inst_entry_ptr = ME.HStable->entries;

	storage_size = (ME.HStable->entry_size + 3)& 0xfffffffc;

  /* calculate actually size of stored data - structure size rounded up
     to be IGRlong word aligned and add int for flags			*/

	inst_entry_size = storage_size + sizeof (int);
		

	for (i = 0; i < ME.HStable->num_entries; i++,inst_entry_ptr += inst_entry_size)
	{
	    printf ("\n\nEntry %d\n",i);
	    if ((*(int *) inst_entry_ptr & HSENTRY_DELETED))
	    {
		printf ("deleted\n");
	    }
	    else
	    {
		printf("number of links is %d\n",ME.HStable->num_links[i]);
		for (j = 0; j < ME.HStable->num_fields; j++)
		{
		    printf("Field #%d is ",j);
		    switch (ME.HStable->field_sizes[j])
		    {
			case 1:
                            int_temp=0;
			    memcpy(&int_temp,inst_entry_ptr + 4 + ME.HStable->offsets[j],1);
			    printf ("%d\n",int_temp);
			    break;

			case 2:
                            int_temp=0;
			    memcpy(&int_temp,inst_entry_ptr + 4 + ME.HStable->offsets[j],2);
			    printf ("%d\n",int_temp);
			    break;

			case 4:
                            int_temp=0;
                            float_temp=0.0;
			    memcpy(&float_temp,inst_entry_ptr + 4 + ME.HStable->offsets[j],4);
			    memcpy(&int_temp,inst_entry_ptr + 4 + ME.HStable->offsets[j],4);
			    printf ("%d %f\n",int_temp,float_temp);
			    break;

			case 8:
                            double_temp=0.0;
			    memcpy(&double_temp,inst_entry_ptr + 4 + ME.HStable->offsets[j],8);
			    printf ("%g\n",double_temp);
			    break;
	
			default:
                            if (ME.HStable->field_sizes[0])
                            {
                               temp_ptr = (char *) malloc(ME.HStable->field_sizes[0]);                    
                               memcpy(temp_ptr,inst_entry_ptr + 4, ME.HStable->field_sizes[0]);
                               for (k=0;k<ME.HStable->field_sizes[0];k++)
                                     printf("%c",temp_ptr[k]);
                               printf("\n");
                               printf("Size %d\n",ME.HStable->field_sizes[0]);
                               free(temp_ptr);
                            }
			    break;

		    }
		}
	    }
	}

	return(1);
}
			
end implementation HSapp;
