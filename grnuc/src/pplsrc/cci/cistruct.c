/* -- This module handles the 'structure' stuff.
      STR = STRuct
   -- */
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cidef.h"
#include "cichardef.h"
#include "citypedef.h"
#include <malloc.h>
#include <limits.h>
#include <string.h>
#define DEBUG 0
/*-TYPEDEFS-------------------------------------------------------------------*/
/* -- Representation of a field, its name, offset, type and address of next one
      NOTE : the "offs" field contains :
      		- the offset from start of struct to field :
      				offs = &struct.field - &struct
   -- */
typedef struct _fieldrep {
			char			*name	;
			unsigned		offs	;
			PCItype        		type	;
			struct _fieldrep	*next	;
} fieldrep ;

/* -- Representation of a struct : Union is TRUE if it is an union, its name,
      size, address of first field. If union/struct has been used in declara-
      tions but is not yet defined, `dclrd' is FALSE else TRUE.
   -- */
typedef struct {
			char	 Union ;
			char	 dclrd ;
			char	 *name ;
			unsigned size,
			         align ;
			fieldrep *flds ;
} structrep ;

static structrep	**stc__list	= NULL	;
static int		stc__count	= 0	,
			stc__stack[MAXSTRUCT]	,
			stc__currt	= EMPTY	;
/*-MACROS---------------------------------------------------------------------*/
#define UNTAGGED "(untagged)"

/* -- Get real dimension
   -- */
#define FIELDcells( f ) ( (f)->type.Dim == 0 ? 1 : (f)->type.Dim )

/* -- Loop on fields of struct at index 'is'
   -- */
#define FIELDbegin( is, f ) for( (f) = stc__list[(is)]->flds ; (f) != NULL ; ) {
#define FIELDend( f )       (f) = (f)->next ; }
/*----------------------------------------------------------------------------*/
extern unsigned TYPsizeof(), TYPalign() ;

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

static void STRpush __((int is));
static void STRpull __((void));
static int STRcurrent __((void));
static int STRallocF __((fieldrep **f, unsigned l));
static int STRallocs __((structrep **s, unsigned l));
static int STRenter __((PCIident tag, int is));

#if defined(__cplusplus)
}
#endif
#undef __


/*----------------------------------------------------------------------------*/
static void STRpush( is )	int is ; {

	if( stc__currt >= EMPTY && stc__currt < MAXSTRUCT )
		stc__stack[++stc__currt] = is ;
	else cibugchk( "STRpush", "cannot stack structure" ) ;
}
/*----------------------------------------------------------------------------*/
int STRfield_count( is ) int is ; {

/* -- Returns the number of fields in union/structure at index `is'.
   -- */
	register fieldrep	*f	;
	register int		count	;

#if DEBUG
  printf( "STRfield_count ENTER is = %d\n", is ) ; fflush( stdout) ;
#endif
	count = 0 ;
	FIELDbegin( is, f )
		count++ ;
	FIELDend( f )
#if DEBUG
  printf( "STRfield_count ENTER count = %d\n", count ) ; fflush( stdout) ;
#endif
	return count ;

} /* STRfield_count */
/*----------------------------------------------------------------------------*/
static void STRpull()	{

	if( stc__currt >= EMPTY && stc__currt < MAXSTRUCT )
		stc__currt-- ;
	else cibugchk( "STRpull", "cannot pull structure from stack" ) ;
}
/*----------------------------------------------------------------------------*/
static int STRcurrent() { return stc__stack[stc__currt] ; }
/*----------------------------------------------------------------------------*/
static int STRallocF( f, l )	fieldrep **f	;
				unsigned l	; {

/* -- Allocates memory for a field representation.
      INPUT  : f, address of pointer to malloc.
               l, field name length.
      RETURNS: TRUE if OK, FALSE if allocation failed.
   -- */

				int rc = TRUE ;

#if DEBUG
	printf( "STRallocF : enter, l = %d\n", l + 1 ) ;
#endif
  l++ ;
  if(    MALLOC( *f		, 1, fieldrep	) != NULL
      && MALLOC( (*f)->name	, l, char	) != NULL )
	(*f)->next = NULL ;
  else rc = ERRmem( "union/struct field" ) ;

#if DEBUG
	printf( "STRallocF : exit, *f = %d, rc = %d\n", *f, rc ) ;
#endif
	return rc ;

} /* STRallocF */
/*----------------------------------------------------------------------------*/
void STRfreeF( s )	structrep *s ; {

/* -- Frees the field list of a structure representation.
   -- */

			register fieldrep *f, *g ;

  f = s->flds ;
  while( f != NULL ) {
  	 g = f->next ; free( f->name ) ; free( (char *) f ) ; f = g ;
  }

} /* STRfreeF */
/*----------------------------------------------------------------------------*/
void STRfree() {

/* -- Frees the structure list. Re-initializes `stc__count' and `stc__list'.
   -- */

				int i ;

		for( i = 0 ; i < stc__count ; i++ ) {
  			STRfreeF( stc__list[i] )		;
  			free( stc__list[i]->name    )	;
  			free( (char *) stc__list[i] )	;
  		}
  		stc__count = 0 ; FREE( stc__list ) ; stc__list = NULL ;

} /* STRfree */
/*----------------------------------------------------------------------------*/
static int STRallocs( s, l )	structrep **s ;
				unsigned  l   ; {

/* -- Allocates space for a structure representation.
      NOTE : alignment  and size  are intialized  with UINT_MAX ( this  will flag
             that they have not been calculated ).
   -- */

				int rc = TRUE ;

  l += 1 ; /* 1 for trailing '\0' */
  if(    MALLOC( *s		, 1, structrep	) != NULL
      && MALLOC( (*s)->name	, l, char	) != NULL ) {
	(*s)->flds	= NULL	  ;
	(*s)->size	= (unsigned) UINT_MAX ;
	(*s)->align	= (unsigned) UINT_MAX ;
  } else rc = ERRmem( "union/struct" ) ;

   return rc ;

} /* STRallocs */
/*----------------------------------------------------------------------------*/
unsigned STRalign( is )	int is ; {

/* -- Computes the alignment of a structure or union.
      INPUT  : is, index of struct in structure list.
      RETURN : alignment of structure.
      NOTE   : the aligment returned is that given by the Green Hill C compiler.
   -- */

  unsigned align, f_align, TYPalign() ;
  fieldrep *f ;

#if DEBUG
	printf( "STRalign : ENTER, #%d <%s>\n", is, stc__list[is]->name ) ;
#endif
/* -- The total alignment of  a structure is  the maximum  alignment of the data
   -- types of its member fields.
   -- */
   if( ( align = stc__list[is]->align ) == (unsigned) UINT_MAX ) {
	align = 0 ;
   	FIELDbegin( is, f )
#if DEBUG
	printf( "STRalign : computing alignment, field <%s>\n", f->name ) ;
#endif
   	   if( ( f_align = TYPalign( &f->type ) ) > align ) align = f_align ;
#if DEBUG
	printf( "STRalign : Computing alignment, f_align %d\n", f_align ) ;
#endif
   	FIELDend( f )
        stc__list[is]->align = align ;
   }
#if DEBUG
	printf( "STRalign : EXIT, #%d, align = %d\n", is, align ) ;
#endif

   return align ;

} /* STRalign */
/*----------------------------------------------------------------------------*/
unsigned STRsizeof( is )	int is ; {

/* -- Computes the size of a structure.
      INPUT  : is, index of struct in structure list
      RETURN : size of structure
      NOTE   : the size returned is that given by the Green Hill C compiler.
   -- */

  unsigned s_align, size, start, f_align ;
  fieldrep *f ;

#if DEBUG
	printf( "STRsizeof : enter <%s>\n", stc__list[is]->name ) ;
#endif
/* -- The size of a structure is the smallest multiple of its total alignment
   -- which will contain all its its fields.
   -- */
   if( !stc__list[is]->dclrd ) {
   	ERRsyn( "object has no defined size", NULL ) ;
   	size = 0 ;
   } else if( ( size = stc__list[is]->size ) == (unsigned) UINT_MAX ) {
   	s_align = STRalign( is ) ;

   	f = stc__list[is]->flds ;
   	start = size = 0 ;
   	FIELDbegin( is, f )
   		f_align = TYPalign( &f->type )				;
   		if( f_align == 0 ) f_align = 1 ; /* See note in STRend() */
   						 /* about f_align == 0   */
   		while( start % f_align ) start++			;
   		start += TYPsizeof( &f->type ) * FIELDcells( f )	;
   		while( size < start ) size += s_align			;
   	FIELDend( f )
  	stc__list[is]->size = size ;
   }

#if DEBUG
	printf( "STRsizeof : exit, is = %d <%s>, size = %d\n", is,
		 stc__list[is]->name, size ) ;
#endif
   return size ;
   
} /* STRsizeof */
/*----------------------------------------------------------------------------*/
unsigned UNIsizeof( iu )	int iu ; {

/* -- Computes the size of a union.
      INPUT  : iu, index of union in structure list
      RETURNS: size of union
   -- */

  unsigned u_align, size, biggest_size, f_size ;
  fieldrep *f ;

#if DEBUG
	printf( "UNIsizeof : enter\n" ) ;
#endif
   if( !stc__list[iu]->dclrd ) {
   	ERRsyn( "object has no defined size", NULL ) ;
   	size = 0 ;
   } if( ( size = stc__list[iu]->size ) == (unsigned) UINT_MAX ) {
/* -- The size  of a union is the smallest multiple of its total alignment which
   -- will contain its largest field.
   -- */
   	u_align = STRalign( iu ) ;

   	f = stc__list[iu]->flds ;
   	biggest_size = size = 0 ;
   	FIELDbegin( iu, f )
   		f_size = TYPsizeof( &f->type ) * FIELDcells( f )	;
   		if( f_size > biggest_size ) biggest_size = f_size	;
   	FIELDend( f )
   	while( size < biggest_size ) size += u_align ;
  	stc__list[iu]->size = size ;
   }

#if DEBUG
	printf( "UNIsizeof : exit, iu = %d, size = %d\n", iu, size ) ;
#endif
   return size ;
   
} /* UNIsizeof */
/*----------------------------------------------------------------------------*/
static int STRenter( tag, is )	PCIident	tag	;
				int		is	; {

  if( strcmp( strcpy( stc__list[is]->name, tag ), UNTAGGED ) )
 	is = STBenter( stc__list[is]->name, is, SYM_UNST_TAG ) ;
  else	is = TRUE ;
  return is ;
} 
/*----------------------------------------------------------------------------*/
int STRfind( tag, p_type )	PCIident tag     ;
				PCItype  *p_type ; {

/* -- Retrieves a structure in the hash table.
      INPUT   : tag, structure name.
      OUTPUT  : p_type, address of structure type.
      RETURNS : TRUE if struct/union was found else FALSE
   -- */

				int is ;

  if( tag != NULL ) {
  	if( ( is = STBfind( tag, SYM_UNST_TAG ) ) != EMPTY ) {
  		if( p_type != NULL ) {
  			p_type->Dim = 0 ;
  			p_type->Ptr = FALSE ;
  			p_type->Rpt = FALSE ;
  			p_type->Fpt = FALSE ;
  			p_type->Spc = NULL  ;
  			p_type->Def = stc__list[is]->Union ? UNION : STRUC ;
  			p_type->Num = is ;
  		}
  		is = TRUE ;
  	} else is = FALSE ;
  } else is = FALSE ;

  return is ;
  
} /* STRfind */
/*----------------------------------------------------------------------------*/
int STRgetfield( is, f_name, p_type, p_info )

int      is		;
PCIident f_name		;
PCItype	 *p_type	;
PCIfield *p_info	;

/* -- Returns the offset of a field in a structure.
      INPUT  : is, index of structure in structure list.
               f_name, field name
      OUTPUT : p_type, address of field type
               p_info, address of field info ( size, alignment, offset )
      RETURNS: FALSE if field does not exist else TRUE
   -- */
   
{ int rc = FALSE ; fieldrep *f ; void TYPeq() ; PCItype *T ;

  if( is < stc__count ) {
  	FIELDbegin( is, f )
  		if( strcmp( f->name, f_name ) == 0 ) {
  			*p_type = f->type			;
  			T	= p_type			;
  			TYPeq( &T, (PCItype **) NULL )		;
  			p_info->offset	= f->offs		;
  			p_info->size	= TYPsizeof( &f->type ) ;
  			p_info->align 	= TYPalign ( &f->type ) ;
  			p_info->sign	= !T->Ptr && !T->Dim	;
  			rc      = TRUE				;
  			break					;
  		}
  	FIELDend( f )
  } else rc = cibugchk( "STRgetfield", "unknown struct index" ) ;
#if DEBUG
  printf( "STRgetfield : <%s> %u\n", f_name, f->offs ) ;
#endif
  return rc ;

} /* STRgetfield */
/*----------------------------------------------------------------------------*/
char *STRname( is ) int is ; {
	static char buf[30] ;
	if( !strcmp( stc__list[is]->name, UNTAGGED ) ) {
 		sprintf( buf, "(untagged #%d)", is ) ;
 		return buf ;
	} else return stc__list[is]->name ;
}
/*----------------------------------------------------------------------------*/
int mkSTR( tag, U_or_S )	PCIident tag	;
				int      U_or_S ; {

/* -- Builds a structure, reserves space in the structure list. Increases struct
      counter.
      INPUT  : tag, structure's tag.
               U_or_S, union or struct ?
      RETURNS: structure's index in list or EMPTY if function failed.
   -- */

				int S_index = EMPTY, i ;
#if DEBUG
    printf( "mkSTR : %s <%s> at %d\n", U_or_S == UNION ? "UNION" : "STRUCT",
            tag, stc__count ) ;
#endif
   if( ( i = STBfind( tag, SYM_UNST_TAG ) ) != EMPTY ) {
   	if( stc__list[i]->dclrd ) {
   		ERRsyn( "union/struct already declared", tag ) ;
   	} else goto DECLARE ;
   }
   else if( ALLOC( stc__list, stc__count + 1, structrep * ) != NULL ) {
   	i = stc__count++	;
/* RM	STRpush( i )	; */
	if( tag == NULL ) tag = UNTAGGED ;
   	if( STRallocs( &stc__list[i], (unsigned) strlen( tag ) ) ) {
   		if( STRenter( tag, i ) )
   		  switch( U_or_S ) {
   		  	case UNION : stc__list[i]->Union = TRUE  ; break ;
   		  	case STRUC : stc__list[i]->Union = FALSE ; break ;
   		  	default    : cibugchk( "mkSTR", "struct type error" ) ;
   		  }
   		  DECLARE :
   		  S_index = i	;
   		  STRpush( i )	; /* NEW */
  		  stc__list[i]->dclrd = TRUE ; /* NEW */
   	}
   } else ERRmem( "union/structure list" ) ;
   
   return S_index ;

} /* mkSTR */
/*----------------------------------------------------------------------------*/
int STRnosize( T ) PCItype *T ; {

	int rc = FALSE ;
	if(	!T->Ptr
	    &&	( T->Def == UNION || T->Def == STRUC )
	    &&	!stc__list[T->Num]->dclrd ) {
		rc = !ERRsyn( "object has no defined size", NULL ) ;
	}
	return rc ;
} 
/*----------------------------------------------------------------------------*/
int STRcreate( U_or_S, tag, p_type )	int	 U_or_S  ;
					PCIident tag     ;
					PCItype  *p_type ; {

/* -- Called when "struct" <tag> is encountered in a variable declaration.
   -- */

   int i, rc ;

   if( !STRfind( tag, p_type ) ) {
/* --	Struct used but not declared. It necessarily has a tag.
   -- */
    if( ALLOC( stc__list, stc__count + 1, structrep * ) != NULL ) {
   	i = stc__count++	;
   	if( rc = STRallocs( &stc__list[i], (unsigned) strlen( tag ) ) ) {
   		if( STRenter( tag, i ) )
   		  switch( U_or_S ) {
   		  	case UNION : stc__list[i]->Union = TRUE  ; break ;
   	
   		  	case STRUC : stc__list[i]->Union = FALSE ; break ;
   		  	default    : cibugchk( "mkSTR", "struct type error" ) ;
   		  }
  		  p_type->Dim = 0 ;
  		  p_type->Ptr = FALSE ;
  		  p_type->Rpt = FALSE ;
  		  p_type->Fpt = FALSE ;
  		  p_type->Spc = NULL  ;
  		  p_type->Def = stc__list[i]->Union ? UNION : STRUC ;
  		  p_type->Num = i ;
  		  stc__list[i]->dclrd = FALSE ;
   	}
    } else rc = ERRmem( "union/structure list" ) ;
   } else rc = TRUE ;
   return rc ;
}
/*----------------------------------------------------------------------------*/
int mkSTRfield( f_type, f_name )	PCItype  *f_type	;
					PCIident  f_name	; {

/* -- Creates a struct field in the current structure.
      INPUT  : f_name, field name.
               f_type, type of field.
      RETURNS: the index of the struct in the struct list where the field was
               created and EMPTY if field  name already exists or field
               representation could not be created.
   -- */
   
		fieldrep *curr, *last, *newf ; int s_index ;

  s_index = STRcurrent() ;
#if DEBUG
	printf( "mkSTRfield : add %s ( type %d dim %d ptr %d ) at %d\n", f_name,
	        f_type->Num, f_type->Dim, f_type->Ptr, s_index ) ;
#endif

/* -- Check that field name does not already exist.
   -- */
  FIELDbegin( s_index, curr )
  	if( strcmp( f_name, curr->name ) == 0 ) {
  		ERRsyn( "duplicate field name in union/struct", f_name ) ;
  		s_index = EMPTY ;
  		break ;
  	}
  FIELDend( curr )
 
  if( s_index != EMPTY )
  	if( STRallocF( &newf, (unsigned) strlen( f_name ) ) ) {
  		strcpy( newf->name, f_name )	;
  		newf->type = *f_type		;
  
		last = NULL ;
  		FIELDbegin( s_index, curr )
  			last = curr ;
  		FIELDend( curr )
  		if( last == NULL ) stc__list[s_index]->flds = newf ;
  		else               last->next              = newf ;
  	} else s_index = EMPTY ;

#if DEBUG
	printf( "mkSTRfield : newf = %d\n", newf ) ;
#endif
  return s_index ;

} /* mkSTRfield */
/*----------------------------------------------------------------------------*/
int mkSTRbitfield( ctx, name )	PCIcontext	*ctx	;
				PCIident	name	; {

	int index ;

	if( ctx->loc != cxFIELD ) {
		ERRsyn( "bit field declaration outside of struct", NULL ) ;
		index = EMPTY ;
	} else {
		WNGsyn( "bit fields ignored", NULL ) ;
		index = MKdcl( ctx, name ) ;
	}
	return index ;
}
/*----------------------------------------------------------------------------*/
PCItype STRend( s_index )	int s_index ; {

/* -- Terminates a union/structure declaration. Computes field offsets,
      union/structure size and alignment.
      INPUT  : s_index, index of union/struct in structure list.
      RETURNS: the type define by the structure
   -- */

	unsigned offset, f_size, f_algn ; fieldrep *f ; PCItype t ;
#if DEBUG
	printf( "STRend : enter <%s> (%s)\n", stc__list[s_index]->name,
	        stc__list[s_index]->Union ? "UNION" : "STRUCT"  ) ;
#endif
  	
/* -- Offsets.
   -- */
   offset = 0 ;
   f = stc__list[s_index]->flds ;
   FIELDbegin( s_index, f )
   	f_size = TYPsizeof( &f->type ) ;
   	f_algn = TYPalign ( &f->type ) ;
#if DEBUG
	printf( "STRend : f_size %u\n", f_size ) ;
	printf( "STRend : f_algn %u\n", f_algn ) ; fflush( stdout ) ;
#endif

/* --	If field is of not-yet-defined type of which alignment and size cannot
	be computed (user error), size and alignment are zero. They are given
	a non-zero value to prevent crashed.
   -- */
	if( f_size == 0 ) f_size = 1 ;
	if( f_algn == 0 ) f_algn = 1 ;
#if DEBUG
	printf( "STRend : f_size %u\n", f_size ) ;
	printf( "STRend : f_algn %u\n", f_algn ) ; fflush( stdout ) ;
#endif
   	if( stc__list[s_index]->Union ) f->offs = 0 ;
   	else {
#if DEBUG
	printf( "STRend : in offset computation\n" ) ; fflush( stdout ) ;
#endif
   		while( offset % f_algn ) offset++ ;
   		f->offs = offset ;
   		offset += f_size * FIELDcells( f ) ;
   	}
   FIELDend( f )

#if DEBUG
	printf( "STRend : after offset computation\n" ) ; fflush( stdout ) ;
#endif

/* -- Size.
   -- */
  if( stc__list[s_index]->Union ) {
  	 UNIsizeof( s_index ) ;
  	 t.Def = UNION ;
  } else {
  	 STRsizeof( s_index ) ;
  	 t.Def = STRUC ;
  }
  STRpull() ;

  t.Dim = 0 ; t.Rpt = t.Fpt = t.Ptr = FALSE ; t.Num = s_index ;

#if DEBUG
	printf( "STRend : EXIT\n" ) ; fflush( stdout ) ;
#endif
  return t ;

} /* STRend */
/*----------------------------------------------------------------------------*/
void STRdump( F )	FILE *F ; {

/* -- For debugging purposes ( nobody's perfect )
   -- */

	int i ; fieldrep *f ; structrep *s ; char *s1, *s2 ; void TYPname() ;

   if( stc__count ) {
     fprintf( F, "\n\t\t\t\tUNION/STRUCT LIST\n\t\t\t\t-----------------\n" ) ;
     for( i = 0 ; i < stc__count ; i++ ) {
   	s = stc__list[i] ;
   	if( s->dclrd ) {
   	  fprintf( F, "\n%d\t%s (%s), size %u, alignment %u\n", i, s->name,
   		 s->Union ? "U" : "S", s->size, s->align ) ;
   	  FIELDbegin( i, f )
   	   TYPname( &f->type, &s1, &s2 )  ;
   	   fprintf( F, " off %4u %-8.8s %-24.24s ptr %2d dim %4d\t%s\n",
   	               f->offs, s1, s2, f->type.Ptr, f->type.Dim, f->name ) ;
   	  FIELDend( f )
   	} else {
   	  fprintf( F, "\n%d\t%s (%s), undeclared", i, s->name,
   		 s->Union ? "U" : "S" ) ;
   	}
   		
     }
     fprintf( F, "\n" ) ;
   }

} /* STRdump */
/*----------------------------------------------------------------------------*/
