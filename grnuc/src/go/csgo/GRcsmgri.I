/*
Name
        GRcsmgr.super_construct

Description
        This method constructs the base coordinate system at (0,0,0).

History
        Kumar Talluri   11/08/86    design and implementation
        mrm             09/30/87    modifications
                        03/04/88    use new construct method for base
                        12/09/91    removed bad call to om$dealloc
        dhm             07/15/92    ansi conversion.
*/

class implementation GRcsmgr;

#include "grimport.h"
#include "csdef.h"
#include "grcoordsys.h"
#include "igr.h"
#include "igrdp.h"
#include "ex.h"
#include "exmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "godef.h"
#include "go.h"
#include "madef.h"
#include "OMerrordef.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIprims.h"
#include "dpgraphics.h"

from GRgraphics import GRconstruct;
from GRconnector import GRflexconn;

extern char *strrchr ();

extern IGRchar DIR_G_car_dir;

method super_construct ()
{
    IGRchar                 name[DI_PATH_MAX]; /* base name (full pathname) */
    IGRint                  size;           /* for dpb call */
    IGRlong                 sts, msg;       /* return codes */
    IGRlong                 flex_flag;      /* index */
    IGRlong                 owners_index;   /* index to at which to connect */
    IGRlong                 graphics_index; /* index to at which to connect */
    GRobjid                 cs_objid;       /* base coordinate system id */
    struct GRid             mygrid;         /* manager id & space number */
    struct GRmd_env         module_info;    /* current module information */
    struct IGRlbsys         lbs_geom;       /* for base coordinate system */
    struct IGRdisplay       active_display; /* for base coordinate system */
    struct GRvg_construct   cnst_lis;       /* for base coordinate system */
    struct GRcs_construct   cs_args;        /* for base coordinate system */
IGRchar			ref_path[1024];
    /*
     *  construct the directory pathname for the base coordinate system
     */

/* use dir path to create the full pass name */

	di$give_pathname(	osnum	= OM_Gw_current_OS,
				pathname = ref_path );
/*
    ex$filename (len = OM_K_MAXOSNAME_LEN, name = file);
    c = (c = strrchr (file, '/')) ? c + 1 : file;
    sprintf (name, "%c%s%cusr%cBASEcoordsys",
             DIR_G_car_dir, c, DIR_G_car_dir, DIR_G_car_dir);
*/
	sprintf( name, "%s:usr:BASEcoordsys", ref_path );

#ifdef DEBUG
    printf ("GRgencs.super_contruct: base cs name is %s\n", name);
#endif

    /*
     *  set up construction parameters for the base coordinate system
     */

    sts = gr$get_active_display (msg = &msg,
                                 sizbuf = &size,
                                 buffer = &active_display,
                                 nret = &size);

    active_display.weight = ACTIVE_CS_WEIGHT;
    active_display.style = 0;

    module_info.md_id.osnum = OM_Gw_current_OS;
    sts = ex$get_modid (mod_osnum = module_info.md_id.osnum,
                        mod_id = &module_info.md_id.objid);
    module_info.md_env.matrix_type = MAIDMX;
    MAidmx (&msg, module_info.md_env.matrix);

    lbs_geom.diag_pt1[0] = 0;
    lbs_geom.diag_pt1[1] = 0;
    lbs_geom.diag_pt1[2] = 0;
    lbs_geom.diag_pt2[0] = 0;
    lbs_geom.diag_pt2[1] = 0;
    lbs_geom.diag_pt2[2] = 0;
    MAidmx (&msg, lbs_geom.matrix);

    cs_args.desc = "base coordinate system is undeletable";
    cs_args.flag = CS_NO_CONNECT_TO_MGR | CS_NO_MAKE_ACTIVE;
    cs_args.type = RECTANGULAR;

    cnst_lis.newflag = 0;
    cnst_lis.msg = &msg;
    cnst_lis.name = name;
    cnst_lis.class_attr = (IGRchar *)&cs_args;
    cnst_lis.level = 0;
    cnst_lis.properties = GRIS_READ_ONLY;
    cnst_lis.display = &active_display;
    cnst_lis.env_info = &module_info;
    cnst_lis.geometry = (IGRchar *) &lbs_geom;

    /*
     *  construct the base coordinate system
     */

    sts = om$construct (classname = "GRcsbase",
                        msg = message GRgraphics.GRconstruct (&cnst_lis),
                        p_objid = &cs_objid);

    if (sts & msg & 1)
    {
        /*
         * connect to the base
         */

        flex_flag = 1;          /* connect with override */
        mygrid.objid = my_id;
        mygrid.osnum = OM_Gw_current_OS;
        owners_index = graphics_index = OM_K_MAXINT;

        sts = om$send (msg = message GRconnector.GRflexconn
                            (&msg, &flex_flag, &mygrid,
                             &owners_index, &graphics_index),
                       targetid = cs_objid);

        if (sts & msg & 1)
        {
            /*
             *  make the base active
             */

            sts = om$send (msg = message GRcsmgr.GRset_active_cs
                                (&msg, &module_info, cs_objid),
                           targetid = my_id);
        }
    }

#ifdef DEBUG
    if (!(sts & msg & 1)) printf ("GRcsmgr.super_construct failed\n");
    if (!(msg & 1)) printf ("msg = 0x%x\n", msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}

end implementation GRcsmgr;
