/* -- This module handles ci's build in functions
   -- SYS = SYStem function
   -- */
/*-INCLUDES-------------------------------------------------------------------*/
#include "pci.h"
#include "pcidef.h"
#include "pcimacros.h"
#include "cichardef.h"
#include "cidef.h"
#include "citypedef.h"
#include <stdio.h>
#include <search.h>
#include <string.h>
/*-CONSTANTS------------------------------------------------------------------*/
#define VARGS	BYTEMASK
#define VTYPE	0x100
#define ENDLIB	"."
#define DEBUG	0

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

static int SYSdump __((PCIlist *dp));
static int SYSnocheck __((PCIlist *ig));
static int SYSio __((PCIlist *io));

#if defined(__cplusplus)
}
#endif
#undef __


/*-MACROS---------------------------------------------------------------------*/
/* -- Used to  fill the  elements of the arrays. Types  of the lib functions are
      BASIC and are not arrays ( null dimension ).
   -- */
   /* RM
#define __atype( Num, Ptr )	{ 0, BASIC, 0, Ptr, 0, Num }
*/
/*                                Def    Rpt Ptr Fpt Dim Num Spc	*/
#define __atype( Num, Ptr )	{ BASIC, 0 , Ptr, 0,  0, Num, NULL }

/* -- Used to fill the `args' field of the structure `syscheck' : `__a' if
      arguments are checked with an array, `__f' with a function.
   -- */
#define __a( array )		{ array, NULL  }
#define __f( funct )		{ NULL , funct }

/* -- If an argument can  be of variable type, flags that the next array element
      contains a possible type for that argument.
   -- */
#define ELSE			| VTYPE

/* -- Generates function name as inserted in hash table.
   -- */
#define MKHNAME( hname, fname )	*( strcpy( hname + 1, (fname) ) - 1 ) = SYSFUN
/*----------------------------------------------------------------------------*/
/* -- Above is the list of all the library functions :
      - name
      - type of the returned value ( bitwise ORed with `PTR' if pointer to ... )
      - number of arguments
      - argument type checking structure : either  an array containing the types
        of the  arguments, or  a  pointer to a  function  that will  perform the
        checks.
      The list is ended by ENDLIB, 0, NULL, { ... }.
      You can insert ( or remove ) a function just anywhere.

   -- */


typedef struct { char					*name	, type  ;
                 Uchar					nargs		;
                 struct { PCItype *typearray   ;
                 	  int     (*typefun)() ; } 	args		;
} syscheck ;

/* -- Arrays of argument types for every function.
   -- */

/* -- prompt, status, message (int: message number, char *: string)
      1: int | char *
   -- */
static PCItype ARGprompt[]	= {	__atype( CI_CHAR   ELSE	, TRUE  ),
					__atype( CI_INT		, FALSE )
} ;

/* -- Form functions needing a string as sole argument.
   -- */
static PCItype ARGstring[]	= {	__atype( CI_CHAR	, TRUE ),
} ;

static PCItype ARGstrcpy[]	= {	__atype( CI_CHAR	, TRUE ),
					__atype( CI_CHAR	, TRUE )
} ;

static PCItype ARGstrlen[]	= {	__atype( CI_CHAR	, TRUE ),
} ;

static PCItype ARGmemcpy[]	= {	__atype( CI_CHAR	, TRUE ),
					__atype( CI_CHAR	, TRUE ),
  					__atype( CI_INT 	, FALSE )
} ;

static PCItype ARGmsonoff[]	= {	__atype( CI_INT		, FALSE )
} ;

static PCItype ARGsin[]		= {	__atype( CI_DOUBLE	, FALSE )
} ;

static PCItype ARGatan2[]	= {	__atype( CI_DOUBLE	, FALSE ),
					__atype( CI_DOUBLE	, FALSE )
} ;

/* -- SCIdelete
      1:char *, 2:GRobj.
   -- */
static PCItype ARGdelete[]	= {	__atype( CI_CHAR	, TRUE	), /*1*/
  					__atype( CI_GROBJ	, FALSE	)  /*2*/
} ;

/* -- SCIinq_files
      1:int *, 2:char **.
   -- */
static PCItype ARGinq_files[]	= {	__atype( CI_INT		, TRUE	), /*1*/
  					__atype( CI_CHAR	, TRUE	)  /*2*/
} ;

/* -- SCIinq_objects
      1:char *, 2:int *, 3:GRobj *.
   -- */
static PCItype ARGinq_objects[]	= {	__atype( CI_CHAR	, TRUE	), /*1*/
  					__atype( CI_INT		, TRUE	), /*2*/
  					__atype( CI_GROBJ	, TRUE	)  /*3*/
} ;

/* -- CIquiet
      1:int, 2:int, 3:int.
   -- */
static PCItype ARGquiet[]	= {	__atype( CI_INT	, FALSE	),	/*1*/
  					__atype( CI_INT	, FALSE	),	/*2*/
  					__atype( CI_INT	, FALSE	)	/*3*/
} ;

/* -- CIexec
      1:char *, 2:GRobj *, 3:short *, 4:char *, 5:int, 6:int, 7:int, 8:void *
   -- */
static PCItype ARGexec[]	= {	__atype( CI_CHAR	, TRUE	), /*1*/
  					__atype( CI_GROBJ	, TRUE	), /*2*/
  					__atype( CI_CHAR	, TRUE	), /*3*/
  					__atype( CI_INT 	, FALSE ), /*4*/
  					__atype( CI_INT 	, FALSE ), /*5*/
  					__atype( CI_INT 	, FALSE ), /*6*/
  					__atype( CI_INT 	, FALSE ), /*7*/
  					__atype( CI_VOID 	, TRUE  ), /*8*/
  					__atype( CI_INT 	, FALSE ), /*9*/
  					__atype( CI_INT 	, TRUE  ), /*0*/
} ;
   
/* -- CIlocate
       1:GRobj *      ,  2:short *,  3:char   * | int,  4:char * | int,
       5:char  * | int,  6:char  *,  7:char   *      ,  8:double *    ,
       9:double *     , 10:int    , 11:GRobj  *      , 12:short  *    ,
      13:int          , 14:int    , 15:double *      , 16:double *    ,
      17:int    *     , 18:int *  , 19:char   *
   -- */ 
static PCItype ARGlocate[]	= {	__atype( CI_GROBJ	, TRUE	), /*1*/
  					__atype( CI_SHORT	, TRUE	), /*2*/
  					__atype( CI_CHAR ELSE	, TRUE	), /*3*/
  					__atype( CI_INT 	, FALSE ), /*3*/
  					__atype( CI_CHAR ELSE	, TRUE	), /*4*/
  					__atype( CI_INT 	, FALSE ), /*4*/
  					__atype( CI_CHAR ELSE	, TRUE	), /*5*/
  					__atype( CI_INT 	, FALSE ), /*5*/
  					__atype( CI_CHAR	, TRUE	), /*6*/
  					__atype( CI_CHAR	, TRUE	), /*7*/
  					__atype( CI_DOUBLE	, TRUE	), /*8*/
  					__atype( CI_DOUBLE	, TRUE	), /*9*/
  					__atype( CI_INT 	, FALSE ), /*0*/
					__atype( CI_GROBJ	, TRUE	), /*1*/
  					__atype( CI_SHORT	, TRUE	), /*2*/
  					__atype( CI_INT 	, FALSE ), /*3*/
  					__atype( CI_INT 	, FALSE ), /*4*/
  					__atype( CI_DOUBLE 	, TRUE  ), /*5*/
  					__atype( CI_CHAR 	, TRUE  ), /*6*/
  					__atype( CI_INT 	, TRUE  ), /*7*/
  					__atype( CI_INT 	, TRUE  ), /*8*/
  					__atype( CI_CHAR 	, TRUE  )  /*9*/
} ;
   
/* -- CIget_module_info
   -- */ 
static PCItype ARGget_module_info[]	= {
  					__atype( CI_STRUCT	, TRUE  ),
  					__atype( CI_GROBJ	, TRUE	),
  					__atype( CI_SHORT 	, TRUE  ) 
} ;

/* -- CIgetevent
      1:char *, 2:int *, 3:int *, 4:int, 5:GRobj *, 6:short *, 7:char * | int,
      8: int.
   -- */ 
static PCItype ARGgetevent[]	= {	__atype( CI_VOID	, TRUE	), /*1*/
  					__atype( CI_INT  	, TRUE	), /*2*/
  					__atype( CI_VOID  	, TRUE	), /*3*/
  					__atype( CI_INT 	, FALSE ), /*4*/
  					__atype( CI_GROBJ	, TRUE	), /*5*/
  					__atype( CI_SHORT	, TRUE  ), /*6*/
  					__atype( CI_CHAR   ELSE	, TRUE  ), /*7*/
  					__atype( CI_INT		, FALSE ), /*7*/
  					__atype( CI_INT 	, FALSE )  /*8*/
} ;

/* -- CIputevent
      1:int, 2:int           , 3:char *  , 4:short * | double * | GRobj *,
      5:int, 6:char * | GRobj, 7:double *, 8: struct *.
   -- */ 
static PCItype ARGputevent[]	= {	__atype( CI_INT		, FALSE	), /*1*/
  					__atype( CI_INT  	, FALSE	), /*2*/
  					__atype( CI_CHAR   ELSE , TRUE	), /*3*/
  					__atype( CI_DOUBLE ELSE	, TRUE	), /*3*/
  					__atype( CI_GROBJ	, TRUE	), /*3*/
  					__atype( CI_SHORT	, TRUE	), /*4*/
  					__atype( CI_INT 	, FALSE ), /*5*/
  					__atype( CI_CHAR   ELSE , TRUE  ), /*6*/
  					__atype( CI_GROBJ	, FALSE ), /*6*/
  					__atype( CI_DOUBLE  	, TRUE	), /*7*/
  					__atype( CI_STRUCT  	, TRUE	)  /*8*/
} ;

/* -- CIsend
       1:char *		, 2:char *, 3:CI_STRUCT, 4:int   ,  5:GRobj | char *,
       6:short | char *	, 7:int   , 8:int      , 9:char *, 10:int
      11: void *
   -- */
static PCItype ARGsend[]	= {	__atype( CI_CHAR	, TRUE	), /*1*/
  					__atype( CI_CHAR 	, TRUE	), /*2*/
  					__atype( CI_STRUCT 	, FALSE	), /*3*/
  					__atype( CI_INT 	, FALSE ), /*4*/
  					__atype( CI_GROBJ  ELSE	, FALSE ), /*5*/
  					__atype( CI_CHAR	, TRUE	), /*5*/
  					__atype( CI_SHORT  ELSE	, FALSE ), /*6*/
  					__atype( CI_CHAR	, TRUE  ), /*6*/
  					__atype( CI_INT  	, FALSE ), /*7*/
  					__atype( CI_INT  	, FALSE ), /*8*/
  					__atype( CI_CHAR 	, TRUE  ), /*9*/
  					__atype( CI_INT  	, FALSE ), /*0*/
  					__atype( CI_VOID  	, TRUE  )  /*1*/
} ;

/* -- CIreadrtree
      1:GRobj *, 2:int, 3:int.
   -- */
static PCItype ARGreadrtree[]	= {	__atype( CI_GROBJ	, TRUE	), /*1*/
 					__atype( CI_INT  	, FALSE ), /*2*/
  					__atype( CI_INT  	, FALSE )  /*3*/
} ;

static PCItype ARGci_clonage[]	= {	__atype( CI_GROBJ	, FALSE	),
					__atype( CI_GROBJ	, TRUE	)
};

static PCItype ARGchan_obj[]	= {	__atype( CI_SHORT	, FALSE	), /*1*/
					__atype( CI_GROBJ	, FALSE	), /*2*/
					__atype( CI_CHAR	, TRUE	), /*3*/
					__atype( CI_SHORT	, TRUE	), /*4*/
					__atype( CI_GROBJ	, TRUE	), /*5*/
					__atype( CI_INT		, TRUE	)  /*6*/
} ;

/* -- CIdpdynamics
      1: char *, 2: char *, 3: void *, 4: int, 5: int *
   -- */
static PCItype ARGdpdynamics[]	= {	__atype( CI_CHAR	, TRUE	), /*1*/
					__atype( CI_CHAR	, TRUE	), /*2*/
					__atype( CI_VOID	, TRUE	), /*3*/
					__atype( CI_INT		, FALSE	), /*4*/
					__atype( CI_INT		, TRUE	), /*5*/
} ;

int cisymb(), SYSio(), SYSdump(), SYSnocheck() ;

static syscheck sys__lib[] = {
{ "aread"		, CI_INT	, VARGS	, __f( SYSio		) },
{ "fread"		, CI_INT	, VARGS	, __f( SYSio		) },
{ "pread"		, CI_INT	, VARGS	, __f( SYSio		) },
{ "write"		, CI_INT	, VARGS	, __f( SYSio		) },
{ "awrite"		, CI_INT	, VARGS	, __f( SYSio		) },
{ "fwrite"		, CI_INT	, VARGS	, __f( SYSio		) },
{ "pwrite"		, CI_INT	, VARGS	, __f( SYSio		) },
{ "prompt"		, CI_INT	, 1	, __a( ARGprompt	) },
{ "status"		, CI_INT	, 1	, __a( ARGprompt	) },
{ "message"		, CI_INT	, 1	, __a( ARGprompt	) },
{ "sh"     		, CI_INT	, 1	, __a( ARGstring	) },
{ "close"     		, CI_INT	, 1	, __a( ARGstring	) },
#ifdef CIREADRTREE
{ "readrtree"		, CI_INT	, 3	, __a( ARGreadrtree	) },
#endif
{ "dump"     		, CI_INT	, VARGS	, __f( SYSdump		) },
{ "endcmd"   		, CI_INT	, 0	, __a( NULL		) },
{ "begincmd" 		, CI_INT	, 1	, __a( ARGstring	) },
{ "begincmd_key"	, CI_INT	, 1	, __a( ARGstring	) },
{ "set_symb"  		, CI_INT	, VARGS	, __f( cisymb    	) },
{ "set_gal_symb"	, CI_INT	, VARGS	, __f( cisymb    	) },
{ "set_text_attr"	, CI_INT	, VARGS	, __f( cisymb    	) },
{ "get_symb"  		, CI_INT	, VARGS	, __f( cisymb    	) },
{ "get_text_attr"	, CI_INT	, VARGS	, __f( cisymb    	) },
{ "msonoff"      	, CI_INT	, 1	, __a( ARGmsonoff  	) },
{ "atoi"		, CI_INT        , 1	, __a( ARGstring	) },
{ "ci_clonage"		, CI_INT	, 2	, __a( ARGci_clonage	) },
{ "CIget_module_info" 	, CI_INT	, 3	, __a( ARGget_module_info)},
{ "CIgetevent"		, CI_INT	, 8	, __a( ARGgetevent 	) },
{ "CIputevent"		, CI_INT	, 8	, __a( ARGputevent 	) },
{ "CIlocate"		, CI_INT        , 19	, __a( ARGlocate 	) },
{ "SCIdelete"		, CI_INT        , 2	, __a( ARGdelete	) },
{ "SCIinq_files"	, CI_INT        , 2	, __a( ARGinq_files	) },
{ "SCIinq_objects"	, CI_INT        , 3	, __a( ARGinq_objects	) },
{ "CIquiet"		, CI_INT        , 3	, __a( ARGquiet		) },
{ "CIexec"		, CI_INT        , 10	, __a( ARGexec 		) },
{ "CIsend"		, CI_INT	, 11	, __a( ARGsend 		) },
{ "CIget_channel_objects",CI_INT	, 6	, __a( ARGchan_obj	) },
{ "CIdpdynamics"	, CI_INT	, 5	, __a( ARGdpdynamics	) },
{ "DBclose"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBcmd"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBflush"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBinit"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBopen"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBread"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBsearch"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBwrite"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBselect"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBattach"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "DBdetach"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "my_id"		, CI_GROBJ      , 0	, __a( NULL		) },
{ "my_os"		, CI_SHORT      , 0	, __a( NULL		) },
{ "sender_id"		, CI_GROBJ      , 0	, __a( NULL		) },
{ "om_call"		, CI_INT	, VARGS	, __f( SYSnocheck	) },
{ "sin"          	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "cos"          	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "tan"          	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "asin"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "acos"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "atan"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "sinh"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "cosh"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "tanh"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "sqrt"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "log"          	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "log10"        	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "exp"          	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "floor"        	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "ceil"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "fabs"         	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "gamma"        	, CI_DOUBLE	, 1	, __a( ARGsin 		) },
{ "atof"         	, CI_DOUBLE	, 1	, __a( ARGstring	) },
{ "pow"          	, CI_DOUBLE	, 2	, __a( ARGatan2		) },
{ "hypot"        	, CI_DOUBLE	, 2	, __a( ARGatan2		) },
{ "atan2"        	, CI_DOUBLE	, 2	, __a( ARGatan2		) },
{ "fmod"         	, CI_DOUBLE	, 2	, __a( ARGatan2		) },
{ "ntoa"         	, CI_CHAR | PTR	, 1	, __a( ARGsin 		) },
{ "memcpy"		, CI_CHAR | PTR	, 3	, __a( ARGmemcpy	) },
{ "strcpy"		, CI_CHAR | PTR	, 2	, __a( ARGstrcpy	) },
{ "strcmp"		, CI_INT       	, 2	, __a( ARGstrcpy	) },
{ "strcat"		, CI_CHAR | PTR	, 2	, __a( ARGstrcpy	) },
{ "strlen"		, CI_INT	, 1	, __a( ARGstrlen	) },
{ ENDLIB		, 0		, 0	, __a( NULL		) }

} ;

/*----------------------------------------------------------------------------*/
int SYSargcheck( f, call )

syscheck	*f	;
PCIlist		*call	;

/* -- Checks the types of the actual arguments of the system library functions
      against those of the formal arguments.
   -- */

{ int			i, j, rc, RC	;
  emsg			tmp		;
  PCItype		formal, *actual ;
  register short 	*argv		;

/* -- Parameter count.
   -- */
  if( f->nargs == VARGS ) rc = f->args.typefun( call ) ;
  else if( f->nargs != call->num - 1 )
  	rc = ERRsyn( "bad number of arguments in function",
              	       PCIvar( call->elt.Auto[0] ) ) ;
  else 
/* -- Parameter types.
   -- */
      for( i = j = 0, rc = TRUE, argv = call->elt.Auto ; i < f->nargs ; i++ ) {
	RC = FALSE ;
	do {
#if DEBUG
  printf( "SYSargcheck: <%s> actual %d <%s>\n", PCIvar( *call->elt.Auto ),
  	  i+1, PCIvar( argv[i+1] ) ) ; fflush( stdout ) ;
#endif
		formal	   =  f->args.typearray[j]	;
		formal.Num &= ~VTYPE			;
		actual	   =  isnull( argv[i+1] ) ? &formal
		                                  : pPCIdef( argv[i+1] ) ;
   	        RC = RC || TYPfuncall( &formal, actual, SYSFUN ) ;
	} while( f->args.typearray[j++].Num & VTYPE ) ;
	if( !RC ) {
	  sprintf( tmp, "%.*s(%d)", MAXEMSG - 6, PCIvar( *call->elt.Auto ), i + 1 ) ;
	  rc = ERRsyn( "argument type mismatch for function", tmp ) ;
   		
   	}
      }

  return rc ;

} /* SYSargcheck */
/*----------------------------------------------------------------------------*/
int cisymb( func )

PCIlist *func ;

{ int rc ; emsg err ;

  if( STBfind( "cnst_list", SYM_GVAR_NAM ) == EMPTY ) {
    sprintf( err, "`cnst_list' does not exist for `%.*s', include \"cisymb.h\"",
  	     MAXEMSG - 55, PCIvar( func->elt.Auto[0] ) ) ;
    rc = ERRsyn( err, NULL ) ;
  }

  return rc ;

} /* cisymb */
/*----------------------------------------------------------------------------*/
static int SYSdump( dp )

PCIlist *dp ;

{ int i, rc = TRUE ; emsg e ;

  for( i = 1 ; i < dp->num ; i++ ) {
  	if( !isvar( dp->elt.Auto[i] ) ) {
  		sprintf( e, "%.*s(%d)", MAXEMSG - 6, PCIval( dp->elt.Auto[0] ), i ) ;
  		rc = ERRsyn( "argument is not a variable", e ) ;
  	}
  }

  return rc ;

} /* SYSdump */
/*----------------------------------------------------------------------------*/
/* ARGSUSED */ static int SYSnocheck( ig ) PCIlist *ig ; { return TRUE ; }
/*----------------------------------------------------------------------------*/
static int SYSio( io )

PCIlist *io ;

/* -- Handles the argument checking of awrite, fwrite, pwrite, write, aread,
      fread, pread, read.
      a..., p... and w... want a file name ( string ) as 1st argument.
      Structure/union  arguments are not accepted.
   -- */

{ int rc = TRUE, i, iarg ; emsg err ;

  switch( PCIvar( io->elt.Auto[0] )[0] ) {
  	case 'a' :
	case 'p' :
	case 'f' : if( io->num <= 2 )
		       rc = ERRsyn( "I/O function must have at least 2 args",
				      PCIvar( io->elt.Auto[0] ) ) ;
		   else if( !isstring( io->elt.Auto[1] ) )
	               rc = ERRsyn( "first arg must be a string for function",
	                              PCIvar( io->elt.Auto[0] ) ) ;
	           break ;
	default  : if( io->num <= 1 )
			rc = ERRsyn( "I/O function must have at least 1 args",
				       PCIvar( io->elt.Auto[0] ) ) ;
  }
  for( i = 1 ; i < io->num ; i++ ) {
        iarg = io->elt.Auto[i] ;
        if( isstruct( iarg ) || ispointer( iarg ) && !isstring( iarg ) ) {
        	sprintf( err, "argument #%d has bad type for", i ) ;
                rc = ERRsyn( err, PCIvar( io->elt.Auto[0] ) ) ;
        }
  }
  return rc ;

} /* SYSio */
/*----------------------------------------------------------------------------*/
void SYSinit()

/* -- Includes the library functions in the hash table, the `data' pointer will
      contain the address of the function record in the structure array Library.
   -- */

{ register syscheck	*lib	;
  register int		i	;

/* -- Insert function names into table.
   -- */
  for( lib = sys__lib, i = 0 ; lib->name[0] != '.' ; lib++, i++ ) {
	STBenter( lib->name, i, SYM_SYST_FCN )	;
  }
                              
} /* SYSinit */
/*----------------------------------------------------------------------------*/
syscheck *SYSfind( fn )

PCIident fn ;

{ int i ;
  
  return (syscheck *) ( ( i = STBfind( fn, SYM_SYST_FCN ) ) == EMPTY ?
                                   NULL : &sys__lib[i] ) ;
}
/*----------------------------------------------------------------------------*/
int mkSYS( funcname )

char *funcname ;

/*  -- Creates a variable bearing the same name as the library function.
       INPUT  : funcname, function's name.
       RETURNS: index of constructed variable if function is in library else
                EMPTY.
    -- */

{ syscheck	*found			;
  int		rc    	, type		;
  PCIcontext	funinfo			;
  PCItype	TYPbasic()		;

  if( ( found = SYSfind( funcname ) ) != NULL ) {
	type = found->type ;
	
	funinfo.typ	= TYPbasic( type & ~PTR )	;
	funinfo.typ.Ptr	= ( type & PTR ) != 0		;
	funinfo.loc	= cxGLOBL			;
	funinfo.sto	= cxSTATC			;
	funinfo.use	= cxFUNCT			;
	funinfo.ref	= FALSE				;
	rc = MKdcl( &funinfo, funcname )		;
  }
  else rc = EMPTY ; /* Non-library function */

  return rc ;

} /* mkSYS */
/*----------------------------------------------------------------------------*/
int SYScall( call )

PCIlist *call ;

{ int		rc	;
  syscheck	*found	;
  emsg		tmp	;

  if( ( found = SYSfind( PCIvar( call->elt.Auto[0] ) ) ) != NULL )
	rc = SYSargcheck( found, call ) ;
  else {
	sprintf( tmp, "unknown function `%s'", PCIvar( call->elt.Auto[0] ) ) ;
	rc = cibugchk( "SYScall", tmp ) ;
  }
#if DEBUG
  printf( "SYScall : EXIT( %d )\n", rc ) ;
#endif
  return rc ;

} /* SYScall */
/*----------------------------------------------------------------------------*/
