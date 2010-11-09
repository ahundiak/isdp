/*
Name
        GRpuldwnlst

Description
        This collection of functions is used to provide a more flexible
        pulldown list for use with I/FORMS than the default mechanism.

History
        aet     who knows?  creation
        mrm     11/23/91    X conversion
        rlw     02/15/92    Added sparc stubs temporarily
        scw     02/29/92    Added more X conversion code
        rlw     03/11/92    Edits for journaling
        elp     01/06/93    port to NT
        elp     02/06/93    integrate WL
*/

#include "FI.h"
#include "FIdyn.h"
#include "dpgraphics.h"
#include "wl.h"
#include "exproto.h"

#include <tools.h>    /* needed for EnvironV and X versions for BUTTON_EVENT */

#ifdef  NONOBJECT
#define EX_inq_events             Inq_events
#define EX_inq_button_data        Inq_button_data
#define EX_get_button_data        Get_button_data
#endif

#define NULL             0
#define ABOVE            0
#define BELOW            1
#define MAX_ASSOC_FORMS 50
#define ASSOC_FIELD_ID  15
#define BORDER           5

#ifndef TRUE
#define TRUE             1
#endif

#ifndef FALSE
#define FALSE            0
#endif

/* forward references */
void GRlist_notify_routine();   /*  associated form notification routine */
void GRasfmbntevent();          /*  button event routine                 */
void GRasfmwinevent();          /*  window event routine                 */

/* static structure that holds the associated list forms   */

static struct GRassocform
{
    Form form_id;               /* form ptr                    */
    int  form_x_size;           /* original form x size        */
    int  form_y_size;           /* original form y size        */
    int  form_label;            /* label of form               */
    int  field;                 /* field to associate sub form */
    int  position;              /* ABOVE of BELOW field        */
    int  max_rows;              /* max number of rows          */
    int  num_vis_rows;          /* number of visible rows      */
    int  num_text_rows;         /* number of text strings      */
    Form sub_form_id;           /* form ptr of associated form */
    int  sub_form_x_size;       /* associated form org. x size */
    int  sub_form_y_size;       /* associated form org. y size */
    void (*notify_routine)();   /* notification routine        */
    void (*winevt_routine)();   /* window event routine        */
}  GRassocforms[MAX_ASSOC_FORMS];

static char TTfontname[15];
static struct standard_st gad_str;  

int GRcreate_pull_down_list(form_label,form,field,max_rows,num_vis_rows,
                            text_strings,num_text_strings,position,form_id)
int   form_label;
Form  form;
int   field;
int   max_rows;
int   num_vis_rows;
char *text_strings[];
int   num_text_strings;
int   position;
int  *form_id ;
{
    int   i;                    /* loop index                     */
    int   status = TRUE;        /* return status                  */
    int   new_form_x_pos;       /* x location of associated form  */
    int   new_form_y_pos;       /* y location of associated form  */
    int   new_form_x_size;      /* x size of associated form      */
    int   new_form_y_size;      /* y size of associated form      */
    int   num_chars;            /* num visible chars in the field */
    int   not_found = TRUE;     /* found flag                     */
    Form  new_form_id;          /* associated form ptr            */
    float bodysize;             /* bodysize of the font           */

    /* find available slot */

    for (i = 0; (i < MAX_ASSOC_FORMS) && not_found ; i++)
    {
        if (GRassocforms[i].form_id == 0)
        {
            *form_id = i;
            not_found = FALSE;
        }
    }

    if (not_found)
    {
        status = FALSE;
        goto wrapup;
    }

    if (max_rows < num_vis_rows)
    {
        num_vis_rows = max_rows;
    }

    if (num_text_strings > max_rows)
    {
        status = FALSE;
        goto wrapup;
    }
        
    /*  set up associated form info */

    not_found = TRUE;
    for (i = 0; (i < MAX_ASSOC_FORMS) && not_found ; i++)
    {
        if (GRassocforms[i].form_id == form)
        {
            GRassocforms[*form_id].winevt_routine =
                GRassocforms[i].winevt_routine;
            not_found = FALSE;
        }
    }

    if (not_found)
    {
        if (FIf_get_window_event_routine
            (form,&GRassocforms[*form_id].winevt_routine))
        {
            GRassocforms[*form_id].winevt_routine = NULL;
        }
        else
        {
            if (GRassocforms[*form_id].winevt_routine == GRasfmwinevent)
            {
                GRassocforms[*form_id].winevt_routine = NULL;
            }
        }
    }


    GRassocforms[*form_id].form_id = form;
    GRassocforms[*form_id].form_label = form_label;
    GRassocforms[*form_id].field = field;
    GRassocforms[*form_id].position = position;
    FIf_get_notification_routine(form,&GRassocforms[*form_id].notify_routine);

    GRassocforms[*form_id].max_rows = max_rows;
    GRassocforms[*form_id].num_text_rows = num_text_strings;
    GRassocforms[*form_id].num_vis_rows = num_vis_rows;

    /*  get associated forms location and size */

    GRgetassocpos(form,field,num_vis_rows,max_rows,position,
                  &new_form_x_pos,&new_form_y_pos,
                  &new_form_x_size,&new_form_y_size);

    /*  create new form and set size and location  */

    FIf_new(2,"",GRlist_notify_routine,&new_form_id);
    GRassocforms[*form_id].sub_form_id = new_form_id;
        
    FIf_set_location(new_form_id,new_form_x_pos,new_form_y_pos);
    FIf_set_size(new_form_id,new_form_x_size,new_form_y_size);

    /*  get original size of form  (used when form is scaled) */

    FIf_get_size(form,&GRassocforms[*form_id].form_x_size,
                 &GRassocforms[*form_id].form_y_size);

    GRassocforms[*form_id].sub_form_x_size = new_form_x_size;
    GRassocforms[*form_id].sub_form_y_size = new_form_y_size;

    /*  define associated form attributes */

    FIf_set_attr(new_form_id,FI_SAVE_RESTORE | FI_NO_BEZEL | FI_LINE_BORDER);

    /*  create associated form field */

    FIg_new(new_form_id,FI_FIELD,ASSOC_FIELD_ID);

    /*  calculate field location and size */

    gad_str.xlo = BORDER;
    gad_str.ylo = BORDER;
    gad_str.yhi = gad_str.ylo + new_form_y_size - (2 * BORDER);

    /*  set up font information */

    FIg_get_font(form,field,TTfontname,&bodysize);
    gad_str.bodysize = bodysize;
    gad_str.fontname = TTfontname;

    gad_str.off_color = FI_BLACK;
    gad_str.on_color = FI_YELLOW;


    FIg_set_standard_variables(new_form_id,ASSOC_FIELD_ID,&gad_str);

    /*  see if a vertical scroll is needed                */

    if (max_rows > num_vis_rows)
    {
        FIfld_set_attr(new_form_id, ASSOC_FIELD_ID, 0,
                       FI_VERT_SCROLL | FI_DISPLAY_VSCROLL);
    }

    /*  set up field type and mode        */
    FIfld_set_type(new_form_id,ASSOC_FIELD_ID,0,FI_ALPHA);
    FIfld_set_mode(new_form_id,ASSOC_FIELD_ID,0,FI_SINGLE_SELECT);

    /*  set up row information  */

    FIfld_set_num_vis_rows(new_form_id,ASSOC_FIELD_ID,num_vis_rows);
    FIfld_set_max_num_rows(new_form_id,ASSOC_FIELD_ID,max_rows);

    /*  make associated field the same num of visible characters as field
        on main form */

    FIfld_get_num_vis_chars(form,field,0,&num_chars);
    FIfld_set_num_vis_chars(new_form_id,ASSOC_FIELD_ID,0,num_chars);

    /*  set up the text */

    for (i = 0; i < num_text_strings; i++)
    {
        FIfld_set_text(new_form_id,ASSOC_FIELD_ID,i,0,
                       text_strings[i],FALSE);
    }

    FIg_activate(new_form_id,ASSOC_FIELD_ID);

    FIg_display(new_form_id,ASSOC_FIELD_ID);

    /* set up button routine */

    FIf_set_button_intercept_routine(new_form_id,GRasfmbntevent);

    /* set up window routine */

    FIf_set_window_event_routine(form,GRasfmwinevent);

wrapup:

    return(status);
}



int GRgetassocpos(form,field,num_vis_rows,max_rows,position,
                  new_form_x_pos,new_form_y_pos,
                  new_form_x_size,new_form_y_size)
Form  form;
int   field;
int   num_vis_rows;
int   max_rows;
int   position;
int  *new_form_x_pos;
int  *new_form_y_pos;
int  *new_form_x_size;
int  *new_form_y_size;
{

    int status = TRUE;          /* return status         */
    int xpos,ypos;              /* location of main form */
    int fxpos,fypos;
    int xsize,ysize;
    int line_height;

    FIf_get_location(form,&xpos,&ypos);

    FIg_get_location(form,field,&fxpos,&fypos);
    FIg_get_size(form,field,&xsize,&ysize);

    *new_form_x_pos = xpos + fxpos - BORDER;
    *new_form_x_size = xsize + (2 * BORDER);

    FIfld_get_row_height(form,field,&line_height);

    *new_form_y_size = (num_vis_rows * line_height) + 
        (2 * BORDER);

    if (position == ABOVE)
    {
        *new_form_y_pos = ypos + fypos - (num_vis_rows * line_height)
            - (2 * BORDER);
    }
    else
    {
        *new_form_y_pos = ypos + fypos + line_height + BORDER;
    }

    if (max_rows > num_vis_rows)
    {
        /* add room for scroll bars  */

        if (num_vis_rows == 1)
        {
            *new_form_x_size += 50;
        }
        else
        {
            *new_form_x_size += 25;
        }
    }

    return(status);
}


        
void  GRasfmbntevent(form,xpos,ypos,button_number,transition,time_tag)
Form form;
int  xpos;
int  ypos;
int  button_number;
int  transition;
int  time_tag;
{
#ifdef X11
    if (button_number == Button3)
#else
    if (button_number == RIGHT_BUTTON)
#endif
    {
        FIf_erase(form);
    }
    else
    {
        FIf_process_point(form,xpos,ypos,button_number,transition,time_tag);
    }
}


void  GRasfmwinevent(form_label,event,form)
int  form_label;
int  event;
Form form;
{
    int    i;
    int    xpos,ypos;
    int    g_xpos,g_ypos;
    int    xsize,ysize;
    int    fld_x_size,fld_y_size;
    int    sf_xsize;
    int    sf_ysize;
    int    form_mask;
    int    screen;
    int    found_id = 0;
    int    found;
    double xscale,yscale;

    found = FALSE;

    for (i=0 ;( i < MAX_ASSOC_FORMS) && !found; i++)
    {
        if (GRassocforms[i].form_id == form)
        {
            found_id = i;
            found = TRUE;
        }
    }


    if ((event == FI_CHANGED_LOCATION) ||
        (event == FI_CHANGED_SIZE))
    {
        for (i=0 ; i < MAX_ASSOC_FORMS; i++)
        {

            if (GRassocforms[i].form_id == form)
            {

                FIf_get_location(GRassocforms[i].form_id,&xpos,&ypos);
                FIf_get_screen(GRassocforms[i].form_id,&screen);
                FIg_get_location(GRassocforms[i].form_id,
                                 GRassocforms[i].field,&g_xpos,&g_ypos);


                xpos += g_xpos;
                ypos += g_ypos;

                FIg_get_size(GRassocforms[i].form_id,
                             GRassocforms[i].field,
                             &fld_x_size,&fld_y_size);



                FIf_get_size(GRassocforms[i].form_id,&xsize,&ysize);

                FIf_get_attr(GRassocforms[i].form_id,&form_mask);

                if (form_mask & FI_NOT_SCALABLE)
                {
                    xscale = 1.0;
                    yscale = 1.0;
                }
                else
                {
                    xscale = (double) xsize /
                             (double) GRassocforms[i].form_x_size;
                    yscale = (double) ysize /
                             (double) GRassocforms[i].form_y_size;
                }

                sf_xsize = (double) GRassocforms[i].sub_form_x_size * xscale;
                sf_ysize = (double) GRassocforms[i].sub_form_y_size * yscale;

                if (GRassocforms[i].position == ABOVE)
                {
                    ypos -= sf_ysize;
                }
                else
                {
                    ypos += fld_y_size;
                }

                FIf_set_location(GRassocforms[i].sub_form_id,xpos,ypos);
#if ! defined( NT )
                FIf_set_screen(GRassocforms[i].sub_form_id,screen);
#endif
                FIf_set_size(GRassocforms[i].sub_form_id,sf_xsize,
                             sf_ysize);
            }
        }
    }

    if (found)
    {
        if (GRassocforms[found_id].winevt_routine)
        {
            (*GRassocforms[found_id].winevt_routine)(form_label,event,form);
        }
    }
}
        

/*ARGSUSED*/
void GRlist_notify_routine(
int    form_label,
int    gadget_label,
double value,
Form   form)
{
    int  i;
    int  found = FALSE;
    int  found_form = 0;
    char text[132]; 

    for (i=0 ;(i < MAX_ASSOC_FORMS) && !found; i++)
    {
        if (GRassocforms[i].sub_form_id == form)
        {
            found_form = i;
            found = TRUE;
        }
    }

    if (found)
    {
        if (gadget_label == 15)
        {
            FIf_erase(form);
            FIg_get_text(form,gadget_label,text);
            FIfld_set_select(form,gadget_label,(int) value,0,FALSE);
            FIg_set_text(GRassocforms[found_form].form_id,
                         GRassocforms[found_form].field,text);

            value += 1.0;
            (*GRassocforms[found_form].notify_routine)
                (GRassocforms[found_form].form_label,
                 GRassocforms[found_form].field,
                 value,
                 GRassocforms[found_form].form_id);

        }
    }
}

int GRproc_pull_down_list(form_no)
int form_no;
{
    int    status = TRUE;
    Form   form;
    int    line_height;
    double xsize,ysize;
    double xloc,yloc;
    float  fld_xlo,fld_ylo,fld_xhi,fld_yhi;
    int    win_no;
    int    mask;
    int    new_win_no;
    int    x,y;
    int    roff;
    int    button;
    int    trans;
    int    timetag;
    int    scroll = FALSE;
    int    auto_scroll = FALSE;
    int    work_status;
    int    field_row;
    int    num_vis_rows;
    int    num_text_rows;
    int    old_field_row = -1;
#ifdef X11
    int          sts;
    int          root_x,root_y;
    unsigned int keys_buttons;
    Window       root_w, child_w;
    XEvent       event;
#endif

    if (form_no < MAX_ASSOC_FORMS)
    {
        if (GRassocforms[form_no].form_id)
        {
            num_vis_rows = GRassocforms[form_no].num_vis_rows;

            if (num_vis_rows <  GRassocforms[form_no].max_rows)
            {
                scroll = TRUE;
            }

            form = GRassocforms[form_no].sub_form_id;

            num_text_rows = GRassocforms[form_no].num_text_rows;
            FIf_display(form);

            FIg_get_dlocation(form,ASSOC_FIELD_ID,&xloc,&yloc);
            FIg_get_dsize(form,ASSOC_FIELD_ID,&xsize,&ysize);
            FIfld_get_row_offset(form,ASSOC_FIELD_ID,&roff);

            fld_xlo = xloc;
            fld_ylo = yloc;
        
            fld_xhi = xloc + xsize;
            fld_yhi = yloc + ysize;

            FIfld_get_row_height(form,ASSOC_FIELD_ID,&line_height);

            FIf_get_window(form,&win_no);
                                
            while(1)
            {
#ifdef X11
                /* check for (and eat) a button event */
                sts = JNL_XCheckMaskEvent(EXdisplay,
                                          ButtonPressMask | ButtonReleaseMask,
                                          &event);
                x       = event.xbutton.x;
                y       = event.xbutton.y;
                trans   = event.xbutton.state;
                timetag = event.xbutton.time;
                new_win_no = event.xbutton.window;

                if (sts)
#else
                /* check for button event */
                EX_inq_events(&mask);
                if (mask & BUTTON_EVENT)
#endif
                {
#ifndef X11
                    EX_inq_button_data(&new_win_no,&x,&y,&button,&trans,
                                       &timetag);
#endif

#ifdef X11
                    if (event.xbutton.button != Button1)
#else
                    if (button != LEFT_BUTTON)
#endif
                    {
#ifdef X11
                        if (event.xbutton.button == Button3)
#else
                        if (button == RIGHT_BUTTON)
#endif
                        {
                            if (old_field_row != -1)
                            {
                                FIfld_set_select(form, ASSOC_FIELD_ID,
                                                 old_field_row, 0, FALSE);
                                old_field_row = -1;
                            }
                            break;
                        }
                        else
                        {
                            if ((x >= fld_xlo) && (x <= fld_xhi) && 
                                (y >= fld_ylo) && (y <= fld_yhi))
                            {
                                field_row = (y - (int)fld_ylo) /
                                            (double)line_height;
                                if (scroll)
                                {
                                    if (field_row < num_vis_rows)
                                    {
                                        field_row += roff;
                                        if (field_row < num_text_rows)
                                        {
                                            if (old_field_row != -1)
                                            {
                                                FIfld_set_select(form,
                                                                 ASSOC_FIELD_ID,
                                                                 old_field_row,
                                                                 0, FALSE);
                                                old_field_row = -1;
                                            }
#ifdef X11
                                                JNL_XPutBackEvent(EXdisplay,
                                                                  &event);
#endif
                                            break;
                                        }
                                    }
                                }
                                else
                                {
                                    if (field_row < num_text_rows)
                                    {
                                        if (old_field_row != -1)
                                        {
                                            FIfld_set_select(form,
                                                             ASSOC_FIELD_ID,
                                                             old_field_row,
                                                             0, FALSE);
                                            old_field_row = -1;
                                        }
#ifdef X11
                                            JNL_XPutBackEvent(EXdisplay,
                                                              &event);
#endif
                                        break;
                                    }
                                }
                            }
                            else
                            {
                                if (trans == DOWN)
                                {
#ifndef X11
                                    EX_get_button_data(&new_win_no, &x, &y,
                                                       &button, &trans, 
                                                       &timetag);
#endif
                                    while(1)
                                    {
                                        FIf_process_point(form,x,y,button,
                                                          trans, timetag);

                                        FIfld_get_row_offset(form,
                                                             ASSOC_FIELD_ID,
                                                             &roff);
#ifndef X11
                                        EX_inq_events(&mask);
                                        if (mask & BUTTON_EVENT)
#endif
                                        {
                                            break;
                                        }
                                    }
                                }
                                else
                                {
                                    FIf_process_point(form,x,y,button,trans,
                                                      timetag);

                                    FIfld_get_row_offset(form,ASSOC_FIELD_ID,
                                                         &roff);
                                }
                            }
                        }
                    }
#ifndef X11
                    EX_get_button_data(&new_win_no,&x,&y,&button,&trans,
                                       &timetag);
#endif
                }
#ifdef X11
                else
                {
                    new_win_no = win_no;
                }
#endif

#ifdef X11
                work_status = XQueryPointer(EXdisplay, new_win_no,
                                            &root_w, &child_w,
                                            &root_x, &root_y,
                                            &x, &y, &keys_buttons);
#else
                Mouseposition(win_no,&x,&y,&work_status);
#endif
                if ((work_status) && (x >= fld_xlo) && (x <= fld_xhi) && 
                    (y >= fld_ylo) && (y <= fld_yhi))
                {
                    field_row = (y - (int)fld_ylo)/(double)line_height;
                    if (scroll)
                    {
                        field_row += roff;
                    }
                    if (old_field_row != field_row)
                    {
                        if (field_row < num_text_rows)
                        {
                            old_field_row = field_row;
                            auto_scroll = TRUE;
                            FIfld_set_select(form,ASSOC_FIELD_ID,field_row,
                                             0,TRUE);
                        }
                        else
                        {
                            if (old_field_row != -1)
                            {
                                FIfld_set_select(form,ASSOC_FIELD_ID,
                                                 old_field_row,0,FALSE);
                                old_field_row = -1;
                            }
                        }
                    }
                }
                else
                {
                    if (old_field_row != -1)
                    {
                        FIfld_set_select(form,ASSOC_FIELD_ID,old_field_row,
                                         0,FALSE);
                        old_field_row = -1;
                    }
                    if (scroll && auto_scroll)
                    {
                        if ((x >= fld_xlo) && (x <= fld_xhi))
                        {
                            if (y < fld_ylo)
                            {
                                if (roff > 0)
                                {
#ifdef X11
                                    if (sts)
                                        JNL_XPutBackEvent(EXdisplay,&event);
#endif
                                    FIfld_set_active_row(form,ASSOC_FIELD_ID,
                                                         --roff,0);
                                }
                            }
                            else
                            {
                                if (y > fld_yhi)
                                {
                                    if ((roff + num_vis_rows) <
                                        num_text_rows)
                                    {
#ifdef X11
                                        if (sts)
                                            JNL_XPutBackEvent(EXdisplay,&event);
#endif
                                        FIfld_set_active_row(form,
                                                             ASSOC_FIELD_ID,
                                                             ++roff,0);
                                    }
                                }
                            }
                        }
                    }
                }
            }                   /* end while */
        }
        else
        {
            status = FALSE;
        }
    }
    else
    {
        status = FALSE;
    }

    return(status);
}

int GRchange_pull_down_text(form_no,text,num_text)
int    form_no;
char **text;
int    num_text;
{
    int status = TRUE;
    int i;

    if (form_no < MAX_ASSOC_FORMS)
    {
        if (GRassocforms[form_no].form_id)
        {
            if (num_text > GRassocforms[form_no].max_rows)
            {
                num_text = GRassocforms[form_no].max_rows;
            }

            GRassocforms[form_no].num_text_rows = num_text;

            for (i = 0; i < num_text; i++)
            {
                FIfld_set_text(GRassocforms[form_no].sub_form_id,
                               ASSOC_FIELD_ID,i,0,text[i],FALSE);
            }

            for (i = num_text; i < GRassocforms[form_no].max_rows; i++)
            {
                FIfld_set_text(GRassocforms[form_no].sub_form_id,
                               ASSOC_FIELD_ID,i,0,"",FALSE);
            }
        }
        else
        {
            status = FALSE;
        }
    }
    else
    {
        status = FALSE;
    }

    return(status);
}

int GRdelete_pull_down_list(form_no)
int form_no;
{
    int status = TRUE;

    if (form_no < MAX_ASSOC_FORMS)
    {
        if (GRassocforms[form_no].form_id)
        {
            FIf_delete(GRassocforms[form_no].sub_form_id);
            GRassocforms[form_no].form_id = 0;
        }
    }
    else
    {
        status = FALSE;
    }

    return(status);
}
