/* -- CI/CCI common library
      Allocation and releasing of an instance_ci pointer.


		- alloc_ci_data
		- free_ci_data

      Etienne BEEKER, Dominique GARDELLA, Alain FALASSE. ISDC, Paris.
   -- */

#define CCI	1
#include "cidef.h"
#include "citypedef.h"
#include <malloc.h>
/*-MACROS---------------------------------------------------------------------*/
/* -- Shorter form for malloc and free
   -- */
#define Malloc( type, nbcell ) (type  *) malloc( (nbcell) * sizeof( type ) )
#define Free( p ) if( (p) != NULL ) free( (char *) (p) )
/*----------------------------------------------------------------------------*/
/* -- To compact mallocs
   -- */
typedef struct instance_ci	ciinfo ;
typedef struct ci_instruction	ciinst ;
typedef struct f_entry		cifent ;
/*----------------------------------------------------------------------------*/
int alloc_ci_data( nb_var	,
                   sz_data	,
                   nb_instr	,
                   sz_text	,
                   nb_f_entries	,
                   p_code	,
                   p_data_seg_ad,
                   p_text_seg_ad
				)

int 	nb_var	, sz_data, nb_instr, sz_text, nb_f_entries ;
ciinfo 	**p_code	;
char	**p_data_seg_ad	;
short	**p_text_seg_ad	;

/* -- Allocates memory to store the parsed code.
      INPUT  : nb_var		, number of variables
               sz_data		, size required by the data segment
               nb_instr		, number of instructions
               sz_text		, size ( in bytes ) required by the text segment
               nb_f_entries	, number of function entries
      OUTPUT : p_code		, address of pointer to code
               p_data_seg_ad	, address of pointer to data segment 
               p_text_seg_ad	, address of pointer to text segment 
      RETURNS: 1 if succefully completed and 0 if of memory allocation failure
   -- */

{
    int rc ;
#ifdef DEBUG
	printf( "alloc_ci_data : entering\n" ) ; fflush( stdout ) ;
	printf( "\tnb_var\t%d\n\tsz_data\t%d\n\tnb_instr\t%d\n", nb_var,
	        sz_data, nb_instr ) ;
	printf( "\tsz_text\t%d\n\tnb_f_entries\t%d\n", sz_text, nb_f_entries ) ;
	fflush( stdout ) ;
#endif

/* Allocates in order
	- the record
	- the instruction array ( paramlist point to text segment )
	- the variable name and value tables ( index 0 points to data segment )
	- the function entry array
	-------------------------- */
  if(    ( (*p_code)                  = Malloc( ciinfo	, 1		) )
      && ( (*p_code)->code            = Malloc( ciinst	, nb_instr	) )
      && ( (*p_code)->code->paramlist = Malloc( short	, sz_text	) )
      && ( (*p_code)->vartable        = Malloc( char *	, nb_var + 1	) )
      && ( (*p_code)->varvaltable     = Malloc( char *	, nb_var + 1	) )
      && ( (*p_code)->vartypetable    = Malloc( char  	, nb_var + 1	) )
      && ( (*p_code)->varflagtable    = Malloc( unsigned char , nb_var + 1) )
      && ( (*p_code)->vardimtable     = Malloc( unsigned short, nb_var + 1) )
      && ( (*p_code)->varvaltable[0]  = Malloc( char	, sz_data	) )
      && ( (*p_code)->f_entries       = Malloc( cifent *, nb_f_entries	) ) ) {
      	
#ifdef DEBUG
	printf( "alloc_ci_data : after all mallocs\n" ) ; fflush( stdout ) ;
#endif
    (*p_code)->save_regs_info = 0;
    (*p_code)->save_regs_buff = 0;

    *p_text_seg_ad = (*p_code)->code->paramlist ;
    *p_data_seg_ad = (*p_code)->varvaltable[0]  ;
    
    rc = 1 ;
  } else rc = 0 ;

#ifdef DEBUG
	printf( "alloc_ci_data : exiting ptr = %d\n", *p_code ) ;
	fflush( stdout ) ;
#endif
  return rc ;

} /* alloc_ci_data */
/*----------------------------------------------------------------------------*/
void free_ci_data( code, old )

ciinfo *code ;
int    old   ;

/* -- Frees all data allocated in alloc_ci_data.
      INPUT  : code, pointer to record to free
               old , flags if the file is an old one
   -- */

{
  int i ; char **s ; cifent **f_e ;

/* Variables
   --------- */
   if( old ) { Free( code->vartable[0] ) ;
   } else    for( i = 0, s = code->vartable ; i < code->nbvar ; i++, s++ )
   			Free( *s ) ;

   Free( code->vartable		)	;
   Free( code->varvaltable[0]	)	;
   Free( code->varvaltable	)	;
   Free( code->vartypetable	)	;
   Free( code->varflagtable	)	;
   Free( code->vardimtable	)	;
   Free( code->save_regs_buff	)	;
   Free( code->save_regs_info	)	;

/* Instructions
   ------------ */
   Free( code->code->paramlist	)	;		/* parameters	*/
   Free( code->code		)	;		/* instructions	*/

/* Function entries
   ---------------- */
   for( i = 0, f_e = code->f_entries ; i < code->nbf_entries ; i++, f_e++ ) {
	Free( (*f_e)->name ) ;
	Free( *f_e	   ) ;
   }
   Free( code->f_entries )	;

/* 'code' itself
   ------------- */
#ifdef DEBUG
   printf( "free_ci_data : freeing %d\n", code ) ;
#endif
   Free( code ) ;

} /* free_ci_data */
/*----------------------------------------------------------------------------*/

