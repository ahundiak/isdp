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
/*----------------------------------------------------------------------------*/
void setTime( const Form form, int field ) {

	char	buffer[100] ;

	if( *_timeformat ) {
		time_t	t = time( NULL ) ;
		cftime( buffer, _timeformat, &t ) ;
		strncpy( _tim, buffer, MAX_TIM_LEN )[MAX_TIM_LEN] = '\0' ;
	} else {
		*_tim = '\0' ;
	}
	FIfld_set_text( form, field, 0, 0, _tim, FALSE ) ;
	
} /* setTime */
/*----------------------------------------------------------------------------*/
void setDate( const Form form, int field ) {

	char	buffer[100] ;

	if( *_dateformat ) {
		time_t	t = time( NULL ) ;
		cftime( buffer, _dateformat, &t ) ;
		strncpy( _dat, buffer, MAX_DAT_LEN )[MAX_DAT_LEN] = '\0' ;
	} else {
		*_dat = '\0' ;
	}
	FIfld_set_text( form, field, 0, 0, _dat, FALSE ) ;

} /* setDate */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
static int initialNotify(	int	form_label,
				int	gadget_label,
				double	value,
				Form	form ) {

	int	max = 0 ;
	char	buf[100],
		*text ;

	switch( gadget_label ) {
		case FAM : max = MAX_MAT_LEN	; goto MAXCHARS ;
		case NAM : max = MAX_NAM_LEN	; goto MAXCHARS ;
		case MAT : max = MAX_MAT_LEN	; goto MAXCHARS ; 
		case CRE : max = MAX_CRE_LEN	; goto MAXCHARS ; 
		case TIM : max = MAX_TIM_LEN	; goto MAXCHARS ; 
		case DAT : max = MAX_DAT_LEN	; goto MAXCHARS ; 
		case LIB : max = MAX_LIB_LEN	; goto MAXCHARS ; 
		case DSC : max = MAX_DSC_LEN	; goto MAXCHARS ; 
		case PAR : max = MAX_PAR_LEN	;
		MAXCHARS :
			   sprintf( buf, "Maximum %d characters", max ) ;
			   text = buf ;
			   break ;
		case DIR : text = "Directory for data base files" ;
			   break ;
		default	 : text = "" ;
			   break ;
		
	}
	prompt( text ) ;
	return FI_SUCCESS ;

} /* initialNotify */
/*----------------------------------------------------------------------------*/
static void updateParField( Form form ) {

	int	i,
		parnum = getParNum()  ;

	for( i = 0 ; i < parnum ; i++ ) {
		FIfld_set_text ( form, PAR, i, 0, _par[i].name , FALSE ) ;
		FIfld_set_value( form, PAR, i, 1, _par[i].value, FALSE ) ;
	}

	for( i = parnum ; i < MAX_PAR_NUM ; i++ ) {
		FIfld_set_text( form, PAR, i, 0, "", FALSE ) ;
		FIfld_set_text( form, PAR, i, 1, "", FALSE ) ;
	}

} /* updateParField */
/*----------------------------------------------------------------------------*/
static void verifyParValue( double value_in, int index, double *value_out ) {

	if( _choice == PLT_CHOICE ) {
		if( value_in <= 0 ) {
			msg( "Thickness must be > 0" ) ;
			*value_out = 1;
		}
	} else {
		*value_out = value_in ;
	}

	_par[index].value = *value_out ;

} /* verifyParValue */
/*----------------------------------------------------------------------------*/
static void verifyParName( char *name_in, int index, char par[MAX_PAR_LEN+1] ) {

	int	i,
		parnum ;
	char	*p = malloc( ( 1 + strlen( name_in ) ) * sizeof( char ) ) ;
	
	if( sscanf( name_in, "%s", p ) != EOF ) {
		strncpy( par, p, MAX_PAR_LEN )[MAX_PAR_LEN] = '\0' ;
	} else {
		*par = '\0' ;
	}
	free( p ) ;

	if( !*par ) {
		msg( "No name entered" ) ;
	} else if( strlen( par ) != strlen( name_in ) ) {
		msg( "Name truncated" ) ;
	}

	parnum = getParNum() ;

	if( *par ) {
		/*
		 * Check that parameter name does not already exist.
		 */
		for( i = 0 ; i < parnum ; i++ ) {
			if( !strcmp( par, _par[i].name ) && index != i ) {
				char buf[100] ;
				sprintf( buf, "Name already defined : <%s>", par ) ;
				msg( buf ) ;
				*par = '\0' ;
				break ;
			}
		}
		strcpy( _par[index].name, par ) ;
	} else if( index < parnum ) {
		/*
		 * Empty name: are we deleting a parameter ? If so shrink
		 * parameter list.
		 */

		if( index < parnum -1 ) {
			for( i = index ; i < parnum ; i++ ) {
				_par[i] = _par[i+1] ;
			}
		}
		*_par[parnum - 1].name = '\0' ;
	}

} /* verifyParName */
/*----------------------------------------------------------------------------*/
static void setForRestrictedEdit( const Form form ) {

	int	i,
		parnum ;

	if( _choice != PRF_CHOICE ) return ;

	FIfld_set_mode( form, LIB, 0, FI_REVIEW ) ;
	FIfld_set_text( form, LIB, 0, 0, _lib, FALSE ) ;
	FIg_display( form, LIB ) ;

	FIfld_set_mode( form, PAR, 0, FI_REVIEW ) ;

	parnum = getParNum() ;
	FIfld_set_num_rows( form, PAR, parnum ) ;

	for( i = 0 ; i < parnum ; i++ ) {

		FIfld_set_text( form, PAR, i, 0, _par[i].name, FALSE ) ;
	}
	FIg_display( form, PAR ) ;

} /* setForRestrictedEdit */
/*----------------------------------------------------------------------------*/
static void setForFullEdit( const Form form ) {

	int	i,
		n ;

	FIfld_set_mode( form, LIB, 0, FI_INSERT ) ;
	FIg_reset( form, LIB ) ;
	FIg_display( form, LIB ) ;

	FIg_erase( form, PAR ) ;

	n = 0 ;
	if( _choice == PRF_CHOICE ) {

		strcpy( _par[n].name, "height"		) ; n++ ;
		strcpy( _par[n].name, "width"		) ; n++ ;
		strcpy( _par[n].name, "flgThickness"	) ; n++ ;
		strcpy( _par[n].name, "webThickness"	) ; n++ ;
		strcpy( _par[n].name, "fltRadius"	) ; n++ ;

	} else if( _choice == PLT_CHOICE ) {

		strcpy( _par[n].name, "thickness"	) ; n++ ;
		/*
		 * There is no library field.
		 */
		FIg_erase( form, LIB ) ;
		FIg_erase( form, LIB_TEXT ) ;

	} else fatal( "Unexpected choice" ) ;

	FIfld_set_num_rows( form, PAR, n ) ;

	for( i = 0 ; i < n ; i++ ) {
		_par[i].value = 1 ;
		FIfld_set_text ( form, PAR, i, 0, _par[i].name	, FALSE ) ;
		FIfld_set_value( form, PAR, i, 1, _par[i].value	, FALSE ) ;
	}

	for( i = n ; i < MAX_PAR_NUM ; i++ ) {
		*_par[i].name = '\0' ;
	}

	if( _choice == PRF_CHOICE ) {
		FIfld_set_mode( form, PAR, 0, FI_INSERT ) ;
	} else {
		/*
		 * The name "thickness" is fixed for plates.
		 */
		FIfld_set_mode( form, PAR, 0, FI_REVIEW ) ;
		FIfld_set_list_scroll( form, PAR, FALSE, FALSE ) ;
	}
	FIg_display( form, PAR ) ;

} /* setForFullEdit */
/*----------------------------------------------------------------------------*/
static void resetFamForm( const Form form ) {

	FIfld_set_text( form, CRE, 0, 0, _cre, FALSE ) ;
	FIfld_set_text( form, DAT, 0, 0, _dat, FALSE ) ;
	FIfld_set_text( form, DIR, 0, 0, _dir, FALSE ) ;

	setTime( form, TIM ) ;

	*_fam = *_nam = *_mat = *_lib = *_dsc = '\0' ;

	if( _choice == PLT_CHOICE ) strcpy( _lib, "tmp" ) ;

	FIg_reset( form, FAM ) ;
	FIg_reset( form, NAM ) ;
	FIg_reset( form, MAT ) ;

	FIg_reset( form, DSC ) ;

	setForFullEdit( form ) ;

	setMatList( form, MAT ) ;

	FIg_start_seq( form, FAM ) ;

} /* resetFamForm */
/*----------------------------------------------------------------------------*/
static void initFamForm( const Form form ) {

	FIf_set_initial_notification_routine( form, initialNotify ) ;

	FIfld_set_max_num_chars( form, FAM, 0, MAX_FAM_LEN ) ;
	FIfld_set_max_num_chars( form, NAM, 0, MAX_NAM_LEN ) ;
	FIfld_set_max_num_chars( form, MAT, 0, MAX_MAT_LEN ) ;
	FIfld_set_max_num_chars( form, CRE, 0, MAX_CRE_LEN ) ;
	FIfld_set_max_num_chars( form, TIM, 0, MAX_TIM_LEN ) ;
	FIfld_set_max_num_chars( form, DAT, 0, MAX_DAT_LEN ) ;
	FIfld_set_max_num_chars( form, LIB, 0, MAX_LIB_LEN ) ;
	FIfld_set_max_num_chars( form, DSC, 0, MAX_DSC_LEN ) ;

	if( _choice == PRF_CHOICE ) {
		FIfld_set_max_num_rows( form, PAR, MAX_PAR_NUM ) ;
	} else {
		/*
		 * Plates : only one parameter, the thickness.
		 */
		FIfld_set_num_vis_rows( form, PAR, 1 ) ;
		FIfld_set_max_num_rows( form, PAR, 1 ) ;
	}

	strncpy( _cre, vslogname(), MAX_CRE_LEN )[MAX_CRE_LEN] = '\0' ;

	setDate( form, DAT ) ;

	strcpy( _dir, "." ) ;

	FIg_set_next_in_seq( form, FAM, NAM ) ;
	FIg_set_next_in_seq( form, NAM, MAT ) ; 
	FIg_set_next_in_seq( form, MAT, CRE ) ;
	FIg_set_next_in_seq( form, CRE, TIM ) ;
	FIg_set_next_in_seq( form, TIM, DAT ) ;

	if( _choice == PRF_CHOICE ) {
		FIg_set_next_in_seq( form, DAT, LIB ) ;
		FIg_set_next_in_seq( form, LIB, DSC ) ;
		FIg_set_text( form, FAM_TITLE, "Add profile" ) ;
	} else {
		/*
		 * Plates : bypass LIB.
		 */
		FIg_set_next_in_seq( form, DAT, DSC ) ;
		FIg_set_text( form, FAM_TITLE, "Add plate" ) ;
	}
	FIg_set_next_in_seq( form, DSC, FAM ) ;
	FIf_set_start_seq( form, FAM ) ;

	FIg_erase( form, WARNING ) ;

	resetFamForm( form ) ;

} /* initFamForm */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
static int famNotify(	int	form_label,
			int	gadget_label,
			double	value,
			Form	form ) {

	int	sel,
		pos,
		row,
		col ;
	char	buf[1024],
		err[100],
		par[MAX_PAR_LEN] ;

#define GETTEXT( __buf ) \
	getStrippedFldText( form, gadget_label, sizeof(__buf), (__buf) )
#define PUTTEXT( __buf ) \
	FIfld_set_text( form, gadget_label, 0, 0, (__buf), FALSE )

	msg( "" ) ;

	switch( gadget_label ) {
		case FI_ACCEPT	:
		case FI_EXECUTE	: sel = writeFamDef() && writePartDef() ;
				  /* Wait_timer( 40 ) ; */
				  FIg_reset( form, gadget_label ) ;
				  if( gadget_label == FI_ACCEPT ) {
				  	if( sel ) FIf_erase( form ) ;
				  } else if( sel ) {
				  	sprintf( buf, "Data appended to %s.p",
				  		 _fam ) ;
				  	msg( buf ) ;
				  }
				  break ;

		case FI_CANCEL	: FIf_erase( form )	; break ;
		case FI_RESET	: resetFamForm( form )	; break ;
		case FAM	:
			GETTEXT( buf )	;
			if( strcmp( _fam, buf ) ) {
				strcpy( _fam, buf ) ;
				if( *buf ) {
					sprintf( buf, "%s/%s.p", _dir, _fam ) ;
				}
				FIfld_set_text( form, FIL, 0, 0, buf, FALSE ) ;

				if( _choice != PRF_CHOICE ) break ;
			
				if( *_fam ) switch( readFamDef() ) {
					case readOK		:
						setForRestrictedEdit( form ) ;
						break ;
					case nothingToRead	:
						setForFullEdit( form ) ;
						break ;
					default			:
						break ;
				}
			}
			PUTTEXT( _fam ) ;
			/* No break intentionally ... */

		case NAM	:
		PARTNAME	:
			gadget_label = NAM ;
			GETTEXT( buf )	;
			if( partIsUnique( _fam, buf ) ) {
			 	strcpy( _nam, buf ) ;
			} else {
			 	sprintf( err, "'%s' already in %s.p",
			 		 buf, _fam ) ;
			 	msg( err ) ;
			 	if( !strcmp( buf, _nam ) ) *_nam = '\0' ;
			}
			PUTTEXT( _nam ) ;
			break ;
			 
		case MAT	:
			GETTEXT( buf ) ;
			if( doesMatExist( buf ) ) {
				strcpy( _mat, buf ) ;
			} else {
				sprintf( err, "'%s' not in material.p", buf ) ;
				msg( err ) ;
				FIfld_set_text( form, gadget_label,
						0, 0, _mat, FALSE ) ;
			}
			PUTTEXT( _mat ) ;
			break ;

		case CRE	: GETTEXT( _cre ) ; PUTTEXT( _cre ) ; break ;
		case TIM	: GETTEXT( _tim ) ; PUTTEXT( _tim ) ; break ;
		case DAT	: GETTEXT( _dat ) ; PUTTEXT( _dat ) ; break ;
		case LIB	: GETTEXT( _lib ) ; PUTTEXT( _lib ) ; break ;
		case DSC	: GETTEXT( _dsc ) ; PUTTEXT( _dsc ) ; break ;
		case PAR	:

		row = (int) value ;
		if( row >= MAX_PAR_NUM ) {
			msg( "Too many parameters" ) ;
			break ;
		}
		FImcf_get_active_col( form, gadget_label, &col, &pos ) ;

		if( col == 0 ) {
			*buf = '\0' ;
			FIfld_get_text( form, gadget_label, row, col,
					sizeof buf, (unsigned char *) buf,
					&sel, &pos ) ;

			verifyParName( buf, row, par ) ;

			if( *par ) {
				FIfld_set_text( form, gadget_label, row, col,
						par, FALSE ) ;
			}

			updateParField( form ) ;

			if( row && row >= ( pos = getParNum() ) ) {
				row = pos - 1 ;
			}
/*AF: causes form to enter an endless loop ...
			FIfld_pos_cursor( form, gadget_label,
						  row, row, 0, 0, 0, 0 ) ;
*/

		} else if( col == 1 ) {
			FIfld_get_value( form, gadget_label, row, col,
					 &value, &sel, &pos ) ;
			verifyParValue( value, row, &value ) ;
			FIfld_set_value( form, gadget_label, row, col,
					 value, FALSE ) ;
		}
		break ;

		case DIR	:
			GETTEXT( buf ) ;
			if( checkDir( buf ) ) {
				strcpy( _dir, buf ) ;
				sprintf( buf, "%s/%s.p", _dir, _fam ) ;
				FIfld_set_text( form, FIL, 0, 0, buf, FALSE ) ;
				setMatList( form, MAT ) ;
			}
			PUTTEXT( _dir ) ;
			goto PARTNAME ;

		case TIME_FMT	:
			FIf_erase( form ) ;
			getTimeFormat() ;
			setTime( form, TIM ) ;
			setDate( form, DAT ) ;
			FIf_display( form ) ;
			break ;
	}

	return FI_SUCCESS ;

} /* famNotify */
/*----------------------------------------------------------------------------*/
void getFam( void ) {

	Form	form ;
	char	file[1024] ;

	sprintf( file, "%s/%s", _formdir, FAM_FORM ) ;

	if( FIf_new( 100, file, famNotify, &form ) != FI_SUCCESS ) {
		fprintf( stderr, "Cannot create form %s\n", file ) ;
	} else {
		_form = form ;
		initFamForm( form ) ;
		FIf_display( form ) ;

		FI_process_forms() ;
	}		

} /* getFam */
/*----------------------------------------------------------------------------*/

