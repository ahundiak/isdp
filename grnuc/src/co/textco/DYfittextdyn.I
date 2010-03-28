/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              COtext
     METHOD NAME:             DYfittextdyn
 
     Abstract:

        This function is used in fitted text dynamics when the 
        user moves the cursor after entering the first data point.
-----
%SC%

     VALUE = DYfittext(elem,me_text_string,me_text_symb,me_ActiveDisplay,
                       me_origin,me_wld_view_mtrx,me_rot_matrix,me_viewind)

     VALUE = DYfittextdyn(info,pnt,pnt_flag,character,num_bytes,char_flag,
                          rot_matrix,objects,num_objects,buffers,num_buffers,
                          out_flags,viewind)
-----
%EN%
      ON ENTRY:

           NAME               DATA TYPE                  DESCRIPTION
     ----------------   ----------------------  -----------------------------
     *elem              struct DPele_header     info to pass to DPdynamics
     *me_text_string    unsigned IGRchar        text string
     *me_text_symb      struct GRdpb_text_symb  'active' text parameters
     *me_ActiveDisplay  struct IGRdisplay       'active' display parameters
     me_origin          IGRpoint                origin (first point) of string
     me_wld_view_mtrx   IGRmatrix               world to view matrix
     me_rot_matrix      IGRmatrix               view rotation matrix 
     me_viewind         IGRint                  type of view independence;
                                                -1 if not view independent

     ON ENTRY:

        NAME       DATA TYPE                    DESCRIPTION
     ----------   ------------        ----------------------------------------
     *info        struct GRdyn_info   information to pass to DPdynamics
     *pnt         EX_button           current cursor position in world
                                      coordinates
     *pnt_flag    IGRboolean          flag is set if cursor has moved
     *character   IGRchar             single character the user has entered
     *num_bytes   IGRint              number of bytes from software queue
     *char_flag   IGRboolean          flag is set if user entered a character
     *rot_matrix  IGRdouble           window rotation matrix
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     **objects    GRid           objects that are in dynamics
     *num_objects IGRint         number of objects in dynamics
     **buffers    DPele_header   buffered elements in dynamics
     *num_buffers IGRint         number of buffered elements
     *out_flags   IGRint         indicates whether or not text is
                                 view independent and if the text
                                 should be erased
     **viewind  struct DPviewind info to provide if text is view ind 

     VALUE (IGRint) =     MSSUCC    - if successful
                          MSFAIL    - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:  MAptsxform
               MA2ptdis
               MAang2vc
               GRcreatelbs

     methods:  GRfm.GRfm_retdata

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  07/21/86 : Design date.
        DEK  07/21/86 : Creation date.
        DEK  07/14/88 : Modified because of sixteen bit text.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
    This function is used in text dynamics when the user moves the
cursor after entering the first datapoint.
----*/
/*EH*/

class implementation COtext;

#include "igr.h"
#include "dpstruct.h"
#include "exmacros.h"
#include "fontdef.h"
#include "dpdef.h"
#include "codef.h"
#include "coimport.h"

struct GRdyn_info
{
   struct DPele_header  *ele_header;
   struct DPviewind     viewind_info;
};

from GRfm import GRfm_retdata;

extern int GRtext_dynamics_in_progress;

static IGRpoint           tmp_pt;          /* current position of cursor  */
static struct extents     lbs_extents;     /* extents of the text string  */
static IGRdouble          unsc_length;     /* unscaled length of string   */
static struct vfont_entry font_info;       /* font information            */
static IGRpoint           origin;          /* origin (first pt) of string */
static IGRmatrix          wld_view_mtrx;   /* world to view matrix        */
static IGRmatrix          rot_matrix;      /* view rotation matrix        */
static IGRint             view_ind;        /* type of view independence;  */
                                           /* -1 if text is not view ind  */

IGRint  DYfittext(elem,me_text_string,me_text_symb,me_ActiveDisplay,me_origin,
                  me_wld_view_mtrx,me_rot_matrix,me_viewind)

struct DPele_header    *elem;            /* structure containing object info */
IGRuchar       	       **me_text_string; /* pointer to the text string       */
struct GRdpb_text_symb *me_text_symb;    /* text symbology                   */
struct IGRdisplay      *me_ActiveDisplay;/* 'active' display parameters      */
IGRpoint               me_origin;        /* origin (first point) of string   */
IGRmatrix              me_wld_view_mtrx; /* world to view matrix of 1st pt   */
IGRmatrix              me_rot_matrix;    /* view rotation matrix of 1st pt   */
IGRint                 me_viewind;       /* type of view independence;       */
                                         /* -1 if not view independent       */

{
   extern IGRint      DYfittextdyn();   /* dynamics function           */
   extern IGRboolean  GRtx_extents();   /* finds the length of a text  */

                                        /* string                      */
   IGRint             status = 1;       /* return value                */
   IGRlong            msg;              /* completion code             */
   IGRlong            rc;               /* OM return code              */
   struct extents     unscaled_extents; /* unscaled extents of the     */
                                        /* text string                 */
   struct GRid        fontmgr_obj;      /* objid/osnum of font manager */
   struct GRdyn_info  dyn_info;         /* info to pass to the dynamics*/
                                        /* fuction                     */
   GRspacenum         cur_mod_osnum;    /* current module's osnum      */
   OM_S_OBJID         cur_mod_id;       /* current module's object id  */
   IGRshort           i;                /* index counter               */

   GRtext_dynamics_in_progress = TRUE;

   view_ind = me_viewind;
   dyn_info.ele_header = elem;

   /*
    *  initialize the position of the cursor
    */

   tmp_pt[0] = 0;
   tmp_pt[1] = 0;
   tmp_pt[2] = 0;

   /*
    * initialize from the command object
    */

   origin[0] = me_origin[0];
   origin[1] = me_origin[1];
   origin[2] = me_origin[2];

   for (i = 0; i < 16; ++i)
   {
      wld_view_mtrx[i] = me_wld_view_mtrx[i];
      rot_matrix[i] = me_rot_matrix[i];
   }

   /* 
    * extents are the diagonal points of the local bounded system
    */

   lbs_extents.left = elem->geometry.lbsys->diag_pt1[0];
   lbs_extents.bottom = elem->geometry.lbsys->diag_pt1[1];
   lbs_extents.right = elem->geometry.lbsys->diag_pt2[0];
   lbs_extents.top = elem->geometry.lbsys->diag_pt2[1];
   lbs_extents.cap = lbs_extents.top;
   lbs_extents.base = lbs_extents.bottom;

   /*
    *  get the objid of the font manager using
    *  its named object
    */

   ex$get_cur_mod(osnum = &cur_mod_osnum,
                  id = &cur_mod_id);

   ex$get_super(mod_id = cur_mod_id,
                mod_osnum = cur_mod_osnum,
                super_name = FONTMGR_NO_NAME,
                create = TRUE,
                super_class = "GRfm",
                super_id = &fontmgr_obj.objid,
                super_osnum = &fontmgr_obj.osnum);

   /*
    * get font information from specified font
    */

   rc = om$send(mode = OM_e_wrt_object,
                msg = message GRfm.GRfm_retdata
                      (&msg,&(me_text_symb->Active_font),&font_info),
                senderid = NULL_OBJID,
                targetid = fontmgr_obj.objid,
                targetos = cur_mod_osnum);

   if (!COERROR(rc) && !COERROR(msg))
   {
      /*
       * find the unscaled length of the text string; hard code the text
       * width argument to 1.0 so no scaling will take place
       */

      GRtx_extents(&msg,*me_text_string,
                   &elem->ele_spec_att.text->estx->text_length,
                   &font_info,me_ActiveDisplay,
                   me_text_symb->Active_charspac,
                   me_text_symb->Active_linespac,1.0,
                   me_text_symb->Active_height,me_text_symb->Active_font,
                   0,elem->ele_spec_att.text->estx->text_length - 1,
                   &unscaled_extents);

      unsc_length = unscaled_extents.right - unscaled_extents.left;

      if (unsc_length == 0)
      {
         unsc_length = 1;
      }

      elem->dis_att = me_ActiveDisplay;

      /*
       * call dynamics function
       */

      DPtxdynamics(DYfittextdyn,&dyn_info,NULL,NULL,NULL);

   }
   else
   {
      status = 0;
   }
   
   GRtext_dynamics_in_progress = FALSE;

   return (status);
}


#argsused
IGRint DYfittextdyn(info,pnt,pnt_flag,character,num_bytes,char_flag,rot_matrix,
                    objects,num_objects,buffers,num_buffers,out_flags,viewind)

struct GRdyn_info   *info;        /* information for DPdynamics          */
struct EX_button    *pnt;         /* current cursor position in world
                                     coordinates                         */
IGRboolean          *pnt_flag;    /* flag indicating point received      */
IGRuchar    	    *character;   /* character of text string            */
IGRint              num_bytes;    /* number of bytes from software queue */
IGRboolean          *char_flag;   /* flag indicating char received       */
IGRdouble           *rot_matrix;  /* window  that are in dynamics        */
struct GRid         **objects;    /* objects that are in dynamics        */
IGRint              *num_objects; /* number of objects in dynamics       */
struct DPele_header **buffers;    /* buffered elements in dynamics       */
IGRint              *num_buffers; /* number of buffered elements         */
IGRint              *out_flags;   /* indicates whether or not text is    */
                                  /* view independent and if the text    */
                                  /* should be erased                    */
struct DPviewind    **viewind;    /* info to provide if text is view ind */

{
   extern IGRboolean  MAptsxform();
   extern IGRboolean  MA2ptdis();
   extern IGRboolean  MAang2vc();
   extern IGRboolean  GRcreate_lbs();

   IGRlong     msg;               /* completion code                */
   IGRdouble   view_pts[6];       /* points in view coordinates     */
   IGRlong     num_points = 2;    /* number of points to xform      */
   IGRint      i;                 /* index                          */
   IGRvector   text_vec;          /* vector to find angle of text   */
   IGRdouble   distance;          /* distance between datapoints    */
   IGRvector   view_x_vect;       /* x vector of view               */
   IGRdouble   text_angle[3];     /* angle of text in radians       */

   /*
    * Note: this routine is to anchor the fitted text string so
    * only a point will be processed
    */

   /*
    * if cursor position has changed, change point
    */

   tmp_pt[0] = pnt->x;
   tmp_pt[1] = pnt->y;
   tmp_pt[2] = pnt->z;

   view_pts[0] = origin[0];
   view_pts[1] = origin[1];
   view_pts[2] = origin[2];
   view_pts[3] = tmp_pt[0];
   view_pts[4] = tmp_pt[1];
   view_pts[5] = tmp_pt[2];

   /*
    * transform point to world coordinates
    */

   if (MAptsxform(&msg,&num_points,wld_view_mtrx,view_pts,view_pts))
   {
      text_vec[0] = view_pts[3] - view_pts[0];   /* vector used in finding */
      text_vec[1] = view_pts[4] - view_pts[1];   /* angle of text          */

      /*
       * machine precision problem when subtracting z-values:
       * text_vec[2] = view_pts[5] - view_pts[2]; just use zero
       */

      text_vec[2] = 0;

      /*
       * find the distance between the two points
       */

      MA2ptdis(&msg,origin,tmp_pt,&distance);

      /*
       * find the angle of text object
       */

      view_x_vect[0] = 1;
      view_x_vect[1] = 0;
      view_x_vect[2] = 0;

      if (MAang2vc(&msg,view_x_vect,text_vec,text_angle))
      {
#ifndef IDRAW
         /*
          * if text is view independent, set the appropriate flag and supply
          * the necessary info for view independent display; also need to
          * initialize the rotation matrix to the identity matrix if this is
          * view independent text since the view rotation shouldn't be used
          */

         if (view_ind >= 0)
         {
            *out_flags |= DP_VIEW_IND_BUF;

            info->viewind_info.type = view_ind;
            info->viewind_info.point[0] = origin[0];
            info->viewind_info.point[1] = origin[1];
            info->viewind_info.point[2] = origin[2];
            *viewind = &info->viewind_info;

            for (i = 0; i < 15; ++i)
            {
               rot_matrix[i] = 0;
            }

            rot_matrix[0] = 1;
            rot_matrix[5] = 1;
            rot_matrix[10] = 1;
            rot_matrix[15] = 1;
         }
#endif  /* IDRAW */

         /*
          * create a local bounded system
          */

         if (GRcreate_lbs(&msg,&(text_angle[0]),rot_matrix,origin,
             &lbs_extents,info->ele_header->geometry.lbsys))
         {
            /*
             * find the text width and height based on the distance between
             * the two input points and the unscaled length of the text
             * object
             */

            info->ele_header->ele_spec_att.text->estx->width = distance / unsc_length;
            info->ele_header->ele_spec_att.text->estx->height = info->ele_header->ele_spec_att.text->estx->width;

            *buffers = info->ele_header;
            *num_buffers = 1;
         }
      }
   }
   return(msg & 1);
}

end implementation COtext;
