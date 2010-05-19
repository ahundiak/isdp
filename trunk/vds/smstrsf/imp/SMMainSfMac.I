/* $Id: SMMainSfMac.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        smstrsf/SMMainSfMac.I
 *
 * Description:
 *
 *      This file implements the function SMMainSfMacDef that defines the macro
 *      definition of the main surface.
 *
 * Dependencies:
 *
 *      SMMainSf
 *
 * Revision History:
 *	$Log: SMMainSfMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *
 *      02/01/93        P. Lacroix      Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation SMMainSf;

#include "AS_status.h"

#include "SMStructSf.h"



#define MAX_TEMP	2 	 
#define MAX_FEET	2
#define MAX_TEMP_FEET	1	 

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMCompMacDef

  Abstract

        This function creates the  Compartment macro definition:

   temp:
		- Rg_collection = Main Surface parameters (template/foot)
              - The surface 

   Feet:
		- Rg_collection
		- Main Surface (copy of template)
		- Main Surface cog (graphic)
			

  Returns

         SMCrtMacDef return code

 -------------------------------------------------------------------------
*/

SMMainSfMacDef()
/*
-fi*/
{
 int		nb_temp, temp_type[MAX_TEMP],nb_feet, nb_temp_feet, 
		temp_feet_ind[MAX_TEMP_FEET];

 char		*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR],
 		*temp_feet_list[MAX_TEMP_FEET], 
		tmp_temp_feet[MAX_TEMP_FEET * macro_MAX_CHAR];

 struct GRid	mac_id;
 

 /* Template initialization */
 nb_temp = 0;

 strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR], "att");
 temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
 temp_type[nb_temp] = ~0;
 nb_temp++;

 strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR], "surface");
 temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
 temp_type[nb_temp] = other_generic;
 nb_temp++;


 /* Feet initialization */

 nb_feet = 0;
 
 strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],"mainsf");
 feet_list[nb_feet] = &tmp_feet[nb_feet*macro_MAX_CHAR];
 nb_feet ++;

 strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],"cog");
 feet_list[nb_feet] = &tmp_feet[nb_feet*macro_MAX_CHAR];
 nb_feet ++;


 /* Set the collection and surface as template feet */

 nb_temp_feet = 0;
 strcpy(&tmp_temp_feet[nb_temp_feet*macro_MAX_CHAR], "attr");
 temp_feet_list[nb_temp_feet] = &tmp_temp_feet[nb_temp_feet*macro_MAX_CHAR];
 temp_feet_ind[nb_temp_feet]  = 0;
 nb_temp_feet ++;




 return(SMCrtMacDef("SMMainSf", "SMPrivMac", nb_temp, temp_list, temp_type, 
	            nb_feet, feet_list, nb_temp_feet, temp_feet_ind, 
		    temp_feet_list, &mac_id));
}

end implementation SMMainSf;

