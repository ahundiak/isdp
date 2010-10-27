/* $Id: VDdrwmacrodf.I,v 1.2 2001/05/17 17:31:24 ramarao Exp $ */
/*---------------------------------------------------------------------------
/*  I/VDS
 *
 * File:        vddraw/imp/VDdrwMacro.I
 *
 * Description:
 *
 *      This file implements the functions needed to generate the macros for
 *	3d and 2d drawing process. The following functions are defined:
 *
 *	VDdrwGm_MacDef		define the 3d/2d component geom macro.
 *	VDdrw2d_MacDef		define the 2d vizualization macro.
 *	VDdrw3d_MacDef		define the 3d vizualization macro.
 *	VDdrw2dVw_MacDef	define the 2d View Area macro. 
 *	VDdrw3dVw_MacDef	define the 3d View volume macro.
 *
 * Dependencies:
 *
 *	VDSroot
 *
 * Revision History:
 *	$Log: VDdrwmacrodf.I,v $
 *	Revision 1.2  2001/05/17 17:31:24  ramarao
 *	Added VDdrwGm20 and VDdrwGm30 macros.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:08:38  cvs
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
# Revision 1.5  1995/07/06  21:07:40  pinnacle
# Replaced: vddraw/imp/VDdrwmacrodf.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/06/27  21:03:42  pinnacle
# Replaced: vddraw/imp/VDdrwmacrodf.I for:  by azuurhou for vds.240
#
 *
 * History:
 *
 *      06/06/95	adz		Creation date.
 *
 * -------------------------------------------------------------------------
 */

class implementation VDSroot;

#include <stdio.h>
#include <string.h>
#include "acdef.h"
#include "acmacros.h"
#include "AS_status.h"


#define	VD_DRW_MACRO_LIB	"VDSdrw"

/*
 * The 2d/3d visualization macro objects are having a undefined number of
 * output geometry. As result, the macro VDdrwGm, is the componet macro
 * object of the main 2d/3d visualization macro objects.
 * The VDdrwGm macro contains enough entry points to connect graphical
 * objects to the macro occurence. The macro size will be determined by
 * finding out * the needed size from the drawing or section object.
 *
 */

struct	VD_s_gmRefList {

	char	*name ;
	int	size ;
} ;

typedef	struct	VD_s_gmRefList	VD_gmRefList ;

/*
 -------- Static List -------------------------------------------------------
 */
%safe

static	VD_gmRefList	gmList[] = {

/*
 *	Macro Name		Macro Size
 *	----------		----------
 */

	{ "VDdrwGm0"	,	 10	},
	{ "VDdrwGm1"	,	 25	},
	{ "VDdrwGm2"	,	 50	},
	{ "VDdrwGm3"	,	100	},
	{ "VDdrwGm4"	,	150	},
	{ "VDdrwGm5"	,	200	},
	{ "VDdrwGm6"	,	300	},
	{ "VDdrwGm7"	,	400	},
	{ "VDdrwGm8"	,	500	},
	{ "VDdrwGm9"	,	600	},
	{ "VDdrwGm10"	,      1000	},
	{ "VDdrwGm20"   ,      2000     },
	{ "VDdrwGm30"   ,      3000     },
	{ NULL	  	,	  0	}} ;	/* Last line of buffer */

%endsafe

/*----------------------------------------------------------------------------*/

long VD_drwGeomGiveMacroBySize( msg, size, name )

IGRlong			*msg ;
IGRint			size ;
IGRchar			*name ;
{
	IGRint			sts = OM_S_SUCCESS ;
	VD_gmRefList		*gmIndex ;	/* static list index	*/

	/*
	 * Return the best fitting object back depening on the input size.
	 */
	*msg = MSFAIL ;
	name[0] = '\0';

	for( gmIndex = gmList ; gmIndex->name ; gmIndex++ ){

		/*
		 * Test the size.
		 */
		if( size < gmIndex->size ){

			strcpy( name, gmIndex->name );
			*msg = MSSUCC ;
			break;
		}
	}

	if( !((*msg)&1) )
	{
	    printf( "Request Development to increase the feet list size\n" );
	}

	return sts ;
}

/*----------------------------------------------------------------------------*/


/*+fi
 -------------------------------------------------------------------------
  Internal Function  VDdrwGm_MacDef

  Abstract
        This function creates the VDdrwGm macro definition:

  The FEETS:
	The feet are all graphical entries to connect to.
 
  Returns
         SMCreMacDef return code

 -------------------------------------------------------------------------
*/

#define VDdrwGm_MAX_TEMP	1 	 
#define	VDdrwGm_MAX_FEET	3000		/* Maximum option.	*/
#define VDdrwGm_MAX_TEMP_FEET	1	 
long VDdrwGm_MacDef()
/*
-fi*/
{
int		sts = OM_S_SUCCESS ;
int		nb_temp,
		nb_feet,
		nb_temp_feet, 
		temp_type[VDdrwGm_MAX_TEMP],
		temp_feet_ind[VDdrwGm_MAX_TEMP_FEET];

char		*temp_list[VDdrwGm_MAX_TEMP],
 		*feet_list[VDdrwGm_MAX_FEET],
 		*temp_feet_list[VDdrwGm_MAX_TEMP_FEET], 
		*pfeet,
		tmp_temp[VDdrwGm_MAX_TEMP * macro_MAX_CHAR],	
		tmp_feet[VDdrwGm_MAX_FEET * macro_MAX_CHAR];

struct GRid	mac_id;
VD_gmRefList	*gmIndex ;
 

	/*
	 * Template initialization
	 */
	nb_temp = 0;

	strcpy( &tmp_temp[nb_temp*macro_MAX_CHAR],	"model" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = 0;
	nb_temp++;

	/*
	 * Feet initialization
	 */
	nb_feet = 0;
	pfeet   = tmp_feet ;
	for( nb_feet=0 ; nb_feet<VDdrwGm_MAX_FEET; nb_feet++ ){
		sprintf( pfeet, "$%d", nb_feet );
		feet_list[nb_feet] = pfeet ;
		pfeet += macro_MAX_CHAR ;
	}

	/*
	 * Extern Feet.
	 */	
	nb_temp_feet = 0;

	for( gmIndex = gmList ; (sts&1) && gmIndex->name ; gmIndex++ ){

		sts =
		SMCrtMacDef(	gmIndex->name,
				VD_DRW_MACRO_LIB,
				nb_temp,
				temp_list,
				temp_type, 
				gmIndex->size,
				feet_list,
				nb_temp_feet,
				((nb_temp_feet) ? temp_feet_ind : NULL ), 
				((nb_temp_feet) ? temp_feet_list : NULL ),
				&mac_id );
	} /* all types. */

	return sts ;
}


/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

/*+fi
 -------------------------------------------------------------------------
  Internal Function  VDdrw2d_MacDef

  Abstract

        This function creates the VDdrw2d macro definition:

  The TEMPLATES:
 
 	- obj	: 3d model object.
 	- coll	: collector for general information.

  The FEETS:
 
 	- geom      :	The extracted geometry.

 	Static, dynamic and/or user attributes can be copied from the 
 	3d model objects to the 2d VDdrw object. (This permit to do 
 	annotation after the drawing is disconnected from the 3d model design
 	file.

  Returns

         SMCreMacDef return code

 -------------------------------------------------------------------------
*/

#define VDdrw2d_MAX_TEMP	2
#define VDdrw2d_MAX_FEET	1
#define VDdrw2d_MAX_TEMP_FEET	1	 

VDdrw2d_MacDef()
/*
-fi*/
{
int		nb_temp,
		temp_type[VDdrw2d_MAX_TEMP],
		nb_feet,
		nb_temp_feet, 
		temp_feet_ind[VDdrw2d_MAX_TEMP_FEET];

char		*temp_list[VDdrw2d_MAX_TEMP],
		tmp_temp[VDdrw2d_MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[VDdrw2d_MAX_FEET],
		tmp_feet[VDdrw2d_MAX_FEET * macro_MAX_CHAR],
 		*temp_feet_list[VDdrw2d_MAX_TEMP_FEET], 
		tmp_temp_feet[VDdrw2d_MAX_TEMP_FEET * macro_MAX_CHAR];

struct GRid	mac_id;
 
	/*
	 * Template initialization
	 */
	nb_temp = 0;

	strcpy( &tmp_temp[nb_temp*macro_MAX_CHAR],	"coll" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = ~0;
	nb_temp++;

	strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR],	"obj" );
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

	return(	SMCrtMacDef(	"VDdrw2d",
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

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

/*+fi
 -------------------------------------------------------------------------
  Internal Function  VDdrw3d_MacDef

  Abstract

        This function creates the VDdrw3d macro definition:

  The TEMPLATES:
 
 	- coll	: collector for general information.
 	- obj	: 3d model object.

  The FEETS:
 
 	- geom      :	The extracted geometry.

  Returns

         SMCreMacDef return code

 -------------------------------------------------------------------------
*/

#define VDdrw3d_MAX_TEMP	2 	 
#define VDdrw3d_MAX_FEET	1
#define VDdrw3d_MAX_TEMP_FEET	1	 

long VDdrw3d_MacDef()
/*
-fi*/
{
int		nb_temp, temp_type[VDdrw3d_MAX_TEMP],
		nb_feet, nb_temp_feet, 
		temp_feet_ind[VDdrw3d_MAX_TEMP_FEET];

char		*temp_list[VDdrw3d_MAX_TEMP],
		tmp_temp[VDdrw3d_MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[VDdrw3d_MAX_FEET],
		tmp_feet[VDdrw3d_MAX_FEET * macro_MAX_CHAR],
 		*temp_feet_list[VDdrw3d_MAX_TEMP_FEET], 
		tmp_temp_feet[VDdrw3d_MAX_TEMP_FEET * macro_MAX_CHAR];

struct GRid	mac_id;
 
	/*
	 * Template initialization
	 */
	nb_temp = 0;

	strcpy( &tmp_temp[nb_temp*macro_MAX_CHAR],	"coll" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = ~0;
	nb_temp++;

	strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR],	"obj" );
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

	return(	SMCrtMacDef(	"VDdrw3d",
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

/*----------------------------------------------------------------------------*/
/*	VDdrw2dVw							      */
/*----------------------------------------------------------------------------*/

/*+fi
 -------------------------------------------------------------------------
  Internal Function  VDdrw2dVw_MacDef

  Abstract

        This function creates the VDdrw2dVw macro definition:

  The TEMPLATES:
 
 	- coll	: collector for general information.
	- obj   : Reference object (optional).

  The FEETS:
 
 	- note	: Graphics generated to place notes under drawing set.

  Returns

         SMCreMacDef return code

 -------------------------------------------------------------------------
*/

#define VDdrw2dVw_MAX_TEMP	2 	 
#define VDdrw2dVw_MAX_FEET	1
#define VDdrw2dVw_MAX_TEMP_FEET	1	 


long VDdrw2dVw_MacDef()
/*
-fi*/
{
int		nb_temp, temp_type[VDdrw2dVw_MAX_TEMP],
		nb_feet, nb_temp_feet, 
		temp_feet_ind[VDdrw2dVw_MAX_TEMP_FEET];

char		*temp_list[VDdrw2dVw_MAX_TEMP],
		tmp_temp[VDdrw2dVw_MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[VDdrw2dVw_MAX_FEET],
		tmp_feet[VDdrw2dVw_MAX_FEET * macro_MAX_CHAR],
 		*temp_feet_list[VDdrw2dVw_MAX_TEMP_FEET], 
		tmp_temp_feet[VDdrw2dVw_MAX_TEMP_FEET * macro_MAX_CHAR];

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

	/*
	 * Feet initialization
	 *
 	 * - vol       : The union volume of ModelView object.	
	 */
	nb_feet = 0;

	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],	"note" );
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

	return(	SMCrtMacDef(	"VDdrw2dVw",
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

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/

/*+fi
 -------------------------------------------------------------------------
  Internal Function  VDdrw3dVw_MacDef

  Abstract

        This function creates the VDdrw3dVw macro definition:

  The TEMPLATES:
 
 	- coll	: collector for general information.
 	- obj	: Model view object.

  The FEETS:
 
 	- vol	: The solid generated as input for VDdrw3dVw process.

  Returns

         SMCreMacDef return code

 -------------------------------------------------------------------------
*/

#define VDdrw3dVw_MAX_TEMP	2 	 
#define VDdrw3dVw_MAX_FEET	1
#define VDdrw3dVw_MAX_TEMP_FEET	1	 

VDdrw3dVw_MacDef()
/*
-fi*/
{
int		nb_temp,
		temp_type[VDdrw3dVw_MAX_TEMP],
		nb_feet,
		nb_temp_feet, 
		temp_feet_ind[VDdrw3dVw_MAX_TEMP_FEET];

char		*temp_list[VDdrw3dVw_MAX_TEMP],
		tmp_temp[VDdrw3dVw_MAX_TEMP * macro_MAX_CHAR],	
 		*feet_list[VDdrw3dVw_MAX_FEET],
		tmp_feet[VDdrw3dVw_MAX_FEET * macro_MAX_CHAR],
 		*temp_feet_list[VDdrw3dVw_MAX_TEMP_FEET], 
		tmp_temp_feet[VDdrw3dVw_MAX_TEMP_FEET * macro_MAX_CHAR];

struct GRid	mac_id;
 

	/*
	 * Template initialization
	 */
	nb_temp = 0;

	strcpy( &tmp_temp[nb_temp*macro_MAX_CHAR],	"coll" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = ~0;
	nb_temp++;

	strcpy(&tmp_temp[nb_temp*macro_MAX_CHAR],	"obj" );
	temp_list[nb_temp] = &tmp_temp[nb_temp*macro_MAX_CHAR];
	temp_type[nb_temp] = other_generic;
	nb_temp++;

	/*
	 * Feet initialization
	 *
 	 * - vol       : The union volume of ModelView object.	
	 */

	nb_feet = 0;

	strcpy(&tmp_feet[nb_feet*macro_MAX_CHAR],	"vol" );
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

	return(	SMCrtMacDef(	"VDdrw3dVw",
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

/*----------------------------------------------------------------------------*/
long VDSloadMacroLibrary( name )
IGRchar		*name ;
{
	IGRint		sts, path_len ;
	IGRchar		path[181];
	
	/*
	 * The library 'name' is loaded.
	 */

	sts = MSSUCC ;
	if( ! ( ac$construct_path(
                                mode            = AC_ADD_PATH | AC_INQ,
                                name            = name,
                                path            = path,
                                path_size       = 180,
				path_len        = &path_len )  & 1 ) ) {

		IGRchar ErrBuf[DI_PATH_MAX] ;

		sprintf( ErrBuf, "Cannot retrieve macro library: %s", name );
		UI_error( ErrBuf  ) ;
		sts = MSFAIL ;
	}
	return sts ;
}

/*----------------------------------------------------------------------------*/

end implementation VDSroot;

