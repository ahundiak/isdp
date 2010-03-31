
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:41 $
$Locker:  $
*/






/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     HStable		table class
	SUBCLASS OF:    global_class	super class

        Abstract:  class that returns indexes for tables

-----
%CD%

        CHANNELS DECLARED:

                      
                 
                                         
-----
%MD%

        MESSAGES DECLARED:



-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY


-----
%PD%
--------------------------------------------------------------------
                C L A S S    D E S C R I P T I O N
--------------------------------------------------------------------

This class purpose is to reduce the storage requirements of the object
space by allowing indices into a table of structures to be stored instead
of the structure itself.  This reduces the files size when there is a 
high chance of multiple objects saving the same structure (i.e. display
attributes of graphics objects).  The entries can be defined as permanent
entries that only get deleted when specifically told or they can automatically
keep track of how many objects access the structure and delete the entry when
that count goes to zero.
----*/
/*EH*/

class specification HStable(1:0) of global_class;

#include "igrtypedef.h"


instance HStable
{
		int		entry_size; 	/* size of the data structure		   */
		char		*new_entry_ptr; /* ptr to malloced memory used to 
						   manipulate the entries		   */
	     	short	num_fields;	/* number of fields in the data structure  */
    variable	short	field_sizes[1]; /* array of size num_fields that specifies 
						   the number of bytes per field	   */
    variable 	short	offsets[1];	/* array of size num_fields that specifies 
						   byte offset from beginning of data 
						   structure 				   */
		short	num_entries;	/* number of entries in the table	   */
    variable	char		entries[1];     /* contains the entries			   */
    variable	char		dir_name[0];    /* directory where names are kept	   */
    variable	int		num_links[1];   /* number of object accessing entry	   */
    channel  {(many_to_many,rel_ordered,initial=1,increment=1) HStable;} to_parent;
    channel  {(many_to_many,rel_ordered,initial=1,increment=1) HStable;} notification;
};
           


override	wake_up,sleep,debug;

 /* messages for entry manipulation */

/********************************************************************************

Message name - define_entry 

Arguments

 Input

	short	num_fields	- number of fields that define your
					  structure to be saved

	short	*sizes		- array of size num_fields that
					  tells the size (i.e. number or bytes)
					  of each field

	short	*offsets	- array of size num_fields that tells the
					  number of bytes offset from the beginning
					  of the structure.


	NOTE:	The sizes and the offsets have to correspond to each other and
		the offsets have to be in increasing order.
		Example:


		struct x
		{
		   int 		a;
		   short 	b;
		   double	c;
		} new_x;

		size[0] = sizeof (new_x.a);
		size[1] = sizeof (new_x.b);
		size[2] = sizeof (new_x.c);

		offsets[0] = (int) &new_x.a - (int) &new_x;
		offsets[1] = (int) &new_x.b - (int) &new_x;
		offsets[2] = (int) &new_x.c - (int) &new_x;
		 
  Output

	long		*msg		- pointer to return message
					  MSSUCC - Success
					  MSFAIL - Failure
						     num_fields < 1

Return code
	TRUE 	- Success
	FALSE	- Failure
		  num_fields < 1

Description

   This message is used to define the format of the structures to be stored.
   IMPORTANT - This message has to be called before any entry manipulation
               is done and the entry passed to any message has to be in the
	       defined format.

********************************************************************************/

message	define_entry(long *msg; short num_fields; short *sizes;
		     short *offsets);



/*******************************************************************************

Message name - create_entry 

Arguments

  Input

	char		*entry		- pointer to an entry 

	int		flags		- options for create entry
					  HSPERM_ENTRY - create a permanent entry
						(i.e. don't keep track of number of
						links and only delete if specifically 
						told to)
					  
  Output

	long		*msg		- pointer to return message
					  MSSUCC - Success
					  MSFAIL - Failure
						   entry not defined

	int  	*index 		- The index of the entry


Return code
	TRUE 	- Success
	FALSE	- Failure
		  entry not defined

Description

	This Message is used to create a entry in the table. It is used when
	a entry is defined, not accessed.  It the entry is already in the
	table, the index is returned. If HSPERM_ENTRY is set int the flags argument,
	then the number of links is set to -1.  If the entry is not in the table
	the entry is added, number of links is set to 0 and the index is returned.
	This differs from add entry which increments the number of links by one.


********************************************************************************/

message	create_entry(long *msg; char *entry; int flags; int *index);



/*******************************************************************************

Message name - add_entry 

Arguments

  Input

	char		*entry		- pointer to an entry 

	int		flags		- options for add entry
					  HSADD_BY_INDEX -uses the entry as 
					     a pointer to an index and adds 
					     by index.  If the index specified
					     does not exist, an error is returned.

					  
  Output

	long		*msg		- pointer to return message
					  MSSUCC - Success
					  MSFAIL - Failure
						   - if GRADD_BY_INDEX and
						     index does not exist
						   - entry not defined

	int  	*index 		- The index of the entry


Return code
	TRUE 	- Success
	FALSE	- Failure
		  - if HSADD_BY_INDEX and index does not exist
		  - entry not defined

Description

	This message is used to add an entry to the table.  If the entry
	does not exist, then one is created and number of links is set to 1.
	If an entry exists, then the number of links is incremented by one (only
	if it is not a permament entry).  If you want to add by index (e.g. object
	is created and the index of the entry is know) you can the the flags
	argument.

********************************************************************************/

message	add_entry(long *msg; char *entry; int flags; int *index);



/********************************************************************************

Message name - retrieve_entry 

Arguments

  Input

	int  	index 		- The index of the entry

					  
  Output

	long		*msg		- pointer to return message
					  MSSUCC - Success
					  MSFAIL - Failure
						   - If index does not exist
						   - entry not defined

	char		*entry		- table entry cooresponding to 
					  the index
Return code
	TRUE 	- Success
	FALSE	- Failure
		  - If index does not exist
		  - entry not defined


Description

	This message will return the entry identified by the index passed in.
	If the index does not exist an error will be returned.

********************************************************************************/

message	retrieve_entry(long *msg; int index; char *entry);



/********************************************************************************

Message name - retrieve_index 

Arguments

  Input

	char		*entry		- pointer to table entry
					  

  Output

	long		*msg		- pointer to return message
					  MSSUCC - Success
					  MSFAIL - Failure
						   - if entry does not exist
						   - entry not defined

	int  	*index 		- The index coorensponding to the 
					  entry that was passed in.  If
					  the entry is not found an error
					  is returned.

Return code
	TRUE 	- Success
	FALSE	- Failure
		  - If entry does not exist
		  - entry not defined

Description

	This message will return the index identified by the entry passed in.
	If the entry does not exist an error will be returned.


********************************************************************************/

message	retrieve_index(long *msg; char *entry; int *index);



/********************************************************************************

Message name - delete_entry 

Arguments
  Input

	int  	index 		- The index of the entry to delete

	int		flags		- options for delete entry
					  HSPERM_ENTRY - has to be set to 
							 delete a permanent entry

					  
  Output

	long		*msg		- pointer to return message
					  MSSUCC - Success
					  MSFAIL - Failure
						   - index does not exist
						   - entry not defined


Return code
	TRUE 	- Success
	FALSE	- Failure
		  - index does not exist
		  - entry not defined

Description

   This message is used to delete an entry in the table.  If the entry
   is a permanent entry, then the GRPERM_ENTRY flag has to be set to 
   delete the entry.  If the entry is not a permanent entry then the
   number of links will be decremented and if equal to zero it
   will be marked as deleted.


********************************************************************************/

message	delete_entry(long *msg; int index; int flags);



/********************************************************************************

Message name - replace_entry 

Arguments

  Input

	char		*entry		- pointer to table entry
					  
	int  	index 		- The index that you want replaced
					  with the table entry passed in.
					  If the index does not exist, an
					  error is returned


  Output

	long		*msg		- pointer to return message
					  MSSUCC - Success
					  MSFAIL - Failure
						   - if index does not exist
						   - entry not defined

Return code
	TRUE 	- Success
	FALSE	- Failure
		  - if index does not exist
		  - entry not defined

Description

   This message is used to replace an existing table entry with a different 
   table entry.  If the index does not exist, an error will occur.  
   WARNING: ALL OBJECTS REFERENCE THIS INDEX WILL NOW REFERENCE THE NEW ENTRY!!


********************************************************************************/

message	replace_entry(long *msg; int index; char *entry);



/********************************************************************************

Message name - change_entry 

Arguments

  Input

	char		*entry		- pointer to table entry

	int		old_index	- old entry to be deleted

	int		flags		- options for change entry
					  HSADD_BY_INDEX -uses the entry as 
					     a pointer to an index and adds 
					     by index.  If the index specified
					     does not exist, an error is returned.

  Output

	long		*msg		- pointer to return message
					  MSSUCC - Success
					  MSFAIL - Failure
						   - if old_index does not exist
						   - entry not defined

	int  	*new_index	- The index of the new entry


Return code
	TRUE 	- Success
	FALSE	- Failure
		  - If old_index does not exist
		  - entry not defined


Description

   This message is used to delete an old entry and add a new entry.  This 
   message actually sends a delete_entry to delete the old entry and then
   sends an add_entry to add a new entry.  The reason this message was 
   created is to only do both sends in one place instead of in every 
   method that needs to do this.


********************************************************************************/

message	change_entry(long *msg; int old_index; char *entry; int flags; int *new_index);

 /* message for name manipulation - not implemented */

message	add_names(long *msg; int num_names; char **names; 
		 char *indexes);
message	retrieve_names(long *msg; int *num_names; 
		       int *index; char **name);
message	retrieve_name_index(long *msg; char *name; int *index);
message	retrieve_num_names(long *msg; int *num_names);
message	delete_names(long *msg; int num_names; int *indexes);

end specification HStable;
