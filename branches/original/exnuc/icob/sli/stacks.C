#include <stdio.h>

/* --------------------  stack functions  ----------------------------*/
typedef struct stack_rec
  {
    int		  size;
    int		  tos;
    char	* ptr [1];
  } stack_rec;

/* -----------------------  make_stack  ------------------------------*/
stack_rec * make_stack ( size )
  int	size;
{
  stack_rec	* sp;
  extern   char * calloc( );

  sp = (stack_rec *) calloc ( 1, sizeof ( stack_rec ) + size * sizeof ( char * ));
  if ( ! sp )
    {
      fprintf(stderr,
	"slic: make_stack() -- No dynamic memory available\n\n");
      exit(1);
    }
  sp->size = size;
  sp->tos = 0;
  sp->ptr [0] = 0;
  return sp;
} /* make_stack */

/* -----------------------  clear_stack  -----------------------------*/
clear_stack ( sp )
  stack_rec	* sp;
{
  sp->tos = 0;
  sp->ptr [0] = 0;
  return 0;
} /* clear_stack */

/* ---------------------  push_stack  --------------------------------*/
int push_stack ( sp, ptr )
  stack_rec	* sp;
  char		* ptr;
{
  if ( sp->tos <= sp->size )
    {
      sp->ptr [ sp->tos ++ ] = ptr;
      return sp->tos;
    }
  return 0;
} /* push_stack */

/* -----------------------  pop_stack  -------------------------------*/
stack_rec * pop_stack ( sp )
  stack_rec	* sp;
{
  if ( sp->tos )
    return (stack_rec *)sp->ptr [ -- sp->tos ];
  return 0;
} /* pop_stack */

/* -----------------------  stack_depth  -----------------------------*/
int stack_depth ( sp )
  stack_rec	* sp;
{
  return sp->tos;
} /* pop_stack */
