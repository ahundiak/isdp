/* -- This module implements the PPL library function CIdpdynamics, which
      invokes dp$dynamics with the function PPLdynamics. In turn, PPLdynamics
      will invoke a function in a PPL files with the arguments usually passed
      to a dynamics handler.
   -- */
class implementation ci ;

#include <stdio.h>
#include "dpmacros.h"
#include "ciinclude.h"
#include "ciexecmacros.h"
#include "cierrordef.h"
#include "cierrmacros.h"
#include "ciprivmacros.h"
#include "dpstruct.h"

extern char			**ci_data_varvaltable ;
extern struct instance_ci	*ci_data ;
/*----------------------------------------------------------------------------*/
typedef struct	{
	char		*dynfile , /* Name of PPL file containing handler */
			*dynfunc ; /* Name of handler function		  */
	OM_S_OBJID	 dynciid ; /* Object id of ci running PPL file	  */
	void		*usrargs ; /* User arguments passed to handler	  */
	long		pplexrc	 ; /* Completion code of PPLdynamics	  */
} CIdynargs ;
/*----------------------------------------------------------------------------*/
int PPLdynamics(	dynargs	, /* Args passed to dp$dynamics		    */
			crsrpos	, /* Current cursor position, world coords  */
			windmat	, /* rot matrix of window related to cursor */
			objects	, /* List of objects which are in dynamics  */
			obcount	, /* Count of objects in above list	    */
			dynbuff	, /* Lists of buffered elements in dynamics */
			bfcount	, /* Count of buffers in above list	    */
			in_dum1	, /* The six arguments below are not used   */
			in_dum2	,
			in_dum3	,
			outdum1	,
			outdum2	,
			outdum3	)
	CIdynargs		*dynargs ;
	struct EX_button	*crsrpos ;
	IGRdouble			*windmat ;
	struct GRid		*objects ;
	int			*obcount ;
	struct DPele_header	*dynbuff ;
	int			*bfcount ;
	char			*in_dum1 ,
				*in_dum2 ,
				*in_dum3 ,
				**outdum1,
				**outdum2,
				**outdum3 ; {

/* -- Dynamics handler. This function is passed as arguments to dp$dynamics.
      Its arguments are fixed. See I/DRAFT DEVELOPMENT PLATFORM PROGRAMMER'S
      REFERENCE MANUAL - MACROS, at the entry "dp$dynamics".
      RETURNS : the return code of the PPL dynamics handler which must be one
		of the three below:
			- TRUE
			- FALSE
			- DP_EXIT_DYNAMICS
   -- */
	int		CIsts,		  /* CI completion code		  */
			OMsts,		  /* OM return code		  */
			DYsts		; /* Return code of PPL handler	  */
	CIpushlist	args[13]	; /* Arg list for PPL handler	  */

#ifdef DEBUG
  printf( "PPLdynamics: ENTER, file %s func %s\n", dynargs->dynfile,
  	   dynargs->dynfunc );
  fflush( stdout ) ;
#endif
	
	args[ 0].addr = &dynargs->usrargs	;	/* Arg #1  */
	args[ 0].size = sizeof dynargs->usrargs ;
	args[ 1].addr = &crsrpos		;	/* Arg #2  */
	args[ 1].size = sizeof crsrpos		;
	args[ 2].addr = &windmat		;	/* Arg #3  */
	args[ 2].size = sizeof windmat		;
	args[ 3].addr = &objects		;	/* Arg #4  */
	args[ 3].size = sizeof objects		;
	args[ 4].addr = &obcount		;	/* Arg #5  */
	args[ 4].size = sizeof obcount		;
	args[ 5].addr = &dynbuff		;	/* Arg #6  */
	args[ 5].size = sizeof dynbuff		;
	args[ 6].addr = &bfcount		;	/* Arg #7  */
	args[ 6].size = sizeof bfcount		;
	args[ 7].addr = &in_dum1		;	/* Arg #8  */
	args[ 7].size = sizeof in_dum1		;
	args[ 8].addr = &in_dum2		;	/* Arg #9  */
	args[ 8].size = sizeof in_dum2		;
	args[ 9].addr = &in_dum3		;	/* Arg #10 */
	args[ 9].size = sizeof in_dum3		;
	args[10].addr = &outdum1		;	/* Arg #11 */
	args[10].size = sizeof outdum1		;
	args[11].addr = &outdum2		;	/* Arg #12 */
	args[11].size = sizeof outdum2		;
	args[12].addr = &outdum3		;	/* Arg #13 */
	args[12].size = sizeof outdum3		;

	ci$push( argc = 13, argv = args ) ;

	CIsts = 1 ;
	OMsts = ci$f_execute(	file		= dynargs->dynciid,
				entry		= dynargs->dynfunc,
				retval		= (char *)&DYsts,
				retsize		= sizeof DYsts,
				senderid	= NULL_OBJID,
				action		= &CIsts ) ;

	if( !( OMsts & SUCC ) ) {
		dynargs->pplexrc = CI_E_FATAL_ERROR ;
		DYsts = FALSE ;
	} else {
		dynargs->pplexrc = CIsts ;
		if( CIsts != CI_S_SUCCESS ) {
			DYsts = FALSE ;
		}
	}
#ifdef DEBUG
  printf( "PPLdynamics: EXIT(%d)\n", DYsts );
#endif
	return DYsts ;

} /* PPLdynamics */
/*----------------------------------------------------------------------------*/
#argsused
int CIdpdynamics( ins, evdata, runparms, state )

	struct ci_instruction	*ins		;
	CIco_resp		*evdata		;
	CIruntime		*runparms	;
	short			*state		; {

/* -- Implements PPL library function `CIdpdynamics'.
      INPUT   : ins, PPL instruction.
                evdata, unused but included for generality.
      RETURNS : always TRUE.
      Arguments of PPL's CIdpdynamics :
	1 : name of PPL file where dynamics handler function is.
	2 : name of dynamics handler function.
	3 : pointer to user information to be passed to above function.
	4 : flags for dp$dynamics.
	5 : pointer to int to store completion code:
		CI_S_SUCCESS 	 : OK
		CI_E_FATAL_ERROR : dp$dynamics failed.
		or the return code of PPLdynamics (See above).
	PPL's CIdpdynamics returns TRUE if the completion code (arg #5) is
	CI_S_SUCCESS else FALSE.
   -- */

	enum CIdynindex	{	CIDYNRC = 0, DYNFILE = 1, DYNFUNC = 2,
				USRARGS = 3, DYNFLGS = 4, RETCODE = 5
	} ;
	register short	*pm	;
	CIdynargs	args	;
	int		*retcode;

	pm = ins->paramlist ;

	args.dynfile	= st_cival( pm[DYNFILE] ) ;
	args.dynfunc	= st_cival( pm[DYNFUNC] ) ;
	args.usrargs	= st_cival( pm[USRARGS] ) ;
	retcode		= (int *)st_cival( pm[RETCODE] ) ;
#ifdef DEBUG
  printf( "CIdpdynamics: ENTER, file %s func %s\n", args.dynfile, args.dynfunc );
  fflush( stdout ) ;
#endif

	if( ci$load(	file_name	= args.dynfile		,
			file_id		= &args.dynciid		,
			sender_id	= evdata->ci_id		,
			sender_os	= OM_Gw_TransOSnum_0	,
			stat		= retcode		) ) {

/* --		Check that dynamics function exist in file.
   -- */
		ci$is_entry_point(	stat	= retcode,
					file	= args.dynciid,
					entry	= args.dynfunc,
					senderid= evdata->ci_id ) ;
		if( *retcode == CI_S_SUCCESS ) {
			args.pplexrc = CI_S_SUCCESS ;
			if( dp$dynamics(
				dyn_fun		= PPLdynamics,
				information	= &args,
				flags		= i_cival( pm[DYNFLGS] ) ) ) {
					*retcode = args.pplexrc ;
			} else {
					*retcode = CI_E_FATAL_ERROR ;
			}
		}
		ci$delete(	file_name	= args.dynfile,
				file_id		= args.dynciid ) ;
	}
	i_cival( pm[CIDYNRC] ) = *retcode == CI_S_SUCCESS ;

#ifdef DEBUG
  printf( "CIdpdynamics: EXIT\n" );
  ci$report_error( status = *retcode, output = CI_ERR_STDOUT ) ;
#endif
	return TRUE ;

} /* CIdpdynamics */
/*----------------------------------------------------------------------------*/
end implementation  ci ;

