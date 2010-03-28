/* #######################    APOGEE COMPILED   ######################## */
class implementation GRunit;

#include "grimport.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "DIglob.h"

method GRis_unit_scalable(IGRlong     *msg;
                          IGRboolean  *scale_flag)
{
  IGRboolean           string_found = FALSE;
  DIchar               name[DI_PATH_MAX];  
  DIchar               scalable_dir[DI_PATH_MAX];  
  DIint                num_syn;
  IGRint               i = 0;
  IGRint               j,pos =0;
  IGRint               len;
  struct GRid          dir;
  IGRint               status;
  
  di$untranslate(objname = name,
  	         ptr = &num_syn,
                 objid = my_id);
  
  /*-- Build directory path :filename:scalable: --*/
  i=1; /* skip first : */
  scalable_dir[0] = ':';
  while(name[i] != ':')
    {
      scalable_dir[i] = name[i];
      i++;
    }
  scalable_dir[i] = 0;
  strcat(scalable_dir,":scalable:");

  /*-- Find occurance of UOM_ --*/
  i=0;
  len = strlen(name);
  while((!string_found) && i<len)
    {
      if(name[i] == 'U')
	{
	 if(name[i+1] == 'O')
	   {
	     if(name[i+2] == 'M')
	       {
		 if(name[i+3] == '_')
		   {
		     pos = i;
		     string_found = TRUE;
		   }
	       }
	   }
       }
      i++;
    }

  /*-- add unit type to directory path --*/
  j = strlen(scalable_dir);
  i = pos;
  while(name[i] != 0)
    {
      scalable_dir[j] = name[i];
      i++;
      j++;
    }
  scalable_dir[j] = 0;

  /*-- check to see if entry exist --*/
  status = di$translate(objname = scalable_dir,
	       p_objid = &dir.objid,
	       p_osnum = &dir.osnum);

  /*-- set scale flag and exit --*/
  if(status == DIR_S_SUCCESS)  
    {
      *scale_flag = TRUE;
      *msg = MSSUCC;
    }
  else
    {
      *scale_flag = FALSE;
      *msg = MSSUCC;
    }

  return(OM_S_SUCCESS);
}

end implementation GRunit;






