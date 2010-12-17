#include "machine.h"
#include "WFF.h"
#include <ctype.h>

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

void _WFFscroll_message (form, label)
  Form	form;
  int	label;
  {
#ifdef XWINDOWS
	XEvent		event;
#else
	int		event;
	int		area;
	int		x, y;
	int		button;
	int		timetag;
#endif
	int		trans;

	static	char *fname = "_WFFscroll_message";

	/*  Local functions  */

	void	_WFFscroll_message_one_word ();

	/*  Scroll the message one character  */

	_WFFscroll_message_one_word (form, label);

	/*  Check to see what the button transition was  */

	if (WFFglobal.button_transition == SINGLE_CLICK)
	  {
		/*  The middle mouse button is already up  */

		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	/*  Go into a loop until the user
	    lets up on the middle mouse button  */

	while (1)
	  {
#ifdef XWINDOWS
            XNextEvent( WFFglobal.display, &event );
            _NFIdebug(( fname, "X_Event type <%d>\n", event.type ));
            if( event.type == ButtonRelease)
            {
                FI_get_transition( &event, &trans );
                _NFIdebug(( fname, "X_trans <%d>\n", trans ));
                if( trans == UP )
                    break;
            } 
#else
 	    /*  Initialize the event mask  */
  	    event = NULL;

  	    Inq_events (&event);
	    _NFIdebug ((fname, "event = <0x%.8x>\n", event));

  	    if (event & BUTTON_EVENT)
	    {
 		Get_button_data (&area, &x, &y, &button, &trans, &timetag);
		_NFIdebug ((fname, "button = <%d>\n", button));
		_NFIdebug ((fname, "trans = <%d>\n", trans));

		if ((button == MIDDLE_BUTTON) && (trans == UP))
		  {
			/*  The middle mouse button was let up  */
			break;
		  }
	     }
#endif
	    /*  Scroll the message one character  */

  	    _WFFscroll_message_one_word (form, label);
	  }

	_NFIdebug ((fname, "returning ...\n"));
	return;
  }


void _WFFscroll_message_one_word (form, label)
  Form	form;
  int	label;
  {
	int		i, status;
	int		bxsize, bysize;
	int		txsize, tysize;
	long	*beginning_char;
	long	*ending_char;
	char	*visible_text;
	char	*full_message;

	static	char *fname = "_WFFscroll_message_one_word";

	_NFIdebug ((fname, "label = <%d>\n", label));

	/*  Find out what character in the string is
	    currently at the beginning of the bezel area  */

	if ((status = FIg_get_user_pointer
		(form, LEFT_SCROLL_BUTTON, (char *) &beginning_char)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_user_pointer = <%d>\n", status));
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	_NFIdebug ((fname, "beginning_char = <%d>\n", *beginning_char));

	/*  See if the message needs scrolling  */

	if ((label == LEFT_SCROLL_BUTTON) && (*beginning_char == 0))
	  {
		_NFIdebug ((fname, "Message is at the beginning\n"));
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	/*  Find out what character in the string
	    is currently at the end of the bezel area  */

	if ((status = FIg_get_user_pointer
		(form, RIGHT_SCROLL_BUTTON, (char *) &ending_char)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_user_pointer = <%d>\n", status));
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	_NFIdebug ((fname, "ending_char = <%d>\n", *ending_char));

	/*  Get the full message text out of the text gadget  */

	if ((status = FIg_get_user_pointer
		(form, ERROR_TEXT, (char *) &full_message)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_user_pointer = <%d>\n", status));
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	if ((label == RIGHT_SCROLL_BUTTON) &&
		(*ending_char == strlen (full_message)))
	  {
		_NFIdebug ((fname, "Message is at the end\n"));
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	/*  Pull the message off of the bezel area  */

	if ((visible_text = (char *) malloc (strlen (full_message) + 1)) == NULL)
	  {
		_NFIdebug ((fname,
			"malloc failed; size = <%d>\n", strlen (full_message) + 1));
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	if ((status = FIg_get_text
		(form, ERROR_TEXT, visible_text)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_text = <%d>\n", status));
		if (visible_text) free (visible_text);
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	/*  Find out how long the bezel area is  */

	if ((status = FIg_get_size
		(form, ERROR_BEZEL, &bxsize, &bysize)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
		if (visible_text) free (visible_text);
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	/*  Find out how long (in pixels) the visible text string is  */

	if ((status = FIg_get_size
		(form, ERROR_TEXT, &txsize, &tysize)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
		if (visible_text) free (visible_text);
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	/*  Scroll the message 1 word (or half the
	    length of the text, whichever comes first)  */

	for (i = 0; i < (strlen (full_message) / 2); ++i)
	  {
		if (label == LEFT_SCROLL_BUTTON)
		  {
			/*  Make sure we don't go past the beginning  */

			if (*beginning_char == 0)
			  {
				_NFIdebug ((fname, "beginning of message\n"));
				break;
			  }

			--(*beginning_char);
			--(*ending_char);

			if (isspace (full_message[*beginning_char]))
			  {
				_NFIdebug ((fname, "found white-space\n"));
				break;
			  }
		  }
		else
		  {
			/*  Make sure we don't go past the end  */

			if (*ending_char == strlen (full_message))
			  {
				_NFIdebug ((fname, "end of message\n"));
				break;
			  }

			++(*beginning_char);
			++(*ending_char);

			if (isspace (full_message[*ending_char]))
			  {
				_NFIdebug ((fname, "found white-space\n"));
				break;
			  }
		  }
	  }

	/*  Copy in the new visible text  */

	strncpy (visible_text,
		&full_message[*beginning_char], *ending_char - *beginning_char);
	visible_text[*ending_char] = NULL;

	/*  Display the new visible text  */

	if ((status = FIg_erase (form, ERROR_TEXT)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_erase = <%d>\n", status));
		if (visible_text) free (visible_text);
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	if ((status = FIg_set_text
		(form, ERROR_TEXT, visible_text)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_text = <%d>\n", status));
		if (visible_text) free (visible_text);
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	if (visible_text) free (visible_text);

	if ((status = FIg_display (form, ERROR_TEXT)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_display = <%d>\n", status));
		_NFIdebug ((fname, "returning ...\n"));
		return;
	  }

	_NFIdebug ((fname, "returning ...\n"));
	return;
  }
