/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   GRtext

     Abstract:    This function will display a text object given a 
               text string, text length, rotation matrix, an origin
               point, and "active parameters".
-----
%SC%
     Value = GRdisptext(msg,text_string,text_length,origin,rot_matrix,
                        lbs_matrix,ActiveDisplay,ActiveLevel,ModuleInfo,
                        text_symb,properties,ActiveAngle,mode,win_objid,flags)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------     ------------            ---------------------------
     *text_string   IGRuchar                text string
     *text_length   IGRshort                length of text string
     origin         GRpoint                 placement pt of text string
     *rot_matrix    IGRdouble               view rotation matrix used
     *lbs_matrix    IGRdouble               local bounded system matrix
     *ActiveDisplay struct IGRdisplay       display parameters to use
     *ActiveLevel   IGRshort                level to place text on
     *ModuleInfo    struct GRmd_env         module environment
     *text_symb     struct GRdpb_text_symb  text symbology
     *properties    IGRushort               the object's graphic properties
                                            (displayable, locatable, etc.);
                                            #defines for these properties
                                            can be found in godef.h
     *ActiveAngle   IGRdouble               active angle
     flags          IGRint                  miscellaneous flags
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *message       IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     Modules:    

         strcpy:                  - A standard C function to copy the
                                    contents of string2 into string1.

         strcat:                  - A standard C function that appends
                                    the contents of string2 onto
                                    string1.

         GRfindmod:               - Returns objid and OS of current
                                    active module.

         GRjust_string:           - Updates justification escape sequences
                                    in a string if necessary and returns
                                    extents of string

         GRcreate_lbs:            - A function that creates an internal
                                    form of a local bounded system
                                    geometry.

         GRnum_disp_char          - A function that determines the number
                                    of displayable characters in a text string.

         GRfm.GRfm_retdata:       - This message will return the data
                                    from the specified font.

         dp$display:              - This message will display the object
                                    by object id.

-----
%RL%

     RELATIONS REFERENCED:

-----
%UI%

     USER INTERFACE DESCRIPTION:

-----
%NB%

     NOTES:  

-----
%CH%
     CHANGE HISTORY:
        
        DEK  09/17/87 : Design date.
        DEK  09/17/87 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

    This method will display a text object given a text string, text
length, rotation matrix, an origin point, and "active parameters".

----*/
/*EH*/

class implementation GRtext;

#include   "msdef.h"
#include   "gotextdef.h"
#include   "grdpbmacros.h"
#include   "igrdef.h"
#include   "dpdef.h"
#include   "dpmacros.h"
#include   "OMmacros.h"
#include   "exmacros.h"
#include   "fontdef.h"
#include   "font.h"
#include   "gotext.h"
#include   "grdpbdef.h"
#include   "grdpb.h"
#include   "codef.h"
#include   "grimport.h"

from GRfm       import GRfm_retdata;

#argsused
IGRint GRdisptext (msg,text_string,text_length,origin,rot_matrix,lbs_matrix,
                   ActiveDisplay,ActiveLevel,ModuleInfo,text_symb,
                   properties,ActiveAngle,mode,win_objid,flags)

IGRlong                *msg;                 /* completion code             */
IGRuchar               *text_string;         /* text string                 */
IGRshort               *text_length;         /* length of text string       */
IGRpoint               origin;               /* origin point for string     */
IGRdouble              *rot_matrix;          /* view rotation matrix        */
IGRdouble              *lbs_matrix;          /* local bounded system matrix */
struct IGRdisplay      *ActiveDisplay;       /* active display parameters   */
IGRshort               *ActiveLevel;         /* level to place text on      */
struct GRmd_env        *ModuleInfo;          /* module environment info.    */
struct GRdpb_text_symb *text_symb;           /* text symbology parameters   */
IGRushort              *properties;          /* graphic properties          */
IGRdouble              *ActiveAngle;         /* active angle                */
enum GRdpmode          *mode;                /* display mode                */
GRobjid                *win_objid;           /* window(s) to display text   */
IGRint                 flags;                /* miscellaneous flags
                                                (defined in gotextdef.h)    */
{

   extern IGRboolean GRcreate_lbs();   /* creates (initializes) the local
                                          bounded system geometry           */
   extern IGRboolean GRjust_string();  /* justifies text string (inserts or
                                          deletes justifications moves) and
                                          returns the extents               */

   struct IGRlbsys        lbs_geom;      /* local bounded system geo  */
   struct IGResintx       tx_attr;       /* disp text specific attr   */
   struct IGRestx         tx_sp_attr;    /* text specific attributes  */
   struct extents         new_extents;
   struct vfont_entry     font_info;     /* font information          */
   IGRlong                num_obj;       /* num objects to display    */
   IGRlong                rc;            /* OM return code            */
   IGRlong                temp_msg;
   IGRlong                status;
   IGRmatrix              *matr[1];      /* matrix ptr for display    */
   IGRshort               i;             /* loop counter              */
   struct DPele_header    elem_buf;      /* buffer for display        */
   struct GRid            fontmgr_obj;   /* objid of font manager     */
   IGRuchar               *l_text_str;   /* local text string         */
   IGRshort               l_text_len;    /* local text length         */
   IGRshort               text_buf_size; /* amount of memory allocated
                                            for text string           */
   IGRint                 view_ind;      /* TRUE if view independent  */
                                         /* FALSE otherwise           */
   IGRint                 view_ind_type; /* type of view independence */
   IGRboolean             value;         /* return value              */

   status = MSSUCC;
   *msg = MSSUCC;   
   view_ind_type = 0;
   tx_attr.estx = &tx_sp_attr;

   num_obj = 1;              /* number of objects to display */

   /*
    *  get the objid of the font manager using its named object
    */

   ex$get_super(mod_id = ModuleInfo->md_id.objid,
                mod_osnum = ModuleInfo->md_id.osnum,
                super_name = FONTMGR_NO_NAME,
                create = TRUE,
                super_class = "GRfm",
                super_id = &fontmgr_obj.objid,
                super_osnum = &fontmgr_obj.osnum);

   /*
    * get information from the specified font
    */

   rc = om$send(mode = OM_e_wrt_object,
                msg = message GRfm.GRfm_retdata
                      (&temp_msg,&text_symb->Active_font,&font_info),
                senderid = NULL_OBJID,
                targetid = fontmgr_obj.objid,
                targetos = ModuleInfo->md_id.osnum);

   if (COERROR(rc))
   {
#ifdef DEBUG
      printf("COtexti.I err: GRfm.GRfm_retdata rc = %d\n",rc);
      om$report_error(sts = rc);
#endif
      goto wrapup;
   }
   else if (COERROR(temp_msg) && (temp_msg != MSINARG))
   {
#ifdef DEBUG
      printf("COtexti.I err: GRfm_retdata temp_msg = %d\n",temp_msg);
#endif
      goto wrapup;
   }

   l_text_len = *text_length;

   l_text_str = (IGRuchar *)om$malloc(size = l_text_len);

   if (l_text_str == 0)
   {
#ifdef DEBUG
      printf("error in malloc");
#endif
      status = MSFAIL;
      goto wrapup;              
   }

   OM_BLOCK_MOVE(text_string,l_text_str,l_text_len);

   text_buf_size = l_text_len;

   GRjust_string(&temp_msg,&l_text_str,&l_text_len,&text_buf_size,
                 &font_info,ActiveDisplay,text_symb,0,NULL,&new_extents);

   if (rot_matrix)
   {
       value = GRcreate_lbs(&temp_msg,ActiveAngle,rot_matrix,origin,
                            &new_extents,&lbs_geom);
   }
   else  /* lbs_matrix was specified */
   {
      for (i = 0; i < 16; ++i)
      {
         lbs_geom.matrix[i] = lbs_matrix[i];
      }

      lbs_geom.matrix[3]  = origin[0];
      lbs_geom.matrix[7]  = origin[1];
      lbs_geom.matrix[11] = origin[2];

      /* 
       *  Initialize extents (local range block diagonal points).
       */

      lbs_geom.diag_pt1[0] = new_extents.left;
      lbs_geom.diag_pt1[1] = new_extents.bottom;
      lbs_geom.diag_pt1[2] = 0;
      lbs_geom.diag_pt2[0] = new_extents.right;
      lbs_geom.diag_pt2[1] = new_extents.top;
      lbs_geom.diag_pt2[2] = 0;

      value = TRUE;
   }

   if (value)
   {
      /*
       * calculate number of displayable characters
       */

      GRnum_disp_char(&temp_msg,l_text_str,&l_text_len,text_symb->Active_font,
                      font_info.flags,&tx_attr.estx->num_char);

      /*
       * fill in text attributes
       */

      tx_attr.estx->font = text_symb->Active_font;
      tx_attr.estx->just = text_symb->Active_just;
      tx_attr.estx->width = text_symb->Active_width;
      tx_attr.estx->height = text_symb->Active_height;
      tx_attr.estx->line_spac = text_symb->Active_linespac;
      tx_attr.estx->char_spac = text_symb->Active_charspac;
      tx_attr.estx->text_length = l_text_len;
      tx_attr.estx->flag = 0;

      tx_attr.text_string = (IGRchar *)l_text_str;
      tx_attr.font_id = ModuleInfo->md_id.osnum;

      rc = dp$build_dis_buffer(buffer = &elem_buf,
                               type = IGRLB,
                               flags = ((text_symb->Active_flags & GRFILLED_TEXT) ? DPPOLY_FILL : 0),
                               display_att = ActiveDisplay,
                               ele_spec_att = &tx_attr,
                               geometry = &lbs_geom);

      if (!(rc & 1)) om$report_error(sts = rc);

      /*
       * if the text is to be view independent, set up the appropriate
       * arguments
       */

      if (*properties & GRIS_VIEW_INDEP)
      {
         view_ind = TRUE;
         view_ind_type = ROTATION_IND;
      }
      else
      {
         view_ind = FALSE;
      }

      /*
       * display object
       */

      matr[0] = (IGRmatrix *) ModuleInfo->md_env.matrix;

      rc = dp$display(msg = &temp_msg,
                      osnum = ModuleInfo->md_id.osnum,
                      objid = *win_objid,
                      mode = *mode,
                      buffer = &elem_buf,
                      num_elem = num_obj,
                      mtx_type = &ModuleInfo->md_env.matrix_type,
                      matrix = matr,
                      view_ind = view_ind,
                      view_ind_type = view_ind_type,
                      view_ind_point = origin);
 
      if (COERROR (rc))
      {
#ifdef DEBUG
          printf("COtexti.I err: dp$display  rc = %d\n",rc);
          om$report_error(sts = rc);
#endif
          goto wrapup;
      }
      else if (COERROR (temp_msg))
      {
#ifdef DEBUG
         printf("COtexti.I err: module.GRdisbyoid temp_msg = %d\n",temp_msg);
#endif
         goto wrapup;
      }
   }
   else
   {
#ifdef DEBUG
       printf("COtexti.I err: GRcreate_lbs temp_msg = %d\n",temp_msg);
#endif
   }             /* end GRcreate_lbs    */

   om$dealloc(ptr = l_text_str);

wrapup:
              
   /*
    *   Check for module or method error
    */

   if (COERROR (rc) || COERROR (temp_msg))
   {
      status = MSFAIL;
   }

   return(status);
}

end implementation GRtext;
