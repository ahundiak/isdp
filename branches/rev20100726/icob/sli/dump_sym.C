/* ---------------------  dump_symbol_table  -------------------------*/
#include <sli.h>

void dump_symbol_table ( list, lev )
  symbol	* list;
  int		  lev;
{
  char	name [2000];
  int	i;

  if ( lev == 0 )
    {
#ifndef NT
      tblf = fopen ( "/tmp/sli.stf", "w" );
#else
      tblf = fopen ( "c:\temp\sli.stf", "w" );
#endif
      if ( tblf ) fprintf(stderr, "dumping symbols to /tmp/sli.stf\n" );
      else return;
      fprintf ( tblf,
          "\nsymbol			type	offset	defined	args\n");
    }
  _COB_for_list ( sp, list, list, symbol )
    name [0] = NULL;
    for ( i = 1; i <= lev; ++ i ) strcat ( name, "+ " );
    strcat ( name, sp->name );
    if ( strlen ( name ) >= 16 )
      fprintf ( tblf, "%s	", name );
    else if ( strlen ( name ) >= 8 )
      fprintf ( tblf, "%s		", name );
    else
      fprintf ( tblf, "%s			", name );
    fprintf ( tblf, "%d	%d	%d	%s\n",
	sp->type, sp->offset, sp->defined, sp->args ? sp->args : "" );
    if ( sp->actions )
      dump_symbol_table ( sp->actions, lev + 1 );
  _COB_end_for_list /* ( sp ) */
  if ( lev == 0 ) 
    {
        if(tblf != NULL)
        fclose ( tblf );
    }
} /* dump_symbol_table */
