/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							stack.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					11/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include "mm.h"
#include "stack.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define stack_c
#include "output.prt"
#include "stack.prt"
#include "sys.prt"

/*
**	VARIABLES
*/

/*
**	FUNCTIONS
*/


/******************************************************************************/

extern void init_stack(
	stack_s stack[],
	int *stack_index)
{
	*stack_index = 0;
	stack[*stack_index].mode = READ;
	stack[*stack_index].line = 0;
	stack[*stack_index].type = NULL;
}

/******************************************************************************/

extern void push(
	int mode,
	int line,
	char *type,
	stack_s stack[],
	int *stack_index)
{
	if (*stack_index >= MAX_STACK - 1)
	{
		fprintf(stderr, "%s: increase MAX_STACK(%d) in \"%s\".\n",
			exe, MAX_STACK, __FILE__);
		EXIT(1);
	}

	(*stack_index)++;
	stack[*stack_index].mode = mode;
	stack[*stack_index].line = line;
	stack[*stack_index].type = type;

}

/******************************************************************************/

extern int pop(
	stack_s stack[],
	int *stack_index)
{
	if (*stack_index <= 0)
	{
		fprintf(stderr, "%s: pop: internal error in \"%s\", line %d.\n",
			exe, __FILE__, __LINE__);
		EXIT(1);
	}
	return stack[(*stack_index)--].mode;
}

/******************************************************************************/

extern int ok_to_read(
	stack_s stack[],
	int stack_index)
{
	int i;

	for (i = 0; i <=  stack_index; i++)
	{
		if (stack[i].mode == SKIP || stack[i].mode == SKIP_REST)
		{
			return 0;
		}
	}
	return 1;
}

/******************************************************************************/
