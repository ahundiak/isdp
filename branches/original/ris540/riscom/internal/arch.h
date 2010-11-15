/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							arch.h
**	AUTHORS:						John Gwyer
**	CREATION DATE:					5/91
**	ABSTRACT:
**		
**	
**	REVISION HISTORY:
*/

#ifndef ARCH_H
# define ARCH_H

#include <stdio.h>
#include <stdlib.h>

#ifdef ARC_DEFINE
# define ARC_EXTERN
# define ARC_INIT(x)	= x
#else
# define ARC_EXTERN		extern
# define ARC_INIT(x)
#endif

#define ARC_MAX_PRECISION 15

#ifdef NO_ARC_DBG
#define ARC_DBG(s)
#else
#define ARC_DBG(s)	if (ARC_debug && ARC_debug_handler) {ARC_debug_handler s;}
#endif

#define ARC_CLEAR_ERROR(arc) \
arc->error_code = 0;\
arc->error_string[0] = '\0';\
arc->arc_error_code = 0;\
arc->arc_error_string[0] = '\0';

typedef struct arc_s
{
    void            (*error_handler)();     /* user-defined error handler */
    short 			remote_arch;            /* remote architecture */
    short 			conversion_flags;       /* flags used for data conversion */
    unsigned int    error_code;             /* generic error code */
    char            error_string[160];      /* generic error string */
    unsigned int    arc_error_code;         /* arch-specific error code */
    char            arc_error_string[160];  /* arch-specific error string */
    short 			second_byte;
} arc_s;

#define TO_BACKEND		1
#define TO_FRONTEND		2
#define FROM_BACKEND	3
#define FROM_FRONTEND	4

/* posible architectures */

#define IBM_370         1
#define IBM_PC          2
#define IBM_PS_2        3
#define IBM_AS_400      4
#define IBM_S_38        5
#define CLIPPER         6
#define VAX             7
#define SUN             8
#define PC              9		/* Intel x86 processor; DOS or NT */
#define HYDRA          10
#define SGI            11
#define HPUX	       12
/* NOTE !!!! This should match the highest arch. in the list above */
#define HIGHEST_KNOWN_ARCH 12
#define V4_FRONTEND		98
#define UNKNOWN_ARCH	99

/* 
** posible operating systems
**
** NOTE: These defines are not being used.
*/

#define IBM_MVS         1
#define IBM_VM          2
#define IBM_VSE         3
#define IBM_DOS         4
#define IBM_PC_DOS      5
#define IBM_OS_2        6
#define UNIX            7
#define VMS             8
#define MSDOS			9

/* posible mvs environements */

#define IBM_MVS_TSO     1
#define IBM_MVS_CICS    2
#define IBM_MVS_BATCH   3

/* Identify which architecture we are running on. */

#if defined(__clipper__)
#define LOCAL_ARCH		CLIPPER
#endif

#if defined(sun) || defined(__Sol2__)
#define LOCAL_ARCH		SUN
#endif

#if defined(vms)
# define LOCAL_ARCH		VAX
#endif

#if defined(WIN32) || defined(Soli)
# define LOCAL_ARCH		PC
#endif

#if defined(DOS)
# define LOCAL_ARCH		PC
#endif

#if defined(sco)
# define LOCAL_ARCH     HYDRA
#endif

#ifdef __ibm_pc__
# define LOCAL_ARCH     IBM_PC
#endif

#ifdef __IBM_370__
# define LOCAL_ARCH     IBM_370
#endif

#if defined(__hpux__)
# define LOCAL_ARCH		HPUX
#endif

typedef struct
{
	unsigned frac : 23;
	unsigned exp : 8;
	unsigned sign : 1;
} clip_float;

typedef struct
{
	unsigned low_frac : 32;
	unsigned high_frac : 20;
	unsigned exp : 11;
	unsigned sign : 1;
} clip_double;

typedef struct
{
	unsigned frac : 24;
	unsigned exp  :  7;
	unsigned sign :  1;
} ibm370_float;
typedef struct
{
	unsigned low_frac 	: 32;
	unsigned high_frac	: 24;
	unsigned exp 		:  7;
	unsigned sign		:  1;
} ibm370_double;

typedef struct
{
	unsigned high_frac : 7;
	unsigned exp : 8;
	unsigned sign : 1;
	unsigned low_frac : 16;
} vax_ffloat;

typedef struct
{
	unsigned high_frac : 7;
	unsigned exp : 8;
	unsigned sign : 1;
	unsigned med_frac : 16;
	unsigned low_frac : 32;
} vax_dfloat;

typedef struct
{
	unsigned high_frac : 4;
	unsigned exp : 11;
	unsigned sign : 1;
	unsigned med_frac : 16;
	unsigned low_frac : 32;
} vax_gfloat;

/*
**	Let's define some macros to help us determine whether or not
**	we need to do data type conversions
*/

#define ARC_SHORT		0x01
#define ARC_INTEGER	    0x02
#define ARC_FLOAT	    0x04
#define ARC_DOUBLE	    0x08
#define ARC_CHAR	    0x10

#define CONVERT_CHARACTER		1
#define CONVERT_DATA			2
#define CONVERT_STRING			3
#define CONVERT_INTEGER			4
#define CONVERT_SHORT			5
#define CONVERT_FLOAT			6
#define CONVERT_DOUBLE			7
#define MAX_CONVERSION_TYPES	8

#define ARC_SHORT_IS_DIFFERENT(x)    ( x & ARC_SHORT	)
#define ARC_INTEGER_IS_DIFFERENT(x)  ( x & ARC_INTEGER  )
#define ARC_FLOAT_IS_DIFFERENT(x)    ( x & ARC_FLOAT    )
#define ARC_DOUBLE_IS_DIFFERENT(x)   ( x & ARC_DOUBLE   )
#define ARC_CHAR_IS_DIFFERENT(x)     ( x & ARC_CHAR     )

/*
**	We are assuming that we will always transform data to or from
**	a Clipper architecture format.
*/

			/*
			**	In the dbms directory we have 2 files (cnvrt_in.c and 
			**	cnvrt_out.c). They temporarily need to transform data
			**	until we put the server code and transforming code on
			**	the IBM. Remember, we plan to always put 'clipper' datatypes
			**	on the network at all times, but right now (june 1990)
			**	we still do not do convertions on the IBM.
			**
			**	To make things look easy, we will use a macro there
			**	instead of the preceding function arrays. (this way
			**	we do not need to make the function arrays a global)
			*/

    /*
    **		-- DATABASE SPECIFIC CONVERSION MACROS --
	*/


	/*  -- DATABASE ARCHITECTURE TO SERVER ARCHITECTURE --
    **  Database to server conversion for db2 is a conversion
	**	from IBM to the architecture on which the server is running.
    */
#ifdef DB2
# if defined(__clipper__)
#   define DB_TO_SRV_CHAR(x)		ARC_ch_ebc_to_asc((arc_s *)0,x)
#   define DB_TO_SRV_DATA(x,len)	ARC_data_ebc_to_asc((arc_s *)0,x,len)
#   define DB_TO_SRV_STR(x)			ARC_str_ebc_to_asc(x)
#   define DB_TO_SRV_SHORT(x)		ARC_short_swap_bytes(x)
#   define DB_TO_SRV_LONG(x)		ARC_int_swap_bytes(x)
#   define DB_TO_SRV_INT(x)			ARC_int_swap_bytes(x)
#   define DB_TO_SRV_REAL(x)		ARC_370_to_clip_float((arc_s *)0,x)
#   define DB_TO_SRV_FLOAT(x)		ARC_370_to_clip_float((arc_s *)0,x)
#   define DB_TO_SRV_DOUBLE(x)		ARC_370_to_clip_double((arc_s *)0,x)
#   define DB_TO_SRV_DEC(x,y,z)		ARC_370_to_asc_decimal((arc_s *)0,x,y,z)
# endif /* __clipper__ */
# if defined(sco)
#   define DB_TO_SRV_STR(x)			ARC_str_ebc_to_asc(x)
# endif /* sco */
#endif /* db2 */



	/*  -- SERVER ARCHITECTURE TO DATABASE ARCHITECTURE --
    **  Server to database conversion for db2 is a conversion
	**	from IBM to the architecture on which the server is running.
    */
#ifdef DB2
# if defined(__clipper__)
#   define SRV_TO_DB_CHAR(x)		ARC_ch_asc_to_ebc(x)
#   define SRV_TO_DB_DATA(x,len)	ARC_data_asc_to_ebc(x,len)
#   define SRV_TO_DB_STR(x)			ARC_str_asc_to_ebc(x)
#   define SRV_TO_DB_SHORT(x)		ARC_short_swap_bytes(x)
#   define SRV_TO_DB_LONG(x)		ARC_int_swap_bytes(x)
#   define SRV_TO_DB_INT(x)			ARC_int_swap_bytes(x)
#   define SRV_TO_DB_REAL(x)		ARC_clip_to_370_float((arc_s *)0,x)
#   define SRV_TO_DB_FLOAT(x)		ARC_clip_to_370_float((arc_s *)0,x)
#   define SRV_TO_DB_DOUBLE(x)		ARC_clip_to_370_double((arc_s *)0,x)
#   define SRV_TO_DB_DEC(x,y,z)     ARC_asc_to_370_decimal((arc_s *)0,x,y,z)
# endif /* __clipper__ */
#endif /* db2 */

/*
** Include all the functions that are in the architecture prototype dir files.
*/

/* error codes */

#define ARC_SUCCESS					0
#define ARC_INTERNAL_ERROR			1
#define ARC_OVERFLOW				2
#define ARC_UNDERFLOW				3
#define ARC_NOT_A_NUMBER			4
#define ARC_NO_CONVERSION			5
#define ARC_IBM_UNDERFLOW_ERROR 	6
#define ARC_IBM_OVERFLOW_ERROR  	7
#define ARC_IBM_INFINITY_ERROR  	8
#define ARC_IBM_NOT_NUMBER_ERROR 	9
#define ARC_IBM_UNDETERMINED_ERROR 	10
#define ARC_LAST_ERROR_CODE			11

#define FROM_NET	0
#define TO_NET		1

#define ARC_CONVERT_CHARACTER(arc, mode, c) \
if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) \
	ARC_convert(arc, mode, CONVERT_CHARACTER, (c), 0);

#define ARC_CONVERT_DATA(arc, mode, d, len) \
if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) \
	ARC_convert(arc, mode, CONVERT_DATA, (d), len);

#define ARC_CONVERT_STRING(arc, mode, s) \
if (ARC_CHAR_IS_DIFFERENT(arc->conversion_flags)) \
	ARC_convert(arc, mode, CONVERT_STRING, (s), 0);

#define ARC_CONVERT_INTEGER(arc, mode, i) \
if (ARC_INTEGER_IS_DIFFERENT(arc->conversion_flags)) \
	ARC_convert(arc, mode, CONVERT_INTEGER, (i), 0);

#define ARC_CONVERT_SHORT(arc, mode, s) \
if (ARC_SHORT_IS_DIFFERENT(arc->conversion_flags)) \
	ARC_convert(arc, mode, CONVERT_SHORT, (s), 0);

#define ARC_CONVERT_FLOAT(arc, mode, f) \
if (ARC_FLOAT_IS_DIFFERENT(arc->conversion_flags)) \
	ARC_convert(arc, mode, CONVERT_FLOAT, (f), 0);

#define ARC_CONVERT_DOUBLE(arc, mode, d) \
if (ARC_DOUBLE_IS_DIFFERENT(arc->conversion_flags)) \
	ARC_convert(arc, mode, CONVERT_DOUBLE, (d), 0);


#define ARC_CHARACTER_TO_NET(arc, c) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_CHARACTER(arc, TO_NET, c);
#define ARC_DATA_TO_NET(arc, d, len) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_DATA(arc, TO_NET, d, len);
#define ARC_STRING_TO_NET(arc, s) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_STRING(arc, TO_NET, s);
#define ARC_INTEGER_TO_NET(arc, i) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_INTEGER(arc, TO_NET, i);
#define ARC_SHORT_TO_NET(arc, s) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_SHORT(arc, TO_NET, s);
#define ARC_FLOAT_TO_NET(arc, f) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_FLOAT(arc, TO_NET, f);
#define ARC_DOUBLE_TO_NET(arc, d) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_DOUBLE(arc, TO_NET, d);

#define ARC_NET_TO_CHARACTER(arc, c) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_CHARACTER(arc, FROM_NET, c);
#define ARC_NET_TO_DATA(arc, d, len) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_DATA(arc, FROM_NET, d, len);
#define ARC_NET_TO_STRING(arc, s) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_STRING(arc, FROM_NET, s);
#define ARC_NET_TO_INTEGER(arc, i) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_INTEGER(arc, FROM_NET, i);
#define ARC_NET_TO_SHORT(arc, s) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_SHORT(arc, FROM_NET, s);
#define ARC_NET_TO_FLOAT(arc, f) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_FLOAT(arc, FROM_NET, f);
#define ARC_NET_TO_DOUBLE(arc, d) \
if (arc->remote_arch != LOCAL_ARCH) ARC_CONVERT_DOUBLE(arc, FROM_NET, d);

ARC_EXTERN  int	ARC_debug								ARC_INIT(0);
ARC_EXTERN  int	(*ARC_debug_handler)(const char *, ...)	ARC_INIT(0);

#endif /* ARCH_H */
