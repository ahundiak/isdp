/* $Id: COtoolsi.I,v 1.1 2001/03/12 15:10:48 ramarao Exp $  */
/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/grnuc/COtoolsi.I
 *
 * Description: Modify this methis to warn the user about delay mode.
 *		Dirty trick. Isn't it? But there is no other way.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: COtoolsi.I,v $
 *      Revision 1.1  2001/03/12 15:10:48  ramarao
 *      Fix for TR# 4846.
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      03/12/01        Rama Rao        File Creation in VDS. TR# 4846
 * -------------------------------------------------------------------*/

class implementation COtools;

#include <FI.h>
#include <coimport.h>
#include <exmacros.h>
#include <dpdef.h>
#include <dp.h>
#include <dperr.h>
#include <dpmacros.h>
#include <grgsdef.h>
#include <grgs.h>
#include <grgsmacros.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DImacros.h>
#include <DIprims.h>
#include "comisc.h"
#include "nddef.h"
#include "ndmacros.h"
#include "msmacros.h"
#include "ASmsg.h"

#ifdef X11
#include <stdio.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#endif

method color_menu_button(char *cmdkey; int color)
{
    if( !strcmp( cmdkey+2, "DlE" ) && color == FI_RED )
    {
	IGRint		mode;
	IGRchar		warning_msg[150];

	nd$mod_batch( request = ND_INQ, p_ret_mode = &mode );
	if( mode == ND_DEFER )
	{
	     strcpy( warning_msg, "Update Mode is DELAYED.\nDo you want to set it to IMMEDIATE?\n" );
	     if( GRconfirm_box( warning_msg ) )
	     {
                nd$mod_batch( request   = ND_SET,
                              req_mode   = ND_IMMEDIATE);
                ex$message( msgnumb = AS_S_UpdImmD);
		GRdelay_button(GR_DELAY_OFF);
	     }
	}
    }
    GRcolor_menu_button(cmdkey, color);
    return(OM_S_SUCCESS);
}

end implementation COtools;
