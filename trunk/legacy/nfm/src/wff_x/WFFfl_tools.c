#include "machine.h"
#include "WFF.h"
#include "WFFconfirm.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

#define LEFT_MARGIN   20
#define RIGHT_MARGIN  20

long _WFFadjust_confirm_form (form)
  Form	form;
  {
	int		form_xsize;
	int		form_ysize;
	int		form_width;
	int		form_height;
/*
	int		x1_size, y1_size;
	int		x2_size, y2_size;
*/
	int		button_x, button_y;
	int		button_width;
	int		button_height;
	int		first_line_width;
	int		first_line_height;
	int		cmd_info_width;
	int		cmd_info_height;
	long	status;

	static	char *fname = "_WFFadjust_confirm_form";

	if ((status = (long) FIf_get_size
		(form, &form_xsize, &form_ysize)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_get_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = (long) FIg_get_size (form,
		FIRST_LINE, &first_line_width, &first_line_height)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = (long) FIg_get_size (form,
		COMMAND_INFO, &cmd_info_width, &cmd_info_height)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	form_height = form_ysize;

	form_width = LEFT_MARGIN + RIGHT_MARGIN;

	if (first_line_width > cmd_info_width)
		form_width += first_line_width;
	else
		form_width += cmd_info_width;

	/*  Set the form width based on the longest text line  */

	if ((status = FIf_set_size (form, form_width, form_height)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIf_set_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_set_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Adjust the location of the CANCEL button  */

	if ((status = (long) FIg_get_location
		(form, CANCEL_BUTTON, &button_x, &button_y)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = (long) FIg_set_location
		(form, CANCEL_BUTTON, LEFT_MARGIN, button_y)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_location = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_location", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Adjust the location of the OK button  */

	if ((status = (long) FIg_get_size
		(form, OK_BUTTON, &button_width, &button_height)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = (long) FIg_get_location
		(form, OK_BUTTON, &button_x, &button_y)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = (long) FIg_set_location (form, OK_BUTTON,
		form_width - RIGHT_MARGIN - button_width, button_y)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_location = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_location", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Adjust the length of the error bezel  */

	if ((status = (long) FIg_get_size
		(form, ERROR_BEZEL, &button_width, &button_height)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = (long) FIg_set_size (form, ERROR_BEZEL,
		form_width - RIGHT_MARGIN, button_height)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = _WFFcenter_gadget (form, CAUTION_TEXT)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_gadget = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	if ((status = _WFFcenter_gadget (form, FIRST_LINE)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_gadget = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	if ((status = _WFFcenter_gadget (form, COMMAND_INFO)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_gadget = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	if ((status = _WFFcenter_gadget (form, ERROR_BEZEL)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_gadget = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	if ((status = _WFFcenter_form (form, -1, Y_FORM_POS)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFcenter_form = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }
