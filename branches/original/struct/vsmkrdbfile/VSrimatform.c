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
void setMatList( const Form form, int field ) {
	
	char	materials[MAX_MATERIALS][MAX_MAT_LEN+1] ;
	int	count,
		i ;

	if( getAllMaterials( materials, &count ) ) {
		FIfld_set_list_num_rows( form, field, 0, count ) ;
		for( i = 0 ; i < count ; i++ ) {
			FIfld_set_list_text( form, field, i, 0, materials[i],
						FALSE ) ;
		}
	} else {
		int	nrows ;
		FIfld_get_list_num_rows( form, field, 0, &nrows ) ;
		for( i = 0 ; i < nrows ; i++ ) {
			FIfld_set_list_text( form, field, i, 0, "", FALSE ) ;
		}
	}		

} /* setMatList */
/*----------------------------------------------------------------------------*/
static void resetMatForm( const Form form ) {

	char	buffer[1024] ;

	FIfld_set_text( form, _CRE, 0, 0, _cre, FALSE ) ;
	FIfld_set_text( form, _DAT, 0, 0, _dat, FALSE ) ;
	FIfld_set_text( form, _DIR, 0, 0, _dir, FALSE ) ;

	setTime( form, _TIM ) ;

	*_mat = *_grd = *_dsc = '\0' ; _dst = 1 ;

	FIg_reset( form, _MAT ) ;
	FIg_reset( form, _GRD ) ;
	FIg_reset( form, _DST ) ;
	FIg_reset( form, _UNI ) ;
	FIg_reset( form, _DSC ) ;

	sprintf( buffer, "%s/material.p", _dir ) ;
	FIfld_set_text ( form, _FIL, 0, 0, buffer	, FALSE ) ;
	FIfld_set_value( form, _DST, 0, 0, _dst  	, FALSE ) ;
	strcpy( _uni, "lb/inch**3" ) ;
	FIfld_set_text ( form, _UNI, 0, 0, "lb/inch**3"	, FALSE ) ;

	setMatList( form, _MAT ) ;
	FIg_start_seq( form, _MAT ) ;

} /* resetMatForm */
/*----------------------------------------------------------------------------*/
static void initMatForm( const Form form ) {

	FIfld_set_max_num_chars( form, _MAT, 0, MAX_MAT_LEN ) ;
	FIfld_set_max_num_chars( form, _GRD, 0, MAX_GRD_LEN ) ;
	FIfld_set_max_num_chars( form, _CRE, 0, MAX_CRE_LEN ) ;
	FIfld_set_max_num_chars( form, _TIM, 0, MAX_TIM_LEN ) ;
	FIfld_set_max_num_chars( form, _DAT, 0, MAX_DAT_LEN ) ;
	FIfld_set_max_num_chars( form, _DSC, 0, MAX_DSC_LEN ) ;

	strncpy( _cre, vslogname(), MAX_CRE_LEN )[MAX_CRE_LEN] = '\0' ;

	setDate( form, DAT ) ;

	strcpy( _dir, "." ) ;

	FIg_set_next_in_seq( form, _MAT, _GRD ) ;
	FIg_set_next_in_seq( form, _GRD, _DSC ) ; 
	FIg_set_next_in_seq( form, _DSC, _CRE ) ;
	FIg_set_next_in_seq( form, _CRE, _TIM ) ;
	FIg_set_next_in_seq( form, _TIM, _DAT ) ;
	FIg_set_next_in_seq( form, _DAT, _DST ) ;
	FIg_set_next_in_seq( form, _DST, _MAT ) ;

	FIf_set_start_seq( form, _MAT ) ;

	FIg_erase( form, WARNING ) ;

	resetMatForm( form ) ;

} /* initMatForm */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
static int matNotify(	int	form_label,
			int	gadget_label,
			double	value,
			Form	form ) {

	int	sel,
		pos ;
	char	buf[1024],
		err[1024] ;

#define GETTEXT( __buf ) \
	getStrippedFldText( form, gadget_label, sizeof(__buf), (__buf) )
#define PUTTEXT( __buf ) \
	FIfld_set_text( form, gadget_label, 0, 0, (__buf), FALSE )

	msg( "" ) ;

	switch( gadget_label ) {
		case FI_RESET	: resetMatForm( form ) ; break ;
		case FI_ACCEPT	:
		case FI_EXECUTE	: sel = writeMatDef() ;
				  /* Wait_timer( 40 ) ; */
				  FIg_reset( form, gadget_label ) ;
				  if( gadget_label == FI_ACCEPT ) {
				  	if( sel ) FIf_erase( form ) ;
				  } else {
				  	if( sel ) msg( "Data appended to material.p" ) ;
				  }
				  break ;
				  
		case FI_CANCEL	: FIf_erase( form )	; break ;

		case _MAT	: GETTEXT( _mat ) ; PUTTEXT( _mat ) ;
				  /* No break intentionally */

		case _GRD	:
		GRADE		: gadget_label = _GRD ;
				  GETTEXT( buf ) ;
				  if( gradeIsUnique( buf ) ) {
				  	strcpy( _grd, buf ) ;
				  } else {
				  	sprintf( err,
				  		 "'%s' already defined in material.p",
				  		 buf ) ;
				  	msg( err ) ;
				  	if( !strcmp( buf, _grd ) ) *_grd = '\0' ;
				  }
				  PUTTEXT( _grd ) ;
				  break ;

		case _DSC	: GETTEXT( _dsc ) ; PUTTEXT( _dsc ) ; break ;
		case _CRE	: GETTEXT( _cre ) ; PUTTEXT( _cre ) ; break ;
		case _TIM	: GETTEXT( _tim ) ; PUTTEXT( _tim ) ; break ;
		case _DAT	: GETTEXT( _dat ) ; PUTTEXT( _mat ) ; break ;
		case _UNI	: GETTEXT( _uni ) ; break ;
		case _DST	: FIfld_get_value( form, gadget_label, 0, 0,
					 &value, &sel, &pos ) ;
				  if( value <= 0 ) {
				  	msg( "Density must be > 0" ) ;
				  	value = _dst ;
					FIfld_set_value( form, gadget_label,
							 0, 0, value, FALSE ) ;
				  } else {
				  	_dst = value ;
				  }
				  break ;
		
		case _DIR	:
			GETTEXT( buf ) ;
			if( checkDir( buf ) ) {
				strcpy( _dir, buf ) ;
				sprintf( buf, "%s/material.p", _dir ) ;
				FIfld_set_text( form, _FIL, 0, 0, buf, FALSE ) ;
				setMatList( form, _MAT ) ;
			}
			PUTTEXT( _dir ) ;
			goto GRADE ;
		
		case _TIME_FMT	:
			FIf_erase( form ) ;
			getTimeFormat() ;
			setTime( form, _TIM ) ;
			setDate( form, _DAT ) ;
			FIf_display( form ) ;
			break ;
	}
	return FI_SUCCESS ;

} /* matNotify */
/*----------------------------------------------------------------------------*/
void getMat( void ) {

	Form	form ;
	char	file[1024] ;

	sprintf( file, "%s/%s", _formdir, MAT_FORM ) ;

	if( FIf_new( 100, file, matNotify, &form ) != FI_SUCCESS ) {
		fprintf( stderr, "Cannot create form %s\n", file ) ;
	} else {
		_form = form ;
		initMatForm( form ) ;
		FIf_display( form ) ;

		FI_process_forms() ;
	}		

} /* getMat */
/*----------------------------------------------------------------------------*/


