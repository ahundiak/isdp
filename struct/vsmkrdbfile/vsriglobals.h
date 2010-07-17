/*
	I/STRUCT

	File dependency :	vsridef.h
				vsri.h
*/
#ifndef vsriglobals_include
#	define vsriglobals_include

#ifdef DECLARE_GLOBALS
#	define STORAGE
#	define ASSIGN( x )	= x
#else
#	define STORAGE extern
#	define ASSIGN( x )
#endif

STORAGE
char		_fam[MAX_FAM_LEN+1]	ASSIGN( "" ),
		_nam[MAX_NAM_LEN+1]	ASSIGN( "" ),
		_mat[MAX_MAT_LEN+1]	ASSIGN( "" ),
		_cre[MAX_CRE_LEN+1]	ASSIGN( "" ),
		_dat[MAX_DAT_LEN+1]	ASSIGN( "" ),
		_tim[MAX_TIM_LEN+1]	ASSIGN( "" ),
		_lib[MAX_LIB_LEN+1]	ASSIGN( "" ),
		_dsc[MAX_DSC_LEN+1]	ASSIGN( "" ),
		_grd[MAX_GRD_LEN+1]	ASSIGN( "" ),
		_uni[MAX_UNI_LEN+1]	ASSIGN( "" ),
		_dir[1024]		ASSIGN( "" ),
		_formdir[1024]		ASSIGN( "" ),
		_dateformat[20]		ASSIGN( "%e %b %Y" ),
		_timeformat[20]		ASSIGN( "%H:%M:%S" ) ;

STORAGE
double		_dst			ASSIGN( 1  ) ;

STORAGE
struct PARDEF	_par[MAX_PAR_NUM] ;

STORAGE
Form		_form			ASSIGN( NULL ) ;

STORAGE
int		_choice			ASSIGN( EXIT_CHOICE ) ;

#endif
