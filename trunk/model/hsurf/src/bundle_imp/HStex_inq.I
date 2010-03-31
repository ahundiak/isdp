/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:35 $
$Locker:  $
*/

class implementation HStex_table;

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"
#include "hsdef.h"
#include "hsmacdef.h"
#include "hsmacros.h"

#include "HSpr_bundle.h"



method inquire_texture_file (IGRchar *filename; IGRint *status)

/*
NAME
    inquire_texture_file

KEYWORD
    Bundle Tables

DESCRIPTION
    Given a file name this method returns one of the following status
      the entry corresponding to the file is already present in the table
      the entry can be added only if it is the active texture filename
      the entry cannot be added
      the entry can be added

PARAMETERS
    filename    (IN) - Filename to be added to the texture table
    status      (OUT)- One of the above explained status

GLOBALS USED
    none
 
HISTORY
    --/--/91  Shridar Subramanian

*/

{
   IGRint   count;
   unsigned short i,index,actindex,curr_vla_size;


   *status = NO_STATUS;
   curr_vla_size = om$dimension_of(varray = me->tex_file_index);
   index =0;
   count =0;
   for (i=1;i< curr_vla_size;i++)
   {
        if (me->tex_file_index[i].ref_ct==0)
        {
           index=i;
           count++;
        }
   }

   for(i=1;i<curr_vla_size &&(me->tex_file_index[i].offset != -1);i++)
   {
     if (strcmp(filename, &me->filenames[me->tex_file_index[i].offset])==0)
            *status = ENTRY_PRESENT;
   }
  
   if (*status != ENTRY_PRESENT)
   {
      if((count ==0) &&   (curr_vla_size >= 255))
            *status = NO_ENTRY;
      else
      {
          hs$get_active_shading_symb(tex_index = &actindex);
          if ((count ==1) && (curr_vla_size >= 255) && (index == actindex)) 
                  *status = ACTIVE_ONLY;
          else
                  *status = ANY_ENTRY;
      }
   }
return(OM_S_SUCCESS);
}




method review_texture_file (IGRchar *filename; IGRint *ref_ct; IGRint first_time)

/*

NAME
   review_texture_file

KEYWORD
   Bundle Tables

DESCRIPTION
   This method lists the next filename in the texture table. (The previous
   index is stored in the instance data last_index). This method is supposed
   to be used with the command review textures in file.

PARAMETERS
   filename    (OUT) - The next filename in the texture table
   ref_ct      (OUT) - the ref count associated with the above file name.
   first_time  (IN)  - Indicates whether this is the first call to review
                       _texture_file.

GLOBALS USED
   none

HISTORY
   --/--/91

*/

{
  unsigned short  curr_vla_size;
  int found;

  curr_vla_size = om$dimension_of(varray = me->tex_file_index);
  if (first_time)
       me->last_index = 0;
  me->last_index++;   
  if (me->last_index >= curr_vla_size)
  {
          *ref_ct = -1;
          strcpy(filename,"");
  }
  else
  {
          found =0;
	  while ((!found) && (me->last_index < curr_vla_size))
	  {
	    if (me->tex_file_index[me->last_index].ref_ct >0)
	    {
		found = 1;
		*ref_ct = me->tex_file_index[me->last_index].ref_ct;
		strcpy(filename, 
		       &me->filenames[me->tex_file_index[me->last_index].offset]);
	    }
	    else
	      me->last_index++;
	  }
  }
  return(OM_S_SUCCESS);
}     
        
  
end implementation HStex_table;
