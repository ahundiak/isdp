class implementation Root;

#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "OMindex.h"
#include "OMlimits.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "igr.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "dp.h"
#include "ex.h"
#include "griodef.h"
#include "grio.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igrdef.h"
#include "exmacros.h"
#include "madef.h"
#include "msdef.h"
#include "griomacros.h"
#include "refdef.h"
#include "ref.h"
#include "refmacros.h"
#include "referr.h"
#include "grerr.h"
#include "OMmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "nddef.h"
#include "ndmacros.h"

/** Helper Functions **/
extern int GRformlbsys();
extern int DEref_view_recalled();


/** Helper Classes **/
from GRgraphics import GRconstruct,GRdisplay,GRdelete;
from GRreffile import GRgetenvironment,GRgetosnum,GRchgcolor;
from IGEgragad  import  DPinrot;



IGRint rfAttachRefFile(msg,
                        filename,
                        ref_grid,
                        ref_osnum)
IGRlong *msg;
IGRchar *filename;
struct GRid *ref_grid;
GRspacenum *ref_osnum;
{
    int		            sts,status;
    long                    msg1;
    OMuword                 classid;
    struct GRvg_construct   const_list;
    struct IGRlbsys         lbsys;
    struct GRmd_env         cur_mod;
    struct IGRdisplay       display;
    IGRshort                level;
    IGRlong                 nbytes_in_buff,nbytes_trans;
    struct GRrf_info        rf_info;
    struct GRid             ref_id;
    IGRint                  i;
    unsigned int            properties;
    IGRchar                 ref_scale[DI_PATH_MAX];
    IGRchar                 ref_filename[DI_PATH_MAX];
    enum GRdpmode           DisplayMode;
    IGRchar                 mode[2];
    IGRchar                 saved_view[2048];

    sts = OM_S_SUCCESS;
    *msg = MSSUCC;
    ref_filename[0]=NULL;

    /*  
     * Set up the construct arguments.
     */

    strcpy(saved_view, "front");

    GRfindrefpath(filename,ref_filename);
    if(access(ref_filename,0) == -1)
     {
         *msg = MSFAIL;
          sts = OM_E_ABORT;
          goto quit;
     }
 
     /* get the current module environment */

     nbytes_in_buff = sizeof(struct GRmd_env);
     sts = gr$get_module_env(msg = msg,
                             sizbuf = &nbytes_in_buff,
                             buffer = &cur_mod,
                             nret = &nbytes_trans);
     if(!(*msg & sts & 1))
     {
        goto quit;
     }

    /* Get active display */

    nbytes_in_buff = sizeof(struct IGRdisplay);
    sts = gr$get_active_display (msg = msg,
                                 sizbuf = &nbytes_in_buff,
                                 buffer = &display,
                                 nret = &nbytes_trans);
    if(!(sts & *msg & 1))
     {
       goto quit;
     }
 
    /* Get active level */ 

    nbytes_in_buff = sizeof(IGRshort);
    sts = gr$get_active_level(msg = msg,
                              sizbuf = &nbytes_in_buff,
                              buffer = &level,
                              nret = &nbytes_trans);
    if(!(sts & *msg & 1))
     {
       goto quit;
     }

    properties = 0;
    om$get_classid ( classname = "GRreffile", p_classid = &classid );

    const_list.msg = &msg1;
    const_list.env_info = &cur_mod;
    const_list.properties = GRIS_NEW | GRIS_LOCATABLE | GRIS_DISPLAYABLE;
    const_list.geometry = (IGRchar *) &lbsys;
    const_list.display = &display;
    const_list.level = level;
    const_list.newflag = FALSE;

    const_list.name = NULL;
    const_list.class_attr = (char *)&rf_info;

    rf_info.filename = ref_filename;
    rf_info.named_view = NULL;
    rf_info.clip_poly = NULL;
    rf_info.prism_classname = NULL;
    rf_info.description = NULL;
    properties = GRRF_IS_READ_ONLY | GRRF_BACKGROUND;

    rf_info.ref_properties = &properties;

    strcpy(ref_scale,"1");
    rf_info.scale = ref_scale;


    {
        /* 
         * Load identity matrix.
         */
        MAidmx(msg,lbsys.matrix);

        /*
         * Design file limits.
         */
        lbsys.diag_pt1[0]  = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt1[1]  = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt1[2]  = (double)(GRDGNLIMITS_MIN_D + 1.0);
        lbsys.diag_pt2[0]  = (double)(GRDGNLIMITS_MAX_D - 1.0);
        lbsys.diag_pt2[1]  = (double)(GRDGNLIMITS_MAX_D - 1.0);
        lbsys.diag_pt2[2]  = (double)(GRDGNLIMITS_MAX_D - 1.0);
    }

    if ( 1 & sts & *msg)
    {
      /** Make the reference file Upadateble **/
      mode[0] = 'W';

      /* if the mode is writable, add that file to the list */
      if (mode[0] == 'W') GRmake_writable ( msg, ref_filename,NULL );

      status = om$construct(osnum = cur_mod.md_id.osnum,
                            obj_osnum = cur_mod.md_id.osnum,
                            classid = classid,
                            p_objid = &ref_id.objid );
      ref_id.osnum = cur_mod.md_id.osnum;
 
      status = om$send(msg = message GRgraphics.GRconstruct(&const_list),
                       senderid = NULL_OBJID,
                       targetid = ref_id.objid,
                       targetos = ref_id.osnum);

        if (status)
        {
            /*
             * Activate any symbology overrides.
             */

            /*
             * Display the constructed object.
             */

            DisplayMode = GRbd;
            
            sts = om$send (mode = OM_e_wrt_message,
                           msg = message GRgraphics.GRdisplay
                                        ( msg,
	                                  &cur_mod.md_env.matrix_type,
                                          cur_mod.md_env.matrix,
                                          &DisplayMode, 
                                          &cur_mod.md_id ),
                      senderid = NULL_OBJID,
                      targetid = ref_id.objid,
                      targetos = ref_id.osnum );

        }
    }

   if ( !(sts & *msg & 1) )
    {
        om$send ( msg = message GRgraphics.GRdelete ( msg, &cur_mod ),
                  senderid =  NULL_OBJID,
                  targetid = ref_id.objid, 
                  targetos = ref_id.osnum);

           *msg = MSFAIL;
    }
   else
    {
       if(ref_grid)
        {
           ref_grid->objid = ref_id.objid;
           ref_grid->osnum = ref_id.osnum;
        }

       if(ref_osnum)
        {
          sts = om$send(msg = message GRreffile.GRgetosnum(msg,ref_osnum),
                        senderid = NULL_OBJID,
                        targetid = ref_id.objid,
                        targetos = ref_id.osnum);
        }
    }
quit:
  return sts;
}


end implementation Root;

