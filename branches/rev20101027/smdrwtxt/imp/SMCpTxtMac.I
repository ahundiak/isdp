/* $Id: SMCpTxtMac.I,v 1.1.1.1 2001/01/04 21:07:34 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smdrwtxt/imp / SMCpTxtMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMCpTxtMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:34  cvs
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

class implementation SMCpTxt;

#include "OMmacros.h"
#include "OMindex.h"
#include "AS_status.h"
#include "acdef.h"
#include "asbox.h"
#include "asdef.h"

/* Section macro definition:
/*   temp:
/*		- Rg_collection = new position of text
/*		- The text to copy and consume
/*
/*   Feet:
/*		- The copied text (new position)
/*
/* 
/* */

#define MAX_TEMP	  2
#define MAX_FEET	  1

SMCpTxtMacDef()
{


 int		nb_temp, temp_type[MAX_TEMP],nb_feet;

 char		*temp_list[MAX_TEMP], tmp_temp[MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];

 struct GRid	mac_id;
 

 /* Template initialization */
 nb_temp = 0;

 strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR], "att");
 temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
 temp_type[nb_temp] = ~0;
 nb_temp++;

 strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR], "text");
 temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
 temp_type[nb_temp] = other_generic;
 nb_temp++;


 /* Feet initialization */

 nb_feet = 0;
 

 strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],"cptxt");
 feet_list[nb_feet] = &tmp_feet[nb_feet*macro_MAX_CHAR];
 nb_feet ++;



 return(SMCrtMacDef("SMCpTxt", "SMPrivMac", nb_temp, temp_list, temp_type, 
	            nb_feet, feet_list, 0, NULL, NULL, &mac_id));
}

end implementation SMCpTxt;

