/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION
----
%HD%
     CLASS NAME:    COedittext

     METHOD NAMES:  execute

     Abstract:  This method implements the edit text
                command, operating on text objects.
----
%MD%
     MODULES AND METHODS INVOKED:

     Modules:
                GRfwd_esc_seq
                GRchar_pos_info
     Methods:
----
%RL%
     RELATIONS REFERENCED:

----
%UI%
     USER INTERFACE DESCRIPTION:

----
%NB%
     NOTES:

----
%CH%
     CHANGE HISTORY:

     WBC  9/08/86:   Design date.
     WBC  9/08/86:   Creation date.
     DEK  9/29/86:   Convert to OM 4.0
     DEK 10/16/86:   Changes for keyboard processer.
     DEK  4/14/87:   Added sends for text field box.
     jjm  3/10/93:   Added pre_sleep method
     scw 08/09/94:   Clarified sleep method
----
%PD%
     PROGRAM DESCRIPTION:


     Method Name: method execute

     Method Description: The execute method prompts for and collects
                         user input, using that input to invoke
                         methods & functions as required to locate & edit
                         a text object.

----*/
/*EH*/

class implementation COedittext;

#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "exmacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "igrdef.h"
#include "codef.h"
#include "grdpbmacros.h"
#include "OMmacros.h"
#include "lcdef.h"
#include "lcmacros.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "DIdef.h"
#include "DItypedef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "madef.h"
#include "fontmacros.h"

from GRgraphics import GRdisplay, GRgetprops;
from GRvg       import GRgetgeom, GRpostabsg, GRgetsymb;
from GRtext     import GRgettxattr, GRreplace_text, GRchange_flag;
from GRfm       import GRfm_retdata;
from GRowner    import GRxform_owner;

/*
 *#define DEBUG
 */

#define  AT_START    0
#define  AT_LOC_OBJ  1

/*---------------------------------------------------------------*/
/*                    method COinit                              */
/*---------------------------------------------------------------*/

method init(IGRint type; IGRchar *str_ptr)
{

#ifdef DEBUG
    printf("Init method.\n");
#endif

    me->mytype = type;
    me^^COedittext.text_buf_size = 0;
    me^^COedittext.text_string = NULL;

    /*
     * set up parameters for status display?
     * in the future?
     */

    /* 
     * get classid from classname
     */

    om$get_classid(classname = "GRtext",
                   p_classid = &me^^COedittext.classid);

    /*
     *  Initialization
     */

    me^^COedittext.attr.properties = LC_WRITE_ONLY | LC_LC_ONLY | LC_DP_ONLY;

    /*
     * 1.2.0 KLUDGE: ORing owner_action with 4096 is a temporary solution for a
     * problem with locating rigid components for dimensioning text.  This
     * kludge will be taken out during some post 1.2.0 platform.
     */

    me^^COedittext.attr.owner_action = (LC_FLEX_COMP | 4096);
    me^^COedittext.locate_stack.num_entries = 0;
    me^^super_cmd.state = AT_START;
    me^^COedittext.cc_info.field_delim = 0;
    me^^COedittext.text_attr.estx = &me^^COedittext.tx_attr;
    me^^COedittext.cc_info.flags = 0;
    me^^COedittext.eligible_classes.w_count = 1;
    me^^COedittext.eligible_classes.w_flags = OM_CLST_subclass;
    me^^COedittext.eligible_classes.p_classes = &me^^COedittext.classid;

    /*
     *  build a display buffer for the text string to be erased
     */

    dp$build_dis_buffer(buffer = &me^^COedittext.ele_header,
                        type = IGRLB,
                        level = &me^^COedittext.level,
                        display_att = &me^^COedittext.disp_attr,
                        ele_spec_att = &me^^COedittext.text_attr,
                        geometry = &me^^COedittext.lbs_geom);

    me^^COedittext.text_attr.estx = &me^^COedittext.tx_attr;
    me^^COedittext.text_attr.just_moves[0] = ESC;
    me^^COedittext.text_attr.just_moves[1] = 'j';
    me^^COedittext.text_attr.just_moves[10] = ESC;
    me^^COedittext.text_attr.just_moves[11] = 'h';

    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method pre_sleep                        */
/*---------------------------------------------------------------*/

method pre_sleep(int (**dyn_function)();char **additional_info)
{
   *additional_info = "Edit Text";
}

/*---------------------------------------------------------------*/
/*                       method COsleep                          */
/*---------------------------------------------------------------*/

method super_cmd.sleep(IGRint pos)
{
    IGRlong     msg;            /* function return code                  */

# ifdef DEBUG
     printf("Sleep method.\n");
# endif

    ex$message(field = MESSAGE_FIELD,
               in_buff = "");
    ex$message(field = PROMPT_FIELD,
               in_buff = "");
    ex$message(field = ERROR_FIELD,
               in_buff = "");

    /*
     * erase the cursor and field box
     */

    dp$erase_hilite(msg = &msg);

    if (COERROR(msg))
    {
#ifdef DEBUG
        printf("COedittexti.I err: dp$erase_hilite msg = %d\n",msg);
#endif
    }

    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COdelete                         */
/*---------------------------------------------------------------*/

method delete(IGRint f_defer_flag)
{
    IGRlong                 status;  /* return status      */

# ifdef DEBUG
     printf("Delete method.\n");
# endif

    /*
     *  if memory has been allocated for a text string, deallocate it
     */

    if (me^^COedittext.text_string)
    {
        om$dealloc(ptr = me^^COedittext.text_string);
    }

    status = om$send(mode = OM_e_wrt_message,
                     msg = message COroot.delete(f_defer_flag),
                     targetid = my_id);

    if (COERROR(status))
    {
#ifdef DEBUG
        printf("COedittexti.I error:  COroot.delete status = %d\n",status);
#endif
    }

    return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------*/
/*                       method COwakeup                         */
/*---------------------------------------------------------------*/

method wakeup(IGRint pos)
{
    IGRlong     msg;            /* function return code */
    IGRlong     nbytes_in_buffer;
    IGRlong     nbytes_transferred;
    IGRint      status;         /* return status        */

#ifdef DEBUG
    printf("Wakeup method.\n");
#endif

    ex$message(field = PROMPT_FIELD,
               in_buff = "");
    ex$message(field = ERROR_FIELD,
               in_buff = "");

    if (me->mytype == 0)
    {
        ex$message(msgnumb = GRC_M_EdtTxt);
    }
    else
    {
        ex$message(msgnumb = GRC_M_ReplTx);
    }
    nbytes_in_buffer = sizeof(me^^COedittext.text_symb);
    status = gr$get_text_symb(msg = &msg,
                              sizbuf = &nbytes_in_buffer,
                              buffer = &me^^COedittext.text_symb,
                              nret = &nbytes_transferred);

    if (COERROR(status) || COERROR(msg))
    {
#ifdef DEBUG
        printf("COedittexti.I error:  gr$get_text_symb status = %d\n",status);
#endif
    }

    /*
     * if an object has been located, find out its current attributes - they may
     * have been changed while this command was asleep (e.g. color, font, etc.)
     */

    if (me^^super_cmd.state == AT_LOC_OBJ)
    {
        IGRlong            om_msg;
        GRspacenum         cur_mod_osnum; /* current module object space # */
        OM_S_OBJID         cur_mod_id;    /* current module's objid        */
        struct GRsymbology symb;          /* symbology structure           */
        struct GRid        fontmgr_obj;   /* font manager object           */

        om_msg = om$send(mode = OM_e_wrt_object,
                         msg = message GRgraphics.GRgetprops
                                           (&msg,&me^^COedittext.properties),
                         senderid = my_id,
                         targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                         targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

        if (1 & om_msg & msg)
        {
            /*
             * if the text object is fillable, set the appropriate flag
             * in the display structure
             */

            if (me^^COedittext.properties & GRFILLED_DISPLAY)
            {
                me^^COedittext.ele_header.flags = DPPOLY_FILL;
            }
            else  /* text isn't fillable; clear the display flag */
            {
                me^^COedittext.ele_header.flags = 0;
            }

            om_msg = om$send(mode = OM_e_wrt_object,
                             msg = message GRtext.GRgettxattr
                                   (&msg,&me^^COedittext.tx_attr,NULL,NULL),
                             senderid = my_id,
                             targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                             targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

            if (1 & om_msg & msg)
            {
                /*
                 *  get the objid of the font manager using
                 *  its named object
                 */

                ex$get_cur_mod(id = &cur_mod_id,
                               osnum = &cur_mod_osnum);

                ex$get_super(mod_id = cur_mod_id,
                             mod_osnum = cur_mod_osnum,
                             super_name = FONTMGR_NO_NAME,
                             create = TRUE,
                             super_class = "GRfm",
                             super_id = &fontmgr_obj.objid,
                             super_osnum = &fontmgr_obj.osnum);

                /*
                 * get address block of specified font
                 */

                om_msg = om$send(mode = OM_e_wrt_object,
                                 msg = message GRfm.GRfm_retdata
                                       (&msg,&me^^COedittext.tx_attr.font,
                                        &me^^COedittext.font_info),
                                 senderid = my_id,
                                 targetid = fontmgr_obj.objid,
                                 targetos = cur_mod_osnum);

                if (1 & om_msg & msg)
                {
                    /*
                     *  find the level and display attributes of the located
                     *  text object
                     */

                    om_msg = om$send(mode = OM_e_wrt_object,
                                     msg = message GRvg.GRgetsymb(&msg,&symb),
                                     senderid = my_id,
                                     targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                     targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                    if (1 & om_msg & msg)
                    {
                        me^^COedittext.level = symb.level;
                        me^^COedittext.disp_attr = symb.display_attr;

                        /*
                         * find the current position in the text string
                         */

                        GRchar_pos_info(&msg,me^^COedittext.text_string,
                                        me^^COedittext.cc_info.cur_char_index,
                                        FALSE,&me^^COedittext.tx_attr,
                                        &me^^COedittext.font_info,
                                        &me^^COedittext.disp_attr,
                                        &me^^COedittext.cc_info);
                    }
                    else
                    {
#ifdef DEBUG
                        printf("COedittext_wakeup: Error: GRvg.GRgetsymb\n");
#endif
                    }
                }
                else
                {
#ifdef DEBUG
                    printf("COedittext_wakeup: Error: GRfm.GRfm_retdata\n");
#endif
                }
            }
            else
            {
#ifdef DEBUG
                printf("COedittext_wakeup: Error: GRtext.GRgettxattr\n");
#endif
            }
        }
        else
        {
#ifdef DEBUG
            printf("COedittext_wakeup: Error: GRgraphics.GRgetprops\n");
#endif
        }
    }

    return(OM_S_SUCCESS);
}

/*------------------------------------------------------------------*/
/*                             execute                              */
/*------------------------------------------------------------------*/

method execute(IGRint *response;
               IGRchar *response_data;
               IGRint  pos)
{
    extern IGRshort    GRfwd_esc_seq();
                                /* finds the number of characters in a   */
                                /* single or several escape sequence(s)  */
    IGRshort    num_chars;      /* # of chars. in the escape sequence(s) */
    IGRshort    temp_index;     /* index of char in text string          */
    IGRshort    line_mode = 0;  /* which type of line to draw            */
    IGRshort    keyin_length;   /* # bytes of consecutive input chars    */
    IGRshort    matrix_type;
    IGRshort    prev_font;
    IGRshort    current_font;
    IGRshort    tmp_short;
    IGRboolean  exit;           /* Boolean to control when to exit       */
    IGRboolean  multi_mode;     /* find # of chars. in single or several */
                                /* consecutive escape sequences          */
    struct IGResintx text_info; /* text information                      */
    struct GRevent     event;   /* event from co$getevent                */
    struct GRevent   loc_event; /* locate event from lc$locate           */
    struct GRsymbology symb;    /* symbology structure                   */
    struct vfont_entry font_info;
    IGRmatrix   matrix;
    IGRint      status;         /* routine return status                 */
    IGRint      size;           /* sizeof a structure                    */
    IGRint      i;
    IGRint      nbytes;         /* # of bytes returned in response_data  */
    IGRint      resp_type;      /* response type                         */
    IGRlong     display_flag;   /* display flag for locate filter        */
    IGRlong     identify_mask;  /* element location mask for lc$locate   */
    IGRlong     accept_mask;    /* element accept mask for lc$locate     */
    IGRlong     mask;           /* input mask for co$getevent            */
    IGRlong     om_msg;         /* OM return code                        */
    IGRlong     msg;            /* function return code                  */
    IGRlong     nbytes_returned;
    IGRlong     nbytes_transferred;
    IGRmatrix   *matr[1];       /* matrix ptr for display                */
    enum    GRdpmode   dpmode;  /* display mode                          */
    struct GRid fontmgr_obj;    /* font manager object                   */
    GRobjid     new_objid;      /* objid of the text element             */
    GRspacenum  cur_mod_osnum;  /* current module object space number    */
    OM_S_OBJID  cur_mod_id;     /* current module's objid                */
    struct  GRmd_env   locate_env;
    IGRchar     *keyin_string;  /* consecutive EX_STRING input chars     */
    IGRchar 	*input_ptr = NULL;/* input chars                    */
    IGRchar     text_name[DI_PATH_MAX];
    IGRpoint    proj_pnt;       /* locate point projected onto text plane*/
    IGRdouble   tparam;
    IGRpoint    view_ind_point; /* point text is view independent about  */
    IGRint      init_edit;      /* TRUE if first time calling GRedit_text*/
    IGRint      view_ind;       /* TRUE if text is view independent      */
    IGRint      view_ind_type;  /* type of view idependence              */
    OM_S_CHANSELECT owner_chan; /* owner channel selector                */

#ifdef DEBUG
    printf("COedittext_execute_method\n");
#endif

    /*
     *  Initialization
     */

    exit = FALSE;
    identify_mask = GRm_DATA | GRm_TEXT_VALUE | GRm_RESET;
    mask = GRm_DATA | GRm_CHAR | GRm_STRING | GRm_RESET;
    accept_mask = GRm_DATA;
    display_flag = 1;
    size = sizeof(struct GRevent);
    keyin_string = NULL;
    init_edit = FALSE;

    ex$get_cur_mod(id = &cur_mod_id,
                   osnum = &cur_mod_osnum);

    /*
     *  must find the geometry of the located text object in case the text
     *  was moved while the command was suspended
     */

    if (me^^super_cmd.state == AT_LOC_OBJ)
    {
        om_msg = om$send(mode = OM_e_wrt_object,
                         msg = message GRvg.GRgetgeom(&msg,
                               &me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix_type,
                               me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix,
                               (IGRchar *)&me^^COedittext.lbs_geom),
                         senderid = my_id,
                         targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                         targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

        if (COERROR(om_msg))
        {
#ifdef DEBUG
            printf("COedittexti.I err: GRvg.GRgetgeom om_msg = %d\n",om_msg);
            om$report_error(sts = om_msg);
#endif
        }
        else if (COERROR(msg))
        {
#ifdef DEBUG
            printf("COedittexti.I err: GRvg.GRgetgeom msg = %d\n",msg);
#endif
        }

        /*
         *  if the located text object is empty, erase it and set
         *  text length to zero
         */

        if (me^^COedittext.tx_attr.flag & EMPTY_TEXT_FLAG)
        {
           matr[0] = (IGRmatrix *)me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix;

           /*
            * if the located text object is view independent, must initialize
            * info for display
            */

           if (me^^COedittext.properties & GRIS_VIEW_INDEP)
           {
              view_ind = TRUE;
              view_ind_type = ROTATION_IND;
              view_ind_point[0] = me^^COedittext.lbs_geom.matrix[3];
              view_ind_point[1] = me^^COedittext.lbs_geom.matrix[7];
              view_ind_point[2] = me^^COedittext.lbs_geom.matrix[11];
           }
           else
           {
              view_ind = FALSE;
           }

           status = dp$display(msg = &msg,
                               osnum = cur_mod_osnum,
                               mode = GRbe,
                               oids = &me^^COedittext.grevent1.located_object[0].located_obj,
                               mtx_type = &me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix_type,
                               matrix = matr,
                               view_ind = view_ind,
                               view_ind_type = view_ind_type,
                               view_ind_point = view_ind_point);

            if (! (1 & status & msg))
            {
#ifdef DEBUG
                printf("COedittext_execute: Error: dp$display\n");
#endif
            }

            me^^COedittext.tx_attr.text_length = 0;
        }
    }

    /*
     *  loop until exit condition occurs
     */

    while (!exit)
    {
        /*
         *  need to locate a text object to edit
         */

        if (me^^super_cmd.state == AT_START)
        {
            /*
             *  call locate filter to locate an object
             */

            nbytes_returned = sizeof(struct GRmd_env);

            gr$get_locate_env(msg = &msg,
                              sizbuf = &nbytes_returned,
                              buffer = &locate_env,
                              nret = &nbytes_transferred);

            status = lc$locate(rc = &msg,
                               event1 = &loc_event,
                               event2 = &me^^COedittext.grevent1,
                               mask1 = identify_mask,
                               mask2 = accept_mask,
                               eventsize = &size,
                               display_flag = display_flag,
                               locate_key = GR_P_IdEle,
                               acc_key = GR_P_Acc,
                               relocate_key = GR_E_EleNotFnd,
                               attributes = &me^^COedittext.attr,
                               stack = &me^^COedittext.locate_stack,
                               eligible_classes = &me^^COedittext.eligible_classes);

            if (!status)
            {
#ifdef DEBUG
                printf("COedittext_execute: Error: COlclocate\n");
#endif
            }
            else if (msg)
            {
                /*
                 * object has been located; this is the first time
                 * it will be editted
                 */

                init_edit = TRUE;

                /*
                 * find out if the text object is view independent or not
                 */

                om_msg = om$send(mode = OM_e_wrt_object,
                                 msg = message GRgraphics.GRgetprops
                                       (&msg,&me^^COedittext.properties),
                                 senderid = my_id,
                                 targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                 targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                if (!(1 & om_msg & msg))
                {
#ifdef DEBUG
                    printf("COedittext_execute: Error: GRgraphics.GRgetprops\n");
#endif
                }

                /*
                 * if the text object is fillable, set the appropriate flag
                 * in the display structure
                 */

                if (me^^COedittext.properties & GRFILLED_DISPLAY)
                {
                    me^^COedittext.ele_header.flags = DPPOLY_FILL;
                }
                else  /* text isn't fillable; clear the display flag */
                {
                    me^^COedittext.ele_header.flags = 0;
                }

                /*
                 *  erase the highlighted text element and clear the 
                 *  edit text bits in the edit text flag
                 */
        
                dp$erase_hilite(msg = &msg);
                me^^COedittext.cc_info.flags &= 0xff20;
                me^^COedittext.cc_info.field_position = 0;
                me^^COedittext.cc_info.field_delim = 0;

                /*
                 * get the attributes and the text string of the text object;
                 * if memory has previously been allocated, delete it since
                 * GRgettxattr will allocate memory for the text string
                 */

                if (me^^COedittext.text_string)
                {
                   om$dealloc(ptr = me^^COedittext.text_string);
                   me^^COedittext.text_buf_size = 0;
                }

                om_msg = om$send(mode = OM_e_wrt_object,
                                 msg = message GRtext.GRgettxattr
                                       (&msg,&me^^COedittext.tx_attr,NULL,
                                        &me^^COedittext.text_string),
                                 senderid = my_id,
                                 targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                 targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                if (1 & om_msg & msg)
                {
                   /*
                    * # of bytes allocated is same as text length
                    */

                   me^^COedittext.text_buf_size = me^^COedittext.tx_attr.text_length;

                   /*
                    * if this is replace text or the located text object is
                    * empty, erase it and set text length to zero
                    */

                   if ((me->mytype) ||
                       (me^^COedittext.tx_attr.flag & EMPTY_TEXT_FLAG))
                   {
                      matr[0] = (IGRmatrix *)me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix;

                      /*
                       * if the located text object is view independent, must
                       * initialize info for display
                       */

                      if (me^^COedittext.properties & GRIS_VIEW_INDEP)
                      {
                         view_ind = TRUE;
                         view_ind_type = ROTATION_IND;
                         view_ind_point[0] = me^^COedittext.lbs_geom.matrix[3];
                         view_ind_point[1] = me^^COedittext.lbs_geom.matrix[7];
                         view_ind_point[2] = me^^COedittext.lbs_geom.matrix[11];
                      }
                      else
                      {
                         view_ind = FALSE;
                      }

                      status = dp$display(msg = &msg,
                                          osnum = cur_mod_osnum,
                                          mode = GRbe,
                                          oids = &me^^COedittext.grevent1.located_object[0].located_obj,
                                          mtx_type = &me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix_type,
                                          matrix = matr,
                                          view_ind = view_ind,
                                          view_ind_type = view_ind_type,
                                          view_ind_point = view_ind_point);

                       if (! (1 & status & msg))
                       {
#ifdef DEBUG
                           printf("COedittext_execute: Error: dp$display\n");
#endif
                       }

                       me^^COedittext.tx_attr.text_length = 0;
                   }

                   /*
                    *  if memory has not been allocated for the text
                    *  string, allocate some so subsequent calls to
                    *  om$realloc will work
                    */

                   if (me^^COedittext.text_buf_size == 0)
                   {
                        me^^COedittext.text_string = (IGRuchar *)om$malloc(
                         size = TEXT_BUF_SIZE);
                        me^^COedittext.text_buf_size = TEXT_BUF_SIZE;
                   }
                }
                else
                {
#ifdef DEBUG
                    printf("COedittext_execute: Error: GRtext.GRgettxattr\n");
#endif
                }

                /*
                 *  get the objid of the font manager using
                 *  its named object
                 */

                ex$get_super(mod_id = cur_mod_id,
                             mod_osnum = cur_mod_osnum,
                             super_name = FONTMGR_NO_NAME,
                             create = TRUE,
                             super_class = "GRfm",
                             super_id = &fontmgr_obj.objid,
                             super_osnum = &fontmgr_obj.osnum);

                /*
                 * get address block of specified font
                 */

                om_msg = om$send(mode = OM_e_wrt_object,
                                 msg = message GRfm.GRfm_retdata
                                       (&msg,&me^^COedittext.tx_attr.font,
                                        &me^^COedittext.font_info),
                                 senderid = my_id,
                                 targetid = fontmgr_obj.objid,
                                 targetos = cur_mod_osnum);

                if (COERROR(om_msg))
                {
#ifdef DEBUG
                    printf("COedittexti.I err: GRfm.GRfm_retdata om_msg = %d\n",om_msg);
                    om$report_error(sts = om_msg);
#endif
                }
                else if (COERROR(msg))
                {
#ifdef DEBUG
                    printf("COedittexti.I err: GRfm_retdata msg = %d\n",msg);
#endif
                }

                /* get geometry of the local bounded system   */

                om_msg = om$send(mode = OM_e_wrt_object,
                                 msg = message GRvg.GRgetgeom(&msg,
                                       &me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix_type,
                                       me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix,
                                       (IGRchar *)&me^^COedittext.lbs_geom),
                                 senderid = my_id,
                                 targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                 targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                if (COERROR(om_msg))
                {
#ifdef DEBUG
                    printf("COedittexti.I err: GRvg.GRgetgeom om_msg = %d\n",om_msg);
                    om$report_error(sts = om_msg);
#endif
                }
                else if (COERROR(msg))
                {
#ifdef DEBUG
                    printf("COedittexti.I err: GRvg.GRgetgeom msg = %d\n",msg);
#endif
                }

                /*
                 *  find the level and display attributes of the located
                 *  text object
                 */

                om_msg = om$send(mode = OM_e_wrt_object,
                                 msg = message GRvg.GRgetsymb(&msg,&symb),
                                 senderid = my_id,
                                 targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                 targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                if (COERROR(om_msg))
                {
#ifdef DEBUG
                    printf("COedittexti.I err: GRvg.GRgetsymb om_msg = %d\n",om_msg);
                    om$report_error(sts = om_msg);
#endif
                }
                else if (COERROR(msg))
                {
#ifdef DEBUG
                    printf("COedittexti.I err: GRvg.GRgetsymb msg = %d\n",msg);
#endif
                }
                me^^COedittext.level = symb.level;
                me^^COedittext.disp_attr = symb.display_attr;

                /*
                 * if the located text object is view independent, position
                 * the cursor at the beginning of the text string
                 * (dp$get_closest_char doesn't work with view independent
                 * text); otherwise use the accept point to determine the
                 * starting cursor position
                 */

                if (me^^COedittext.properties & GRIS_VIEW_INDEP)
                {
                   /*
                    * must move past stroke start escape sequences, if any,
                    * at the beginning of the text string since they are
                    * not valid cursor positions
                    */

                   multi_mode = FALSE;
                   i = 0;

                   while (GRfwd_esc_seq(&msg,
                                        me^^COedittext.text_string,
                                        &me^^COedittext.tx_attr.text_length,
                                        &multi_mode,&i,&num_chars) &&
                          ((me^^COedittext.text_string[i + 1] == 'j') ||
                           (me^^COedittext.text_string[i + 1] == 'J')))
                   {
                      i += num_chars;
                   }
                }
                else
                {
                   /*
                    *  project the locate data point onto the plane defined by
                    *  text element and adjust the cursor position accordingly
                    */

                   GRlbsplapproj(&msg,&me^^COedittext.lbs_geom,
                                 &me^^COedittext.grevent1.event.button,
                                 proj_pnt,&tparam);


                   /*
                    * position the cursor under the character indicated
                    * by the locate point; have to temporarily increment
                    * the text length and insert a change font esc seq and
                    * a blank char so the positon after the last char in the
                    * text string may be selected (the change font is used
                    * in case last char in string is a 16 bit char); make sure
                    * enough memory is available for the 'extra' chars;
                    * also make sure the text length does not exceed the
                    * maximum text length, which is limited to a signed short's
                    * greatest positive number
                    */

                   tmp_short = me^^COedittext.tx_attr.text_length + 5;

                   if (tmp_short >= 0)
                   {
                      me^^COedittext.tx_attr.text_length = tmp_short;

                      if (me^^COedittext.tx_attr.text_length > me^^COedittext.text_buf_size)
                      {
                          me^^COedittext.text_string = (IGRuchar *)om$realloc(
                                        ptr = (char *)me^^COedittext.text_string,
                                        size = (OMuint)me^^COedittext.tx_attr.text_length);

                          me^^COedittext.text_buf_size = me^^COedittext.tx_attr.text_length;
                      }

                      me^^COedittext.text_string[me^^COedittext.tx_attr.text_length - 5] = ESC;
                      me^^COedittext.text_string[me^^COedittext.tx_attr.text_length - 4] = 'f';
                      OM_BLOCK_MOVE(&me^^COedittext.text_symb.Active_ascii_font,
                                    &(me^^COedittext.text_string[me^^COedittext.tx_attr.text_length - 3]),
                                    2);
                      me^^COedittext.text_string[me^^COedittext.tx_attr.text_length - 1] = BLANK;
                   }

                   text_info.estx = &me^^COedittext.tx_attr;
                   text_info.font_id = cur_mod_osnum;
                   text_info.text_string = (IGRchar *) me^^COedittext.text_string;
                   text_info.prev_font = -1;
                   text_info.flags = 0;

                   status = dp$get_closest_char(msg = &msg,
                                                lbsys = &me^^COedittext.lbs_geom,
                                                txt_ele = &text_info,
                                                osnum = cur_mod_osnum,
                                                mod_objid = cur_mod_id,
                                                point = proj_pnt,
                                                which_char = &i);

                   me^^COedittext.tx_attr.text_length -= 5;

                   /*
                    * since a change font and a blank were added to the end of
                    * of the text string, the index returned may be greater
                    * than the text length - if so, set the index to text
                    * length
                    */

                   if (i > me^^COedittext.tx_attr.text_length)
                   {
                      i = me^^COedittext.tx_attr.text_length;
                   }
                }

                /*
                 *  find position info about the char the cursor is to be
                 *  displayed under
                 */

                me^^COedittext.cc_info.cur_char_index = 0;

                GRvalid_cursor_position(&msg,me^^COedittext.text_string,
                                        me^^COedittext.tx_attr.text_length,
                                        -1,me^^COedittext.tx_attr.font,
                                        me^^COedittext.font_info.flags,i,
                                        &me^^COedittext.cc_info.cur_char_index);
                GRchar_pos_info(&msg,me^^COedittext.text_string,
                                me^^COedittext.cc_info.cur_char_index,
                                FALSE,&me^^COedittext.tx_attr,
                                &me^^COedittext.font_info,
                                &me^^COedittext.disp_attr,
                                &me^^COedittext.cc_info);

                /*
                 *  find the number of lines in the text string
                 */

                me^^COedittext.num_lines = 1;
                multi_mode = FALSE;
                i = 0;
                prev_font = -1;
                current_font = me^^COedittext.tx_attr.font;
                font_info = me^^COedittext.font_info;

                while (i < me^^COedittext.tx_attr.text_length)
                {
                    if (GRfwd_esc_seq(&msg,me^^COedittext.text_string,
                                      &me^^COedittext.tx_attr.text_length,
                                      &multi_mode,&i,&num_chars))
                    {
                        /*
                         * if changing (or popping) to a different font,
                         * find the font_info of the new font
                         */

                        if (me^^COedittext.text_string[i + 1] == 'f')
                        {
                            prev_font = current_font;

                            OM_BLOCK_MOVE(&me^^COedittext.text_string[i + 2],
                                          &current_font,2);

                            font$get_info(msg = &msg,
                                          font_num = &current_font,
                                          font_info = &font_info);
                        }
                        else if ((me^^COedittext.text_string[i + 1] == 'p') &&
                                 (me^^COedittext.text_string[i + 2] & POP_FONT))
                        {
                            if (prev_font != -1)
                            {
                                current_font = prev_font;

                                font$get_info(msg = &msg,
                                              font_num = &current_font,
                                              font_info = &font_info);
                            }
                        }
                        i += num_chars;
                    }
                    else if (me^^COedittext.text_string[i] == ESC)
                    {
                        if (me^^COedittext.text_string[i + 1] == LINEFEED)
                        {
                            ++me^^COedittext.num_lines;
                        }
                        i += 2;
                    }
                    else if (font_info.flags & SIXTEEN_BIT)
                    {
                        i += 2;
                    }
                    else /* seven or eight bit char */
                    {
                        ++i;
                    }
                }
                me^^super_cmd.state = AT_LOC_OBJ;
            }
            else if (me^^COedittext.grevent1.response == RESET)
            {
                /* stay in command on reset -- go back to locate */
            }
            else if (me^^COedittext.grevent1.response == GR_UNKNOWN_TYPE)
            {
                exit = TRUE;  /* unrecognized input -- return control */
            }
        }                          /* end if haven't located text object */

        if (me^^super_cmd.state == AT_LOC_OBJ)
        {
            /*
             *  object has been located; edit it!
             */

            if (me->mytype==0)
            {
              
                 ex$message(field = PROMPT_FIELD,
                       msgnumb = GR_P_EdtTxt);
            }
            else
            {

                  ex$message(field = PROMPT_FIELD,
                       msgnumb = GR_P_RplText);
            }

            do
            {
                /*
                 *  display the cursor
                 */

                line_mode = 1;   /* draw a vertical cursor in front of char */
                dpmode = GRhhd;  /* draw the cursor in half highlight mode  */

                if (me^^COedittext.properties & GRIS_VIEW_INDEP)
                {
                   view_ind = TRUE;  /* text is view independent */
                }
                else  /* text is not view independent */
                {
                   view_ind = FALSE;
                }

                status = GRtext_cursor(&msg,
                                       &(me^^COedittext.text_string[me^^COedittext.cc_info.cur_char_index]),
                                       &me^^COedittext.cc_info,
                                       &me^^COedittext.tx_attr,
                                       &me^^COedittext.lbs_geom,
                                       &dpmode,&line_mode,view_ind);

                if (COERROR(status) || (COERROR(msg)))
                {
#ifdef DEBUG
                    printf("COedittexti.I err: GRtext_cursor");
#endif
                }

                /*
                 * if the cursor is in a field, draw the field box
                 */

                if ((me^^COedittext.cc_info.field_delim != 0) &&
                    (!(me^^COedittext.cc_info.flags & 16)))
                {
                   dpmode = GRhd;

                   GRtext_fieldbox(&msg,me^^COedittext.text_string,
                                   &me^^COedittext.tx_attr,
                                   &me^^COedittext.font_info,
                                   &me^^COedittext.disp_attr,
                                   &me^^COedittext.cc_info.field_position,
                                   &dpmode,&me^^COedittext.lbs_geom,view_ind);
                }
                keyin_length = 0;
                om_msg = TRUE;

                do
                {
                    co$getevent(msg = &msg,
                                event_mask = mask,
                                nbytes = &nbytes,
                                mode = EX_ALL_ASCII_MODE,
                                response = response,
                                response_data = response_data,
                                event = &event);

                    if ((event.response == EX_STRING) && om_msg)
                    {
                        --nbytes;  /* disregard the NULL terminator */

                        /*
                         *  the pointer to the text string is initialized to
                         *  NULL; must call om$malloc the first time requesting
                         *  memory; subsequent requests for memory must be made
                         *  by calling om$realloc
                         */

                        if (keyin_string)
                        {
                            /*
                             * check to see if the text length has exceeded the
                             * maximum number a signed short can represent
                             * (since text length is stored as a signed short)
                             */

                            tmp_short = keyin_length + nbytes;

                            if (tmp_short >= 0)
                            {
                                keyin_string = om$realloc(ptr = (char *)keyin_string,
                                                          size = (OMuint)tmp_short);
                            }
                            else
                            {
                                /*
                                 * maximum number of chars. exceeded; continue
                                 * calling co$getevent so the rest of the
                                 * EX_STRING events will be read off the
                                 * software queue and discarded, otherwise
                                 * command server will try to interpret them as
                                 * commands
                                 */

                                om_msg = FALSE;
                            }
                        }
                        else
                        {
                            keyin_string = om$malloc(size = nbytes);
                        }

                        if (om_msg)
                        {
                            OM_BLOCK_MOVE(response_data,
                                          &(keyin_string[keyin_length]),
                                          nbytes);
                            keyin_length += (IGRshort)nbytes;
                            input_ptr = (IGRchar *) keyin_string;
                        }
                    }
                }
                while ((event.response == EX_STRING) &&
                       (ex$peek_event_queue(resp = &resp_type)) &&
                       (resp_type == EX_STRING));

                if (!om_msg)
                {
                    ex$message(msgnumb = GR_E_MaxTxLnExTxTr);
                }

                switch (event.response)
                {
                    case EX_CHAR:
                    case EX_STRING:

                       /*
                        * erase the cursor and field box
                        */

                       dp$erase_hilite(msg = &msg);

                       /*
                        *  call function to edit the text string
                        */

                       if (event.response == EX_CHAR)
                       {
                          keyin_length = nbytes;
                          input_ptr = (IGRchar *) response_data;
                       }

                       if (! GRedit_text(&msg,init_edit,input_ptr,keyin_length,
                                         &me^^COedittext.text_string,
                                         &me^^COedittext.tx_attr,
                                         &me^^COedittext.text_buf_size,
                                         &me^^COedittext.font_info,
                                         &me^^COedittext.disp_attr,
                                         &me^^COedittext.num_lines,
                                         &me^^COedittext.cc_info,
                                         &me^^COedittext.text_attr,
                                         &me^^COedittext.ele_header,
                                         GRbe,GRbd,view_ind))
                       {
                          if (msg == MSFAIL)
                          {
                             ex$message(msgnumb = GR_E_MaxTxLnExTxTr);
                          }
#ifdef DEBUG
                           printf("COedittexti.I err: GRedit_text msg = %d\n",msg);
#endif
                       }

                       /* 
                        * GRedit_text has already been called at least once
                        */

                       init_edit = FALSE;
                       break;

                    case DATA:

                        /*
                         * erase the cursor and field box
                         */

                        dp$erase_hilite(msg = &msg);

                        if (COERROR(msg))
                        {
#ifdef DEBUG
                           printf("COedittexti.I err: dp$erase_hilite msg = %d\n",msg);
#endif
                        }

                        /*
                         * if the located text object is not view independent,
                         * use the accept point to determine the cursor
                         * position; otherwise ignore the data point and
                         * leave the cursor at its current position
                         */

                        if (!(me^^COedittext.properties & GRIS_VIEW_INDEP))
                        {
                           /*
                            * project the locate data point onto the plane
                            * defined by text element and adjust the cursor
                            * position accordingly
                            */

                           GRlbsplapproj(&msg,&me^^COedittext.lbs_geom,
                                         &event.event.button,proj_pnt,&tparam);

                           /*
                            * position the cursor under the character indicated
                            * by the locate point; have to temporarily
                            * increment the text length and insert a change
                            * font esc seq and a blank char so the positon
                            * after the last char in the text string may be
                            * selected (the change font is used in case last
                            * char in string is a 16 bit char); make sure
                            *  enough memory is available for the 'extra' chars
                            * also make sure the text length does not exceed
                            * the maximum text length, which is limited to a
                            * signed short's greatest positive number
                            */

                           tmp_short = me^^COedittext.tx_attr.text_length + 5;

                           if (tmp_short >= 0)
                           {
                              me^^COedittext.tx_attr.text_length = tmp_short;

                              if (me^^COedittext.tx_attr.text_length > me^^COedittext.text_buf_size)
                              {
                                  me^^COedittext.text_string = (IGRuchar *)om$realloc(
                                                ptr = (char *)me^^COedittext.text_string,
                                                size = (OMuint)me^^COedittext.tx_attr.text_length);

                                  me^^COedittext.text_buf_size = me^^COedittext.tx_attr.text_length;
                              }

                              me^^COedittext.text_string[me^^COedittext.tx_attr.text_length - 5] = ESC;
                              me^^COedittext.text_string[me^^COedittext.tx_attr.text_length - 4] = 'f';
                              OM_BLOCK_MOVE(&me^^COedittext.text_symb.Active_ascii_font,
                                            &(me^^COedittext.text_string[me^^COedittext.tx_attr.text_length - 3]),
                                            2);
                              me^^COedittext.text_string[me^^COedittext.tx_attr.text_length - 1] = BLANK;
                           }

                           text_info.estx = &me^^COedittext.tx_attr;
                           text_info.font_id = cur_mod_osnum;
                           text_info.text_string = (IGRchar *) me^^COedittext.text_string;
                           text_info.prev_font = -1;
                           text_info.flags = 0;

                           status = dp$get_closest_char(msg = &msg,
                                                        lbsys = &me^^COedittext.lbs_geom,
                                                        txt_ele = &text_info,
                                                        osnum = cur_mod_osnum,
                                                        mod_objid = cur_mod_id,
                                                        point = proj_pnt,
                                                        which_char = &i);

                           me^^COedittext.tx_attr.text_length -= 5;

                           /*
                            * since a change font and a blank were added to the
                            * end of of the text string, the index returned may
                            * be greater than the text length - if so, set the
                            * index to text length
                            */

                           if (i > me^^COedittext.tx_attr.text_length)
                           {
                              i = me^^COedittext.tx_attr.text_length;
                           }

                           /*
                            *  find position info about the char the cursor is
                            *  to be displayed under
                            */

                           temp_index = me^^COedittext.cc_info.cur_char_index;

                           GRvalid_cursor_position(&msg,
                                                   me^^COedittext.text_string,
                                                   me^^COedittext.tx_attr.text_length,
                                                   -1,
                                                   me^^COedittext.tx_attr.font,
                                                   me^^COedittext.font_info.flags,
                                                   i,&temp_index);

                           GRchar_pos_info(&msg,me^^COedittext.text_string,
                                           temp_index,
                                           TRUE,&me^^COedittext.tx_attr,
                                           &me^^COedittext.font_info,
                                           &me^^COedittext.disp_attr,
                                           &me^^COedittext.cc_info);
                        }
                        break;

                    case RESET:

                        me^^super_cmd.state = AT_START;
                        ex$message(field = ERROR_FIELD,
                                   in_buff = "");

                        /*
                         * erase the cursor and field box
                         */

                        dp$erase_hilite(msg = &msg);

                        if (COERROR(msg))
                        {
#ifdef DEBUG
                           printf("COedittexti.I err: dp$erase_hilite msg = %d\n",msg);
#endif
                        }
                        break;  /* do nothing; go back to locate */

                    default:

                        /*
                         * erase the cursor and field box
                         */

                        dp$erase_hilite(msg = &msg);

                        if (COERROR(msg))
                        {
#ifdef DEBUG
                           printf("COedittexti.I err: dp$erase_hilite msg = %d\n",msg);
#endif
                        }
                        exit = TRUE;
                        break;
                }

                if ((event.response != EX_CHAR) &&
                    (event.response != EX_STRING) &&
                    (event.response != EX_DATA))
                {
                   IGRint    ii;

                   /*
                    * update the text object with the editted text string and
                    * also update the abstract geometry; if the text object is
                    * now empty, must update the text object's flag indicating
                    * the text object is empty (if it wasn't already empty)
                    * and display the empty text object, using its name if it
                    * has one; if the text object was empty when editting began
                    * but now it is not, must update the text object's flag
                    * indicating the text object is not empty
                    */

                   for (ii = 0; (ii < me^^COedittext.tx_attr.text_length) &&
                                (me^^COedittext.text_string[ii] == ESC) &&
                                ((me^^COedittext.text_string[ii + 1] == 'j') ||
                                 (me^^COedittext.text_string[ii + 1] == 'J'));
                        ii += 10);

                   if (ii == me^^COedittext.tx_attr.text_length)
                   {
                      /*
                       * the text string only contains stroke start move(s);
                       * it is effectively empty
                       */

                      me^^COedittext.tx_attr.text_length = 0;
                      me^^COedittext.cc_info.cur_char_index=0;
                   }

                   if (me^^COedittext.tx_attr.text_length)
                   {
                      if (me^^COedittext.tx_attr.flag & EMPTY_TEXT_FLAG)
                      {
                         /*
                          * text object was empty when located but now isn't;
                          * send message to clear the bit in the text flag that
                          * indicates the text object is empty
                          */

                         om_msg = om$send(mode = OM_e_wrt_object,
                                          msg = message GRtext.GRchange_flag
                                                   (&msg,FALSE,
                                                    EMPTY_TEXT_FLAG),
                                          senderid = my_id,
                                          targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                          targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                         if (COERROR(om_msg) || COERROR(msg))
                         {
                             ex$message(msgnumb = GR_E_ErrEncCmdRst);
#ifdef DEBUG
                             printf("COedittext_execute_method:  GRtext.GRreplace_text failed\n");
#endif
                             break;
                         }

                         me^^COedittext.tx_attr.flag &= ~EMPTY_TEXT_FLAG;
                      }
                   }
                   else  /* text object is empty */
                   {
                      if (!(me^^COedittext.tx_attr.flag & EMPTY_TEXT_FLAG))
                      {
                         /*
                          * text object was not empty when located but now is;
                          * send message to set the bit in the text flag that
                          * indicates the text object is empty
                          */

                         om_msg = om$send(mode = OM_e_wrt_object,
                                          msg = message GRtext.GRchange_flag
                                                   (&msg,TRUE,
                                                    EMPTY_TEXT_FLAG),
                                          senderid = my_id,
                                          targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                          targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                         if (COERROR(om_msg) || COERROR(msg))
                         {
                             ex$message(msgnumb = GR_E_ErrEncCmdRst);
#ifdef DEBUG
                             printf("COedittext_execute_method:  GRtext.GRreplace_text failed\n");
#endif
                             break;
                         }

                         me^^COedittext.tx_attr.flag |= EMPTY_TEXT_FLAG;
                      }

                      /*
                       * need to display the empty text object; if the text
                       * object is named, the name becomes the text object's
                       * text string so that the empty text object's name is
                       * displayed
                       */

                      status = di$untranslate(objname = text_name,
                                              objid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                              osnum = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                      if (status == DIR_S_SUCCESS)
                      {
                         /*
                          * the text object is named; use the text name as the
                          * text object's text string; want the text name
                          * without the pathname, so call di$split
                          */

                         di$split(pathname = text_name,
                                  name = text_name);

                         me^^COedittext.tx_attr.text_length = (IGRshort)strlen(text_name);

                         /*
                          * may have to allocate (more) memory for the
                          * text string
                          */

                         if (me^^COedittext.tx_attr.text_length > me^^COedittext.text_buf_size)
                         {
                            if (me^^COedittext.text_buf_size == 0)
                            {
                               me^^COedittext.text_string = (IGRuchar *)om$malloc(
                                   size = (OMuint)me^^COedittext.tx_attr.text_length);
                            }
                            else  /* some memory has been allocated: realloc */
                            {
                               me^^COedittext.text_string = (IGRuchar *) om$realloc(
                                   ptr = (char *)me^^COedittext.text_string,
                                   size = (IGRint)me^^COedittext.tx_attr.text_length);
                            }

                            me^^COedittext.text_buf_size = me^^COedittext.tx_attr.text_length;
                         }

                         OM_BLOCK_MOVE(text_name,
                                       me^^COedittext.text_string,
                                       (IGRint)me^^COedittext.tx_attr.text_length);
                      }
                      else if (status & ERRO)  /* di$untranslate failed */
                      {
#ifdef DEBUG
                          printf("COedittext_execute_method:  di$untranslate failed\n");
#endif
                      }
                   }

                   om_msg = om$send(mode = OM_e_wrt_object,
                                    msg = message GRtext.GRreplace_text
                                             (&msg,
                                              &me^^COedittext.grevent1.located_object[0].module_info,
                                              me^^COedittext.tx_attr.text_length,
                                              me^^COedittext.text_string),
                                    senderid = my_id,
                                    targetid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                    targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                   if (COERROR(om_msg) || COERROR(msg))
                   {
                       ex$message(msgnumb = GR_E_ErrEncCmdRst);
#ifdef DEBUG
                       printf("COedittext_execute_method:  GRtext.GRreplace_text failed\n");
#endif
                       break;
                   }

                   om$make_chanselect(channame = "GRconnector.to_owners",
                                      p_chanselect = &owner_chan);

                   matrix_type = MAIDMX;

                   for (i = 0; i < 16; ++i)
                   {
                       matrix[i] = 0.0;
                   }

                   matrix[0] = 1.0;
                   matrix[5] = 1.0;
                   matrix[10] = 1.0;
                   matrix[15] = 1.0;

                   i = 0;

                   om_msg = om$send(mode = OM_e_wrt_object,
                                    msg = message GRowner.GRxform_owner
                                             (&msg,
                                              &me^^COedittext.grevent1.located_object[0].module_info,
                                              &matrix_type,matrix,
                                              &new_objid,&i),
                                    senderid = me^^COedittext.grevent1.located_object[0].located_obj.objid,
                                    p_chanselect = &owner_chan,
                                    targetos = me^^COedittext.grevent1.located_object[0].located_obj.osnum);

                   if (COERROR(om_msg) || COERROR(msg))
                   {
                       ex$message(msgnumb = GR_E_ErrEncCmdRst);
#ifdef DEBUG
                       printf("COedittext_execute_method:  GRowner.GRxform_owner failed\n");
#endif
                       break;
                   }

                   /*
                    * if the text object is now empty, must display it
                    */

                   if (me^^COedittext.tx_attr.flag & EMPTY_TEXT_FLAG)
                   {
                      matr[0] = (IGRmatrix *)me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix;

                      /*
                       * if the located text object is view independent, must
                       * initialize info for display
                       */

                      if (me^^COedittext.properties & GRIS_VIEW_INDEP)
                      {
                         view_ind = TRUE;
                         view_ind_type = ROTATION_IND;
                         view_ind_point[0] = me^^COedittext.lbs_geom.matrix[3];
                         view_ind_point[1] = me^^COedittext.lbs_geom.matrix[7];
                         view_ind_point[2] = me^^COedittext.lbs_geom.matrix[11];
                      }
                      else
                      {
                         view_ind = FALSE;
                      }

                      status = dp$display(msg = &msg,
                                          osnum = cur_mod_osnum,
                                          mode = GRbd,
                                          oids = &me^^COedittext.grevent1.located_object[0].located_obj,
                                          mtx_type = &me^^COedittext.grevent1.located_object[0].module_info.md_env.matrix_type,
                                          matrix = matr,
                                          view_ind = view_ind,
                                          view_ind_type = view_ind_type,
                                          view_ind_point = view_ind_point);

                      if (! (1 & status & msg))
                      {
#ifdef DEBUG
                         printf("COedittext_execute: Error: dp$display\n");
#endif
                      }
                   }
                }
            }
            while ((me^^super_cmd.state == AT_LOC_OBJ) &&
                   (!exit));
        }   /* end if object has been located */
    }   /*  end while (!exit) */

    if (keyin_string)
    {
        om$dealloc(ptr = keyin_string);
    }

#ifdef DEBUG
    printf("COedittext_execute_method: Exiting\n");
#endif

    return(OM_S_SUCCESS);

}   /*  end execute method */

end implementation COedittext;
