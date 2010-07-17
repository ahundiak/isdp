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
#include "vsRDBdef.h"
#include "vsridef.h"
#include "vsri.h"
#include "vsriglobals.h"
#include "vsriproto.h"
/*----------------------------------------------------------------------------*/
void stripString( char *string ) {

	/*
	 * Remove leading & trailing spaces. `stripped' is supposed to have
	 * at least the size of `string'.
	 */
	char	*start = string ;

	if( *start ) {
		char	*end ;

		while( isspace( *start ) ) start++ ;

		end = start + strlen( start ) - 1 ;

		while( isspace( *end ) ) end-- ;
		*++end = '\0' ;

		while( *string++ = *start++ ) ;
		*string = '\0' ;
	}

} /* stripString */
/*----------------------------------------------------------------------------*/
void rmDupSpaces( char *string ) {

	int	haveSpace	= FALSE ;
	char	*from		= string,
		*to		= string ;

	while( *from ) {
		if( isspace( *from ) ) {
			if( !haveSpace ) {
				*to++		= *from ;
				haveSpace	= TRUE ;
			}
		} else {
			*to++		= *from ;
			haveSpace	= FALSE ;
		}
		from++ ;
	}
	*to = '\0' ;

} /* rmDupSpaces */
/*----------------------------------------------------------------------------*/
void getStrippedFldText( const Form form, int field, int size, char *text ) {
	int	sel,
		pos ;

	FIfld_get_text( form, field, 0, 0,
			size, (unsigned char *) text, &sel, &pos ) ;

	stripString( text ) ;

	rmDupSpaces( text ) ;

} /*  getStrippedFldText */
/*----------------------------------------------------------------------------*/
int checkFamData( void ) {

	char	*t = NULL ;
	int	rc = FALSE ;

	     if( !*_fam		) { t = "Family not specified"		; }
	else if( !*_nam		) { t = "Name not specified"		; }
	else if( !*_mat		) { t = "Material not specified"	; }
	else if( !*_dat		) { t = "Date not specified"		; }
	else if( !*_tim		) { t = "Time not specified"		; }
	else if( !*_lib		) { t = "Library not specified"		; }
	else if( !getParNum()	) { t ="No parameters specified"	; }
	else rc = TRUE ;

	if( t ) msg( t ) ;

	return rc ;

} /* checkFamData */
/*----------------------------------------------------------------------------*/
int doesMatExist( const char *material ) {

	int	p_partnumLEN,
		line,
		found = FALSE ;
	char	file[1024],
		buf[1024],
		*p1		= NULL,
		*p2		= NULL ;
	FILE	*f ;

	if( !*material ) return TRUE ;

	sprintf( file, "%s/material.p", _dir ) ;

	if( access( file, R_OK ) != 0 ) return FALSE ;

	f = fopen( file, "r" ) ;

	p_partnumLEN = strlen( PDU_PARTID_ATTR ) ;
	line = 0 ;

	while( fgets( buf, 1024, f ) ) {

		line++ ;

		if( strncmp( buf, PDU_PARTID_ATTR, p_partnumLEN ) ) continue ;

		p1 = strchr( buf, '\'' ) ;
		if( p1 ) {
			p2 = strchr( p1 + 1, '\'' ) ;
		}
		if( !( p1 && p2 ) ) {
			char badFormat[30] ;

			sprintf( badFormat, "%s='<material>'", PDU_PARTID_ATTR);
			badFileFormat( file, line, badFormat, buf ) ;
			/*NOTREACHED*/
		}
		*p2 = '\0' ;
		if( !strcmp( p1 + 1, material ) ) {
			found = TRUE ;
			break ;
		}
	}
	fclose( f ) ;

	return found ;

} /* doesMatExist */
/*----------------------------------------------------------------------------*/
int getParNum( void ) {

	int i ;

	for( i = 0 ; i < MAX_PAR_NUM && *_par[i].name ; i++ ) ;

	return i ;

} /* getParNum */
/*----------------------------------------------------------------------------*/
int gradeIsUnique( const char *grade ) {

	int	p_revisionLEN,
		line ;
	char	file[1024],
		buf[1024],
		*p1	= NULL,
		*p2	= NULL ;
	FILE	*f ;

	sprintf( file, "%s/material.p", _dir ) ;

	/*
	 * material.p may not have been created yet...
	 */
	if( access( file, F_OK ) != 0 ) return TRUE ;

	if( !( f = fopen( file, "r" ) ) ) {
		sprintf( buf, "Cannot read %s", file ) ;
		fatal( buf ) ;
	}

	p_revisionLEN = strlen( PDU_REVISION_ATTR ) ;
	line = 0 ;

	while( fgets( buf, 1024, f ) ) {

		line++ ;

		if( strncmp( buf, PDU_REVISION_ATTR, p_revisionLEN ) )
			continue ;

		p1 = strchr( buf, '\'' ) ;
		if( p1 ) {
			p2 = strchr( p1 + 1, '\'' ) ;
		}
		if( !( p1 && *p1 && p2 ) ) {
			char badFormat[30] ;

			sprintf( badFormat, "%s='<grade>'", PDU_REVISION_ATTR );
			badFileFormat(	file, line, badFormat, buf ) ;
			/*NOTREACHED*/
		}
		*p2 = '\0' ;

		if( !strcmp( p1+1, grade ) ) return FALSE ;

	}
	return TRUE ;

} /* gradeIsUnique */
/*----------------------------------------------------------------------------*/
int partIsUnique( const char *family, const char *partname ) {

	int	p_partnumLEN,
		line ;
	char	file[1024],
		buf[1024],
		*p1	= NULL,
		*p2	= NULL ;
	FILE	*f ;

	if( !*family || !*partname ) return TRUE ;

	sprintf( file, "%s/%s.p", _dir, family ) ;

	/*
	 * <family>.p may not have been created yet...
	 */
	if( access( file, F_OK ) != 0 ) return TRUE ;

	if( !( f = fopen( file, "r" ) ) ) {
		sprintf( buf, "Cannot read %s", file ) ;
		fatal( buf ) ;
	}

	p_partnumLEN = strlen( PDU_PARTID_ATTR ) ;
	line = 0 ;

	while( fgets( buf, 1024, f ) ) {

		line++ ;

		if( strncmp( buf, PDU_PARTID_ATTR, p_partnumLEN ) ) continue ;

		p1 = strchr( buf, '\'' ) ;
		if( p1 ) {
			p2 = strchr( p1 + 1, '\'' ) ;
		}
		if( !( p1 && *p1 && p2 ) ) {
			char badFormat[30] ;

			sprintf( badFormat, "%s='<part name>'",
				 PDU_PARTID_ATTR ) ;
			badFileFormat( file, line, badFormat, buf ) ;
			/*NOTREACHED*/
		}
		*p2 = '\0' ;

		if( !strcmp( p1+1, partname ) ) return FALSE ;

	}
	return TRUE ;

} /* partIsUnique */
/*----------------------------------------------------------------------------*/
int checkMatData( void ) {

	int	rc	= FALSE ;
	char	*t	= NULL,
		err[200] ;

	     if( !*_mat		) { t = "Material not specified"	; }
	else if( !*_grd		) { t = "Grade not specified"		; }
	else if( !*_dat		) { t = "Date not specified"		; }
	else if( !*_tim		) { t = "Time not specified"		; }
	else if( !*_uni		) { t = "Density unit not specified"	; }
	else if( _dst < 0	) { t = "Density not specified"		; }
	else if( !gradeIsUnique( _grd ) ) {
		sprintf( err, "'%s' already defined in material.p", _grd ) ;
		t = err ;
	} else rc = TRUE ;

	if( t ) msg( t ) ;

	return rc ;

} /* checkMatData */
/*----------------------------------------------------------------------------*/

