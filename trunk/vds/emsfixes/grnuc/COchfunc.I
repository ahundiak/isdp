/* $Id: COchfunc.I,v 1.1.2.1 2003/08/26 13:25:25 ylong Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/emsfixes/COchfunc.I
 *
 * Description:
 *	Override the function COch_name for TR7926.
 *
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: COchfunc.I,v $
 *      Revision 1.1.2.1  2003/08/26 13:25:25  ylong
 *      Override function COch_name for TR7926
 *
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      08/25/03        ylong           File Creation in VDS.
 * -------------------------------------------------------------------*/
/*
Name
  COchfunc.I

Description
  These functions perform the actions used by the COchange commands.

History
        mrm     08/16/88    created by extracting code from existing commands
        jhw     01/23/89    added gr$gsdisplay in COch_dis_on (TR#89N0291)
        mrm     02/24/89    I/DRAW changes
                05/04/89    added COch_cp_layer
                09/25/89    removed COch_symbology, COch_color, COch_layer,
                            COch_style, COch_weight, COch_cp_layer
        jsd     01/21/92    prefix names with ".deleted_"
                            for COch_delete, COch_undelete
        jsd     01/23/92    added support for graphic group/set
                            for COch_delete, COch_undelete
        jsd     03/24/92    removed incorrect I/DRAW defs and fixed removal
                            of ".deleted_" from objects
        jsd     09/08/92    1. changed di$rename to GRvg.GRchgname (TR 92N5839)
                               This added objid and osnum to COpre_* functions.
                            2. removed multiple calls to make_chanselect.
                            3. replaced strcmp with om$is_ancestry_valid.
        jsd     05/10/93    COpre_undelete_name now removes all ".deleted_"
                            that have been added to a name.
 
        abhijit  01/16/98   Avoided attaching '.deleted' prefix for Base
                            Coordinate System object  
*/

class implementation CEO_GSLOCATE;

#include "coimport.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "dpmacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DImacros.h"
#include "DIprims.h"
#include "lcmacros.h"
#include <alloca.h>
#include "grmsg.h"

from GRgraphics import GRdisplay;
from GRvg import GRchgdp, GRchgcolor, GRchglevel, GRchgstyle,
                 GRchgweight, GRchgname, GRchgprops;
from GRundo import GRudsave, GRudundo, GRudonoff;

/*
Name 
  COch_name

Abstract
  This object passes the GRvg.GRchgname message to the object on the
  graphic set channel.

Synopsis
  IGRint COch_name (msg, caller_id, caller_os, mod, events, gschan, userdata)

  *msg       IGRlong          return code
                                MSSUCC - success
                                MSFAIL - failure
                                GR_E_INV_REQUEST - duplicate name
                                GRw_no_value - null name was passed in events[1]
  caller_id  OM_S_OBJID       calling object's id 
  caller_os  OMuword          calling object's osnum 
  *mod       struct GRmd_env  current module information 
  *events    struct GRevent   events[1] - keyin field used as new name
  *gschan    OM_S_CHANSELECT  containing object(s) to work with
  *userdata  char             unused

Return Values
  TRUE  - successful
  FALSE - unsuccessful

Keywords
  modify name 

*/

#argused
IGRint COch_name (msg, caller_id, caller_os, mod, events, gschan, userdata)

IGRlong         *msg;           /* return code */
OM_S_OBJID       caller_id;     /* calling object's id */
OMuword          caller_os;     /* calling object's osnum */
struct GRmd_env *mod;           /* current module information */
struct GRevent  *events[];      /* event pointer array */
OM_S_CHANSELECT *gschan;        /* containing object(s) to work with */
char            *userdata;      /* unused */

{
    IGRint              sts, ret;       /* return code */
    struct GRmd_env     dummy_mod;      /* filled in by gr$gspass */
    char obj_name[DI_PATH_MAX];
    char obj_dir[DI_PATH_MAX];
    char cur_dir[DI_PATH_MAX];
    char *p = NULL;


    if (strlen (events[1]->event.keyin))
    {
	/*
	 * first, split the name and dir fot TR7926
	 */
	di$pwd(dirname = cur_dir);
	strcpy( obj_dir, events[1]->event.keyin );
	if( obj_dir[0] == ':' )
	{
	   p = strrchr( obj_dir, ':' );
	   if( p )
	   {
	      *p = '\0';
	      strcpy( obj_name, ++p );
	   }
	   sts = di$cd ( dirname = obj_dir );
	   if( !(sts&1) )
	   {
	      UI_status("Directory doe not exist");
	      goto wrapup;
	   }
	}
	else
	{
	   strcpy( obj_name, events[1]->event.keyin );
	}

        /* send the change name message */

        sts = gr$gspass (msg = &ret,
                         pass_msg = message GRvg.GRchgname
                                   (msg, &dummy_mod, obj_name),
                                   /*(msg, &dummy_mod, events[1]->event.keyin),*/
                         path = &dummy_mod,
                         senderid = caller_id,
                         senderos = caller_os,
                         p_chanselect = gschan);

	di$cd ( dirname = cur_dir );

        /* update the directory form */
        di$update_dir_form();
    }
    else
    {
        /* don't give objects NULL names */

        *msg = GRw_no_value;
        ret = MSSUCC;
        sts = OM_S_SUCCESS;
    }

#ifdef DEBUG
    if (!(*msg & 1)) printf ("COch_name: *msg = %#x\n", *msg);
    if (!(ret & 1)) printf ("COch_name: ret = %#x\n", ret); 
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

wrapup:
    return (sts & ret & *msg & 1);
}


end implementation CEO_GSLOCATE;
