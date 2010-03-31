
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/


class implementation HStable;

#include <stdio.h>
#include <string.h>

#include "OMerrordef.h"
#include "OMmacros.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "exmacros.h"

#include "hstabdef.h"
#include "hstabmacros.h"
#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"

#include "HSpr_bundle.h"


method	define_entry(
IGRlong *msg; 
IGRshort num_fields; 
IGRshort *sizes; 
IGRshort *offsets)
{

    int status = OM_S_SUCCESS;
    int storage_size;

	*msg = MSSUCC;

  /* make sure number of fields is ok and that there are no entries	*/

	if ((num_fields > 0) && (ME.HStable->num_entries == 0))
	{
	    ME.HStable->num_fields = num_fields;

  /* set vla to the appropriate sizes					*/

	    status = om$vla_set_dimension( varray = ME.HStable->field_sizes,
					   size = num_fields);
	    
	    
	    if (! (status & 1))
	    {
#ifdef DEBUG
		om$report_error(sts = status);
#endif
		goto wrapup;
	     }

	    status = om$vla_set_dimension( varray = ME.HStable->offsets,
					   size = num_fields);
	    
	    
	    if (! (status & 1))
	    {
#ifdef DEBUG
		om$report_error(sts = status);
#endif
		goto wrapup;
	     }

  /* move sizes and offsets into instance data				*/

	    OM_BLOCK_MOVE(sizes,ME.HStable->field_sizes,sizeof(IGRshort) * num_fields);
	    OM_BLOCK_MOVE(offsets,ME.HStable->offsets,sizeof(IGRshort) * num_fields);

  /* calculate size of entry 						*/
  /* actually store entry size rounded up to be IGRlong word aligned and
     then store a flags word for each entry (int)			*/

	    ME.HStable->entry_size = ME.HStable->offsets[num_fields -1] + 
				     ME.HStable->field_sizes[num_fields -1];

  /* rounding up to be IGRlong word (4 byte alligned)			*/

	    storage_size = (ME.HStable->entry_size + 3) & 0xfffffffc;

  /* malloc memory to be used for table manipulation			*/

	    ME.HStable->new_entry_ptr = om$malloc( size = storage_size);

	}
	else if ( num_fields == 0 )
	{
	   ME.HStable->num_entries = 0;
	   ME.HStable->entry_size = 0;
	   ME.HStable->num_fields = 0;
	   storage_size = (ME.HStable->entry_size + 3) & 0xfffffffc;

           if (storage_size)
	       ME.HStable->new_entry_ptr = om$malloc( size = storage_size);
	}
	else
	   status = OM_E_ERROR;

wrapup:
	return(status);
}

method	create_entry( 
IGRlong *msg; 
IGRchar *entry; 
int  flags;
int *index)
{

    int	status = TRUE;
    int 	i;
    int	field_end;
    int	storage_size;
    int	first_avail_entry = -1;
    int	inst_entry_size;
    int	found_entry = FALSE;
    IGRchar	*inst_entry_ptr;


  /* make sure entry has been defined					*/

	if (ME.HStable->num_fields > 0)
	{
	    *msg = MSSUCC;
	    inst_entry_ptr = ME.HStable->entries;

	    storage_size = (ME.HStable->entry_size + 3)& 0xfffffffc;

  /* calculate actually size of stored data - structure size rounded up
     to be IGRlong word aligned and add int for flags			*/

	    inst_entry_size = storage_size + sizeof (int);

	    OM_BLOCK_MOVE(entry,ME.HStable->new_entry_ptr,ME.HStable->entry_size);

  /* since structures be me padded because of alignment problems, this 
     code zeroes out all padded data.  This is so we can do quicker
     comparisons							*/

	    for (i = 0; i < ME.HStable->num_fields - 1; i++)
	    {   
		field_end = ME.HStable->offsets[i] + ME.HStable->field_sizes[i];

		if ( field_end < ME.HStable->offsets[i+1])
		{
		    memset(ME.HStable->new_entry_ptr + field_end,0,
			       ME.HStable->offsets[i+1] - field_end);
		}
	    }

	    field_end = ME.HStable->offsets[ME.HStable->num_fields - 1] + 
			ME.HStable->field_sizes[ME.HStable->num_fields - 1];

	    if (field_end < storage_size)
	    {
		memset(ME.HStable->new_entry_ptr + field_end,0,
			    storage_size - field_end);
	    }

	    found_entry = FALSE;
	    *index = -1;

  /* search for entry							*/

	    for (i = 0; i < ME.HStable->num_entries; i++,inst_entry_ptr += inst_entry_size)
	    {

  /* make sure entry is not deleted				*/

		if (!(*(int *) inst_entry_ptr & HSENTRY_DELETED))
		{

  /* compare the entry (macro in grtabmacros.h)			*/

		    cmpentry(inst_entry_ptr+4,ME.HStable->new_entry_ptr,storage_size,found_entry);

		    if (found_entry)
		    {
			*index = i;
			break;
		    }

  /* see if there is another created entry  - ONLY 1 created entry (entry
     with num_links 0) will exist at one time					*/

		    if (ME.HStable->num_links[i] == 0)
		    {
			*index = i;
		    }
		}
		else
		{
  /* save first delete entry so it can be reused			*/

		    if (first_avail_entry == -1)
		    {
			first_avail_entry = i;
		    }
		}
	    }
	        

	    if (!found_entry)
	    {

  /* if there are no  entries with 0 links, use new entry		*/

		if (*index == -1)
		{
		    if (first_avail_entry == -1)
		    {

  /* if no deleted entries, add one to end				*/

			*index = ME.HStable->num_entries++;

			status = om$vla_set_dimension( varray = ME.HStable->entries,
					       size =	(ME.HStable->num_entries * 
							 inst_entry_size));
	        
	        
			if (! (status & 1))
			{
#ifdef DEBUG
			    om$report_error(sts = status);
#endif
			    goto wrapup;
			}

			status = om$vla_set_dimension( varray = ME.HStable->num_links,
							size =	(ME.HStable->num_entries));
	        
	        
			if (! (status & 1))
			{
#ifdef DEBUG
			    om$report_error(sts = status);
#endif
			    goto wrapup;
			}

		    }
		    else
		    {
  /* if there is a deleted entry, reuse it			*/

			*index = first_avail_entry;
		    }
		}


		inst_entry_ptr = &ME.HStable->entries[inst_entry_size * *index];

  /* make sure flags are 0 				*/

		*(int *) inst_entry_ptr = 0;
		inst_entry_ptr += 4;
		    
  /* copy entry into the table					*/

		OM_BLOCK_MOVE(ME.HStable->new_entry_ptr,inst_entry_ptr,
				  storage_size);

  /* set number of links to 0					*/

		ME.HStable->num_links[*index] = 0;

	    }

  /* if a permanent entry, denote by assigning number of links to -1	*/

	    if (flags & HSPERM_ENTRY)
	    {
		ME.HStable->num_links[*index] = -1;
	    }
	}
	else
	{
  /* entry has not been defined						*/

	    *msg = MSFAIL;
	    status = FALSE;
	}

wrapup:
	return(status);
}




method	add_entry( 
IGRlong *msg; 
IGRchar *entry; 
int flags; 
int *index)
{

    int	status = TRUE;
    int 	i;
    int	field_end;
    int	storage_size;
    int	first_avail_entry = -1;
    int	inst_entry_size;
    int	found_entry = FALSE;
    IGRchar	*inst_entry_ptr;



  /* make sure entry has been defined					*/

	if (ME.HStable->num_fields > 0)
	{
	
	    *msg = MSSUCC;
	    inst_entry_ptr = ME.HStable->entries;

	    storage_size = (ME.HStable->entry_size + 3) & 0xfffffffc;

  /* calculate actually size of stored data - structure size rounded up
     to be IGRlong word aligned and add int for flags			*/

	    inst_entry_size = storage_size + sizeof (int);

	    if (flags & HSADD_BY_INDEX)
	    {
  /* make sure index is defined				*/

		if (*(int *) entry < ME.HStable->num_entries)
		{
		    inst_entry_ptr = &ME.HStable->entries[*index * inst_entry_size];

		    if ( !(*(int *) inst_entry_ptr & HSENTRY_DELETED))
		    {
  /* increment number of links if not a permanent entry			*/

			if (ME.HStable->num_links[*(int *) entry] != -1)
			{
			    ME.HStable->num_links[*(int *) entry]++;
			}
		    }
		    else
		    {
  /* entry is deleted				*/

			*msg = MSFAIL;
			status = FALSE;
		    }
		}
		else
		{
  /* invalid index				*/
		    *msg = MSFAIL;
		    status = FALSE;
		}
	    }
	    else
	    {
  
		OM_BLOCK_MOVE(entry,ME.HStable->new_entry_ptr,ME.HStable->entry_size);

  /* since structures be me padded because of alignment problems, this 
     code zeroes out all padded data.  This is so we can do quicker
     comparisons							*/


		for (i = 0; i < ME.HStable->num_fields - 1; i++)
		{   
		    field_end = ME.HStable->offsets[i] + ME.HStable->field_sizes[i];

		    if ( field_end < ME.HStable->offsets[i+1])
		    {
			memset(ME.HStable->new_entry_ptr + field_end,0,
				   ME.HStable->offsets[i+1] - field_end);
		    }
		}

		field_end = ME.HStable->offsets[ME.HStable->num_fields - 1] + 
			    ME.HStable->field_sizes[ME.HStable->num_fields - 1];

		if (field_end < storage_size)
		{
		    memset(ME.HStable->new_entry_ptr + field_end,0,
				storage_size - field_end);
		}

		found_entry = FALSE;

  /* search for entry							*/

		for (i = 0; i < ME.HStable->num_entries; i++,inst_entry_ptr += inst_entry_size)
		{

  /* make sure entry is not deleted				*/

		    if (!(*(int *) inst_entry_ptr & HSENTRY_DELETED))
		    {

  /* compare the entry (macro in grtabmacros.h)			*/

			cmpentry(inst_entry_ptr+4,ME.HStable->new_entry_ptr,storage_size,found_entry);

			if (found_entry)
			{
			    *index = i;
			    break;
			}
		    }
		    else
		    {
  /* save first delete entry so it can be reused			*/

			if (first_avail_entry == -1)
			{
			    first_avail_entry = i;
			}
		    }
		}
		    

  /* if not entry found and not  return index, add new entry		*/

		if ((!found_entry) && ( !(flags & HSRET_INDEX)))
		{


		    if (first_avail_entry == -1)
		    {

  /* if no deleted entries, add one to end				*/

			*index = ME.HStable->num_entries++;

			status = om$vla_set_dimension( varray = ME.HStable->entries,
					       size =	(ME.HStable->num_entries * 
							 inst_entry_size));
	        
	        
			if (! (status & 1))
			{
#ifdef DEBUG
			    om$report_error(sts = status);
#endif
			    goto wrapup;
			}

			status = om$vla_set_dimension( varray = ME.HStable->num_links,
						    size =  (ME.HStable->num_entries));
	    
	    
			if (! (status & 1))
			{
#ifdef DEBUG
			    om$report_error(sts = status);
#endif
			    goto wrapup;
			}

		    }
		    else
		    {
  /* if there is a deleted entry, reuse it			*/

			*index = first_avail_entry;
		    }

  /* initialize number of links to zero - incremented below		*/

		    ME.HStable->num_links[*index] = 0;

		    inst_entry_ptr = &ME.HStable->entries[inst_entry_size * *index];

  /* make sure flags are 0 				*/

		    *(int *) inst_entry_ptr = 0;
		    inst_entry_ptr += 4;
		    
  /* copy entry into the table					*/

		    OM_BLOCK_MOVE(ME.HStable->new_entry_ptr,inst_entry_ptr,
				  storage_size);


		    
		}
		else
		{

  /* either found or not HSRET_INDEX			*/

		    if (!found_entry)
		    {

	    /* then HSRET_INDEX has to be TRUE and !found_entry and HSRET_INDEX is error  */

			*msg = MSFAIL;
			status = FALSE;
			goto wrapup;
		    }
		}

  /* if not permanent entry and not HSRET_INDEX, increment number of links	*/

		if ((ME.HStable->num_links[*index] != -1) || (flags & HSRET_INDEX))
		{
		    ME.HStable->num_links[*index]++;
		}
	    }		        
	}
	else
	{

  /* entry has not been defined						*/

	    *msg = MSFAIL;
	    status = FALSE;
	}

wrapup:
	return(status);
}


method	retrieve_index( 
IGRlong *msg; 
IGRchar *entry; 
int *index)
{
    int	status = TRUE;

  /* send message to add to retrieve the index		*/

	status = om$send (	mode = OM_e_wrt_object,
				msg =  message HStable.add_entry(msg, entry, HSRET_INDEX, index),
				senderid = my_id,
	   			targetid = my_id);
	

	return(status);
}


method	retrieve_entry( 
IGRlong *msg; 
int index; 
IGRchar *entry)
{
    int status = TRUE;
    int inst_entry_size;
    IGRchar *inst_entry_ptr;


  /* make sure entry has been defined					*/

	if (ME.HStable->num_fields > 0)
	{
  /* make sure index in not greater than num entries		*/

	    if (index < ME.HStable->num_entries)
	    {

  /* calculate actually size of stored data - structure size rounded up
     to be IGRlong word aligned and add int for flags			*/

		inst_entry_size = ((ME.HStable->entry_size + 3) & 0xfffffffc) + sizeof (int);

		inst_entry_ptr = &ME.HStable->entries[index * inst_entry_size];

  /* make sure entry is not deleted				*/

		if (*(int *) inst_entry_ptr & HSENTRY_DELETED)
		{
		   *msg = MSFAIL;
		   status = FALSE;
		   goto wrapup;
		}

  /* copy instance data into entry				*/

		*msg = MSSUCC;
		OM_BLOCK_MOVE(inst_entry_ptr + 4,
			      entry,ME.HStable->entry_size);

	    }
	    else
	    {
  /* index not valid						*/

		*msg = MSFAIL;
		status = FALSE;
	    }
	}
	else
	{
  /* entry not defined						*/

	    *msg = MSFAIL;
	    status = FALSE;
	}
wrapup:
	return(status);
}


method	delete_entry(
IGRlong *msg; 
int index; 
int flags)
{

    IGRchar	*inst_entry_ptr;
    int	inst_entry_size;
    int	delete_entry = FALSE;
    int	status = TRUE;

  /* make sure entry has been defined					*/

	if (ME.HStable->num_fields > 0)
	{
	    *msg =MSSUCC;

  /* make sure index is valid						*/

	    if (index < ME.HStable->num_entries)
	    {
  /* calculate actually size of stored data - structure size rounded up
     to be IGRlong word aligned and add int for flags			*/

		inst_entry_size = ((ME.HStable->entry_size + 3) & 0xfffffffc) + sizeof (int);
		inst_entry_ptr = &ME.HStable->entries[index * inst_entry_size];

  /* make sure entry is not deleted				*/

		if (! (*(int *) inst_entry_ptr & HSENTRY_DELETED))
		{

		    if (ME.HStable->num_links[index] == -1)
		    {
  /* only delete permanent entries if the HSPERM_ENTRY flag is set	*/

			if (flags & HSPERM_ENTRY)
			{
			    delete_entry = TRUE;
			}
		    }
		    else
		    {
  /* if not permanent and after decrementing number of links, number of links
     <= 0, delete entry								*/

			if (--ME.HStable->num_links[index] <= 0)
			{
			    delete_entry = TRUE;
			}

		    }

  /* if need be, mark entry as deleted				*/

		    if (delete_entry)
		    {

			*(int *) inst_entry_ptr |= HSENTRY_DELETED;
		    }

		}	    
		else
		{
  /* entry already deleted				*/

		    *msg = MSFAIL;
		    status = FALSE;
		}
	    }
	    else
	    {
  /* invalid index					*/

	       *msg = MSFAIL;
	       status = FALSE;
	    }
	}
	else
	{
  /* entry not defined					*/

	   *msg = MSFAIL;
	   status = FALSE;
	}

	return(status);
}

method	change_entry(
IGRlong *msg; 
int old_index; 
IGRchar *entry; 
int flags; 
int *new_index)
{

    int	status;

  /* delete old entry						*/

	status = om$send (	mode = OM_e_wrt_object,
				msg =  message HStable.delete_entry(msg,old_index,flags),
				senderid = my_id,
	   			targetid = my_id);

  /* if that succeeds, add new entry				*/

	if (status)
	{

	    status = om$send (	mode = OM_e_wrt_object,
				msg = message   HStable.add_entry(msg, entry, flags, new_index),
				senderid = my_id,
	   			targetid = my_id);
	}

	return(status);
}

method	replace_entry(
IGRlong *msg; 
int index; 
IGRchar *entry)
{
    int	status = TRUE;
    int 	i;
    int	field_end;
    int	storage_size;
    int	inst_entry_size;
    IGRchar	*inst_entry_ptr;



  /* make sure entry has been defined					*/

	if (ME.HStable->num_fields > 0)
	{
	    *msg = MSSUCC;

  /* make sure index is valid						*/

	    if (index < ME.HStable->num_entries)
	    {
		inst_entry_ptr = ME.HStable->entries;

		storage_size = (ME.HStable->entry_size + 3)& 0xfffffffc;

  /* calculate actually size of stored data - structure size rounded up
     to be IGRlong word aligned and add int for flags			*/

		inst_entry_size = storage_size + sizeof (int);
		inst_entry_ptr = &ME.HStable->entries[index * inst_entry_size];

  /* make sure entry is not deleted				*/

		if (! (*(int *) inst_entry_ptr & HSENTRY_DELETED))
		{

		    OM_BLOCK_MOVE(entry,ME.HStable->new_entry_ptr,ME.HStable->entry_size);

  /* since structures be me padded because of alignment problems, this 
     code zeroes out all padded data.  This is so we can do quicker
     comparisons							*/

		    for (i = 0; i < ME.HStable->num_fields - 1; i++)
		    {   
			field_end = ME.HStable->offsets[i] + ME.HStable->field_sizes[i];

			if ( field_end < ME.HStable->offsets[i+1])
			{
			    memset(ME.HStable->new_entry_ptr + field_end,0,
				   ME.HStable->offsets[i+1] - field_end);
			}
		    }

		    field_end = ME.HStable->offsets[ME.HStable->num_fields - 1] + 
			    ME.HStable->field_sizes[ME.HStable->num_fields - 1];

		    if (field_end < storage_size)
		    {
			memset(ME.HStable->new_entry_ptr + field_end,0,
				storage_size - field_end);
		    }


		    inst_entry_ptr += 4;

  /* replace the entry							*/
		    
		    OM_BLOCK_MOVE(ME.HStable->new_entry_ptr,inst_entry_ptr,
				  storage_size);

		}
		else
		{
  /* entry already deleted					*/

		    *msg = MSFAIL;
		    status = FALSE;
		}
	    }
	    else
	    {
  /* invalid index						*/

		*msg = MSFAIL;
		status = FALSE;
	    }
	}	
	else
	{
  /* entry not defined						*/

	    *msg = MSFAIL;
	    status = FALSE;
	}

	return(status);
}

 /* message for name manipulation  - not implemented  */

method	add_names(
IGRlong *msg; 
int num_names; 
IGRchar **names; 
IGRchar *indexes)
{
	return(1);
}

method	retrieve_names(
IGRlong *msg; 
int *num_names; 
int *index; 
IGRchar **name)
{
	return(1);
}

method	retrieve_name_index(
IGRlong *msg; 
IGRchar *name; 
int *index)
{
	return(1);
}

method	retrieve_num_names( 
IGRlong *msg; 
int *num_names)
{
	return(1);
}

method	delete_names( 
IGRlong *msg; 
int num_names; 
int *indexes)
{
	return(1);
}

method wake_up()
{

    int status = TRUE;
    int storage_size;

	if (!ex$is_temp_wakeup())
	{
	    if (ME.HStable->entry_size)
	    {
		storage_size = (ME.HStable->entry_size + 3) & 0xfffffffc;
		ME.HStable->new_entry_ptr = om$malloc( size = storage_size);
	    }
	}

	return(status);
}

method global_class.sleep( int temp_sleep )
{

    int	status = TRUE;

	if (!temp_sleep)
	{
	   om$dealloc(ptr = ME.HStable->new_entry_ptr);
	}

	return(status);
}


method debug()
{

    int	i,j;
    int	int_temp;
    int	storage_size;
    int	inst_entry_size;
    IGRchar	*inst_entry_ptr;
    double   double_temp;
    float    float_temp;




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
			    printf ("????\n");
			    break;

		    }
		}
	    }
	}

	return(1);
}
			
end implementation HStable;
