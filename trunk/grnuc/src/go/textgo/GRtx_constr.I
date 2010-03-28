/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME        
 
     Abstract: This function will fillin the instance data for a
               text element.        
-----
%SC%

     VALUE =  GRtext_constr(arglist)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                DESCRIPTION
     ----------   --------------- -----------------------------------
     *arglist   GRvg_construct  pointer to default argument list

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED:   GRvg.GRputname
                        GRvg.GRputsymb
                        MAinvmx
                        MAmulmx
                        MAlbextents
                        GRmodule.GRmdaddwrng
                        GRvg.GRpostabsg
                        GRmodule.GRmdremwrng
-----
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  03/28/86 : Design date.
        DEK  03/29/86 : Creation date.
        DEK  07/28/88 : View independence added.
        DEK  08/31/88 : Check for GRNOT_IN_RTREE added.
        SCW  07/22/92 : Removed copyright header
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
      This program fills in the instance data of the text element
   and posts the object.
----*/
/*EH*/

class implementation GRtext;

#include   "msdef.h"
#include   "grerr.h"
#include   "OMmacros.h"
#include   "gotextdef.h"
#include   "grimport.h"
#include   "grownmacros.h"

from GRmodule import GRmdaddwrng, GRmdremwrng;

method GRconstruct(struct GRvg_construct *arglist)
{
   extern IGRdouble     MAdabs();
   extern IGRboolean    MAinvmx();

   struct IGRlbsys      *lbs_ptr;          /* local bounded system pointer */
   struct GRsymbology   symbology;
   struct IGResintx     *text;             /* element specific attributes  */
   struct GRpost_info   info;              /* processing information       */
   struct IGRlbsys      tmp_lbsys;         /* local bounded sys. struct.   */
   IGRmatrix            invmx;             /* inverse matrix               */
   IGRmatrix            tmp_matrix;        /* temp matrix                  */
   GRobjid              new_id;            /* for post method              */
   IGRlong              OMmsg;
   IGRshort             mxsize = 4;        /* matrix size                  */
   IGRshort             i;
   GRrange              range;             /* range of the text object     */
   IGRdouble            longest_extent;    /* largest abs(coordinate)      */
   IGRdouble            tmp_pt1;
   IGRdouble            tmp_pt2;

   *(arglist->msg) = MSSUCC;
   OMmsg = OM_S_SUCCESS;

   me^^GRgraphics.properties = arglist->properties | GRIS_NEW;

   symbology.display_attr.color = arglist->display->color;
   symbology.display_attr.weight = arglist->display->weight;
   symbology.display_attr.style = arglist->display->style;
   symbology.level = arglist->level;

   if (arglist->name)
   {
      OMmsg = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRputname(arglist->msg,arglist->name),
                      senderid = my_id,
                      targetid = my_id);
   }

   text = (struct IGResintx *)arglist->class_attr;

   me^^GRtext.attr.font = text->estx->font;
   me^^GRtext.attr.just = text->estx->just;
   me^^GRtext.attr.flag = text->estx->flag;
   me^^GRtext.attr.width = text->estx->width;
   me^^GRtext.attr.height = text->estx->height;
   me^^GRtext.attr.num_char = text->estx->num_char;
   me^^GRtext.attr.line_spac = text->estx->line_spac;
   me^^GRtext.attr.char_spac = text->estx->char_spac;
   me^^GRtext.attr.text_length = text->estx->text_length;

   OM_SET_DIMENSION(me^^GRtext.text_string,(IGRint)text->estx->text_length);

   OM_BLOCK_MOVE(text->text_string,
                 me^^GRtext.text_string,
                 text->estx->text_length);

   lbs_ptr = (struct IGRlbsys *)arglist->geometry;

   OMmsg = om$send(mode = OM_e_wrt_object,
                   msg = message GRvg.GRputsymb(arglist->msg,&symbology),
                   senderid = my_id,
                   targetid = my_id);
   
   if (1 & OMmsg)
   {
      if (!(me^^GRgraphics.properties & GRNOT_IN_RTREE))
      {
         if (arglist->env_info->md_env.matrix_type != MAIDMX)
         {
            /* 
             * determine inverse transformation matrix
             */

            if (MAinvmx(arglist->msg,&mxsize,arglist->env_info->md_env.matrix,
                        invmx))
            {
               /* 
                * multiply local bounded system matrix by inverse matrix
                */

               MAmulmx(arglist->msg,&mxsize,&mxsize,&mxsize,invmx,
                       lbs_ptr->matrix,tmp_matrix);

            }
            else
            {
               *(arglist->msg) = GRSNOINVTRAN;
               OMmsg = OM_E_ABORT;
            }
         }
         else                              /* identity matrix        */
         {
            for (i = 0; i < 16; ++i)
            {
                tmp_matrix[i] = lbs_ptr->matrix[i];
            }
         }

         if (*(arglist->msg) & OMmsg & 1)
         {
            /*
             * determine range of text: if view independent text, must use the
             * coordinate that is the greatest distance from the origin to make
             * a psuedo diagonal box
             */

            for (i = 0; i < 16; ++i)
            {
                tmp_lbsys.matrix[i] = tmp_matrix[i];
            }

            if (me^^GRgraphics.properties & GRIS_VIEW_INDEP)
            {
               longest_extent = 0;

               for (i = 0; i < 2; ++i)
               {
                  tmp_pt1 = MAdabs(arglist->msg,&(lbs_ptr->diag_pt1[i]));
                  tmp_pt2 = MAdabs(arglist->msg,&(lbs_ptr->diag_pt2[i]));

                  if (tmp_pt1 > longest_extent)
                  {
                     longest_extent = tmp_pt1;
                  }

                  if (tmp_pt2 > longest_extent)
                  {
                     longest_extent = tmp_pt2;
                  }
               }

               tmp_lbsys.diag_pt1[0] = -longest_extent;
               tmp_lbsys.diag_pt1[1] = -longest_extent;
               tmp_lbsys.diag_pt1[2] = longest_extent;
               tmp_lbsys.diag_pt2[0] = longest_extent;
               tmp_lbsys.diag_pt2[1] = longest_extent;
               tmp_lbsys.diag_pt2[2] = -longest_extent;
            }
            else
            {
               for (i = 0; i < 3; ++i)
               {
                   tmp_lbsys.diag_pt1[i] = lbs_ptr->diag_pt1[i];
                   tmp_lbsys.diag_pt2[i] = lbs_ptr->diag_pt2[i];
               }
            }

            MAlbextents(arglist->msg,&tmp_lbsys,range,&range[3]); 

            /* KLUDGE don't use OMmsg until add is fixed  */

            om$send(mode = OM_e_wrt_object,
                           msg = message GRmodule.GRmdaddwrng(arglist->msg,
                                 range,&my_id),
                           senderid = my_id,
                           targetid = arglist->env_info->md_id.objid,
                           targetos = arglist->env_info->md_id.osnum);
         }
      }

      info.construct_flag = TRUE;         /* post the instance data */

      OMmsg = om$send(mode = OM_e_wrt_object,
                      msg = message GRvg.GRpostabsg(arglist->msg,
                            arglist->env_info,&info,arglist->geometry,
                            &new_id),
                      senderid = my_id,
                      targetid = my_id);

      if (!(1 & OMmsg & *(arglist->msg)) &&
          !(me^^GRgraphics.properties & GRNOT_IN_RTREE))
      {
         OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRmodule.GRmdremwrng(
                               arglist->msg,range,&my_id),
                         senderid = my_id,
                         targetid = arglist->env_info->md_id.objid,
                         targetos = arglist->env_info->md_id.osnum);
      }

      gr$add_to_active_owner(msg = arglist->msg,
                             mod_env = arglist->env_info,
                             objid = my_id);

   }

   return (OMmsg);
}

end implementation GRtext;
