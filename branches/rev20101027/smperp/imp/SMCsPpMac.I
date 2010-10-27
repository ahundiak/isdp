/* $Id: SMCsPpMac.I,v 1.1.1.1 2001/01/04 21:07:35 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smperp/imp / SMCsPpMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCsPpMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:35  cvs
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

class implementation SMCsPp;

#include "OMmacros.h"
#include "OMindex.h"
#include "AS_status.h"
#include "acdef.h"
#include "asbox.h"
#include "asdef.h"

/* Perpendicular macro definition:
/*   temp:
/*		- an ACrg_collection that contains:
/*
/*		. is_analysis (if it is the perp for the analysis)
/*		. is_middle ( if the middle perp is needed)
/*		. is_drawing ( if used for the drawing)
/*		. AftName (name of the Aft Perp if need to be displayed)
/*		. MidName (name of the middle Perp if need to be displayed)
/*		. ForName (name of the Fore Perp if need to be displayed)
/*		. DrwName = name for the drawing macro 
/*					(default = SMDrwPrp)
/*		. axis = coord. axis on which are the perp (default x)	
/*
/*		- Coordinate system (act ship cs or act EMS cs)
/*		- AftDist = Expression distance from cs to the 
/*			aft perp (default 0)
/*		- ForeDist = Expression distance from to the aft 
/*			perp to the fore perp (LPP)
/*		
/*
/*
/*   Feet (2 or 3 infinite planes ):
/*
/*		- the Aft Perp
/*		- the Middle Perp (if needed otherwise NULL_OBJID)
/*		- the Fore Perp
/*
/* 
/* */

#define MAX_TEMP	4
#define MAX_FEET	3

SMCsPpMacDef()
{
 int	nb_temp;	
 char	*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR];	
 int	temp_type[MAX_TEMP];	
 int	nb_feet;	
 char	*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];
 struct GRid	 mac_id;
 
 /* Templates initialization */

 nb_temp = 0;
 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "attributes");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = ~0;

 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "coord");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = ref_generic;

 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "AftDist");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = parameter_generic | double_type | ~0;

 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "ForeDist");
 temp_list[nb_temp]   = &tmp_temp[nb_temp * macro_MAX_CHAR];
 temp_type[nb_temp++] = parameter_generic | double_type | ~0;



 /* Feet initialization */
 
 nb_feet = 0;
 strcpy(&tmp_feet[nb_feet * macro_MAX_CHAR],"AftPerp");
 feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
 nb_feet++;

 strcpy(&tmp_feet[nb_feet * macro_MAX_CHAR],"MidPerp");
 feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
 nb_feet++;

 strcpy(&tmp_feet[nb_feet * macro_MAX_CHAR],"ForePerp");
 feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
 nb_feet++;


 return(SMCrtMacDef("SMCsPp", "SMPrivMac", nb_temp, temp_list, temp_type, 
	   nb_feet, feet_list, 0, NULL, NULL, &mac_id));
}

end implementation SMCsPp;

