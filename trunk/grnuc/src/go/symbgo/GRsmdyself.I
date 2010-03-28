/* #######################    APOGEE COMPILED   ######################## */
/*\
Name
   GRdisyourself

Description
   This method sets up display for the components of a symbol reference
   header object.

   *msg         IGRlong        completion code:
   *mx_type     IGRshort       type of matrix 
   matrix       IGRmatrix      environment transformation matrix
   *mode        GRdpmode       the display mode 
   *alt_symb    struct IGRaltdisplay 
   *sp_info     struct DP_information
   range_key    OM_p_KEY_DESC  range of the grahic object

Notes 
   It is necessary to respond to the GRhhdo, GRheo, and GRhdo modes
   even if the object is not displayable.

Return Values
   MSSUCC - successful completion
   MSFAIL - failure of routine
 
History
   DKM    07/11/86 : Design date.
   DKM    07/11/86 : Creation date.
   HGW    07/26/86 : Added code for display attriubutes and properties
   HGW    08/07/86 : Changed terminolgy
   HGW    11/04/87 : Changes for version 1.1
   HGW    08/09/88 : Changes for version 1.2
   SCW    07/23/92 : Ansi conversion
\*/

class implementation GRsmhdr;

#include "grimport.h"
#include "gocmacros.h"
#include "msdef.h"
#include "grerr.h"
#include "dpmacros.h"
#include "gocmacros.h"
#include "dpdef.h"
#include "grsymdef.h"

method GRdisyourself(IGRlong *msg; IGRshort *mx_type; IGRmatrix matrix;
                     enum GRdpmode *mode; struct IGRaltdisplay *alt_symb;
                     struct DP_information *sp_info;
                     OM_p_KEY_DESC range_key)
{
IGRlong              OMmsg;                /* OM return code           */
IGRint               i,j;                    /* index for GRgetabsg      */
IGRint               use_new_alt_symb;
IGRint               save_layers[DP_NUM_OF_LEVELS/32 + 1];
IGRint               all_layers[DP_NUM_OF_LEVELS/32 + 1];
IGRshort             sym_ref_mx_type;      /* symbol ref matrix type   */
IGRshort             dlist_mx_type;   
IGRpoint             origin;
IGRmatrix            sym_ref_env_matrix;   /* symbol ref env matrix    */
IGRmatrix            dlist_matrix;
struct DPviewinfo    view_info;            /* Saved view information   */
struct IGRlbsys      *absgptr;             /* pointer to abstract geom */
struct GRsymbology   symb;                 /* symbology for display    */
struct IGRaltdisplay new_alt_symb;
OM_S_CHANSELECT      chansel;
int                  old_is_update;

   *msg = MSSUCC;
   OMmsg = MSSUCC;
   use_new_alt_symb = FALSE;
   chansel.type = OM_e_addr;
   chansel.u_sel.addr = &me->to_components;

   /*
    *  Insure that the object is displayable.
    */

   if (((me->properties & GRIS_DISPLAYABLE ) ||
        (*mode == GRhdo)                     ||
        (*mode == GRhhdo)                    ||
        (*mode == GRheo))                    &&
       (DPlevel_on (me->level, sp_info)))
   {

      GRgetabsg(msg,mx_type,matrix,(IGRchar **)&absgptr,i);
      origin[0] = absgptr->matrix[3];
      origin[1] = absgptr->matrix[7];
      origin[2] = absgptr->matrix[11];

      /*
       *  If display attributes are defined for the symbol, pass the 
       *  display attributes to the components.
       */
   
      if (me->owner_properties & GR_SYM_DISPLAY_ATTR)
      {
         use_new_alt_symb = TRUE;

         /*
          *  Get the symbology for the symbol. 
          */

         OMmsg = om$send(msg = message GRvg.GRgetsymb (msg, &symb),
                 targetid = my_id);

         if (alt_symb)
         {
            new_alt_symb = *alt_symb;
         }else
         {
            new_alt_symb.color     = NULL;
            new_alt_symb.weight    = NULL;
            new_alt_symb.style     = NULL;
         }

         if ((me->owner_properties & GR_SYM_COLOR) && (!new_alt_symb.color))
         {
            new_alt_symb.color =  &symb.display_attr.color;
         }

         if ((me->owner_properties & GR_SYM_WEIGHT) && (!new_alt_symb.weight))
         {
            new_alt_symb.weight = &symb.display_attr.weight;
         }

         if ((me->owner_properties & GR_SYM_STYLE) &&
             (!new_alt_symb.style))
         {
            new_alt_symb.style = &symb.display_attr.style;
         }
      }

      /*
       *  Substitute all layers.
       */

      for (i=0; i < (DP_NUM_OF_LEVELS/32 + 1); i++)
      {
         all_layers[i] = 0xffffffff;
      }
      DPset_levels(save_layers, all_layers, sp_info);

      if (me->properties & GRIS_VIEW_INDEP)
      {
         dp$set_view_ind (type = 0, point = origin, dp_info = sp_info,
            old = &view_info);
      }

      /*
       *  Modify the transformation matrix of the components.
       */

      for (i=0; i <= 15; ++i)
      {
         sym_ref_env_matrix[i] = absgptr->matrix[i];
      }
      MAtypemx(msg,sym_ref_env_matrix,&sym_ref_mx_type);

      dlist_matrix[3] = (me->origin)[0];
      dlist_matrix[7] = (me->origin)[1];
      dlist_matrix[11] = (me->origin)[2];
      dlist_matrix[12] = dlist_matrix[13] = dlist_matrix[14] = 0.0;
      dlist_matrix[15] = 1.0;
      for ( j =0; j < 3; j++ )
      {
         for ( i =0;i < 3; i++ )
         {
            dlist_matrix[(4 * j)+ i] = (me->matrix)[i + ( 3 * j)];
         }
      }
      MAtypemx(msg,dlist_matrix,&dlist_mx_type);

      /* Do not add symbold to display lists because of the nested
         symbol complications 
      */
/*
      DPdlist_enter_reference_file( sp_info, dlist_mx_type, dlist_matrix );  
*/
      old_is_update = sp_info->is_update;
      sp_info->is_update = 0;

      OMmsg = om$send(mode = OM_e_wrt_object,
              msg = message GRgraphics.GRdisyourself (msg, 
              &sym_ref_mx_type, sym_ref_env_matrix, mode, 
              (use_new_alt_symb) ? &new_alt_symb : alt_symb, 
              sp_info, range_key),
              senderid = my_id, p_chanselect = &chansel);
      sp_info->is_update = old_is_update;

/*
      DPdlist_exit_reference_file( sp_info, mx_type, matrix );  
*/


      if (me->properties & GRIS_VIEW_INDEP)
      {
         dp$reset_view_ind (dp_info = sp_info, old = &view_info);
      }

      /*
       *  Restore the layers.
       */

      DPreset_levels(save_layers, sp_info);
   }
   GR_NOTIFY_LISTENERS(msg, &OMmsg, GR_DISPLAYED);
   return (OMmsg);
}

end implementation GRsmhdr;
