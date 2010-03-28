class implementation COcptxfljf;



#include "coimport.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "grmessage.h"
#include "exmacros.h"
#include "godef.h"
#include "go.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "exdef.h"
#include "execmsg.h"
#include "dp.h"
#include "cotxmacros.h"
#include "gotextdef.h"
#include "dpmacros.h"

#define WORD_SPACE_FACTOR 0.9

from GRtext     import GRgettxattr, GRchgtextattr, GRreplace_text;
from GRvg       import GRgetgeom;
from GRgraphics import GRcptform;


#define _start 0
#define _locate_text 1
#define _get_left_margin 2
#define _get_right_margin 3
#define _get_placement_point 4

method set_autowrap (int autowrap)
{
  int		  status = OM_S_SUCCESS;

    if (autowrap)
    {
        me^^COcptxfljf.autowrap = TRUE;
    }
    else
    {
        me^^COcptxfljf.autowrap = FALSE;
    }
quit:
  return OM_S_SUCCESS;
}

method erase_highlight ()
{
  int		  status = OM_S_SUCCESS;

    IGRlong  msg;

    dp$erase_hilite(msg = &msg);
quit:
  return OM_S_SUCCESS;
}

method get_text ()
{
  int		  status = OM_S_SUCCESS;

    me^^COcptxfljf.text_grid.objid = me->event1.located_object[0].located_obj.objid;
    me^^COcptxfljf.text_grid.osnum = me->event1.located_object[0].located_obj.osnum;
    me^^COcptxfljf.module_info = me->event1.located_object[0].module_info;
quit:
  return OM_S_SUCCESS;
}

method save_left_margin ()
{
  int		  status = OM_S_SUCCESS;

    me^^COcptxfljf.first_point[0] = me->event1.event.button.x;
    me^^COcptxfljf.first_point[1] = me->event1.event.button.y;
    me^^COcptxfljf.first_point[2] = me->event1.event.button.z;
quit:
  return OM_S_SUCCESS;
}

method find_distance ()
{
  int		  status = OM_S_SUCCESS;

    extern IGRboolean MA2ptdis();

    IGRlong           temp_msg;
    IGRpoint          point2;

    /*
     *  find the distance between the two input points
     */

    point2[0] = me->event1.event.button.x;
    point2[1] = me->event1.event.button.y;
    point2[2] = me->event1.event.button.z;

    if (! MA2ptdis(&temp_msg,me^^COcptxfljf.first_point,
                   point2,&me^^COcptxfljf.distance))
    {
        me->ret = MSFAIL;
    }
quit:
  return OM_S_SUCCESS;
}

method place_text ()
{
  int		  status = OM_S_SUCCESS;

    extern IGRint            GRblock_text();
    extern IGRboolean        MAtrlmx();

    struct IGRestx           text_attr;
    struct GRdpb_text_symb   text_symb;
    struct GRmd_env          cur_module_info;
    struct IGRlbsys          lbsys;
    IGRuchar                 *text_string;
    IGRlong                  om_msg, temp_msg;
    IGRlong                  nbytes_in_buffer;
    IGRlong                  nbytes_transferred;
    GRobjid                  newtext_objid, temp_objid;
    IGRmatrix                tform_matrix;
    IGRmatrix                *matr[1];
    IGRvector                delta_vector;

    me->ret = MSSUCC;

    nbytes_in_buffer = sizeof(cur_module_info);

    gr$get_module_env(msg = &temp_msg,
                      sizbuf = &nbytes_in_buffer,
                      buffer = &cur_module_info,
                      nret = &nbytes_transferred);

    /*
     * find the origin of the original text object in order to determine the
     * delta vector used in creating a translation matrix to translate the
     * new text object to the specified position (the new origin)
     */

    om_msg = om$send(msg = message GRvg.GRgetgeom
                              (&temp_msg,
                               &me^^COcptxfljf.module_info.md_env.matrix_type,
                               me^^COcptxfljf.module_info.md_env.matrix,
                               (IGRchar *)&lbsys),
                     targetid = me^^COcptxfljf.text_grid.objid,
                     targetos = me^^COcptxfljf.text_grid.osnum);

    if (om_msg & temp_msg & 1)
    {
        delta_vector[0] = me->event1.event.button.x - lbsys.matrix[3];
        delta_vector[1] = me->event1.event.button.y - lbsys.matrix[7];
        delta_vector[2] = me->event1.event.button.z - lbsys.matrix[11];;

        MAtrlmx(&temp_msg,delta_vector,tform_matrix);

        /*
         * copy and transform (to the new origin) the selected text element
         */

        om_msg = om$send(msg = message GRgraphics.GRcptform
                                                (&temp_msg,
                                                 &me^^COcptxfljf.module_info,
                                                 tform_matrix,&cur_module_info,
                                                 &newtext_objid),
                         targetid = me^^COcptxfljf.text_grid.objid,
                         targetos = me^^COcptxfljf.text_grid.osnum);

        if (om_msg & temp_msg & 1)
        {
            /*
             * get the selected text object's text attributes and text string
             */

            om_msg = om$send(msg = message GRtext.GRgettxattr
                                                     (&temp_msg,
                                                      &text_attr,NULL,
                                                      &text_string),
                             targetid = newtext_objid,
                             targetos = cur_module_info.md_id.osnum);

            if (om_msg & temp_msg & 1)
            {
                /*
                 * change the text object's justification if it is not
                 * equal to the current justification
                 */

                nbytes_in_buffer = sizeof(text_symb);

                gr$get_text_symb(msg = &temp_msg,
                                 sizbuf = &nbytes_in_buffer,
                                 buffer = &text_symb,
                                 nret = &nbytes_transferred);

                if (text_attr.just != text_symb.Active_just)
                {
                    /*
                     * set the module evvironment's objid to NULL_OBJID so
                     * the R-tree won't be updated since it will be updated
                     * when the text object's text string is replaced
                     */

                    temp_objid = cur_module_info.md_id.objid;
                    cur_module_info.md_id.objid = NULL_OBJID;

                    om_msg = om$send(msg = message GRtext.GRchgtextattr
                                                        (&temp_msg,
                                                         &cur_module_info,
                                                         GRTEXT_JUST,
                                                         &text_symb),
                                     targetid = newtext_objid,
                                     targetos = cur_module_info.md_id.osnum);

                    cur_module_info.md_id.objid = temp_objid;
                }

                if (om_msg & temp_msg & 1)
                {
                    /*
                     * "block" the text string
                     */

                    if (GRblock_text(&temp_msg,&text_string,&text_attr,
                                     &lbsys,me^^COcptxfljf.distance,
                                     me^^COcptxfljf.autowrap,
                                     WORD_SPACE_FACTOR))
                    {
                        /*
                         * replace the copied object's text string with the
                         * blocked text string
                         */

                        om_msg = om$send(msg = message GRtext.GRreplace_text
                                                        (&temp_msg,
                                                         &cur_module_info,
                                                         text_attr.text_length,
                                                         text_string),
                                         targetid = newtext_objid,
                                         targetos = cur_module_info.md_id.osnum);

                        if (om_msg & temp_msg & 1)
                        {
                            /*
                             * display the blocked text string
                             */

                            matr[0] = (IGRmatrix *)cur_module_info.md_env.matrix;
                            me^^COcptxfljf.text_grid.objid = newtext_objid;
                            me^^COcptxfljf.text_grid.osnum = cur_module_info.md_id.osnum;

                            dp$display(msg = &temp_msg,
                                       osnum = cur_module_info.md_id.osnum,
                                       mode = GRbd,
                                       oids = &me^^COcptxfljf.text_grid,
                                       num_elem = 1,
                                       mtx_type = &cur_module_info.md_env.matrix_type,
                                       matrix = matr);
                        }
                        else  /* error: GRtext.GRreplace_text */
                        {
                            me->ret = temp_msg;
                        }
                    }
                    else  /* error: GRblock_text */
                    {
                        me->ret = temp_msg;
                    }
                }
                else  /* error: GRtext.GRchgtextattr */
                {
                    me->ret = temp_msg;
                }

                /*
                 * deallocate the memory for the text string
                 */

                if (text_string)
                {
                    om$dealloc(ptr = text_string);
                }
            }
            else  /* error: GRtext.GRgettxattr */
            {
                me->ret = MSFAIL;
            }
        }
        else  /* error: GRgraphics.GRcptform */
        {
            me->ret = MSFAIL;
        }
    }
    else  /* error: GRvg.GRgetgeom */
    {
        me->ret = MSFAIL;
    }
quit:
  return OM_S_SUCCESS;
}

end implementation COcptxfljf;
