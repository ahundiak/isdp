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

/*
**  DEFINES
*/

#if defined(unix)
# define RISCONFIG_FILE     "/etc/risconfig"
# define INGRCONFIG_FILE    "/usr/ip32/ingrconfig"
#elif defined(WIN32) || defined(DOS) || defined(vms)
# define RISCONFIG_FILE     0
# define INGRCONFIG_FILE    0
#endif

#define RIS_CLIENT_ALL_PLATFORMS 	"RISCLI:RISCCU:RISCSU"

#if defined(__clipper__)

/*
** RIS Client and Utility products
*/
# define RIS_UTILITIES_PRODUCT     	"RISUTL:RISUCU"
# define RIS_DEVELOPMENT_PRODUCT    "RISDP:RISPCUC"
# define RIS_CLIENT_RUNTIME_PRODUCT	"RISCLI:RISCCU"
# define RIS_CLIENT_PROGRAM			"riscli"

/*
** RIS Server products
*/
# define RISX_PRODUCT       "RISINFDS:RISXC"
# define RISX_PROGRAM       "risinfds:risxc"
# define RISXNET_PRODUCT    "RISINFNS:RISXCNET"
# define RISXNET_PROGRAM    "risinfns:risxcnet"
# define RISO_PRODUCT       "RISORADS:RISOC"
# define RISO_PROGRAM       "risorads:risoc"
# define RISONET_PRODUCT    "RISORANS:RISOCNET"
# define RISONET_PROGRAM    "risorans:risocnet"
# define RISI_PRODUCT       "RISINGDS:RISIC"
# define RISI_PROGRAM       "risingds:risic"
# define RISINET_PRODUCT    "RISINGNS:RISICNET"
# define RISINET_PROGRAM    "risingns:risicnet"
# define RISD_PRODUCT       "RISDB2DS:RISDC"
# define RISD_PROGRAM       "risdb2ds:risdc"
# define RISY_PRODUCT       "RISSYBDS:RISYC"
# define RISY_PROGRAM       "rissybds:risyc"
# define RISMSSQL_PRODUCT   "RISMSFDS"
# define RISMSSQL_PROGRAM   "rismsfds"
# define RISOS4DS_PRODUCT   "RISOS4DS:RISOS4DS"
# define RISOS4DS_PROGRAM   "risos4ds:risos4ds"

#elif defined(sun)

/*
** RIS Client and Utility products
*/
# define RIS_UTILITIES_PRODUCT     	"RISUTL:RISUSU"
# define RIS_DEVELOPMENT_PRODUCT    "RISDP:RISPSUC"
# define RIS_CLIENT_RUNTIME_PRODUCT	"RISCLI:RISCSU"
# define RIS_CLIENT_PROGRAM      	"riscli"

/*
** RIS Server products
*/
# define RISX_PRODUCT       "RISINFDS:RISXS"
# define RISX_PROGRAM       "risinfds:risxs"
# define RISXNET_PRODUCT    "RISINFNS:RISXSNET"
# define RISXNET_PROGRAM    "risinfns:risxsnet"
# define RISO_PRODUCT       "RISORADS:RISOS"
# define RISO_PROGRAM       "risorads:risos"
# define RISONET_PRODUCT    "RISORANS:RISOSNET"
# define RISONET_PROGRAM    "risorans:risosnet"
# define RISI_PRODUCT       "RISINGDS:RISIS"
# define RISI_PROGRAM       "risingds:risis"
# define RISINET_PRODUCT    "RISINGNS:RISISNET"
# define RISINET_PROGRAM    "risingns:risisnet"
# define RISD_PRODUCT       "RISDB2DS:RISDS"
# define RISD_PROGRAM       "risdb2ds:risds"
# define RISY_PRODUCT       "RISSYBDS:RISYS"
# define RISY_PROGRAM       "rissybds:risys"
# define RISMSSQL_PRODUCT   "RISMSFDS"
# define RISMSSQL_PROGRAM   "rismsfds"
# define RISOS4DS_PRODUCT   "RISOS4DS:RISOS4DS"
# define RISOS4DS_PROGRAM   "risos4ds:risos4ds"

#elif defined(unix)

/*
** RIS Client and Utility products
*/

# define RIS_UTILITIES_PRODUCT     	"RISUTL"
# define RIS_DEVELOPMENT_PRODUCT    "RISDP"
# define RIS_CLIENT_RUNTIME_PRODUCT "RISCLI"
# define RIS_CLIENT_PROGRAM      	"riscli"

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

#elif defined(WIN32)

/*
** RIS Client and Utility products
*/
# define RIS_DEVELOPMENT_PRODUCT    "RISDP"
# define RIS_CLIENT_RUNTIME_PRODUCT "RIS"
# define RIS_UTILITIES_PRODUCT     	"RIS"
# define RIS_CLIENT_PROGRAM      	"riscli.exe"

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

#elif defined(DOS)

/*
** RIS Application and Utility products
*/
# define RIS_UTILITIES_PRODUCT     	"RISUTL"
# define RIS_DEVELOPMENT_PRODUCT    "RISDP"
# define RIS_CLIENT_RUNTIME_PRODUCT "RISRT"

#endif
