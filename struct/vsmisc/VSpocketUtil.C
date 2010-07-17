/*
	I/STRUCT

	This functions add or remove Structural Pocket Menu to the
	default Pocket Menu.

	Value returned :
	-----------------

		- MSSUCC		     : Sucessfull operation.
		- VS_K_pk_ST_PK_MN_EXISTS    : Structural pocket menu already
					       exists.
		- VS_K_pk_ST_PK_MN_NOT_HERE  : Structural pocket menu doesn't
					       exist.
		- VS_K_pk_PK_MN_NOT_FOUND    : Default pocket menu not found.
		- VS_K_pk_ERROR 	     : Error encountered.

	How add to a gadget :
	---------------------

		To add a new gadget in the default pocket menu add to the static
		structure 'list' in the function 'VSaddStructuralPocketMenu' a
		structure VSaddGadget defined in 'vspocketmenu.h'. The arguments
		to fill are :
			- long	type_cmd     : type of command FI_CMD_KEY or
					       FI_CMD_STRING.
			- char	*cmd	     : the command string or ASCII key.
			- char	*symbol_file : name of symbol file.
			- char	symbol_index : symbol index in symbol file.

*/
#include <stdio.h>
#include <FI.h>
#include <FIdyn.h>
#include "msdef.h"
#include "vdpktdef.h"
#include "vdpktmacros.h"
#include "vsicondef.h"
#include "vspocketmenu.h"
#include "VDobj.h"
#include "vsdbgmacros.h"

#define testRC( value_to_return ) \
	if( rc != FI_SUCCESS ) { sts = (value_to_return) ; goto wrapup ; }
/*----------------------------------------------------------------------------*/
int VSaddStructuralPocketMenu() {

static struct VDpktGadgets VSlist[] = {

  { FI_CMD_KEY,"VSSlBmOnSr",VS_K_PKT_SYM_FILE,VS_K_PKT_SlBmOnSr },
  { FI_CMD_KEY,"VSSlStOnPl",VS_K_PKT_SYM_FILE,VS_K_PKT_SlStOnPl },
  { FI_CMD_KEY,"VSSlSdPl"  ,VS_K_PKT_SYM_FILE,VS_K_PKT_SlSdPl	},
  { FI_CMD_KEY,"VSSlMcFt"  ,VS_K_PKT_SYM_FILE,VS_K_PKT_SlMcFt	},
  { VDPKT_ENDLIST, 0, 0, 0 }} ;

	int	sts = MSSUCC,
		rc ;

	/*
	 * Add gadgets to default pocket menu.
	 */
	rc = vd$pkt_add_gadgets( gadgets = VSlist ) ;
	testRC( VS_K_pk_ERROR ) ;

	/*
	 * reconstruct pocket mneu with gadgets.
	 */
	rc = vd$pkt_menu() ;
	testRC( VS_K_pk_ERROR ) ;

	wrapup :
		return sts ;

} /* VSaddStructuralPocketMenu */
/*----------------------------------------------------------------------------*/
int VSdelStructuralPocketMenu() {

static struct VDpktGadgets VSlist[] = {

  { FI_CMD_KEY,"VSSlBmOnSr",VS_K_PKT_SYM_FILE,VS_K_PKT_SlBmOnSr },
  { FI_CMD_KEY,"VSSlStOnPl",VS_K_PKT_SYM_FILE,VS_K_PKT_SlStOnPl },
  { FI_CMD_KEY,"VSSlSdPl"  ,VS_K_PKT_SYM_FILE,VS_K_PKT_SlSdPl	},
  { FI_CMD_KEY,"VSSlMcFt"  ,VS_K_PKT_SYM_FILE,VS_K_PKT_SlMcFt	},
  { VDPKT_ENDLIST, 0, 0, 0 }} ;

	int	sts = MSSUCC,
		rc ;

	/*
	 * Delete gadgets to default pocket menu.
	 */
	rc = vd$pkt_del_gadgets( gadgets = VSlist ) ;
	testRC( VS_K_pk_ERROR ) ;

	/*
	 * Reconstruct the pocket menu.
	 */
	rc = vd$pkt_menu( ) ;
	testRC( VS_K_pk_ERROR ) ;

	wrapup :
		return sts ;

} /* VSdelStructuralPocketMenu */
/*----------------------------------------------------------------------------*/
