/* $Id: ciexinstr.C,v 1.1.1.1 2001/01/04 21:08:33 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddbg / ciexinstr.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: ciexinstr.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:33  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

/*
** ciexinstr.c
**
**   Contains the general function that executes the instructions. Depending on
** the instruction complexity, a specialized function is called, or the job is
** done here.
** 
** Etienne BEEKER, Dominique GARDELLA, Alain FALASSE. ISDC, Paris.
*/

#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
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
#include "msdef.h"
#include "msmacros.h"
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"
#include "cimsg.h"
#include "cierrordef.h"
#include "cierrmacros.h"
#include "cisetup.h"
#include <signal.h>
#include <string.h>


#define SOFT_ERR(text,number)		/* software error */ \
    sprintf(errmess, "%s\tline %d: %s %d", __FILE__, __LINE__, text, number); \
    erreur(errmess);


extern struct		instance_ci *ci_data ;
extern char		**ci_data_varvaltable;
extern char		*ci_data_info;
extern char		errmess[];
extern OM_S_OBJID	ci_id	;
double 			ci_give_value();

static char			*cix__Type, **cix__Addr	;
static struct ci_instruction	*cix__Code,  *cix__Inst	;
static short			*cix__List		;
unsigned short			*cix__Dimn		;
static CIruntime		*cix__Renv		;
static CIco_resp		*cix__Coev		;
static OM_S_OBJID		cix__ciid		;
char				*CIexmessage()		;

#define	DEBUG	1

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

static void CIrestore_env __((CItraps *sigenv));
static void CIcatch __((int sig));
static void CIsignals __((CItraps *sigenv));

#if defined(__cplusplus)
}
#endif
#undef __



/* -- MACROS -----------------------------------------------------------------*/
/* -- Shorter forms.
   -- */
#define PM	(cix__List)

#define Val(i)		(			cix__Addr[i])
#define dVal(i)		( *( (double	 *)	cix__Addr[i]))
#define iVal(i)		( *( (int	 *)	cix__Addr[i]))
#define sVal(i)		( *( (short 	 *)	cix__Addr[i]))
#define oVal(i)		( *( (OM_S_OBJID *)	cix__Addr[i]))
#define cVal(i)		( *(			cix__Addr[i]))
#define pVal(i)		( *((char 	**)	cix__Addr[i]))
#define stVal(i)	( cix__Type[i] & PTR ? pVal(i) : Val(i) )

#define aPM(i)		(			cix__Addr[PM[i]])
#define dPM(i)		( *( (double	 *)	cix__Addr[PM[i]]))
#define iPM(i)		( *( (int	 *)	cix__Addr[PM[i]]))
#define sPM(i)		( *( (short 	 *)	cix__Addr[PM[i]]))
#define oPM(i)		( *( (OM_S_OBJID *)	cix__Addr[PM[i]]))
#define cPM(i)		( *(			cix__Addr[PM[i]]))
#define pPM(i)		( *((char 	**)	cix__Addr[PM[i]]))

#define PTRorARR(i)	( cix__Dimn[i] ? Val(i) : pVal(i) )

#define INT(u)		((int) ci_give_value(u))

#define SWTYP( ipm, ivar, err, ival )					\
	switch( cix__Type[(ivar) = PM[(ipm)]] ) {			\
	      case CI_CHAR	: (ival) = cVal(ivar)		; break;\
	      case CI_SHORT	: (ival) = sVal(ivar)		; break;\
	      case CI_INT	: (ival) = iVal(ivar)		; break;\
	      case CI_DOUBLE	: (ival) = dVal(i1) != 0	; break;\
	      default		: erreur( err )			; STOP ;\
	}
/*----------------------------------------------------------------------------*/
#if !CI_NO_SIG_TRAP
static void CIrestore_env( sigenv ) CItraps *sigenv ; {

/* -- Resets signals to their previous values.
   -- */
#ifdef DEBUG
  printf( "CIrestore_env: ENTER\n" ) ; fflush( stdout ) ;
#endif
#ifdef DEBUG
  printf( "CIrestore_env: id %u --------------------------------------\n", ci_id ) ;
  printf( "           bus_error %u flt_error %u mem_fault %u\n",
	  sigenv->bus_error, sigenv->flt_excep, sigenv->mem_fault ) ;
  printf( "           bad_syscl %u ill_instr %u\n", sigenv->bad_syscl,
	  sigenv->ill_instr ) ;
#endif
	signal( SIGBUS , sigenv->bus_error ) ;
	signal( SIGFPE , sigenv->flt_excep ) ;
	signal( SIGSEGV, sigenv->mem_fault ) ;
	signal( SIGSYS , sigenv->bad_syscl ) ;
	signal( SIGILL , sigenv->ill_instr ) ;
/* ERASE
	if( jump ) {
#ifdef DEBUG
  printf( "CIrestore_env: JUMPING\n" ) ; fflush( stdout ) ;
#endif
		longjmp( sigenv->stack_env, 1 )      ;
	}
 end ERASE */
#ifdef DEBUG
  printf( "CIrestore_env: EXIT\n" ) ; fflush( stdout ) ;
#endif
}
/*----------------------------------------------------------------------------*/
static void CIcatch( sig ) int sig ; {

	if( sig == SIGILL ) signal( SIGILL, SIG_IGN ) ;
	CIerrexc( cix__Coev, cix__Renv, ci_data->ficcmd, sig, cix__Inst ) ;
#ifdef DEBUG
  printf( "CIcatch: back from CIerrexc\n" ) ; fflush( stdout ) ;
#endif
/* ERASE	CIrestore_env( TRUE )	; ERASE */

/*	CIset_errno( CI_W_EXEC_ABORTD, ci_data->ficcmd, "%s" )	;*/
	longjmp( cix__Renv->interrupt.stack_env, 1 )      			;
}
/*----------------------------------------------------------------------------*/
static void CIsignals( sigenv ) CItraps *sigenv ; {

	sigenv->bus_error = signal( SIGBUS , CIcatch ) ;
	sigenv->flt_excep = signal( SIGFPE , CIcatch ) ;
	sigenv->mem_fault = signal( SIGSEGV, CIcatch ) ;
	sigenv->bad_syscl = signal( SIGSYS , CIcatch ) ;
	sigenv->ill_instr = signal( SIGILL , CIcatch ) ;
#ifdef DEBUG
  printf( "CIsignals: id %u --------------------------------------\n", ci_id ) ;
  printf( "           bus_error %u flt_error %u mem_fault %u\n",
	  sigenv->bus_error, sigenv->flt_excep, sigenv->mem_fault ) ;
  printf( "           bad_syscl %u ill_instr %u\n", sigenv->bad_syscl,
	  sigenv->ill_instr ) ;
#endif
}
#endif /* !CI_NO_SIG_TRAP */
/*----------------------------------------------------------------------------*/
int CIexecinfo( file, line, coev, runp )

	char		**file	;
	int		*line	;
	CIco_resp	**coev	;
	CIruntime	**runp	; {

	if( om$is_objid_valid(	objid = cix__ciid    ,
				osnum = OM_Gw_TransOSnum_0 ) & OM_S_SUCCESS ) {
		*file = ci_data->ficcmd ;
		*line = cix__Inst->paramlist[cix__Inst->nbparam] ;
		*coev = cix__Coev	;
		*runp = cix__Renv	;
		return TRUE		;
	} else return FALSE ;

} /* CIexecinfo */
/*----------------------------------------------------------------------------*/
int CIlineno() {
	return cix__Inst->paramlist[cix__Inst->nbparam] ;
}
/*----------------------------------------------------------------------------*/
/* -- Flag to resume execution or not after a math function error.
   -- */
char CIresume ;

/* -- Go and execute next instruction.
   -- */
#define GO	goto NEXT

/* -- Stop execution
   -- */
#define STOP	goto FAILURE

#define INIT	cix__Type = ci_data->vartypetable	;\
		cix__Code = ci_data->code		;\
		cix__Addr = ci_data_varvaltable		;\
		cix__Dimn = ci_data->vardimtable		;\
		cix__Renv = runenv			;\
		cix__Coev = coevdata			;\
		cix__ciid = coevdata->ci_id		;
/*----------------------------------------------------------------------------*/
#argsused
int CIexecute( msg, file, program, coevdata, state, runenv )

int		*msg		;
char		*file		;
CIprogseq	*program	;
CIco_resp	*coevdata	;
short		*state		;
CIruntime	*runenv		;	 {

/* -- Due to possibles problems which may arise with setjmp/longjmp for
      automatic or register variables (not being restored to the right values),
      this function's local variables are declared as `static'.
      INPUT	: file, name of PPL file.
      UPDATE	: state, state of running ci object.
      		  coevdata, for interruptions of execution due to calls to the
      		  	event or locate filters.
		: runenv, runtime parameters and data.
      OUTPUT	: msg, completion code (values defined in cierrordef.h).
   -- */
  int	ic, ninstr, compteur, rc, i, i0, i1, i2, val1, val2 ;
  short	*stack, *istack	;
  extern short	CIstop_chk	;

#ifdef DEBUG
  printf( "CIexecute( %s ) ENTER\n", ci_data->ficcmd ) ; fflush( stdout ) ;
#endif
  ic		= program->pc		;
  istack	= &program->istack	;
  stack		= (short *)program->stack	;
  ninstr	= ci_data->nbinstr	;
  compteur	= 0			;
  rc		= CI_EXEC_SUSPNDED	;

  INIT ;
#if !CI_NO_SIG_TRAP
  if( CItrapsigs ) CIsignals( &runenv->interrupt ) ;
#endif
/*
  CI_IGE->interrupt.executing = TRUE ;
 */
  *state |= CI_EXECUTING_PPL ;
  *msg = CI_S_SUCCESS ;
  CIresume = TRUE ;

#ifdef DEBUG
  printf( "EXEC enter\n" ) ; fflush( stdout ) ;
#endif

#if !CI_NO_SIG_TRAP
  if( CItrapsigs ) {
  	if( setjmp( runenv->interrupt.stack_env ) > 0 ) {
#ifdef DEBUG
  printf( "CIexecute: JUMPED, stopping execution of %d\n", ci_id ) ; fflush( stdout ) ;
#endif
/* --		Abort this file.
   -- */
   		*msg = CI_W_EXEC_ABORTD ;
		rc = CI_EXEC_CLEAREVQ ; goto END ;
  	}
  }
#endif
  while( ic < ninstr ) {
/* -- Counter used to avoid infinite loops, note that rhs of `&&' performed only
      if CIstop_chk != 0.
   -- */
  if( CIstop_chk && ( compteur++ % CIstop_chk ) == 0 ) {
		if( IGEstop() ) {
			ex$message( msgnumb = CI_S_exSTOPWN ) ;
			*msg = CI_W_EXEC_ABORTD ;
			IGEresetstop()		;
			sleep( 1 )		;
			rc = CI_EXEC_CLEAREVQ	;
			break			;
 		}
  }

  cix__Inst = cix__Code + ic		;
  cix__List = cix__Code[ic].paramlist	;

  switch( cix__Code[ic].type ) {

  default	  : SOFT_ERR( "unknown instruction", ic ) ; STOP ;
   
  case BRANCHSW   : if( iPM(1) == iPM(2) ) ic = PM[0] ; else ic++ ; break ;

  case DBRANCHCOND: if( dPM(1) ) ic++ ; else ic = PM[0] ; break ;

  case IBRANCHCOND: if( iPM(1) ) { ic++ ; break ; } /* else : no break */

  case BRANCH	  : ic = PM[0] ; break ;

  case BRANCHFUNC : if( *istack >= MAXSTACK ) {
				ex$message( msgnumb = CI_F_exSTCOVR ) ;
				*msg = CI_E_FATAL_ERROR ;
				rc = CI_EXEC_CLEAREVQ	;
				goto END 	;
 		    }
		    stack[(*istack)++] = ic + 1 ;
		    ic = PM[0] ;
		    break ;

  case EXIT_FILE  : rc = CI_EXEC_FINISHED ; goto END ;

  case RETURN	  : if( --(*istack) < 0 ) {
			    	rc = CI_EXEC_FINISHED ; goto END ;
		    } else 	ic = stack[*istack] ;
		    break;

  case FCALL	  : rc = cifcall( cix__Inst, coevdata, runenv, state ) ;
  		    INIT ;
                    goto TEST ;

  case BRANCHXTRN : rc = cibranchxtrn( cix__Inst ) ;
  		    INIT ;
                    goto TEST ;

/* Comparison of variables of type CI_INT */
  case IEQ	: iPM(0) = iPM(1) == iPM(2) ; GO ;
  case INE	: iPM(0) = iPM(1) != iPM(2) ; GO ;
  case IGE	: iPM(0) = iPM(1) >= iPM(2) ; GO ;
  case ILE	: iPM(0) = iPM(1) <= iPM(2) ; GO ;
  case IGT	: iPM(0) = iPM(1)  > iPM(2) ; GO ;
  case ILT	: iPM(0) = iPM(1)  < iPM(2) ; GO ;

/* Comparison of variables of type CI_DOUBLE */
  case DEQ	: iPM(0) = dPM(1) == dPM(2) ; GO ;
  case DNE	: iPM(0) = dPM(1) != dPM(2) ; GO ;
  case DGE	: iPM(0) = dPM(1) >= dPM(2) ; GO ;
  case DLE	: iPM(0) = dPM(1) <= dPM(2) ; GO ;
  case DGT	: iPM(0) = dPM(1)  > dPM(2) ; GO ;
  case DLT	: iPM(0) = dPM(1)  < dPM(2) ; GO ;
 
/* Comparison of common types variables */
  case EQ : case NE : case GE : case LE : case LT : case GT :
			rc = ci_relop( cix__Inst ) ; goto TEST ;

/* Arithmetic between variables of type CI_INT */
  case IADDI	: iPM(0) = iPM(1) + iPM(2) ; GO ;
  case IMINI	: iPM(0) = iPM(1) - iPM(2) ; GO ;
  case IMULI	: iPM(0) = iPM(1) * iPM(2) ; GO ;
  case IDIVI	: iPM(0) = iPM(1) / iPM(2) ; GO ;
  case IMODI	: iPM(0) = iPM(1) % iPM(2) ; GO ;

/* Arithmetic between variables of type CI_DOUBLE */
  case DADDD	: dPM(0) = dPM(1) + dPM(2) ; GO ;
  case DMIND	: dPM(0) = dPM(1) - dPM(2) ; GO ;
  case DMULD	: dPM(0) = dPM(1) * dPM(2) ; GO ;
  case DDIVD	: dPM(0) = dPM(1) / dPM(2) ; GO ;

/* Arithmetic between common type variables */
/* the result is assigned to a variable of type CI_INT */
  case IADD : case IMIN : case IMUL : case IDIV : case IMOD :
	    			rc = int_arop( cix__Inst ) ; goto TEST ;

/* Arithmetic between common type variables */
/* the result is assigned to a variable of type CI_DOUBLE */
  case DADD : case DMIN : case DMUL : case DDIV :
	    			rc = double_arop( cix__Inst ) ; goto TEST ;

/* bitwise operator */
  case BITAND	:
  case BITOR	:
  case BITEOR	: rc = ci_binbit_op( cix__Inst ) ; goto TEST	;
  case BITNEG	: iPM(0) = ~ iPM(1)		; GO		;

/* shift operators */
  case LSHIFT	: iPM(0) = iPM(1) << iPM(2)	; GO ;
  case RSHIFT	: iPM(0) = iPM(1) >> iPM(2)	; GO ;

/* address operator : makes i0  point on i1 */
  case ASSIGNTADDR: aPM(0) = (char *) &aPM(1)	; GO ;

/* logical operators between variables of type CI_INT */
  case IAND	: iPM(0) = iPM(1) && iPM(2)	; GO ;
  case IOR	: iPM(0) = iPM(1) || iPM(2)	; GO ;
  case INEGBOOL	: iPM(0) = ! iPM(1)		; GO ;

/* logical operators between common type variables */
  case AND	: SWTYP( 1, i1, "AND: unknown type", val1 ) ;
	    	  SWTYP( 2, i2, "AND: unknown type", val2 ) ;
	      	  iPM(0) = val1 && val2 ; GO ;

  case OR	: SWTYP( 1, i1, "OR: unknown type", val1 ) ;
	    	  SWTYP( 2, i2, "OR: unknown type", val2 ) ;
	    	  iPM(0) = val1 || val2 ; GO ;

  case NEGBOOL	: switch( cix__Type[i1 = PM[1]] ) {
	      		case CI_CHAR	: iPM(0) = ! cVal(i1) ; GO ;
	     		case CI_SHORT	: iPM(0) = ! sVal(i1) ; GO ;
	      		case CI_DOUBLE	: iPM(0) = ! dVal(i1) ; GO ;
	    	  }
	    	  erreur( "NEGBOOL: unknown type" ) ; STOP ;


/* assignment between variables of type CI_INT, CI_DOUBLE and common */	
  case IASSIGNTI	: iPM(0) = iPM(1) ; GO ;
  case DASSIGNTD	: dPM(0) = dPM(1) ; GO ;
  case ASSIGNT		:

	    switch( cix__Type[i0 = PM[0]] ) {
	      case CI_CHAR	: cVal(i0) = ci_give_value(PM[1])	; GO ;
	      case CI_SHORT	: sVal(i0) = ci_give_value(PM[1])	; GO ;
	      case CI_INT	: iVal(i0) = ci_give_value(PM[1])	; GO ;
	      case CI_DOUBLE	: dVal(i0) = ci_give_value(PM[1])	; GO ;
	      case CI_GROBJ	: oVal(i0) = oPM(1)	 		; GO ;
	    }
	    if( cix__Type[i0] & PTR ) {
		i1 = PM[1] ;
		if( cix__Dimn[i1] || isfunction( i1 ) && isextern( i1 ) ) {
			pVal(i0) = Val(i1) ;
		} else	/* considered to be an int */
	                iVal(i0) = ci_give_intvalue(i1) ;
		GO ;
	    }
	    erreur( "ASSIGNT: unknown type" ) ; STOP ;

  case OPPOS	: switch ( cix__Type[i0 = PM[0]] ) {
	      		case CI_CHAR	: cVal(i0) = - cPM(1); GO ;
	      		case CI_SHORT	: sVal(i0) = - sPM(1); GO ;
	      		case CI_INT	: iVal(i0) = - iPM(1); GO ;
	      		case CI_DOUBLE	: dVal(i0) = - dPM(1); GO ;
	    	  }
	    	  erreur( "OPPOS: unknown type" ) ; STOP ;

  case CALCINDEX:   
	    i0 = PM[0];
	    i1 = PM[1];

	    /* verify the index is not out of range */
	    i = INT( PM[2] ) ;
/* NOTE: i < 0 causes problems if pointer or with citype.h ! */
	    if( i < 0 || ( cix__Dimn[i1] && i >= cix__Dimn[i1] ) ) {
		ex$message(	msgnumb	= CI_E_ixINDVAL	,
				type	= "%d"		,
				var	= `i`		,
				buff	= errmess	) ;

		CIerror( &i,	coevdata,
				runenv,
				ci_data->ficcmd,
				cix__Inst->paramlist[cix__Inst->nbparam],
				'F',
				CIexmessage( CI_E_ixFTITLE ),
				errmess, NULL, NULL, NULL, NULL ) ;
		STOP ;
	    }
	    /* update the pointer for access according to an index */
	    switch( cix__Type[i0] ) {
	    	case CI_CHAR   : Val(i0) = (char *)stVal(i1) + i;
				 break;
	    	case CI_SHORT  : Val(i0) = (char *)((short *)stVal(i1) + i);
				 break;
	    	case CI_INT    : Val(i0) = (char *)((int *) stVal(i1) + i);
				 break;
	    	case CI_DOUBLE : Val(i0) = (char *)((double *)stVal(i1) + i);
				 break;
	    	case CI_GROBJ  : Val(i0) = (char *)((OM_S_OBJID *)stVal(i1)+i);
				 break;

/* --		The 3rd arg contains the size of the struct
   -- */
	    	case CI_STRUCT : Val(i0) = stVal(i1) + i * PM[3] 	; break;
/* --		Array of PTR or pointer to pointer
   -- */
	    	default		: if( cix__Dimn[i1] )
				       Val(i0) = (char *)((char **)Val(i1)+i);
				  else Val(i0) = (char *)((char **)pVal(i1)+i);
	    }
	    GO ;

/* -- Accessing struct field ( We just add bytes ... )
	1 : struct address, 2 : field offset
   -- */
  case STRUCTFIELD	: aPM(0) = (char *) ( (unsigned) aPM(1) + PM[2] ) ; GO ;

/* -- Content of Pointer + Num value ( content of i1 (pointer) + i2 )
	1 : index of Pointer or Array, 2 : index of Num value
   -- */
  case STRUCTPTR	: aPM(0) = (char *) ( PTRorARR(PM[1]) + PM[2]   ) ; GO ;

/* -- Pointer + Num value
	1 : index of Pointer or Array, 2 : index of Num value,
	3 : sizeof *Pointer
   -- */
  case PPLUS	: pPM(0) = PTRorARR(PM[1]) + INT(PM[2]) * PM[3] ; GO ;
  case PMINUS	: pPM(0) = PTRorARR(PM[1]) - INT(PM[2]) * PM[3] ; GO ;

/* -- Pointer - Pointer ( both of the same type )
	1 : index of Pointer or Array, 2 : index of Pointer or Array,
	3 : sizeof *Pointer
   -- */
  case PDELTA	: iPM(0) = ( PTRorARR(PM[1]) - PTRorARR(PM[2]) ) / PM[3] ; GO ;

/* -- Structures equality and difference.
	1 : index of first struct, 2 : index of second struct
	3 : size of structs
   -- */
  case MEMEQU	: iPM(0) = memcmp( aPM(1), aPM(2), PM[3] ) == 0 ; GO ;
  case MEMDIF	: iPM(0) = memcmp( aPM(1), aPM(2), PM[3] ) != 0 ; GO ;

/* -- Structures assignment.
	0 : index of first struct, 1 : index of second struct
	2 : size of structs
   -- */
  case MEMCPY	: memcpy( aPM(0), aPM(1), PM[2] ) ; GO ;

/* -- Function argument stack manipulation
   -- */
  case PUSHADR	: rc = STCpushA( PM[0] )	       ; goto TEST ;
  case PULLADR	: rc = STCpullA( PM[0] )	       ; goto TEST ;
  case PUSHVAL	: rc = STCpushV( PM[0], PM[1], PM[2] ) ; goto TEST ;
  case PULLVAL	: rc = STCpullV( PM[0], PM[1], PM[2] ) ;
   		  TEST : switch( rc ) {
				case ISUCCESS	: NEXT : ic++ ; break ;

				case IFAILED	: FAILURE :
						  *msg	= CI_W_EXEC_ABORTD ;
						  rc	= CI_EXEC_CLEAREVQ ;
						  goto END ;

				case IFLUSH	: ic++ ;

				default		: rc = CI_EXEC_SUSPNDED ;
						  goto END ;
		         }
		  break ;

    } /* switch */
    if( !CIresume ) { rc = CI_EXEC_CLEAREVQ ; goto END ; }
  } /* while */

  rc = CI_EXEC_SUSPNDED	;

  END :
#if !CI_NO_SIG_TRAP
  	if( CItrapsigs ) CIrestore_env( &runenv->interrupt ) ;
#endif
  	program->pc = ic ;
  	*state &= ~CI_EXECUTING_PPL ;
	cix__ciid = NULL_OBJID ;
#ifdef DEBUG
  printf( "END( %d )\n", rc ) ; fflush( stdout ) ;
#endif
        return rc ;

} /* CIexecute */
/*----------------------------------------------------------------------------*/
