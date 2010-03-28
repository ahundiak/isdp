/*
 *	Etienne   BEEKER
 *	Dominique GARDELLA
 *
 */
/*-INCLUDES-------------------------------------------------------------------*/
#include <string.h>
#include <malloc.h>
#include <stdio.h>
#include <ctype.h>
#include "cichardef.h"
#include "pcidef.h"
#include "pci.h"
#include "pcimacros.h"
#include "fcidef.h"
#include "cidef.h"
#include "citypedef.h"
#define DEBUG 0

#ifdef SUNOS
#define strtoul strtol
#endif
/*----------------------------------------------------------------------------*/
/* -- List of local variables and count.
   -- */
static Ushort	*var__local	= NULL,
		var__locsz	= 0	;

/*
 *  ANSI static prototype
 */
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif
#if defined(__cplusplus)
extern "C" {
#endif

static void VARscope __((int *v));
/*static char *VARtype __((PCItype *T, Uchar sts, char *name)); */

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
#define TYPDIM( v, t ) { PCItype *eq = &t ;				\
  TYPeq( &eq, (PCItype **) NULL ) ;				\
  switch( eq->Def ) {							\
	case TYPDF :							\
	case ENUMT : PCItyp( v ) = CI_INT	; break ;		\
	case BASIC :							\
		switch( eq->Num ) {					\
			case CI_INTEGER	: PCItyp( v ) = CI_INT	  ; break ; \
			case CI_NUMERIC : PCItyp( v ) = CI_DOUBLE ; break ; \
			default         : PCItyp( v ) = eq->Num	  ; break ; \
		} break ; 					\
	case UNION :						\
	case STRUC : PCItyp( v ) = CI_STRUCT	; break ;	\
	default	   : cibugchk( "MKvar", "unknown type" ) ;	\
  }								\
  if( eq->Ptr ) PCItyp( v ) |= PTR ;				\
  PCIdim( v ) = eq->Dim ;					\
}
#define MADE( var ) ( (var) != EMPTY )
/*----------------------------------------------------------------------------*/
void		VARdebug(), TYPname()	;
unsigned	TYPalign()		;
/*----------------------------------------------------------------------------*/
unsigned VARsizeof( v ) int v ; {

/* -- Returns the elementary  size of variable at index v in the variable table,
      `elementary' means  that if the variable  is an array  this size  shall be
      multiplied by the array dimension.
   -- */

  int TYPsizeof() ; return TYPsizeof( pPCIdef( v ) ) ;
}	
/*----------------------------------------------------------------------------*/
int VARalloc( var, dim )	int	var ;
				Ushort	dim ; {

/* -- Allocates memory in the data segment for a variable.
      INPUT  : var, index of variable in the variable table.
               dim, dimension of variable ( arrays ... ).
      RETURNS: TRUE if OK, FALSE in case of data segment overflow.
   -- */

  register int alignt, offset	;
	   int rc = TRUE	;

  if( TYPsizeof( pPCIdef( var ) ) == 0 ) {
/* -- Type "void".
   -- */
   	PCIval( var ) = 0	;
   	rc = TRUE		;
  } else {
  	alignt = TYPalign( pPCIdef( var ) )	;
  	offset = PCIseg.data - PCIval( 0 )	;

#if DEBUG
 printf( "VARalloc : %s alignt %d\n", PCIvar( var ), alignt ) ;
#endif
  	while( offset % alignt ) offset++ ;

  	PCIval( var )	= PCIval( 0 )	+ offset			;
  	PCIseg.data	= PCIval( var )	+ VARsizeof( var ) * dim	;
  	if( PCIseg.data >= PCIval( 0 ) + MAXDATA )
  		rc = ERRovr( "data segment overflow for", PCIvar( var ) ) ;
  		
#if DEBUG
  printf( "VARalloc: <%s> al %d good al ? %d\n", PCIvar( var ), alignt,
  		((unsigned) PCIval( var )) % alignt == 0 ) ;
#endif
  }
  return rc ;
  	
} /* VARalloc */
/*----------------------------------------------------------------------------*/
void VARauxsz( T, V )	PCIident V  ;
			PCItype  *T ; {

/* -- Generates an auxilliary variables ( mimicking an address register ) name
      in the form AUXVAR <var size> <ident>.
      INPUT  : T, type of variable.
      UPDATE : V, seed for var name (IN), then var name (OUT).
   __ */

		PCIident tmp ; char *s, *itoa() ;

  *( itoa( tmp + 1, (int) TYPsizeof( T ) ) - 1 ) = AUXVAR 	;
  s = V ; while( *s == AUXVAR || isdigit( *s ) ) s++		;
  strcpy( V, strcat( tmp, s ) )					;
#if DEBUG
  printf( "VARauxsz : V = <%s>\n", V ) ;
#endif
} /* VARauxsz */
/*----------------------------------------------------------------------------*/
static void VARscope( v )	int *v ; {

/* -- Adds local variable to the list of variables to be forgotten once function
      or operator declaraction is finished.
   -- */
#if DEBUG
 printf( "VARscope: <%s> in <%s>\n", PCIvar( *v ), PCIvar( PCIfcn ) ) ;
#endif
   if( ALLOC( var__local, var__locsz + 1, Ushort ) == NULL ) *v = EMPTY ;
   else var__local[var__locsz++] = *v ;
}
/*----------------------------------------------------------------------------*/
void VARforget( F ) PCIident F ; {

/* -- Removes local variables from the symbol table.
   -- */
   register Ushort *var, *end ; emsg e ; void STBremove() ;
   
#if DEBUG
  printf( "VARforget: ENTER, var__locsz = %d\n", var__locsz ) ;
#endif
	for( var = var__local, end = var + var__locsz ; var < end ; var++ ) {
#if DEBUG
  printf( "VARforget: removing <%s> in <%s> from symbol table\n",
          PCIvar( *var ), F ) ;
#endif
		if( PCIopt.warnmsgs && PCIusd( *var ).stat == VAR_NOT_USED ) {
		   sprintf( e, "%.*s in %.*s", MAXEMSG / 2 - 3, PCIvar( *var ),
					       MAXEMSG / 2 - 3, F             );
		   WNGsyn( "unused variable", e ) ;
		   PCIusd( *var ).stat = VAR_USED ;
		}
   		STBremove( PCIvar( *var ), SYM_LVAR_NAM ) ;
   	}
 
	var__locsz = 0 ; FREE( var__local ) ; var__local = NULL ;
}
/*----------------------------------------------------------------------------*/
int MKvar( C, V )	PCIcontext	*C	;
			PCIident	V	; {

/* -- Creates a (global for the moment) variable.
   -- */

			register int v ; PCItype *TDFeq() ;

#if DEBUG
     printf( "MKvar : <%s> loc %d sto %d ", V, C->loc, C->sto ) ;
     /* TYPdump( "", &C->typ ) ;*/
#endif

  if( PCInvar >= MAXVAR - 1 ) {
        ERRovr( "too many variables", NULL ) ;
        v = EMPTY ;
  } else {
	v = PCInvar++ ;
/* --	Unused now but must be set to NULL.
   -- */
	PCIdef( v ).Spc = NULL ;

	if( C->sto == cxEXTRN ) {    	
	    	PCIsts( v ) = CI_XTRN	;
	    	PCI_Count_externals()	;
    	} else PCIsts( v ) = 0 ;
    	if( C->use == cxFUNCT			) PCIsts( v ) |= CI_FUNC ;
    	if( C->typ.Ptr && C->typ.Fpt == FCNPTR	) PCIsts( v ) |= CI_FNPT ;
		
	if(    C->typ.Def == BASIC
	    && C->typ.Num == CI_STRING ) C->typ.Num = CI_CHAR ;

	PCIdef( v ) = C->typ ;
	if( C->typ.Def == TYPDF ) {
		if( C->typ.Dim && *V != AUXVAR )
		  if( !TDFmultidim( (int) C->typ.Num ) ) return EMPTY ;
		TYPDIM( v, C->typ ) ;
	} else {
		if( STRnosize( &C->typ ) ) return EMPTY ;
		if( C->use != cxFUNCT && TYPvoid( &C->typ ) ) {
			ERRsyn( "void type for", V ) ;
			return EMPTY ;
		}
		TYPDIM( v, C->typ ) ;
	}


/* -- 	Store var's name.
   -- */
   	if( MALLOC( PCIvar( v ), 1 + strlen( V ), char ) != NULL
	    && STBenter( strcpy( PCIvar( v ), V ), v,
	                 C->loc == cxLOCAL ? SYM_LVAR_NAM : SYM_GVAR_NAM )
   	  ) {
   	  	PCIusd( v ).func = (Uchar) PCIfcn ;

#if DEBUG
     printf( "MKvar : " ) ; VARdebug( v ) ; 
#endif
/* --     	Internal variables begin with `AUXVAR': no allocation for them,
		as well as for externs and reference variables. 
   -- */
		if( V[0] != AUXVAR && C->sto != cxEXTRN && !C->ref ) {
	    	 if( !VARalloc( v, C->typ.Dim == 0 ? 1 : C->typ.Dim ) )
	    	 		v = EMPTY ;
		}
/* --	    	Store aligmnent in four leftmost bits.
   -- */
		PCIsts( v ) |= ( TYPalign( pPCIdef( v ) ) << 4 ) ;
	} else {
		ERRmem( "name of variable" ) ;
		v = EMPTY ;
	}
  } /* else */

#if DEBUG
   printf( "MKvar : vars %d EXIT( %d )\n", PCInvar, v ) ;
#endif
  return v ;

} /* MKvar */
/*----------------------------------------------------------------------------*/
int VARext( xfile, V )	PCIident	V	;
			FILE		**xfile	; {

/* -- Writes external symbols onto `.n' file.
   -- */

			int rc = TRUE ; SysVfname dot_n ;

  if( !PCIopt.prtxsyms ) return TRUE ;

  if( *xfile == NULL ) {
    if( strcmp( PCIfile, SRC_DEF ) == 0 )
          strcpy( dot_n, NML_DEF )					;
    else  *( strchr( strcpy( dot_n, PCIfile ), EOSTR ) - 1 ) = NML_EXT	;

    if( ( *xfile = fopen( dot_n, "w" ) ) == NULL )
  		rc = ERRusr( "FILEOP", "cannot open", dot_n ) ;
    else
    		fprintf( *xfile, "# pci %s\n#\t\tExternals list for \"%s\"\n",
    	                 CI_VERSION_NUMBER, PCIfile ) ;
  }
  if( rc ) fprintf( *xfile, "%s\n", V ) ;
  
  return rc ;

} /* VARext */ 	
/*----------------------------------------------------------------------------*/
int MKdcl( C, V )	PCIcontext	*C	;
			PCIident	V 	; {

/* -- Handles a declaration of a variable, a structure field, a type name
      an argument.
      INPUT  : C, context information
               V, name of variable
      RETURNS: variable or field index if OK, EMPTY otherwise.
   -- */

		int iv  = EMPTY ; extern int yy__xused ;

#if DEBUG
/*  if( V[0] != AUXVAR && V[0] != CSTVAR ) */ {
    printf( "MKdcl : <%s> loc %d .Def %d .Num %d .Dim %d .Ptr %d\n", V, C->loc,
            C->typ.Def, C->typ.Num, C->typ.Dim, C->typ.Ptr ) ;
  }
#endif
/* --	Unused now but must be set to NULL.
   -- */
  C->typ.Spc = NULL ;

  switch( C->loc ) {
    case cxFIELD :   if( C->use == cxFUNCT )
    				ERRsyn( "function declaration in struct", V ) ;
    		     else	iv = mkSTRfield( &C->typ, V ) ;
    		     break ;

    case cxLOCAL :
    		     if( MADE( iv = STBfind( V, SYM_LVAR_NAM ) ) )
	 		      ERRsyn( "variable already declared", V ) ;
/* --		     Do not allow a local variable to bear the same name as an
		     argument.
   -- */
        	     else if(	   UFNisarg( V ) != EMPTY
        	     		|| UOPisarg( V ) != EMPTY )
        	     	      ERRsyn( "variable name is that of an argument", V ) ;
        	     else if( C->sto != cxEXTRN ) {
        	     	iv = MKvar( C, V )	;
        	     	VARscope( &iv )		;
        	     } else goto GLOBAL ;
		     break ;
    case cxGLOBL :   GLOBAL :
#if DEBUG
  printf( "MKvar: <%s> cxGLOBL\n", V ) ;
#endif
/* --		     There is no  way to know the size of `@' variables at  exec
   --		     time, so include it in their names.
   -- */
    		     if( *V == AUXVAR ) VARauxsz( &C->typ, V ) ;
    		     if( MADE( iv = STBfind( V, SYM_GVAR_NAM ) ) ) {
/* --		        Internal vars are not declared...
   -- */
      	  		if( *V != CSTVAR && *V != AUXVAR && *V != REGVAR ) {
             		   if( C->use != cxFUNCT ) {
			      if( !isextern( iv ) )
	 		      	ERRsyn( "variable already declared", V ) ;
	 		   } else if( !TYPcompare( C->typ, PCIdef( iv ) ) ) {
	 		      ERRsyn( "redeclaration of", V ) ;
	 		   } else yy__xused = PCIusd( iv ).stat ;
          	    	} else PCIdef( iv ) = C->typ ;
        	     } else iv = MKvar( C, V ) ;
		     break ;

    case cxTYPDF :   if( C->use == cxFUNCT )
    				ERRsyn( "function declaration in typedef", V ) ;
    		     else	iv = mkTDF( &C->typ, V ) ;
    		     break ;

    case cxFNARG :   if( C->use == cxFUNCT )
    				ERRsyn( "function declaration in args", V ) ;
    		     else	iv = mkUFNarg( C, V ) ;
    		     break ;

    case cxOPARG :   if( C->use == cxFUNCT )
    				ERRsyn( "function declaration in args", V ) ;
    		     else	iv = mkUOParg( C, V ) ;
    		     break ;

    case cxTIARG :   if( C->use == cxFUNCT )
    				ERRsyn( "function declaration in args", V ) ;
    		     else	iv = mkTYIarg( C, V ) ;
    		     break ;

    default	 :   cibugchk( "MKdcl", "unknown location for declaration" ) ;
   }

#if DEBUG
    printf( "MKdcl : EXIT(%d)\n", iv ) ;
#endif
  return iv ;

} /* MKdcl */
/*----------------------------------------------------------------------------*/
static char *VARtype( T, sts, name )	PCItype *T ; Uchar sts ; char *name ; {

	static emsg 	buf1 ;
	emsg		buf2 ;
	char 		*def,
			*nam ;
	int		star ;

#define UorS( p ) ( *(p) == 's' || *(p) == 'u' ? (p) : "" )

  *( def = buf1 ) = EOSTR;
  star	= T->Ptr	;
  while( star-- ) *def++ = '*' ; *def = EOSTR ;
  if( T->Dim ) sprintf( def, "[%d]", T->Dim ) ;
  if( star = T->Rpt ) {
  	nam = buf2 ;
  	while( star-- ) *nam++ = '*' ;
  	sprintf( nam, "(%s)", buf1 ) ;
  } else if( T->Fpt ) 	sprintf( buf2, "(%s)", buf1 ) ;
         else		strcpy( buf2, buf1 ) ;
  if( T->Fpt && ! ( sts & CI_XTRN ) || ( sts & CI_USER ) ) strcat( buf2, "()" ) ;
  else if( !T->Fpt && STBfind( name, SYM_SYST_FCN ) != EMPTY ) strcat( buf2, "() [lib]" ) ;
  TYPname( T, &def, &nam ) ;
  sprintf( buf1, "%s %s %s", UorS( def ), nam, buf2 ) ;

  return buf1 ;

} /* VARtype */			
/*----------------------------------------------------------------------------*/
void VARdump( F )	FILE *F ; {

/* -- Dumps user-declared variables onto file.
   -- */
        	      	register char	**N	;
        	      	register int	u	;
        	      	void		qsort()	;
        	      	int		curfun,i;
			char		*ptr	;

  N = &PCIvar( 0 ) ; curfun = MAXFUNC + 1 ;

  fprintf( F, "\n\t\t\t\tVARIABLES\n\t\t\t\t---------\n\n" ) ;
  for( u = 0 ; u < PCInvar ; u++, N++ ) {
	   if( isidchar( **N ) ) {

	   	if( PCIusd( u ).func != (Uchar) EMPTY /* < MAXFUNC */ ) {
	   		if(  PCIusd( u ).func != curfun ) {
	   			curfun = PCIusd( u ).func ;
	   			switch( *PCIvar( curfun ) ) {
	   				case INIVAR :
	   			ptr = PCIvar( curfun ) + 1 ;
	   			fprintf( F, "*** typeinit (#%s) ***\n", ptr ) ;
	   			break ;
	   				case OPRVAR :
	   			i = strtoul( PCIvar( curfun ) + 1, &ptr, 10 ) ;
	   			fprintf( F, "*** operator `%.*s' (#%d) ***\n",
	   				    strlen( ptr ) - 4, ptr, i ) ;
	   				    break ;

	   				default :
	   			fprintf( F, "*** %s() ***\n", PCIvar( curfun ) ) ;
			} /* switch */
	   		}
		} else if( curfun != MAXFUNC ) {
			fprintf( F, "*** Global ***\n" ) ;
			curfun = MAXFUNC ;
		}
		fprintf( F, "%-40s %s\n", *N, VARtype( pPCIdef( u ),
						       PCIsts( u ), *N  ) ) ;

	   }
  }

} /* VARdump */			
/*----------------------------------------------------------------------------*/
void VARdebug( v )	int v ; {

			PCItype t ; char *def, *nam ;

  t = PCIdef( v ) ;

  TYPname( &t, &def, &nam ) ;
  printf( "-- Dump of Variable --\n" ) ;
  printf( "Name : <%s>\tType Definition : <%s>\n", PCIvar( v ), def ) ;
  printf( "Type : <%s>\t", nam ) ;
  printf( "Dimension : %d\tPointer : %d Fcnptr ; %d Rpt : %d\n", t.Dim, t.Ptr,
          t.Fpt, t.Rpt ) ;

}
/*----------------------------------------------------------------------------*/
