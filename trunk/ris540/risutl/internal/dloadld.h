/* Do not alter this SPC information: $Revision: 1.2.27.1 $ */

/*
**	NAME:							dloadfrm.h
**	AUTHORS:						Hitesh R. Patel
**	CREATION DATE:					8/93
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 

#ifndef RIS_DLOAD_H
#define RIS_DLOAD_H

#ifdef DLD_GLOBAL_DEFINE
# define DLD_EXTERN
# define DLD_INIT(value) = value
#else
# define DLD_EXTERN extern
# define DLD_INIT(value)
#endif

/*
**	INCLUDES
*/
#include "ris.h"
#include "rislimit.h"
#include "ris_err.h"

/*
**	DEFINES
*/

/*
** The following defines corresponds to each RIS interface call.
*/
/*EXPORTS MACRO BEGIN*/
#define DLD_loader						1
#define DLD_unloader					2
#define DLDlod_batch_load				3
#define DLDlod_interactive_load			4
#define DLDlod_get_RISlod_debug_addr	5
#define DLDuld_heart_of_unload			6
#define DLDuld_get_RISuld_debug_addr	7
#define DLDlod_fprint_risloddes			8
#define DLDuld_fprint_risulddes			9
/*EXPORTS MACRO END*/

/* DLOAD errors */
#define	RIS_COULD_NOT_GET_REGISTRY	1
#define	RIS_COULD_NOT_LOAD_RIS_DLL	2
#define	RIS_COULD_NOT_FIND_RIS_FUNC 3

#define DLOADCODE RISdldLDULD_errcode	// Error Code if Dynamic Loading Fails

#define DLD_DBG(s) if(RISdldLDULD_debug) {RISdldLDULD_output_debug s;}

#define SET_RISCA(status) { DLOADCODE = status; }
#define RIS_RETURN() { return; }

#if defined(unix)
#define RIS_OBJECT_NAME "risforms.o" 
#endif
#if defined(WIN32)
#define RIS_OBJECT_NAME "i9rislu6.dll"
#define RIS_OBJECT_NAME_32S "i9risls6.dll"
#endif

#if defined(unix)
#define DYNAMIC_LOAD_FUNCION(objects)	dload(objects, TEXTREDEF) 
#endif
#if defined(WIN32)
#define	DYNAMIC_LOAD_FUNCTION(objects)	LoadLibrary(objects)
#endif

#if defined(unix)
#define	GET_FUNCTION_ADDRESS(name) \
	(int (*)() )dload_address_lookup(name) 
#endif
#if defined(WIN32)
#define	GET_FUNCTION_ADDRESS(name) \
	GetProcAddress(handle, name)
#endif

#if defined(unix)
#define FUNCTION_ADDRESS(func) (*func_info[func].address)
#endif
#if defined(WIN32)
#define FUNCTION_ADDRESS(func) (func_info[func].address)
#endif

#ifndef STRING
#define STRING(s) ((s)?(s):"NULL")
#endif

/* Modes for RISdldLDULD_get_risdir() */
#define MATCH_MAJOR					1
#define MATCH_MAJOR_MINOR			2
#define MATCH_MAJOR_MINOR_RELEASE	3
#define MATCH_HIGHEST				4
#define MATCH_COMPATIBLE			5

#if defined(__clipper__)
# define PLATFORM "c100"
#elif  defined(__hpux__)
# define PLATFORM "hpux"
#elif defined(Soli)
# define PLATFORM "Soli"
#elif defined(__Sol2__)
# define PLATFORM "Sol2"
#elif defined(sun)
# define PLATFORM "sun"
#elif defined(sco)
# define PLATFORM "sco"
#elif defined(WIN32)
# define PLATFORM "nt"
#elif defined(DOS)
# define PLATFORM "dos"
#endif

/*
**	TYPES
*/
typedef struct func_info_s
{
	char	*name;
#if defined(unix)
	int		(*address)();
#endif
#if defined(WIN32)
	FARPROC	address;
#endif
} func_info_s;


/*
**	VARIABLES
*/

/* Variables available to applications */
DLD_EXTERN	int	RISdldLDULD_errcode	DLD_INIT(RIS_SUCCESS);
DLD_EXTERN	int	RISdldLDULD_debug 	DLD_INIT(0);

#endif /* RIS_DLOAD_H */
