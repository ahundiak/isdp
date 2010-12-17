#include "FI.h"
#include "UMS.h"
#include "stdio.h"
#include "malloc.h"
#include "dba_msg.h"
#include "PDUstr.h"
#include "PDUproto.h"

#define MAXLINE 2002
#define FORM_OUTPUT 105
#define FORM_TEXT_SIZE 119
#define TITLE 13
#define OUTPUT 14
#define READ_MORE 16
#define READ_EOF 17
#define TEXT_SIZE 26

extern char PDUdba_stext[MAXLINE], PDUdba_errtxt[250], *PDUdba_get_msg();
extern double PDUdba_form_value;
extern int PDUdba_num_rows, PDUdba_total_lines, PDUdba_error, PDUdba_text_size, PDUdba_notify();
extern Form PDUdba_output_fpt, PDUdba_text_fpt;
extern FILE *PDUdba_filnam_ptr;

/* Function:    PDUdba_display_report */

int PDUdba_display_report (output)
char *output;
{
  int status;

  status = PDUdba_list_output (0, output);
  return (status);
}

/* Function:	PDUdba_list_output */

int PDUdba_list_output (option, filename)
int option;
char *filename;
{
  char *text_ptr;
  int status, jj;
  Form fpt=PDUdba_output_fpt;

  if (option)
    status = FIfld_get_num_vis_rows (fpt, OUTPUT, &PDUdba_num_rows);

  switch (option)
    { case 0:
      status = FIf_new (FORM_OUTPUT, "PDUdba_output", PDUdba_notify, &PDUdba_output_fpt);
      if (status) return (99);
      fpt = PDUdba_output_fpt;

      status = FIfld_get_num_vis_rows (fpt, OUTPUT, &PDUdba_num_rows);
      PDUdba_add_output (0);
      status = FIfld_set_num_rows (fpt, OUTPUT, 0);
      status = FIg_set_text (fpt, TITLE, filename);
      PDUdba_filnam_ptr = fopen (filename, "r");
      if (!PDUdba_filnam_ptr)
        { strcpy (PDUdba_errtxt, PDUdba_get_msg (DBA_E_OPEN_FILE, "%s%s", 0, 
          "output file", filename));  
        return (99); }
      PDUdba_total_lines = 0;  
      text_ptr = fgets (PDUdba_stext, MAXLINE, PDUdba_filnam_ptr);
      if (!text_ptr)
        { strcpy (PDUdba_errtxt, PDUdba_get_msg (DBA_E_OUTPUT_NO_LINES, "%s", 0, 
          filename, 0));  
        return (99); }
      status = fseek (PDUdba_filnam_ptr, 0, 0);
      for (jj=0, status=0; !status; ++jj)
        status = PDUdba_add_output (1);
      PDUdba_set_text_size (fpt, PDUdba_text_size);
      status = FIf_display (fpt);
      break;
    case READ_EOF:
      /*PDUdba_print_msg (PDUdba_get_msg (DBA_M_PROCWAIT, 0, 0, 0, 0));*/
      for (jj=0, PDUdba_error=0; !PDUdba_error; ++jj) PDUdba_error = PDUdba_add_output (1);
      if (jj == 1)
        { strcpy (PDUdba_errtxt, PDUdba_get_msg (DBA_E_EOF, 0, 0, 0, 0));
        return (99); }
      status = FIfld_set_active_row (fpt, OUTPUT,
        PDUdba_total_lines - PDUdba_num_rows, 0);
      break;
    case READ_MORE:
      /*PDUdba_print_msg (PDUdba_get_msg (DBA_M_PROCWAIT, 0, 0, 0, 0));*/
      for (jj = 0; jj < PDUdba_num_rows; ++jj)
        { status = PDUdba_add_output (1);  if (status) break; }
      if (!jj)
        { strcpy (PDUdba_errtxt, PDUdba_get_msg (DBA_E_EOF, 0, 0, 0, 0));
        return (99); }
      status = FIfld_set_active_row (fpt, OUTPUT,
        PDUdba_total_lines - PDUdba_num_rows, 0);
      break;
    case TEXT_SIZE:
      PDUdba_error = PDUdba_text_size_form (0, fpt);  break;
    case FI_CANCEL:
      fclose (PDUdba_filnam_ptr);
      status = FIf_erase (fpt);
      if (PDUdba_text_fpt) status = FIf_erase (PDUdba_text_fpt);
      break; }

  return (PDUdba_error);
}
/* Function:	PDUdba_add_output */

int PDUdba_add_output (option)
int option;
{
  char *text_ptr;
  int status;
  Form fpt=PDUdba_output_fpt;
  static char blank_line;
  static int rows=0;

  if (!option) 
    { rows = 0;  blank_line = 0;  return (0); }
read_file:
  text_ptr = fgets (PDUdba_stext, MAXLINE, PDUdba_filnam_ptr);
  if (!text_ptr) return (1);

  if (text_ptr[0] == 12) ++text_ptr;
  if (text_ptr[0] == 10)
    { if (blank_line) goto read_file;
    blank_line = 1;  text_ptr[0] = ' '; }
  else blank_line = 0;

  if (PDUdba_total_lines >= rows)
    { rows += PDUdba_num_rows;
    status = FIfld_set_num_rows (fpt, OUTPUT, rows); }

  status = FIfld_set_text (fpt, OUTPUT, PDUdba_total_lines, 0, text_ptr, 0);
  ++PDUdba_total_lines;

  return (0);
}
/* Function:    PDUdba_notify */

/* ARGSUSED */
int PDUdba_notify (form_label, label, value, fpt)
int form_label, label;
double value;
Form fpt;
{
  PDUdba_form_value = value;

  switch (form_label)
    { case FORM_TEXT_SIZE:
      PDUdba_error = PDUdba_text_size_form (label, 0);  break;
    case FORM_OUTPUT:
      PDUdba_error = PDUdba_list_output (label, (char *) 0);  break;
    default:
      break; }

  return (0);
}
/* Function:	PDUdba_text_size_form */

int PDUdba_text_size_form (option, fpt)
int option;
Form fpt;
{
  int status;
  static Form saved_form;

  switch (option)
    { case 0:
      status = FIf_new (FORM_TEXT_SIZE, "PDUdba_text_size", PDUdba_notify,
        &PDUdba_text_fpt);
      if (status) return (99);
      saved_form = fpt;
      status = FIg_set_value (PDUdba_text_fpt, TEXT_SIZE, (double) PDUdba_text_size);
      status = FIf_display (PDUdba_text_fpt);
      break;
    case TEXT_SIZE:
      PDUdba_text_size = PDUdba_form_value;
      PDUdba_set_text_size (saved_form, PDUdba_text_size);
      break;
    case FI_CANCEL:
      status = FIf_delete (PDUdba_text_fpt);  PDUdba_text_fpt = 0;
      break; }

  return (PDUdba_error);
}
/* Function:	PDUdba_set_text_size */

int PDUdba_set_text_size (fpt, text_num)
Form fpt;
int text_num;
{
  float bodysize=0;
  int status;

  status = FIg_erase (fpt, 14);  
  switch (text_num)
    { case 1:  bodysize = 12;  break;
    case 2:  bodysize = 15;  break;
    case 3:  bodysize = 20;  break;
    case 4:  bodysize = 25;  break;
    case 5:  bodysize = 30;  break; }
  status = FIg_set_font (fpt, 14, "mono821b", bodysize);
  status = FIg_activate (fpt, 14);
  status = FIg_display (fpt, 14);  

  return (0);
}
/* Function:	PDUdba_get_msg */
char *PDUdba_get_msg (msgnum, msgfmt, maxlng, ptr1, ptr2)
int msgnum;
char *msgfmt;
int maxlng;
void *ptr1, *ptr2;
{
  int status;
  static char *s1_ptr;
  static unsigned s1_size=0;

  if (!s1_size) { s1_size = 200;  s1_ptr = malloc (s1_size); }
  if (maxlng > 0 && maxlng + 1 > s1_size)
    { s1_size = maxlng + 1;  s1_ptr = realloc (s1_ptr, s1_size); }

  status = UMSGetByNum (s1_ptr, msgnum, msgfmt, ptr1, ptr2);
  if (status == UMS_E_NOTFND)
    sprintf (s1_ptr, "Message number 0x0%x is not in message file.", msgnum);

  if (maxlng) s1_ptr[maxlng] = 0;

  return (s1_ptr);
}
/* Function:	PDUdba_print_msg */

int PDUdba_print_msg (message)
char *message;
{
  int status;

  status = Display_message (1, 1 /*CENTER*/, message);

  return (0);
}
