#include "UNIX_or_VMS.h"

#if UNIX
#	include "/usr/ip32/inc/inc.h"
#	define PDM_OWNED_FILE		"/usr/lib/nodes/owned/pdm_server"
#	define PDM_SERVER		"/usr/ip32/pdm/PDMserver.exe"
#	define PDM_DIR			"/usr/ip32/pdm/"
#	define SERVER_DAT		"/usr/ip32/inc/server.dat"
#	define SITE_ERROR		1
#endif

#if VMS
#	include "PRO_DD_INC:inc.h"
#	define PDM_OWNED_FILE		"INC_NODES:[OWNED]PDM_SERVER"
#	define PDM_SERVER		"PRO_DD_PDM:PDMserver.exe"
#	define PDM_DIR			"PRO_DD_PDM:"
#	define SERVER_DAT		"PRO_DD_INC:SERVER.DAT"
#	define SITE_ERROR		0
#endif
