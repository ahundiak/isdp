class implementation ci ;

/* -- Runtime error display, either on form or UNIX window, depending upon the
      value of `CIeroutput' ( 1: UNIX window, 0: form ).
   -- */
/*----------------------------------------------------------------------------*/
#	include "OMminimum.h"
#	include "OMmacros.h"
#	include "OMlimits.h"
#	include "OMprimitives.h"
#	include "OMerrordef.h"
#	include "igrtypedef.h"
#	include "igetypedef.h"
#	include "godef.h"
#	include "codef.h"
#	include "ex.h"
#	include "exdef.h"
#	include "exmacros.h"
#	include "msdef.h"
#	include "msmacros.h"
#	include "cidef.h"
#	include "citypedef.h"
#	include "ciprivmacros.h"
#	include "cimsg.h"
#	include <FI.h>
#	include <string.h>
#	include "cisetup.h"
/*----------------------------------------------------------------------------*/
extern OMuword OM_Gw_TransOSnum_0 ;
/*----------------------------------------------------------------------------*/
#define CiError_name	"CiError"
#define CiError_help	"CIer_runtime"
/* -- Label of runtime error form, set to a random value to be recognized in
      `form_input' method.
   -- */
#define CiError_label	INT_MAX
#define MAXDIGIT	4	/* Max count of digit in line number	*/
#define ERTXSIZE	70	/* Max size of error text		*/
#define MSTXSIZE	90	/* Max size of diagnostic message line	*/
#define MSGLINES	5	/* Max number of diagnostic lines	*/
/*----------------------------------------------------------------------------*/
extern struct instance_ci *ci_data ;
extern char	**ci_data_varvaltable ;
extern char	*ci_data_info	;
/*----------------------------------------------------------------------------*/
/* -- Gadget labels.
   -- */
enum ERlabs		{	RESUMEX =  1, /* Resume execution button*/
				ABORTEX =  4, /* Abort  execution button*/
				HELPBTN	=  6, /* Help button		*/
				FILENAM	= 18, /* File name   text	*/
				LINENUM = 19, /* Line number text	*/
				SEVERER = 20, /* Severe error flag	*/
				FATALER = 21, /* Fatal  error flag	*/
				WARNING = 22, /* Warning      flag	*/
				ERRTYPE = 23, /* Type of error		*/
				MSGLIN1 = 38, /* Diagnostic message	*/
				MSGLIN2 = 39, /*  lines ( 1 through 5 ) */
				MSGLIN3 = 40,
				MSGLIN4 = 41,
				MSGLIN5 = 43
} ;
/*----------------------------------------------------------------------------*/
/* -- Ids of CiError form and of command object associated with it.
   -- */
static Form		ci__errid	;
static struct GRid	ci__error_co	;
extern char		CIresume	;

%safe
/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static int CIer_gerase __((enum ERlabs L));
static int CIer_put __((enum ERlabs L, char *text));
static char *srcfile __((char *pathname));
static long UNIXwindow __((int *action, char *file, int line, int severity, 
                           char *errtype, char *l1, char *l2, char *l3, 
                           char *l4, char *l5));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe


/*----------------------------------------------------------------------------*/
OMuword CIosnum() {
	static OMuword osnum = (OMuword) -1 ;

	if( osnum == (OMuword) -1 ) {
		om$os_name_to_number(	osname	= "OM_TransOS_0",
					p_osnum	= &osnum	) ;
	}
	return osnum ;
}
/*----------------------------------------------------------------------------*/
static int CIer_gerase( L )	enum ERlabs 	L ; {

  long rc;
#ifdef DEBUG
  printf( "CIer_gerase: %d\n", L ) ;
#endif
  rc = FIg_erase (ci__errid, L);
#ifdef DEBUG
  if (rc != FI_SUCCESS)
	fprintf( stderr, "CIerror, FIg_erase: bad rc\n" ) ;
#endif
  	
  return ( rc == FI_SUCCESS );
}	
/*----------------------------------------------------------------------------*/
int CIfm_wait_for_end( form ) Form form ; {

	struct EX_button	wait		;
	int			size, resp	;
/* -- Waits inconditionnaly for EX_RJT_MOVEON.
      Erases and deletes form if `form' is not NULL.
   -- */
#ifdef DEBUG
  printf( "CIfm_wait_for_end: ENTER\n" ) ;
#endif
	do {
		ex$wait_for_input(	response	= &resp	,
					buffer		= (char *)&wait	,
					byte		= &size	) ;
#ifdef DEBUG
  printf( "CIfm_wait_for_end: resp %d\n", resp ) ;
#endif
	} while( resp != EX_RJT_MOVEON ) ;
#ifdef DEBUG
  printf( "CIfm_wait_for_end: EXIT\n" ) ;
#endif
	if( form != NULL ) {
		CIfm_erase( form, 1, 0 );
		CIfm_delete( form ) ;
	}

	return TRUE ;
}
/*----------------------------------------------------------------------------*/
static int CIer_put( L, text )	enum ERlabs 	L	;
				char		*text	; {
	
  struct FI_X_data_st	gad	;
  long			rc	;

  strncpy( gad.value.alpha, text, FI_X_STRLEN - 1 )[FI_X_STRLEN] = '\0' ;
  rc = FIg_set_text (ci__errid, L, gad.value.alpha);
  
#ifdef DEBUG
  if( rc != FI_SUCCESS ) {
  	fprintf( stderr, "CIerror, FIg_set_text: bad rc (%d)\n", rc ) ;
  }
#endif
  return rc ;

} /* CIer_put */
/*----------------------------------------------------------------------------*/
int CIerror_form_process( form, button ) int			form	;
					 struct FI_X_data_st	*button ; {

/* -- Expected event: Help, Abort or Resume button has been pressed.
   -- */
  struct EX_button event ; long size, rc ; int resp ;

#ifdef DEBUG
  printf( "CIerror_form_process: form %d CiError_label %d gadget %d\n", form,
	CiError_label, button->label ) ;
#endif
  if( form == CiError_label ) {
	switch( button->label ) {
		case HELPBTN :
			CIfm_help( &ci__error_co, CiError_help ) ;
/* -- 			Unhighlight button.
   -- */
			button->type		= FI_X_INT;
			button->value.ivalue	= 0	;
			CIfm_put( ci__errid, button )	;
		        break ;

/* --		`CIresume' initialized to TRUE.
   -- */
		case ABORTEX : CIresume = FALSE ;

		case RESUMEX :
/* --			Put moveon on queue so that `wait_for_end' can exit
			wait-for-input loop.
   -- */
			size = sizeof( struct EX_button ) 	;
			resp = EX_RJT_MOVEON			;
			ex$putque( msg  = &rc  , response = &resp,
				   byte = &size, buffer   = (char *)&event ) ;
	      		break ;

	      	default	     :
	      		fprintf( stderr,
	      	                 "CIerror_form_process: unexpected label %d\n",
	      	                 button->label ) ;
	      	        break ;
	} /* switch */
	rc = TRUE ;
  } else return FALSE ;

#ifdef DEBUG
  printf( "CIerror_form_process: EXIT CIresume %d\n", CIresume ) ;
#endif
  return rc ;

} /* CIerror_form_process */
/*----------------------------------------------------------------------------*/
static char *srcfile( pathname ) char *pathname ; {
		static char N[CI_NAME_MAX+1] ; char *f ; char length ;

	if( ( f = strrchr( pathname, '/' ) ) == NULL ) f = pathname ;
	else f++ ;

	length = strlen( strcpy( N, f ) ) ;
	if( N[length-2] != '.' && N[length-1] != 'u' ) {
		N[length] = '.' ; N[length+1] = 'u' ; N[length+2] = '\0' ;
	}
	return N ;
}
/*----------------------------------------------------------------------------*/
static long UNIXwindow( action, file, line, severity, errtype,
		        l1    , l2  , l3  , l4      , l5     )

int	*action, line ;
char	severity, *file, *errtype, *l1, *l2, *l3, *l4, *l5 ;

/* -- Displays runtime error to UNIX window. Same arguments as CIerror below.
      RETURNS: always TRUE.
   -- */

{	char *ln[MSGLINES] ; int i ;

	ln[0] = l1 ; ln[1] = l2 ; ln[2] = l3 ; ln[3] = l4 ; ln[4] = l5 ;

	fprintf( stderr, "\n-- Command Interpreter Runtime Error\n\
File: %s  Line: %d\n\
%c>> %s\n\
DIAGNOSTIC:\n", srcfile( file ), line, severity, errtype ) ;

	for( i = 0 ; i < MSGLINES ; i++ ) {
		if( ln[i] != NULL ) {
			fprintf( stderr, "%s\n", ln[i] ) ;
		}
	}
	fprintf( stderr, "--\n" ) ;
	*action = FALSE ;
	return TRUE ;

} /* UNIXwindow */
/*----------------------------------------------------------------------------*/
long CIerror( action, evdata, runinfo, file, line, severity,
	      errtype, l1, l2, l3, l4, l5 )

int		*action, line ;
CIco_resp	*evdata	;
CIruntime	*runinfo ;
char		severity, *file, *errtype, *l1, *l2, *l3, *l4, *l5 ;

/* -- Activates or re-activates Runtime Error Form and fills it.
      INPUT  : evdata	, event data of ci object as a command object.
	       runinfo	, runtime parameters.
	       file	, name of executing PPL file.
      	       line	, line number where error occured.
	       severity , 'W' = warning, 'S' = severe, 'F' = fatal.
	       errtype	, origin of error ( OM, math function, I/O, etc. ).
	       l[1-5]	, diagnostic lines ( unused ones must be set to NULL ).
      OUTPUT : action	, TRUE = resume execution, FALSE = abort execution.
      RETURNS: status of FIform manipulations.
   -- */

{
  long int	rc			;
  char		buf[20], *ln[MSGLINES]	;
  enum ERlabs	lb[MSGLINES]		;

#ifdef DEBUG
  printf( "CIerror: enter ci_id = %d\n", evdata->ci_id ) ; fflush( stdout ) ;
#endif
  if( CIeroutput == 1 )
  	return UNIXwindow( action, file, line, severity, errtype,
  			   l1	 , l2  , l3  , l4      , l5     ) ;
  	
  rc = CIfm_init( CiError_name	, CiError_label	, evdata->ci_id,
  		  OM_Gw_TransOSnum_0, TRUE	, &ci__errid ) ;
  	
  ci__error_co.objid	= evdata->ci_id	;
  ci__error_co.osnum	= OM_Gw_TransOSnum_0;
  if( rc != FI_SUCCESS ) {
/* --		Use UNIX Window ...
   -- */
   		CIeroutput = 1 ;
   
  		fprintf( stderr, "CIerror: cannot create form\n" ) ;
  		return UNIXwindow( action, file, line, severity, errtype,
  			   	   l1	 , l2  , l3  , l4      , l5     ) ;
  }

/* -- According to severity, erase unwanted gadgets ... Fatal errors cannot be
      recovered.
   -- */
  switch( severity ) {
  	case 'W' : 	CIer_gerase( SEVERER )	;
			CIer_gerase( FATALER )	;
			CIresume = TRUE 	; break ;
  	case 'S' : 	CIer_gerase( WARNING )	;
			CIer_gerase( FATALER )	;
			CIresume = TRUE 	; break ;
  	case 'F' :	CIer_gerase( WARNING )	;
			CIer_gerase( SEVERER )	;
			CIresume = FALSE	; break	;
  	default  : fprintf( stderr, "CI Error Form, unknown severity\n" ) ;
  }

/* -- Put file name ( ridden of path ).
   -- */
  CIer_put( FILENAM, srcfile( file ) ) ;

/* -- Put line number.
   -- */
#ifdef DEBUG
  	printf( "CIerror: Put line number.\n" ) ; fflush( stdout ) ;
#endif
  sprintf( buf, "%d", line ) ; buf[MAXDIGIT+1] = '\0' ;
  CIer_put( LINENUM, buf ) ;

/* -- Put error type.
   -- */
#ifdef DEBUG
  	printf( "CIerror: Put error type.\n" ) ; fflush( stdout ) ;
#endif
  CIer_put( ERRTYPE, errtype ) ;

/* -- Put diagnostic lines.
   -- */
  ln[0] = l1 ; lb[0] = MSGLIN1 ; ln[1] = l2 ; lb[1] = MSGLIN2 ;
  ln[2] = l3 ; lb[2] = MSGLIN3 ; ln[3] = l4 ; lb[3] = MSGLIN4 ;
  ln[4] = l5 ; lb[4] = MSGLIN5 ;
#ifdef DEBUG
  	printf( "CIerror: Put diagnostic lines.\n" ) ; fflush( stdout ) ;
#endif
  for( rc = 0 ; rc < MSGLINES ; rc ++ ) {
  	if( ln[rc] == NULL )	CIer_gerase( lb[rc] ) ;
  	else			CIer_put   ( lb[rc], ln[rc] ) ;
  }

/* -- Display form.
   -- */
  ex$message( msgnumb = CM_M_exERFORM ) ;
#ifdef DEBUG
  	printf( "CIerror: Display form.\n" ) ; fflush( stdout ) ;
#endif
  rc = CIfm_display( ci__errid, 1 )	;
  ex$message( msgnumb = CI_P_exERFORM ) ;

  CIfm_wait_for_end( ci__errid ) ;

/* -- Form has been dismissed: Restore PPL command file prompts.
   -- */
  if( CIresume ) {
  	ex$message( field = PROMPT_FIELD , in_buff = runinfo->msgsys.Prompt  ) ;
  	ex$message( field = MESSAGE_FIELD, in_buff = runinfo->msgsys.Message ) ;
  }

#ifdef DEBUG
  	printf( "CIerror: EXIT CIresume %d\n", CIresume ) ;
#endif

  *action =  CIresume ;
  return TRUE ;

} /* CIerror */
/*----------------------------------------------------------------------------*/
/*int CIexecuting() {
/*	
/* -- Returns TRUE if there is a ci object executing a PPL file (i.e. not only
/*      loaded. )
/*   -- */
/*	extern OM_S_OBJID	ci_id		;
/*   return    ( om$is_objid_valid(	objid = ci_id    ,
/*   					osnum = CIosnum() ) & OM_S_SUCCESS )
/*   	  && CI_IGE != NULL
/*	  && CI_IGE->interrupt.executing ;
/*}*/
/*----------------------------------------------------------------------------*/

end implementation ci ;
