/* $Id: GRconstrcs.I,v 1.1 2001/02/15 20:45:50 build Exp $ */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:        vds/vddetail/cmd/GRconstrcs.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: GRconstrcs.I,v $
 *      Revision 1.1  2001/02/15 20:45:50  build
 *      *** empty log message ***
 *
 *
 * History
 * 	02/15/01	adz	MP 3951
 */

/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRconstruct_cs

Description
   This function is used to construct a coordinate system.

Arguments
   *msg           IGRlong              completion code
   *mod_env       struct GRmd_env      module environment
   level          IGRshort             level
   *display       struct IGRdisplay    display info
   properties     IGRushort            properties of the coordinate system
   name[]         IGRchar              name of the coordinate system
   classname      IGRchar              name of class to construct
   *lb            struct IGRlbsys      The geometry of the coordinate sys
   *cs_id         struct GRid          the cordinate system object id

Return Values
   MSSUCC   -  if successful
   MSFAIL   -  if failure

History
   Gray Winn   06/10/88    Creation Date
   SCW         07/08/92    ANSI conversion
\*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "dp.h"
#include "godef.h"
#include "go.h"
#include "lcdef.h"
#include "griodef.h"
#include "ex.h"
#include "grio.h"
#include "lc.h"
#include "msdef.h"
#include "grcoordsys.h"
#include "csdef.h"
#include "exmacros.h"

#include "vddlodef.h"
#include "vddlomacros.h"
#include "v_dbgmacros.h"


from GRgraphics   import GRconstruct;

IGRint GRconstruct_cs (msg, mod_env, level, display, properties, name,
                       classname, lb, cs_id)
IGRlong           *msg;
struct GRmd_env   *mod_env;
IGRshort          level;
struct IGRdisplay *display;   
IGRushort         properties;
IGRchar           name[];
IGRchar           classname[];
struct IGRlbsys   *lb;
struct GRid       *cs_id;
{
IGRlong                 om_msg;
struct GRvg_construct   const_list;
struct GRcs_construct   class_attr;

   SetProc( GRconstruct_cs ); Begin

   *msg = MSSUCC;

   /*
    *  Construct the coordinate system.
    */

   class_attr.desc = NULL;
   class_attr.flag = CS_CONNECT_TO_MGR;
   class_attr.type = RECTANGULAR;

   const_list.msg = msg;
   const_list.newflag = FALSE;
   const_list.name = name;
   const_list.class_attr = (IGRchar *)&class_attr;
   const_list.env_info = mod_env;
   const_list.properties = properties;
   const_list.level = level;
   const_list.display = display;
   const_list.geometry = (IGRchar *)lb;

   /*
    * Within ISDP the drawings are redirected to the drwaing layout level.
    * We need to optain this information and set it into active value.
    */

   {
        long            sts1, msg1;
        VD_drwLoInfo    drwLoInfo;

        sts1 = vd$drw_layout_info ( msg  = &msg1,
                                    type = VD_K_drwLO_drvLevel,
                                    info = &drwLoInfo  );
        if ( sts1 == VD_UNDEFINED )  {	/* Do nothing */ }
	else if ( !(sts1&msg1&1) )   {  /* Do nothing */ }
	else{
   		const_list.level = drwLoInfo.val.sValue;
		__DBGpr_int(" New Level ", const_list.level );
	}
   }
   
   cs_id->osnum = mod_env->md_id.osnum;
   om_msg = om$construct(osnum = mod_env->md_id.osnum,
            classname = classname,
            msg = message GRgraphics.GRconstruct(&const_list),
            p_objid = &cs_id->objid);

   End
   return(om_msg);
}
end implementation Root;
