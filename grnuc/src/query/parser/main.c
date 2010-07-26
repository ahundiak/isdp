#include "stdio.h"
#include "string.h"

static char *ptr, buffer [1024];
int QYstatus, QYblank;

main ( argc, argv )
       char *argv [];
{
  for ( ;; )
  {
    printf ( "---> " );
    fflush ( stdout );

    ptr = buffer;
    do
      if (!fread ( ptr++, 1, 1, stdin ))
      {
        printf ( "\n" );
        exit ( 0 );
      }
    while (*(ptr - 1) != '\n');
    *(ptr - 1) = '\0';
    set_buffer ( buffer );
    QYblank = 1;
    if (yyparse ())
      printf ( "syntax error in that query\n" );
    QYblank = 0;
    set_buffer ( buffer );

    if (!yyparse ())
    {
      printf ( "the query is %s\n", QYstatus ? "true" : "false" );
      if (QYis_in_class_list ( "coucou" ))
        printf ( "coucou is in the class list\n" );
      else
        printf ( "coucou is in NOT the class list\n" );
      if (QYis_in_class_list ( "cuicui" ))
        printf ( "cuicui is in the class list\n" );
      else
        printf ( "cuicui is in NOT the class list\n" );
      if (QYis_in_class_list ( "zizi" ))
        printf ( "zizi is in the class list\n" );
      else
        printf ( "zizi is in NOT the class list\n" );
    }
  }
}


query ( op1, oper, op2 )
        char *op1, *op2;
        int  oper;
{
  int val;

  if (QYblank)
  {
    printf ( "blank one: 0\n" );
    return NULL;
  }
  else
  {
    if (oper == 270)
      printf ( "exist ( %s ): %d\n", op1, val = *op1 > 'k' );
    else
      printf ( "%s %d %s -> %d\n", op1, oper, op2, val = strcmp ( op1, op2 ) <= 0 ? 1 : NULL );

    return val;
  }
}
