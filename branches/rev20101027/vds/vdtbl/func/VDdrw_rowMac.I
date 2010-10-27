/* $Id: VDdrw_rowMac.I,v 1.1.1.1 2001/01/04 21:09:27 cvs Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vdtbl/func/VDdrw_rowMac.I
 *
 * Description:
 *
 *      This file implements the function VD_drwtb_rowMacDef that defines the
 *	macro definition for the Table Row Object.  
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem	Creation date.
 *	07/07/95	adz		change to VDSdrw lib.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblRow;

#include "AS_status.h"

#define VD_DRW_MACRO_LIB        "VDSdrw"

/*+fi
 -------------------------------------------------------------------------
  Internal Function  VD_drwtb_rowMacDef

  Abstract

        This function creates the VDdrwTblRow macro definition:

  The TEMPLATES:
 
 	- coll		: collector for overridden information.
 	- objs		: set of model objects

  The FEETS:
 
 	- geom		:	geometry of row - lines and texts
	- misc		: 	miscellaneous components (line-out etc)

  Returns

         SMCreMacDef return code

 -------------------------------------------------------------------------
-fi*/

#define MAX_TEMP	2 	 
#define MAX_FEET	2
#define MAX_TEMP_FEET	1	 


VD_drwtb_rowMacDef()
{
int		nb_temp,
		temp_type[MAX_TEMP],
		nb_feet,
		nb_temp_feet, 
		temp_feet_ind[MAX_TEMP_FEET];

char		*temp_list[MAX_TEMP],
		tmp_temp[MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[MAX_FEET],
		tmp_feet[MAX_FEET * macro_MAX_CHAR],
 		*temp_feet_list[MAX_TEMP_FEET], 
		tmp_temp_feet[MAX_TEMP_FEET * macro_MAX_CHAR];

struct GRid	mac_id;
 

	/*
	 * Template initialization
	 */
	nb_temp = 0;

	strcpy( &tmp_temp[nb_temp*macro_MAX_CHAR],	"coll" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = ~0;
	nb_temp++;

	strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR],	"objs" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = other_generic;
	nb_temp++;

	/*
	 * Feet initialization
	 *
 	 * - geom    	: line and text components
 	 * - misc     	: miscellaneous components 
	 */

	nb_feet = 0;
 
	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],	"geom" );
	feet_list[nb_feet] = &tmp_feet[nb_feet*macro_MAX_CHAR];
	nb_feet ++;

	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],	"misc" );
	feet_list[nb_feet] = &tmp_feet[nb_feet*macro_MAX_CHAR];
	nb_feet ++;

	/*
	 * Set the collection as template feet
	 */

	nb_temp_feet = 0;
	strcpy(&tmp_temp_feet[nb_temp_feet*macro_MAX_CHAR], "attr");
	temp_feet_list[nb_temp_feet] =
			&tmp_temp_feet[nb_temp_feet*macro_MAX_CHAR];
	temp_feet_ind[nb_temp_feet]  = 0;
	nb_temp_feet ++;


	return(	SMCrtMacDef(	"VDdrwTblRow",
				VD_DRW_MACRO_LIB,
				nb_temp,
				temp_list,
				temp_type, 
				nb_feet,
				feet_list,
				nb_temp_feet,
				temp_feet_ind, 
				temp_feet_list,
				&mac_id ));
}

end implementation VDdrwTblRow;

