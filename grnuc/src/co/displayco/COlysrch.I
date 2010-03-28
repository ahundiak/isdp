/* #######################    APOGEE COMPILED   ######################## */

class implementation COlayer;

#include 	<string.h>
#include	<ctype.h>
#include 	"exdef.h"
#include	"exmacros.h"
#include	"dpdef.h"
#include 	"dp.h"
#include	"dpmacros.h"
#include	"lydef.h"
#include 	"OMindex.h"
#include 	"OMerrordef.h"
#include	"grmessage.h"


/*
 *  layers	I	This is the layers array.
 *
 *  number	I	This is a character index into the layers array.
 *
 *  name	I	This is a name index into the layers array.
 *
 *  elig	I	This is an elig index into the layers array.
 *
 *  occupied	I	This is an occupied index into the layer array.
 *
 *  num_layer	I/O	This inputs the number of elements in the layers
 *			 array.
 *			 
 *			The output is the number of elements that were
 *			found to match the input.
 *
 *  found	O	An array of indexes that matched the input.  The
 *			memory is malloced inside the function.
 *			 
 */
 
method search (struct GRlayer *group; struct GRindlayer *ind_ly; IGRchar *number; IGRchar *name;
	       IGRchar *elig;  IGRchar *occupied; IGRint *num_layer;
	       IGRshort  *found; IGRshort group_flag)

{
    IGRint  t_number, ii, good_index, found_layers = 0, name_found;
    IGRchar *temp, s_name[256];
    IGRint  group_search;
    IGRint  layer_no;

	if (*num_layer) 
	{
	   t_number = *num_layer;
	}
	else 
	{
	   t_number = MAX_LVLDEF;
	}

	if (group_flag == L_On_Flag)
	{
	   group_search = 1;
	}
	else 
	{
	   group_search = 0;
	}

    *num_layer = 0;  /* no layers found yet */
    

	for (ii = 0; ii < t_number; ii++)
	{
       if ( (group_search) && (group[ii].delete) )  /* should search? */
         good_index = 0;
       else
  	     good_index = 1;

       if (good_index)
       {
	     name_found = 0;

	     if (strlen (name)) 
	     {
	        if (group_search)
	        {
	           strcpy (s_name, group[ii].name);
	        }
	        else
	        {
/*	           strcpy (s_name, ind_ly[ii].name);*/
	        }

	        while (temp = strchr (s_name, ',')) 
	        {
		      *temp = '\0';
/*
 *  Skip null character.
 */
 
		      temp++;
		      if (strcmp (s_name, name) == 0) 
		      {
		        name_found = 1;
		        break;
		      }
/*
 *  Skip whitespace.
 */
 
		      temp++;
		      strcpy (s_name, temp);

	        }  /* end while loop */

	        if (!name_found)
	        {
	  	      if (strcmp (s_name, name) != 0) 
		      { 
		        good_index = 0;
		      }
	        }
	     }

	     if (strlen (number)) 
	     {
	        if (group_search) 
	        {
		      layer_no = atoi (number);
		      if (!DPlevel_check (layer_no, group[ii].ly_num_mask)) 
		      {
		        good_index = 0;
		      }
	        }
	        else 
	        {
		      if (strcmp (ind_ly[ii].number, number) != 0) 
		      {
		        good_index = 0;
	          }
	        }
	     }

	     if (strlen (occupied)) 
	     {
            if (group_search)
            {
               if (strcmp (group[ii].occupied, occupied) != 0)
               {
                 good_index = 0;
               }
            }
            else
            {
               if (strcmp (ind_ly[ii].occupied, occupied) != 0)
               {
                 good_index = 0;
               }
            }
	     }

	     if (strlen (elig)) 
	     {
	        if (group_search)
	        { 
	           if (strcmp (group[ii].elig, elig) != 0) 
	           {
		         good_index = 0;
	           }
	        }
	        else
	        {
	           if (strcmp (ind_ly[ii].elig, elig) != 0) 
	           {
		         good_index = 0;
	           }
	        }
	     }

       }  /* end if should search */

	   if (good_index) 
	   {
         found[found_layers] = ii;
	     found_layers++;	       
       }

	}  /* end for loop */


	*num_layer = found_layers;

	return(1);
}

end implementation COlayer;
