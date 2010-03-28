/* -- Exception (signaled) error handler.
   -- */
#if !CI_NO_TRAP_SIG
#	include "OMminimum.h"
#	include "OMerrordef.h"
#	include "igrtypedef.h"
#	include "igetypedef.h"
#	include "ex.h"
#	include "godef.h"
#	include "codef.h"
#	include "grerr.h"
#	include "gr.h"
#	include "igr.h"
#	include "igrdp.h"
#	include "cidef.h"
#	include "citypedef.h"
#	include "ciprivmacros.h"
#	include "cimsg.h"
#	include <signal.h>
#	include <memory.h>
#	include <string.h>
#	include <ctype.h>
/* -- This flag cannot be set until the adequate library is available !
   -- */
#ifdef CI_FPE
#	include <ieeefp.h>
#endif
/*----------------------------------------------------------------------------*/
#define MAXLENGTH	90 /* without trailing '\0' */
#define MAXPMLINS	 3 /* line count for parameter print out */
#define MAXPMPRNT	 9 /* max number of function params printed on 3 lines*/
#define PMPERLINE	(MAXPMPRNT/MAXPMLINS)
/*----------------------------------------------------------------------------*/
extern struct	instance_ci *ci_data	;
extern char	**ci_data_varvaltable	;
static char	*ci__hint, CIresume	;
extern		etext, edata, end	;
extern char	*CIexmessage()		;

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

static void CIfpehandler __((void));
static void putblanks __((char *b, int size));
static void CIdmpchar __((int c, int n, char buf[MAXLENGTH /PMPERLINE +1 ]));
static void CIchkpointer __((int iptr, int n));
static void CIfcnargs __((short *list, int npm, char **lines, int inc));
static void CIchkfcnaddr __((int ifcn));
static void CIdmpinstr __((struct ci_instruction *I, char **ln));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
#ifdef CI_FPE
static void CIfpehandler() {
	int type, op ;

	switch( _fpftype ) {
		default			:
		case UNKNOWN		: type = CI_E_fpUNKNER ; break ;
		case INT_DIVZ		: type = CI_E_fpIDIVZR ; break ;
		case INT_OVFLW		: type = CI_E_fpINTOVR ; break ;
		case FP_OVFLW		: type = CI_E_fpFLTOVR ; break ;
		case FP_UFLW		: type = CI_E_fpFLTUND ; break ;
		case FP_INXACT		: type = CI_E_fpINXACT ; break ;
		case FP_DIVZ		: type = CI_E_fpFDIVZR ; break ;
		case FP_INVLD		: type = CI_E_fpINVOPR ; break ;
		case FP_IN_OVFLW	: type = CI_E_fpINXOVR ; break ;
		case FP_IN_UFLW		: type = CI_E_fpINXUND ; break ;
	}

	strcpy( ci__hint, CIexmessage( type ) ) ;
	if( _fpfault != NULL ) {
		switch( _fpfault->operation ) {
			default		: op = 0		; break ;
			case FP_ADD	: op = CI_E_fpADDITN	; break ;
			case FP_SUB	: op = CI_E_fpSUBTRC	; break ;
			case FP_MULT	: op = CI_E_fpMULTPL	; break ;
			case FP_DIV 	: op = CI_E_fpDIVISN	; break ;
			case FP_SQRT	: op = CI_E_fpSQROOT	; break ;
			case FP_REM	: op = CI_E_fpREMAIN	; break ;
			case FP_CONV	: op = CI_E_fpCONVRT	; break ;
			case FP_RNDI	: op = CI_E_fpRNDING	; break ;
			case FP_CMPT	:
			case FP_CMP	: op = CI_E_fpCOMPAR	; break ;
			case FP_NEG	: op = CI_E_fpNEGOPR	; break ;
			case FP_ABS	: op = CI_E_fpABSVAL	; break ;
		}
		strcat( ci__hint, op ? CIexmessage( op ) : "." ) ;
	}
} /* CIfpehandler */
#endif
/*----------------------------------------------------------------------------*/
int CIerrexc( coev, runp, file, sig, instr )
					CIco_resp		*coev	;
					CIruntime		*runp	;
					char 			*file	;
					int			sig 	;
					struct ci_instruction	*instr	; {

/* -- Returns always FALSE: execution cannot be resumed after such an error.
      The 5th diagnostic line is reserved for a tentative of explanation...
   -- */
	char why[500], buf[5][MAXLENGTH+1], *ln[5] ; int u ;

	strcat( strcpy( why, CIexmessage( CI_E_sgFTITLE ) ), " " ) ;
	switch( sig ) {
		case SIGBUS	: u = CI_E_sgBUSERR ; break ;
		case SIGFPE	: u = CI_E_sgFLOATX ; break ;
		case SIGSEGV	: u = CI_E_sgMEMFLT ; break ;
		case SIGSYS	: u = CI_E_sgSYSCAL ; break ;
		case SIGILL	: u = CI_E_sgILLINS ; break ;
	}
	strcat( why, CIexmessage( u ) ) ;
	for( u = 0 ; u < 5 ; u++ ) ln[u] = memset( buf[u], 0, MAXLENGTH + 1 ) ;
	ci__hint = ln[4] ; *ci__hint = '\0' ;
	CIdmpinstr( instr, ln ) ;
#ifdef DEBUG
for( u = 0 ; u < 5 ; u++ ) printf( "1: line %d <%s>\n", u , ln[u] ) ;
#endif
	for( u = 0 ; u < 5 ; u++ ) if( *ln[u] == '\0' ) ln[u] = NULL  ;
#ifdef DEBUG
for( u = 0 ; u < 5 ; u++ ) 
	if( ln[u] ) printf( "2 : line %d <%s>\n", u , ln[u] ) ;
	else printf( "2 : line %d is NULL \n", u ) ;
#endif

	CIerror( &u, coev, runp, file, instr->paramlist[instr->nbparam], 'F',
		 why, ln[0], ln[1], ln[2], ln[3], ln[4] ) ;
	CIresume = FALSE ;
	return FALSE ;
}
/*----------------------------------------------------------------------------*/
static void putblanks( b, size ) char *b ; int size ; {
	register int u ;
	for( u = strlen( b ) ; u < size ; u++ ) b[u] = ' ' ;
}
/*----------------------------------------------------------------------------*/
static void CIdmpchar( c, n, buf ) char c, buf[MAXLENGTH/PMPERLINE+1] ;
				   int n ; {

/* -- Format "n:'c'(i=<integer>)(o=<octal>)(x=<hexa>)" if printable else
             "n:'^<control>'-<ascii>(i=<integer>)(o=<octal>)(x=<hexa>)"
   -- */
   static char *ascii[] =
		{	"nul", "soh", "stx", "etx", "eot", "enq", "ack", "bel",
   			"bs" , "ht" , "nl" , "vt" , "np" , "cr" , "so" , "si" ,
   			"dle", "dc1", "dc2", "dc3", "dc4", "nak", "syn", "etb",
   			"can", "em" , "sub", "esc", "fs" , "gs" , "rs" , "us" ,
   		} ;

	if( isprint( c ) ) {
		sprintf( buf, "%d:'%c'     ,i=%3d,o=%03o,x=%#x", n, c, c, c, c ) ;
	} else if( iscntrl( c ) ) {
		if( c == 0x7F ) {
			sprintf( buf, "%d:    -del,i=%3d,o=%03o,x=%#x", n, c, c, c ) ;
		} else {
			sprintf( buf, "%d:'^%c'-%3s,i=%3d,o=%03o,x=%#x",
			          n, toupper( c + '`' ), ascii[c], c, c, c ) ;
		}
	} else {
		sprintf( buf, "%d:i=%3d,o=%03o,x=%#x", n, c, c, c ) ;
	}

} /* CIdmpchar */
/*----------------------------------------------------------------------------*/
static void CIchkpointer( iptr, n ) int iptr, n ; {

/* -- Checks if a pointer contains a valid address.
      NOTE: though being a (very) bad address, NULL is accepted since it is
            often used as a flag.
   -- */
	char *sbrk() ;

  if( *ci__hint == '\0' ) {
  	if( ci_data->varflagtable[iptr] & CI_FNPT ) {
		if( cival( iptr ) >= (char *) &etext ) {
			sprintf( ci__hint, CIexmessage( CI_E_sgBADFPT ), n ) ;
		}
  	} else {
		if(    (    cival( iptr ) >  (char *)NULL
		         && cival( iptr ) <  (char *) &etext )
	    	    ||  cival( iptr ) >= sbrk( 0 )            ) {
			sprintf( ci__hint, CIexmessage( CI_E_sgBADPTR ), n ) ;
		}
	}
  }
} /* CIchkpointer */
/*----------------------------------------------------------------------------*/
static void CIfcnargs( list, npm, lines, inc )	short	*list	;
						int	npm, inc;
						char	**lines ; {

/* -- MAXPMLINS lines available.
   -- */
	char *arg[MAXPMPRNT] ; int i, j ;

  for( i = 0 ; i < MAXPMPRNT ; i++ )
	arg[i] =   lines[i/PMPERLINE]
	         + ( i % PMPERLINE ) * ( MAXLENGTH / PMPERLINE ) ;

  if( npm / inc > MAXPMPRNT ) npm = MAXPMPRNT * inc ;

    for( i = 0 ; i < npm ; i += inc ) {
    	j = i / inc ;
    	if( ci_data->vartypetable[list[i]] & PTR ) {
    		sprintf( arg[j], "%d:pointer %u", j + 1, p_cival( list[i] ) ) ;
    		CIchkpointer( list[i], j ) ;
    	} else if( ci_data->vardimtable[list[i]] ) {
    		sprintf( arg[j], "%d:array %u"  , j + 1,  cival( list[i] ) ) ;
    	} else switch( ci_data->vartypetable[list[i]] ) {
	   case CI_CHAR	  : CIdmpchar( c_cival( list[i] ), j + 1, arg[j] ) ;
		   	    break ;
	   case CI_SHORT  : sprintf( arg[j], "%d:%d"      , j + 1,
	   				s_cival( list[i] ) ) ;
		   	    break ;
	   case CI_GROBJ  : sprintf( arg[j], "%d:objid %u", j + 1,
	   				o_cival( list[i] ) ) ;
		   	    break ;
	   case CI_INT    : sprintf( arg[j], "%d:%d"       , j + 1,
	   				i_cival( list[i] ) ) ;
		   	    break ;
	   case CI_DOUBLE : sprintf( arg[j], "%d:%e"       , j ,
	   				d_cival( list[i] ) ) ;
		   	    break ;
	   case CI_STRUCT : sprintf( arg[j], "%d:union/struct", j + 1 ) ;
		   	    break ;
	}
#ifdef DEBUG
printf( "arg[%d] 1 : <%s>\n", j + 1, arg[j] ) ;
#endif
	putblanks( arg[j], MAXLENGTH / PMPERLINE ) ;
#ifdef DEBUG
printf( "arg[%d] 2 : <%s>\n", j + 1, arg[j] ) ;
#endif
    }

} /* CIfcnargs */
/*----------------------------------------------------------------------------*/
static void CIchkfcnaddr( ifcn ) int ifcn ; {

/* -- Checks if function has a valid address. Here a function pointer with a
      NULL value is not accepted since it is used to call a function.
      WARNING: message is erroneous if function's address is absolute (ABS).
   -- */
	char *sbrk() ;

	if(    cival( ifcn ) >= (char *) &etext
	    && cival( ifcn ) <= sbrk( 0 ) /* To catch (ABS) */
	    || cival( ifcn ) == NULL		) {
		if( *ci__hint == '\0' ) {
			if( ci_data->varflagtable[ifcn] & CI_FNPT )
				strcpy( ci__hint, CIexmessage( CI_E_sgFCNPTR ) );
			else	strcpy( ci__hint, CIexmessage( CI_E_sgFCNADR ) );
		}
	}
}
/*----------------------------------------------------------------------------*/
static void CIdmpinstr( I, ln ) struct ci_instruction *I ; char **ln ; {

	short		L		;
	int		u = 0, gap, npm ;
	char		*msg 		;

  L = strlen( strcpy( ln[u], CIexmessage( CI_E_sgDIAGNO ) ) ) ;
  strcat( ln[u], " " ) ; L += 1 ;

  switch( I->type ) {
/* --	In library call: the instruction format is:
	0: function 1...n: arguments
   -- */
	case FCALL	: msg = CIexmessage( CI_E_sgLIBCAL )	;
			  strcat( strcpy( ln[u] + L, msg ), " " );
			  L += strlen( msg ) + 1		;
			  gap = 1 ; npm = I->nbparam - 1 ;
			  goto FUNCTION ;

/* --	In external call: the instruction format is:
	0: function ... i: argument #i i+1: alignment of #i i+2: size of #i
	last: var holding returned value
   -- */
	case BRANCHXTRN	: msg = CIexmessage( CI_E_sgEXTCAL )	;
			  strcat( strcpy( ln[u] + L, msg ), " " );
			  L += strlen( msg ) + 1		;
			  gap = 3 ; npm = I->nbparam - 2 ;
#ifdef DEBUG
printf( " CIdmpinstr: npm %d\n", I->nbparam -1 ) ;
#endif
			  CIchkfcnaddr( I->paramlist[0] ) ;
			  FUNCTION :
			  strncpy(	ln[u] + L	,
			  		ci_data->vartable[I->paramlist[0]],
			  		MAXLENGTH - L	) ;
			  ln[u][MAXLENGTH] = '\0' ;
			  CIfcnargs( I->paramlist + 1, npm,
			  	     ln + 1          , gap ) ;
			  break ;
	case IDIVI	:
	case DDIVD	:
	case IDIV	:
	case DDIV	: strcpy( ln[u] + L, CIexmessage( CI_E_sgDIVOPR ) ) ;
			  goto OPERANDS ;
	case IMODI	:
	case IMOD	: strcpy( ln[u] + L, CIexmessage( CI_E_sgMODOPR ) ) ;
			  goto OPERANDS ;
	case CALCINDEX	: strcpy( ln[u] + L, CIexmessage( CI_E_sgINDIRC ) ) ;
			  OPERANDS :
			  	CIfcnargs( I->paramlist + 1, 2, ln + 1, 1 ) ;
			  break ;
	case IASSIGNTI	: 
	case DASSIGNTD	:
	case ASSIGNT	: strcpy( ln[u] + L, CIexmessage( CI_E_sgASSIGN ) ) ;
			  strcpy( ci__hint  , CIexmessage( CI_E_sgBADLHS ) ) ;
			  break ;
	default		: strcpy( ln[u] + L, "?" ) ;
  }

} /* CIdmpinstr */
/*----------------------------------------------------------------------------*/

#endif /* !CI_NO_TRAP_SIG at top */
