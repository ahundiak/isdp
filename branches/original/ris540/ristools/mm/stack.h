/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							stack.h
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					11/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/

/*
**	DEFINES
*/
#define MAX_STACK		50

#define READ			0
#define SKIP			1
#define SKIP_REST		2
#define READ_BOTH		3

#define INIT_STACK()			(init_stack(stack, &stack_index))
#define PUSH(mode,line,type)	(push(mode, line, type, stack, &stack_index))
#define POP()					(pop(stack, &stack_index))
#define OK_TO_READ()			(ok_to_read(stack, stack_index))
#define STACK_EMPTY()			(stack_index == 0)

/*
**	TYPES
*/
typedef struct stack_s
{
	int mode;
	int line;
	char *type;
} stack_s;

/*
**	VARIABLES
*/
