/* ###################   APOGEE COMPILED   ################## */
/* ###################   ANSI COMPILED     ################## */
#include "EMS.h"
/*
 * NAME
 *	EMcpsearch
 *
 * Abstract
 *    	This routine performs a special kind of a search
 * 	needed by internal copy methods
 *
 * Synopsis
 *	void EMcpsearch (rc,
 *			   objid,
 *			   copy_id,
 *			   copy_info,
 *			   option,
 *			   copy_exists)  
 *			 
 *
 * Description
 *    	This function checks if the incomong objid is exists
 *	in the objid_array. The manipulation of objid_array and
 * 	the return valus depend on the caller's option.
 *
 * objid: The incoming objid
 *
 * *copy_id: The objid of the copy. It may be sent by the caller
 *	     or returned by the function based upon the caller's
 * 	     option.
 *
 * *copy_info: The struct containing the stored information.
 *	       The objid_array is a contiguous array of objid
 *	       and copy_id's.
 *
 * option: 
 *    0 - find out if the incoming objid's copy already exists
 *	  or not. There may be two cases:
 *	  i) The incoming objid is not in the objid_array.
 *	     In this the return code will be MSSUCC and
 *	     copy_exists FALSE(0).
 *
 *	  ii) The incoming objid is in the objid_array. In this case
 *	      either the copy_id exists or not.
 *	      Copy_id is returned if it exists and copy_exists
 * 	      will be TRUE. Otherwise, copy_exists will be returned
 *	      as FALSE(0). In both cases the return code will be
 *	      MSSUCC.
 *
 *    1 - This option is a super set of the last option (0).
 *	  In addition to its functions for option = 0, it
 *	  inserts incoming objid into the objid_array if it
 *	  is not already present in the objid_array.
 *
 *    2 - Check if the incoming objid is already present in the
 *	  objid_array. If so, insert its copy_id in the
 *        object_array and return with success.. If objid is not 
 *	  present in the objid_array,
 *	  return with success.
 *
 *    3 - If the incoming objid is already present, put its
 *	  copy id in the objid_array. If incoming objid does
 *        not exists in the objid_array, insert objid and copy_objid
 *	  in the right places. 
 *
 *  Return Values:
 *	The return code can be one of the following:
 *	MSSUCC, MSFAIL, MSNOMEM
 */

#include <stdio.h>

/* igr.h replacement */


# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

/* end of gr.h replacement */
#include "msmacros.h"
#include <math.h>
#include "emsmacros_c.h"
#include "emserr.h"
#include "EMcp.h"
#include "emsdef.h"
#include "nd.h" /* For EMcp_list */

#define INITIAL_SIZE 100
#define INCREMENT    20
#define NO_COPIED_ID    -9999

void EMcpsearch (rc,
		   objid,
		   copy_id,
		   copy_info,
		   option,
		   copy_exists)

IGRlong	   		*rc;
GRobjid	   		objid, *copy_id;
struct EMcp_info	*copy_info;
IGRshort		option;
IGRboolean		*copy_exists;
{

  IGRlong    index_for_insert, objid_index;
  IGRlong    start, middle, end;

  IGRboolean OBJID_EXISTS = FALSE;

#ifdef DEBUG
fprintf (stderr,"\nreach EMcpsearch\n");
fprintf (stderr,"objid = %d\n", objid);
fprintf (stderr,"option = %d\n",option);
#endif

  *rc = MSSUCC;
  *copy_exists = FALSE;

  /*
   * malloc or realloc memory if needed
   */

   if (copy_info->objid_array == NULL )
   {

#ifdef DEBUG
fprintf (stderr,"going to malloc the memory\n");
#endif

	copy_info->num_entries = 0;
	copy_info->array_size = INITIAL_SIZE;
	copy_info->objid_array = (GRobjid *) malloc ((unsigned)
				   (INITIAL_SIZE * sizeof (GRobjid)));

	if (copy_info->objid_array == NULL)
	{
	   *rc = MSNOMEM;
	   goto wrapup;
	}
   }
   else  if ( (copy_info->num_entries * 2) == copy_info->array_size )
   	 {
	    /* extend the size of objid_array, as there is
	     * no more space available
	     */

#ifdef DEBUG
fprintf (stderr,"going to realloc the memory\n");
#endif


	    copy_info->array_size += INCREMENT;
	    copy_info->objid_array = (GRobjid *) realloc (
		copy_info->objid_array, (unsigned)(copy_info->array_size 
			* sizeof (GRobjid)));   

	    if (copy_info->objid_array == NULL)
	    {
		*rc = MSNOMEM;
		goto wrapup;
	    }
	 }

/* 
 * find out if the objid already exists or not
 */
	
#ifdef DEBUG
fprintf (stderr,"num_entries = %d\n", copy_info->num_entries);
#endif

if (copy_info->num_entries)
{
   if (objid < copy_info->objid_array[0])
   {
      index_for_insert = 0;
   }
   else if (objid == copy_info->objid_array[0] )
   {
        OBJID_EXISTS = TRUE;
	objid_index = 0;
   }
  
   else if (objid > copy_info->objid_array[(copy_info->num_entries - 1) 
								* 2])
   {
	  index_for_insert = copy_info->num_entries * 2;
   }
   else if (objid == copy_info->objid_array[(copy_info->num_entries - 1) 
							* 2])
   {
	OBJID_EXISTS = TRUE;
	objid_index = (copy_info->num_entries - 1) * 2;
   }
   else   /* objid is not <= first entry 
			or
	     objid is not >= last entry */

   {
	start = 0;
	end = copy_info->num_entries;
	middle = (start + end)/2;
	
	do
	{
	    middle = (start + end) / 2;
	    if (objid == copy_info->objid_array[middle * 2] )
	    {
		OBJID_EXISTS = TRUE;
		objid_index = middle * 2;
	    }
	    else if (objid < copy_info->objid_array[middle * 2] )
			end = middle - 1;
	         else
	   		start = middle + 1;
	} while (start <= end   &&  !OBJID_EXISTS );

	if (!OBJID_EXISTS) index_for_insert = start * 2;
     }

 }   /* if (copy_info->num_entries) */			   
 else
 {
	index_for_insert = 0;
 }

  /*
   * Perform the task as per the caller's option
   */

#ifdef DEBUG
fprintf (stderr,"OBJID_EXISTS = %d \n", OBJID_EXISTS);
fprintf (stderr,"copy_exists = %d \n",*copy_exists);
#endif

   switch (option)
   {
      case 0:
#ifdef DEBUG
fprintf (stderr,"reach option = 0\n");
#endif

	if (OBJID_EXISTS)
	{
	 if (copy_info->objid_array[objid_index + 1] == NO_COPIED_ID )
	    *copy_exists = FALSE;
	 else
	 {
	    *copy_id = copy_info->objid_array[objid_index + 1];
	    *copy_exists = TRUE;
	 }
	}
	else
	{
#ifdef DEBUG
fprintf (stderr,"reach else for if (OBJID_EXISTS)\n");
#endif

	   *copy_exists = FALSE;

#ifdef DEBUG
fprintf (stderr,"going to break for case 0 \n");
fprintf (stderr,"copy_exits = %d \n", *copy_exists );
#endif 
	}
	break;

#ifdef DEBUG
fprintf (stderr,"after break for case 0\n");
#endif 

      case 1:
#ifdef DEBUG
fprintf (stderr,"enter case 1\n");
#endif 

	if (OBJID_EXISTS)
	{
	 if (copy_info->objid_array[objid_index + 1] == NO_COPIED_ID )
	    *copy_exists = FALSE;
	 else
	 {
	    *copy_id = copy_info->objid_array[objid_index + 1];
	    *copy_exists = TRUE;
	 }
	}
	else
	{
	   IGRint  i;

	   for (i = copy_info->num_entries; i > (index_for_insert/2); i--)
	   {
	      copy_info->objid_array[2 * i] = 
			copy_info->objid_array[2 * i -2];
	      copy_info->objid_array[2 * i + 1] =
			copy_info->objid_array[2 * i - 1];
	   }
	      copy_info->objid_array[index_for_insert] = objid;
	      copy_info->objid_array[index_for_insert + 1] =
				NO_COPIED_ID;
	      (copy_info->num_entries)++;
	      *copy_exists = FALSE;
	}
#ifdef DEBUG
fprintf (stderr,"exit case 1\n");
#endif 
	break;
	
	case 2:
#ifdef DEBUG
fprintf (stderr,"enter case 2\n");
#endif 
	   if (OBJID_EXISTS)
		copy_info->objid_array[objid_index + 1] = *copy_id;
#ifdef DEBUG
fprintf (stderr,"exit case 1\n");
#endif 

	   break;

	case 3:
#ifdef DEBUG
fprintf (stderr,"enter case 3\n");
#endif 
	   if (OBJID_EXISTS)
	   {
	      if (copy_info->objid_array[objid_index + 1] ==
						NO_COPIED_ID )
	            copy_info->objid_array[objid_index + 1] = *copy_id;

	       else    /* object id and its copy are already there,
			  it is an error to call with this option */

		   *rc = MSFAIL;
	  }
	  else 	/* incoming objid is not already present in the objid_array
		   therefore, insert objid as well as copy_id */
	  {
	   IGRint i;

	   for (i = copy_info->num_entries; i > (index_for_insert/2); i--)
	   {
	      copy_info->objid_array[2 * i] = 
			copy_info->objid_array[2 * i -2];
	      copy_info->objid_array[2 * i + 1] =
			copy_info->objid_array[2 * i - 1];
	    } 
	      copy_info->objid_array[index_for_insert] = objid;
	      copy_info->objid_array[index_for_insert + 1] =
				*copy_id;
	      (copy_info->num_entries)++;

	  }
#ifdef DEBUG
fprintf (stderr,"enter case 3\n");
#endif 
	  break;

	} /*end switch */
#ifdef DEBUG
fprintf (stderr,"outside switch\n");
#endif 

wrapup:
#ifdef DEBUG
fprintf (stderr,"rech return\n");
#endif
	return;

  }			 

/*
 * This function will get the position of the incoming GRid in 
 * graph_array field of EMcp_info. This array is managed by
 * Associative sub-system. If the function could not find the
 * position of the incoming object, then it shall return a 
 * code of MSFAIL else it shall return MSSUCC;
 *
 * pp : 07/24/91 : Creation
 */

IGRlong EMget_clone_pos(EMmsg, options, in_GRid, cp_info, pos, clone_objid)
IGRlong *EMmsg;
unsigned int options;
struct GRid *in_GRid;
struct EMcp_info *cp_info;
IGRint *pos;
OM_S_OBJID *clone_objid;
{
 IGRint i,cnt;
 struct NDcp_list *cp_ptr;
 IGRboolean found = FALSE;

 *EMmsg = MSSUCC;

 cp_ptr = cp_info->graph_info.graph_array;
 cnt = cp_info->graph_info.graph_count;

  for (i=0;i < cnt;i++)
  {
   if (cp_ptr[i].original == in_GRid->objid)
   {
    *pos = i;
    found = TRUE;
    if (clone_objid)
      *clone_objid = cp_ptr[i].clone;
    break;
   }
  }
 
 if (!found)
  *EMmsg = MSFAIL;

 return (TRUE);
}
