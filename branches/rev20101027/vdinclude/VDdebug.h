/*
 * VDdebug.h
 *
 *	defines debugging variables specific to VDS
 *	also, for the moment, modified debugging macros from COBmacros.h
 *
 * depends on stdio.h
 */


#ifndef VDdebug_include
#define VDdebug_include


/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/*				Start of #ifdef VD_DEBUG			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#ifdef VD_DEBUG

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				Global Variables				*/
/*										*/
/*	Defined		in : VDdbg_glob.c					*/
/*	Toggled / Reset in : ci=toggle [[m] / [f] / [c]] [<any>]		*/
/*										*/
/*	Set ENV variable  : `export MKDOPT=$MKDOPT" -DVD_DEBUG"` to enable or	*/
/*	reset MKDOPT to original value to disable macros.			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

extern	int	VDmethod;
extern	int	VDfunct;
extern	int	VDcomment;

extern	int	__lvl__ ;		/* indentation level */
extern	int	__prev__;		/* previous indentation level */

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				Variables/Local					*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#ifdef	COMMENT 
#	define VDCOMMENT	( VDcomment | COMMENT )
#else 
#	define VDCOMMENT	( VDcomment )
#endif

#ifdef	FUNCT 
#	define VDFUNCT		( VDfunct | FUNCT | VDCOMMENT )
#else
#	define VDFUNCT		( VDfunct | VDCOMMENT )
#endif

#ifdef	METHOD 
#	define VDMETHOD		( VDmethod | METHOD | VDFUNCT )
#else
#	define VDMETHOD		( VDmethod | VDFUNCT )
#endif

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*			Print nesting level indicators				*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * Print one "| " string for each level
 */

#define __indent			\
{   int ii;				\
    for(ii=0; ii++ < __lvl__; )		\
	fputs("|", stdout);		\
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				General Purpose					*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * Compatible with $EXNUC/include/COBmacros.h
 */

#define __debug(x) x

#omdef  __bugprint (bflag=VDMETHOD, str, var =  NULL )
{
if (bflag) {
    if ( *(str) == '-') __lvl__ = __lvl__>0 ? __lvl__-- : 0;
     __indent;
    if ( *(str) == '+') __lvl__++;
    printf (str , var );
    };
};
#endomdef

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	VDS Debugging Macros : Similar to $STRUCT/include/vsdbgmacros.h		*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/* ------------------------------------------------------------------
 * print my_id
 */

#define __myid  printf("  =>> my_id: [%d,%d]\n", OM_Gw_current_OS, my_id )

/* ------------------------------------------------------------------
 * enter method
 *	multiple args must be enclosed within back quote:  '`'
 */

#omdef  __enterMethod (name, argfmt = NULL, args = NULL )
{
if ( VDMETHOD) {
    if (__prev__ == __lvl__) putchar ('\n'); 
     __indent; __lvl__++;
    printf ("+m{ %s.%s [%d,%d] (", p_ACLD->s_name, name, OM_Gw_current_OS,my_id);
#   if om$specified (argfmt)
	printf (argfmt , args);
#   endif
    puts (")");		/* includes newline */
    };
/*if ( status == OM_E_ABORT ) goto quit;	// Does not really make sense	*/
};
#endomdef

/* ------------------------------------------------------------------
 * exit method
 *	multiple args must be enclosed within back quote:  '`'
 */

#omdef  __exitMethod (name, argfmt = NULL, args = NULL )
{
if ( VDMETHOD) {
     __lvl__-- ; __indent; __prev__ = __lvl__;
    printf ("-m} %s.%s [%d,%d] (", p_ACLD->s_name, name, OM_Gw_current_OS,my_id);
#   if om$specified (argfmt)
	printf (argfmt , args);
#   endif
    puts (")");		/* includes newline */
    };
};
#endomdef

/* ------------------------------------------------------------------
 * exit method when error occurred OR extra information (__LINE__,__FILE__) required
 *	multiple args must be enclosed within back quote:  '`'
 */

#omdef  __exit_error_Method (name, argfmt = NULL, args = NULL )
{
if ( VDMETHOD) {
     __lvl__-- ; __indent; __prev__ = __lvl__;
    printf ("-m} %s.%s [%d,%d] (At line %d of the file %s", p_ACLD->s_name, name, OM_Gw_current_OS,my_id,__LINE__,__FILE__);
#   if om$specified (argfmt)
	printf (argfmt , args);
#   endif
    puts (")");		/* includes newline */
    };
};
#endomdef

/* ------------------------------------------------------------------
 * enter function
 *	multiple args must be enclosed within back quote:  '`'
 */

#omdef  __enterFunction (name, argfmt = NULL, args =  NULL )
{
if ( VDFUNCT) {
    if (__prev__ == __lvl__) putchar ('\n'); 
     __indent; __lvl__++;
    printf ("+f{ %s (", name );
#   if om$specified (argfmt)
	printf (argfmt , args);
#   endif
    puts (")");		/* includes newline */
    };
};
#endomdef

/* ------------------------------------------------------------------
 * exit function
 *	multiple args must be enclosed within back quote:  '`'
 */

#omdef  __exitFunction (name, argfmt = NULL,  args =  NULL )
{
if ( VDFUNCT) {
     __lvl__-- ; __indent; __prev__ = __lvl__;
    printf ("-f} %s (", name );
#   if om$specified (argfmt)
	printf ( argfmt, args);
#   endif
    puts (")");		/* includes newline */
    };
};
#endomdef

/* ------------------------------------------------------------------
 * exit function when error occurred OR extra information (__LINE__,__FILE__) required
 *	multiple args must be enclosed within back quote:  '`'
 */

#omdef  __exit_error_Function (name, argfmt = NULL,  args =  NULL )
{
if ( VDFUNCT) {
     __lvl__-- ; __indent; __prev__ = __lvl__;
    printf ("-f} %s (At line %d of the file %s", name,__LINE__,__FILE__ );
#   if om$specified (argfmt)
	printf ( argfmt, args);
#   endif
    puts (")");		/* includes newline */
    };
};
#endomdef

/* ------------------------------------------------------------------
 * debugging prints
 *	prefix with  "  =>> "
 */

#define __print_goto(label)						\
	{ if ( VDCOMMENT )						\
		{ __indent ; fputs ("  =>> goto ",stdout);		\
		printf ( label ); 					\
		printf (" At line %d of the file %s",__LINE__,__FILE__ );\
		putchar ('\n'); }					\
	}
#define __prints(s)					\
	{ if ( VDCOMMENT )				\
		{ __indent ; fputs ("  =>> ",stdout);	\
		printf ( s ); putchar ('\n'); }		\
	}

#define  __printf(s,v)					\
	{ if ( VDCOMMENT )				\
		{ __indent ; fputs (" =>> ",stdout);	\
		printf ( s , v ) ; putchar ('\n'); }	\
	}

# print an element of a list
#	must follow a __prints or __printf without a newline
#define __print_list(s)					\
	{ if ( VDCOMMENT )				\
		{ printf ( s ); fputs ("  ",stdout); }	\
	}

#define __print_eol()					\
	{ if ( VDCOMMENT ) { putchar ('\n'); } }

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*		VD_DEBUG not defined : generates empty strings (DELIVERY)	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
#else

#define __debug(x)

#omdef  __bugprint(bflag=VDMETHOD,str,args =  NULL)
#endomdef

#define __myid

#omdef  __enterMethod(name, argfmt = NULL, args = NULL )
/*  if ( status == OM_E_ABORT ) goto quit;	// Does not really make sense	*/
#endomdef

#omdef  __exitMethod(name, argfmt = NULL, args = NULL )
#endomdef

#omdef  __exit_error_Method(name, argfmt = NULL, args = NULL )
#endomdef

#omdef  __enterFunction(name , argfmt = NULL, args = NULL)
#endomdef

#omdef  __exitFunction(name , argfmt = NULL, args = NULL)
#endomdef

#omdef  __exit_error_Function(name , argfmt = NULL, args = NULL)
#endomdef

#define	 __print_goto(label)
#define  __prints(s)
#define  __printf(s,v)
#define  __print_list(s)
#define  __print_eol

#endif

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				End of #ifdef VD_DEBUG				*/
/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */


/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				VDS Print Utilities				*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

/*
 * general Purpose utilities for printing return values
 */

#define __BoolStr(s)		(s == FALSE) ? "FALSE" : "TRUE"

#define __MSretCodeStr(s)	(s == MSSUCC) ? "MSSUCC" :	\
				(s == MSFAIL) ? "MSFAIL" :	\
				(s == MSINARG) ? "MSINARG" : "INVALID MS ERROR"
	
#define __FIretCodeStr(s)	(s == FI_SUCCESS) ? "FI_SUCCESS" : "FI_FAIL"

#endif VDdebug_include
