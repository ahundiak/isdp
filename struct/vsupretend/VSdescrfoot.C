/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include "vspart.h"
#include "vscmd.h"
#include "vsmeasdef.h"
#include "vsdef.h"
#include "vsbeamdef.h"
#include "vsplatedef.h"
#include "vsiomacros.h"
#include "vsRDBdef.h"
#include "vsRDBmacros.h"
#include "vsglobalmsg.h"
/*
 * Includes of function prototypes.
 */
#include "vsfnditmary.h"
#include "vsioproto.h"
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
int VSdescribeFoot( rtype, osnum, name, value, outbuf )

unsigned long	rtype ;
OMuword		osnum ;
char		*name,
		*outbuf ;
double		value ; {

	long	msg ;
	char	*Unit ;
#define	_dist	0
#define _class	1
#define _pmtype	2
#define _bmtype	3
#define _pgeom	4
#define _bgeom	5
#define	_none	6
	int	u,
		copy ;

	long	keyList[VS_rdb_MAXCLASSES] ;
	int	clsList[VS_rdb_MAXCLASSES] ;
	long	kpList [VS_rdb_MAXPLTYPES] ;
	int	ptList [VS_rdb_MAXPLTYPES] ;
	long	kbList [VS_rdb_MAXBMTYPES] ;
	int	btList [VS_rdb_MAXBMTYPES] ;
	

	     if( !strcmp( name, VS_K_plLengthAttr ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_plWidthAttr  ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_plThcknsAttr ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_bmLengthAttr ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_bmHeightAttr ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_bmWidthAttr  ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_bmFlgThkAttr ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_bmWebThkAttr ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_bmFltRadAttr ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_prFpThckAttr ) ) { u = _dist	; }
	else if( !strcmp( name, VS_K_prMbrClsAttr ) ) { u = _class	; }
	else if( !strcmp( name, VS_K_prMbrTypAttr ) ) { 
		     if( rtype & VS_m_PLATE )	u = _pmtype ;
		else if( rtype & VS_m_BEAM  )	u = _bmtype ;
		else				u = _none ;
	} else if( !strcmp( name, VS_K_prMbrGeoAttr  ) ) {
		     if( rtype & VS_m_PLATE )	u = _pgeom ;
		else if( rtype & VS_m_BEAM  )	u = _bgeom ;
		else				u = _none ;
	} else				      { u = _none	; }

	copy = FALSE ;
	switch( u ) {

		case _dist	:
			vs$system_to_unit(	msg	= &msg,
						value	= value,
						type	= GRIO_DISTANCE,
						osnum	= osnum,
						p_unit	= &Unit ) ;
			copy = TRUE ;
			break ;


		case _class	:
			vs$get_member_classes_from_RDB(	msg	= &msg,
							clsList	= clsList,
							keyList	= keyList ) ;
			if( msg & 1 ) {
				int	found ;

				VSfind_item_in_array( (int) value,
							clsList,
							VS_rdb_MAXCLASSES,
							&found ) ;
				if( found != -1 ) {
					msg = keyList[found] ;
					strcpy( outbuf,
						VSmsgkey2string( msg ) ) ;
					break ;

				}
			}
			goto NONE ;

		case _pmtype	:
			vs$get_mb_plate_types_from_RDB(	msg	= &msg,
							typeList= ptList,
							keyList	= kpList ) ;
			if( msg & 1 ) {
				int	found ;
				VSfind_item_in_array( (int) value,
							ptList,
							VS_rdb_MAXPLTYPES,
							&found ) ;
				if( found != -1 ) {
					msg = kpList[found] ;
					strcpy( outbuf,
						VSmsgkey2string( msg ) ) ;
					break ;
				}
			}
			goto NONE ;

		case _bmtype	:
			vs$get_mb_beam_types_from_RDB(	msg	= &msg,
							typeList= btList,
							keyList	= kbList ) ;
			if( msg & 1 ) {
				int	found ;
				VSfind_item_in_array( (int) value,
							btList,
							VS_rdb_MAXPLTYPES,
							&found ) ;
				if( found != -1 ) {
					msg = kbList[found] ;
					strcpy( outbuf,
						VSmsgkey2string( msg ) ) ;
					break ;
				}
			}
			goto NONE ;

		case _pgeom	:
			switch( (int) value ) {
				case VS_rdb_plFLAT	:
					msg = VS_gI_flat	; break ;
				case VS_rdb_plCURVED	:
					msg = VS_gI_curved	; break ;
				default			: goto NONE ;
			}
			strcpy( outbuf, VSmsgkey2string( msg ) ) ;
			break ;

		case _bgeom	:
			switch( (int) value ) {
				case VS_rdb_bmLINEAR	:
					msg = VS_gI_linear	; break ;
				case VS_rdb_bmCURVED	:
					msg = VS_gI_curved	; break ;
				case VS_rdb_bmTWISTED	:
					msg = VS_gI_twisted	; break ;
				default			: goto NONE ;
			}
			strcpy( outbuf, VSmsgkey2string( msg ) ) ;
			break ;
		case _none	:
		NONE		:
			*outbuf = '\0' ;
			break ;
	}
	if( copy ) {
		if( msg & 1 )	{

			/*
			 * Remove possible trailing blanks.
			 */
			strcpy( outbuf, VSstripString( Unit ) ) ;
		} else {
			*outbuf = '\0' ;
		}
	}

	return 1 ;

} /* VSdescribeFoot */
/*----------------------------------------------------------------------------*/

