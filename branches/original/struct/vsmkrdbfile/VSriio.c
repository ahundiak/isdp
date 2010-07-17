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
int findLanguage( const char *EXNUCdir, char *language ) {

	int	rc ;
	char	languageFile[1024] ;
	FILE	*f ;

	*language = '\0' ;

	sprintf( languageFile, "%s/config/language", EXNUCdir ) ;
	if( f = fopen( languageFile, "r" ) ) {

		rc = fscanf( f, "%s", language ) > 0 && *language ;
	} else {
		fprintf( stderr, "Cannot open <EXNUC dir>/config/language\n" ) ;
		rc = 0 ;
	}

	return rc ;

} /* findLanguage */
/*----------------------------------------------------------------------------*/
int checkDir( const char *directory ) {

	int		rc = FALSE ;
	struct stat	buf ;
	char		err[1024] ;

	if( stat( directory, &buf ) == -1 ) {
		sprintf( err, "%s : %s", sys_errlist[errno], directory ) ;
		msg( err ) ;
	} else if( !S_ISDIR( buf.st_mode ) ) {
		sprintf( err, "Not a directory : %s", directory ) ;
		msg( err ) ;
	} else if( !(     getuid() == buf.st_uid && ( buf.st_mode & S_IWUSR )
		      ||  getgid() == buf.st_gid && ( buf.st_mode & S_IWGRP )
		      ||  ( buf.st_mode & S_IWOTH ) ) ) {
		sprintf( err, "Directory is not writable : %s", directory ) ;
		msg( err ) ;
	} else rc = TRUE ;

	return rc ;

} /* checkDir */
/*----------------------------------------------------------------------------*/
enum READRC readFamDef( void ) {

	int		i,
			j,
			n_catalognameLEN,
			n_cofilenameLEN,
			line ;
	char		dot_f[1024],
			err[1024],
			buf[BUFSIZ],
			fam[100],
			lib[100],
			*p ;
	FILE		*f ;
	struct PARDEF	par[MAX_PAR_NUM] ;

	sprintf( dot_f, "%s/%s.f", _dir, _fam ) ;

	/*
	 * Family definition file may be not yet created.
	 */
	if( access( dot_f, R_OK ) != 0 ) {
		return nothingToRead ;
	}

	if( !( f = fopen( dot_f, "r" ) ) ) {
		sprintf( err, "Cannot read %s", dot_f ) ;
		msg( err ) ;
		return readError ;
	}

	/*
	 * We are looking for the library name and the parameter names.
	 */
	i	= 0 ;
	*fam	= '\0' ;
	*lib	= '\0' ;

	n_catalognameLEN 	= strlen( PDU_NFM_CATALOG_NAME ) ;
	n_cofilenameLEN		= strlen( PDU_FILENAME_ATTR ) ;

	line = 0 ;
	while( fgets( buf, BUFSIZ, f ) ) {

		line++ ;

		if( !strncmp( buf, PDU_NFM_CATALOG_NAME, n_catalognameLEN ) ) {

			p = strchr( buf, '=' ) ;

			if( !( p && *(p+1) ) ) {
				char badFormat[50] ;

				sprintf( badFormat, "%s(char[12])=<family>",
					  PDU_NFM_CATALOG_NAME ) ;
				badFileFormat( dot_f, line, badFormat, buf ) ;
				/*NOTREACHED*/
			}
			sscanf( p + 1, "%s", fam ) ;

		} else if( !strncmp( buf, PDU_FILENAME_ATTR,
				     n_cofilenameLEN ) ) {

			p = strchr( buf, '/' ) ;

			if( !( p && *(p+1) ) ) {
				char badFormat[50] ;

				sprintf( badFormat, "%s(char[14])=<library>",
					 PDU_FILENAME_ATTR ) ;

				badFileFormat( dot_f, line, badFormat, buf ) ;
				/*NOTREACHED*/
			}
			sscanf( p + 1, "%s", lib ) ;

		} else if( !strncmp( buf, "p_s", 3 ) ) {

			char	*p1,
				*p2,
				*p ;

			p1 = strchr( buf, '|' ) ;
			p2 = p1 ? strchr( p1 , '(' ) : NULL ;

			if( !( p1 && *(p1+1) && p2 && *(p2+1) ) ) {
				badFileFormat(	dot_f,
						line,
					 	"p_s<N>|<parameter>(double)=...",
						buf ) ;
				/*NOTREACHED*/
			}

			for(	j = 0, p = p1 + 1 ;
				p < p2 && j < MAX_PAR_LEN ;
				j++, p++ ) {
				par[i].name[j] = *p ;
			}
			par[i].name[j]	= '\0' ;

			i++ ;			
		}
	}

	fclose( f ) ;

	if( !*fam ) {
		sprintf( buf, "Cannot find family in %s\n", dot_f ) ;
		msg( buf ) ;
		return missingItem ;
	}

	if( strcmp( fam, _fam ) ) {
		sprintf( buf, "Bad family <%s> in %s\n", fam, dot_f ) ;
		msg( buf ) ;
		return missingItem ;
	}

	if( !*lib ) {
		sprintf( buf, "Cannot find library in %s\n", dot_f ) ;
		msg( buf ) ;
		return missingItem ;
	}

	if( !i ) {
		sprintf( buf, "Cannot find parameter names in %s\n", dot_f ) ;
		msg( buf ) ;
		return missingItem ;
	}

	strncpy( _fam, fam, MAX_FAM_LEN )[MAX_FAM_LEN] = '\0' ;
	strncpy( _lib, lib, MAX_LIB_LEN )[MAX_LIB_LEN] = '\0' ;

	for( j = 0 ; j < i ; j++ ) {
		_par[i] = par[i] ;
	}
	for( j = i ; j < MAX_PAR_NUM ; j++ ) {
		*_par[i].name	= '\0' ;
	}
		
	return readOK ;
		
} /* readFamDef */
/*----------------------------------------------------------------------------*/
int writeFamDef( void ) {

	int	i,
		n,
		parnum ;
	char	dot_f[1024],
		err[1024] ;
	FILE	*f ;

	if( !checkFamData() ) return FALSE ;

	sprintf( dot_f, "%s/%s.f", _dir, _fam ) ;

	/*
	 * Family definition file already created, do not overwrite it.
	 */
	if( access( dot_f, F_OK ) == 0 ) {
		return TRUE ;
	}

	if( !( f = fopen( dot_f, "w" ) ) ) {
		sprintf( err, "Cannot write %s", dot_f ) ;
		msg( err ) ;
		return FALSE ;
	}

	fprintf( f, "[\n" ) ;
	fprintf( f, "%s(char[%d])=%s\n",
		    PDU_NFM_CATALOG_NAME, MAX_FAM_LEN, _fam ) ;
	fprintf( f, "%s(char[100])=Parametric Catalog for %s\n",
		    NFM_CATALOGDESC, _fam ) ;

	if( _choice == PRF_CHOICE ) {
		fprintf( f, "%s(char[%d])=struct/%s\n",
			    PDU_FILENAME_ATTR, MAX_LIB_LEN, _lib ) ;
		fprintf( f, "p_d1|coor_sys(referential)=coor_sys\n" ) ;
		fprintf( f, "p_o2|interference(curve)=interference\n" ) ;
		fprintf( f, "p_o3|schematic(curve)=schematic\n" ) ;
		fprintf( f, "p_o4|without_fillet(curve)=without_fillet\n" ) ;
		fprintf( f, "p_o5|with_fillet(curve)=with_fillet\n" ) ;
	} else {
		fprintf( f, "%s(char[%d])=%s\n",
			    PDU_FILENAME_ATTR, MAX_LIB_LEN, _lib ) ;
	}

	fprintf( f, "p_u0|%s(char[%d])=Part Number\n",
					PDU_PARTID_ATTR,	MAX_NAM_LEN ) ;
	fprintf( f, "p_u0|%s(char[%d])=Material\n",
					PDU_REVISION_ATTR,	MAX_MAT_LEN ) ;
	fprintf( f, "p_u0|%s(char[%d])=Part Description\n",
					PDU_PARTDESC,		MAX_DSC_LEN ) ;
	fprintf( f, "p_u0|%s(char[%d])=CREATED BY\n",
					NFM_CREATOR,		MAX_CRE_LEN ) ;
	fprintf( f, "p_u0|%s(char[%d])=Part Creation Date\n",
					PDU_CREATIONDATE,	MAX_DAT_LEN ) ;

/* Creation time removed from PDM 2.1 ...
	fprintf( f, "p_u0|%s(char[%d])=Part Creation Time\n",
					PDU_CREATIONTIME,	MAX_TIM_LEN ) ;
   --- */

	fprintf( f, "p_u0|%s(char[1])=Part Type\n",
						PDU_PARTTYPE_ATTR ) ;

	if( _choice == PRF_CHOICE ) {
		parnum = getParNum() ;
		for( i = 0, n = 8 ; i < parnum ; i++, n++ ) {

			fprintf( f, "p_s%d|%s(double)=%s\n",
				     n, _par[i].name, _par[i].name ) ;
		}
	} else {
		fprintf( f, "p_u0|thickness(char[10])=thickness\n" ) ;
	}

	fprintf( f, "p_f0|%s(char[%d])=Local File Name\n",
		    PDU_FILENAME_ATTR, MAX_LIB_LEN ) ;
	fprintf( f, "]\n" ) ;

	fclose( f ) ;

	return TRUE ;

} /* writeFamDef */
/*----------------------------------------------------------------------------*/
int IsAlreadyInMatAndFam( void ) {

	char	dot_p[1024],
		buf[BUFSIZ] ;
	FILE	*f ;
	int	partid_attrLEN ;
	int	revision_attrLEN ;
	int	line ;
	char	*p = NULL ;
	char	mat[100] ;
	char	fam[100] ;

	sprintf( dot_p, "%s/mat_and_fam.p", _dir ) ;
	if(  !( f = fopen( dot_p, "r" ) ) ) {
		/*
		 * If you cannot read it it probably has not been created.
		 */
		return FALSE ;
	}
	partid_attrLEN	= strlen( PDU_PARTID_ATTR ) ;
	revision_attrLEN= strlen( PDU_REVISION_ATTR ) ;

	line = 0 ;
	*fam = '\0' ;
	*mat = '\0' ;
	while( fgets( buf, BUFSIZ, f ) ) {
		line++ ;
		if( !strncmp( buf, PDU_PARTID_ATTR, partid_attrLEN ) ) {
			p = strchr( buf, '=' ) ;
			if( !( p && *(p+1) ) ) {
				char badFormat[50] ;
				sprintf( badFormat, "%s='<material>'\n",
					 PDU_PARTID_ATTR ) ;
				badFileFormat( dot_p, line, badFormat , buf ) ;
				/*NOTREACHED*/
			}
			sscanf( p + 1, "'%s", mat ) ;
			mat[strlen(mat)-1] = '\0' ; /* remove trailing ' */

		} else if( !strncmp( buf, PDU_REVISION_ATTR, revision_attrLEN ) ) {
			p = strchr( buf, '=' ) ;
			if( !( p && *(p+1) ) ) {
				char badFormat[50] ;
				sprintf( badFormat, "%s='<family>'\n",
					 PDU_REVISION_ATTR ) ;
				badFileFormat( dot_p, line, badFormat , buf ) ;
				/*NOTREACHED*/
			}
			sscanf( p + 1, "'%s'", fam ) ;
			fam[strlen(fam)-1] = '\0' ; /* remove trailing ' */

		}
		if( *fam && *mat ) {
			if( !strcmp( fam, _fam ) && !strcmp( mat, _mat ) ) {
				fclose( f ) ;
				return TRUE ;
			}
			*fam = *mat = '\0' ;
		}
	}
	fclose( f ) ;
	return FALSE ;

} /* IsAlreadyInMatAndFam */
/*----------------------------------------------------------------------------*/
int writePartDef( void ) {

	int	i,
		parnum ;
	char	dot_p[1024],
		err[1024] ;
	FILE	*f ;

	if( !checkFamData() ) return FALSE ;

	sprintf( dot_p, "%s/%s.p", _dir, _fam ) ;

	if( !( f = fopen( dot_p, "a" ) ) ) {
		sprintf( err, "Cannot write %s", dot_p ) ;
		msg( err ) ;
		return FALSE ;
	}

	fprintf( f, "[\n" ) ;
	fprintf( f, "%s=%s\n"	, PDU_NFM_CATALOG_NAME	, _fam ) ;
	fprintf( f, "%s='%s'\n"	, PDU_PARTID_ATTR	, _nam ) ;
	fprintf( f, "%s='%s'\n"	, PDU_REVISION_ATTR	, _mat ) ;
	fprintf( f, "%s='%s'\n"	, PDU_PARTDESC		, _dsc ) ;
	fprintf( f, "%s='%s'\n"	, NFM_CREATOR		, _cre ) ;
	fprintf( f, "%s='%s'\n"	, PDU_CREATIONDATE	, _dat ) ;

/* Creation time removed from PDM 2.1 ...
	fprintf( f, "%s='%s'\n"	, PDU_CREATIONTIME	, _tim ) ;
   --- */

	if( _choice == PRF_CHOICE ) {
		fprintf( f, "%s='P'\n", PDU_PARTTYPE_ATTR ) ;

		parnum = getParNum() ;
		for( i = 0 ; i < parnum ; i++ ) {
			fprintf( f, "%s=%g\n", _par[i].name, _par[i].value ) ;
		}

	} else {
		/*
		 * Plates.
		 */
		fprintf( f, "%s='N'\n", PDU_PARTTYPE_ATTR ) ;
		fprintf( f, "%s='%g'\n", _par[0].name, _par[0].value ) ;
	}
	fprintf( f, "%s='%s'\n", PDU_FILENAME_ATTR, _lib ) ;
	fprintf( f, "]\n" ) ;

	fclose( f ) ;

	if( IsAlreadyInMatAndFam() ) return TRUE ;

	/*
	 * Add to mat_and_fam.p
	 */
	sprintf( dot_p, "%s/mat_and_fam.p", _dir ) ;

	if( !( f = fopen( dot_p, "a" ) ) ) {
		sprintf( err, "Cannot write %s", dot_p ) ;
		msg( err ) ;
		return FALSE ;
	}

	fprintf( f, "[\n" ) ;
	fprintf( f, "%s=mat_and_fam\n"	, PDU_NFM_CATALOG_NAME     	) ;
	fprintf( f, "%s='%s'\n"		, PDU_PARTID_ATTR	, _mat	) ;
	fprintf( f, "%s='%s'\n"		, PDU_REVISION_ATTR	, _fam	) ;
	fprintf( f, "%s=''\n"		, PDU_PARTDESC			) ;
	fprintf( f, "%s='%s'\n"		, NFM_CREATOR		, _cre	) ;
	fprintf( f, "%s='%s'\n"		, PDU_CREATIONDATE	, _dat	) ;

/* Creation time removed from PDM 2.1 ...
	fprintf( f, "%s='%s'\n"		, PDU_CREATIONTIME	, _tim	) ;
   --- */

	fprintf( f, "%s=''\n"		, PDU_PARTTYPE_ATTR		) ;
	if( _choice == PRF_CHOICE ) {
		fprintf( f, "vs_type='cross_section'\n"		) ;
	} else {
		fprintf( f, "vs_type='plate'\n"			) ;
	}
	fprintf( f, "%s='tmp'\n", PDU_FILENAME_ATTR ) ;
	fprintf( f, "]\n" ) ;

	fclose( f ) ;

	return TRUE ;
	
} /* writePartDef */
/*----------------------------------------------------------------------------*/
int writeMatDef( void ) {

	char	dot_p[1024],
		err[1024],
		unitCode = '?' ;
	FILE	*f ;

	if( !checkMatData() ) return FALSE ;

	sprintf( dot_p, "%s/material.p", _dir, _fam ) ;

	if( !( f = fopen( dot_p, "a" ) ) ) {
		sprintf( err, "Cannot write %s", dot_p ) ;
		msg( err ) ;
		return FALSE ;
	}

	if( !strcmp( _uni, "g/cm**3" ) ) {
		unitCode = 'm' ;
	} else if( !strcmp( _uni, "kg/m**3" ) ) {
		unitCode = 'M' ;
	} else if( !strcmp( _uni, "lb/inch**3" ) ) {
		unitCode = 'e' ;
	} else if( !strcmp( _uni, "lb/ft**3" ) ) {
		unitCode = 'E' ;
	} else {
		sprintf( err, "Unknown density unit : <%s>", _uni ) ;
		fatal( err ) ;
		/*NOTREACHED*/
	}
	fprintf( f, "[\n" ) ;
	fprintf( f, "%s=material\n"	, PDU_NFM_CATALOG_NAME		) ;
	fprintf( f, "%s='%s'\n"		, PDU_PARTID_ATTR	, _mat	) ;
	fprintf( f, "%s='%s'\n"		, PDU_REVISION_ATTR	, _grd	) ;
	fprintf( f, "%s='%s'\n"		, PDU_PARTDESC		, _dsc	) ;
	fprintf( f, "%s='%s'\n"		, NFM_CREATOR		, _cre	) ;
	fprintf( f, "%s='%s'\n"		, PDU_CREATIONDATE	, _dat	) ;

/* Creation time removed from PDM 2.1 ...
	fprintf( f, "%s='%s'\n"		, PDU_CREATIONTIME	, _tim	) ;
   --- */

	fprintf( f, "%s='G'\n"		, PDU_PARTTYPE_ATTR		) ;
	fprintf( f, "density=%g\n"				, _dst	) ;
	fprintf( f, "unit='%c'\n"				, unitCode ) ;
	fprintf( f, "%s='tmp'\n"	, PDU_FILENAME_ATTR		) ;
	fprintf( f, "]\n" ) ;

	fclose( f ) ;

	return TRUE ;
	
} /* writeMatDef */
/*----------------------------------------------------------------------------*/
int getAllMaterials(	char	materials[MAX_MATERIALS][MAX_MAT_LEN+1],
			int	*count ) {

	int	i,
		p_partnumLEN,
		line,
		dontHaveIt ;
	char	dot_p[1024],
		buf[1024],
		*p1	= NULL,
		*p2	= NULL ;
	FILE	*f ;

	*count = 0 ;

	sprintf( dot_p, "%s/material.p", _dir, _fam ) ;

	/*
	 * material.p may be not yet created.
	 */
	if( access( dot_p, R_OK ) != 0 ) {
		return TRUE ;
	}

	if( !( f = fopen( dot_p, "r" ) ) ) {
		sprintf( buf, "Cannot read %s", dot_p ) ;
		msg( buf ) ;
		return FALSE ;
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
		if( !( p1 && p2 ) ) {
			char badFormat[30] ;

			sprintf( badFormat, "%s='<material>'", PDU_PARTID_ATTR);
			badFileFormat( dot_p, line, badFormat, buf ) ;
			/*NOTREACHED*/
		}
		*p2 = '\0' ; p1++ ;

		dontHaveIt = TRUE ;
		for( i = 0 ; i < *count ; i++ ) {
			if( !strcmp( p1, materials[i] ) ) {
				dontHaveIt = FALSE ; break ;
			}
		}
		if( dontHaveIt ) {
			strncpy( materials[*count],
				 p1,
				 MAX_MAT_LEN )[MAX_MAT_LEN] = '\0' ;
			(*count)++ ;
		}
	}
	fclose( f ) ;

	return *count != 0 ;

} /* getAllMaterials */
/*----------------------------------------------------------------------------*/

