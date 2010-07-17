/*
	I/STRUCT
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/lock.h>
#include <time.h>
#include <sys/stat.h>
#include "unistd.h"
#include <FI.h>
#include "VX_FIproto.h"
#include "vsridef.h"
#include "vsri.h"
#include "vsriglobals.h"
#include "vsriproto.h"

static char		_date[3],
			_time[3],
			_monthname,
			_leadingzero,
			_longyear,
			_twelvehour,
			_noampm,
			_idate,
			_itime,
			_dsep[2][2],
			_tsep[2][2] ;
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
static int timNotify(	int	form_label,
			int	gadget_label,
			double	value,
			Form	form ) {

	int	sel,
		pos,
		i ;
	char	fmt[20],
		buffer[100] ;

	switch( gadget_label ) {
		case FI_RESET	: _idate	= 0 ;
				  _itime	= 0 ;
				  _monthname	= TRUE ;
				  _leadingzero	= TRUE ;
				  _longyear	= TRUE ;
				  _twelvehour	= TRUE ;
				  _noampm	= TRUE ;
				  FIf_reset( form ) ;
				  FIg_display( form, FI_FORM_GROUP ) ;
				  break ;

		case FI_ACCEPT	: FIf_erase( form )		; break ;

		case FI_CANCEL	: _idate = -1 ;
				  FIf_erase( form )		; break ;

		case DAY	: _date[_idate++] = 'd' ;
				  FIg_erase( form, DAY )	; break ;

		case MONTH	: _date[_idate++] = 'm' ;
				  FIg_erase( form, MONTH )	; break ;

		case YEAR	: _date[_idate++] = 'y' ;
				  FIg_erase( form, YEAR )	; break ;

		case DAY_FMT	: FIg_get_state( form, gadget_label, &i ) ;
				  _leadingzero = !i ; break ;

		case MONTH_FMT	: FIg_get_state( form, gadget_label, &i ) ;
				  _monthname = !i ; break ;

		case YEAR_FMT	: FIg_get_state( form, gadget_label, &i ) ;
				  _longyear = !i ; break ;

		case HOURS	: _time[_itime++] = 'h' ;
				  FIg_erase( form, HOURS )	; break ;

		case MINUTES	: _time[_itime++] = 'm' ;
				  FIg_erase( form, MINUTES )	; break ;

		case SECONDS	: _time[_itime++] = 's' ;
				  FIg_erase( form, SECONDS )	; break ;

		case HOUR_FMT	: FIg_get_state( form, gadget_label, &i ) ;
				  _twelvehour = !i ; break ;

		case AM_PM	: FIg_get_state( form, gadget_label, &i ) ;
				  _noampm = !i ; break ;
	}
	if( _idate > 0 ) {
		time_t	t = time( NULL ) ;

		FIfld_get_text( form, DATE_SEP1, 0, 0,
				  2, (unsigned char *) _dsep[0], &sel, &pos ) ;

		FIfld_get_text( form, DATE_SEP2, 0, 0,
				  2, (unsigned char *) _dsep[1], &sel, &pos ) ;

		*fmt = '\0' ;
		for( i = 0 ; i < _idate ; i++ ) {
			switch( _date[i] ) {
				case 'd' :
					strcat( fmt,
						_leadingzero ? "%d" : "%e" ) ;
					break ;
				case 'm' :
					strcat( fmt,
						_monthname ? "%b" : "%m" ) ;
					break ;
				case 'y' :
					strcat( fmt,
						_longyear ? "%Y" : "%y" ) ;
					break ;
			}
			if( i < 2 ) {
				if( *_dsep[i] ) {
					strcat( fmt, _dsep[i] ) ;
				} else {
					strcat( fmt, " " ) ;
				}
			}
		}

		cftime( buffer, fmt, &t ) ;
		FIfld_set_text( form, DATE_FIELD, 0, 0, buffer, FALSE ) ;

		strcpy( _dateformat, buffer ) ;
	}

	if( _itime > 0 ) {
		time_t	t = time( NULL ) ;

		FIfld_get_text( form, TIME_SEP1, 0, 0,
				  2, (unsigned char *) _tsep[0], &sel, &pos ) ;
		FIfld_get_text( form, TIME_SEP2, 0, 0,
				  2, (unsigned char *) _tsep[1], &sel, &pos ) ;
				  
		*fmt = '\0' ;
		for( i = 0 ; i < _itime ; i++ ) {
			switch( _time[i] ) {
				case 'h' :
					strcat( fmt,
						_twelvehour ? "%I" : "%H" ) ;
					if( !_noampm ) {
						strcat( fmt, "%p" ) ;
					}
					break ;
				case 'm' : strcat( fmt, "%M" ) ; break ;
				case 's' : strcat( fmt, "%S" ) ; break ;
			}
			if( i < 2 ) {
				if( *_tsep[i] ) {
					strcat( fmt, _tsep[i] ) ;
				} else {
					strcat( fmt, " " ) ;
				}
			}
		}

		cftime( buffer, fmt, &t ) ;
		FIfld_set_text( form, TIME_FIELD, 0, 0, buffer, FALSE ) ;
		strcpy( _timeformat, buffer ) ;
	}
	return FI_SUCCESS ;

} /* timNotify */
/*----------------------------------------------------------------------------*/
int getTimeFormat( void ) {

	char	file[1024] ;
	Form	form ;

	sprintf( file, "%s/%s", _formdir, TIM_FORM ) ;

	if( FIf_new( 200, file, timNotify, &form ) != FI_SUCCESS ) {
		fprintf( stderr, "Cannot create form %s\n", file ) ;
		return FALSE ;
	}

	FIf_display( form ) ;

	strcpy( _tsep[0], ":" ) ;
	strcpy( _tsep[1], ":" ) ;
	strcpy( _dsep[0], " " ) ;
	strcpy( _dsep[1], " " ) ;

	_monthname	= TRUE ;
	_leadingzero	= TRUE ;
	_longyear	= TRUE ;
	_twelvehour	= TRUE ;
	_noampm		= TRUE ;
	_idate = _itime = 0 ;

	FI_process_forms() ;

	return TRUE ;

} /* getTimeFormat */
/*----------------------------------------------------------------------------*/
