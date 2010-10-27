/* $Id: VDdrw_hdrMac.I,v 1.2 2001/01/18 21:01:41 paul_noel Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vdtbl/func/VDdrw_hdrMac.I
 *
 * Description:
 *
 *      This file implements the function VD_drwtb_hdrMacDef that defines the
 *	macro definition for the Table Header Object.  
 *
 * Dependencies:
 *
 * History:
 *
 *      04/14/95        R. Manem	Creation date.
 *	07/07/95	adz		Change to VDSdrw lib.
 *	07/10/00	adz		Add new parent (optional)
 *
 * -------------------------------------------------------------------------
 */

class implementation VDdrwTblHdr;

#include "AS_status.h"

#define VD_DRW_MACRO_LIB        "VDSdrw"

/*+fi
 -------------------------------------------------------------------------
  Internal Function  VD_drwtb_hdrMacDef

  Abstract

        This function creates the VDdrwTblHdr macro definition:

  The TEMPLATES:
 
 	- coll		: collector for general information.
 	- cs		: coordinate system
 	- obj		: Table Parent Reference object (Tree Node, set).

  The FEETS:
 
 	- header	:	components of the header 
 	- trailer	:	components of the trailer 
	- misc		: 	miscellaneous components (future expansion)

  Returns

         SMCreMacDef return code

 -------------------------------------------------------------------------
-fi*/

#define MAX_TEMP	3 	 
#define MAX_FEET	3
#define MAX_TEMP_FEET	1	 


VD_drwtb_hdrMacDef()
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

	strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR],	"cs" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = other_generic;
	nb_temp++;

	strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR],	"obj" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = other_generic;
	nb_temp++;

	/*
	 * Feet initialization
	 *
 	 * - header     : header components
 	 * - trailer    : trailer components
 	 * - misc     	: miscellaneous objects (Future expansion)
	 */

	nb_feet = 0;
 
	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],	"header" );
	feet_list[nb_feet] = &tmp_feet[nb_feet*macro_MAX_CHAR];
	nb_feet ++;

	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],	"trailer" );
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


	return(	SMCrtMacDef(	"VDdrwTblHdr",
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

end implementation VDdrwTblHdr;

