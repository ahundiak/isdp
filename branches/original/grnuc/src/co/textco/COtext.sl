/* #######################    APOGEE COMPILED   ######################## */
/*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
*/ 


/******************************************************************************

Description:

    This class implements the following commands:

    1)  Place Text
    2)  Place View Independent Text
    3)  Place Fitted Text
    4)  Place View Independent Fitted Text

Abstract class:      No.

Override methods:
    message init
    message wakeup
    message delete
    message dynamics

Messages:
    message append_text_to_buffer
    message clear_buffer
    message store_origin
    message get_view_rot_matrix
    message construct_text
    message is_it_empty_text
    message calc_angle_size
    message get_construct_attr
    message named_empty_text
    message empty_text_no_name
    message init_text_attr
    message set_empty_flag
    message check_dynamics
    message dyn_set_prompt

History:  Bill Cecil     03/08/89  Design and Implementation
		 jjm      3/10/93  added pre_sleep method

Algorithm:

Notes:

******************************************************************************/

class           COtext
super_class     CEO_LOCATE
product_name    "$SOURCE"
start_state     terminate
options         "SItc"

specification

#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "dpstruct.h"

instance
{
    struct GRvg_construct    cnst_lis;      /* construction list             */
    struct GRdpb_text_symb   text_symb;     /* text symbology                */
    struct extents           text_extents;
    struct extents           just_extents;  /* justified extents of the text */
    struct vfont_entry       font_info;     /* font information              */
    struct IGResintx         tx_attr;       /* cnst text specific attr       */
    struct IGRestx           text_attr;     /* text specific attributes      */
    struct IGRlbsys          lbs_geom;      /* local bounded system geometry */
    struct DPele_header      elem;          /* information for dynamics      */
    struct EX_button         origin_button; /* save origin as a button       */
    IGRlong                  cnst_lis_msg;  /* return msg from construct     */
    GRspacenum               cur_mod_osnum; /* current module's osnum        */
    IGRchar                  empty_tx_name[GR_MAX_CHAR]; 
                                            /* empty text element's name     */
    IGRuchar                 *text_string;  /* pointer to text string        */
    GRclassid                classid;       /* classid of object             */
    IGRshort                 text_length;   /* length of string in bytes     */
    IGRshort                 text_buf_size; /* # of bytes currently allocated*/
                                            /* for text_string               */
    IGRint                   viewind;       /* type of view independence     */
    IGRboolean               dyn_on;        /* flag to indicate if dynamics  */
                                            /* are on (1 == on, 0 == off)    */
    IGRpoint                 origin;        /* origin point of text object   */
    IGRmatrix                rot_matrix;    /* rotation matrix of view origin
                                               was placed in                 */
    IGRmatrix                wld_view_mtrx; /* world to view transformation
                                               matrix                        */
}

implementation

#include "coimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "godef.h"
#include "go.h"
#include "dp.h"
#include "grdpbmacros.h"
#include "exmacros.h"
#include "fontdef.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"
#include "dpdef.h"
#include "dpmacros.h"
#include "igrdef.h"
#include "igr.h"
#include "dpstruct.h"
#include "OMmacros.h"
#include "DItypedef.h"
#include "DIdef.h"
#include "DIglob.h"
#include "DIprims.h"
#include "gotextdef.h"
#include "copltxdef.h"

from GRgraphics import GRconstruct;
from GRfm       import GRfm_retdata;

extern IGRboolean      GRcreate_lbs();
extern IGRboolean      GRjust_string();
extern IGRboolean      GRvalid_string();
extern IGRboolean      GRnum_disp_char();
extern IGRint          DYtext();
extern IGRint          DYfittext();
extern IGRboolean      MA2ptdis();      /* finds dist between two pts   */
extern IGRboolean      MAang2vc();      /* finds angle between two vect */
extern IGRboolean      MAptsxform();    /* transforms points            */

action init
{
    /*
     * initialize pointers to structures in the construction list structure
     */

    me^^COtext.cnst_lis.msg = &me^^COtext.cnst_lis_msg;
    me^^COtext.cnst_lis.env_info = &me->ModuleInfo;
    me^^COtext.cnst_lis.newflag = FALSE;
    me^^COtext.cnst_lis.geometry = (IGRchar *)&me^^COtext.lbs_geom;
    me^^COtext.cnst_lis.display = &me->ActiveDisplay;
    me^^COtext.tx_attr.estx = &me^^COtext.text_attr;
    me^^COtext.cnst_lis.class_attr = (IGRchar *)&me^^COtext.tx_attr;
    me^^COtext.cnst_lis.name = NULL;

    /*
     * initialize text length and allocate memory for the text string
     */

    me^^COtext.text_length = 0;
    me^^COtext.text_buf_size = INIT_TEXT_BUF_SIZE;
    me^^COtext.text_string = (IGRuchar *) om$malloc(size = INIT_TEXT_BUF_SIZE);

    om$send(mode = OM_e_wrt_message,
            msg = message CEO_LOCATE.init(type,str_ptr),
            targetid = my_id);
}

action pre_sleep
{
   *additional_info = "Place Text";
}

action wakeup
{
    IGRlong                temp_msg;
    IGRlong                nbytes_in_buffer;
    IGRlong                nbytes_transferred;
    IGRchar                classname[14];
    struct GRid            fontmgr_obj;   /* objid/osnum of font manager     */
    OM_S_OBJID             cur_mod_id;    /* current modules object id       */
    IGRboolean             set_inq;       /* flag to indicate if setting or  */
                                          /* inquiring dynamics (1: inquire) */

    om$send(mode = OM_e_wrt_message,
            msg = message CEO_LOCATE.wakeup(pos),
            targetid = my_id);

    /*
     * build class name
     */

    strcpy(classname,"GR");
    strcat(classname,me->DatabaseType);
    strcat(classname,"text");

    /* 
     * get classid from classname
     */

    status = om$get_classid(classname = classname,
                            p_classid = &me^^COtext.classid);

    /*
     * set the current properties in the construction list structure
     */

    nbytes_in_buffer = sizeof(me^^COtext.cnst_lis.properties);

    gr$get_active_prop(msg = &temp_msg,
                       sizbuf = &nbytes_in_buffer,
                       buffer = &me^^COtext.cnst_lis.properties,
                       nret = &nbytes_transferred);

    me^^COtext.viewind = -1;

#ifndef IDRAW
    if ((me->mytype == PL_VI_TEXT) ||
        (me->mytype == PL_VI_FIT_TEXT))
    {
       me^^COtext.cnst_lis.properties |= GRIS_VIEW_INDEP;
       me^^COtext.viewind = ROTATION_IND;
    }
#endif  /* IDRAW */

    nbytes_in_buffer = sizeof(me^^COtext.text_symb);
    gr$get_text_symb(msg = &temp_msg,
                     sizbuf = &nbytes_in_buffer,
                     buffer = &me^^COtext.text_symb,
                     nret = &nbytes_transferred);

    if (me^^COtext.text_symb.Active_flags & GRFILLED_TEXT)
    {
       me^^COtext.cnst_lis.properties |= GRFILLED_DISPLAY;
    }
    else
    {
       me^^COtext.cnst_lis.properties &= ~GRFILLED_DISPLAY;
    }

    /*
     *  get the objid of the font manager using its named object
     */

    ex$get_cur_mod(id = &cur_mod_id,
                   osnum = &me^^COtext.cur_mod_osnum);

    ex$get_super(mod_id = cur_mod_id,
                 mod_osnum = me^^COtext.cur_mod_osnum,
                 super_name = FONTMGR_NO_NAME,
                 create = TRUE,
                 super_class = "GRfm",
                 super_id = &fontmgr_obj.objid,
                 super_osnum = &fontmgr_obj.osnum);

    /*
     * get font information
     */

    status = om$send(mode = OM_e_wrt_object,
                     msg = message GRfm.GRfm_retdata
                            (&temp_msg,&(me^^COtext.text_symb.Active_font),
                             &me^^COtext.font_info),
                     senderid = my_id,
                     targetid = fontmgr_obj.objid,
                     targetos = me^^COtext.cur_mod_osnum);

    if (!(status & temp_msg & 1))
    {
        ex$message(msgnumb = GR_E_ActFtNotLd,
                   time = 2);
        me^^super_cmd.state = _terminate;
        goto quit;
    }

    set_inq = 1;
    DPdynflags(&temp_msg,&set_inq,&me^^COtext.dyn_on,NULL);

    if ((me->mytype == PL_FIT_TEXT) ||
        (me->mytype == PL_VI_FIT_TEXT))
    {
        /*
         * fitted text must always be left center justified
         */

        me^^COtext.text_symb.Active_just = LEFT_CENTER;
    }
}

action delete
{
    /*
     *  if memory has been allocated for a text string, deallocate it
     */

    if (me^^COtext.text_string)
    {
        om$dealloc(ptr = me^^COtext.text_string);
    }

    om$send(mode = OM_e_wrt_message,
            msg = message CEO_LOCATE.delete(f_defer_flag),
            targetid = my_id);
}

action append_text_to_buffer()
{
    IGRlong        temp_msg;
    IGRint         resp_type;      /* response type                          */
    IGRint         event_on_queue; /* 1 if an event is on the software queue */
    enum font_type cur_font_type;  /* type (7/16) of font                    */
    IGRshort       replace_index;  /* index in text string to begin replacing*/
                                   /* escape sequences                       */
    IGRshort       tmp_length;
    IGRuchar       *text_ptr;

        me->ret = MSSUCC;
        text_ptr = me^^COtext.text_string;
        replace_index = me^^COtext.text_length;

        do
        {
            if (me->ret == MSSUCC)
            {
                --(me->nbytes1);  /* don't include the NULL terminator */

                /*
                 * check to make sure the current text length plus the number
                 * of bytes to be appended is not a number larger than the text
                 * length variable can hold; since text length is stored as a
                 * short (signed), it is too large if the length becomes
                 * negative
                 */

                tmp_length = me^^COtext.text_length + me->nbytes1;

                if (tmp_length >= 0)
                {
                    if (tmp_length > me^^COtext.text_buf_size)
                    {
                        tmp_length = me^^COtext.text_buf_size + me->nbytes1 + TEXT_BUF_SIZE;

                        if (tmp_length >= 0)
                        {
                            me^^COtext.text_buf_size = tmp_length;

                            if (text_ptr = (IGRuchar *)om$realloc(ptr = (char *) me^^COtext.text_string,
                                                                                       size = (IGRint)me^^COtext.text_buf_size))
                            {
                                me^^COtext.text_string = text_ptr;
                            }
                            else  /* sufficient memory couldn't be allocated */
                            {
                                me^^COtext.text_buf_size -= me->nbytes1 + TEXT_BUF_SIZE;
                                me->ret = MSFAIL;
                            }
                        }
                        else  /* # of chars too large for text length */
                        {
                            text_ptr = NULL;
                            me->ret = MSINARG;
                        }
                    }
                }
                else /* number of chars too large for text length (short) */
                {
                    text_ptr = NULL;
                    me->ret = MSINARG;
                }

                if (text_ptr)
                {
                    OM_BLOCK_MOVE(me->response_data,
                                  &(me^^COtext.text_string[me^^COtext.text_length]),
                                  me->nbytes1);

                    me^^COtext.text_length += (IGRshort)me->nbytes1;
                }
            }

            /*
             * if there are several consecutive EX_STRING events on the
             * software queue, get them all before calling function to
             * replace control sequences with escape sequences since
             * one or more of the control sequences may be split
             * between events, and a partial control sequence would
             * not be understood by the replacement function
             */

            if (event_on_queue = (ex$peek_event_queue(resp = &resp_type)) &&
                (resp_type == EX_STRING))
            {
                status = co$getevent(msg = &temp_msg,
                                     event_mask = me->event_mask1,
                                     event_size = me->event_size,
                                     event = &me->event1,
                                     prompt = me->prompt,
                                     value_type = me->value_type,
                                     response = me->response,
                                     response_data = me->response_data,
                                     nbytes = &me->nbytes1,
                                     mode = me->filter_mode);

                if (!(status & 1))
                {
#ifdef DEBUG
                    printf("COtext.sl err: getevent: status = %d\n",status);
#endif
                }
            }
        } while (event_on_queue &&
                 resp_type == EX_STRING);

        /*
         * call functions to replace control sequences with escape sequences
         * and justify the text string
         */

        if (me^^COtext.font_info.flags & SIXTEEN_BIT)
        {
           cur_font_type = sixteen;
        }
        else if (me^^COtext.font_info.flags & EIGHT_BIT)
        {
           cur_font_type = eight;
        }
        else
        {
           cur_font_type = seven;
        }

        COinsert_escape(&temp_msg,
                        &(me^^COtext.text_string),
                        &me^^COtext.text_length,
                        &me^^COtext.text_buf_size,
                        &replace_index,
                        &cur_font_type,
                        &me^^COtext.text_symb,
                        &me->ActiveDisplay);

        if (temp_msg != MSFAIL)
        {
            GRjust_string(&temp_msg,
                          &me^^COtext.text_string,
                          &me^^COtext.text_length,
                          &me^^COtext.text_buf_size,
                          &me^^COtext.font_info,
                          &me->ActiveDisplay,
                          &me^^COtext.text_symb,
                          0,NULL,
                          &me^^COtext.text_extents);

            if (temp_msg == MSFAIL)
            {
                me->ret = MSINARG;
            }
        }
        else
        {
            me->ret = MSINARG;
        }
}

action clear_buffer()
{
    me^^COtext.text_length = 0;
}

action dynamics  /* (int dynamics; int *sts) */
{   
    IGRboolean set_inq=1;
    IGRlong temp_msg;
    
    /* check if dynamics has been set or unset since last pass */

    DPdynflags(&temp_msg,&set_inq,&me^^COtext.dyn_on,NULL);

    switch (dynamics)
    {
        case GRdyntext:

            {
                IGRlong    temp_msg;

                /*
                 * need to justify the text string in case one of the text
                 * attributes has changed
                 */

                GRjust_string(&temp_msg,
                              &me^^COtext.text_string,
                              &me^^COtext.text_length,
                              &me^^COtext.text_buf_size,
                              &me^^COtext.font_info,
                              &me->ActiveDisplay,
                              &me^^COtext.text_symb,
                              0,NULL,
                              &me^^COtext.text_extents);

                if (!DYtext(&me^^COtext.elem,
                            &me^^COtext.tx_attr,
                            &me^^COtext.lbs_geom,
                            &me^^COtext.cur_mod_osnum,
                            &me^^COtext.text_symb,
                            &me^^COtext.text_extents,
                            &me^^COtext.text_length,
                            &me^^COtext.text_string,
                            &me->ActiveDisplay,
                            &me->ActiveAngle,
                            me^^COtext.viewind))
                {
                    ex$message(msgnumb = GR_E_ActFtNotLd,
                               time = 2);
                    *sts = OM_E_ABORT;
                }

                /*
                 *  updating text length
                 */

                me^^COtext.text_length = me^^COtext.text_buf_size = me^^COtext.elem.ele_spec_att.text->estx->text_length;
            }
            break;

        case GRdynfittext:

            if (me^^COtext.dyn_on)
            {
                IGRpoint           origin_point;

                origin_point[0] = me^^COtext.origin_button.x;
                origin_point[1] = me^^COtext.origin_button.y;
                origin_point[2] = me^^COtext.origin_button.z;

                DYfittext(&me^^COtext.elem,
                          &me^^COtext.text_string,
                          &me^^COtext.text_symb,
                          &me->ActiveDisplay,
                          origin_point,
                          me^^COtext.wld_view_mtrx,
                          me^^COtext.rot_matrix,
                          me^^COtext.viewind);
            }
            break;

        default:

            om$send(mode = OM_e_wrt_message,
                    msg = message CEO_LOCATE.dynamics(dynamics,sts),
                    targetid = my_id);
            break;
    }
}

action store_origin()
{
    /*
     * save the button structure in event1 which contains the origin
     * of the text object
     */

    me^^COtext.origin_button = me->event1.event.button;
}

action get_view_rot_matrix()
{

        IGRlong         temp_msg;
        IGRshort        inquire;       /* flag to indicate an inquiry  */
        IGRlong         which_error;   /* points to error in GRwnparam */
        IGRlong         view_bytes;    /* number of bytes returned     */
        struct GRid     window_id;     /* widow's objid and OS         */

        struct var_list list[2];


        inquire = TRUE;
        window_id.osnum = me^^COtext.origin_button.osnum;
        window_id.objid = me^^COtext.origin_button.objid;




    /*
     * if placing view dependent text must find the view rotation matrix,
     * otherwise don't factor any view rotation in; if placing fitted text,
     * also need the world to view transformation matrix
     */

    if ((me->mytype == PL_TEXT) ||
        (me->mytype == PL_FIT_TEXT))
    {
        list[0].var = VW_ROT_NO_CON;
        list[0].var_ptr = (char *)me^^COtext.rot_matrix;
        list[0].num_bytes = sizeof(IGRdouble)*16;
        list[0].bytes_returned= &view_bytes;
        list[1].var = END_PARAM;
        list[1].var_ptr = NULL;
        list[1].num_bytes = 0;
        list[1].bytes_returned = NULL;

          dp$inq_set_gragad( msg = &temp_msg,
                              osnum = window_id.osnum,
                              gragad_objid = window_id.objid,
                              which_error = &which_error,
                              var_list = list );
    }
#ifndef IDRAW
    else
    {
        IGRint   i;

        for (i = 1; i < 15; ++i)
        {
           me^^COtext.rot_matrix[i] = 0;
        }

        me^^COtext.rot_matrix[0] = 1;
        me^^COtext.rot_matrix[5] = 1;
        me^^COtext.rot_matrix[10] = 1;
        me^^COtext.rot_matrix[15] = 1;
    }
#endif  /* IDRAW */

    if ((me->mytype == PL_FIT_TEXT) ||
        (me->mytype == PL_VI_FIT_TEXT))
    {


        list[0].var = WLD_TO_VIEW;
        list[0].var_ptr = (char *)me^^COtext.wld_view_mtrx;
        list[0].num_bytes = sizeof(IGRdouble)*16;
        list[0].bytes_returned= &view_bytes;
        list[1].var = END_PARAM;
        list[1].var_ptr = NULL;
        list[1].num_bytes = 0;
        list[1].bytes_returned = NULL;

        /*
         * get rotation matrix and world to view transformation
         * matrix from the window
         */

        inquire = TRUE;
        window_id.osnum = me^^COtext.origin_button.osnum;
        window_id.objid = me^^COtext.origin_button.objid;




/*        GRwnparam(&temp_msg,&inquire,&window_id,
                  &which_error,WLD_TO_VIEW,
                  (IGRchar *)me^^COtext.wld_view_mtrx,
                  sizeof(IGRdouble) * 16,&view_bytes,END_PARAM,NULL,0,NULL);
*/

          dp$inq_set_gragad( msg = &temp_msg,
                              osnum = window_id.osnum,
                              gragad_objid = window_id.objid,
                              which_error = &which_error,
                              var_list = list );
    }
}

action init_text_attr()
{
    IGRlong         temp_msg;

    /*
     * initialize the text attributes to the current values
     */

    me^^COtext.text_attr.font = me^^COtext.text_symb.Active_font;
    me^^COtext.text_attr.just = me^^COtext.text_symb.Active_just;
    me^^COtext.text_attr.width = me^^COtext.text_symb.Active_width;
    me^^COtext.text_attr.height = me^^COtext.text_symb.Active_height;
    me^^COtext.text_attr.line_spac = me^^COtext.text_symb.Active_linespac;
    me^^COtext.text_attr.char_spac = me^^COtext.text_symb.Active_charspac;
    me^^COtext.text_attr.flag = 0;

    /*
     * need to justify the text string in case one of the text attributes has
     * changed
     */

    GRjust_string(&temp_msg,
                  &me^^COtext.text_string,
                  &me^^COtext.text_length,
                  &me^^COtext.text_buf_size,
                  &me^^COtext.font_info,
                  &me->ActiveDisplay,
                  &me^^COtext.text_symb,
                  0,NULL,
                  &me^^COtext.text_extents);

    me^^COtext.text_attr.text_length = me^^COtext.text_length;
    me^^COtext.tx_attr.text_string = (IGRchar *) me^^COtext.text_string;

    /*
     * calculate number of displayable characters
     */

    GRnum_disp_char(&temp_msg,
                    me^^COtext.text_string,
                    &me^^COtext.text_length,
                    me^^COtext.text_symb.Active_font,
                    me^^COtext.font_info.flags,
                    &me^^COtext.text_attr.num_char);
}

action construct_text()
{
    IGRlong         temp_msg;
    IGRlong         nbytes_in_buffer;
    IGRlong         nbytes_transferred;
    IGRpoint        origin_point;
    IGRmatrix       *matr[1];  /* pointer to matrix for display */
    struct GRid     buffer;
    struct GRmd_env display_env;

    /*
     * check the text string for validity (i.e. all fields are closed, no
     * duplicate field numbers)
     */

    if (!GRvalid_string (&temp_msg,me^^COtext.text_string,
                         &me^^COtext.text_length,-1,
                         me^^COtext.text_symb.Active_font,
                         &me^^COtext.font_info))
    {
        if (temp_msg == MSINARG)
        {
           ex$message(msgnumb = GR_E_DupFldNo);
        }
        else
        {
           ex$message(msgnumb = GR_E_MisFld);
        }

        me^^COtext.text_length = 0;
        me->ret = OM_E_ABORT;
        goto quit;       
    }

    /*
     * create the local bounded system of the text object
     */

    origin_point[0] = me^^COtext.origin_button.x;
    origin_point[1] = me^^COtext.origin_button.y;
    origin_point[2] = me^^COtext.origin_button.z;

    if (!GRcreate_lbs(&temp_msg,
                      &me->ActiveAngle,
                      me^^COtext.rot_matrix,
                      origin_point,
                      &me^^COtext.text_extents,
                      &me^^COtext.lbs_geom))
    {
#ifdef DEBUG
         printf("COtexti.I err: GRcreate_lbs temp_msg = %d\n",temp_msg);
#endif
        me->ret = OM_E_ABORT;
        goto quit;
    }

    /*
     * construct object by classid
     */

    nbytes_in_buffer = sizeof(me->ModuleInfo);
    gr$get_construct_env(msg = &temp_msg,
                         point = &me^^COtext.origin_button,
                         sizbuf = &nbytes_in_buffer,
                         buffer = &me->ModuleInfo,
                         nret = &nbytes_transferred);


    status = om$construct(osnum = me^^COtext.cur_mod_osnum,
                          classid = me^^COtext.classid,
                          p_objid = &buffer.objid,
                          msg = message GRgraphics.GRconstruct(&me^^COtext.cnst_lis),
                          neighbor = OM_GS_NULL_NEIGHBOR);

    if (!(status & 1))
    {
#ifdef DEBUG
        printf("COtexti.I err: OM_construct_object_by_classid rc = %d\n", rc);
#endif
        me->ret = OM_E_ABORT;
        goto quit;
    }

    /*
     * if this is an empty text element and it is named (text length
     * doesn't equal zero), add its name to the directory subsystem
     */

    if ((me^^COtext.tx_attr.estx->flag & EMPTY_TEXT_FLAG) &&
        (me^^COtext.text_length))
    {
        status = di$add_name(objname = me^^COtext.empty_tx_name,
                             objid = buffer.objid);

        if (!(status & 1))
        {
#ifdef DEBUG
           printf("COtexti.I err: di$add_name");
#endif
           me->ret = OM_E_ABORT;
           goto quit;
        }
        me^^COtext.text_length = 0;
    }

    /*
     * display object
     */

    nbytes_in_buffer = sizeof(display_env);
    gr$get_display_env(msg = &temp_msg,
                       sizbuf = &nbytes_in_buffer,
                       buffer = &display_env,
                       nret = &nbytes_transferred);

    matr[0] = (IGRmatrix *) display_env.md_env.matrix;
    buffer.osnum = display_env.md_id.osnum;

    status = dp$display(msg = &temp_msg,
                        osnum = me^^COtext.cur_mod_osnum,
                        mode = GRbd,
                        oids = &buffer,
                        num_elem = 1,
                        mtx_type = &display_env.md_env.matrix_type,
                        matrix = matr);

    if (!(status & 1))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }
}

action is_it_empty_text()
{
    if (me^^COtext.text_length)
    {
        me->ret = GRTEXT_NOT_EMPTY;
    }
    else
    {
        me->ret = GRTEXT_EMPTY;
    }
}

action calc_angle_size()
{
    IGRlong   temp_msg;
    IGRlong   num_points;    /* number of points to xform                   */
    IGRdouble view_pnts[6];  /* input points in view coordinates            */
    IGRdouble distance;      /* distance between the two points             */
    IGRdouble unsc_length;   /* unscaled text length                        */
    IGRdouble text_angle[3]; /* angle of the text object                    */
    IGRvector text_vec;      /* vector calculated from the two input points */
    IGRvector view_x_vect;   /* x-axis vector of the view                   */
    struct extents  unscaled_extents;

    view_pnts[0] = me^^COtext.origin_button.x;
    view_pnts[1] = me^^COtext.origin_button.y;
    view_pnts[2] = me^^COtext.origin_button.z;
    view_pnts[3] = me->event1.event.button.x;
    view_pnts[4] = me->event1.event.button.y;
    view_pnts[5] = me->event1.event.button.z;

    /*
     *  find the distance between the two input points
     */

    if (!MA2ptdis(&temp_msg,view_pnts,&view_pnts[3],&distance))
    {
#ifdef DEBUG
        printf("COtexti.I err: MA2ptdis temp_msg = %d\n",temp_msg);
#endif
    }

    /*
     *  transform the input points from world to view
     *  coordinates
     */

    num_points = 2;

    if (!MAptsxform(&temp_msg,&num_points,
                    me^^COtext.wld_view_mtrx,view_pnts,view_pnts))
    {
#ifdef DEBUG
        printf("COtexti.I err: MAptsxform temp_msg = %d\n",temp_msg);
#endif
    }

    text_vec[0] = view_pnts[3] - view_pnts[0]; 
    text_vec[1] = view_pnts[4] - view_pnts[1];

    /*
     * text_vec[2] = view_pnts[5] - view_pnts[2]:
     * the above equation does not equal 0 for 
     * rotated views; just use zero
     */

    text_vec[2] = 0;

    /*
     * find the unscaled length of the text element; hard code the
     * text width argument to 1.0 so no scaling will take place
     */

    GRtx_extents(&temp_msg,
                 me^^COtext.text_string,
                 &me^^COtext.text_length,
                 &me^^COtext.font_info,
                 &me->ActiveDisplay,
                 me^^COtext.text_symb.Active_charspac,
                 me^^COtext.text_symb.Active_linespac,
                 1.0,
                 me^^COtext.text_symb.Active_height,
                 me^^COtext.text_symb.Active_font,
                 0,me^^COtext.text_length - 1,
                 &unscaled_extents);

    unsc_length = unscaled_extents.right - unscaled_extents.left;

    if (unsc_length == 0)
    {
        unsc_length = 1;
    }

    /*
     *  find the angle of the text object
     */

    view_x_vect[0] = 1;
    view_x_vect[1] = 0;
    view_x_vect[2] = 0;

    if (!MAang2vc(&temp_msg,view_x_vect,text_vec,text_angle))
    {
#ifdef DEBUG
        printf("COtexti.I err: MAang2vc temp_msg = %d\n",temp_msg);
#endif
    }

    me->ActiveAngle = text_angle[0];

    /* 
     * calculate the true extents of the text string using the unscaled length
     * and  distance; copy scaled height and width into the text symbology
     * structure
     */

    me^^COtext.text_symb.Active_height = distance / unsc_length;
    me^^COtext.text_symb.Active_width = me^^COtext.text_symb.Active_height;
}

action get_construct_attr()
{
    IGRlong         temp_msg;
    IGRlong         nbytes_in_buffer;
    IGRlong         nbytes_transferred;

    /*
     * must find the current construction attributes
     */

    nbytes_in_buffer = sizeof(me->ActiveAngle);
    gr$get_active_angle(msg = &temp_msg,
                        sizbuf = &nbytes_in_buffer,
                        buffer = &me->ActiveAngle,
                        nret = &nbytes_transferred);

    if (!(temp_msg & 1))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    nbytes_in_buffer = sizeof(me->ActiveDisplay);
    gr$get_active_display(msg = &temp_msg,
                          sizbuf = &nbytes_in_buffer,
                          buffer = &me->ActiveDisplay,
                          nret = &nbytes_transferred);

    if (!(temp_msg & 1))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    nbytes_in_buffer = sizeof(me^^COtext.cnst_lis.level);
    gr$get_active_level(msg = &temp_msg,
                        sizbuf = &nbytes_in_buffer,
                        buffer = &me^^COtext.cnst_lis.level,
                        nret = &nbytes_transferred);

    if (!(temp_msg & 1))
    {
        me->ret = OM_E_ABORT;
        goto quit;
    }

    nbytes_in_buffer = sizeof(me^^COtext.text_symb);
    gr$get_text_symb(msg = &temp_msg,
                     sizbuf = &nbytes_in_buffer,
                     buffer = &me^^COtext.text_symb,
                     nret = &nbytes_transferred);

    if (!(temp_msg & 1))
    {
        me->ret = OM_E_ABORT;
    }

    if ((me->mytype == PL_FIT_TEXT) ||
        (me->mytype == PL_VI_FIT_TEXT))
    {
        /*
         * fitted text must always be left center justified
         */

        me^^COtext.text_symb.Active_just = LEFT_CENTER;
    }
}

action named_empty_text()
{
    IGRlong                temp_msg;
    struct GRid            text_grid;     /* empty text element name      */

    status = di$translate(objname = me->event1.event.keyin,
                          p_objid = &text_grid.objid,
                          p_osnum = &text_grid.osnum);

    if (status == DIR_W_NAME_NOT_FOUND)
    {
        /*
         *  want to display the name of the
         *  element without its pathname
         */

        di$split(pathname = me->event1.event.keyin,
                 name = me^^COtext.empty_tx_name);

        /*
         *  find the length (in bytes) of the text name
         */

        me^^COtext.text_length = (IGRshort)strlen(me^^COtext.empty_tx_name);

        if (me^^COtext.text_length > me^^COtext.text_buf_size)
        {
           me^^COtext.text_string = (IGRuchar *)om$realloc(ptr = (char *) me^^COtext.text_string,
                                                                      size = (IGRint)me^^COtext.text_length);

           OM_BLOCK_MOVE(me^^COtext.empty_tx_name,
                         me^^COtext.text_string,
                         me^^COtext.text_length);

            me^^COtext.text_buf_size = me^^COtext.text_length;
        }

        if (!GRjust_string(&temp_msg,
                           &me^^COtext.text_string,
                           &me^^COtext.text_length,
                           &me^^COtext.text_buf_size,
                           &me^^COtext.font_info,
                           &me->ActiveDisplay,
                           &me^^COtext.text_symb,
                           0,NULL,
                           &me^^COtext.text_extents))
        {
 #ifdef DEBUG
            printf("COtexti.I err: GRproc_str temp_msg = %d\n",temp_msg);
 #endif
        }
        me^^COtext.text_attr.text_length = me^^COtext.text_length;
        me^^COtext.tx_attr.text_string = (IGRchar *) me^^COtext.text_string;
        me->ret = MSSUCC;
    }
    else if (status == DIR_S_SUCCESS)
    {
        ex$message(msgnumb = GR_E_NameNotUniq);
        me->ret = MSINARG;
    }
}

action empty_text_no_name()
{
    IGRdouble  tx_range;

    /*
     * find the text extents of the cross that will be displayed
     */

    tx_range = me^^COtext.text_symb.Active_height * CROSS_SIZE_FACTOR;
    me^^COtext.text_extents.top = tx_range;
    me^^COtext.text_extents.cap = tx_range;
    me^^COtext.text_extents.base = -tx_range;
    me^^COtext.text_extents.bottom = -tx_range;
    tx_range = me^^COtext.text_symb.Active_width * CROSS_SIZE_FACTOR;
    me^^COtext.text_extents.left = -tx_range;
    me^^COtext.text_extents.right = tx_range;
    me^^COtext.text_attr.flag |= EMPTY_TEXT_FLAG;
}

action set_empty_flag()
{
    me^^COtext.text_attr.flag |= EMPTY_TEXT_FLAG;
}

action check_dynamics()
{
    /*
     * check to see if dynamics is on or off
     */

    if (me^^COtext.dyn_on)
    {
        me->ret = GRdynamics_on;
    }
    else  /* dynamics is off */
    {
        me->ret = GRdynamics_off;
    }
}

/*
Action
        dyn_set_prompt (long dyn_prompt, non_dyn_prompt)

Description
        This action fills in the CEO's prompt field using one of the message
        key arguments passed in.  If dynamics is on, the prompt is filled in
        with the message corresponding to the first argument; if dynamics is
        off, the second argument is used.
*/

action dyn_set_prompt (long dyn_prompt, non_dyn_prompt)
{
    /*
     * check to see if dynamics is on or off and fill in the prompt field
     * with the appropriate message
     */

    if (me^^COtext.dyn_on)
    {
        ex$message(msgnumb = dyn_prompt,
                   buff = me^^CEO.prompt);
    }
    else  /* dynamics is off */
    {
        ex$message(msgnumb = non_dyn_prompt,
                   buff = me^^CEO.prompt);
    }
}
