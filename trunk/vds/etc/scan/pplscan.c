#include <stdio.h>
#include <malloc.h>

int  NB_TO_IGNORE = 0 ;
char FILES_TO_IGNORE[][50] = 
{
#ifdef CLIX
	"X11/Xlib.h",
	"Xlib.h",
	"X11/Xutil.h",
	"Xutil.h",
	"X11/X.h",
	"X.h",
	"X11/Xatom.h",
	"X11/Xos.h",
	"X11/FI.h",
	"X11/MwmUtil.h",
	"X11/Intrinsic.h",
	"Intrinsic.h",
	"X11/IntrinsicP.h",
	"IntrinsicP.h",
	"X11/FIdyn.h",
	"X11/keysym.h",
	"keysym.h",
	"X11/MS.h",
	"X11/StringDefs.h",
	"X11/Xresource.h",
	"Xresource.h",
	"X11/XFIproto_pub.h",
	"GL/gl.h",
	"GL/glu.h",
	"GL/glx.h",
	"XFIproto_pub.h",
	"../hfiles/UTErrDef.h",
	"../hfiles/UTmacros.h",
	"strings.h",
	"bsvalues_ib.h",
	"bsvalues_nt.h",
	"y.tab.h",
	"port.h",
	"vsx_stdlib.h",
	"i8859_ctype.h",
	"sys/bsdtypes.h",
	"shampub.h",
	"windef.h",
	"wingdi.h",
	"winuser.h",
	"X11/extensions/multibuf.h",
	""
#else
	"GL/gl.h",
	"GL/glu.h",
	"GL/glx.h",
	"xgl/xgl.h",
	"sys/bsdtypes.h",
	"windef.h",
	"winuser.h",
	"wingdi.h",
	""
#endif
} ;

#define	my_DEBUG 0
#define DEBUG 0
#define MAXINC 1000
struct
{
	int	dirnum ;
	char	name[256] ;
} __list[MAXINC] ;

int	__last = 0 ;

int can_ignore( char *inc )
{
  int rc = 0 ;
  int i ;
	
  for( i = 0 ; i < NB_TO_IGNORE ; i++ )
  {
    if( !strcmp( inc, FILES_TO_IGNORE[i] ) )
    {
      rc = 1 ; break ;
    }
  }
  return rc ;
}

int not_in_list( char *inc )
{
  int i ;
  for( i = 0 ; i < __last ; i++ )
  {
    if( !strcmp( inc, __list[i].name ) )
    {
#if DEBUG
      fprintf(stderr, "Already in list <%s>\n", inc ) ;
#endif
      return 0 ;
    }
    else
    {
#if DEBUG
      fprintf(stderr, "Not in list <%s>\n", inc ) ;
      fprintf(stderr, "Not in list <%s>\n", inc ) ;
#endif
    }
  }
  return 1 ;
}

void add( char *f, int dirnum )
{
  if( __last < MAXINC )
  {
#if my_DEBUG
    fprintf(stderr, "Adding at %3d : <%s>\n", __last, f ) ;
#endif
    strcpy( __list[__last].name, f ) ;
    __list[__last++].dirnum = dirnum ;
  }
  else
  {
    fprintf( stderr, "Too many include files: %d, max allowed %d\n", __last, MAXINC ) ;
    exit( 2 ) ;
  }
}

FILE *open_file( char *name, char *dirnames[], int dircount, int *dirindex )
{
  int	i ;
  char	fullname[256] ;
  FILE	*str = NULL ;

  for( i = 0 ; i < dircount ; i++ )
  {
    sprintf( fullname, "%s/%s", dirnames[i], name ) ;
    if( str = fopen( fullname, "r" ) )
    {
      *dirindex = i ;
      break ;
    }
  }
  return str ;

} /* open_file */

int read_line( FILE *str, char *inc )
{
  enum state
  {
    __eol	= 0x0001,
    __sharp	= 0x0002,
    __sp	= 0x0004,
    __i		= 0x0008,
    __n		= 0x0010,
    __c		= 0x0020,
    __l		= 0x0040,
    __u		= 0x0080,
    __d		= 0x0100,
    __e		= 0x0200,
    __quote	= 0x0400,
    __lt	= 0x0800,
    __gt	= 0x1000,
    __nothing	= 0x2000,
    __file	= 0x4000 
  } ;
  int	rc = 1, st, c, go = 1 ;
  char *name = inc ;

  st = __eol ;
  do
  {
    switch( c = getc( str ) )
    {
    case '\n' : if( st & ( __eol | __nothing ) ) st = __sharp ;
		break ;
    case '#'  : if( st & __sharp ) st = __sp | __i ; else goto file ;
		break ;
    case 'i'  : if( st & ( __i | __sp ) ) st = __n ; else goto file ;
		break ;
    case 'n'  : if( st & __n ) st = __c ; else goto file ;
		break ;
    case 'c'  : if( st & __c ) st = __l ; else goto file ;
		break ;
    case 'l'  : if( st & __l ) st = __u ; else goto file ;
		break ;
    case 'u'  : if( st & __u ) st = __d ; else goto file ;
		break ;
    case 'd'  : if( st & __d ) st = __e ; else goto file ;
		break ;
    case 'e'  : if( st & __e ) st = __sp ; else goto file ;
		break ;
    case '\t' :
    case ' '  : if( !( st & ( __sharp | __e | __sp ) ) ) goto file ;
		break ;
    case '<'  :
    case '"'  : if( ( st & __sp ) && !( st & __i ) ) st = __file ; else /* next case */
    case '>'  : if( st & __file ) go = 0 ; else st = __nothing ;
		break ;
    case EOF  : rc = 0 ; go = 0 ;

#if DEBUG
      fprintf(stderr, "Reached EOF\n" ) ;
#endif
		break ;
    default   : 

file :		if( !( st & __file ) ) st = __nothing ;
		else *name++ = c ;

		break ;
    }
  } while( go ) ;

  *name = '\0' ;	  	
  return rc ;		
}

int scan( int flag, char *file, char *dirs[], int count )
{
  FILE	*str ;
  int	rc = 1, dirnum = 0;

  if( ! ( str = flag ? open_file( file, dirs, count, &dirnum ) : fopen( file, "r" ) ) )
  {
    if( can_ignore( file ) )
    {
      rc = 1 ;
    }
    else
    {
      fprintf( stderr, "Cannot open %s\n", file ) ;
      rc = 1 ;		/* HF: changed in order to continue processing  rc = 0 ; */
    }
  }
  else
  {
    char inc[256] ;
#if DEBUG
    fprintf(stderr, "Scanning <%s/%s>\n", dirs[dirnum], file ) ;
#endif
    add( file, dirnum ) ;

    while( read_line( str, inc ) )
    {
#if DEBUG
      fprintf(stderr, "Read <%s>\n", inc ) ;
#endif
      if( not_in_list( inc ) )
      {
	if( !( rc = scan(	1,
				inc,
				dirs,
				count ) ) )
	{
#if DEBUG
	  fprintf(stderr, "End after <%s>\n", inc ) ;
#endif
	  break ;
	}
      }
    }
    fclose( str ) ;
  }
  return rc ;
			
} /* scan */

int main( int argc, char **argv )
{
  /* ARGS :
   * #0 : .u to scan
   * #i : directories where to look for .h's
   */
  int i ;
  int rc ;

  if( argc <= 1 ) 
  {
    fprintf( stderr, "Usage: pplscan <source.u> dir1 dir2 ...\n" ) ;
    rc = 1 ;
  }
  else
  {
    char name[80], *c;
    strcpy ( name, argv[1] );

    memset ( __list, 0, sizeof ( __list ) );

#if my_DEBUG
    fprintf( stderr, "sizeof ( __list ) = %d\n", sizeof ( __list ) );
    for( i = 0 ; i < argc-1 ; i++ )
    {
      fprintf( stderr,"+ argv[%d] = %s\n", i, argv[i] ) ;
    }
#endif

    c = argv[0];
    argv[0] = argv[2];
    argv[1] = c;
    strcpy ( c, "/usr/include" ) ;

    /*argv[0] = "." ; argv[1] = "/usr/include" ;*/

#if my_DEBUG
    for( i = 0 ; i < argc-1 ; i++ )
    {
      fprintf( stderr,"- argv[%d] = %s\n", i, argv[i] ) ;
    }
#endif

    for( NB_TO_IGNORE = 0 ; ;  NB_TO_IGNORE++ )
    {
      if( ! FILES_TO_IGNORE[NB_TO_IGNORE][0] ) break ;
    }

    if( scan( 0, name, argv, argc ) )
    {
      rc = 0 ;

      for( i = 0 ; i < __last ; i++ )
      {
	printf( "\t%s/%s", argv[__list[i].dirnum], __list[i].name ) ;

#if my_DEBUG
	fprintf(stderr, "\t%s/%s\n", argv[__list[i].dirnum], __list[i].name ) ;
#endif

	if( i != __last - 1 )
	{
	  printf( " \\\n" ) ;
	}
	else
	{
	  printf( "\n" ) ;
	}
      }
    }
  }
  return rc ;
} /* main */
