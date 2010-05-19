/* $Id: SMSpltSrfMac.I,v 1.1.1.1 2001/01/04 21:07:38 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smspace/vol / SMSpltSrfMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSpltSrfMac.I,v $
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

class implementation SMSpltSrf;

#include "OMmacros.h"
#include "OMindex.h"
#include "AS_status.h"
#include "acdef.h"
#include "asbox.h"
#include "asdef.h"

/* Compartment macro definition:
/*   temp:
/*		- profile
/*		- bounded volume.
/*
/*   Feet:
/*		- volume
/*
/* 
/* */

#define MAX_TEMP	17  /* Mask exp + Offset exp + support + 14 * surf */
#define MAX_FEET	1

SMSpltSrfMacDef()
{
 int	nb_temp, i;
 char	*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR];	
 int	temp_type[MAX_TEMP];	
 int	nb_feet;	
 char	*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];
 struct GRid	 mac_id;
 
 nb_temp = 0;
 /* Template initialization */
 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "ExpMask");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = parameter_generic;

 /* Template initialization */
 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "offset");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = parameter_generic;

 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "support");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = other_generic;

 i       = 1;
 while(nb_temp < MAX_TEMP)
  {
   sprintf(&tmp_temp[nb_temp * macro_MAX_CHAR],"splt_srf%d",i++);
   temp_list[nb_temp] = &tmp_temp[nb_temp * macro_MAX_CHAR];
   temp_type[nb_temp++] = other_generic;
  }


 /* Feet initialization */
 strcpy(&tmp_feet[0 * macro_MAX_CHAR],"surf");
 feet_list[0] = &tmp_feet[0 * macro_MAX_CHAR];

 nb_feet = 1;

 return(SMCrtMacDef("SMSpltSrf", "SMPrivMac", nb_temp, temp_list, temp_type, 
	   nb_feet, feet_list, 0, NULL, NULL, &mac_id));
}

end implementation SMSpltSrf;

