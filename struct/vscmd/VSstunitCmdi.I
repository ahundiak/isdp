/*
	I/STRUCT
*/
class implementation VSstunitCmd ;

#include <stdio.h>
#include <string.h>
#include <FI.h>
#include "UOMdef.h"
#include "UOM.h"
#include "dpbco.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "OMtypes.h"
#include "OMmacros.h"
#include "vsglobalmsg.h"
#include "vscmddef.h"
#include "vsmiscmacros.h"
#include "vsiomacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes
 */
%safe
#include "VX_FIproto.h"
%endsafe
#include "vsgetUOMtabl.h"
#include "vsioproto.h"
#include "vsstrngproto.h"

#define VS_K_unUNIT_FIELD	12
#define MAX_ABBRV		10

/*----------------------------------------------------------------------------*/
method statusDispAvailable( int on ) {

	char	msg[MS_MAX_MSG_LENGTH] ;

	if( on ) {
		*msg = '(' ;
		ex$message(	msgnumb		= VS_gI_StsFrmLst,
				buff		= msg + 1 ) ;
		strcat( msg + 1, ")" ) ;
	} else {
		*msg = '\0' ;
	}
	ex$message(	in_buff		= msg,
			justification	= CENTER_JUS,
			field		= KEYIN_FIELD ) ;

	return OM_S_SUCCESS ;

} /* method statusDispAvailable */
/*----------------------------------------------------------------------------*/
method storeEvent(	struct GRevent	*event ;
			int		toIndex ) {

	long sts ;

	if( toIndex < 3 ) {
		me->events[toIndex] = *event ;
		sts = OM_S_SUCCESS ;
	} else	sts = OM_E_INVARG ;

	return sts ;

} /* method storeEvent */
/*----------------------------------------------------------------------------*/
method displayActiveUnits( long *msg ) {

	long		sts ;
	GRIOalias_name	defUnits[3] ;
	char		buffer[GRIO_MAX_ALIAS_SIZE*3+MS_MAX_MSG_LENGTH] ;
	short		nbUnits,
			flag ;
	int		i ;

	flag = 0 ;
	sts = co$get_default_units(	
				msg		= msg,
				osnum		= me->ModuleInfo._MD_OS,
				table_name	= me->UOMtable,
				flag		= &flag,
				num_defaults	= &nbUnits,
				default_units	= defUnits ) ;
	__CheckRC( sts, *msg, "co$get_default_units", wrapup ) ;

	strcpy( buffer, &defUnits[0][0] ) ;
	for( i = 1; i < nbUnits ; ++i ) {
		strcat( buffer, "," ) ;
                strcat( buffer, &defUnits[i][0] ) ;
	}

	ex$message( msgnumb = VS_gI_ActMassUnit, type = "%s", var = `buffer` ) ;

	wrapup :
		me->ret = sts & 1 & *msg ? VS_K_ACT_SUCCESS : VS_K_ABORT_CMD ;
		return OM_S_SUCCESS ;

} /* method displayActiveUnits */
/*----------------------------------------------------------------------------*/
method putActiveUnits( long *msg ) {

	long		sts ;
	GRIOalias_name	defUnits[3] ;
	short		nbUnits ;
	int		i ;
        IGRboolean	flag = FALSE ;
	struct GRevent	*ev ;

#define VALID_STRING( e ) (    (e).response == EX_STRING \
			    && strlen( (e).event.keyin ) < GRIO_MAX_ALIAS_SIZE \
			    && (e).subtype != GRst_DEFAULT )

        /* 
         * Set all unit strings to NULL 
         */
	for( i = 0 ; i < 3 ; i++ ) defUnits[i][0] = 0 ;
	nbUnits = 0 ;

	/* 
	 *  Get all possible unit strings. The first subtype of GRst_DEFAULT
	 *  indicates the end of input. 
	 */
	ev = me->events ;
	if( VALID_STRING( ev[0] ) ) {
		strcpy( &defUnits[nbUnits][0], ev[0].event.keyin ) ;
		nbUnits++ ;
		
		if( VALID_STRING( ev[1] ) ) {
			strcpy( &defUnits[nbUnits][0], ev[1].event.keyin ) ;
			nbUnits++ ;

			if( VALID_STRING( ev[2] ) ) {
				strcpy( &defUnits[nbUnits][0],
					ev[2].event.keyin ) ;
				nbUnits++ ;
			}
		}
	}

	/*
	 * If no strings were set then either one of the subtypes was
	 * invalid or one of the strings was too long. 
	 */
	if( nbUnits == 0 ) {
		*msg = CO_E_INVINP ; sts = OM_W_ABORT ;
	} else {
		sts = co$put_default_units(
				msg		= msg,
				table_name	= me->UOMtable,
				osnum		= me->ModuleInfo._MD_OS,
				flag		= &flag,
				num_defaults	= &nbUnits,
				default_units	= defUnits ) ;

		if( !( sts & 1 & *msg ) ) *msg = CO_E_INVINP ;
	}

	if( !( sts & 1 & *msg ) ) {
		if( *msg == CO_E_INVINP ) {
			me->ret = CO_E_INVINP ;
		} else {
			me->ret = VS_K_ABORT_CMD ;
		}
	} else me->ret = VS_K_ACT_SUCCESS ;

	return OM_S_SUCCESS ;

} /* method putActiveUnits */ 
/*----------------------------------------------------------------------------*/
method setUOMtable( char *UOMtable ) {

	om$vla_set_dimension(	varray	= me->UOMtable,
				size	= 1 + strlen( UOMtable ) ) ;
	strcpy( me->UOMtable, UOMtable ) ;

	return OM_S_SUCCESS ;

} /* method setUOMtable */
/*----------------------------------------------------------------------------*/
method status_disp() {

	long			sts,
				msg ;
	int			i,		/* Loop index		*/
				row,		/* Row counter		*/
				count ;		/* Count of aliases	*/
	OMuword			osnum ;		/* Of active file	*/
	UOM_TYPE		*UOMtable ;	/* Pointer to UOM table	*/
	UOM_VARIANT		*variant ;	/* For a UOM type	*/
	char			**aliases ;	/* For a variant	*/
	char			*form,		/* Status display form	*/
				buf[(1+GRIO_MAX_ALIAS_SIZE)*MAX_ABBRV],
				toCvrt[3+GRIO_MAX_ALIAS_SIZE],
				*converted ;	/* Alias -> active unit	*/
	double			value ;		/* One alias's value	*/

	om$send(msg	= message CEO_LOCATE.status_disp(),
		mode	= OM_e_wrt_message,
		targetid= my_id ) ;

	form = me->status_display_form_ptr ;
	if( !form ) return OM_S_SUCCESS ;

	ex$get_cur_mod( osnum = &osnum ) ;

	sts = VSgetUOMtable( osnum, me->UOMtable, &UOMtable ) ;
	if( !( sts & 1 ) ) goto wrapup ;

	/*
	 * Count variants on the UOM. Note: this is a circular list.
	 */
	count	= 0 ;
	variant = UOMtable->variant ;
	do {	count++ ;
		variant = variant->next ;
	} while( variant != UOMtable->variant ) ;

	FIfld_set_num_rows( form, VS_K_unUNIT_FIELD, count ) ;

	row = 0 ;

	variant = UOMtable->variant ;

	do {
		aliases = variant->alias ;
	
		i	= 0 ;
		*buf	= '\0' ;

		while( aliases[i] && i < MAX_ABBRV ) {
		
			strcat( buf, aliases[i] ) ;

			if( aliases[i+1] ) strcat( buf, "," ) ;
			i++ ;
		}
		/*
		 * Show value of unit wrt active unit.
		 */
		sprintf( toCvrt, "1 %s", aliases[0] ) ;
		vs$unit_to_system(	msg	= &msg,
					type	= me->UOMtable,
					unit	= toCvrt,
					p_value	= &value ) ;

		vs$system_to_unit(	msg	= &msg,
					type	= me->UOMtable,
					osnum	= osnum,
					value	= value,
					p_unit	= &converted ) ;

		FIfld_set_text( form, VS_K_unUNIT_FIELD, row, 0,
						buf, FALSE ) ;
		FIfld_set_text( form, VS_K_unUNIT_FIELD, row, 1,
						converted, FALSE ) ;
		row++ ;
		variant = variant->next ;

	} while( variant != UOMtable->variant ) ;

	wrapup :
		return OM_S_SUCCESS ;

} /* method status_disp */
/*----------------------------------------------------------------------------*/
method form_notification( int label, gadget ; double value ; char *form ) {

	long		msg,
			size ;
	int		rc ;
	int		sel,
			pos ;
	char		alias[(1+GRIO_MAX_ALIAS_SIZE)*MAX_ABBRV],
			*comma ;

	switch( gadget ) {

	case FI_ACCEPT		:

		om$send(msg	= message CEO.erase_form_by_label(
						STATUS_FORM, TRUE, &rc ),
			targetid= my_id ) ;
		break ;

	case VS_K_unUNIT_FIELD	:
		FIfld_get_text( form, gadget, (int) value, 0, sizeof alias,
                		(unsigned char *) alias, &sel, &pos ) ;

		/*
		 * Look for ',' if any.
		 */
		if( comma = strchr( alias, ',' ) ) *comma = '\0' ;

		pos = EX_STRING ;
                size= strlen( alias ) + 1 ;
		ex$putque(	byte		= &size,
                		msg		= &msg,
                		response	= &pos,
                		buffer		= alias ) ;
		break ;

	}
	return OM_S_SUCCESS ;

} /* method form_notification */
/*----------------------------------------------------------------------------*/

end implementation VSstunitCmd ;
