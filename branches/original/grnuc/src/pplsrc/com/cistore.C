/*
** cistore.C
**
** GARDELLA Dominique
**
** Contains the functions needed to save all the data issued by the parsing on
** a regular file, and to retrieve all these informations.
**
** creation	: April 87
** modification : Checking of the version number ( 23/04 )
**              : Improvement due to registers ( 29/04 )
**		: Elimination of pointers on the data segment ( 19/05 )
*/

#define _1st_VAR 0
#define TRUE	1
#define FALSE	0
#define TELL( m, text ) if( (m) != NULL ) strcpy( m, text )

#define CIM_PRINT(var1,var2) \
    if ( fprintf( dot_e, var1, var2 ) < 0 ) { \
	TELL( errmess, "error in printing the parsed file" ) ; \
	return 0 ; \
    }
#define CIM_WRITE( var1, var2, var3 ) \
    if( fwrite( var1, var2, var3, dot_e ) <= 0 ) { \
	TELL( errmess, "error in writing the parsed file" ) ; \
	return 0 ; \
    }
#define CIM_SCAN( var1, var2 ) \
    if ( fscanf( dot_e, var1, var2 ) < 0 ) { \
	*msg = CI_E_ACCCOMPILED ; \
	return 0 ; \
    }
#define CIM_READ( var1, var2, var3 ) \
    if ( fread(var1, var2, var3, dot_e) <= 0 ) { \
	*msg = CI_E_ACCCOMPILED ; \
	return 0 ; \
    }
#define CIM_IF_NULL_ABORT( var1 ) \
    if ( ( var1 ) == 0 ) { \
	TELL( errmess, "cannot save file without variables or parameters" ) ; \
	return 0 ; \
    }
#define EXEC 1

#define CCI	1
#include "cidef.h"
#include "citypedef.h"
#include "ciprivmacros.h"
#include "OMerrordef.h"
#include "cierrordef.h"
#include <malloc.h>
#include <string.h>

static int sz_char	= sizeof(char),
	   sz_short	= sizeof(short),
	   sz_unsigned	= sizeof(unsigned int);

/*----------------------------------------------------------------------------*/
#define CIMAGIC_STRING	"!<ci>\n"
#define CIMAGIC_LENGTH    ( sizeof( CIMAGIC_STRING ) - 1 )
/*----------------------------------------------------------------------------*/
int store_parsed(	file_name	,
			tag		,
			code		,
			data_seg_addr	,
			text_seg_addr	,
			extnum		,
			errmess		)

char			*file_name	;
char			*tag		;
struct instance_ci	*code		;
char			*data_seg_addr	;
short			*text_seg_addr	;
int			extnum		;
char			*errmess	;

/* -- Writes compiled data and instructions to a file.
      INPUT  : file_name	, file to write to
      	       tag		, user-defined tag ( if NULL, "" is written )
               code     	, pointer to record of compiled code
               data_seg_addr	, address of data segment
               text_seg_addr	, address of text segment
               extnum		. TRUE if there are external symbols.
      OUTPUT : errmess		, contains error message
      RETURNS: 1 if successfully completed and 0 if write problem
   -- */

{
    char	*data_addr,
		*next_char;

    register int i,		/* all purpose index */
    		 sz_names = 0;	/* size needed for variable names */

    unsigned     sz_text,	/* size of the text segment ( Nb of short ) */
		 sz_data,	/* ----------- data --------------- char  - */  
		 blank		= 1,
		 nb_blank	= 0,
		 nb_util	= 0;

    FILE	*dot_e	;		/* created ( or updated ) file */

#undef cival
#define cival( i ) ( code->varvaltable[i] )

#ifdef DEBUG
	printf( "store_parsed : entering\n" ) ; fflush( stdout ) ;
#endif

/*
** Open the file
*/
    if ( ( dot_e = fopen( file_name, "w" ) ) == NULL ) {
    	sprintf( errmess, "cannot open %s for writing", file_name ) ;
	return 0 ;
    }

#ifdef DEBUG
	printf( "store_parsed : file opened\n" ) ; fflush( stdout ) ;
#endif
/*
** Version number.
** Number of variables, of instructions, size of the text segment, of the data
** segment, address of the data segment, space needed for variable names, first
** instruction number.
*/
    if( tag == NULL ) tag = "" ;

    sz_text = (unsigned) ( text_seg_addr - code->code[0].paramlist ) ; 
    sz_data = (unsigned) ( data_seg_addr - code->varvaltable[0]    ) ;

    for( i = 0 ; i < code->nbvar ; i++ ) {
#ifdef DEBUG
	printf( "store_parsed : <%s>\n", code->vartable[i] ) ; fflush( stdout ) ;
#endif
    	sz_names += ( strlen( code->vartable[i] ) + 1 ) ;
    }
    
    if( fprintf( dot_e, "%s %s %d %s %d %d %d %d %d %d %d %d ",
    		 CIMAGIC_STRING		,
    		 CI_VERSION_NUMBER	,
    		 strlen( tag )		,
    		 tag			,
    		 extnum			,
		 code->nbvar		,
		 code->nbinstr		,
		 sz_text		,
		 sz_data		,
		 (unsigned)( cival(0) )	,
		 sz_names		,
		 code->nbf_entries	 ) < 0 ) {
    	TELL( errmess, "error in saving the parsed file" ) ;
	return 0 ;
    }
#ifdef DEBUG
	printf( "store_parsed : header written\n" ) ; fflush( stdout ) ;
#endif

/*    
 * All the instructions: the first field of the structure ci_instruction
 * isn't saved (cf. ci.h)
 */
    for( i = 0 ; i < code->nbinstr ; i++ )
        CIM_WRITE( &code->code[i].type, 2, 1 )

#ifdef DEBUG
	printf( "store_parsed : instr written\n" ) ; fflush( stdout ) ;
#endif
/* Their parameters */
    CIM_IF_NULL_ABORT( sz_text )
    CIM_WRITE( code->code->paramlist, sz_short, sz_text )

#ifdef DEBUG
	printf( "store_parsed : instr params header written\n" ) ; fflush( stdout ) ;
#endif
/* Variables values */
    CIM_IF_NULL_ABORT( code->nbvar - _1st_VAR )
    CIM_WRITE( code->varvaltable + _1st_VAR, sizeof( NULL ),
                        code->nbvar - _1st_VAR )
    for( next_char = cival(0) ; next_char < data_seg_addr ; next_char++ ) {
	if ( *next_char == 0 ) {
	    nb_blank++ ;
	    if ( !blank ) {
		CIM_WRITE( &nb_util	, sz_unsigned	, 1		)
		CIM_WRITE( data_addr	, sz_char	, nb_util	)
		nb_util	= 0	;
		blank	= 1	;
	    }
	} else {
	    nb_util++ ;
	    if( blank ) {
		CIM_WRITE( &nb_blank, sz_unsigned, 1 )
		nb_blank	= 0		;
		data_addr	= next_char	;
		blank		= 0		;
	    }
	}
    } if( blank ) {
	CIM_WRITE( &nb_blank	, sz_unsigned, 1	)
	nb_util = 0;
	CIM_WRITE( &nb_util	, sz_unsigned, 1	)
    } else {
	CIM_WRITE( &nb_util	, sz_unsigned	, 1		)
	CIM_WRITE( data_addr	, sz_char	, nb_util	)
    }
    
    /* types */
    CIM_WRITE( &code->vartypetable[_1st_VAR], sz_char, code->nbvar - _1st_VAR )

    /* dimensions */
    CIM_WRITE( &code->vardimtable[_1st_VAR], sz_short, code->nbvar - _1st_VAR )

    /* scopes (DG: 24/09) */
    CIM_WRITE( &code->varflagtable[_1st_VAR], sz_char, code->nbvar - _1st_VAR )

    /* names */
    for( i = _1st_VAR ; i < code->nbvar ; i++ )
	CIM_PRINT( " %s", code->vartable[i] )


    /* f entries */
    for( i = 0 ; i < code->nbf_entries; i++ ) {
	CIM_PRINT( " %s", code->f_entries[i]->name     ) ;
	CIM_PRINT( " %d", code->f_entries[i]->no_instr ) ;
    }
/*
** Close the file
*/
    if( fclose( dot_e ) != 0 ) {
    	if( errmess != NULL ) sprintf( errmess, "cannot close %s", file_name ) ;
	return 0 ;
    }

#ifdef DEBUG
	printf( "store_parsed : exiting(1)\n" ) ; fflush( stdout ) ;
#endif
    return 1 ;

} /* store_parsed */
/*----------------------------------------------------------------------------*/
int CIreadhdr( input, vnum, tag, nbext, msg )	FILE	*input	;
						char	*vnum	,
						    	*tag	;
						long	*msg	;
						int	*nbext	; {
/* -- Reads compiled file header.
   -- */

  int	i, chr, rc = FALSE, len ;
  char 	magic[CIMAGIC_LENGTH], format[20] ;

  *msg = CI_S_SUCCESS ;
 
/* -- Check magic string
   -- */
  for( i = 0 ; i < CIMAGIC_LENGTH ; i++ ) {
   	if( ( chr = fgetc( input ) ) == EOF ) { magic[i] = '\0' ; break ; }
  	else magic[i] = chr ;
  }
  if( strncmp( magic, CIMAGIC_STRING, CIMAGIC_LENGTH ) == 0 ) {
  	if( fscanf( input, "%s%d", vnum, &len ) >= 0 ) {
  		if( len != 0 ) {
  			sprintf( format, " %%%dc%%d", len ) ;
  			if( fscanf( input, format, tag, nbext ) < 0 ) {
  				goto READ_ERROR ;
  			}
  			tag[len] = '\0' ;
  		} else  if( fscanf( input, "%d"  ,      nbext ) < 0 ) {
  				goto READ_ERROR ;
  			} else tag[0] = '\0' ;
  		rc = TRUE ;
  	} else {
  		READ_ERROR : *msg = CI_E_ACCCOMPILED ;
  	}
  } else *msg = CI_E_BADMAGICNB ;

  return rc ;
}
/*----------------------------------------------------------------------------*/
int recall_parsed( file_name		,
		   tag			,
                   p_code		,
                   extnum		,
                   msg			 )

char 			*file_name		;
char			*tag			;
struct instance_ci 	**p_code		;
int			*extnum			;
long			*msg			;

/* -- Loads a compile files into memory.
      INPUT  : file_name	, file to load.
      OUTPUT : tag		, user-defined tag ( must be a char xxx[256] )
               p_code   	, address of pointer to record to fill
               extenum, TRUE if there are external symbols else FALSE.
               errmess		, contains error message
      RETURNS: 1 if successfully completed, 0 if read problem.
      NOTE : extnum can be NULL if this info is not desired.
   -- */

#undef cival
#define cival( i ) ( data->varvaltable[i] )
{
    register int i;

    char	*old_data_addr	, /* old data segment address */
    		*name_addr	, /* addr. in the space reserved for var. names */
    		*io_addr	, /* address for I/O */
		*io_max		,
        	version[CI_MAX_VERSION],
		dummy		;
    /* for alloc ci_data	*/
    char	*dataaddr	;
    short	*textaddr	;

    short 	*text_addr;

    int		 nb_instr	, /* number of instructions */
		 nb_var		, /* --------- variables */
		 nb_regs = 0    , /* number of registers */
                 nb_f_ent	, /* nb of function entries */
		 sz_text	, /* size of the text segment ( Nb of short ) */
		 sz_data	, /* ----------- data --------------- char  - */
		 sz_names	, /* ----------- space reserved for var. names */
		 data_addr_update;  /* delta between old and new address of */
		                    /* the data segment                      */

    FILE	*dot_e ;		/* read file */

    unsigned	 		nb_char	;
    register struct instance_ci *data	;
    int 			rc, nbext ;
    

#ifdef DEBUG
	printf( "recall_parsed : entering\n" ) ; fflush( stdout ) ;
#endif

  rc = 1 ; *msg = CI_S_SUCCESS ;

/*
** Open the file
*/
  if( ( dot_e = fopen( file_name, "r" ) ) == NULL ) {
  	*msg = CI_E_CANT_ACCESS ;
	return 0 ;
  }

#ifdef DEBUG
	printf( "recall_parsed : open successful\n" ) ; fflush( stdout ) ;
#endif
  if( !CIreadhdr( dot_e, version, tag, &nbext, msg ) ) {
  	goto CLOSE ;
  }
  if( extnum ) *extnum = nbext ;
#ifdef DEBUG
	printf( "recall_parsed : header successful\n" ) ; fflush( stdout ) ;
#endif

  if( fscanf( dot_e, "%d%d%d%d%d%d%d",
  			&nb_var		,
			&nb_instr	,
			&sz_text	,
			&sz_data	,
			&old_data_addr	,
			&sz_names	,
			&nb_f_ent	) < 0 ) {
	*msg = CI_E_ACCCOMPILED ;
	goto CLOSE ;
  }

#ifdef DEBUG
	printf( "recall_parsed : scan successful\n" ) ; fflush( stdout ) ;
#endif
  rc = sizeof( CI_VERSION_NUMBER ) - 1 ;

  if( strcmp( version, CI_VERSION_NUMBER ) != 0 ) {
  	*msg = CI_E_VER_MISMTCH ;
   	goto CLOSE ;
  }

#ifdef DEBUG
	printf( "recall_parsed : before alloc\n" ) ; fflush( stdout ) ;
#endif
/*
** Memory allocation
*/
  if( !alloc_ci_data( 	nb_var		,
                        sz_data		,
                        nb_instr	,
                        sz_text 	,
                        nb_f_ent	,
                        p_code		,
                        &dataaddr	,
                        &textaddr	) ) {
  				*msg = CI_E_CANT_MALLOC ;
                        	goto CLOSE ;
  }
#ifdef DEBUG
	printf( "recall_parsed : after alloc_ci_data\n" ) ; fflush( stdout ) ;
#endif

  data = *p_code ;
  if( !( data->vartable[0] = malloc( sz_names ) ) ) {
  				*msg = CI_E_CANT_MALLOC ;
                        	goto CLOSE ;
  }
#ifdef DEBUG
	printf( "recall_parsed : after malloc vartable\n" ) ; fflush( stdout ) ;
#endif

  text_addr		= data->code->paramlist 	;
  data_addr_update	= cival(0) - old_data_addr 	;

/*      All the instructions */
#ifdef DEBUG
	printf( "recall_parsed : reading instr\n" ) ; fflush( stdout ) ;
#endif
  data->nbinstr = nb_instr ;
  CIM_READ( &dummy, 1, 1 )	/* smooth transition between fscanf and fread */

  for( i = 0 ; i < nb_instr; i++ ) CIM_READ( &data->code[i].type, 2, 1 )
  data->code->paramlist = text_addr;
  for( i = 1 ; i < nb_instr ; i++ )
  	data->code[i].paramlist =   data->code[i-1].paramlist
                                  + data->code[i-1].nbparam + 1 ;

/*      Their parameters */
#ifdef DEBUG
	printf( "recall_parsed : reading params\n" ) ; fflush( stdout ) ;
#endif
  CIM_READ( text_addr, sz_short, sz_text )

/*        Variables */
#ifdef DEBUG
	printf( "recall_parsed : reading vars\n" ) ; fflush( stdout ) ;
#endif
  data->nbvar	= nb_var	;
  io_addr	= cival(0)	;
#ifdef DEBUG
	printf( "recall_parsed : reading addresses\n" ) ; fflush( stdout ) ;
#endif
  CIM_READ( data->varvaltable + _1st_VAR, sizeof( NULL ), nb_var - _1st_VAR )
  io_max = io_addr + sz_data;

  while( io_addr < io_max ) {
	    CIM_READ( &nb_char, sz_unsigned, 1 )
	    for( i=0 ; i < nb_char ; i++ ) io_addr[i] = '\0' ;
            io_addr += nb_char ;

	    CIM_READ( &nb_char, sz_unsigned, 1 )
	    if( nb_char > 0 ) CIM_READ( io_addr, sz_char, nb_char )
            io_addr += nb_char ;
  }

    /*    types */
#ifdef DEBUG
	printf( "recall_parsed : reading types\n" ) ; fflush( stdout ) ;
#endif
  CIM_READ( &data->vartypetable[_1st_VAR], sz_char, data->nbvar - _1st_VAR )

    /*    dimensions */
#ifdef DEBUG
	printf( "recall_parsed : reading dimensions\n" ) ; fflush( stdout ) ;
#endif
  CIM_READ( &data->vardimtable[_1st_VAR], sz_short, data->nbvar - _1st_VAR )

    /*    scopes (DG: 24/09) */
#ifdef DEBUG
	printf( "recall_parsed : reading scopes\n" ) ; fflush( stdout ) ;
#endif

  CIM_READ( &data->varflagtable[_1st_VAR], sz_char, data->nbvar - _1st_VAR )

  name_addr = data->vartable[_1st_VAR];
  for( i = _1st_VAR ; i < nb_var ; i++ ) {
	    /* names */
	    CIM_SCAN( " %s", name_addr )
#ifdef DEBUG
	printf( "recall_parsed : read <%s>\n", name_addr ) ; fflush( stdout ) ;
#endif
	    data->vartable[i] = name_addr;
	    name_addr += ( strlen( data->vartable[i] ) + 1 ) ;

	    /* count registers for context save */
	    if(data->vartable[i][0] == '^')
		    nb_regs++;

	    /* values */
	    if(    data->vartable[i][0] != '@' 
	        && !( data->varflagtable[i] & CI_XTRN ) )
	        cival(i) += data_addr_update;
  }

  /* create register save info */
  { int tsize = 0;

    data->save_regs_info = (CIregsave *)malloc ((nb_regs + 1) * sizeof (CIregsave));
    data->save_regs_info[nb_regs].addr = 0;
    data->save_regs_info[nb_regs].size = 0;

    for (i = _1st_VAR; i < nb_var; i++) {
      if (data->vartable[i][0] == '^') {
        switch (data->vartable[i][1]) {
          case 'D': tsize += data->save_regs_info[--nb_regs].size = 8; break;
          case 'p':
          case 'I':
          case 'O': tsize += data->save_regs_info[--nb_regs].size = 4; break;
          case 'S': tsize += data->save_regs_info[--nb_regs].size = 2; break;
          case 'C': tsize += data->save_regs_info[--nb_regs].size = 1; break;
          default : tsize += data->save_regs_info[--nb_regs].size = 0; break;
        }
        data->save_regs_info[nb_regs].addr = cival (i);
      }
    }
    data->save_regs_buff = malloc (tsize);
  }

          /* This is the first free address ( used to compute struct sizes ) */
#ifdef DEBUG
	printf( "recall_parsed : nv_var %d cival( 0 ) %d sz_data %d\n", nb_var,
	cival( 0 ), sz_data ) ; fflush( stdout ) ;
#endif
  for( i = 0 ;    data->varflagtable[i] & CI_XTRN
	       || *data->vartable[i] == '@'       ; i++ ) ;
  cival( nb_var ) = cival( i ) + sz_data ;

/*        close the list of names */
  data->vartable[nb_var] = NULL ;

    /*    f entries */
#ifdef DEBUG
	printf( "recall_parsed : reading functions\n" ) ; fflush( stdout ) ;
#endif
  data->nbf_entries = 0 ;
  for( i = 0 ; i < nb_f_ent ; i++ ) {
	char s[80] ;
	short no_instr;
	CIM_SCAN( " %s", s ) ;
	CIM_SCAN( " %hd", &no_instr ) ;
        if( !create_f_ent( data, s, no_instr ) ) {
        	*msg = CI_E_CANT_MALLOC ;
		goto CLOSE ;
        }
  }

/*
** Close the file
*/
  CLOSE :
  if( fclose( dot_e ) != 0 ) {
  	*msg = CI_E_ACCCOMPILED ;
  }
#ifdef DEBUG
	printf( "recall_parsed : exiting msg = %d\n", *msg ) ; fflush( stdout ) ;
#endif

  
  return *msg == CI_S_SUCCESS ;

} /* recall_parsed */
/*----------------------------------------------------------------------------*/
