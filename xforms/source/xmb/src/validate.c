
/*****************************/
/*                           */
/*         validate.c        */
/*                           */
/*   Programmer:             */
/*          Mack Draper      */
/*                           */
/*   Date:  Dec. 21,1988     */
/*                           */
/*****************************/

#include <stdio.h>

#include "FI.h"
#include "UMS.h"
#include "XMB.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

extern double atof();

/*--------------------------------------------------------------------*/

int validate_integer_field (char i_str[200],
                            Form form,
                            int err_field_index,
                            int *status)
{
  int x;	
  int string_ok;
  char t_str[200];


   string_ok = 1;
   
   for (x = 0; x < strlen (i_str); x++)
      if ((i_str[x] == ' ') ||
          (i_str[x] == '-') ||
          (isdigit (i_str[x])))
      {
      }
      else
         string_ok = 0;

   if (string_ok == 1)
   {
      *status = 1;
      return (atoi (i_str));
   }
   else
   {
      *status = 0;
      UMSGetByNum (t_str, MB_E_BADINTNBR, 0);

      FIfld_set_text (form, err_field_index, 0, 0,
                      t_str, 0);

      FIg_display (form, err_field_index);
      
      return (-1);
   }
}


double validate_double_field (char f_str[200],
                              Form form,
                              int err_field_index,
                              int *status)
{
  int x;
  int string_ok;
  char t_str[200];


  string_ok = 1;
   
  for (x = 0; x < strlen (f_str); x++)
    {
      if ((f_str[x] == ' ') ||
          (f_str[x] == '-') ||
          (f_str[x] == '+') ||
          (f_str[x] == '.') ||
          (f_str[x] == 'e') ||
          (f_str[x] == 'E') ||
          (isdigit (f_str[x])))
      {
      }
      else
         string_ok = 0;
    }

   if (string_ok == 1)
   {
      *status = 1;
      return (atof (f_str));
   }
   else
   {
      *status = 0;	
   
      UMSGetByNum (t_str, MB_E_BADFPNBR, 0);

      FIfld_set_text (form, err_field_index, 0, 0,
                      t_str, 0);

      FIg_display (form, err_field_index);
      
      return  (-1);
   }
}

/*--------------------------------------------------------------------*/

int print_error (Form form,
                 int err_field_index,
                 char t_str[200])
{
   FIfld_set_text (form, err_field_index, 0, 0, t_str, 0);
   
   FIg_display (form, err_field_index);

  return ( FI_SUCCESS );
}
   
 
