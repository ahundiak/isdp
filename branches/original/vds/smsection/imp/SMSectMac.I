/* $Id: SMSectMac.I,v 1.1.1.1 2001/01/04 21:07:37 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/smsection/imp / SMSectMac.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: SMSectMac.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:37  cvs
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

class implementation SMsection;

#include "OMmacros.h"
#include "OMindex.h"
#include "AS_status.h"
#include "acdef.h"
#include "asbox.h"
#include "asdef.h"

/* Section macro definition:
/*   temp:
/*		- Attribute collection.
/*		- Coordinate system (active).
/*              - Compartment object.
/*   SM_MAX_PARTS:
/*		- From Frame.
/*		- To Frame.
/*
/*   Feet:
/*		- N * output closed curves 
/*
/*   N = 100
/* 
/* */

#define MAX_BAS_TEMP	  3
#define MAX_FEET	100

SMSectMacDef()
{
 int	nb_temp;	
 char	*temp_list[MAX_BAS_TEMP + 2 * SM_MAX_PARTS];
 char   tmp_temp[MAX_BAS_TEMP * macro_MAX_CHAR];	
 char   tmp_ff[SM_MAX_PARTS * macro_MAX_CHAR], tmp_tf[SM_MAX_PARTS * macro_MAX_CHAR];
 int	temp_type[MAX_BAS_TEMP + 2 * SM_MAX_PARTS];	
 int	nb_feet;	
 char	*feet_list[MAX_FEET], tmp_feet[MAX_FEET * macro_MAX_CHAR];
 struct GRid	 mac_id;
 
 int i;

 /* Template initialization */
 nb_temp = 0;
 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "attr");
 temp_list[nb_temp] = &tmp_temp[nb_temp * macro_MAX_CHAR];
 nb_temp++;

 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "cs");
 temp_list[nb_temp] = &tmp_temp[nb_temp * macro_MAX_CHAR];
 nb_temp++;


 strcpy(&tmp_temp[nb_temp * macro_MAX_CHAR], "compart");
 temp_list[nb_temp] = &tmp_temp[nb_temp * macro_MAX_CHAR];
 nb_temp++;

 for(i=0;i<SM_MAX_PARTS;i++)
  {
   sprintf(&tmp_ff[i *macro_MAX_CHAR],"ff%d",i);
   temp_list[nb_temp] = &tmp_ff[i * macro_MAX_CHAR];
   nb_temp++;

   sprintf(&tmp_tf[i *macro_MAX_CHAR],"tf%d",i);
   temp_list[nb_temp] = &tmp_tf[i * macro_MAX_CHAR];
   nb_temp++;
  }


 /* Feet initialization */
 nb_feet = 0;
 i       = 0;
 while(nb_feet < MAX_FEET)
 {
   sprintf(&tmp_feet[nb_feet * macro_MAX_CHAR],"curve%d",i);
   feet_list[nb_feet] = &tmp_feet[nb_feet * macro_MAX_CHAR];
   nb_feet++;
   i++;
 }

 for(i=0;i<MAX_BAS_TEMP + 2 * SM_MAX_PARTS;i++) temp_type[i] = 0;

 return(SMCrtMacDef("SMsection", "SMPrivMac", nb_temp, temp_list, temp_type, 
	   nb_feet, feet_list, 0, NULL, NULL, &mac_id));
}

end implementation SMsection;

