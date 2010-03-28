/*
** ciextern.C
**
** Dominique GARDELLA
**
*/

 
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

#define	NUM_REG_ARGS	2		/* # subr register arguments */

extern struct instance_ci *ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;
extern char 	errmess[];
extern	char	*malloc();

struct	ret_val  {	/* struct defining values returned from call */
	double	d;
	int	i;
}  ret_val;
extern	struct ret_val *_ci_call();	/* assembly routine */

char	*align_vals;	/* Buffer of alignment values, allocated here, 
			   used by _ci_call assembly routine.
			   These values are subtracted from stack ptr
			   prior to push of individual arguments to
			   provide stack alignment compatible w/ Green Hills
			   compiler stack alignment algorithm.
			*/


/*
 *	ci_call()
 *
 *	Interface to assembly routine to do actual call of function
 *	with specified arguments. Any error checking should be done here.
 *	At present, primary purpose is to construct a list of alignment
 *	values for stack arguments. The _ci_call routine will subtract the
 *	provided alignment value from sp prior to pushing the argument.
 *
 *	The return value of the function whose address is in parameter "f_addr"
 *	is placed in a structure and the address of this structure is returned
 *	by this function. This function will return 0 if invalid parameter
 *	values are detected.
 */

struct ret_val *ci_call(f_addr, nargs, arg_types, arg_sizes, arg_aligns, args)
char	(* f_addr)();
int	nargs;
char	arg_types[];
short	arg_sizes[];		/* used only when arg type is CI_STRUCT */
char	arg_aligns[];		/* used only when arg type is CI_STRUCT */
char	*args[];
{
	int	i;
	int	sp = 0;			/* monitor stack alignment value */
	struct	ret_val  *tmp_ret;	/* use tmp ptr so we can "free" */
	char	*l_align_vals	;	/* Ensures recursive invocations of ci */
#ifdef DEBUG
printf("ci_call: IN\n");
fflush(stdout);
#endif

	if (nargs) {
		if ((l_align_vals = malloc(nargs)) == (char *) 0)
			return((struct ret_val *) 0);
		align_vals = l_align_vals ;
	}
	for (i = 0; i < nargs; i++)
		align_vals[i] = 0;
	for (i = nargs - 1; i >= 0; i--)  {
		switch (arg_types[i])  {
			case CI_CHAR:
			case CI_SHORT:
			case CI_INT:
			case CI_GROBJ:
				if (i < NUM_REG_ARGS)  /* don't change sp if */
					continue;      /* register parameter */
				sp += sizeof(int);
				break;
			case CI_DOUBLE:	/* must be aligned to 8 bytes */
				if (i < NUM_REG_ARGS)
					continue;
				if (sp & (sizeof(double) - 1))  {
					add_alignment(i, nargs, arg_types);
					sp = (sp + sizeof(double) - 1) & 
						~(sizeof(double) - 1);
				}
				sp += sizeof(double);
				break;

			case CI_STRUCT:
				/* size should be multiple of alignment */
				if (arg_sizes[i] & (arg_aligns[i] - 1))
					return((struct ret_val *) 0);
				if (arg_aligns[i] == sizeof(double))  {
					if (sp & (sizeof(double) - 1))  {
						add_alignment(i, nargs, 
								arg_types);
						sp = (sp + sizeof(double)-1) &
							~(sizeof(double) - 1);
					}
				}
				sp += arg_sizes[i];
				break;
			default:
				return((struct ret_val *) 0);
		}
	}

#ifdef DEBUG
printf("ci_call: before add_alignment\n");
fflush(stdout);
#endif

	/* The stack must be 8-byte aligned for all calls */
	if (sp & (sizeof(double) - 1))
		add_alignment(NUM_REG_ARGS, nargs, arg_types);

#ifdef DEBUG
printf("ci_call: after add_alignment\n");
fflush(stdout);
#endif
#ifdef DEBUG 
for( i = 0 ; i < nargs ; i++ ) {
printf( "ci_call : al = %d, sz = %d type = %d align_vals %u\n",
	arg_aligns[i], arg_sizes[i], arg_types[i], align_vals[i] ) ;
fflush( stdout ) ;
}
#endif

	tmp_ret = _ci_call(f_addr, nargs, arg_types, arg_sizes, args);

#ifdef DEBUG
printf("ci_call: after _ci_call\n");
fflush(stdout);
#endif

	if (nargs)
		free(l_align_vals);

#ifdef DEBUG
printf("ci_call: OUT\n");
fflush(stdout);
#endif

	return(tmp_ret);
}


/*	add_alignment()
 *
 *	This routine mimics the Green Hills compiler stack parameter alignment
 *	algorithm by searching from the current argument index toward higher
 *	indices for sequences of 4-byte (pushed) arguments, (only floating and
 *	structure args are not considered 4-byte arguments), setting the
 *	highest indexed 4-byte argument's "align_val" entry to 4.
 *
 *	This routine is necessary because the compiler algorithm will subtract
 *	4 from the stack pointer at the beginning, (right to left argument 
 *	evaluation), of one or more general register pushes if the argument 
 *	to follow the pushes requires an 8-byte alignment.
 */

add_alignment(cur_index, numargs, arg_types)
int	cur_index;
int	numargs;
char	arg_types[];
{
	int	i;

	/* only look for stack 4-byte parameters (i.e. skip register parms)*/
	i = (cur_index < NUM_REG_ARGS) ? (NUM_REG_ARGS + 1) : (cur_index + 1);

	for (; i < numargs; i++)	{
		switch (arg_types[i])  {
		/*	case CI_FLOAT: */
			case CI_DOUBLE:
			case CI_STRUCT:
				align_vals[i - 1] = 4;
				return;
			default:
				break;
		}
	}
	align_vals[numargs - 1] = 4;	/* add alignment to last arg */
}


cibranchxtrn(instr)

/* Instructions of type BRANCHXTRN have a special format:
   0		: variable carrying the name, type and address of the function
   i		: i-th parameter of function
   i + 1	: alignment of i-th parameter
   i + 2	: size      of i-th parameter
   nbparam -1	: register to be assigned
   nbparam 	: source line number
   
   E.g :	func( p1, p2, p3 ) : 12-parameter instruction
		ifunc, ip1, ap1, sp1, ip2, ap2, sp2, ip3, ap3, sp3, ireg, line

   Modified: February 3, 1988 by Alain FALASSE to accommodate struct args.
   Returns 1 when O.K., 0 otherwise.
*/

struct ci_instruction *instr;
{
    int		nargs;				/* number of arguments */
    char	arg_types[MAXPARAM];
    short	arg_sizes[MAXPARAM];		/* for arg. of type struct */
    char	arg_aligns[MAXPARAM];		/* id. */
    char	*arg_vals[MAXPARAM];
    short	param;				/* to speed up access */
    register	i, ia;

/* format the arguments and call the function */
    nargs = ( instr->nbparam - 2 ) / 3 ;


#ifdef DEBUG 
printf( "cibranchxtrn : function <%s> nargs = %d\n",
	ci_data->vartable[instr->paramlist[0]], nargs ) ; fflush( stdout ) ;
#endif
    for( ia = 1, i = 0 ; i < nargs ; i++, ia += 3 ) {

	param = instr->paramlist[ia] ;

	arg_aligns[i]	= instr->paramlist[ia+1];
	arg_sizes[i]	= instr->paramlist[ia+2];
	if (    isarray(param)
/* --		Argument is an external function ?
   -- */
	     ||     ( ci_data->varflagtable[param] & CI_FUNC )
	     	&&  ( ci_data->varflagtable[param] & CI_XTRN )
	     	&& !( ci_data->varflagtable[param] & CI_FNPT ) ) {
	    arg_types[i] = CI_INT;
	    arg_vals[i] = (char *)&cival(param);
	} else if ( ispointer(param) || isGRobj(param) ) {
	    arg_types[i] = CI_INT;
	    arg_vals[i] = cival(param);
	} else if ( isstruct(param) ) {
	    arg_types[i]	= CI_STRUCT	;
	    arg_vals[i]		= cival(param)	;
	} else {
	    arg_types[i]	= ci_data->vartypetable[param];
	    arg_vals[i]		= cival(param);
	}
#ifdef DEBUG 
printf( "cibranchxtrn : <%s> al = %d, sz = %d type = %d \n",
	ci_data->vartable[param], arg_aligns[i], arg_sizes[i], arg_types[i]
	) ;
fflush( stdout ) ;
#endif
    }
    param = instr->paramlist[0];

#ifdef DEBUG
printf("Before ci_call\n");printf("faddr = %d\n", (int)(cival(param)));
for (i=0; i<nargs; i++)
  printf("%d: types %d, vals %d al %d sz %d\n", i, arg_types[i],
	  	 (int)(arg_vals[i]),arg_aligns[i], arg_sizes[i] );
fflush(stdout);
#endif

#ifdef DEBUG
  printf( "ciextern.c <%s> fun ptr ? %d\n",
  			ci_data->vartable[param],
  			ci_data->varflagtable[param] & CI_FNPT ) ;
  fflush( stdout ) ;
#endif
    ci_call( (char (*)())(int)( ci_data->varflagtable[param] & CI_FNPT
				? p_cival( param ) : cival(   param ) ),
             nargs, arg_types, arg_sizes, arg_aligns, arg_vals);

#ifdef DEBUG
printf("After ci_call\n");
fflush(stdout);
#endif

/* assign the register */
    param = instr->paramlist[instr->nbparam - 1];
    if ( ispointer(param) )
	i_cival(param) = ret_val.i;
    else {
#ifdef DEBUG
  printf( "retval type is %d\n", ci_data->vartypetable[param] ) ;
fflush(stdout);
#endif
    	switch (ci_data->vartypetable[param])
    {
      case CI_VOID	: break ;
      case CI_CHAR	: c_cival(param) = ret_val.i; break;
      case CI_SHORT	: s_cival(param) = ret_val.i; break;
      case CI_INT	: i_cival(param) = ret_val.i; break;
      case CI_GROBJ	: o_cival(param) = ret_val.i; break;
      case CI_DOUBLE	: d_cival(param) = ret_val.d; break;
      default:		/* defensive programming */
	sprintf(errmess, "Unexpected external function type: %d\n",
		ci_data->vartypetable[param]);
	erreur(errmess);
	return 0;
    }
    }
#ifdef DEBUG
  printf( "cibranchxtrn EXIT\n" ) ;
fflush(stdout);
#endif

    return 1;
}
