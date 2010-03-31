/* ###################   APOGEE COMPILED   ################## */
class implementation EMSloop;

#include "EMS.h"
# include <stdio.h>
#include "EMSlmdef.h"
#include "OMmacros.h"

from EMSedge import EMdisplay;

method EMmkf_lp_display (
        IGRlong                 *EMmsg;
        struct DPele_header     *sf_ele_header;
        IGRshort                *mx_type;
        IGRmatrix               matrix;
        enum GRdpmode           *display_mode;
        struct DP_information   *sp_info;
        IGRshort                display_flag;
        IGRlong                 sender_lp_type;
        IGRlong                 sender_lp_gr;
        IGRlong                 external_lp_gr;
        IGRlong                 display_gr;
        IGRuchar        p_lp_style;
        IGRuchar        c_lp_style;
        IGRboolean              *any_lp_displayed)

/*
History
	RC	12/16/87		Creation Date

*/

{
   OM_S_CHANSELECT      lp_ed_chan, to_inner;
   IGRlong              mthd_stat;
IGRlong   OM_stat;
   IGRboolean           display_myself;

   OM_stat = OM_S_SUCCESS;
   *EMmsg = EMS_S_Success;
   mthd_stat = EMS_S_Success;

   /*
    * The following assumptions are made for this 
    * method:
    *
    * 1) It is assumed the this method is invoked by
    *    my parent loop on the looptree.
    * 
    * 2) A p-loop loop can not have a p-loop as a child
    *    and vice versa. Similarly, a c-loop can not
    *    have a c-loop as a child and vice versa.
    *
    * I can be either a p-loop or a c-loop. Based upon
    * my loop type, there are two cases:
    *
    * 1) If I am a p-loop, my parent loop is
    *    either a regular c-loop or a dummy c-loop.
    *    There are two cases based upon my parent c-loop 
    *    type:
    *    
    *    a) If my parent c-loop is a dummy c-loop,
    *	    my group is opposite to my parent's group
    *	    (i.e., opposite to sender_lp_gr);
    *
    *    b) If my parent's c-loop is a regular c-loop,
    *	    my group is same as that of parent's group
    *       (i.e., same as sender_lp_gr).
    *
    *
    * 2) If I am a c-loop (regular or dummy), my parent's
    *    loop is a p-loop. In such a case my group is 
    *	 same as that of my parents' group (i.e, sender_lp_gr).
    */

    display_myself = FALSE;

    if (ME.EMSloop->lp_props & EMLP_EXTERNAL)
    {
      if (external_lp_gr == display_gr) display_myself = TRUE;
      sender_lp_type = EMLP_PLOOP;
      sender_lp_gr = external_lp_gr;
      
    } /* if (ME.EMSloop->lp_props & EMLP_EXTERNAL) */
    else
    {
      if (ME.EMSloop->lp_props & EMLP_PLOOP)
      {

        if (sender_lp_type & EMLP_DUMMY_CLOOP)
        {
          if (sender_lp_gr == EMS_MKFACE_GROUP1)
          {
             sender_lp_gr = EMS_MKFACE_GROUP2;
             if (display_gr == EMS_MKFACE_GROUP2) display_myself = TRUE; 
			
          } /* if (sender_lp_gr == EMS_MKFACE_GROUP1) */
	
          else
          {
             sender_lp_gr = EMS_MKFACE_GROUP1;
             if (display_gr == EMS_MKFACE_GROUP1) display_myself = TRUE; 
          }

        } /* if (sender_lp_type & EMLP_DUMMY_CLOOP) */

        else
        if (!(sender_lp_type & EMLP_PLOOP))
        {
          if (sender_lp_gr == EMS_MKFACE_GROUP1)
          {
             if (display_gr == EMS_MKFACE_GROUP1) display_myself = TRUE; 

          }			
          else
          {
             if (display_gr == EMS_MKFACE_GROUP2) display_myself = TRUE; 
          }

        } /* if (!(sender_lp_type & EMLP_PLOOP)) */

        else
        {
           *EMmsg = EMS_E_Fail;
           fprintf (stderr,"p-lp inside p-lp or wrong loop type\n");
           goto wrapup;
        }
        sender_lp_type = EMLP_PLOOP;

      } /* if (ME.EMSloop->lp_props & EMLP_PLOOP) */
    
      else	/* I am a c-loop (regular or dummy ) */
      {
          sender_lp_type = (ME.EMSloop->lp_props & EMLP_DUMMY_CLOOP) ?
				EMLP_DUMMY_CLOOP : 0;

          if (sender_lp_gr == EMS_MKFACE_GROUP1)
          {
             if (display_gr == EMS_MKFACE_GROUP1) display_myself = TRUE; 
			
          } /* if (sender_lp_gr == EMS_MKFACE_GROUP1) */
	
          else
              if (display_gr == EMS_MKFACE_GROUP2) display_myself = TRUE; 

      } /* else for if (ME.EMSloop->lp_props & EMLP_PLOOP) */

    } /* else for if (ME.EMSloop->lp_props & EMLP_EXTERNAL) */

    /*
     * display myself if group is to be displayed.
     */

    if (display_myself)
    {
      IGRuchar def_style;

      *any_lp_displayed = TRUE;

      lp_ed_chan.type = OM_e_addr;
      lp_ed_chan.u_sel.addr = &ME.EMSbd_owner->to_comps;
      def_style = sf_ele_header->dis_att->style;

      if (ME.EMSloop->lp_props & EMLP_PLOOP) 
          sf_ele_header->dis_att->style = p_lp_style;
      else 
          sf_ele_header->dis_att->style = c_lp_style;

      OM_stat = om$send (msg = message EMSedge.EMdisplay (&mthd_stat, 
                          sf_ele_header, mx_type, matrix, display_mode, 
                           sp_info, display_flag, NULL),
                         p_chanselect = &lp_ed_chan);
      EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);

      sf_ele_header->dis_att->style = def_style;

    } /* if (display_myself) */

    /*
     * send the same message to my childern loops
     */
  
    to_inner.type = OM_e_addr;
    to_inner.u_sel.addr = &ME.EMSloop->to_inner;

    OM_stat = om$send (msg = message EMSloop.EMmkf_lp_display (&mthd_stat,
                        sf_ele_header, mx_type, matrix, display_mode,
                        sp_info, display_flag, sender_lp_type, 
                        sender_lp_gr, external_lp_gr, display_gr,
                        p_lp_style, c_lp_style, any_lp_displayed),
                       p_chanselect = &to_inner);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopError,wrapup);


wrapup:

  EMWRAPUP (*EMmsg,OM_stat,"In EMSloop.EMmkf_lp_display");

  return (OM_stat);
}

end implementation EMSloop;


