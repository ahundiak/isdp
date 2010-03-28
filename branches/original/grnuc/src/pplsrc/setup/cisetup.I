/* -- Command Interpreter Setup Form Handler.
   -- */
class implementation COcisetup ;
/*----------------------------------------------------------------------------*/
#	include "OMminimum.h"
#	include "OMerrordef.h"
#	include "igrtypedef.h"
#	include "ex.h"
#	include "exdef.h"
#	include "exmacros.h"
#	include "FI.h"
#	include "cimsg.h"
#	include <string.h>
#	include <malloc.h>
#	include <sys/types.h>
#	include <sys/stat.h>
#	include <unistd.h>
#	define CISETUP_MODULE
#	include "cisetup.h"
/*----------------------------------------------------------------------------*/
/* -- Compiler options. ( Variables private to this module ).
   -- */
%safe
static char	CInowarnin = TRUE	, CInoptrchk = FALSE	,
		CInoargchk = FALSE	, CIexternfn = FALSE	,
		CIunusedfn = FALSE	, CInoprepro = FALSE	;
%endsafe
/* -- Max number of chars which will be read from each line of CISETUP file.
   -- */
#define MAXBYTES	(CI_PATH_MAX + 1 + 20) /* 20 for "<option>=" */
typedef char iobuf[MAXBYTES] ;
/* -- Structure containing form's options.
   -- */
typedef struct {
	char		nowarnin, noptrchk, noargchk, externfn, unusedfn, noprepro,
			ninclude, dynamics, gdisplay, messages, eroutput,
			trapsigs,
			*includes[MAXINCDIRS]	,
			src_path[CIPATHLEN+1]	;
	UNIXpath	prepronm, previous ;
	short		stop_chk ;
} options ;

/*----------------------------------------------------------------------------*/
extern char	 CS_path_name[];
extern char	*CIfm_cut_path(), *CIexmessage(), *getenv();
extern void	CIsu_upd_current();
/*----------------------------------------------------------------------------*/
int CIsu_get_path( rel, abs ) char *rel ; UNIXpath abs ; {

/* -- Gets a full path from a relative path, searching through the standard
      paths of the product.
      RETURNS: TRUE if found else FALSE
   -- */
	int index, len, max ;

#ifdef DEBUG
  printf( "CIsu_get_path: ENTER(%s)\n", rel ) ; fflush( stdout ) ;
#endif
	for( index = 0 ;; index++ ) {
		if( ex$get_path(	index	= index		,
					path	= abs		,
					len	= 1 + CI_PATH_MAX	) ) {
#ifdef DEBUG
  printf( "CIsu_get_path: %d abs(%s)\n", index, abs ) ; fflush( stdout ) ;
#endif
			len	= strlen( abs )		;
			max	= CI_PATH_MAX - len	; 
			strncpy( abs + len, rel, max )[max] = '\0' ;
#ifdef DEBUG
  printf( "CIsu_get_path: %d abs(%s)\n", max, abs ) ; fflush( stdout ) ;
#endif
			if( access( abs, R_OK ) == 0 ) break ;
		} else { *abs = '\0' ; break ; }
	}
#ifdef DEBUG
  printf( "CIsu_get_path: EXIT(%s)\n", abs ) ; fflush( stdout ) ;
#endif
	return *abs != '\0' ;

} /* CIsu_get_path */
/*----------------------------------------------------------------------------*/
char *CIsu_read() {


/* -- Reads CI setup shell variables.
      RETURNS : status of operation.
   -- */

#define GET( name, format, value )	\
	if( str = getenv( name ) ) sscanf( str, format, value )

	char		*str, *msg, *getenv(), *inc	;
	int		i				;
	iobuf		opt, var			;

	msg		= NULL ;
	CIsrc_path[0]	= '\0' ;
	
	GET( "Xnoptrchk"	, "%d"	, &i	) ;
	if( str ) CInoptrchk = i != FALSE ;
	
	GET( "Xexternfn"	, "%d"	, &i	) ;
	if( str ) CIexternfn = i != FALSE ;

	GET( "Xnoargchk"	, "%d"	, &i	) ;
	if( str ) CInoargchk = i != FALSE ;

	GET( "Xunusedfn"	, "%d"	, &i	) ;
	if( str ) CIunusedfn = i != FALSE ;

	GET( "silent"		, "%d"	, &i	) ;
	if( str ) CInowarnin = i != FALSE ;

	GET( "trapsigs"		, "%d"	, &i	) ;
	if( str ) CItrapsigs = i != FALSE ;

	GET( "display"		, "%d"	, &i	) ;
	if( str ) CIgdisplay = i != FALSE ;

	GET( "dynamics"		, "%d"	, &i	) ;
	if( str ) CIdynamics = i != FALSE ;

	GET( "messages"		, "%d"	, &i	) ;
	if( str ) CImessages = i != FALSE ;

	GET( "eroutput"		, "%d"	, &i	) ;
	if( str ) CIeroutput = i ? 1 : 0 ;

	GET( "stop_period"	, "%d"	, &i	) ;
	if( str ) if( i < 0 || i > 999 )	CIstop_chk = 20 ;
		  else				CIstop_chk = i  ;

	GET( "preprocessing"	, "%d"	, &i	) ;
	if( str ) CInoprepro = i == FALSE ;

	GET( "preprocessor"	, "%s"	, opt	) ;
	if( str ) strcat( strcpy( CIprepronm, "-p" ), opt ) ;

/* --	Look for "src_path1", "src_path2", ...
   -- */
	for( i = 1 ; ; i++ ) {
		sprintf( var, "src_path%d", i ) ;
		GET( var, "%s", opt )		;

		if( !str ) break ;

		if(   strlen( opt )
		    + strlen( CIsrc_path )
		    + 1 /* for ':' */ <= CIPATHLEN ) {
				strcat( CIsrc_path, opt ) ;
				strcat( CIsrc_path, ":" ) ;
#ifdef DEBUG
  printf( "CIPATH=%s\n", CIsrc_path ) ;
#endif
		}
	} /* for */

/* --	Look for "include1", "include2", ...
   -- */
	CIninclude = 0		;
	inc	   = CIincludes	;

	for( i = 1 ; ; i++ ) {
		sprintf( var, "include%d", i )	;
		GET( var, "%s", opt )		;

		if( !str ) break ;

		if( CIninclude <= MAXINCDIRS ) {
			sprintf( inc, "-I%s ", opt ) ;
			inc += strlen( opt ) + 3 ; /* "-I" & ' ' */
#ifdef DEBUG
  printf( "include=%s\n", opt ) ;
#endif
			CIninclude++ ;
		} else {
			msg = (char *)CIexmessage( CI_W_suIDIROV ) ;
			break ;
		}
	} /* for */

	return msg ;

} /* CIsu_read */
/*----------------------------------------------------------------------------*/
char *CIiniopt() {

/* --
      NOTE: CIprevious updated in COci.execute.
   -- */
	char		*msg		;
	int		nopt		;
	extern char	*exefile()	;

#ifdef DEBUG
 printf( "CIiniopt: ENTER\n" ) ; fflush( stdout ) ;
#endif
	CItrapsigs	= TRAPSIGSdef	;
	CIdynamics	= DYNAMICSdef	;
	CIgdisplay	= GDISPLAYdef	;
	CImessages	= MESSAGESdef	;
	CIeroutput	= EROUTPUTdef	;
	CIstop_chk	= STOP_CHKdef	;
	*CIcci_path	= '\0'		;
	*CIprevious	= '\0'		;
	*CIprepronm	= '\0'		;
	*CIsrc_path	= '\0'		;
	*CIincludes	= '\0'		;
	CIninclude	= 0		;

	msg = CIsu_read() ;

/* -- Fill values not set in file CISETUP.
   -- */
	if( ! *CIprepronm ) {
		CIsu_get_path( OMCPP_REL_PATH, CIprepronm + 2 ) ;
		CIprepronm[0] = '-' ;
		CIprepronm[1] = 'p' ;
/* ERASE
		sprintf( CIprepronm, "-p%sige/om/bin/omcpp", CS_path_name ) ;
end ERASE */
	}
#ifdef DEBUG
 printf( "CIiniopt: after init CIprepronm\n" ) ; fflush( stdout ) ;
#endif
	if( !*CIcci_path ) {
		CIsu_get_path( CCI_REL_PATH, CIcci_path ) ;
}
#ifdef DEBUG
 printf( "CIiniopt: after init CIcci_path\n" ) ; fflush( stdout ) ;
#endif
	if( !CIninclude ) {
		CIsu_get_path( PPL_INC_REL_PATH, CIincludes + 2 ) ;
		CIincludes[0] = '-' ;
		CIincludes[1] = 'I' ;
/* ERASE
  		sprintf( CIincludes, "-I%s%s",
	 			     CS_path_name, "draft/ppl/include" ) ;
end ERASe */
		CIninclude = 1 ;
	}
#ifdef DEBUG
 printf( "CIiniopt: after init CIincludes\n" ) ; fflush( stdout ) ;
#endif

	nopt = 0 ;
	if( CInowarnin ) CIcciargs[nopt++] = "-s"		;
	if( CInoptrchk ) CIcciargs[nopt++] = "-Xnoptrchk"	;
	if( CInoargchk ) CIcciargs[nopt++] = "-Xnoargchk"	;
	if( CIexternfn ) CIcciargs[nopt++] = "-Xexternfn"	;
	if( CIunusedfn ) CIcciargs[nopt++] = "-Xunusedfn"	;
	if( CInoprepro ) CIcciargs[nopt++] = "-P"		;

	CIcciargs[nopt++] = CIincludes	;
	CIcciargs[nopt  ] = NULL	;

#ifdef DEBUG
 printf( "CIiniopt: EXIT\n" ) ; fflush( stdout ) ;
#endif
	return msg ;
} /* CIiniopt */
/*----------------------------------------------------------------------------*/
void CIputopt( O ) options *O ; {

	int nopt = 0, i, len ;

#ifdef DEBUG
 printf( "CIputopt: EXIT\n" ) ; fflush( stdout ) ;
#endif
	if( CInowarnin = O->nowarnin ) CIcciargs[nopt++] = "-s"		;
	if( CInoptrchk = O->noptrchk ) CIcciargs[nopt++] = "-Xnoptrchk"	;
	if( CInoargchk = O->noargchk ) CIcciargs[nopt++] = "-Xnoargchk"	;
	if( CIexternfn = O->externfn ) CIcciargs[nopt++] = "-Xexternfn"	;
	if( CIunusedfn = O->unusedfn ) CIcciargs[nopt++] = "-Xunusedfn"	;
	if( CInoprepro = O->noprepro ) CIcciargs[nopt++] = "-P"		;

	strcat( strcpy( CIprepronm, "-p" ), O->prepronm ) ;

	for( i = 0, *CIincludes = '\0', len = 0 ; i < O->ninclude ; i++ ) {
		len += 3			; if( len > CI_PATH_MAX ) break ;
		strcat( CIincludes, "-I"	) ;
		len += strlen( O->includes[i] )	; if( len > CI_PATH_MAX ) break ;
		strcat( CIincludes, O->includes[i]	) ;
		len += 1			; if( len > CI_PATH_MAX ) break ;
		strcat( CIincludes, " "		) ;
	}
	if( *CIincludes ) CIcciargs[nopt++] = CIincludes	;

	CIcciargs[nopt  ] = NULL	;

/* --	Redisplay directories if CIPATH is new and CiSrcLs form is here.
   -- */
#ifdef DEBUG
   printf( "CIputopt: old CIPATH\n%s\nnew CIPATH %s\n", O->src_path, CIsrc_path ) ;
   printf( "CIputopt: cmp %d\n", strcmp( CIsrc_path, O->src_path ) ) ;
   printf( "CIputopt: CIls_is_form_on %d\n", CIls_is_form_on() ) ;
   fflush( stdout ) ;
#endif
	if(    strcmp( CIsrc_path, O->src_path )
	    && CIls_is_form_on()		) {
#ifdef DEBUG
   printf( "CIputopt: calling CIls_dpdir\n" ) ;; fflush( stdout ) ;
#endif
		strcpy( CIsrc_path, O->src_path )	;
	    	CIls_dpdir( TRUE, 0, 3 ) ;
	} else strcpy( CIsrc_path, O->src_path )	;
#ifdef DEBUG
   for( i = 0 ; i < nopt ; i++ ) {
   	printf( "*** <%s>\n", CIcciargs[i] ) ;
   }
   printf( "*** cipath : <%s>\n", CIsrc_path ) ;; fflush( stdout ) ;
#endif

	CIdynamics = O->dynamics	; CIgdisplay = O->gdisplay ;
	CImessages = O->messages	; CIeroutput = O->eroutput ;
	CIstop_chk = O->stop_chk	; CItrapsigs = O->trapsigs ;
#ifdef DEBUG
   printf( "CIputopt: dynamics %d, messages %d, gdisplay %d, eroutput %d, stop_chk %d\n",
   	   CIdynamics, CImessages, CIgdisplay, CIeroutput, CIstop_chk ) ;
   fflush( stdout ) ;
#endif

} /* CIputopt */
/*----------------------------------------------------------------------------*/
char *CIgetopt(	O )	options *O ; {

	register char *p, *msg = NULL ; register int i ;

/* ERASE	if( CIcci_path[0] == '\0' ) msg = CIiniopt() ; end ERASE */
#ifdef DEBUG
printf( "CIgetopt: after CIiniopt\n" ) ; fflush( stdout ) ;
#endif

	O->nowarnin = CInowarnin ;
	O->noptrchk = CInoptrchk ;
	O->noargchk = CInoargchk ;
	O->externfn = CIexternfn ;
	O->unusedfn = CIunusedfn ;
	O->noprepro = CInoprepro ;

#ifdef DEBUG
printf( "CIgetopt: nowarnin %u\n", O->nowarnin ) ; fflush( stdout ) ;
printf( "CIgetopt: noptrchk %u\n", O->noptrchk ) ; fflush( stdout ) ;
printf( "CIgetopt: noargchk %u\n", O->noargchk ) ; fflush( stdout ) ;
printf( "CIgetopt: externfn %u\n", O->externfn ) ; fflush( stdout ) ;
printf( "CIgetopt: unusedfn %u\n", O->unusedfn ) ; fflush( stdout ) ;
printf( "CIgetopt: noprepro %u\n", O->noprepro ) ; fflush( stdout ) ;
printf( "CIgetopt: prepronm %u\n", O->prepronm ) ; fflush( stdout ) ;
printf( "CIgetopt: src_path %u\n", O->src_path ) ; fflush( stdout ) ;
printf( "CIgetopt: includes %u\n", O->includes ) ; fflush( stdout ) ;
printf( "CIgetopt: ninclude %u\n", O->ninclude ) ; fflush( stdout ) ;
#endif
	strcpy( O->prepronm, CIprepronm + 2 )	;	/* Skip "-p" */
	strcpy( O->src_path, CIsrc_path     )	;
	strcpy( O->previous, CIprevious	    )	;
#ifdef DEBUG
printf( "CIgetopt: after 3 strcpy's\n" ) ; fflush( stdout ) ;
#endif
	
#ifdef DEBUG
printf( "CIgetopt: after init ext_path\n" ) ; fflush( stdout ) ;
#endif
	for( p = CIincludes, i = 0 ; *p && i < MAXINCDIRS ; ) {
		if( *p == '-' && *(p+1) == 'I' ) {
			p += 2 ;			/* Skip "-I" */
			sscanf( p, "%s", O->includes[i] ) ;
			p += strlen( O->includes[i] ) ; i++ ;
		} else p++ ;
	}
#ifdef DEBUG
printf( "CIgetopt: after init includes\n" ) ; fflush( stdout ) ;
#endif
	O->ninclude = CIninclude = i ;


	O->dynamics = CIdynamics	; O->gdisplay = CIgdisplay ;
	O->messages = CImessages	; O->eroutput = CIeroutput ;
	O->stop_chk = CIstop_chk	; O->trapsigs = CItrapsigs ;

	return msg ;

} /* CIgetopt */
/*-CI-SETUP-FORM-MANAGEMENT---------------------------------------------------*/
#define CiSetup_name	"CiSetup"
#define CiSetup_label	12345
#define CiSetup_help	"CIsetup"

#define MAXPATH		FI_X_STRLEN
#define MAXMSG		33
#define	ENDSTRING	0
/*----------------------------------------------------------------------------*/
/* -- CiSetup form gadget labels.
   -- */
enum gadget_labels	{
	QUIT_BTN =  4, EXIT_BTN =  1, NOWARNIN = 15, NOPTRCHK = 13,
	NOARGCHK = 16, EXTERNFN = 17, UNUSEDFN = 18, NOPREPRO = 19,
	INCLUDES = 21, PREPRONM = 23, CCI_PATH = 29, EXT_PATH = 31,
	SRC_PATH = 37, MSGBGRND = 47, MSG_TEXT = 24, REST_BTN =  3,
	PREVIOUS = 51, DYNAMICS = 57, GDISPLAY = 58, MESSAGES = 59,
	STOP_CHK = 64, EROUTPUT = 65, HELP_BTN =  6, RUN_BTON =  2,
	LISTFMBT = 69, WRIT_BTN = 68, SYST_DEF = 67, SVRS_BTN =  5,
	TRAPSIGS = 66, TRAPTEXT = 71
} ;
/*----------------------------------------------------------------------------*/
typedef char path[MAXPATH+1] ;
 
static Form		ci__setup				;
static char		incbuf[MAXINCDIRS * (MAXPATH+1)]	;
/* static char		extbuf[2          * (MAXPATH+1)]	; */
static options		choice					;
/*----------------------------------------------------------------------------*/
int CIsplit_path( search, paths, size )
					char	search[CIPATHLEN+1]	;
					char	**paths			;
					int	size			; {

/* -- Splits `search' path into component directories by replacing ':' with
      '\0' in the string.
      OUTPUT : search , string containing directories separated by '\0'.
                       must be of size CIPATHLEN + 1.
	       paths  , array of pointers to char pointing to the directories
                       in `cipath'. Unused elements are set to NULL.
	       size   , dimension of `paths'.
      RETURNS: TRUE.
   -- */
	char	*p	;
	int	i	;
	
	i = 0 ;
	if( *search ) {
		p = search ;
		if( *p != ':' ) paths[i++] = p ;
		while( p ) {
			p = strchr( p, ':' ) ;
			if( p ) {
				*p = '\0' ;
				if( *++p ) {
					if( i < size )	paths[i++] = p ;
				}
			}
		}
	}
	for( ; i < size ; i++ ) paths[i] = NULL ;

	return *search != '\0' ;

} /* CIsplit_path */
/*----------------------------------------------------------------------------*/
void CIsu_putenv( var, index ) char *var ; int index ; {

/* -- Puts `var' in the evironment using memory at slot `index' of array
      `Environ'. Memory must be allocated and `Environ' be static so that `var'
      remains in the environment after this procedure is exited.
     ( See putenv(3C) ). Note that the allocated memory is never freed and must
     not be for the reasons explained above.
   -- */

#define ENV_VAR_MAX (MAXINCDIRS * 2 + 10)
%safe
	static char	*Environ[ENV_VAR_MAX] = { NULL } ;
%endsafe
	int		nbytes, i			 ;

	if( index < ENV_VAR_MAX ) {
/* --		1st time, slot zero is NULL: initialize the rest.
   -- */
		if( *Environ == NULL )
			for( i = 0 ; i < ENV_VAR_MAX ; i++ ) Environ[i] = NULL ;
		nbytes = ( 1 + strlen( var ) ) * sizeof( char ) ;

		if( Environ[index] == NULL ) {
			Environ[index] = malloc( nbytes ) ;
		} else	Environ[index] = realloc( Environ[index], nbytes ) ;

		if( Environ[index] == NULL ) {
			goto MEMFAIL ;
		} else {
			if( putenv( strcpy( Environ[index], var ) ) ) {
				MEMFAIL:
				CIsu_msg( CIexmessage( CI_E_ciNOMMRY ) ) ;
			}
		}
	}

} /* CIsu_putenv */
/*----------------------------------------------------------------------------*/
char *CIsu_write() {

/* -- Write CI setup to environment and to file $HOME/.cisetup.
      RETURNS: status of operation.
   -- */

	FILE		*cisustr		;
	char		*msg, *str		;
	iobuf		var, tmp		;
	UNIXpath	cisetup			;
	int		i, nvars		;
	char		src[1+CIPATHLEN]	;
	char		*components[MAXINCDIRS]	;

#define PUT( name, format, value )			\
	sprintf( var, format, name, value )	;	\
	fprintf( cisustr, "export %s\n", var )	;	\
	CIsu_putenv( var, nvars ) ; nvars++


	*cisetup = '\0' ;
	GET( "HOME", "%s", cisetup ) ;
	strcat( strcat( cisetup, "/" ), CISETUP ) ;

	if( ( cisustr = fopen( cisetup, "w" ) ) == NULL ) {
		msg = (char *)CIexmessage( CI_W_suNOOPEN ) ;
	} else {
		nvars = 0 ;

		PUT( "Xnoptrchk"	, "%s=%d",	CInoptrchk	) ;
		PUT( "Xexternfn"	, "%s=%d",	CIexternfn	) ;
		PUT( "Xnoargchk"	, "%s=%d",	CInoargchk	) ;
		PUT( "Xunusedfn"	, "%s=%d",	CIunusedfn	) ;
		PUT( "silent"		, "%s=%d",	CInowarnin	) ;
		PUT( "preprocessing"	, "%s=%d",	!CInoprepro	) ;
		PUT( "display"		, "%s=%d",	CIgdisplay	) ;
		PUT( "trapsigs"		, "%s=%d",	CItrapsigs	) ;
		PUT( "dynamics"		, "%s=%d",	CIdynamics	) ;
		PUT( "messages"		, "%s=%d",	CImessages	) ;
		PUT( "eroutput"		, "%s=%d",	CIeroutput	) ;
		PUT( "stop_period"	, "%s=%d",	CIstop_chk	) ;
		PUT( "preprocessor"	, "%s=%s",	CIprepronm + 2	) ;

		for( i = 0 ; i < CIninclude ; i++ ) {
			sprintf( tmp, "include%d", i + 1 )	;
			PUT( tmp, "%s=%s", choice.includes[i] )	;
		}
/* --		Disable remaining variables if any.
		for( ; ; i++ ) {
			sprintf( tmp, "include%d", i + 1 )	;
			if( getenv( tmp ) ) PUT( tmp, "%s=\"\"", "" ) ;
		}
   -- */

		CIsplit_path(	strcpy( src, CIsrc_path ),
				components,
				MAXINCDIRS ) ;
		for( i = 0 ; components[i] != NULL ; i++ ) {
			sprintf( tmp, "src_path%d", i + 1 )	;
#ifdef DEBUG
  printf( "CIsu_write: PUT %s=%s\n", tmp, components[i] ) ;
#endif
			PUT( tmp, "%s=%s", components[i] )	;
		}
/* --		Disable remaining variables if any.
		for( ; ; i++ ) {
			sprintf( tmp, "src_path%d", i + 1 )	;
			if( getenv( tmp ) ) {
#ifdef DEBUG
  printf( "CIsu_write: PUT %s=\"\"\n", tmp ) ;
#endif
				PUT( tmp, "%s=\"\"", "" ) ;
			}
		}
   -- */

		fclose( cisustr )		;
		chmod( cisetup, S_IRWXU )	;

		msg = (char *)CIexmessage( CI_I_suFIWRTN ) ;

	}
	return msg ;

} /* CIsu_write */
/*----------------------------------------------------------------------------*/
int CIsu_get( gad ) struct FI_X_data_st *gad ; {

  return CIfm_get (ci__setup, gad);
}
/*----------------------------------------------------------------------------*/
int CIsu_clear()  {

/* -- Clears message area.
   -- */
  CIsu_msg( "" ) ;
  return FIg_hilite (ci__setup, MSGBGRND);
}
/*----------------------------------------------------------------------------*/
int CIsu_msg( text ) char *text ; {
	struct FI_X_data_st mess ;

	if( text != NULL ) {
		mess.type	= FI_X_ALPHA ;
		mess.label	= MSG_TEXT ;
		strcpy( mess.value.alpha, text )[MAXMSG+1] = ENDSTRING ;
		return CIfm_put( ci__setup, &mess ) ;
	} else return TRUE ;
}
/*----------------------------------------------------------------------------*/
int CIinfo_CCI_PATH()  { struct FI_X_data_st input ;

/* -- Displays path to cci executable.
   -- */
	input.type	= FI_X_ALPHA	;
	input.label	= CCI_PATH	;
	input.index	= 0		;
	strcpy( input.value.alpha, CIcci_path ) ;
	return CIfm_put( ci__setup, &input ) ;
}
/*----------------------------------------------------------------------------*/
void CIinfo_EXT_PATH()  { struct FI_X_data_st input ;

	input.type	= FI_X_ALPHA	;
	input.label	= EXT_PATH	;
	input.index	= 1		;
	strcpy( input.value.alpha, CIext_path[1] ) ;
	CIfm_put( ci__setup, &input ) ;

	input.index	= 0		;
	strcpy( input.value.alpha, CIext_path[0] ) ;
	CIfm_put( ci__setup, &input ) ;
}
/*----------------------------------------------------------------------------*/
void CIsu_put_cipath() {

	struct FI_X_data_st	gad		;
	char			tmp[CIPATHLEN+1];
	int			i		;
	char			*dirs[10]	;

/* -- Splits <dir1>:<dir2>:...:<dirn> into <dir1>, <dir2>, ..., <dirn>.
   -- */

	gad.type = FI_X_ALPHA ; gad.label = SRC_PATH ;

	CIsplit_path( strcpy( tmp, choice.src_path ), dirs, 10 ) ;
	for( i = 0 ; dirs[i] != NULL ; i++ ) {

		strncpy( gad.value.alpha, dirs[i], FI_X_STRLEN - 1 ) ;
		gad.value.alpha[FI_X_STRLEN - 1] = '\0' ;
		gad.index = i ;
#ifdef DEBUG
  printf( "CIsu_put_cipath : gad = <%s>\n", gad.value.alpha ) ;
#endif
		CIfm_put( ci__setup, &gad ) ;
	}
	FIfld_pos_cursor (ci__setup, SRC_PATH, 0, 0, 0, 0, 0, 0);

} /* CIsu_put_cipath */
/*----------------------------------------------------------------------------*/
void CIsu_get_includes( max_index )  int max_index ; {
	struct FI_X_data_st	G 	;
	int			i, j	;

	G.type	= FI_X_ALPHA	;
	G.label	= INCLUDES	;

	for( i = 0, j = 0 ; i < max_index ; i++ ) {
		if( j >= MAXINCDIRS ) {
			CIsu_msg( CIexmessage( CI_W_suIDIROV ) ) ;
			break ;
		} else {
			G.index = i	;
     		     	CIsu_get( &G )	;
#ifdef DEBUG
  printf( "CIsu_get_includes: i=%d max_index=%d\n", i, max_index ) ; fflush( stdout ) ;
  printf( "CIsu_get_includes: i=%d G.max_index=%d\n", i, G.max_index ) ; fflush( stdout ) ;
  printf( "CIsu_get_includes: G.index=%d <%s>\n", G.index, G.value.alpha ) ; fflush( stdout ) ;
#endif
			if( *G.value.alpha != '\0' ) {
				strcpy( choice.includes[j],
					G.value.alpha	  ) ;
     		     		j++ ;
			}
		}
	}
	choice.ninclude = CIninclude = j ;
		
} /* CIsu_get_includes */
/*----------------------------------------------------------------------------*/
void CIsu_get_cipath( max_index ) int max_index ; {

/* -- Gets paths to user PPL source file. Catenates them in
		<dir1>:<dir2>:...:<dirn>
   -- */
	struct FI_X_data_st	G ;
	int			length, pathlen, i ;
#ifdef DEBUG
  printf( "CIsu_get_cipath: ENTER\n" ) ; fflush( stdout ) ;
#endif
	*choice.src_path = '\0' ;
	pathlen = 0		;
	G.type	= FI_X_ALPHA	;
	G.label	= SRC_PATH	;

	for( i = 0 ; i < max_index ; i++ ) {
		G.index = i ;
		CIsu_get( &G )	;
		if( *G.value.alpha != '\0' ) {
#ifdef DEBUG
  printf( "CIsu_get_cipath: got <%s>\n", G.value.alpha ) ; fflush( stdout ) ;
#endif
			length = strlen( G.value.alpha ) + 1 /* for ':' */ ;
			if( length + pathlen <= CIPATHLEN ) {
				strcat( choice.src_path, G.value.alpha	) ;
				strcat( choice.src_path, ":"		) ;
				pathlen += length + 1 ;
			} else break ;
		}
	}
#ifdef DEBUG
  printf( "CIsu_get_cipath: EXIT\n" ) ; fflush( stdout ) ;
#endif
} /* CIsu_get_cipath */	
/*----------------------------------------------------------------------------*/
void CIsu_defaults() { int i ; char *rc  ;

    for( i = 0 ; i < MAXINCDIRS ; i++ ) {
		*( choice.includes[i] = incbuf + i * MAXPATH ) = ENDSTRING ;
    }
    rc = CIgetopt( &choice ) ;

    if( rc != NULL ) CIsu_msg( rc ) ;

} /* CIsu_defaults */
/*----------------------------------------------------------------------------*/
int CIsu_set_on_off( lb, flag ) int lb, flag ; {

	struct FI_X_data_st input ;
#ifdef DEBUG
 printf( "CIsu_set_on_off: lb = %d flag = %d\n", lb, flag ) ; fflush( stdout ) ;
#endif
	input.type		= FI_X_INT	;
	input.value.ivalue	= flag		;
	input.label		= lb		;
	return CIfm_put( ci__setup, &input )	;
}	
/*----------------------------------------------------------------------------*/
void CIsu_init() { struct FI_X_data_st in ;

/* -- Initializes CISetup form gadgets.
   -- */
	CIsu_set_on_off( NOWARNIN, (int) choice.nowarnin ) ;
	CIsu_set_on_off( NOPTRCHK, (int) choice.noptrchk ) ;
	CIsu_set_on_off( NOARGCHK, (int) choice.noargchk ) ;
	CIsu_set_on_off( EXTERNFN, (int) choice.externfn ) ;
	CIsu_set_on_off( UNUSEDFN, (int) choice.unusedfn ) ;
	CIsu_set_on_off( NOPREPRO, (int) choice.noprepro ) ;
	CIsu_set_on_off( TRAPSIGS, (int) choice.trapsigs ) ;
	CIsu_set_on_off( DYNAMICS, (int) choice.dynamics ) ;
	CIsu_set_on_off( GDISPLAY, (int) choice.gdisplay ) ;
	CIsu_set_on_off( MESSAGES, (int) choice.messages ) ;
	CIsu_set_on_off( EROUTPUT, (int) choice.eroutput ) ;

	in.index= 0		;
	in.type	= FI_X_ALPHA	;

/* -- Display path to pre-processor.
   -- */
	in.label= PREPRONM	;
	strcpy( in.value.alpha, choice.prepronm ) ;
	CIfm_put( ci__setup, &in ) ;
  
/* -- Display CIPATH.
   -- */
	CIinfo_CCI_PATH() ;

/* -- Link files.
   -- */
	CIinfo_EXT_PATH() ;

/* -- Include directories.
   -- */
	in.label = INCLUDES	;
	for( in.index = choice.ninclude - 1 ; in.index >= 0 ; in.index-- ) {
		strcpy( in.value.alpha, choice.includes[in.index] ) ;
#ifdef DEBUG
  printf( "CIsu_init: include[%d] <%s>\n", in.index, choice.includes[in.index]);
#endif
		CIfm_put( ci__setup, &in ) ;
	}

/* -- Display path to source files.
   -- */

	CIsu_put_cipath() ;

/* -- Stop execution window check.
   -- */
	in.index	= 0			;
	in.type		= FI_X_INT		;
	in.label	= STOP_CHK		;
	in.value.ivalue	= choice.stop_chk	;
	CIfm_put( ci__setup, &in ) ;


	CIsu_upd_current() ;

} /* CIsu_init */
/*----------------------------------------------------------------------------*/
void CIsu_upd_current() {	struct FI_X_data_st file ;

/* -- Last file processed ( path may be partly discarded to fit field ).
   -- */
	file.type	= FI_X_ALPHA ;
	file.label	= PREVIOUS ;
#ifdef DEBUG
  printf( "CIsu_upd_current: previous<%s>,CIprevious<%s>\n", choice.previous, CIprevious ) ;
#endif
	if( strcmp( CIprevious, choice.previous ) )
		strcpy( choice.previous, CIprevious ) ;

   	if( !strcmp( choice.previous, "" ) ) {
   		strcpy( file.value.alpha, (char *)CIexmessage(CI_I_suNOFILE));
   	} else {
		CIfm_cut_path( choice.previous, MAXMSG, file.value.alpha ) ;
	}
			
	CIfm_put( ci__setup, &file ) ;

} /* CIsu_upd_current */
/*----------------------------------------------------------------------------*/
CIsu_wakeup( coid, coos, req, fid )	OM_S_OBJID	coid;
					OMuword		coos;
					int		req;
					Form		*fid; {

/* -- req = 0 no form.
            1 construct & display
            2 display
   -- */
		int rc ;
#ifdef DEBUG
   printf( "CIsu_wakeup : req %d\n", req ) ;
#endif
   ex$message(	field	= PROMPT_FIELD,
   		in_buff = ""		) ;
   ex$message(	msgnumb	= CM_M_suMTITLE ) ;

/* -- Construct form if first time else display it.
   -- */
   switch( req ) {
	case 1  :
		rc = CIfm_init( CiSetup_name	, CiSetup_label	, coid,
				coos    	, TRUE		, &ci__setup ) ;
		if( rc ) {
		  *fid = ci__setup	;
		  CIsu_defaults()	;
		  CIsu_init()		;
		  CIsu_upd_current()	;
#if 1
	FIg_erase (ci__setup, TRAPSIGS);
	FIg_erase (ci__setup, TRAPTEXT);
#endif

		  rc = CIfm_display( ci__setup, 1 ) ;
#ifdef DEBUG
  if( !rc )
  printf( "CIsu_wakeup : wakeup CiSetup failed rc %d \n", rc ) ;
#endif
		}
		break ;
	case 2  : ci__setup = *fid ;
		  CIsu_upd_current()    ;
#if CI_NO_SIG_TRAP
	FIg_erase (ci__setup, TRAPSIGS);
#endif

		  rc = CIfm_display( ci__setup, 0 ) ;
		  break ;
	default :
	case 0  : rc = TRUE ;
   }

   CIsu_msg( CIexmessage( CI_I_suPROMPT ) ) ;
#ifdef DEBUG
   printf( "CIsu_wakeup : EXIT(%d)\n", rc ) ;
#endif
   return rc ;

} /* CIsu_wakeup */
/*----------------------------------------------------------------------------*/
void CIsu_sysdef() {

/* -- Resets some gadgets to harmless values as regards applications written in
      PPL.
   -- */
	struct FI_X_data_st in ;

	CIdynamics = choice.dynamics = DYNAMICSdef	;
	CIdynamics = choice.gdisplay = GDISPLAYdef	;
	CImessages = choice.messages = MESSAGESdef	;
	CIsu_set_on_off( DYNAMICS, DYNAMICSdef )	;
	CIsu_set_on_off( GDISPLAY, GDISPLAYdef )	;
	CIsu_set_on_off( MESSAGES, MESSAGESdef )	;

	CIsu_get_path( OMCPP_REL_PATH, CIprepronm + 2 ) ;
	CIprepronm[0] = '-' ;
	CIprepronm[1] = 'p' ;
/* ERASE
	sprintf( CIprepronm, "-p%sige/om/bin/omcpp", CS_path_name )	;
end ERASE */
	strcpy( in.value.alpha, strcpy( choice.prepronm, CIprepronm + 2 ) ) ;
	in.label	= PREPRONM	;
	in.type		= FI_X_ALPHA	;
	in.index	= 0		;
	CIfm_put( ci__setup, &in )	;

} /* CIsu_sysdef */
/*----------------------------------------------------------------------------*/
char *CIsu_save( wrtflg ) int wrtflg ; {

/* -- WRITE button has been selected. Saves setup for run and writes it to file
      CISETUP.
   -- */
     CIputopt( &choice ) ;

	return (wrtflg ? (char *)CIsu_write() : 
                         (char *)CIexmessage( CI_I_suOPSAVD ));

} /* CIsu_save */
/*----------------------------------------------------------------------------*/
void CIsu_delete( fid ) Form fid ; {

/* -- Deletes CiSrcLs subform if any then deletes self.
   -- */
	CIls_delete( 1, fid ) ;
	CIfm_delete(    fid ) ;
}
/*----------------------------------------------------------------------------*/
void CIsu_sleep( fid ) Form fid ; {

/* -- Does not really sleep at present.
   -- */
		ci__setup = fid ;
		CIsu_clear() ;
		/* CIfm_erase( ci__setup, 0 ) ;
		UI_status( "" ) ;
		UI_prompt( "" ) ;
		UI_message( "" ) ;*/ ;
}
/*----------------------------------------------------------------------------*/
char *CIsu_chk_file( file, mode )  path file ; int mode ; {

/* -- Checks file with respect of mode ( execute or read ). If permision is
      denied, returns an error message in a static buffer fit for the form's
      message area.
   -- */
		static char msg[MAXMSG+1], *c ; int l ;

#ifdef DEBUG
  printf( "CIsu_chk_file: file <%s>\n", file ) ;
#endif
	if( access( file, mode ) != 0 ) {
		switch( mode ) {
		    case X_OK : c = (char *)CIexmessage( CI_W_suNOEXEC ) ; 
                                break ;
		    case R_OK : c = (char *)CIexmessage( CI_W_suNOREAD ) ; 
                                break ;
		}
#ifdef DEBUG
  printf( "CIsu_chk_file: MAXMSG %d strlen( c ) %d\n", MAXMSG, strlen( c ) ) ;
#endif
		l = MAXMSG - strlen( c ) ;
		c = strcat( (char *)CIfm_cut_path( file, l, msg ), c ) ;
#ifdef DEBUG
  printf( "CIsu_chk_file: <%s>\n", c ) ;
#endif
	} else c = NULL ;
	return c ;

} /* CIsu_chk_file */
/*----------------------------------------------------------------------------*/
method form_input( int form_label ; char *value ) {

  struct FI_X_data_st	*form_data	;
  char			*msg		;
  extern char		*CIls_cnst()	;
  struct GRid		cosetup		;

/* -- Invoked when CiSetup or CiSrcLs forms are modified (both are attached to
      the COcisetup command object).
   -- */

#ifdef DEBUG
  printf( "COcisetup.form_input: form_label %d\n", form_label ) ;
  fflush( stdout ) ;
#endif
  form_data	= (struct FI_X_data_st *) value	;
  cosetup.objid = my_id				;
  cosetup.osnum = OM_Gw_current_OS		;

  if( form_label == CiSetup_label ) {

  ci__setup = (Form)me^^super_cmd.form_id	;
  CIsu_clear() ;

  switch( form_data->label ) {

/* --Control buttons :
     Help		: invokes help on CI set-up.
     Save-Restore	:
     Run-Execute	: saves options for design session.
     Dismiss-Execute	: saves options for design session, exits form.
     Dismiss-Abort	: exits form, no save.
     Revert-Restore	: restores options to values before forms was invoked.
   -- */
     case HELP_BTN : CIfm_help( &cosetup, CiSetup_help );
		     CIsu_set_on_off( HELP_BTN, 0 )	; break ;

     case SVRS_BTN : break ;

     case RUN_BTON : CIsu_msg( CIsu_save( 0 ) )		;
		     CIsu_set_on_off( RUN_BTON, 0 )	; break ;

     case EXIT_BTN : CIsu_msg( CIsu_save( 0 ) )		;
     case QUIT_BTN : CIsu_set_on_off( form_data->label, 0 ) ;
		     CIfm_erase( ci__setup, 1, 1 )	; break ;

     case REST_BTN : CIsu_defaults()				;
		     CIsu_init()				;
		     CIsu_set_on_off( REST_BTN, 0 ) 		;
		     CIsu_msg( CIexmessage( CI_I_suRESETV ) )	; break ;
/* -- Check list.
   -- */
     case NOWARNIN : choice.nowarnin = form_data->value.ivalue ; break ;
     case NOPTRCHK : choice.noptrchk = form_data->value.ivalue ; break ;
     case NOARGCHK : choice.noargchk = form_data->value.ivalue ; break ;
     case EXTERNFN : choice.externfn = form_data->value.ivalue ; break ;
     case UNUSEDFN : choice.unusedfn = form_data->value.ivalue ; break ;
     case NOPREPRO : choice.noprepro = form_data->value.ivalue ; break ;

/* -- Field of paths to include files for cci.
   -- */
     case INCLUDES : CIsu_get_includes( form_data->max_index ) ;
		     break ;

/* -- Field of pre-processor pathname for cci.
   -- */
     case PREPRONM : strcpy( choice.prepronm, form_data->value.alpha )	;
		     CIsu_msg( CIsu_chk_file( choice.prepronm, X_OK ) )	;
		     break ;

/*--  Field of paths to PPL source files.
   -- */
     case SRC_PATH : CIsu_get_cipath( form_data->max_index )   ; break ;

/* -- Toggles:
		- Trap signals ON/OFF during execution of PPL file.
      		- Dynamics			"
      		- Display			"
      		- Messages			"
   -- */
     case TRAPSIGS : choice.trapsigs = form_data->value.ivalue ; break ;
     case DYNAMICS : choice.dynamics = form_data->value.ivalue ; break ;
     case GDISPLAY : choice.gdisplay = form_data->value.ivalue ; break ;
     case MESSAGES : choice.messages = form_data->value.ivalue ; break ;

/*  -- Count of instructions after which STOP window must be checked.
    -- */
     case STOP_CHK : choice.stop_chk = form_data->value.ivalue ; break ;

/* -- Error output toggle: form or UNIX window.
   -- */
     case EROUTPUT : choice.eroutput = form_data->value.ivalue ; break ;

/* -- Button invoking CiSrcLs form, save button, system defaults button.
   -- */
     case LISTFMBT : msg = CIls_cnst( my_id, OM_Gw_current_OS, ci__setup	);
     		     if( msg == NULL )	CIls_init()	;
     		     else		{
     		     		CIsu_msg( msg ) ;
     		     		CIsu_set_on_off( LISTFMBT, 1 ) ;
     		     }
     		     break ;

/* -- Write-File button	: saves options for sessions, writes them to CISETUP.
   -- */
     case WRIT_BTN : CIsu_msg( CIsu_save( 1 ) )		;
		     CIsu_set_on_off( WRIT_BTN, 0 )	; break ;

/* -- Button restoring certain gadgets to system defaults.
   -- */
     case SYST_DEF : CIsu_sysdef()			;
		     CIsu_set_on_off( SYST_DEF, 0 )	; break ;

     default       : fprintf( stderr, "CI setup: Unknown gadget label: %d\n",
		              form_data->label ) ;
  }
   ex$message( msgnumb = CM_M_suMTITLE ) ;

  } else /* This is for CiSrcLs form */ CIls_input( form_data, &cosetup ) ;

#ifdef DEBUG
  printf( "COcisetup.form_input: EXIT\n" ) ; fflush( stdout ) ;
#endif
  return OM_S_SUCCESS ;

} /* method form_input */
/*----------------------------------------------------------------------------*/
void CIsu_ls_deleted() {
	long rc ;
#ifdef DEBUG
  printf( "CIsu_ls_deleted: ENTER\n" ) ;
#endif
	 rc = CIsu_set_on_off( LISTFMBT, 0 ) ;
#ifdef DEBUG
  printf( "CIsu_ls_deleted: EXIT(%d)\n", rc ) ;
#endif
}
/*----------------------------------------------------------------------------*/

end implementation COcisetup ;
