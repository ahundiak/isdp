
class implementation Root;

#include "grimport.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "gr.h"
#include "madef.h"
#include "igrdp.h"
#include "grdpb.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "referr.h"
#include "dp.h"
#include "dpstruct.h"
/* prototype files */
%safe
#include "maidmx.h"
#include "dpdisplay.h"
%endsafe

from IGEdisplay import DPdisbyoid, DPdisbybuf;


%safe
extern int GRlocate_in_progress; 
%endsafe


IGRint  DPdisbybuf(
      IGRlong                   *msg,
      GRspacenum                osnum,
      GRobjid                   objid,
      enum GRdpmode             mode,
      IGRlong                   num_elem,
      struct DPele_header       *buffer,
      IGRint			view_ind,
      IGRint			view_ind_type,
      IGRdouble			*view_ind_point)
    {
      IGRlong status = TRUE;

        
        if (objid == NULL_OBJID)
        {
           ex$get_cur_mod(id = &objid, osnum = &osnum);
        }


        status = om$send (   msg = message IGEdisplay.DPdisbybuf(
                                      msg, &mode, buffer, &num_elem, view_ind,
				      view_ind_type, view_ind_point), 
                                senderid = NULL_OBJID, 
                                targetid = objid, 
                                targetos = osnum);


        if (!(1 & status))
        {
#ifdef	DEBUG
           printf("Error in dpdisplay send to DPdisbybuf\n");
           om$report_error(sts = status);
#endif
        }

	return(status);
    }


IGRint  DPdisbyoid(
      IGRlong                   *msg,
      GRspacenum                osnum,
      GRobjid                   objid,
      enum GRdpmode             mode,
      IGRlong                   num_elem,
      struct GRid               *oids,
      IGRshort                  *mtx_type,
      IGRmatrix                 *matrix[],
struct IGRaltdisplay		*alt_symb,
      IGRboolean                mtx_flag)
       {


      IGRlong   msg1;
      IGRlong   status = TRUE;
      IGRmatrix matr;
      IGRmatrix *mat[1];
      IGRshort  type = MAIDMX;
      struct IGRaltdisplay new_alt_symb;
      struct GRhesym       buffer;

        
        if (objid == NULL_OBJID)
        {
           ex$get_cur_mod(id = &objid, osnum = &osnum);
        }
        if ( ( GRlocate_in_progress ) && ( !alt_symb ) )
        {
            /*
             * If the object is in a reference file
             */
            GRcheckref(msg, NULL, NULL, NULL, &(oids->osnum) );

            if ( *msg != GRNOTREFFILE )
            {

               gr$get_visible_edge_sym( msg = msg, buffer = &buffer );

               alt_symb = &new_alt_symb;
               alt_symb->rgb_value = NULL;
               if ( !(buffer.flags & DPB_USE_ORIG_COLOR) )
               {
                  alt_symb->color = &buffer.color;
               }
               else
               {
                  alt_symb->color = NULL;
               }
               if ( !(buffer.flags & DPB_USE_ORIG_WEIGHT) )
               {
                  alt_symb->weight = &buffer.weight;
               }
               else
               {
                  alt_symb->weight = NULL;
               }
               if ( !(buffer.flags & DPB_USE_ORIG_STYLE) )
               {
                  alt_symb->style = &buffer.style;
               }
               else
               {
                  alt_symb->style = NULL;
               }

            }
        }

           

        if (mtx_flag == 0)
        {
           status = om$send (   msg = message IGEdisplay.DPdisbyoid (
                                   msg, &mode, oids, &num_elem,
                                   mtx_type, 
                                   matrix, alt_symb), 
                             senderid = NULL_OBJID, 
                             targetid = objid, 
                             targetos = osnum);

        if (!(1 & status))
        {
#ifdef	DEBUG
           printf("Error in dpdisplay send to DPdisbyoid\n");
           om$report_error(sts = status);
#endif
        }

        }
        else
        {
           MAidmx(&msg1, matr);
           mat[0] = (IGRmatrix *) matr;

           status = om$send (   msg = message IGEdisplay.DPdisbyoid (
                                   msg, &mode, oids, &num_elem, &type, 
                                   mat, alt_symb), 
                             senderid = NULL_OBJID, 
                             targetid = objid, 
                             targetos = osnum);

        if (!(1 & status))
        {
#ifdef	DEBUG
           printf("Error in dpdisplay send to DPdisbyoid\n");
           om$report_error(sts = status);
#endif
        }

        }

	return(status);

}
end implementation Root;
