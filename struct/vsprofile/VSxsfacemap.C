/* $Id: VSxsfacemap.C,v 1.1.1.1 2001/01/04 21:10:56 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	vsprofile/VSxsfacemap.C
 *
 * Description:
 *		Maps beam faces
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSxsfacemap.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:56  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.2  1998/02/19  17:19:40  pinnacle
 * Added 34 beam faces
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	02/19/98	ah		Added 34 new beam faces
 ***************************************************************************/

#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vssectiondef.h"
#include "vsglobalmsg.h"

/*-ARRAY-OF-FACE-NAMES--------------------------------------------------------*/
typedef struct {
	char	*intName ;	/* Internal name of face		*/
	/*
	 * We store the address of the global containing the message number
	 * and not the value of the message number since the compiler does
	 * not know its value at parse time. But storing the address of a
	 * global variable in a static variable is OK.
	 */
	long	*descKey,	/* Message key of abbr'd description	*/
		*longKey ;	/* Message key of long description	*/
} VSfaceDesc ;

/*
 * The order in the following array is important, names correspond to indices
 * #defined in "vssectiondef.h".
 * The internal name is assigned by beams to their faces.
 */
#define KEYS( pattern ) &VS_gI_##pattern, &VS_gI_##pattern##_long

static VSfaceDesc VS_Ga_FaceDescr[VS_K_sc_MAXFACES] = {
/*
  Internal name		 Msg keys of description     Index in vssectiondef.h
 */
{ VS_K_nmFlgSupR	, KEYS( FlgSupR      ) }, /* VS_K_sc_FlgSupR	*/
{ VS_K_nmFlgSupE	, KEYS( FlgSupE	     ) }, /* VS_K_sc_FlgSupE	*/
{ VS_K_nmFlgSupL	, KEYS( FlgSupL	     ) }, /* VS_K_sc_FlgSupL	*/
{ VS_K_nmFlgSupILS	, KEYS( FlgSupILS    ) }, /* VS_K_sc_FlgSupILS	*/
{ VS_K_nmFlgSupILF	, KEYS( FlgSupILF    ) }, /* VS_K_sc_FlgSupILF	*/
{ VS_K_nmWebL		, KEYS( WebL	     ) }, /* VS_K_sc_WebL	*/
{ VS_K_nmFlgInfILF	, KEYS( FlgInfILF    ) }, /* VS_K_sc_FlgInfILF	*/
{ VS_K_nmFlgInfILS	, KEYS( FlgInfILS    ) }, /* VS_K_sc_FlgInfILS	*/
{ VS_K_nmFlgInfL	, KEYS( FlgInfL	     ) }, /* VS_K_sc_FlgInfL	*/	
{ VS_K_nmFlgInfE	, KEYS( FlgInfE	     ) }, /* VS_K_sc_FlgInfE	*/
{ VS_K_nmFlgInfR	, KEYS( FlgInfR	     ) }, /* VS_K_sc_FlgInfR	*/	
{ VS_K_nmFlgInfIRS	, KEYS( FlgInfIRS    ) }, /* VS_K_sc_FlgInfIRS	*/	
{ VS_K_nmFlgInfIRF	, KEYS( FlgInfIRF    ) }, /* VS_K_sc_FlgInfIRF	*/
{ VS_K_nmWebR		, KEYS( WebR	     ) }, /* VS_K_sc_WebR	*/
{ VS_K_nmFlgSupIRF	, KEYS( FlgSupIRF    ) }, /* VS_K_sc_FlgSupIRF	*/
{ VS_K_nmFlgSupIRS	, KEYS( FlgSupIRS    ) }, /* VS_K_sc_FlgSupIRS	*/
{ VS_K_nmCircle		, KEYS( Circle	     ) }, /* VS_K_sc_Circle	*/
/*
 *	Additional beam faces.
 */
{ VS_K_nmFlgSupR_2	, KEYS( FlgSupR_2    ) }, /* VS_K_sc_FlgSupR_2	  */
{ VS_K_nmFlgSupE_2	, KEYS( FlgSupE_2    ) }, /* VS_K_sc_FlgSupE_2	  */
{ VS_K_nmFlgSupL_2	, KEYS( FlgSupL_2    ) }, /* VS_K_sc_FlgSupL_2	  */
{ VS_K_nmFlgSupILS_2	, KEYS( FlgSupILS_2  ) }, /* VS_K_sc_FlgSupILS_2  */
{ VS_K_nmFlgSupILF_2	, KEYS( FlgSupILF_2  ) }, /* VS_K_sc_FlgSupILF_2  */
{ VS_K_nmWebL_2		, KEYS( WebL_2	     ) }, /* VS_K_sc_WebL_2	  */
{ VS_K_nmFlgInfILF_2	, KEYS( FlgInfILF_2  ) }, /* VS_K_sc_FlgInfILF_2  */
{ VS_K_nmFlgInfILS_2	, KEYS( FlgInfILS_2  ) }, /* VS_K_sc_FlgInfILS_2  */
{ VS_K_nmFlgInfL_2	, KEYS( FlgInfL_2    ) }, /* VS_K_sc_FlgInfL_2	  */	
{ VS_K_nmFlgInfE_2	, KEYS( FlgInfE_2    ) }, /* VS_K_sc_FlgInfE_2	  */
{ VS_K_nmFlgInfR_2	, KEYS( FlgInfR_2    ) }, /* VS_K_sc_FlgInfR_2	  */	
{ VS_K_nmFlgInfIRS_2	, KEYS( FlgInfIRS_2  ) }, /* VS_K_sc_FlgInfIRS_2  */	
{ VS_K_nmFlgInfIRF_2	, KEYS( FlgInfIRF_2  ) }, /* VS_K_sc_FlgInfIRF_2  */
{ VS_K_nmWebR_2		, KEYS( WebR_2	     ) }, /* VS_K_sc_WebR_2	  */
{ VS_K_nmFlgSupIRF_2	, KEYS( FlgSupIRF_2  ) }, /* VS_K_sc_FlgSupIRF_2  */
{ VS_K_nmFlgSupIRS_2	, KEYS( FlgSupIRS_2  ) }, /* VS_K_sc_FlgSupIRS_2  */
{ VS_K_nmCircle_2	, KEYS( Circle_2     ) }, /* VS_K_sc_Circle_2	  */

{ VS_K_nmFlgSupR_3	, KEYS( FlgSupR_3    ) }, /* VS_K_sc_FlgSupR_3	  */
{ VS_K_nmFlgSupE_3	, KEYS( FlgSupE_3    ) }, /* VS_K_sc_FlgSupE_3	  */
{ VS_K_nmFlgSupL_3	, KEYS( FlgSupL_3    ) }, /* VS_K_sc_FlgSupL_3	  */
{ VS_K_nmFlgSupILS_3	, KEYS( FlgSupILS_3  ) }, /* VS_K_sc_FlgSupILS_3  */
{ VS_K_nmFlgSupILF_3	, KEYS( FlgSupILF_3  ) }, /* VS_K_sc_FlgSupILF_3  */
{ VS_K_nmWebL_3		, KEYS( WebL_3	     ) }, /* VS_K_sc_WebL_3	  */
{ VS_K_nmFlgInfILF_3	, KEYS( FlgInfILF_3  ) }, /* VS_K_sc_FlgInfILF_3  */
{ VS_K_nmFlgInfILS_3	, KEYS( FlgInfILS_3  ) }, /* VS_K_sc_FlgInfILS_3  */
{ VS_K_nmFlgInfL_3	, KEYS( FlgInfL_3    ) }, /* VS_K_sc_FlgInfL_3	  */	
{ VS_K_nmFlgInfE_3	, KEYS( FlgInfE_3    ) }, /* VS_K_sc_FlgInfE_3	  */
{ VS_K_nmFlgInfR_3	, KEYS( FlgInfR_3    ) }, /* VS_K_sc_FlgInfR_3	  */	
{ VS_K_nmFlgInfIRS_3	, KEYS( FlgInfIRS_3  ) }, /* VS_K_sc_FlgInfIRS_3  */	
{ VS_K_nmFlgInfIRF_3	, KEYS( FlgInfIRF_3  ) }, /* VS_K_sc_FlgInfIRF_3  */
{ VS_K_nmWebR_3		, KEYS( WebR_3	     ) }, /* VS_K_sc_WebR_3	  */
{ VS_K_nmFlgSupIRF_3	, KEYS( FlgSupIRF_3  ) }, /* VS_K_sc_FlgSupIRF_3  */
{ VS_K_nmFlgSupIRS_3	, KEYS( FlgSupIRS_3  ) }, /* VS_K_sc_FlgSupIRS_3  */
{ VS_K_nmCircle_3	, KEYS( Circle_3     ) }, /* VS_K_sc_Circle_3	  */

{ VS_K_nmFlgSupR_4	, KEYS( FlgSupR_4    ) }, /* VS_K_sc_FlgSupR_4	  */
{ VS_K_nmFlgSupE_4	, KEYS( FlgSupE_4    ) }, /* VS_K_sc_FlgSupE_4	  */
{ VS_K_nmFlgSupL_4	, KEYS( FlgSupL_4    ) }, /* VS_K_sc_FlgSupL_4	  */
{ VS_K_nmFlgSupILS_4	, KEYS( FlgSupILS_4  ) }, /* VS_K_sc_FlgSupILS_4  */
{ VS_K_nmFlgSupILF_4	, KEYS( FlgSupILF_4  ) }, /* VS_K_sc_FlgSupILF_4  */
{ VS_K_nmWebL_4		, KEYS( WebL_4	     ) }, /* VS_K_sc_WebL_4	  */
{ VS_K_nmFlgInfILF_4	, KEYS( FlgInfILF_4  ) }, /* VS_K_sc_FlgInfILF_4  */
{ VS_K_nmFlgInfILS_4	, KEYS( FlgInfILS_4  ) }, /* VS_K_sc_FlgInfILS_4  */
{ VS_K_nmFlgInfL_4	, KEYS( FlgInfL_4    ) }, /* VS_K_sc_FlgInfL_4	  */	
{ VS_K_nmFlgInfE_4	, KEYS( FlgInfE_4    ) }, /* VS_K_sc_FlgInfE_4	  */
{ VS_K_nmFlgInfR_4	, KEYS( FlgInfR_4    ) }, /* VS_K_sc_FlgInfR_4	  */	
{ VS_K_nmFlgInfIRS_4	, KEYS( FlgInfIRS_4  ) }, /* VS_K_sc_FlgInfIRS_4  */	
{ VS_K_nmFlgInfIRF_4	, KEYS( FlgInfIRF_4  ) }, /* VS_K_sc_FlgInfIRF_4  */
{ VS_K_nmWebR_4		, KEYS( WebR_4	     ) }, /* VS_K_sc_WebR_4	  */
{ VS_K_nmFlgSupIRF_4	, KEYS( FlgSupIRF_4  ) }, /* VS_K_sc_FlgSupIRF_4  */
{ VS_K_nmFlgSupIRS_4	, KEYS( FlgSupIRS_4  ) }, /* VS_K_sc_FlgSupIRS_4  */
{ VS_K_nmCircle_4	, KEYS( Circle_4     ) }, /* VS_K_sc_Circle_4	  */

} ;
/*----------------------------------------------------------------------------*/
long VStransFaceNumberToNm( msg, number, name )

long		*msg ;
int		number ;
char		*name ; {

	long		sts ;	/* OM return code	*/

	if( number >= 0 && number < VS_K_sc_MAXFACES ) {
		strcpy( name, VS_Ga_FaceDescr[number].intName ) ;
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	} else {
		*name = '\0' ;
		*msg	= EMS_E_NoSolution ;
		sts	= OM_W_NAMENOTFOUND ;
	}

	return sts ;

} /* VStransFaceNumberToNm */
/*----------------------------------------------------------------------------*/
long VStransFaceNmToNumber( msg, name, number )

long			*msg ;
char			*name ;
int			*number ; {

	long		sts ;	/* OM return code	*/
	int		i ;

	sts	= OM_W_NAMENOTFOUND ;
	*msg	= EMS_E_NoSolution ;

	for( i = 0 ; i < VS_K_sc_MAXFACES ; i++ ) {
		if( !strcmp( name, VS_Ga_FaceDescr[i].intName ) ) {
			*msg	= MSSUCC ;
			sts	= OM_S_SUCCESS ;
			*number	= i ;
			break ;
		}
	}
	return sts ;

} /* VStransFaceNmToNumber */
/*----------------------------------------------------------------------------*/
long VSgetCmpDescr( msg, descr, longdescr )

/*
 * This function interfaced by macro vs$getComponentDescr.
 */

long		*msg ;
long		descr[VS_K_sc_MAXFACES] ;
long		longdescr[VS_K_sc_MAXFACES] ; {

	int	i ;

	for( i = 0 ; i < VS_K_sc_MAXFACES ; i++ ) {
		descr[i] = *VS_Ga_FaceDescr[i].descKey ;
		if( longdescr ) longdescr[i] = *VS_Ga_FaceDescr[i].longKey ;
	}
	*msg = MSSUCC ;
	return OM_S_SUCCESS ;

} /* VSgetCmpDescr */
/*----------------------------------------------------------------------------*/
long VSgetCmpNameAndDescr( msg, usrIndex, name, descr )

long	*msg ;
int	usrIndex ;
char	**name ;
long	*descr ; {

	long	sts ;

	if( usrIndex >= 0 && usrIndex < VS_K_sc_MAXFACES ) {
		*name	= VS_Ga_FaceDescr[usrIndex].intName ;
		*descr	= *VS_Ga_FaceDescr[usrIndex].longKey ;
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	} else {
		*msg	= EMS_E_NoSolution ;
		sts	= OM_W_NAMENOTFOUND ;
	}

	return sts ;

} /* VSgetCmpNamesAndDescrs */
/*----------------------------------------------------------------------------*/

