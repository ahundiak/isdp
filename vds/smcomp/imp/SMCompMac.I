/* $Id: SMCompMac.I,v 1.1.1.1 2001/01/04 21:07:33 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        SMcomp/SMCompMac.I
 *
 * Description:
 *
 *      This file implements the function SMCompMacDef that defines the macro
 *	definition of the compartment.
 *
 * Dependencies:
 *
 *      SMcomp
 *
 * Revision History:
 *	$Log: SMCompMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:33  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.2  1998/04/24  17:05:12  pinnacle
# TR179801040
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
 * 04/24/92  Ch. Heraud  Creation date.
 * 04/24/98  ah          Raise number of vilumes from 10 to 30
 * -------------------------------------------------------------------------
 */
class implementation SMcomp;

#include "OMmacros.h"
#include "OMindex.h"
#include "AS_status.h"
#include "acdef.h"
#include "asbox.h"
#include "asdef.h"

#include "SMcomp_def.h"

#if 0
#define MAX_TEMP	21 	 /* 1 + 2 * 10 	*/
#define MAX_FEET	15	 /* 5 + 1 * 10 	*/
#endif

#define MAX_TEMP (1 + (2 * SM_MAX_ALLOW_VOL))
#define MAX_FEET (5 + (1 * SM_MAX_ALLOW_VOL))

#define MAX_TEMP_FEET	 1	 

/*+fi
 -------------------------------------------------------------------------
  Internal Function  SMCompMacDef

  Abstract

	This function creates the  Compartment macro definition:
   temp:
		- Compart dynamic collection.
              	- 2 * N * ((Root volume or compart dynamic collection) + 
		           (Root volume or compart graphic object)

   Feet:
		- Computed solid (graphic)
		- Compart cog (graphic)
		- Compart volume (double)
		- Compart area (double)
		- Compart floor area (double)
		- N *
			- cog	 (graphic)
					
 
  Returns
         
         SMCrtMacDef return code

 -------------------------------------------------------------------------
*/

SMCompMacDef()
/*
-fi */
{
 int	nb_temp;	
 char	*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR];	
 int	temp_type[MAX_TEMP];
 int	nb_feet, nb_temp_feet, temp_feet_ind[MAX_TEMP_FEET];
 char	*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];
 char   *temp_feet_list[MAX_TEMP_FEET], tmp_temp_feet[MAX_TEMP_FEET * macro_MAX_CHAR];
 struct GRid	 mac_id;
 
 int i;

 /* Template initialization */
 nb_temp = 0;

 strcpy(&tmp_temp[nb_temp], "user_dyn");
 temp_list[0] = &tmp_temp[nb_temp];
 nb_temp++;

 i = 1;
 while(nb_temp < MAX_TEMP)
  {
   sprintf(&tmp_temp[nb_temp * macro_MAX_CHAR],"attr%d",i);
   temp_list[nb_temp] = &tmp_temp[nb_temp * macro_MAX_CHAR];
   nb_temp++;

   sprintf(&tmp_temp[nb_temp * macro_MAX_CHAR],"root%d",i++);
   temp_list[nb_temp] = &tmp_temp[nb_temp * macro_MAX_CHAR];
   nb_temp++;
  }

 /* Feet initialization */
 strcpy(&tmp_feet[0*macro_MAX_CHAR],"sol");

 strcpy(&tmp_feet[1*macro_MAX_CHAR],"cog");
 strcpy(&tmp_feet[2*macro_MAX_CHAR],"volume");
 strcpy(&tmp_feet[3*macro_MAX_CHAR],"area");
 strcpy(&tmp_feet[4*macro_MAX_CHAR],"floor_area");

 feet_list[0] = &tmp_feet[0*macro_MAX_CHAR];
 feet_list[1] = &tmp_feet[1*macro_MAX_CHAR];
 feet_list[2] = &tmp_feet[2*macro_MAX_CHAR];
 feet_list[3] = &tmp_feet[3*macro_MAX_CHAR];
 feet_list[4] = &tmp_feet[4*macro_MAX_CHAR];

 nb_feet = 5;
 i       = 1;
 while(nb_feet < MAX_FEET)
 {
   sprintf(&tmp_feet[nb_feet * macro_MAX_CHAR],"cog%d",i);
   feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
   nb_feet++;

/*
 * sprintf(&tmp_feet[nb_feet * macro_MAX_CHAR],"volume%d",i);
 *  feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
 * nb_feet++;

 * sprintf(&tmp_feet[nb_feet * macro_MAX_CHAR],"area%d",i);
 * feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
 * nb_feet++;
 */
  i++;
 }

 /* Set the collection as template feet */
 nb_temp_feet = 1;
 strcpy(&tmp_temp_feet[0], "attr");
 temp_feet_list[0] = &tmp_temp_feet[0];
 temp_feet_ind[0]  = 0;

 for(i=0;i<MAX_TEMP;i++) temp_type[i] = 0;

 return(SMCrtMacDef("SMcomp", "SMPrivMac", nb_temp, temp_list, temp_type, 
	            nb_feet, feet_list, nb_temp_feet, temp_feet_ind, temp_feet_list, 
		    &mac_id));
}

end implementation SMcomp;

