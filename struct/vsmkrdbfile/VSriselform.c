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
/*ARGSUSED*/
static int selNotify(	int	form_label,
			int	gadget_label,
			double	value,
			Form	form ) {

	switch( gadget_label ) {
		case FI_ACCEPT	: FIf_erase( form )	; break ;
		case FI_CANCEL	: _choice = EXIT_CHOICE ;
				  FIf_erase( form )	; break ;
		case SEL_MAT	: _choice = MAT_CHOICE	; break ;
		case SEL_PRF	: _choice = PRF_CHOICE	; break ;
		case SEL_PLT	: _choice = PLT_CHOICE	; break ; 
	}
	return FI_SUCCESS ;

} /* selNotify */
/*----------------------------------------------------------------------------*/
int getChoice( int *choice ) {

	char	file[1024] ;
	Form	form ;

	sprintf( file, "%s/%s", _formdir, SEL_FORM ) ;

	if( FIf_new( 200, file, selNotify, &form ) != FI_SUCCESS ) {
		fprintf( stderr, "Cannot create form %s\n", file ) ;
		return FALSE ;
	}

	_choice = MAT_CHOICE ;
	FIg_set_state_on( form, SEL_MAT ) ;

	FIf_display( form ) ;

	FI_process_forms() ;

	*choice = _choice ;

	return TRUE ;

} /* getChoice */
/*----------------------------------------------------------------------------*/

