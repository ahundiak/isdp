/* $Id: SMSlCambMac.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/imp / SMSlCambMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSlCambMac.I,v $
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
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation SMSlCamber;

#include "OMmacros.h"
#include "OMindex.h"
#include "AS_status.h"
#include "acdef.h"
#include "asbox.h"
#include "asdef.h"

/* Circular Camber macro definition:
/*   temp:
/*		- Coord syst
/*		- ACrg_collect
/*			- z_pos
/*			- symetry
/*			- extension (0=hull range + 50%, 1 =bounded by hull, 
/*				2=user defined)
/*			- reverse
/*			- ext_x1
/*			- ext_x2	user defined extension
/*			- ext_y1
/*			- ext_y2	
/*			- nb_sl
/*				- slope		nb_sl times
/*				- y_dist
/*   Feet:
/*		- surface
/*
/* 
/* */

#define MAX_TEMP	2
#define MAX_PT		50

#define MAX_FEET	1

SMSlCamberMacDef()
{
 int	nb_temp;
 char	*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR];	
 int	temp_type[MAX_TEMP];	
 int	nb_feet;	
 char	*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];
 struct GRid	 mac_id;
 

 nb_temp = 0;
 

 /* Template initialization */
 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "coord");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = ref_generic;

 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "attributes");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = ~0;

 /* Feet initialization */
 nb_feet = 0;
 strcpy(&tmp_feet[nb_feet * macro_MAX_CHAR],"surf");
 feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
 nb_feet++;

 return(SMCrtMacDef("SMSlCamber", "SMPrivMac", nb_temp, temp_list, temp_type, 
	   nb_feet, feet_list, 0, NULL, NULL, &mac_id));
}

end implementation SMSlCamber;

