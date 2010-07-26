/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRclip

Description
   This method is used to clip a symbol to a right prism.  The clip 
   operation will generate two or three new symbols.  The first symbol
   contains all elements within the right prism.  The second symbol will
   contain all elements outside of the right prism.  The third symbol will
   contain the elements overlapping the right prism.  The overlapping 
   symbol is created depending on the clip flag.  The original symbol
   header will remain intact depending on the clip flag.

   *msg         IGRlong             completition code
   *mod_env     struct GRmd_env     The originial module environment.
   *target_env  struct GRmd_env     The target environment.
   *prism       IGRchar             The prism to clip against.
   *inside_id   struct GRid         The object id of the inside owner.
   *outside_id  struct GRid         The object id of the outside owner.
   *overlap_id  struct GRid         The object id of the overlapping owner.
   *clip_flag   IGRlong             The flag describing the type of clip.

Algorithm
   The following are ways to clip a symbol:

   1. Let the symbol do the work by transforming itself to a cell
      and then clipping the cell.

      A. Symbol copies itself to a cell.
      B. Clips and deletes the cell.

      Adv.  Uses existing clip code for the cell.
      Dis.  Creates a temporary copy of a cell.

   2. Let the symbol definition perform the clip.

      A. Symbol header passes a message to the symbol definition.
      B. Symbol definition passes down the transformation matrix in
         the module environment and clips the elements.  Then must apply
         transformation to each element.  Must change symbology of
         each element.  

      Adv. Does not create any temporary copies.
      Dis. Duplicates a lot of code.

   The first way was choosen.
   This method will construct a cell from the symbol.
   Then clip and delete the cell.

   By constructing a temporary cell we are able to utilize the
   existing code to clip a cell and the existing code to convert
   a symbol to a cell.

Return Values
   MSSUCC  -- successful completion
   MSFAIL --  if failure

History
   HGW     02/12/87 : Creation 
   HGW     11/07/87 : Changes for version 1.1
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "msdef.h"
#include "OMerrordef.h"
#include "grerr.h"
#include "gocmacros.h"
#include "grownerdef.h"

method GRclip(IGRlong *msg; struct GRmd_env *mod_env;
              struct GRmd_env *target_env; IGRchar *prism; 
              struct GRid *inside_id; struct GRid *outside_id;
              struct GRid *overlap_id; IGRlong *clip_flag)
{
IGRlong              om_msg;
IGRlong              ret_msg;
IGRlong              prism_rel;
IGRlong              local_clip_flag;
IGRint               copy_flag;
IGRshort             prism_type;
struct GRid          cl_id;

   *msg = MSSUCC;

   if (me->properties & GRIS_VIEW_INDEP)
   {
      /*
       *  Do not clip a view independent symbol.
       */

      return (OM_S_SUCCESS);
   }   

   local_clip_flag = *clip_flag | GR_CLIP_NORGCK;
   copy_flag = (*clip_flag & GR_CLIP_NODEL) ? TRUE : FALSE;

   /*
    *  Do we perform a range check?
    */
   
   if (!(*clip_flag & GR_CLIP_NORGCK))
   {
      if (*clip_flag & GR_CLIP_RTPRISM)
      {
         prism_type = 0;
      }else
      {
         prism_type = 1;      
      }

      /*
       *  Is the symbol within the prism.
       */

      om_msg = om$send ( 
               msg = message GRgraphics.GRprismrel (&ret_msg,
               &mod_env->md_env.matrix_type, mod_env->md_env.matrix, NULL,
               &prism_type, prism, &prism_rel), targetid = my_id);

      if (om_msg & ret_msg & 1)
      {         
         if (prism_rel == 1)
         {
            *msg = GR_I_OBJINSIDE;  /* symbol is inside */
            goto FINISH;
         }else if (prism_rel == 0)
         {
            *msg = GR_I_OBJOUTSIDE; /* symbol is outside */
            goto FINISH;
         }
      }else
      {
         *msg = MSFAIL;
         om_msg = OM_S_SUCCESS;
         goto FINISH;
      }
   }
   
   /*
    *  The symbol is overlapping the right prism.  Generate a temporary
    *  cell that will contain all the elements within the symbol.
    */

   om_msg = om$send(
            msg = message GRsmhdr.GRcp_symbol_to_cell (&ret_msg, mod_env,
            target_env, &cl_id), targetid = my_id);

   om_msg = om$send (
            msg = message GRgraphics.GRclip (&ret_msg, target_env, target_env,
            prism, inside_id, outside_id, overlap_id, &local_clip_flag),
            targetid = cl_id.objid, targetos = cl_id.osnum);

   if ((om_msg & ret_msg & 1) && (!copy_flag))
   {
      /*
       *  If this is not a copy operation then delete the original
       *  symbol since it has been replaced by clipped cells.
       */

      om_msg = om$send (
               msg = message GRgraphics.GRdelete (msg, mod_env),
               targetid = my_id);
   }else 
   {
      /*
       *  If this was a copy operation then delete the cell that was
       *  created to be used as a model for clipping.
       */

      om$send (msg = message GRgraphics.GRdelete (&ret_msg, target_env),
               targetid = cl_id.objid, targetos = cl_id.osnum);
   }
FINISH:
   GR_NOTIFY_LISTENERS(msg, &om_msg, GR_CLIPPED);
   return (om_msg);
}
end implementation GRsmhdr;
