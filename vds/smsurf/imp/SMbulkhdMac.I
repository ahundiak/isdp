/* $Id: SMbulkhdMac.I,v 1.1.1.1 2001/01/04 21:07:39 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsurf/imp / SMbulkhdMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMbulkhdMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:39  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1997/02/06  21:04:40  pinnacle
# Created: smsurf/imp/SMbulkhdMac.I by jwfrosch for vds.241
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation SMbulkhead;

#include "OMmacros.h"
#include "OMindex.h"
#include "AS_status.h"
#include "acdef.h"
#include "asbox.h"
#include "asdef.h"

/* Bulkhead macro definition:
/*   temp:
/*		- Coord syst
/*		- ACrg_collect
/*			- dir_axis
/*			- x_axis
/*			- hight
/*			- period
/*			- len1
/*			- len2
/*			- extension (0=hull range + 50%, 1=bounded by hull, 2=user defined)
/*			- reverse
/*			- ext_x1
/*			- ext_x2	user defined extension
/*			- ext_z1
/*			- ext_z2
/*			- rad1
/*			- rad2
/*
/*		- A point
/*   Feet:
/*		- surface
/*
/*
/* */

#define MAX_TEMP	3
#define MAX_FEET	1

SMbulkheadMacDef()
{
  char		*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR];
  char		*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];

  int		temp_type[MAX_TEMP];
  int		nb_feet = 0, nb_temp = 0;
  struct GRid	mac_id;

  /*
   * Template initialization
   */
  strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "coord");
  temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
  temp_type[nb_temp++] = ref_generic;

  strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "attributes");
  temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
  temp_type[nb_temp++] = ~0;

  strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "point");
  temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
  temp_type[nb_temp++] = point_generic;

  /*
   * Feet initialization
   */
  strcpy(&tmp_feet[nb_feet * macro_MAX_CHAR],"surf");
  feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
  nb_feet++;

  return ( SMCrtMacDef ( "SMbulkhead", "SMPrivMac", nb_temp, temp_list, temp_type,
			nb_feet, feet_list, 0, NULL, NULL, &mac_id) );
}

end implementation SMbulkhead;
