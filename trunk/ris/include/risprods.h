/* Do not alter this SPC information: $Revision: 1.5.21.1 $ */
/*
**  NAME:                           risprods.h
**  AUTHORS:                        Sunil Murthy
**  CREATION DATE:                  11/92
**  ABSTRACT:
**			A set of macros that define RIS product names and program names
** 			on the Clipper and Sun platforms.
**
**  REVISION HISTORY:
**	06/30/93	GEO	
**			Rename products and server programs for RIS versions > 4.3.1;
**			NOTE: A server program name definition for a platform
**				  does not mean the program is supported on that platform
**			NOTE: RISCLI and RISRT products are mutually exclusive
*/

# define RISCONFIG_FILE  "/opt/ingr/ingrconfig"
# define INGRCONFIG_FILE "/opt/ingr/ingrconfig"

#define RIS_CLIENT_ALL_PLATFORMS  "RISCLI:RISCCU:RISCSU"

/*
** RIS Client and Utility products
*/
# define RIS_UTILITIES_PRODUCT      "RISUTL"
# define RIS_DEVELOPMENT_PRODUCT    "RISDP"
# define RIS_CLIENT_RUNTIME_PRODUCT "RISCLI"
# define RIS_CLIENT_PROGRAM         "riscli"

/*
** RIS Server products
*/
# define RISX_PRODUCT       "RISINFDS"
# define RISX_PROGRAM       "risinfds"
# define RISXNET_PRODUCT    "RISINFNS"
# define RISXNET_PROGRAM    "risinfns"
# define RISO_PRODUCT       "RISORADS"
# define RISO_PROGRAM       "risorads"
# define RISONET_PRODUCT    "RISORANS"
# define RISONET_PROGRAM    "risorans"
# define RISI_PRODUCT       "RISINGDS"
# define RISI_PROGRAM       "risingds"
# define RISINET_PRODUCT    "RISINGNS"
# define RISINET_PROGRAM    "risingns"
# define RISD_PRODUCT       "RISDB2DS"
# define RISD_PROGRAM       "risdb2ds"
# define RISY_PRODUCT       "RISSYBDS"
# define RISY_PROGRAM       "rissybds"
# define RISMSSQL_PRODUCT   "RISMSFDS"
# define RISMSSQL_PROGRAM   "rismsfds"
# define RISOS4DS_PRODUCT   "RISOS4DS"
# define RISOS4DS_PROGRAM   "risos4ds"
