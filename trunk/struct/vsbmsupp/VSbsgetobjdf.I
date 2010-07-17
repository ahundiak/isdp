/* $Id: VSbsgetobjdf.I,v 1.1.1.1 2001/01/04 21:10:21 cvs Exp $  */
/***************************************************************************
 * I/STRUCT
 *
 * File:	vsbmsupp/VSbsgetobjdf.I
 *
 * Description: Gets top or bottom of plate
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSbsgetobjdf.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:21  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/02/20  20:26:00  pinnacle
# CR179800676
#
 *
 * History:
 * MM/DD/YY  AUTHOR    DESCRIPTION
 * 02/20/98  ah        Added header
 ***************************************************************************/

class implementation VSbeamSupp ;

#include "EMSmsgdef.h"
#include "ACrg_collect.h"
#include "vsglobalmsg.h"
#include "vsbmsuppdef.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"
/*----------------------------------------------------------------------------*/
method VSgetObjDef( long *msg ; VSobjDef *myDef ) {

#define nbRoots 17
#define nbFeet	1
#define maxName 14
#define maxIntPos 5

	long 		sts ;
	int		i ;

	static char	*tNames[nbRoots] ;
	static int	 tTypes[nbRoots] ;

	static char	*fNames[nbFeet] = { VS_K_bsBmSupp } ;

	static char	iNameBuf[maxName * nbRoots ] ; 
	char *n = iNameBuf ;

	if( !tNames[0] ) {
		sprintf(tNames[0]= n,"%s",VS_K_bsBmAxis);
		tTypes[0] = macro_generic ;
		n += maxName ;
		sprintf(tNames[1]= n,"%s",VS_K_bsTwAng );
		tTypes[1] = text_type ;
		n += maxName ;
		for( i=0; i< maxIntPos ;i++ ) {
			sprintf(tNames[3*i+2]= n,"%s%d",VS_K_bsPosition,i+1);
			tTypes[3*i+2] = other_generic;
			n += maxName ;
			sprintf(tNames[3*i+3]= n,"%s%d",VS_K_bsIntAngle,i+1);
			tTypes[3*i+3] = double_type ;
			n += maxName ;
			sprintf(tNames[3*i+4]= n,"%s%d",VS_K_bsIntRefType,i+1);
			tTypes[3*i+4] = text_type ;
			n += maxName ;
		}

	}

	myDef->info			= VS_gI_StfnrSupp ;
	myDef->type			= 0 ;
	myDef->minInput			= 2 ;
	
	/*
	 * Templates.
	 */
	myDef->input.count		= nbRoots ;
	myDef->input.names		= tNames ;
	myDef->input.type.types		= tTypes ;
	
	/*
	 * Feet.
	 */
	myDef->output.count		= nbFeet ;
	myDef->output.names		= fNames ;
	myDef->output.type.classids	= NULL ;
	
	/*
	 * Virtual feet.
	 */
	myDef->virtual.count		= 0 ;
	
	/*
	 * Templates feet.
	 */
	myDef->i2o.count 		= 0 ; 

	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	return sts ;

} /* method VSgetObjDef */
/*----------------------------------------------------------------------------*/

end implementation VSbeamSupp ;
