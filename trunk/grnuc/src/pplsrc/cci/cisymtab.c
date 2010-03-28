#include <stdio.h>
#include <string.h>
#include "pci.h"
#include "pcidef.h"
#include <xc/hash.h>
/*----------------------------------------------------------------------------*/
#define STBSIZE 499
/*----------------------------------------------------------------------------*/
typedef struct		{	Uchar	what	;
				char	*name	;
} hkey ;
typedef struct 		{	hkey	key	;
				Ushort	indx	;
} hcell ;
/*----------------------------------------------------------------------------*/
static HASHTABLE	*stb__list 	;
static char		stb__exists	;
/*----------------------------------------------------------------------------*/
int STBhashc( kfield, tsize )	hkey *kfield ; int tsize ;	{
	if (kfield->name)
		return hashc( kfield->name, tsize );
	return 0;
}
/*----------------------------------------------------------------------------*/
int STBcmp( kf1, kf2 )	hkey *kf1, *kf2 ; {
	int rc ;
#if DEBUG
  printf( "STBcmp 1: %s (%u) (%u) 2: %s (%u) (%u)", kf1->name, kf1->what,
           kf1,  kf2->name, kf2->what, kf2 );fflush(stdout);
#endif
	if (!kf1->name && !kf2->name)
		rc = kf1->what - kf2->what;
	else if (!kf1->name || !kf2->name)
		rc = 1;
	else if( ( rc = strcmp( kf1->name, kf2->name ) ) == 0 )
		rc = kf1->what - kf2->what ;
#if DEBUG
 printf( "STBcmp: rc = %d\n", rc ) ;
#endif
	return rc ;
}
/*----------------------------------------------------------------------------*/
int STBenter( key, number, kind )	char	*key	;
					int	number	,
						kind	; {

			hcell c ; int rc = TRUE ;

	c.key.name	= key		;
	c.key.what	= kind		;
	c.indx		= number	;

#if DEBUG
  printf( "STBenter: %s what %d (&key=%u)\n", key, c.key.what, &key ) ; fflush( stdout ) ;
#endif
	if( hashadd( stb__list, &c, NULL ) == NULL )
  		rc = ERRmem( "symbol table entry" ) ;
  	else rc = TRUE ;

  	return rc ;

} /* STBenter */
/*----------------------------------------------------------------------------*/
int STBfind( key, type )	char *key ; int type ; {

			hkey k ; hcell *c ;

  k.name = key	;
  k.what = type	;
#if DEBUG
  printf( "STBfind: %s %d (&k=%u)\n", k.name, k.what, &k ) ;
#endif

  return ( c = (hcell *) hashlookup( stb__list, (char *) &k ) ) != NULL ?
				c->indx : EMPTY ;
} /* STBfind */
/*----------------------------------------------------------------------------*/
void STBremove( key, type )	char *key ; int type ; {
/* -- Removes an entry ( supposed to exist ).
   -- */
	STBfind( key, type ) ; hashdel( stb__list ) ;
}
/*----------------------------------------------------------------------------*/
int STBcreate() {
return stb__exists = ( stb__list = hashinit( hcell , STBSIZE, STBhashc,
				      	   STBcmp, key	  , 0 ) ) != NULL ;
}	
/*----------------------------------------------------------------------------*/
void STBdestroy() {
	if( stb__exists ) hashfree( stb__list ) ;
}
/*----------------------------------------------------------------------------*/
