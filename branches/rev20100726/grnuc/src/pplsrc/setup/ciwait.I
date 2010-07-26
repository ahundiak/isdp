class implementation ci ;

/* -- Displays a clock while file is parsing. And displays compiler output to
      a form if any. This module  is only used when CIeroutput is set to "0",
      i.e. output to a form is  requested.
   -- */
/*----------------------------------------------------------------------------*/
#       include <string.h>
#	include <malloc.h>
#       include <errno.h>
#       include <fcntl.h>
#       include <sys/signal.h>
#       include <ctype.h>
#	include "igrtypedef.h"
#	include "igetypedef.h"
#	include "ex.h"
#	include "exdef.h"
#	include "exmacros.h"
#	include "msdef.h"
#	include "msmacros.h"
#	include "cimsg.h"
#	include "FI.h"
#	include "cisetup.h"
/*----------------------------------------------------------------------------*/

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

static int CIcci_rc __((int cci_pid));

#if defined(__cplusplus)
}
#endif
#undef __
%endsafe

#if !defined(P_tmpdir)
#define P_tmpdir	"/usr/tmp/"
#endif

#define CiClock_name	"CiClock"
#define CiClock_label	1
#define CLKMSGLEN	27		/* Length of message field in CiClock */
/*----------------------------------------------------------------------------*/
/* -- Ids of CiClock and CiCci forms.
   -- */
static Form	ci__clock	;
static Form	ci__cicci	;
/* -- Help topic associated with CiCci form.
   -- */
static char		*ci__cicci_help	;
/* -- Command object associated with CiCci form.
   -- */
static struct GRid	ci__cicci_co	;
/*----------------------------------------------------------------------------*/
/* -- Gadget labels of CiClock.
   -- */
enum CKlabs	{
	CICLKDIAL = 11, CICLKMSG1 = 16, CICLKMSG2 = 17
} ;
/*----------------------------------------------------------------------------*/
int CIclock( msg1, msg2 ) char *msg1, *msg2 ; {

/* -- Displays CiClock form. Fills the two text areas.
      INPUT  : msg1, msg2, messages to display (may be truncated if too long).
   -- */
	long			rc		;
	struct FI_X_data_st	gad		;
	extern int		errno		;
 
  rc = CIfm_init(	CiClock_name	, CiClock_label	, NULL_OBJID,
			0		, TRUE		, &ci__clock ) ;

  gad.type = FI_X_ALPHA ;
  if( msg1 != NULL ) {
  	gad.label = CICLKMSG1 ;
 	strncpy( gad.value.alpha, msg1, CLKMSGLEN )[CLKMSGLEN] = '\0' ;
  	CIfm_put( ci__clock, &gad ) ;
  }

  if( msg2 != NULL ) {
  	gad.label = CICLKMSG2 ;
  	strncpy( gad.value.alpha, msg2, CLKMSGLEN  )[CLKMSGLEN] = '\0' ;
        CIfm_put( ci__clock, &gad ) ;
  }

  gad.type		= FI_X_INT	;
  gad.label		= CICLKDIAL	;
  gad.value.ivalue	= 0		;
  CIfm_put( ci__clock, &gad ) ;

  return CIfm_display( ci__clock, 0 ) ;

} /* CIclock */
/*----------------------------------------------------------------------------*/
int CImv_clock( val, pid ) int val, pid ; {

/* -- Moves hand of CI clock. Kills cci if STOP window was hit.
      RETURNS : FALSE if STOP was hit else TRUE.
   -- */

		struct FI_X_data_st gad ; int rc = TRUE ; 
		unsigned int sleep() ;

  		gad.type		= FI_X_INT	;
  		gad.label		= CICLKDIAL	;
  		gad.value.ivalue	= val		;
		gad.value.ivalue++	;
		CIfm_put( ci__clock, &gad )	;
		if( IGEstop() ) {
			if( pid != -1 ) {
			  gad.label	= CICLKMSG2			;
			  gad.type	= FI_X_ALPHA			;
			  ex$message( msgnumb = CI_I_erCCIABO	,
				      buff    = gad.value.alpha	)	;
			  kill( pid, SIGTERM )				;
			  CIfm_put( ci__clock, &gad )			;
			  sleep( 1 )					;
			}
			IGEresetstop()					;
			rc = FALSE					;
		}
		return rc ;
} /* CImv_clock */
/*----------------------------------------------------------------------------*/
char *CIfm_cut_path( in, n, out ) char *in, *out ; int n ; {

/* -- Cuts a pathname to `n' characters so as to fit a field or message area.
      The start of the pathname gets cut if need be.
      INPUT  : in, pathname to cut.
               n , length that the resulting string must have at most.
               out, cut string.
      RETURNS: `out'.
   -- */
			int len ; char *s ;

	len = strlen( in ) ; strcpy( out, "..." ) ;
	if( len > n ) {
		while( TRUE ) {
			s = strchr( in, '/' ) ;
			if( s != NULL ) {
				if( strlen( s ) <= n - 3 ) {
					strcpy( out + 3, s ) ;
					break ;
				} else in = s + 1 ;
			} else {
			   if( n > 3 ) {
				  len = strlen( in ) ;
				  if( len > n ) n = len ;
				  strncpy( out + 3, in, n - 3 )[len] = '\0' ;
			   } else strncpy( out    , in,     3 )[3  ] = '\0' ;
				break ;
			}
		}
	} else strcpy( out, in ) ;

	return out ;

} /* CIfm_cut_path */
/*----------------------------------------------------------------------------*/
#define CiCci 		"CiCci"
#define CiCcilab	98765
enum ciccilab	{ CICCIHLP = 5, CICCIDEL = 4, CICCITTL = 11, CICCIFLD = 12 } ;
/*----------------------------------------------------------------------------*/
int CIcci_form_process( label, in )	int	label		;
					struct  FI_X_data_st *in	; {

/* -- Processes input of CiCci form. Called by `ci.form_input'.
   -- */
  	struct EX_button event ; int resp ; long size, rc;

	if( label == CiCcilab ) {
		switch( in->label ) {
		  case CICCIDEL :
/* --			Put moveon on queue so that `wait_for_end' can exit
			wait-for-input loop.
   -- */
			size = sizeof( struct EX_button ) 	;
			resp = EX_RJT_MOVEON			;
			ex$putque( msg = &rc, response = &resp, byte = &size,
				buffer = (char *)&event ) ;
			break;
		  case CICCIHLP :
		  	CIfm_help( &ci__cicci_co, ci__cicci_help ) ;
			in->type	= FI_X_INT	;
			in->value.ivalue= 0		;
			CIfm_put( ci__cicci, in )	;
		/* UI_message( "Help not implemented" ) ; */
			break ;
		}
		rc = TRUE ;
	} else rc = FALSE ;

	return rc ;

} /* CIcci_form_process */
/*----------------------------------------------------------------------------*/
void CIcci_out_form( title, ciid, line, count, help )
				int		title			;
				OM_S_OBJID	ciid			; 
				char		*line[FI_X_LINE_LEN]	;
				int		count			;
				char		*help			; {
	
/* -- Starts CiCci forms and fills it. Then waits for user input in form.
      INPUT: line, array of lines of output.
             count, number of lines.
             title, title number in message sub-system.
	     ciid , id of ci object creating this form.
	     help , help topic associated with form.
      NOTE: nothing else may be done before form is exited.
   -- */
	long			rc		;
	struct FI_X_data_st	gad		;
	extern char		*CIexmessage()	;
#ifdef DEBUG
  printf( "CIcci_out_form: ENTER\n" ) ;
#endif

  ci__cicci_co.osnum	= OM_Gw_TransOSnum_0	;
  ci__cicci_co.objid	= ciid			;
  ci__cicci_help		= help			;

  rc = CIfm_init(	CiCci		, CiCcilab	, ciid,
			OM_Gw_TransOSnum_0, TRUE	, &ci__cicci ) ;

/* -- Output title if any.
   -- */
  gad.type	= FI_X_ALPHA	;

  if( title != 0 ) {
  	gad.label	= CICCITTL	;
  	strcpy( gad.value.alpha, CIexmessage( title ) ) ;
  	CIfm_put( ci__cicci, &gad ) ;
  }

  gad.label	= CICCIFLD	;
  for( gad.index = 0 ; gad.index < count ; gad.index++ ) {
    strncpy( gad.value.alpha, line[gad.index], FI_X_STRLEN )[FI_X_STRLEN] = '\0' ;

    CIfm_put( ci__cicci, &gad ) ;
    FIfld_pos_cursor (ci__cicci, CICCIFLD, 0, 0, 0, 0, 0, 0);
  }

  if( CIfm_display( ci__cicci, 1 ) ) {
  	ex$message( msgnumb = CI_P_erEXITFM )		;
  	CIfm_wait_for_end( ci__cicci )			;
  	ex$message( field	= PROMPT_FIELD	,
	      	    in_buff	= ""		)	;
  }

#ifdef DEBUG
  printf( "CIcci_out_form: EXIT\n" ) ;
#endif
} /* CIcci_out_form */
/*----------------------------------------------------------------------------*/
void CIstart_clock( file ) char *file ; {

/* --	Starts waiting clock.
   -- */
	char 		msg1[FI_X_STRLEN], msg2[FI_X_STRLEN],
			*c, cut[CLKMSGLEN+1] 	 	;
	UNIXpath	buf ;

	if( ( c = strrchr( strcpy( buf, file ), '/' ) ) == NULL ) c = buf ;
	else c++ ;
	sprintf( msg1, "Parsing: %s", c ) ;
	if( c == buf )	c = "." ;
	else {
		if( c == buf + 1 )	*c	= '\0' ;
		else			*--c	= '\0' ;
		c = buf ;
	}
	sprintf( msg2, "in: %s", CIfm_cut_path( c, CLKMSGLEN - 4, cut ) ) ;
	CIclock( msg1, msg2 ) ;

} /* CIstart_clock */
/*----------------------------------------------------------------------------*/
static int CIcci_rc( cci_pid ) int cci_pid ; {

/* -- Gets cci rc from cci rc file. There is no other way to get the return
      code of a process form ex$fork if this process has been run with
      wait_flag set to 1.
      RETURNS : cci rc or 1 if cannot open cci rc file.
   -- */
#define CCI_RC_FILE "ccirc"
	UNIXpath ccirc ; int rc = -1 ; FILE *ccircstream ;

	sprintf( ccirc, "%s%s%d", P_tmpdir, CCI_RC_FILE, cci_pid ) ;
	if( ( ccircstream = fopen( ccirc, "r" ) ) != NULL ) {
		fscanf( ccircstream, "%d", &rc )	;
		fclose( ccircstream )			;
		unlink( ccirc )				;
#ifdef DEBUG
  printf( "CIcci_rc: cci returned %d\n", rc ) ;
#endif
	} else rc = 1 ;
	return rc ;
}
/*----------------------------------------------------------------------------*/
int CIpipe( ciid, argc, argv ) OM_S_OBJID ciid ; int argc ; char **argv ; {

/* -- Runs ex$fork with named pipe for output to read it and sends output to the
      CiCci form.
      INPUT  : ciid, object id of ci object running cci.
	       argc, count of arguments for cci.
               argv, array of arguments for cci.
      NOTE   : argv[1] is expected to point to the filename to compile.
      RETURNS: the return code of cci.

   -- */
#define NP2 "/usr/tmp/NP2"

   int	pipedsc, u, rc, pid = -1, v = 0, go, i, w ;
   char buf[501], *line[FI_X_LINE_LEN], c	;

#ifdef DEBUG
  printf( "CIpipe: ENTER file<%s>\n", argv[1] ) ;
#endif
	CIstart_clock( argv[1] ) ;
	CImv_clock( v++, pid ) ;
	ex$fork( num_entry	= argc		,
		 argu		= argv		,
		 childpid	= &pid		,
		 redir_io	= REDIR_OUTPUT	) ;
#ifdef DEBUG
  printf( "CIpipe: child is %d\n", pid ) ;
#endif
	go = CImv_clock( v++, pid ) ;

	if( ( pipedsc = open( NP2, O_RDONLY | O_NDELAY ) ) == -1 ) {
		UI_message( "CI: cannot open NP2" ) ;
	} else {
		go = go && CImv_clock( v++, pid ) ;
#ifdef DEBUG
  printf( "CIpipe: NP2 opened <%s>\n", NP2 ) ;
  printf( "CIpipe: go %d\n", go ) ;
#endif
		u = 0 ;
		if( go ) {
#ifdef DEBUG
  printf( "CIpipe: reading pipe\n" ) ; fflush( stdout ) ;
#endif
		   i = 0 ;
		   do {
			go = go && CImv_clock( v++, pid ) ;
			if( read( pipedsc, &c, 1 ) ) {
			   switch( c ) {
			     case '\r' :
			     case '\n' : buf[i] = '\0' ; i = 0 ;
				if( line[u] = malloc( 1 + strlen( buf ) ) ) {
					strcpy( line[u], buf ) ;
#ifdef DEBUG
	printf( "CIpipe: %d <%s>\n", u, line[u] ) ;
#endif
					u++ ;
				}
				break ;
			      default   : buf[i++] = c ; break ;
			   }
			} else { for( w = 0 ; w < 1000000 ; w++ ) ; }
			if( kill( pid, 0 ) == -1 ) {
			   while( read( pipedsc, &c, 1 ) ) {
			     switch( c ) {
				case '\r' :
				case '\n' : buf[i] = '\0' ; i = 0 ;
				  if( line[u] = malloc( 1 + strlen( buf ) ) ) {
					strcpy( line[u], buf ) ;
#ifdef DEBUG
	printf( "CIpipe: %d <%s>\n", u, line[u] ) ;
#endif
					u++ ;
				  }
				  break ;
				default   : buf[i++] = c ; break ;
			     }
			   }
			   break ;
			}
		   } while( u < FI_X_LINE_LEN ) ;
		}
		close( pipedsc ) ;

		CIfm_erase( ci__clock, 1, 0 )			;
		CIfm_delete( ci__clock )	;
		if( go && u ) {
			CIcci_out_form( 0, ciid, line, u, "CIer_compile" ) ;
		}
		while( u ) {
			free( line[--u] ) ;
		}
	}
/* --	A good rc should be returned!
   -- */
	rc = go ? ( CIcci_rc( pid ) == 0 ) : 0 ;

#ifdef DEBUG
  printf( "CIpipe: EXIT(%d)\n", rc ) ;
#endif
	return rc ;

} /* CIpipe */			
/*----------------------------------------------------------------------------*/

end implementation ci ;
