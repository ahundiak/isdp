/***********************************

  		toolbox.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; casted func args
*/

#include <sys/types.h> /*** need these two for stat() call ***/
#include <sys/stat.h>
#include <dirent.h>
#include <stdio.h>

#include <X11/Xlib.h>

#include "FI.h"
#include "FEI.h"
#include "FIdyn.h"
#include "NFBpriv.h"
#include "UMS.h"
#include "FB.h"

#include "XFIproto_pub.h"
#include "XFIproto_pri.h"
#include "XFBproto_pri.h"

extern struct dpb_struct dpb;
extern Form work_form;
extern struct gadget_struct gadget_attr;
extern struct standard_st default_attr;
extern Form Font_form;

extern Display *display;
extern GC xfb_GC;
extern XGCValues GC_values;
extern int hilite_plane;

extern int font_count;
extern Font Font_array[200];

#define TYPEFACE_LIST_FLD 22

/* static void Build_characteristics_value(); */

/*----------------------------------------------------------------------*/

static void Build_characteristics_value (int *characteristics)
{
  *characteristics = 0;

  if (gadget_attr.display == 0)
    *characteristics |= FI_NOT_DISPLAYED;

  if (gadget_attr.selectable == 0)
    *characteristics |= FI_NOT_ENABLED;

  if (gadget_attr.hilite == 1)
    *characteristics |= FI_HILITED;

  if (gadget_attr.dither == 1)
    *characteristics |= FI_NO_DITHERING;

  if (gadget_attr.initial_notify == 1)
    *characteristics |= FI_INITIAL_NOTIFY;

  if (gadget_attr.complete_notify == 0)
    *characteristics |= FI_NO_COMPLETE_NOTIFY;

  if (gadget_attr.help == 1)
    *characteristics |= FI_HELP_TOPIC;

  if ((gadget_attr.cmd_string == 1) &&
    (gadget_attr.command_string[0] != (char) NULL))
    *characteristics |= FI_CMD_STRING;

  if ((gadget_attr.cmd_key == 1) &&
      (gadget_attr.command_string[0] != (char) NULL))
    *characteristics |= FI_CMD_KEY;

  if (gadget_attr.text_gadget == 1)
    *characteristics |= FI_TEXT_GADGET;

  if (gadget_attr.vert_scroll_notify)
    *characteristics |= FI_VERT_SCROLL_NOTIFY;
}

/*-------------------------------------------------------------------------*/

void Set_new_gadget_defaults(void)
{
  int new_label;

  gadget_attr.display = 1;
  gadget_attr.selectable = 1;
  gadget_attr.hilite = 0;
  gadget_attr.dither = 0;
  gadget_attr.initial_notify = 0;
  gadget_attr.complete_notify = 1;
  gadget_attr.help = 0;
  gadget_attr.cmd_string = 0;
  gadget_attr.data = 0;
  gadget_attr.cmd_key = 0;
  gadget_attr.text_string = 0;
  gadget_attr.text_gadget = 1;
  gadget_attr.vert_scroll_notify = 0;

  strcpy (gadget_attr.font_name, dpb.font_name);
  gadget_attr.bodysize = dpb.bodysize;
  gadget_attr.text_style = dpb.text_style;
  gadget_attr.text_justification = dpb.text_justification;

  gadget_attr.on_color = dpb.on_color;
  gadget_attr.off_color = dpb.off_color;

  gadget_attr.line_weight = dpb.line_weight;
  gadget_attr.line_style = dpb.line_style;
  gadget_attr.line_depth = dpb.line_depth;

  gadget_attr.command_string[0] = '\0';
  gadget_attr.help_topic[0] = '\0';

  FIf_get_next_label (work_form, &new_label);
  gadget_attr.gadget_label = new_label;
}


/*-----------------------------------------------------------------------*/

void Create_and_init_gadget (Form form,
                             int gadget_type,
                             int new_label)
{
  int characteristics;
  int status;
  char empty_string[100];


  status = FIg_new (form, gadget_type, new_label);

  if (status != FI_SUCCESS)
  {
    char error_string[1000];

    UMSGetByNum (error_string, FB_E_BADSTSNEW, "%d", status);
    Report_nonfatal_error (error_string);
  }

  empty_string[0] = '\0'; /* NULL string */

  /********************************/
  /* */
  /* Set up generic gadget data */
  /* */
  /********************************/

  default_attr.xlo = gadget_attr.x_pos;
  default_attr.ylo = gadget_attr.y_pos;
  default_attr.xhi = gadget_attr.x_size;
  default_attr.yhi = gadget_attr.y_size;

  default_attr.attr_mask = characteristics;
  default_attr.value = gadget_attr.default_value;
  default_attr.bodysize = (float)gadget_attr.bodysize;

  default_attr.text = gadget_attr.off_text;
  default_attr.help_topic = gadget_attr.help_topic;
  default_attr.command = gadget_attr.command_string;

  default_attr.fontname = gadget_attr.font_name;
  default_attr.user_pointer = empty_string;

  default_attr.off_color = gadget_attr.off_color;
  default_attr.on_color = gadget_attr.on_color;

  default_attr.off_color2 = 0; /* Reserved for future use */
  default_attr.on_color2 = 0; /* Reserved for future use */

  default_attr.symbol_index = gadget_attr.off_sym_index;

  FIg_set_standard_variables (form, new_label, &default_attr);

  Build_characteristics_value (&characteristics);

  FIg_set_attr (form, new_label, characteristics);

  FIg_set_default_attr ((struct FIform_obj *)form, new_label, characteristics);

  /* This is new 10/21/89 */

  _FI_g_verify_erase_color ((struct FIform_obj *)form, new_label, FI_FORM_GROUP);
}


/*-----------------------------------------------------------------------*/

int forms_intersect (Form form1, Form form2)
{
  int form1_xpos, form1_ypos, form1_xsize, form1_ysize;
  int form2_xpos, form2_ypos, form2_xsize, form2_ysize;
  int form1_xhigh, form1_yhigh, form2_xhigh, form2_yhigh;

  FIf_get_location (form1, &form1_xpos, &form1_ypos);
  FIf_get_size (form1, &form1_xsize, &form1_ysize);
  form1_xhigh = form1_xpos + form1_xsize;
  form1_yhigh = form1_ypos + form1_ysize;

  FIf_get_location (form2, &form2_xpos, &form2_ypos);
  FIf_get_size (form2, &form2_xsize, &form2_ysize);
  form2_xhigh = form2_xpos + form2_xsize;
  form2_yhigh = form2_ypos + form2_ysize;

  /**************************************************************/
  /* */
  /* If one of form1's X endpoints falls within the range of */
  /* form2's X endpoints, and one of form1's Y endpoints falls */
  /* within the range of form2's Y endpoints then the forms */
  /* intersect. */
  /* Also if both endpoints fall entirely within the limits of */
  /* the other form's endpoints. */
  /* */
  /**************************************************************/

  if (((form1_xpos >= form2_xpos) && (form1_xpos <= form2_xhigh)) ||
      ((form1_xhigh >= form2_xpos) && (form1_xhigh <= form2_xhigh)) ||
      ((form1_xpos >= form2_xpos) && (form1_xhigh <= form2_xhigh)) ||
      ((form2_xpos >= form1_xpos) && (form2_xhigh <= form1_xhigh)))
  {
    if (((form1_ypos >= form2_ypos) && (form1_ypos <= form2_yhigh)) ||
        ((form1_yhigh >= form2_ypos) && (form1_yhigh <= form2_yhigh)) ||
        ((form1_ypos >= form2_ypos) && (form1_yhigh <= form2_yhigh)) ||
        ((form2_ypos >= form1_ypos) && (form2_yhigh <= form1_yhigh)))
    {
      return(1);
    }
    else
    {
      return(0);
    }
  }
  else
  {
    return(0);
  }
}

/*--------------------------------------------------------------------------*/

void Refresh_work_form(void)
{
  Redisplay (work_form);
}

/*--------------------------------------------------------------------------*/

void Report_fatal_form_error (int status,
                              char *file_string)
{
  char error_string[1000];
  char extra_string[200];

  UMSGetByNum (error_string, FB_E_STATUS, "%d", status);
  strcat (error_string, "\n");

  if (status == FI_FORM_FILE_NOT_FOUND)
  {
    UMSGetByNum (extra_string, FB_E_CANTLOCATE, "%s", file_string);
  }
  else
  {
    UMSGetByNum (extra_string, FB_E_BADFORMAT, "%s", file_string);
  }

  strcat (error_string, extra_string);

  FI_message_box (FI_CURRENT_SCREEN, -1, -1, "Fatal Error",
      FI_RED, "swiss742b", 25.0,
      error_string, FI_BLACK, "swiss742b", 25.0,
      FI_LEFT_JUSTIFIED, 60);

  fprintf (stderr, "Exiting due to Report_fatal_form_error\n");
  exit (1);
}

/*--------------------------------------------------------------------------*/

void Report_fatal_error (char *error_string)
{

  FI_message_box (FI_CURRENT_SCREEN, -1, -1, "Fatal Error",
      FI_RED, "swiss742b", 25.0,
      error_string, FI_BLACK, "swiss742b", 25.0,
      FI_LEFT_JUSTIFIED, 60);

  fprintf (stderr, "exiting due to Report_fatal_error\n");
  exit (1);
}
/*--------------------------------------------------------------------------*/

void Report_nonfatal_error (char *error_string)
{
  FI_message_box (FI_CURRENT_SCREEN, -1, -1, "Error",
      FI_YELLOW, "swiss742b", 25.0,
      error_string, FI_BLACK, "swiss742b", 25.0,
      FI_LEFT_JUSTIFIED, 60);
}

/*-----------------------------------------------------------------------*/

void Break_up_multi_line_string (Form form,
                                 int label,
                                 char *string)
{
  int i, index;
  int spots[100];
  char t_str[500];

  FIfld_set_num_rows (form, label, 0);

  if (strlen (string) != 0)
  {
    index = 0;

    for (i = 0; i < strlen (string); i++)
      if (string[i] == '\n')
      {
        spots[index] = i;
        index++;
      }

    for (i = 0; i < index; i++)
    {
      if (i == 0)
      {
        if (spots[0] > 0)
        {
          strncpy (t_str, string, spots[0]);
          t_str[spots[0]] = '\0';
          FIfld_set_text (form, label, 0, 0, t_str, 0);
        }
        else
        {
            FIfld_set_text (form, label, 0, 0, "", 0);
        }
      }
      else
      {
        if ((spots[i] - spots[i-1]) > 1)
        {
          strncpy (t_str, &(string [spots[i-1]+1]),
              spots[i] - (spots[i-1] + 1));
          t_str[spots[i] - (spots[i-1] + 1)] = '\0';
          FIfld_set_text (form, label, i, 0, t_str, 0);
        }
        else
        {
          FIfld_set_text (form, label, i, 0, "", 0);
        }
      }
    }

    if (index == 0)
      FIfld_set_text (form, label, 0, 0, string, 0);
    else
      if ((spots[index-1]+1) < strlen (string))
      {
        strcpy (t_str, &(string[spots[index-1]+1]));
        FIfld_set_text (form, label, index, 0, t_str, 0);
      }
  }
}

/*------------------------------------------------------------------------*/

void Form_multi_line_string (Form form,
                             int label,
                             char *string)
{
  int rows, x, dummy;
  char t_str[8000];
  char line[2004];

  FIfld_get_num_rows (form, label, &rows);

  t_str[0] = (char) NULL;
  for (x = 0; x < rows; x++)
  {
    FIfld_get_text (form, label, x, 0, 2000, 
		(unsigned char *)line, &dummy, &dummy);
    strcat (t_str, line);
    if (x != (rows - 1))
    {
      strcat (t_str, "\n");
    }

    if ((x == (rows - 1)) && (strlen (line) == 0))
    {
      t_str[strlen(t_str)-1] = '\0';
    }
  }
  strcpy (string, t_str);
}


/*-----------------------------------------------------------------------*/
void _FI_free ( void *pointer )
/* dmb:08/29/92:Exp change from int pointer */
{
  if ( pointer )
    free ( pointer );
}

/*-----------------------------------------------------------------------*/

_FI_draw_box (Window window,
              int xlo,
              int ylo,
              int xhi,
              int yhi)
{
  XDrawLine (display, window, xfb_GC, xlo, ylo, xlo, yhi);
  XDrawLine (display, window, xfb_GC, xlo, yhi, xhi, yhi);
  XDrawLine (display, window, xfb_GC, xhi, yhi, xhi, ylo);
  XDrawLine (display, window, xfb_GC, xhi, ylo, xlo, ylo);
  XFlush (display);
}

/***************************************************************************/
/* */
/* sort_font_names() */
/* */
/* Finds all of the avaliable Xfont names and places them sorted into */
/* the Text Selection Form Single Select field. */
/* */
/***************************************************************************/

sort_font_names(void)
{
  struct dirent *dp;
  DIR *dirp;
  char form_filename[2000][16];
  char *sorted_filename[2000];
  char *temp_filename;
  int x, y, z;
  char t_str[200];
  int len;

  /* dmb:04/09/93:Adding for CR#249202403 */
  char ingr_root[256] = {(char) NULL};
  char tmp_path[256] = {(char) NULL};
  
  FI_get_ingr_root(ingr_root);

  if (strcmp (ingr_root, "") != 0)  
  {
    strcpy (tmp_path, ingr_root);
    strcat (tmp_path, "/resrc/fontserver/typeface");
  }
  else  /* INGRHOME not set */
  {
	strcpy(tmp_path, "/usr/ip32/resrc/fontserver/typeface");
  }

  /* dmb:04/09/93:end addition */


  /* dmb:04/09/93:Changed for CR#249202403 */
/*  if ( (dirp = opendir ("/usr/ip32/resrc/fontserver/typeface")) == NULL ) */
  /* dmb:04/09/93:end original */
  if ( (dirp = opendir (tmp_path)) == NULL )
  {
     return(1);
  }
  else
  {
    x = 0;
    while (( dp = readdir ( dirp )) != NULL )
    {
      if (( strcmp ( dp->d_name, ".." ) != 0 ) &&
          ( strcmp ( dp->d_name, "." ) != 0 ))
      {
        strcpy (t_str, dp->d_name);
        len = strlen (t_str);

        if (len > 3)
        {
           if (strcmp (&(t_str[len - 3]), ".tf") == 0)
           {
            t_str[len - 3] = '\0';
            strcpy( form_filename[x], t_str );
            sorted_filename[x] = form_filename[x];
  
            x++;
           }
        }
      }
    }

    closedir ( dirp );

    if ( x ) /* There are typefaces in the directory */
    {
      FIfld_set_num_rows (Font_form, TYPEFACE_LIST_FLD, 0);

      if (x == 1) /* Only one entry, so no need to sort */
      {
        FIfld_set_text (Font_form, TYPEFACE_LIST_FLD, 0, 0,
            form_filename[0], 0);
      }
      else /* Need to sort the files into alphabetical order */
      {    /* before placing them into the form. */

        for (y=0; y < x - 1; y++)
        {
          for (z=y+1; z < x; z++)
          {
            if ( strcmp (sorted_filename[y], sorted_filename[z]) > 0 )
            {
              temp_filename = sorted_filename[y];
              sorted_filename[y] = sorted_filename[z];
              sorted_filename[z] = temp_filename;
            }
          }
        }

        /* Now that they are sorted, place them into the form */

        for (y = 0; y < x; y++)
        {
           strcpy(t_str, sorted_filename[y]);

           FIfld_set_text (Font_form, TYPEFACE_LIST_FLD, y, 0, t_str, 0);
        }
      }
    }
  }
  return(FI_SUCCESS); /* sml:11-15-94:added for ANSI */
}

/*----------------------------------------------------------------------*/

Redisplay (Form form)
{
  int xsize, ysize;

  FIf_get_size (form, &xsize, &ysize);

  FIf_paint_area (form, 0, 0, xsize, ysize);
}

/*---------------------------------------------------------------------*/

/*
Initialize_color_array(void)
{
Pixel (*color_func)();

FI_get_env (FI_TRANSLATE_COLOR, &color_func);

FI_X_14[0] = (*color_func) (0, FI_OFF_WHITE);
FI_X_14[1] = (*color_func) (0, FI_MED_GREY);
FI_X_14[2] = (*color_func) (0, FI_BLACK);
FI_X_14[3] = (*color_func) (0, FI_YELLOW);
FI_X_14[4] = (*color_func) (0, FI_LT_GREY);
FI_X_14[5] = (*color_func) (0, FI_DK_GREY);
FI_X_14[6] = (*color_func) (0, FI_WHITE);
FI_X_14[7] = (*color_func) (0, FI_RED);
FI_X_14[8] = (*color_func) (0, FI_GREEN);
FI_X_14[9] = (*color_func) (0, FI_BLUE);
FI_X_14[10] = (*color_func) (0, FI_LT_YELLOW);
FI_X_14[11] = (*color_func) (0, FI_DK_RED);
FI_X_14[12] = (*color_func) (0, FI_DK_GREEN);
FI_X_14[13] = (*color_func) (0, FI_DK_BLUE);
}
*/
