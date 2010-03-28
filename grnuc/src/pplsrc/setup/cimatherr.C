/* -- Math function error handler.
   -- */
#include "OMminimum.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "ex.h"
#include "godef.h"
#include "codef.h"
#include "grerr.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"
#include "cimsg.h"
#include "msdef.h"
#include "msmacros.h"
#include <string.h>
#define  _INGR_EXTENSIONS 1
#include <math.h>
#undef _INGR_EXTENSIONS

/* Fix to get the exception structure included on all boxes while
 * compilingunder STDC (standard C).  14-Sep-92
 */
#if defined (__STDC__) && !defined(__clipper__) || defined(__mips__)
#ifndef IRIX5
struct exception {
        int type;
        char *name;
        double arg1;
        double arg2;
        double retval;
};
#endif
#endif

#define  CI_DOMAIN     1
#define  CI_SING       2
#define  CI_OVERFLOW   3
#define  CI_UNDERFLOW  4
#define  CI_TLOSS      5
#define  CI_PLOSS      6

/*----------------------------------------------------------------------------*/
extern char			*CIexmessage()		;
extern char			CIresume, CI_in_math	;
/*----------------------------------------------------------------------------*/

/*--------------------------------------*/

/*
Because of a bug in EG, an EG function call
results in a sqrt: DOMAIN error message.
While waiting for a fix from EG, the simplest
solution is to disable the error display for
this case.  This function will be removed
after the EG fix is in place.  Mike Lanier
*/

static int  matherr_silence = 0;
void   MathErrSilence( int mode )
{
matherr_silence = mode;
}
/*--------------------------------------*/

int matherr( x ) register struct exception *x ; {

	char		Err[80], Arg1[40], Arg2[40], Resl[40], *title, *file ;
	int		rc, act, msgnum, lineno ;
	CIco_resp	*coev	;
	CIruntime	*runp	;

/* -- Only trap errors occured during execution of a ci object, i.e. a ci exists
      and is executing a PPL file.
   -- */
/* RM
	if( CIexecuting() ) {
   end RM */

	if( !CI_in_math ) return matherr_silence ;

	if( CIexecinfo( &file, &lineno, &coev, &runp ) ) {
	  title = CIexmessage( CI_E_maFTITLE ) ;
	  sprintf( Err, "*** %s *** ", x->name ) ;

	  switch( x->type ) {
		case CI_DOMAIN    : msgnum = CI_E_maDOMERR ; break ;
		case CI_SING      : msgnum = CI_E_maSINGUL ; break ;
		case CI_OVERFLOW  : msgnum = CI_E_maOVERFL ; break ;
		case CI_UNDERFLOW : msgnum = CI_E_maUNDRFL ; break ;
		case CI_TLOSS     : msgnum = CI_E_maTTLOSS ; break ;
		case CI_PLOSS     : msgnum = CI_E_maPTLOSS ; break ;
	   }
	   strcat( Err, CIexmessage( msgnum ) ) ;

	   ex$message(	msgnumb	= CI_E_maRESULT	,
			buff	= Resl		,
			type	= "%e"		,
			var	= `x->retval`	) ;

	   if(    !strcmp( x->name, "jn"	)
	       || !strcmp( x->name, "yn"	)
	       || !strcmp( x->name, "pow"	)
	       || !strcmp( x->name, "fmod"	)
	       || !strcmp( x->name, "hypot"	)
	       || !strcmp( x->name, "atan2"	) ) {
		    	
		        ex$message(	msgnumb	= CI_E_maARGFMT	,
		        		buff	= Arg1		,
		        		type	= "%s%e"	,
		        		var	= `"1", x->arg1` ) ;
		        ex$message(	msgnumb	= CI_E_maARGFMT	,
		        		buff	= Arg2		,
		        		type	= "%s%e"	,
		        		var	= `"2", x->arg2` ) ;

			CIerror( &act, coev, runp, file, lineno, 'S',
			         title, Err, Arg1, Arg2, Resl, NULL ) ;
	   } else {
		        ex$message(	msgnumb	= CI_E_maARGFMT	,
		        		buff	= Arg1		,
		        		type	= "%s%e"	,
		        		var	= `"", x->arg1` ) ;

			CIerror( &act, coev, runp, file, lineno, 'S',
			         title, Err, Arg1, Resl, NULL, NULL ) ;
	   }
	   rc = 1 ;
	} else rc = 0 ;

	return rc ;

} /* matherr */
/*----------------------------------------------------------------------------*/

