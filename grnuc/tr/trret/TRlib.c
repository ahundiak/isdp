/**********************  File: TRlib.c  ******************************/

#include <stdio.h>
#include <string.h>
#include <ctype.h>

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++ GRTRchange_extension */
/* This function takes a file name 'name' as somename.ext and replaces the
   extension with 'ext'. The input name may or may not have an extension. The
   change is done in place.
*/

char *GRTRchange_extension ( name, ext )

  char	*name;
  char	*ext;
{

  char		*c1;
  static char	rs[256];
  int		length;

  rs[0] = '\0';
  length = strlen ( ext );
  if ( length > 12 )
    goto quit;

  c1 = name;

  while ( *c1 == ' ' )
    c1++;

  strcpy ( rs, c1 );
  c1 = rs + strlen ( rs ) - 1;
  while ( (*c1 != '.') && (*(c1-1) != '/') && (c1 > rs) )
    c1--;

  if ( *c1 == '.' ) {
    *c1 = '\0';
    while ( (*c1 != '/') && (c1 > rs) )
      c1--;
  }
  *(c1 + 13 - length) = '\0';
  strcat ( c1, "." );
  strcat ( c1, ext );
quit:
  return ( rs );
}


/* ++++++++++++++++++++++++++++++++++++++++++++++++ GRTRget_product_data_field */
/*
   This function reads thru the product_data file to find the
   package specified and returns the contents of the field 
   corresponding to the location.
*/
int GRTRget_product_data_field ( package, location, wanted_field )
  char		*package;	/* Product name - Fist field in product_data */
  int		location;	/* Location of the wanted field (1-5) */
  char		*wanted_field;  /* Output */
{
  char		c[5][128];
  char		tmp[130];
  char  	*cp, *TRget_ingrhome(), product_data[500];
  int		ret_stat = 0;
  FILE		*fp = NULL;

  wanted_field[0] = '\0';

  if (package == NULL || package[0] == '\0')
  {
    goto quit;
  }

  if ( location < 1 || location > 5 )
  {
    goto quit;
  }


  if ( cp = TRget_ingrhome())
  {
      sprintf (product_data, "%s/product_data", cp);
  }
  else
  {
#ifdef CLIX
      strcpy (product_data, "/usr/ip32/product_data");
#endif
#ifdef SUNOS
      strcpy (product_data, "/usr/ip32/product_data");
#endif
#ifdef SUNOS5
      strcpy (product_data, "/opt/ingr/product_data");
#endif
#ifdef IRIX
      strcpy (product_data, "/var/opt/ingr/product_data");
#endif
  }

  fp = fopen ( product_data, "r" );
  if ( ! fp ) {
    perror ( product_data );
    goto quit;
  }

  tmp[0] = '"';
  strcpy ( &tmp[1], package );
  strcat ( tmp, "\"" );
  while ( fscanf(fp, "%s %s %s %s %s", c[0], c[1], c[2], c[3], c[4]) == 5 )
  {
    if ( ! strcmp ( tmp, c[0] ) ) 
    {
      strcpy ( wanted_field, c[location-1] );
      break;
    }
  }

  if (wanted_field[0] != '\0')
     ret_stat = 1;

quit:
  if (fp)
    fclose(fp);
  return ( ret_stat );
}

/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ GRTRdirname */
/* This function return the directory name of the pathname specified.
   It works like the Unix command dirname
*/
 
char *GRTRdirname ( path )
  char *path;
{
  char *direct, cw_dir[256];
  char *cp, *cp1; 
  int i;
  extern char *EXgetcwd();

  direct = (char *) malloc (256 * sizeof (char));

  cw_dir[0] = '\0';
  EXgetcwd (cw_dir, 256);

  strcpy (direct, path);

  cp = strrchr (direct , '/');

  if ( cp == NULL )
  {
      strcpy (direct, cw_dir);
      goto quit;
  }

  cp1 = direct;

  for  (i = 0; i < strlen (direct) ; i++ )
  { 
     if ( ! strcmp (cp , cp1+i))
	break;
  }

  direct[i] = '\0';

quit: 

  return (direct); 
}

