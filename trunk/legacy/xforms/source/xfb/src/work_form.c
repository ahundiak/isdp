/***********************************

		work_form.c

***********************************/

/*
  History
	04-28-92	sml		ANSI-ized; removed extra func args; casted
						  func args
*/

/*****************************/
/* */
/* This file contains global variables and gadget notification routine */
/*needed by the work_form. */
/* */
/* Programmer: */
/* Mack Draper */
/* */
/* Date: ??? */
/* */
/*****************************/

#include <stdio.h>
#include "FI.h"
#include "FIdyn.h"
#include "NFBpriv.h"

#include "XFIproto_pub.h"
#include "XFBproto_pri.h"

struct form_data form_attr;
struct dpb_struct dpb;
struct gadget_struct gadget_attr;
struct standard_st default_attr;
Form work_form;
int save_restore_flag;
int keyin_label;

extern Form Message_form;

/* ARGSUSED */
void fi_work_form (int form_label,
                  int gadget_label,
                  double value,
                  Form form_ptr)
{
  /* printf ("notification for gadget: %d\n", gadget_label); */
  if (gadget_label <= 10)
  {
    FIg_set_state_off (work_form, gadget_label);
  }

  return;
}

/* ARGSUSED */
void fi_dummy_work_form (int form_label,
                        int gadget_label,
                        double value,
                        Form form_ptr)
{
  return;
}

/* ARGSUSED */
void fi_message_form (int form_label,
                     int gadget_label,
                     double value,
                     Form form_ptr)
{
  int dummy, type, status;
  unsigned char t_str[1000];
  int temp_label;

  if (gadget_label == 44)
  {
    FIfld_get_text (Message_form, 44, 0, 0, 200, t_str, &dummy, &dummy);

    temp_label = atoi (t_str);

    if (temp_label > 0)
    {
      status = FIg_get_type (work_form, temp_label, &type);
      if (status == FI_SUCCESS)
        keyin_label = temp_label;
      else
        FIg_set_text (Message_form, 44, "");
    }
    else
      FIg_set_text (Message_form, 44, "");
  }
  return;
}
