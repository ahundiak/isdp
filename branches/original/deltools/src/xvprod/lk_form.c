#include "main.h"
#include "defs.h"
#include <FI.h>
#include <FEI.h>

char	keyinput[KEY_LEN];
int	loadkey_note();

static int	accepted_form;
#define	ACCEPTED_FORM	1

Form	keyform;
extern Form delform;

char *
form_get_key(prodname, prodnumber)
char * prodname;
char * prodnumber;
{
    int		sts, window;
    char	product[64];
    char	path[MAXPATHLEN];

    keyinput[0] = 0;
    sprintf(path, "%s/loadkey.form", MYSTUFFDIR);
    sts = FIf_new(LOADKEYFORM, path,
			    loadkey_note, &keyform);

    FIf_set_window_level(keyform, FI_HIGH_PRIORITY);
    if (chkerror(sts, "creating loadkey form"))
	exit(1);

    sprintf(product,"%s (%s)", prodname, prodnumber);

    FIg_set_justification(keyform, LK_PROD, FI_CENTER_JUSTIFIED);
    FIg_set_text(keyform, LK_PROD, product);
    sts = FIf_display(keyform);
    FIfld_pos_cursor(keyform, LK_KEYFIELD, 0, 0, 0, 0, 0, 0); 
    FIf_process_form(keyform);
    FIf_display(delform);
    return(keyinput);
}

loadkey_note ( f_label, g_label, value, fp )
  int     f_label;       /* The label of the form   */
  int     g_label;       /* The label of the gadget */
  double  value;         /* The value of the gadget */
  Form    fp;            /* Pointer to the form     */
{
  static char   * text;
  static int      text_size = 0;
  int             status;

  switch ( g_label ) 
  {
    case LK_KEYFIELD: 
          status = FIg_get_text (fp, g_label, keyinput);
          if ( status != FI_SUCCESS )
          {
              return;
          }
	 accepted_form = TRUE;
	 sleep(1);
	 FIf_erase(fp);
         break;
  } /* switch */
} /* loadkey_note */



int FIf_process_form( form )
int form;
{
	int event;
	int display_status;
	int send_to_forms;

	accepted_form = FALSE;

	for(;;)
	{
		Wait_for_next ( FI_EVENT_MASK, &event );

		send_to_forms = TRUE;
		

		if ( send_to_forms )
		{
			if ( ! FI_process_event ( event ) )
				FI_clear_event ( event );
		}

		FIf_is_displayed ( form, &display_status );

		if ( ! display_status ) break;
	}

	if ( accepted_form == TRUE )

		return ( ACCEPTED_FORM );
	else
		return ( ! ACCEPTED_FORM );
}
