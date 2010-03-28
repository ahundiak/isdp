/*
** cioper.c
**
**   Contains the specialized functions that executes various operations on 
** variables (arithmetic, boolean, etc ...).
**
** Dominique GARDELLA. ISDC, Paris.
*/

 
#include "OMminimum.h"
#include "OMmacros.h"
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

#define SOFT_ERR(text,number)		/* software error */ \
    sprintf(errmess, "%s\tline %d: %s %d", __FILE__, __LINE__, text, number); \
    erreur(errmess);

extern struct instance_ci *ci_data;
extern char	**ci_data_varvaltable;
extern char	*ci_data_info;
extern char errmess[];


double ci_give_value(i)
/*
**   Returns the value of the variable, whose index is i, as a DOUBLE,
** if the variable is numeric.
*/
int i;
{
    char *addr = ci_data_varvaltable[i];
    
    switch( ci_data->vartypetable[i] )
    {
      case CI_CHAR:
        return (double)(*addr);
      case CI_SHORT:
	return (double)(*(short *)addr);
      case CI_INT:
      case CI_GROBJ:
	return (double)(*(int *)addr);
      case CI_DOUBLE:
	return *(double *)addr;
    }

    if ( ci_data->vartypetable[i] & PTR )
	return (double)(*(int *)addr);		/* Just like an 'int' */

    /* software error */
    sprintf(errmess,
	  "%s\tline %d: variable %s of type %d", __FILE__, __LINE__,
	   ci_data->vartable[i], ci_data->vartypetable[i]);
    erreur(errmess);
    return 0.;				/* dummy value */
}


int ci_give_intvalue(i)
/*
**   Returns the value of the variable, whose index is i, as an INTEGER,
** if the variable is numeric.
*/
int i;
{
    char *addr = ci_data_varvaltable[i];
    
    switch( ci_data->vartypetable[i] )
    {
      case CI_CHAR:
        return (int)(*addr);
      case CI_SHORT:
	return (int)(*(short *)addr);
      case CI_INT:
      case CI_GROBJ:
	return (int)(*(int *)addr);
    }

    if ( ci_data->vartypetable[i] & PTR )
	return (int)(*(int *)addr);	/* Just like an 'int' */

    /* software error */
    sprintf(errmess,
	  "%s\tline %d: variable %s of type %d", __FILE__, __LINE__,
	   ci_data->vartable[i], ci_data->vartypetable[i]);
    erreur(errmess);
    return 0;				/* dummy value */
}


ci_relop(instr)
/*
** Execute a 'relationnal operator' instruction between 2 common type variables.
** The result is affected to an 'int' variable.
** HISTORY
** 	122287 DG:	-string comparison is no longer achieved.
**			-change in the argument list.
*/
struct ci_instruction *instr;
{
    int i0 = instr->paramlist[0],		/* result */
	i1 = instr->paramlist[1],		/* first operand */
	i2 = instr->paramlist[2],		/* second operand */
       *val_i0 = (int *)ci_data_varvaltable[i0],
	rc;

    if ( isdouble(i1) || isdouble(i2) )
    {
 	    double drc = ci_give_value(i1) - ci_give_value(i2);
	    if( drc == 0. ) rc = 0;
	    else if( drc < 0. ) rc = -1;
	    else rc = 1;            
    }
    else
/* 122287 DG:  rc = (int)(ci_give_value(i1) - ci_give_value(i2)); */
            rc = ci_give_intvalue(i1) - ci_give_intvalue(i2);
    
/* Evaluate result */
    switch ( instr->type )
    {
      case EQ:
	*val_i0 = !rc;
	return ISUCCESS;
      case NE:
	*val_i0 = rc;
	return ISUCCESS;
      case GE:
	*val_i0 = (rc >= 0);
	return ISUCCESS;
      case LE:
	*val_i0 = (rc <= 0);
	return ISUCCESS;
      case LT:
	*val_i0 = (rc < 0);
	return ISUCCESS;
      case GT:
	*val_i0 = (rc > 0);
	return ISUCCESS;
    }
         
    SOFT_ERR("Unknown instruction", instr->type)
    return IFAILED;
}


double_arop(instr)
/*
** Execute an 'arithmetic operator' instruction.
** The result is assigned to a 'double float' variable.
** HISTORY
**	010888: The initial argument list order is kept.
** CREATION
**	122287
** AUTHOR
**	DG
*/
struct ci_instruction *instr;
{
    double     *val_i0 = (double *)ci_data_varvaltable[instr->paramlist[0]],
		val1 = ci_give_value(instr->paramlist[1]),
		val2 = ci_give_value(instr->paramlist[2]);

    switch ( instr->type )
    {
      case DADD:
	*val_i0 = val1 + val2;
	return ISUCCESS;
      case DMIN:
        *val_i0 = val1 - val2;
	return ISUCCESS;
      case DMUL:
        *val_i0 = val1 * val2;
	return ISUCCESS;
      case DDIV:
        *val_i0 = val1 / val2;
	return ISUCCESS;
    }

    SOFT_ERR("Unknown instruction", instr->type)
    return IFAILED;
}


int_arop(instr)
/*
**   Execute an 'arithmetic operator' instruction between two integers.
** The result is assigned to an 'int' variable.
** NOTES
** 	Here a 'GRobj' is considered a true integer.
** CREATION
**	122287
** AUTHOR
**	DG
*/
struct ci_instruction *instr;
{
    int *val_i0 = (int *)ci_data_varvaltable[instr->paramlist[0]],
	 val1 = ci_give_intvalue(instr->paramlist[1]),
         val2 = ci_give_intvalue(instr->paramlist[2]);

    switch ( instr->type )
    {
      case IADD:
	*val_i0 = val1 + val2;
	return ISUCCESS;
      case IMIN:
        *val_i0 = val1 - val2;
	return ISUCCESS;
      case IMUL:
        *val_i0 = val1 * val2;
	return ISUCCESS;
      case IDIV:
        *val_i0 = val1 / val2;
	return ISUCCESS;
      case IMOD:
        *val_i0 = val1 % val2;
	return ISUCCESS;
    }

    SOFT_ERR("Unknown instruction", instr->type)
    return IFAILED;
}


ci_binbit_op(instr)
/*
**   Execute a 'binary bitwise operator' instruction. We assume that all
** necessary tests have been done at parsing time, i.e. the two operands
** must be integer values.
** The result is affected to an 'int' variable.
*/
struct ci_instruction *instr;
{
    int *val_i0 = (int *)ci_data_varvaltable[instr->paramlist[0]],
	 val1 = ci_give_intvalue(instr->paramlist[1]),
         val2 = ci_give_intvalue(instr->paramlist[2]);

    switch( instr->type )
    {
      case BITAND:
	*val_i0 = val1 & val2;
	return ISUCCESS;
      case BITOR:
	*val_i0 = val1 | val2;
	return ISUCCESS;
      case BITEOR:
	*val_i0 = val1 ^ val2;
	return ISUCCESS;
    }

    SOFT_ERR("Unknown instruction", instr->type)
    return IFAILED;
}
