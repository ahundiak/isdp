/* $Id: VLunwmacrodf.I,v 1.1.1.1 2001/01/04 21:11:56 cvs Exp $  */

/*************************************************************************
 * I/LOFT
 *
 * File:        src/unwext/VLunwmacrodf.I
 *
 * Description: Macro definitions for Unwrap and Feature Objects.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VLunwmacrodf.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:11:56  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:32:50  pinnacle
# LOFT 2.5.1
#
# Revision 1.1  1997/10/28  15:30:48  pinnacle
# Created: src/unwext/VLunwmacrodf.I by rchennup for loft
#
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *      10/28/97   Rama Rao     File Creation
 *************************************************************************/

class implementation VDSroot;

#include <stdio.h>
#include <string.h>
#include "acdef.h"
#include "acmacros.h"
#include "AS_status.h"
#include "vlunfold.h"

#define	VD_DRW_MACRO_LIB	"VDSdrw"

#define VLunwFeat_MAX_TEMP	2
#define VLunwFeat_MAX_FEET	1
#define VLunwFeat_MAX_TEMP_FEET	1	 

VLunwFt_MacDef()
{
int		nb_temp,
		temp_type[VLunwFeat_MAX_TEMP],
		nb_feet,
		nb_temp_feet, 
		temp_feet_ind[VLunwFeat_MAX_TEMP_FEET];

char		*temp_list[VLunwFeat_MAX_TEMP],
		tmp_temp[VLunwFeat_MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[VLunwFeat_MAX_FEET],
		tmp_feet[VLunwFeat_MAX_FEET * macro_MAX_CHAR],
 		*temp_feet_list[VLunwFeat_MAX_TEMP_FEET], 
		tmp_temp_feet[VLunwFeat_MAX_TEMP_FEET * macro_MAX_CHAR];

struct GRid	mac_id;
 
	/*
	 * Template initialization
	 */
	nb_temp = 0;

	strcpy( &tmp_temp[nb_temp*macro_MAX_CHAR],	"coll" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = ~0;
	nb_temp++;

	strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR],	"feat" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = other_generic;
	nb_temp++;

	/*
	 * Feet initialization
	 *
 	 * - geom      : The extracted geometry.
	 */

	nb_feet = 0;
 
	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],	"geom" );
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

	return(	SMCrtMacDef(	"VLunwFeat",
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

#define VLunwObj_MAX_TEMP	20
#define VLunwObj_MAX_FEET	3
#define VLunwObj_MAX_TEMP_FEET	1	 


long VLunwObj_MacDef()
{
int		nb_temp, temp_type[VLunwObj_MAX_TEMP],
		nb_feet, nb_temp_feet, j, k, 
		temp_feet_ind[VLunwObj_MAX_TEMP_FEET];

char		*temp_list[VLunwObj_MAX_TEMP],
		tmp_temp[VLunwObj_MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[VLunwObj_MAX_FEET],
		tmp_feet[VLunwObj_MAX_FEET * macro_MAX_CHAR],
 		*temp_feet_list[VLunwObj_MAX_TEMP_FEET], 
		tmp_temp_feet[VLunwObj_MAX_TEMP_FEET * macro_MAX_CHAR];

struct GRid	mac_id;
 
	/*
	 * Template initialization
	 */
	nb_temp = 0;

	strcpy( &tmp_temp[nb_temp*macro_MAX_CHAR],	"coll" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = ~0;
	nb_temp++;

	strcpy( &tmp_temp[nb_temp*macro_MAX_CHAR],	"obj" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = ~0;
	nb_temp++;

  	for (k=2; k<VLunwObj_MAX_TEMP; k=k+1){
       	   j = k * macro_MAX_CHAR;
           sprintf(&tmp_temp[j],"Edge%d",(k-2) );
	   temp_list[k] = &tmp_temp[j] ;
	   temp_type[k] = ~0;
   	}

	nb_feet = 0;

	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],	"geom" );
	feet_list[nb_feet] = &tmp_feet[nb_feet*macro_MAX_CHAR];
	nb_feet ++;

	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR], UNFOLD_NAM_UNWSRF );
	feet_list[nb_feet] = &tmp_feet[nb_feet*macro_MAX_CHAR];
	nb_feet ++;

	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR], UNFOLD_NAM_UVSRF );
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

	return(	SMCrtMacDef(	"VLunwObj",
				VD_DRW_MACRO_LIB,
				VLunwObj_MAX_TEMP,
				temp_list,
				temp_type, 
				nb_feet,
				feet_list,
				nb_temp_feet,
				temp_feet_ind, 
				temp_feet_list,
				&mac_id ));
}

end implementation VDSroot;

