/* $Id: SMWindMac.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smwind/imp / SMWindMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMWindMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
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
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation SMwind;

#include "OMmacros.h"
#include "OMindex.h"
#include "AS_status.h"
#include "acdef.h"
#include "asbox.h"
#include "asdef.h"

/* Wind area polygon macro definition:
/*   temp:
/*		- Wind area polygon dynamic collection.
/*		- N * polygons.
/*
/*   Feet:
/*		- N * polygons (projected on the corresponding plane.
/* 
/* */

#define MAX_TEMP	11 	 /* 2 + 9 */
#define MAX_FEET	 9	 /* 9     */

SMWindMacDef()
{
 int	nb_temp;	
 char	*temp_list[2+SM_MAX_ALLOW_PLG], tmp_temp[(2+SM_MAX_ALLOW_PLG) * macro_MAX_CHAR];
 int	temp_type[2+SM_MAX_ALLOW_PLG];	
 int	nb_feet;	
 char	*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];
 struct GRid	 mac_id;
 
 int i;

 /* Template initialization */
 strcpy(&tmp_temp[0], "user_dyn");
 temp_list[0] = &tmp_temp[0];

 strcpy(&tmp_temp[1 * macro_MAX_CHAR], "cs");
 temp_list[1] = &tmp_temp[1 * macro_MAX_CHAR];

 nb_temp = 2;
 i       = 1;
 while(nb_temp < 2+SM_MAX_ALLOW_PLG)
  {
   sprintf(&tmp_temp[nb_temp * macro_MAX_CHAR],"plg%d",i);
   temp_list[nb_temp] = &tmp_temp[nb_temp * macro_MAX_CHAR];
   nb_temp++;
   i++;
  }

 /* Feet initialization */

 nb_feet = 0;
 i       = 1;
 while(nb_feet < MAX_FEET)
 {
   sprintf(&tmp_feet[nb_feet * macro_MAX_CHAR],"plg%d",i);
   feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
   nb_feet++;
   i++;
 }

 for(i=0;i<2+SM_MAX_ALLOW_PLG;i++) temp_type[i] = 0;

 return(SMCrtMacDef("SMwind", "SMPrivMac", nb_temp, temp_list, temp_type, 
	   nb_feet, feet_list, 0, NULL, NULL, &mac_id));
}

end implementation SMwind;

