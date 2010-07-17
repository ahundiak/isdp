/* $Id: VSexdstfrRDB.C,v 1.2 2001/01/17 00:00:49 ramarao Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsris/VSexdstfrRDB.C
 *
 * Description: Density
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VSexdstfrRDB.C,v $
 * Revision 1.2  2001/01/17 00:00:49  ramarao
 * *** empty log message ***
 *
 * Revision 1.3  2000/11/03  18:51:32  pinnacle
 * ylong
 *
 * Revision 1.2  2000/11/02  20:02:50  pinnacle
 * (No comment)
 *
 * Revision 1.1  2000/11/01  16:21:06  pinnacle
 * ah
 *
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 11/01/00  ah      Added Header
 *                   Use cache routine VDdenGetDensity
 * 11/02/00  ylong   Default setting of "density"
 ***************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include "UOMdef.h"
#include "vsglobalmsg.h"
#include "vsRDBdef.h"
#include "vsRISmacros.h"
#include "vsRDBmacros.h"
#include "vsmiscmacros.h"
#include "vsmeasdef.h"
#include "vsiomacros.h"
#include "vsdbgmacros.h"
#include "msdef.h"
#include "ms.h"
#include "msmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsstrngproto.h"

extern IGRlong VDdenGetDensity __((IGRchar   *material,
                                   IGRchar   *grade,
                                   IGRdouble *density,
                                   IGRchar   *unit));

/*----------------------------------------------------------------------------*/
static long VSconvertDensityToSysUnits( msg, unitType, usrUnit, sysUnit )

long	*msg ;
char	unitType ;
double	usrUnit,
	*sysUnit ; {

	double		distFactor,
			massFactor ;
	char		*massUnit,
			*distUnit,
			oneUnitOfMass[UOM_K_MAX_LEN],
			oneUnitOfDist[UOM_K_MAX_LEN] ;
		
	/*
	 * NOTE: since we here hard-code "lb_mass", "in", etc., it is very much
	 * dependent of what is put in the distance and mass UOM tables, which
	 * may be altered (possibly by the user), BUT there is no other way
	 * to convert the user units to database units ( We use #defines of
	 * "vsmeasdef.h" ).
	 */

	switch( unitType ) {
		case VS_K_PDM_lb_per_cubic_in	: massUnit = VS_K_POUND ;
						  distUnit = VS_K_INCH	; break;

		case VS_K_PDM_lb_per_cubic_ft	: massUnit = VS_K_POUND ;
						  distUnit = VS_K_FOOT	; break;

		case VS_K_PDM_g_per_cubic_cm	: massUnit = VS_K_GRAM  ;
						  distUnit = VS_K_CM	; break;

		case VS_K_PDM_kg_per_cubic_m	: massUnit = VS_K_KG	;
						  distUnit = VS_K_METER	; break;

		default				: *msg = MSINARG ; goto wrapup ;
	}

	sprintf( oneUnitOfMass, "1. %s", massUnit ) ;
	sprintf( oneUnitOfDist, "1. %s", distUnit ) ;

	vs$unit_to_system(	msg	= msg,
				unit	= oneUnitOfMass,
				type	= VS_K_uomMASS,
				p_value	= &massFactor ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	vs$unit_to_system(	msg	= msg,
				unit	= oneUnitOfDist,
				type	= GRIO_DISTANCE,
				p_value	= &distFactor ) ;
	if( !( *msg & 1 ) ) goto wrapup ;

	*sysUnit =   usrUnit * massFactor
		   / ( distFactor * distFactor * distFactor ) ;

	wrapup :
		return *msg & 1 ;

} /* VSconvertDensityToSysUnits */
/*----------------------------------------------------------------------------*/
long VSextractDensityFromRDB( msg, errStr, material, grade, density )

long		*msg ;
char		*errStr,
		*material,
		*grade ;
double		*density ; {

	long	sts ;
	char	searchCriteria[VS_K_MAX_CHARS],
		**p_density	= NULL,
		**p_unit	= NULL ;
	int	dcount		= 0,
		ucount		= 0 ;
	char	units;
	char	errLoc[DI_PATH_MAX];

	if( errStr ) *errStr = '\0' ;
	errLoc[0] = '\0' ;

	*msg = MSSUCC ;

	if( ! density ){
		*msg = MSFAIL ;
		goto wrapup ;
	}

	*density = 0.0 ;

        /* ---------------------------------------
         * See if it's in the cache
         */
        sts = VDdenGetDensity(material,grade,density,&units);
        if (sts & 1) {
          VSconvertDensityToSysUnits(msg,units,*density,density);
	  if( *density < 0.000000001 ){
		sprintf(errLoc,"Invalid Density for %s, %s in cache. Set to 1", 
				material, grade );
		*density = 1.0 ;
	  }
          *msg = MSSUCC;
          goto wrapup;
        }
	*density = 0.0 ;

	/* Find density given material+grade.
	 * Note that the grade is in "revision" and the material in "part_num".
	 * SELECT	density
	 * FROM		material
	 * WHERE		n_itemrev  = '<grade>'
	 *		AND	n_itemname = '<material>'	
	 */
	sprintf( searchCriteria, "%s='%s' AND %s='%s'",
		 PDU_REVISION_ATTR	, grade,
		 PDU_PARTID_ATTR	, material ) ;

	sts = vs$RISquery(	table	= VS_K_PDM_matCat,
				select	= VS_K_PDM_densityAttr,
				where	= searchCriteria,
				p_count	= &dcount,
				p_list	= &p_density ) ;
	if( !sts ) {
		*msg = MSFAIL ;
		ex$message(	msgnumb	= VS_gW_QyDstFailed,
				buff	= errLoc,
				type	= "%s%s",
				var	= `material,grade` ) ;
		goto wrapup ;
	} else if( !dcount ) {
		*msg = MSFAIL ;
		ex$message(	msgnumb	= VS_gW_NoDensity,
				buff	= errLoc,
				type	= "%s%s",
				var	= `material,grade` ) ;
		goto wrapup ;
	}

	if( ! strlen( p_density[0] )) {
		sprintf( errLoc, "No Density defined for %s, %s. Set to 1", 
				material, grade );
		*density = 1.0 ;
	}	
	else{ 	*density = atof( p_density[0] ) ; }

	VSfreeList( dcount, p_density ) ;

	/*
	 * Now get unit type.
	 * Note that the grade is in "revision" and the material in "part_num".
	 * SELECT	unit
	 * FROM		material
	 * WHERE		n_itemrev  = '<grade>'
	 *		AND	n_itemname = '<material>'	
	 */

	sts = vs$RISquery(	table	= VS_K_PDM_matCat,
				select	= VS_K_PDM_unitAttr,
				where	= searchCriteria,
				p_count	= &ucount,
				p_list	= &p_unit ) ;

	if( !sts ) {
		*msg = MSFAIL ;
		ex$message(	msgnumb	= VS_gW_QyDstUnitFailed,
				buff	= errLoc,
				type	= "%s%s",
				var	= `material,grade` ) ;
		goto wrapup ;
	} else if( !ucount ) {
		*msg = MSFAIL ;
		ex$message(	msgnumb	= VS_gW_NoDstUnit,
				buff	= errLoc,
				type	= "%s%s",
				var	= `material,grade` ) ;
	}

	VSconvertDensityToSysUnits(	msg,
					p_unit[0][0],
					*density,
					density ) ;
	VSfreeList( ucount, p_unit ) ;

	if( *density < 0.000000001 ){
		sprintf( errLoc, "Invalid Density for %s, %s. Set to 1", 
				material, grade );
		*density = 1.0 ;
	}

	*msg = MSSUCC ;

	wrapup :
		if( errLoc[0] != '\0' ){
			printf("%s\n", errLoc );
			if( errStr ) { strcpy( errStr, errLoc );}
		}
			
		return *msg & 1 ;

} /* VSextractDensityFromRDB */
/*----------------------------------------------------------------------------*/

