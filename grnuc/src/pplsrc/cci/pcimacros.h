/*
 * Contains the macro definitions for the CI compiler sources files
 */

#ifndef PCIMACROS_INCLUDE
#	define PCIMACROS_INCLUDE
#	include "pci.h"
#	include "pcidef.h"

/* -- Counts external references
   -- */
#	define PCI_Count_externals()   PCI_G_externals++
#	define PCI_If_externals()      ( PCI_G_externals > 0 )

/* -- Currently scanned file init and retrieve
   -- */
#	define PCI_Set_current_file( f ) strcpy( PCI_G_curfile, (f) )
#	define PCI_Get_current_file()    PCI_G_curfile

/* -- Current line number manipulation
   -- */
#	define PCI_Set_current_line( l ) PCI_G_curline = (l)
#	define PCI_Get_current_line()    PCI_G_curline
#	define PCI_Incr_current_line()   PCI_G_curline++

/* -- Remembers if a variable was used
   -- */
#	define PCIusd( var )	( PCI_G_used[(var)] )

/* -- Screening of type, segment, current function ...
   -- */
#	define  PCIdef( var )	( PCI_G_type[(var)] )
#	define pPCIdef( var )	( PCI_G_type + (var)  )
#	define PCIseg		PCI_G_segment
#	define PCIerr		PCI_G_synerr
#	define PCIfcn		PCI_G_curfunc
#	define PCIopt		PCI_G_options
#	define PCIgen		PCI_G_genins
#	define PCIvoid		PCI_G_void

/* -- Accesses to fields of compiled code via global pointer. This is mostly
   -- intended to insulate the code from drastic changes of this global data
   -- structure.
   -- `var' is the index of the variable
   -- */
#	define PCIdata		PCI_G_p_code
#	define PCIvar( var )	( PCI_G_var[(var)] 	)
#	define PCIdim( var )   	( PCI_G_dim[(var)] 	)
#	define PCItyp( var )   	( PCI_G_typ[(var)] 	)
#	define PCIsts( var )	( PCI_G_sts[(var)] 	)
#	define PCInvar		( PCIdata->nbvar   	)
#	define PCIcode		( PCIdata->code    	)
#	define PCInins		( PCIdata->nbinstr 	)
#	define PCInufn		( PCIdata->nbf_entries	)
#	define PCIfile		( PCIdata->ficcmd  	)

/* -- Macros giving access to the value of the variable at index "i", according
   -- to its type.
   -- */
#	define PCIadr( var )	( PCI_G_adr[(var)] )
#	define PCIval( var )	(  PCIadr( var ).Chr )
#	define PCIdbl( var )	( *PCIadr( var ).Dbl )
#	define PCIint( var )	( *PCIadr( var ).Int )
#	define PCIshr( var )	( *PCIadr( var ).Shr )
#	define PCIchr( var )	( *PCIadr( var ).Chr )
#	define PCIobj( var )	( *PCIadr( var ).Obj )
#	define PCIptr( var )	( *PCIadr( var ).Pch )
#	define PCIstr( var )	( ispointer( var ) ? PCIptr( var ) \
				                   : PCIval( var ) )
/* -- Macro acceeding to table of labels.
   -- */
#	define PCInlab		( PCI_G_nlabel )

/* -- Allocation.
   -- */
#define MALLOC(  p, s, t ) \
	( (p) = (t *) malloc( (unsigned) (s) * sizeof( t ) ) )
#define REALLOC( p, s, t ) \
	( (p) = (t *) realloc( (char *) (p), (unsigned) (s) * sizeof( t ) ) )
#define ALLOC(   p, s, t ) \
  ( (p) = (t *) ( !(p) ? malloc( (unsigned) (s) * sizeof( t ) ) \
  	               : realloc( (char *) (p), (unsigned) (s) * sizeof( t ) )))
#define FREE( p )	if( p ) free( (char *) (p) )

/* -- Stack occupancy.
   -- */
#	define GAP( s ) ( (s) < sizeof( long ) ? sizeof( long ) : (s) )

/* -- Valid identifier character.
   -- */
#define isidchar( c ) ( isalpha( c ) || c == '_' || c == '$' )

/* -- 1st and 2nd byte manipulation
   -- */
#	define LObyte( u )	( (u) & BYTEMASK )
#	define HIbyte( u )	LObyte( (u) >> CHAR_BIT )
#	define Lshift( u )	( (u) << CHAR_BIT )
#	define Rshift( u )	( (u) >> CHAR_BIT )

/* -- Extracts BaSic type number stored in the first four bits ( from right )
      ( CI_CHAR ... CI_STRUCT )
   -- */
#	define BStype( u )	( (u) & 0xf )
#endif
