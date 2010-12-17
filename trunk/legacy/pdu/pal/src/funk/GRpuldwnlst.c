/* file : GRpuldwnlst.c */
#include <stdio.h>
#include "FIdyn.h"
#if defined (__sgi) || defined (__Sol2__) || defined (sparc)
#include <XFIproto_pub.h>
#else
#include <FIproto_pub.h>
#endif
#ifdef ENV5
#include <tools.h>
#endif
#ifdef bld21
#include "FI.h"
#endif

/* #ifdef  NONOBJECT */
#define EX_inq_events	Inq_events
#define EX_inq_button_data	Inq_button_data
#define EX_get_button_data	Get_button_data
 /* #endif */

#define ABOVE	0
#define BELOW	1
#define	MAX_ASSOC_FORMS	5
#define ASSOC_FIELD_ID	1
#define BORDER		5
#ifndef TRUE
#define TRUE	1
#endif

#ifndef FALSE
#define FALSE	0
#endif

/* static structure that holds the associated list forms   */

static 	struct GRassocform
	{
	    Form	form_id;	/*  form ptr  			*/
	    int		form_x_size;	/*  original form x size 	*/
	    int		form_y_size;	/*  original form y size 	*/
	    int		form_label;	/*  label of form	 	*/
	    int		field1;		/*  field to associate sub form */

	    /* PB management of multi column field */
	    int 	mcf_flag1; 	/* multi column field indicator	*/
	    int 	row1;		/* processed row 		*/
	    int 	pos1;		/* relative row in the window	*/
	    int 	col1; 		/* column to display sub-form 	*/
	    int		field2;		/*  field to associate sub form */
	    int 	mcf_flag2; 	/* multi column field indicator	*/
	    int 	row2;		/* processed row 		*/
	    int 	pos2;		/* relative row in the window	*/
	    int 	col2;	 	/* column to put the result	*/

	    int		position;	/*  ABOVE of BELOW field	*/
	    int		max_rows;	/*  max number of rows		*/
	    int		num_vis_rows;	/*  number of visible rows	*/
	    int		num_text_rows;	/*  number of text strings	*/
	    Form	sub_form_id;	/*  form ptr of associated form */
	    int		sub_form_x_size;/*  associated form org. x size */
	    int		sub_form_y_size;/*  associated form org. y size */
	    int		(*notify_routine)();/* notification routine	*/
	    int		(*winevt_routine)();/* window event routine	*/
	}  GRassocforms[MAX_ASSOC_FORMS];

static    char TTfontname[15];
static    struct standard_st   gad_str;  

int	SGcreate_pull_down_list(form_label,form,
		    field1, mcf_flag1,row1,pos1,col1,
		    field2, mcf_flag2,row2,pos2,col2,
		    max_rows,num_vis_rows,text_strings,
		    num_text_strings,position,form_id)

    int		form_label;
    Form	form;
    int		field1;
    int 	mcf_flag1;
    int 	row1;
    int 	pos1;
    int		col1;
    int		field2;
    int 	mcf_flag2;
    int 	row2;
    int 	pos2;
    int 	col2;
    int		max_rows;
    int		num_vis_rows;
    char	*text_strings[];
    int		num_text_strings;
    int		position;
    int		*form_id ;

{

    int i;		/* loop index 				*/
    int status = TRUE;	/* return status 			*/
    int new_form_x_pos; /* x location of associated form	*/
    int new_form_y_pos; /* y location of associated form	*/
    int new_form_x_size;/* x size of associated form		*/
    int new_form_y_size;/* y size of associated form		*/
    int num_chars;	/* num visible chars in the field	*/
    int not_found = TRUE;/* found flag				*/
    Form new_form_id;   /* associated form ptr			*/
    float bodysize;	/* bodysize of the font			*/

    int l;		/* length of text_strings		*/
    int col0_num_chars;	/* width of column 0 			*/
    int col0_xsize; 	/*size of column0 			*/
    int g_xsize; 	/*size of associated gadget		*/

    int	PALlist_notify_routine(); /*  associated form notification routine */
    int	PALasfmbntevent();	     /*  button event routine		      */
    int	PALasfmwinevent();	     /*  window event routine		      */

   /* find available slot	*/

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
	
/*  PB make associated gadget length as the longest text_string (+1) */

	num_chars= 0;
	for (i = 0; i < num_text_strings; i++)
	  {
	   l= strlen (text_strings[i]);
	   if (l > num_chars) num_chars= l;
	  }
	num_chars ++;

/* PB find associated gadget size for num_chars */

	FIfld_get_num_vis_chars (form, field1, 0, &col0_num_chars);
	if (mcf_flag1 == 1)
	   FImcf_get_col_size      (form, field1, 0, &col0_xsize, &i);
	else
	   FIg_get_size      (form, field1, &col0_xsize, &i);
	g_xsize= (col0_xsize/col0_num_chars)*num_chars;

/* KK added for SUN */

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
            if (GRassocforms[*form_id].winevt_routine == PALasfmwinevent)
            {
                GRassocforms[*form_id].winevt_routine = NULL;
            }
        }
    }

/*  set up associated form info	*/

	GRassocforms[*form_id].form_id = form;
	GRassocforms[*form_id].form_label = form_label;
	GRassocforms[*form_id].field1 = field1;
        /* PB initialize new attributes */
        GRassocforms[*form_id].mcf_flag1= mcf_flag1;
        GRassocforms[*form_id].row1= row1;
        GRassocforms[*form_id].pos1= pos1;
        GRassocforms[*form_id].col1= col1;
	GRassocforms[*form_id].field2 = field2;
        GRassocforms[*form_id].mcf_flag2= mcf_flag2;
        GRassocforms[*form_id].row2= row2;
        GRassocforms[*form_id].pos2= pos2;
        GRassocforms[*form_id].col2= col2;

	GRassocforms[*form_id].position = position;
	FIf_get_notification_routine(form,&GRassocforms[*form_id].notify_routine);
	GRassocforms[*form_id].max_rows = max_rows;
	GRassocforms[*form_id].num_text_rows = num_text_strings;
	GRassocforms[*form_id].num_vis_rows = num_vis_rows;


/*  get associated forms location and size	*/

	PALgetassocpos(form,field1,
		      mcf_flag1,row1,pos1,col1,
		      num_vis_rows,max_rows,position,&new_form_x_pos,&new_form_y_pos,
		      &new_form_x_size,&new_form_y_size);

/*  create new form and set size and location  */

	status = FIf_new(2,"",PALlist_notify_routine,&new_form_id);

	GRassocforms[*form_id].sub_form_id = new_form_id;
	
	FIf_set_location(new_form_id,new_form_x_pos,new_form_y_pos);

	/* PB override x_size */
        new_form_x_size=g_xsize+ 2*BORDER;
 	/* PB space for scroll bar */
	if (max_rows > num_vis_rows)
	   if (num_vis_rows == 1)
	      new_form_x_size += 50;
	   else
	      new_form_x_size += 25;

	FIf_set_size(new_form_id,new_form_x_size,new_form_y_size);

/*  get original size of form  (used when form is scaled) */

	FIf_get_size(form,&GRassocforms[*form_id].form_x_size,&GRassocforms[*form_id].form_y_size);

	GRassocforms[*form_id].sub_form_x_size = new_form_x_size;
	GRassocforms[*form_id].sub_form_y_size = new_form_y_size;

/*  define associated form attributes	*/

	FIf_set_attr(new_form_id,FI_SAVE_RESTORE | FI_NO_BEZEL | FI_LINE_BORDER);

/*  create associated form field	*/

	status = FIg_new(new_form_id,FI_FIELD,ASSOC_FIELD_ID);

/*  calculate field location and size	*/

	gad_str.xlo = BORDER;
	gad_str.ylo = BORDER;
	gad_str.yhi = gad_str.ylo + new_form_y_size - (2 * BORDER);

/*  set up font information	*/

	FIg_get_font(form,field1,TTfontname,&bodysize);
	gad_str.bodysize = bodysize;
	gad_str.fontname = TTfontname;

	gad_str.off_color = FI_BLACK;
	gad_str.on_color = FI_WHITE;


	FIg_set_standard_variables(new_form_id,ASSOC_FIELD_ID,&gad_str);

/*  see if a vertical scroll is needed		*/

	if (max_rows > num_vis_rows)
	{
	   FIfld_set_attr(new_form_id,ASSOC_FIELD_ID,0,FI_VERT_SCROLL | FI_DISPLAY_VSCROLL);
	}

/*  set up field type and mode	*/
	FIfld_set_type(new_form_id,ASSOC_FIELD_ID,0,FI_ALPHA);
	FIfld_set_mode(new_form_id,ASSOC_FIELD_ID,0,FI_SINGLE_SELECT);

/*  set up row information  */

	FIfld_set_num_vis_rows(new_form_id,ASSOC_FIELD_ID,num_vis_rows);
	FIfld_set_max_num_rows(new_form_id,ASSOC_FIELD_ID,max_rows);

/*  make associated field the same num of visible characters as field
    on main form */
			
	/* PB			
	FIfld_get_num_vis_chars(form,field1,0,&num_chars);
        */

	FIfld_set_num_vis_chars(new_form_id,ASSOC_FIELD_ID,0,num_chars);

/*  set up the text	*/

	for (i = 0; i < num_text_strings; i++)
	    FIfld_set_text(new_form_id,ASSOC_FIELD_ID,i,0,
				    text_strings[i],FALSE);



	FIg_activate(new_form_id,ASSOC_FIELD_ID);

	status = FIg_display(new_form_id,ASSOC_FIELD_ID);

/* set up button routine */

	FIf_set_button_intercept_routine(new_form_id,PALasfmbntevent);

/* set up window routine   */

	FIf_set_window_event_routine(form,PALasfmwinevent);

wrapup:
	return(status);
}

/* eof : GRpuldwnlst.c */
