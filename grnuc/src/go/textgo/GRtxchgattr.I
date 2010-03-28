/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

    CLASS  NAME:  GRtext
    METHOD NAME:  GRchgtextattr

    Abstract:
             This method changes one or more of the text object's attributes
          (font, justification, line spacing, character spacing, height, width)
          and posts the abstract geometry of the object.  This will update the
          range in the R-tree (unless tne module environments object id is
          equal to NULL_OBJID).
-----
%SC%    
        GRchgtextattr(msg,module_env,attr,text_symb)

-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   ------------------------------------
     *module_env  struct GRmd_env module environment information
     attr         IGRuint        bitmask indicating attribute(s) to
                                 change; #defines for this bitmask
                                 are defined in gotextdef.h
    *text_symb    struct GRdpb_text_symb text symbology structure
                                         containing attributes to
                                         change
-----
%EX%
     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg           IGRlong         completion code
                                     MSSUCC - successful completion
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:

     Methods:  GRpostabsg
               GRfm_retdata
               GRgetgeom
-----
%RL%

     RELATIONS REFERENCED:
        none.
-----
%NB%

     NOTES:
        none.
-----
%CH%

     CHANGE HISTORY:
        
        WBC     06/26/86 : Design date.
        WBC     06/26/86 : Creation date.
        WBC     10/09/87 : Changed arguments - replace type and
                           matrix with module environment and
                           added new_objid.
        WBC     07/19/88 : Modified to change one or more attributes
                           specified by a bitmask.  Also removed
                           argument new_objid since class won't change.
        SCW     07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This method changes one or more attributes of a text object
(specified by a bitmask) and posts its abstract geometry.  This will
update the object's range in the R-tree (unless the module
environment's objid is equal to NULL_OBJID).
----*/
/*EH*/

class implementation GRtext;

#include   "grimport.h"
#include   "msdef.h"
#include   "fontdef.h"
#include   "font.h"
#include   "gotext.h"
#include   "grdpbdef.h"
#include   "grdpb.h"
#include   "exmacros.h"
#include   "grdpbmacros.h"
#include   "codef.h"

from GRfm import GRfm_retdata;

#define CHG_FONT      0
#define CHG_JUST      1
#define CHG_LN_SP     2
#define CHG_CHR_SP    3
#define CHG_HT        4
#define CHG_WID       5

method GRchgtextattr(IGRlong *msg; struct GRmd_env *module_env;
                     IGRuint attr; struct GRdpb_text_symb *text_symb)
{
    extern IGRboolean  GRabsg_del_by_objid();
                                    /* deletes abstract geometry from the    */
                                    /* cache                                 */
    struct vfont_entry font_info;   /* contains font information             */
    struct extents   new_extents;   /* extents reflecting origin point       */
    struct GRdpb_text_symb text_symb2; /* updated text symbology to be used  */
                                    /* by GRchgtxstring                      */
    struct IGRlbsys  lbs;           /* structure to contain a local boun. sys*/
    struct GRpost_info info;        /* processing info. for post abstr. geom.*/
    struct GRid      fontmgr_obj;   /* font manager object                   */
    OM_S_OBJID       cur_mod_id;    /* current module's objid                */
    GRobjid          new_objid;
    IGRlong          OMmsg;         /* return code                           */
    IGRlong          temp_msg;      /* temporary message                     */
    IGRint           attr_type;     /* type of attribute to change           */

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;
    attr_type = 0;

    /*
     *  clear the unused bits in the bitmask (only the six low order bits
     *  are being used)
     */

    attr &= 0x3f;

    while (attr)
    {
        for (; !(attr & 1); ++attr_type, attr >>= 1);

        /*
         *  change the appropriate text attribute
         */

        switch (attr_type)
        {
            case CHG_FONT:      /* change font */

                ME.GRtext->attr.font = text_symb->Active_font;
                break;

            case CHG_JUST:      /* change justification */

                ME.GRtext->attr.just = text_symb->Active_just;
                break;

            case CHG_LN_SP:     /* change line spacing */

                ME.GRtext->attr.line_spac = text_symb->Active_linespac;
                break;

            case CHG_CHR_SP:    /* change character spacing */

                ME.GRtext->attr.char_spac = text_symb->Active_charspac;
                break;

            case CHG_HT:        /* change height */

                ME.GRtext->attr.height = text_symb->Active_height;
                break;

            case CHG_WID:       /* change width */

                ME.GRtext->attr.width = text_symb->Active_width;
                break;

            default:

                *msg = MSINARG;
                break;

        }   /* end switch */
        ++attr_type;
        attr >>= 1;
    }   /* end "while (attr)" */

    /*
     *  initializing values to be used in GRchgtxstring
     */

    text_symb2.Active_font = ME.GRtext->attr.font;
    text_symb2.Active_just = ME.GRtext->attr.just;
    text_symb2.Active_linespac = ME.GRtext->attr.line_spac;
    text_symb2.Active_charspac = ME.GRtext->attr.char_spac;
    text_symb2.Active_height = ME.GRtext->attr.height;
    text_symb2.Active_width = ME.GRtext->attr.width;

    ex$get_modid(mod_osnum = OM_Gw_current_OS,
                 mod_id = &cur_mod_id);

    /*
     *  get the objid of the font manager using its named object
     */

    ex$get_super(mod_id = cur_mod_id,
                 mod_osnum = OM_Gw_current_OS,
                 super_name = FONTMGR_NO_NAME,
                 create = TRUE,
                 super_class = "GRfm",
                 super_id = &fontmgr_obj.objid,
                 super_osnum = &fontmgr_obj.osnum);

    /*
     * get font information from the specified font
     */

    OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRfm.GRfm_retdata
                               (&temp_msg,&(ME.GRtext->attr.font),&font_info),
                    senderid = my_id,
                    targetid = fontmgr_obj.objid,
                    targetos = OM_Gw_current_OS);

    if (!COERROR(OMmsg) && !COERROR(temp_msg))
    {
        OMmsg = om$send(mode = OM_e_wrt_object,
                        msg = message GRtext.GRchgtxstring
                               (&temp_msg,&text_symb2,
                                &font_info,0,NULL,&new_extents),
                        senderid = my_id,
                        targetid = my_id);

        if (!COERROR(OMmsg) && !COERROR(temp_msg))
        {
            /*
             *  Initialize arguments in order to post the abstract data.
             *  This will update the text object's range in the R-tree
             *  (unless the module environment's objid equals NULL_OBJID).
             */

            info.construct_flag = FALSE;

            /* get geometry of the local bounded system   */

            OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRvg.GRgetgeom
                                   (&temp_msg,
                                    &module_env->md_env.matrix_type,
                                    module_env->md_env.matrix,
                                    (IGRchar *)&lbs),
                            senderid = my_id,
                            targetid = my_id);

            if (!COERROR(temp_msg) && !COERROR(1 & OMmsg))
            {
                /*
                 *  update the local bounded system's diagonal points
                 *  to reflect the new extents of the text string
                 */

                lbs.diag_pt1[0] = new_extents.left;
                lbs.diag_pt1[1] = new_extents.bottom;
                lbs.diag_pt1[2] = 0;
                lbs.diag_pt2[0] = new_extents.right;
                lbs.diag_pt2[1] = new_extents.top;
                lbs.diag_pt2[2] = 0;

                OMmsg = om$send(mode = OM_e_wrt_object,
                                msg = message GRvg.GRpostabsg
                                      (&temp_msg,module_env,&info,
                                      (IGRchar *)&lbs,&new_objid),
                                senderid = my_id,
                                targetid = my_id);

                if (!COERROR(temp_msg) && !COERROR(OMmsg))
                {
                    GRabsg_del_by_objid(&my_id,&OM_Gw_current_OS);
                }
                else
                {
                    *msg = MSFAIL;
                }
            }
            else
            {
                *msg = MSFAIL;
            }           /* end GRvg.GRgetgeom */
        }
        else
        {
            *msg = MSFAIL;
        }           /* end GRtext.GRchgtxstring */
    }
    else
    {
        if (COERROR(OMmsg))
        {
            OMmsg = OM_E_ABORT;
        }
        *msg = MSFAIL;
    }                  /* end GRfm.GRfm_retdata */
    return(OMmsg);
}

end implementation GRtext;
