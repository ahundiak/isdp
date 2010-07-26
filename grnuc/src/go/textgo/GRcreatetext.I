/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     CLASS NAME   GRtext

     Abstract:    This function will create a text object given a 
               text string, text length, rotation matrix, an origin
               point, and "active parameters".
-----
%SC%
     Value = GRcreatetext(msg,text_string,text_length,origin,rot_matrix,
                          lbs_matrix,classname,ActiveDisplay,ActiveLevel,
                          ModuleInfo,text_symb,properties,ActiveAngle,mode,
                          win_objid,flags,buffer)
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
     *classname     IGRchar                 type of class to create
     *ActiveDisplay struct IGRdisplay       display parameters to use
     *ActiveLevel   IGRshort                level to place text on
     *ModuleInfo    struct GRmd_env         module environment
     *text_symb     struct GRdpb_text_symb  text symbology
     *properties    IGRushort               the object's graphic properties
                                            (displayable, locatable, etc.);
                                            #defines for these properties
                                            can be found in godef.h
     *ActiveAngle   IGRdouble               active angle
     *mode          GRdpmode                display mode
     *win_objid     GRobjid                 object id of window
     flags          IGRint                  miscellaneous flags
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     *message       IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *buffer        GRid            object id of constucted text

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

         om$get_classid:          - An OM macro that will return
                                    your classid from your
                                    classname.

         GRfindmod:               - Returns objid and OS of current
                                    active module.

         GRjust_string:           - Updates justification escape sequences
                                    in a string if necessary and returns
                                    extents of string

         om$construct:            - An OM macro used to construct an
                                    object by classid.

         GRcreate_lbs:            - A function that creates an internal
                                    form of a local bounded system
                                    geometry.

         GRnum_disp_char          - A function that determines the number
                                    of displayable characters in a text string.

         GRfm.GRfm_retdata:      - This message will return information
                                    about the specified font.

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
        
        DEK  10/16/86 : Design date.
        DEK  10/16/86 : Creation date.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

    This method will create a text object given a text string, text
length, rotation matrix, an origin point, and "active parameters".

----*/
/*EH*/

class implementation GRtext;

#include   "msdef.h"
#include   "exmacros.h"
#include   "fontdef.h"
#include   "font.h"
#include   "gotextdef.h"
#include   "gotext.h"
#include   "dpmacros.h"
#include   "grdpbdef.h"
#include   "grdpb.h"
#include   "codef.h"
#include   "OMmacros.h"
#include   "grimport.h"

from GRfm       import GRfm_retdata;

IGRint GRcreatetext (msg,text_string,text_length,origin,rot_matrix,lbs_matrix,
                     classname,ActiveDisplay,ActiveLevel,ModuleInfo,
                     text_symb,properties,ActiveAngle,mode,win_objid,flags,
                     buffer)

IGRlong                 *msg;           /* completion code                */
IGRuchar                *text_string;   /* text string                    */
IGRshort                *text_length;   /* length of text string          */
IGRpoint                origin;         /* origin point for string        */
IGRdouble               *rot_matrix;    /* view rotation matrix           */
IGRdouble               *lbs_matrix;    /* local bounded system matrix    */
IGRchar                 *classname;     /* type of class to create        */
struct IGRdisplay       *ActiveDisplay; /* active display parameters      */
IGRshort                *ActiveLevel;   /* level to place text on         */
struct GRmd_env         *ModuleInfo;    /* module environment info.       */
struct GRdpb_text_symb  *text_symb;     /* text symbology parameters      */
IGRushort               *properties;    /* graphic properties             */
IGRdouble               *ActiveAngle;   /* active angle                   */
enum GRdpmode           *mode;          /* display mode                   */
GRobjid                 *win_objid;     /* window(s) to display text      */
IGRint                  flags;          /* miscellaneous flags
                                          (defined in gotextdef.h):
                                          bit 0: 1 - display,
                                                 0 - no display       
                                          bit 1: 1 - empty text,
                                                 0 - non-empty text       */
struct GRid             *buffer;        /* objid and osnum of text obj    */
{

   extern IGRboolean GRcreate_lbs();   /* creates (initializes) the local
                                          bounded system geometry           */
   extern IGRboolean GRjust_string();  /* justifies text string (inserts or
                                          deletes justifications moves) and
                                          returns the extents               */

   struct GRvg_construct  cnst_lis;      /* construction list       */
   struct IGRlbsys        lbs_geom;      /* local bounded system geo*/
   struct IGResintx       tx_attr;       /* cnst text specific attr */
   struct IGRestx         tx_sp_attr;    /* text specific attributes*/
   struct extents         new_extents;
   struct vfont_entry     font_info;     /* font information        */
   GRclassid              classid;       /* classid of object       */
   IGRlong                cnst_lis_msg;  /* return msg from cnst    */
   IGRlong                num_obj;       /* num objects to display  */
   IGRlong                rc;            /* OM return code          */
   IGRlong                temp_msg;
   IGRlong                status;
   IGRmatrix              *matr[1];      /* matrix ptr for display  */
   IGRshort               i;             /* loop counter            */
   IGRshort               flag;
   struct GRid            fontmgr_obj;   /* objid of font manager   */
   IGRuchar               *l_text_str;   /* local text string       */
   IGRshort               l_text_len;    /* local text length       */
   IGRshort               text_buf_size; /* amount of memory allocated
                                            for text string         */
   IGRboolean             value;         /* return value            */

   status = MSSUCC;           /* initialize to success */
   *msg = MSSUCC;

    l_text_str = NULL;

    /* 
     * get classid from classname
     */

    rc = om$get_classid(classname = classname,
                        p_classid = &classid);

    if (!COERROR (rc))
    {
        /*
         * hard code the following construction variables
         */

        cnst_lis.newflag = 0;
        cnst_lis.name = NULL;
        cnst_lis.properties = *properties;

        if (text_symb->Active_flags & GRFILLED_TEXT)
        {
            cnst_lis.properties |= GRFILLED_DISPLAY;
        }
        else  /* clear the filled display bit */
        {
            cnst_lis.properties &= ~GRFILLED_DISPLAY;
        }

        cnst_lis.display = ActiveDisplay;
        cnst_lis.msg = &cnst_lis_msg;
        cnst_lis.env_info = ModuleInfo;
        cnst_lis.class_attr = (IGRchar *)&tx_attr;
        tx_attr.estx = &tx_sp_attr;
        cnst_lis.geometry = (IGRchar *)&lbs_geom;
        cnst_lis.level = *ActiveLevel;

        num_obj = 1;              /* number of objects to display */
        rc = OM_S_SUCCESS;

        if (flags & GRTX_EMPTY)
        {
           flag = EMPTY_TEXT_FLAG;
        }
        else
        {
           flag = 0;
        }

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
         * get specified font information
         */

        rc = om$send(mode = OM_e_wrt_object,
                     msg = message GRfm.GRfm_retdata
                               (&temp_msg,&text_symb->Active_font,
                                &font_info),
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

        if (l_text_len)
        {
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
        }

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

           GRnum_disp_char(&temp_msg,l_text_str,&l_text_len,
                           text_symb->Active_font,font_info.flags,
                           &tx_attr.estx->num_char);

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
           tx_attr.text_string = (IGRchar *)l_text_str;
           tx_attr.estx->flag = flag;

           /*
            * construct object by classid
            */

           rc = om$construct(osnum = ModuleInfo->md_id.osnum,
                             classid = classid,
                             p_objid = &(buffer->objid),
                             msg = message GRgraphics.GRconstruct(&cnst_lis),
                             neighbor = OM_GS_NULL_NEIGHBOR);

           if (COERROR (rc))
           {
#ifdef DEBUG
              printf("COtexti.I err: OM_construct_object_by_classid rc = %d\n", rc);
              om$report_error(sts = rc);
#endif
              goto wrapup;
           }

           buffer->osnum = ModuleInfo->md_id.osnum;

           if (flags & GRTX_DISPLAY)
           {
              /*
               * display object
               */

              matr[0] = (IGRmatrix *) ModuleInfo->md_env.matrix;

              rc = dp$display(msg = &temp_msg,
                              osnum = ModuleInfo->md_id.osnum,
                              objid = *win_objid,
                              mode = *mode,
                              oids = buffer,
                              num_elem = num_obj,
                              mtx_type = &ModuleInfo->md_env.matrix_type,
                              matrix = matr);
    
              if (COERROR (rc))
              {
   #ifdef DEBUG
                  printf("COtexti.I err: module.GRdisbyoid rc = %d\n",rc);
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
           }         /* end if display */
        }
        else
        {
#ifdef DEBUG
            printf("COtexti.I err: GRcreate_lbs temp_msg = %d\n",temp_msg);
#endif
        }             /* end GRcreate_lbs    */

        if (l_text_str) om$dealloc(ptr = l_text_str);

wrapup:
              
       /*
        *   Check for module or method error
        */

       if (COERROR (rc) || COERROR (temp_msg))
       {
          status = MSFAIL;
       }
    }
    else
    {
#ifdef DEBUG
        printf("COtexti.I err: OM_get_classid_from_name rc = %d\n",rc);
        om$report_error(sts = rc);
#endif
        status = MSFAIL;
    }    

    return(status);
}

end implementation GRtext;

