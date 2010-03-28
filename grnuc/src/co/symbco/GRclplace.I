/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRclplace

Description
   This method is used to place a cell.

   *msg           IGRlong           return code 
   num_origins    IGRint            The number of origins (i.e. cells
                                    to be placed).
   origins[]      IGRpoint          The origins of the cells
   *angle         IGRdouble         The angle (in radians)
   scale[]        IGRdouble         An array of x,y,z scales
   rot_matrix     IGRmatrix         Matrix defining the way the cell
                                    is viewed. (View rotation)
   name[]         IGRchar           The name of the cell
   properties     unsigned short    The properties of the new cell
   *display       struct IGRdisplay ptr to display attributes
   *class_attr    IGRchar           Class specific attributes
   level          IGRshort          The level of the cell
   *symbol_env    struct GRmd_env   Original symbol environment
   *target_env    struct GRmd_env   Environment to construct objects in
   *classname     IGRchar           The class name of the cell
   *sdh_id        struct GRid       The symbol definition header
   cl_id[]        struct GRid       The new cell id's

Return Values
   MSSUCC  -- successful completion
   MSFAIL  -- failure

History
   Gray Winn  02/21/87    Creation date.
   Gray Winn  11/09/87    Changes for version 1.1
   dhm        11/20/91    Get the active level if level is NULL.
   dhm        12/16/91    Fixed memory fault problem and TR 91N4073.
   scw        07/07/92    ANSI conversion
\*/

class implementation Root;

#include "coimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "msdef.h"
#include "grsymdef.h"
#include "grsym.h"
#include "vardef.h"
#include "var.h" 
#include "ex.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

from GRgraphics   import GRconstruct, GRdelete, GRgetrang;
from GRsymbol     import GRset_inq_symbol;
from GRsmdfhdr    import GRcp_sd_to_ams;

IGRint GRclplace (msg, num_origins, origins, angle, scale, rot_matrix,
                   name, properties, display, class_attr, level, 
                   symbol_env, target_env, classname, sdh_id, cl_id)
IGRlong           *msg;
IGRint            num_origins;
IGRpoint          origins[];
IGRdouble         *angle;
IGRdouble         scale[];
IGRdouble         rot_matrix[];
IGRchar           name[];
unsigned short    properties;
struct IGRdisplay *display;
IGRchar           *class_attr;
IGRshort          level;
struct GRmd_env   *symbol_env;
struct GRmd_env   *target_env;
IGRchar           classname[];
struct GRid       *sdh_id;
struct GRid       cl_id[];
{
IGRlong                    om_msg;
IGRlong                    ret_msg;
IGRlong                    temp;
IGRint                     i;
IGRboolean                 world;
IGRint                     constructed;
IGRpoint                   temp_origin;
IGRmatrix                  place_matrix;  /* sym ref placement mat  */
GRrange                    range;
struct GRvg_construct      cnst_list;     /* construction list      */
struct IGRlbsys            geom;
struct GRvar_list          list[4];
struct GRcell_class_attr   local_class_attr;
struct IGRaltdisplay       alt_display, *p_alt_display;

   *msg = MSSUCC;
   constructed = 0;
   world = FALSE;
   cnst_list.newflag = 0;
   cnst_list.name = name;
   cnst_list.properties = properties;
   cnst_list.display = display;
   cnst_list.msg = &ret_msg;
   cnst_list.env_info = target_env;
   cnst_list.geometry = (IGRchar *)&geom;

   /* TR 91N3684
    * Get the active level as the default.   dhm  11/20/91
    */

   if (!level)
   {
     gr$get_active_level( buffer = &cnst_list.level );
   }
   else
   {
     cnst_list.level = level;
   }

   if (!class_attr)
   {
      local_class_attr.properties = NULL;

      list[0].var = GR_SYMBOL_NAME;
      list[0].var_ptr = local_class_attr.name_symbol;
      list[0].num_bytes = MAX_SYMBOL_DEF_NAME;
      list[0].bytes_returned = &temp;

      list[1].var = GR_SYMBOL_DESC;
      list[1].var_ptr = local_class_attr.desc_symbol;
      list[1].num_bytes = MAX_SYMBOL_DEF_DESC;
      list[1].bytes_returned = &temp;

      list[2].var = GR_TIME_STAMP;
      list[2].var_ptr = (IGRchar *) &local_class_attr.time_stamp;
      list[2].num_bytes = sizeof (IGRlong);
      list[2].bytes_returned = &temp;

      list[3].var = END_PARAM;
      list[3].var_ptr = NULL;
      list[3].num_bytes = NULL;
      list[3].bytes_returned = NULL;

      om_msg = om$send (
               msg = message GRsymbol.GRset_inq_symbol (&ret_msg, 0, list),
               senderid = NULL_OBJID, targetid = sdh_id->objid, 
               targetos = sdh_id->osnum);

      cnst_list.class_attr = (IGRchar *) &local_class_attr;
   }else
   {
      cnst_list.class_attr = class_attr;
   }

   /*
    *  Call a routine to calculate the placement matrix based on the
    *  active angle, active scale, world to view port rotation, 
    *  placement origin.
    */

   temp_origin[0] = 0;
   temp_origin[1] = 0;
   temp_origin[2] = 0;
   om_msg = GRsmplmat(&ret_msg, angle, scale, temp_origin, rot_matrix,
            place_matrix);

   /*
    *  Copy the placement matrix to the abstract geometry.
    */

   for (i=0; i < 16; ++i)
   {
      geom.matrix[i] = place_matrix[i];
   }

   om_msg = om$send (
            msg = message GRgraphics.GRgetrang (msg, NULL, NULL, &world,
            range), 
            senderid = NULL_OBJID, targetos = sdh_id->osnum,
            targetid = sdh_id->objid);

   for (i=0; i < 3; ++i)
   {
      geom.diag_pt1[i] = range[i];
      geom.diag_pt2[i] = range[i+3];
   }

   if (om_msg & ret_msg & 1)
   {
      for (i=0; i < num_origins; ++i)
      {      
         /*
          *  Construct the cell.
          */
             
         cl_id[i].osnum = target_env->md_id.osnum;
         om_msg = om$construct(classname = classname,
                  osnum = target_env->md_id.osnum,
                  p_objid = &cl_id[i].objid);

         if (om_msg & 1)
         {
            constructed++;
            geom.matrix[3] = origins[i][0];
            geom.matrix[7] = origins[i][1];
            geom.matrix[11] = origins[i][2];
            place_matrix[3] = origins[i][0];
            place_matrix[7] = origins[i][1];
            place_matrix[11] = origins[i][2];
   
            /*
             *  Send a message to the cell header to
             *  initilaze itself.
             */

            om_msg = om$send(
                     msg = message GRgraphics.GRconstruct (&cnst_list),
                     senderid = NULL_OBJID,
                     targetid = cl_id[i].objid,
                     targetos = cl_id[i].osnum);

            if (om_msg & ret_msg & 1)
            {
               /*
                *  Copy the active symbol definition from the local
                *  cell library to the active module space. The 
                *  objects should be transformed by the placement
                *  matrix.  The objects will be added to the 
                *  appropriate index objects.
                */

               /*  Fixed memory fault problem and TR91N4073.  dhm   */

               if (display)
               {
                 alt_display.color = &display->color;
                 alt_display.weight = &display->weight;
                 alt_display.style = &display->style;

                 p_alt_display = &alt_display;
               }
               else
                 p_alt_display = NULL;

               om_msg = om$send(
                        msg = message GRsmdfhdr.GRcp_sd_to_ams (&ret_msg, 
                        place_matrix, p_alt_display, &cl_id[i], symbol_env, 
                        target_env),
                        senderid = NULL_OBJID,
                        targetid = sdh_id->objid,
                        targetos = sdh_id->osnum);
            }
         }
      }
   }

   if ( (!(om_msg & ret_msg & 1)) && constructed)
   {
      for (i = 0; i < constructed; ++i)
      {
         ret_msg = om$send(
                   msg = message GRgraphics.GRdelete (&ret_msg, 
                   target_env),
                   senderid = NULL_OBJID,
                   targetid = cl_id[i].objid,
                   targetos = cl_id[i].osnum);
      }
   }  
   return(om_msg);
}
end implementation Root;
