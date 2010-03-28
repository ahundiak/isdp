/* These routines allow the support of user-specified EMS layer to IGDS level 
   mapping.  

   GUinit_map(msg, map_filename) : initializes the layer-to-level map to either
                                   the default or a map defined by a 
				   user-specified file.

   GUigemapigds(msg, symbology)  : maps the EMS layer described within the 
				   symbology structure to the corresponding
				   IGDS level.


   

   CHANGE HISTORY:

     MEF	10/24/89 : Creation date.
     mrm        07/23/91   Correct the initialization of the map
                04/03/92   Fix boneheaded read of map file
*/
   

#include <grimport.h>
#include <OMminimum.h>
#include <igrtypedef.h>
#include <igetypedef.h>
#include <igr.h>
#include <igrdp.h>
#include <godef.h>
#include <gr.h>
#include <transdef.h>
#include <transerr.h>
#include <translate.h>
#include <stdio.h>
#include <ctype.h>
#include <go.h>

static IGRint lvl_map[1024];

void GUinit_map(msg, map_filename)
IGRlong         *msg;
IGRchar   	 map_filename[];
{
    FILE        *mapfile;
    IGRchar 	line[81];
    IGRchar 	layer_str[10];
    IGRchar   	level_str[10];
    IGRshort  	layer_num;
    IGRshort   	level_num;
    IGRint 	i, j;

    *msg = GUsuccess;

    /* set up the default layer mapping table */

    lvl_map[0] = 1;
    for (i = 1; i < 1024; i++)
    {
        lvl_map[i] = (j = i % 63) ? j : 63;
    }

    /* See if there is a user-defined symbology mapping file */

    if (map_filename)
    {
        if (mapfile = fopen(map_filename,"r"))
        {
            while ((fgets(line, 80, mapfile)) != 0)
            {
                layer_str[0] = NULL;
                level_str[0] = NULL;

                sscanf(line, "%s %s", layer_str, level_str);

                if (isalnum(layer_str[0]))
                    layer_num = atoi(layer_str);
                else
                    layer_num = -999 ;

                if (isalnum(level_str[0]))
                    level_num = atoi(level_str);
                else
                    level_num = -999 ;

                /* Update the mapping table with the
                   user-defined symbology mapping */
                if (((layer_num >= 0) && (layer_num <= 1023)) &&
                    ((level_num > 0) && (level_num <= 63)))
                    lvl_map [layer_num] = level_num;
            }
            fclose(mapfile);
        }
        else
        {
            *msg = GUMAPNOTFOUND;
        }
    }
}



void GUigemapigds(msg ,symbology)

IGRlong      		*msg;
struct 	GRsymbology  	*symbology;

{
 symbology->level = lvl_map[symbology->level];
 *msg = GUsuccess;
}
