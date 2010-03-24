/* --------------------   make_file_name   ---------------------------*/
#include <sli.h>

make_file_name ( name, extension )
  char	* name;
  char	* extension;
{
  symbol	* sp;
  symbol	* insert_sym (), * find_type ();
  extern char	* expand_shell_vars (), * strip_quotes (), *find_msg ();
  extern char	* strrchr();
  char		* ch;

  name[0] = '\0';

  if ( 0 == strcmp ( extension, ".T" ) )
    {
      sp = find_type ( _product_name_word );  /* this MUST be present */
      strcpy ( name, expand_shell_vars(strip_quotes(sp->name)));
      if ( name[0] == '\0' )
	{
	 printf("slic: Can't find value of environment variable '%s'\n",
	    strip_quotes(sp->name) );
          errors ++;
	  return (-1);
	}
#ifndef NT
      if ( name [ strlen ( name ) - 1 ] != '/' )
#else
      if (name [strlen (name) -1] != '\\')
#endif
	{
	  name [ strlen ( name ) + 1 ] = '\0' ;
#ifndef NT
	  name [ strlen ( name ) ] = '/' ;
#else
          name [strlen(name)] = '\\';
#endif
	}
#ifndef NT
      strcat ( name, "config/commands/" );
#else
       strcat (name,"config\\commands\\");
#endif

      extension = "";	/*** get rid of the ".T" extension ***/

    }   /*** path for .T file ***/
  else
    { /*** figure out path for .S and .I files ***/
      if ( spath_sp  && ! strcmp ( extension, ".S" ) )
        {
          strcpy ( name,
		expand_shell_vars ( strip_quotes ( spath_sp->name )));
#ifndef NT
         if ( name [ strlen ( name ) - 1 ] != '/' ) strcat (name, "/");
#else
if ( name [ strlen ( name ) - 1 ] != '\\' )
  strcat ( name, "\\");
#endif
        }
      else if ( ipath_sp &&  ! strcmp ( extension, "i.I" ) )
        {
          strcpy ( name,
		expand_shell_vars ( strip_quotes ( ipath_sp->name )));
#ifndef NT
          if ( name [ strlen ( name ) - 1 ] != '/' )
            strcat ( name, "/");
#else
 if ( name [ strlen ( name ) - 1 ] != '\\' )
            strcat ( name, "\\");
#endif
        }
      else if ( path_sp )
        {
          strcpy ( name,
		expand_shell_vars ( strip_quotes ( path_sp->name )));
#ifndef NT
          if ( name [ strlen ( name ) - 1 ] != '/' )
            strcat ( name, "/");
#else
if ( name [ strlen ( name ) - 1 ] != '\\' )
            strcat ( name, "\\");
#endif
        }
    }  /*** .S or .I file path ***/

  if ( ! class_sp )
    {
      yyerror ( find_msg ( "msg_no_class" ));
      class_sp = insert_sym ( "no_class", _class_word, 1, "duplicate class" );
    }

  if ( 0 == strcmp ( extension, ".S" ) )
        /* the .S file always uses the classname */
	strcat ( name, class_sp->name );
  else if ( 0 == strcmp ( extension, "i.I" ) )
    {
      sp = find_type ( _output_name_word );
      if ( sp ) 	/** "output_name" was specified **/
        strcat ( name, strip_quotes ( sp->name ));
      else  /* use the default filename ( = ".sl" file_name ) */
	{
	  strcat ( name, file_name );
	  if ( NULL != ( ch = strrchr( file_name, '.' ) ) )
	    {
		ch = strrchr(name,'.');
		* ch = '\0';
	    }
	}
    }
  else /*** ".T" file ***/
    {
      sp = find_type ( _cmd_string_word );  /*** this MUST be here ***/
      strcat ( name, sp->strs->list.next->str );
    }

  strcat ( name, extension );
#ifndef NT
  if ( NULL == (ch = strrchr(name,'/') ) ) ch = name;
   else ch++; 
#else
  if (NULL == (ch = strrchr(name,'\\')))
   ch = name;
  else
    ch ++;
#endif
  if ( strlen ( ch ) > 14 )
    {
      fprintf ( stderr, find_msg ( "msg_trunc" ),
	( extension[0] == 'i' ) ? ".I" :
		( ! extension [0] ? ".T" : extension ), name, 14 );
      putc ( '\n', stderr );
    }

/****
  if ( extension[0] == NULL )
    {
      strcpy ( t_filename, name );
    }
****/

} /* make_file_name */
