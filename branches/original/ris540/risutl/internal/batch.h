/* Do not alter this SPC information: $Revision: 1.1.54.1 $ */
/*
**	NAME:							batch.h
**	AUTHORS:						Dave Buehmann
**	CREATION DATE:					4/88
**	ABSTRACT:
**		
**	REVISION HISTORY:
*/
 
#ifdef BATCH_GLOBAL_DEFINE
# define BATCH_EXTERN
# define BATCH_INIT(value) = value
#else
# define BATCH_EXTERN extern
# define BATCH_INIT(value)
#endif

/*
**	INCLUDES
*/
#include <stdio.h>
#include "utl_err.h"
#include "utl_inf.h"
#include "ris_err.h"
#include "risutl.h"
#include "util.h"

/*
**	DEFINES
*/
#ifdef NO_BTC_DBG
#define BTC_DBG(s)
#else
#define BTC_DBG(s)	if (RISbtc_debug) {RIScom_output_debug s;}
#endif
#define PROMPT1				"ris> "
#define BATCH_MODE 0
#define INTERACTIVE_MODE 1
/*
**	VARIABLES
*/
BATCH_EXTERN int	RISbtc_debug		BATCH_INIT(0);
BATCH_EXTERN debug_info_s RISbtc_debug_info[]
#ifdef BATCH_GLOBAL_DEFINE
=
{
	{	"btc",	3,	&RISbtc_debug	},
	{	"utl",	3,	&RISutl_debug	},
}
#endif
;
BATCH_EXTERN int RISbtc_debug_count	BATCH_INIT((sizeof(RISbtc_debug_info)/sizeof(debug_info_s)));
BATCH_EXTERN int RISbtc_mode;
#if defined(WIN32S)
BATCH_EXTERN int RISbtc_outmode;
#endif
