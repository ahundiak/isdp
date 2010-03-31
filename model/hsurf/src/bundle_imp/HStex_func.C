
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:34 $
$Locker:  $
*/

#include <stdio.h>
#include <string.h>

#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"

#include "hsurf.h"
#include "hssymb.h"
#include "hstex_table.h"
#include "hsmacros.h"

#include "HSpr_bundle.h"



#if defined(__STDC__) || defined(__cplusplus)
	void HSrm_tex_file( IGRchar *filename,
	       struct offset_ref_ct *tex_file_index,
		     unsigned short index,
			     IGRint *last_offset,
		     unsigned short max_vla )
#else
	void HSrm_tex_file(filename, tex_file_index, index, last_offset,max_vla)
	IGRchar			*filename;
	struct offset_ref_ct	*tex_file_index;
	unsigned short		index;
	IGRint			*last_offset;
	unsigned short		max_vla;
#endif

/*
NAME
    HSrm_tex_file

KEYWORD
    Bundle Tables

DESCRIPTION
    This function removes a particular texture file from the texture table.
    Since the texture file names are stored in a 1 dimensional array, this
    function also repacks the array (moves filenames up and adjusts offsets
    ) after the file name has been deleted from the texture table.

PARAMETERS
    filename    (IN) - texture table vla
    index       (IN) - index of the entry to be deleted 
    max_vla     (IN) - size fo the vla
    last_offset (IN/OUT) - last offset in the texture table vla
    tex_file_index (IN/OUT) - the ref_ct and offset array  

GLOBALS USED
    none

RETURN VALUES
    none

HISTORY
    --/--/91 Shridar Subramanian

*/
    

{
  IGRint    length;
  IGRint    offset;
  unsigned short temp_index, i;

  temp_index = index;
  offset = tex_file_index[index].offset;
  length = strlen(&filename[offset]) + 1;


  OM_BLOCK_MOVE(&filename[offset+length], &filename[offset ],
         (*last_offset - offset - length )); 

  *last_offset -= length;
  tex_file_index[index].offset = -1; 
  for (i=1;i<max_vla;i++)
  {
     if  (tex_file_index[i].offset > = offset)
     {
         tex_file_index[i].offset -= length;
     }
      
  }
}
 
  
