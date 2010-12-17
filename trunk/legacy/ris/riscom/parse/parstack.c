/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							parstack.c
**	AUTHORS:						David Michal
**	CREATION DATE:					3/88
**	ABSTRACT:
**		Contains the stack manipulating routines.
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "parser.h"


/*
**	TYPES
*/
typedef struct stack_node
{
	ristree * tp;
	struct stack_node *next;
} stack_node;

/*
**	FUNCTION PROTOTYPES
*/
#define parstack_c
#include "parstack.prt"
#include "comalloc.prt"
#include "comdebug.prt"
#include "comgtnme.prt"



/*
**	DEFINES
*/

/*
**	VARIABLES
*/
static  stack_node * RISpar_top_of_stack;

/*
**	FUNCTIONS
*/



/******************************************************************************/

/*
** this is the POP routine for the stack. it returns the value in
** the node at the top of the stack.
*/

extern ristree *RISpar_pop()
{
	ristree *value_holder;

	value_holder = RISpar_top_of_stack->tp;
	RISpar_top_of_stack = RISpar_top_of_stack->next;
	return (value_holder);
}

/******************************************************************************/

/*
** this is the PUSH routine for the stack. it pushes values onto
** the top of the stack.
*/

extern void RISpar_push(
	ristree * tree_value)
{
	stack_node * new_stackptr;

	new_stackptr = ALLOCT(stack_node);
	new_stackptr->next = RISpar_top_of_stack;
	RISpar_top_of_stack = new_stackptr;
	RISpar_top_of_stack->tp = tree_value;
}

/******************************************************************************/

/*
** this routine simply creates a new stack.
*/

extern void RISpar_create_stack()
{
	RISpar_top_of_stack = ALLOCT(stack_node);
}

/******************************************************************************/

/*
** this routine simply looks at the top of the stack without
** affecting the actual stack itself. it returns the top
** ristree pointer.
*/

extern ristree *RISpar_top()
{
	return (RISpar_top_of_stack->tp);
}

/******************************************************************************/

/*
** this routine simply prints out the stack  
*/

extern void RISpar_print_stack()
{
	stack_node * tempstack;

	tempstack = RISpar_top_of_stack;
	while (tempstack->tp)
	{
		RIScom_output_debug("%s ",RIScom_get_token_name(tempstack->tp->tok));
		if (tempstack->tp->info.val)
		{
			RIScom_output_debug("%s ",tempstack->tp->info.val);
		}
		RIScom_output_debug("\n");
		tempstack = tempstack->next;
	}
}

/******************************************************************************/
