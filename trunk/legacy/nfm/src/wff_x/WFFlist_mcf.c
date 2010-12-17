#include "machine.h"
#include "WFF.h"
#include "FIdyn.h"
#include "WFFpersist.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

/*  Maximum number of columns for a listing  */

int NFI_MAX_LISTING_COLS;
int NFI_MAX_COLUMNS;

long _WFFlist_load_mcf (form, mode, num_frozen_cols, attr_list, data_list)
  Form		form;
  int		mode;
  int		num_frozen_cols;  /*  i - Number of columns to freeze scrolling  */
  MEMptr	attr_list;
  MEMptr	data_list;
  {
	int		left_cols;
	int		right_cols;
	long	status;

	static	short first_time = TRUE;

	static	char *fname = "_WFFlist_load_mcf";

	long	_WFFlist_create_mcf ();
	long	_WFFlist_load_mcf_data ();
	long	_WFFlist_position_mcfs ();

	if (first_time == TRUE)
	  {
		_NFIdebug ((fname,
			"Getting the maximum number of visible columns ...\n"));

		if ((status = (long) FImcf_get_num_vis_cols
			(form, HIDDEN_TOP_LEFT_MCF, &left_cols)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FImcf_get_num_vis_cols = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_vis_cols", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if ((status = (long) FImcf_get_num_vis_cols
			(form, HIDDEN_TOP_RIGHT_MCF, &right_cols)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FImcf_get_num_vis_cols = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_vis_cols", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		NFI_MAX_LISTING_COLS = left_cols + right_cols;

		/*  Erase the hidden mcfs  */

		_NFIdebug ((fname, "Erasing the hidden mcfs ...\n"));

		if ((status = FIg_erase (form, HIDDEN_TOP_LEFT_MCF)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_erase = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if ((status = FIg_erase (form, HIDDEN_TOP_RIGHT_MCF)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_erase = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if ((status = FIg_erase (form, HIDDEN_BOTTOM_LEFT_MCF)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_erase = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if ((status = FIg_erase (form, HIDDEN_BOTTOM_RIGHT_MCF)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_erase = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_erase", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }
	else
	  {
		/*  Delete the previously created mcfs  */

		_NFIdebug ((fname, "Deleting the previously created mcfs ...\n"));

		if ((status = (long) FIg_delete
			(form, TOP_LEFT_MCF)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_delete = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if ((status = (long) FIg_delete
			(form, TOP_RIGHT_MCF)) != FI_SUCCESS)
		  {
			/*  See if the gadget was created last time  */

			if (status != FI_NO_SUCH_GADGET)
			  {
				_NFIdebug ((fname, "FIg_delete = <%d>\n", status));
				ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }
		  }

		if ((status = (long) FIg_delete
			(form, BOTTOM_LEFT_MCF)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_delete = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if ((status = (long) FIg_delete
			(form, BOTTOM_RIGHT_MCF)) != FI_SUCCESS)
		  {
			/*  See if the gadget was created last time  */

			if (status != FI_NO_SUCH_GADGET)
			  {
				_NFIdebug ((fname, "FIg_delete = <%d>\n", status));
				ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }
		  }
	  }

	first_time = FALSE;

	if (attr_list != NULL)
	  {
		if ((status = MEMbuild_array (attr_list)) != MEM_S_SUCCESS)
		  {
			_NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
			ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_MEM);
		  }
	  }

	if ((status = MEMbuild_array (data_list)) != MEM_S_SUCCESS)
	  {
		_NFIdebug ((fname, "MEMbuild_array = <0x%.8x>\n", status));
		ERRload_struct (NFI, NFI_E_MEM, "%s%x", "MEMbuild_array", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MEM);
	  }

	/*  Create the mcf to reflect the attr_list;
	    mode is FI_MULTI_SELECT so that report output can be selected  */

	if ((status = _WFFlist_create_mcf (form, TOP_LEFT_MCF,
		num_frozen_cols, FI_MULTI_SELECT, data_list)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFlist_create_mcf = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	if ((status = _WFFlist_create_mcf (form, TOP_RIGHT_MCF,
		num_frozen_cols, FI_MULTI_SELECT, data_list)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFlist_create_mcf = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	if ((status = _WFFlist_create_mcf (form,
		BOTTOM_LEFT_MCF, num_frozen_cols, mode, data_list)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFlist_create_mcf = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	if ((status = _WFFlist_create_mcf (form,
		BOTTOM_RIGHT_MCF, num_frozen_cols, mode, data_list)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFlist_create_mcf = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	/*  Position the mcfs on the form  */

	if ((status = _WFFlist_position_mcfs (form)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFlist_position_mcfs = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	/*  Load the attr_list and data_list into the mcfs  */

	if ((status = _WFFlist_load_mcf_data (form,
		num_frozen_cols, TOP_LEFT_MCF, TOP_RIGHT_MCF, BOTTOM_LEFT_MCF,
		BOTTOM_RIGHT_MCF, attr_list, data_list)) != NFI_S_SUCCESS)
	  {
		_NFIdebug ((fname, "_WFFlist_load_mcf_data = <0x%.8x>\n", status));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (status);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFlist_create_mcf (form, label, num_frozen_cols, mode, data_list)
  Form		form;
  int		label;
  int	num_frozen_cols;
  int		mode;
  MEMptr	data_list;
  {
	int		i, status;
	int		num_rows;
	int		num_chars;
	int		vis_columns = 0;
	int		num_vis_cols = 0;
	int		total_cols = 0;
	int		attr_mask;
	int		xpos, ypos;
	int		xsize, ysize;
	int		end_loop = 0;
	int		justification = 0;
	struct	standard_st st_var;

	static	char *fname = "_WFFlist_create_mcf";

	_NFIdebug ((fname, "label = <%d>\n", label));
	_NFIdebug ((fname, "num_frozen_cols = <%d>\n", num_frozen_cols));
	_NFIdebug ((fname, "mode = <%d>\n", mode));

	switch (label)
	  {
		case TOP_LEFT_MCF:
		case BOTTOM_LEFT_MCF:

			_NFIdebug ((fname, "Getting the location from the hidden mcfs\n"));

			if ((status = FIg_get_location
				(form, label - 100, &xpos, &ypos)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }

			break;

		case TOP_RIGHT_MCF:

			_NFIdebug ((fname, "Getting the location from the TOP_LEFT_MCF\n"));

			if ((status = FIg_get_location
				(form, TOP_LEFT_MCF, &xpos, &ypos)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }

			if ((status = FIg_get_size
				(form, TOP_LEFT_MCF, &xsize, &ysize)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }

			xpos += xsize;
			ypos += ysize;

			break;

		case BOTTOM_RIGHT_MCF:

			_NFIdebug ((fname,
				"Getting the location from the BOTTOM_LEFT_MCF\n"));

			if ((status = FIg_get_location
				(form, BOTTOM_LEFT_MCF, &xpos, &ypos)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }

			if ((status = FIg_get_size
				(form, BOTTOM_LEFT_MCF, &xsize, &ysize)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }

			xpos += xsize;
			ypos += ysize;

			break;

		default:
			_NFIdebug ((fname, "unrecognized label <%d>\n", label));
			ERRload_struct (NFI, NFI_E_INVALID_INPUT, NULL);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_INVALID_INPUT);
	  }

	_NFIdebug ((fname, "xpos, ypos = %d, %d\n", xpos, ypos));

	/*  Create the new mcf  */

	_NFIdebug ((fname, "Creating the new mcf\n"));

	if ((status = FIg_new (form, FI_MULTI_COL, label)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_new = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_new", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Load the standard variable structure  */

	st_var.xlo = xpos;
	st_var.ylo = ypos;
#if defined(OS_INTELSOL)
	st_var.xhi = 1000;
	st_var.yhi = 800;
#else
	st_var.xhi = 0;
	st_var.yhi = 0;
#endif
	st_var.attr_mask = FI_NOT_DISPLAYED;
	st_var.value = 0.0;
	st_var.bodysize = 15.0;
	st_var.text = NULL;
	st_var.help_topic = NULL;
	st_var.command = NULL;
	st_var.fontname = "mono821b";
	st_var.user_pointer = NULL;
	st_var.off_color = FI_BLACK;
	st_var.on_color = FI_YELLOW;
	st_var.off_color2 = 0;
	st_var.on_color2 = 0;
	st_var.symbol_index = 0;
	st_var.symbol_index2 = 0;
	st_var.next_in_seq = 0;

	/*  Set the standard variable structure for the mcfs  */

	_NFIdebug ((fname, "Setting the standard variables\n"));

	if ((status = FIg_set_standard_variables
		(form, label, &st_var)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_standard_variables = <%d>\n", status));
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIg_set_standard_variables", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	attr_mask = FI_NOT_DISPLAYED;

	/*  Set the gadget characteristic mask to
	    FI_VERT_SCROLL_NOTIFY for the BOTTOM_RIGHT_MCF - Glenn 2/11/91  */

	if (label == BOTTOM_RIGHT_MCF)
	  {
		_NFIdebug ((fname, "Adding FI_VERT_SCROLL_NOTIFY to attr_mask\n"));

		attr_mask |= FI_VERT_SCROLL_NOTIFY;
	  }

	/*  Make sure the characteristics mask is set  */

	_NFIdebug ((fname, "Setting the attr_mask to FI_NOT_DISPLAYED\n"));

	if ((status = FIg_set_attr (form, label, attr_mask)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_set_attr = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_set_attr", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	_NFIdebug ((fname,
		"Getting the number of visible columns of the hidden mcf\n"));

	switch (label)
	  {
		case TOP_LEFT_MCF:
		case BOTTOM_LEFT_MCF:

			num_vis_cols = num_frozen_cols;
			total_cols = num_frozen_cols;
			vis_columns = num_frozen_cols;

			break;

		case TOP_RIGHT_MCF:
		case BOTTOM_RIGHT_MCF:

			num_vis_cols = NFI_MAX_LISTING_COLS - num_frozen_cols;

			/*  Find out how many columns to set  */

			total_cols = 0;
			vis_columns = 0;
			for (i = num_frozen_cols; i < data_list->columns; ++i)
			  {
				++total_cols;

				if (vis_columns < num_vis_cols) ++vis_columns;
			  }

			break;
	  }

	/*  See if there are any columns  */

	if (total_cols == 0)
	  {
		_NFIdebug ((fname, "there are no columns for this mcf\n"));
		if ((status = FIg_delete (form, label)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_delete = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_delete", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		_NFIdebug ((fname, " returning SUCCESS\n"));
		return (NFI_S_SUCCESS);
	  }

	/*  Set the number of columns  */

	_NFIdebug ((fname, "Setting number of columns to %d\n", total_cols));

	if ((status = FImcf_set_num_cols (form, label, total_cols)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FImcf_set_num_cols = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_num_cols", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Set the number of visible rows  */

	_NFIdebug ((fname, "Getting number of visible rows\n"));

	if ((status = FIfld_get_num_vis_rows
		(form, label - 100, &num_rows)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_get_num_vis_rows = <%d>\n", status));
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_rows", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	_NFIdebug ((fname, "Setting number of visible rows to %d\n", num_rows));

	if ((status = FIfld_set_num_vis_rows

		(form, label, num_rows)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_num_vis_rows = <%d>\n", status));
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_rows", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Get the number of visible characters in the first column  */

	_NFIdebug ((fname,
		"Getting the number of visible characters from the hidden mcf\n"));

	if ((status = FIfld_get_num_vis_chars
		(form, label - 100, 0, &num_chars)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_get_num_vis_chars = <%d>\n", status));
		ERRload_struct
			(NFI, NFI_E_FORM, "%s%d", "FIfld_get_num_vis_chars", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	switch (label)
	  {
		case TOP_LEFT_MCF:

			justification = FI_CENTER_JUSTIFIED;
			end_loop = num_frozen_cols;

			break;

		case TOP_RIGHT_MCF:

			justification = FI_CENTER_JUSTIFIED;
			end_loop = data_list->columns - num_frozen_cols;

			break;

		case BOTTOM_LEFT_MCF:

			justification = FI_LEFT_JUSTIFIED;
			end_loop = num_frozen_cols;

			break;

		case BOTTOM_RIGHT_MCF:

			justification = FI_LEFT_JUSTIFIED;
			end_loop = data_list->columns - num_frozen_cols;

			break;
	  }

	for (i = 0; i < end_loop; ++i)
	  {
		/*  Set the number of visible characters  */

		_NFIdebug ((fname, "%d: Setting number of visible characters to %d\n",
			i, num_chars));

		if ((status = FIfld_set_num_vis_chars
			(form, label, i, num_chars)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_num_vis_chars = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_vis_chars", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		/*  Set the mode for the columns  */

		_NFIdebug ((fname, "%d: Setting the mode\n", i));

		if ((status = FIfld_set_mode (form, label, i, mode)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_mode = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_mode", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		/*  Set the justification for the columns  */

		_NFIdebug ((fname, "%d: Setting the justification\n", i));

		if ((status = FImcf_set_justification
			(form, label, i, justification)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FImcf_set_justification = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FImcf_set_justification", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		/*  Set the type for the columns  */

		_NFIdebug ((fname, "%d: Setting the type to FI_ALPHA\n", i));

		if ((status = FIfld_set_type
			(form, label, i, FI_ALPHA)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_type = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_type", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		switch (label)
		  {
			case TOP_LEFT_MCF:
			case TOP_RIGHT_MCF:

				/*  No field attributes for the top mcfs  */

				attr_mask = FI_DEFAULT;

				break;

			case BOTTOM_LEFT_MCF:

				/*  Disable everything but
				    NOTIFY_BY_LINE, VERT_SCROLL, and HORT_SCROLL  */

				attr_mask = FI_NOTIFY_BY_LINE;
				attr_mask |= FI_VERT_SCROLL | FI_HORT_SCROLL;
				attr_mask |= FI_DISPLAY_HSCROLL;

				break;

			case BOTTOM_RIGHT_MCF:

				/*  Disable everything but NOTIFY_BY_LINE,
				    HORT_SCROLL, DISPLAY_HSCROLL and VERT_SCROLL  */

				attr_mask = FI_NOTIFY_BY_LINE | FI_VERT_SCROLL;
				attr_mask |= FI_HORT_SCROLL | FI_DISPLAY_HSCROLL;

				break;
		  }

		_NFIdebug ((fname, "%d: Setting field attributes\n", i));

		if ((status = FIfld_set_attr
			(form, label, i, attr_mask)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIfld_set_attr = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_attr", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }

	switch (label)
	  {
		case TOP_LEFT_MCF:

			/*  Don't show the scroll bars  */

			attr_mask = FI_DISABLE_VSCROLL | FI_DISABLE_HSCROLL;

			break;

		case TOP_RIGHT_MCF:

			/*  Don't show the scroll bars or row select buttons  */

			attr_mask = FI_DISABLE_VSCROLL | FI_DISABLE_HSCROLL;
			attr_mask |= FI_NO_ROW_BUTTONS;

			break;

		case BOTTOM_LEFT_MCF:

			/*  Enable vertical scrolling and disable horizontal scrolling  */
	                _NFIdebug ((fname, "num_frozen_cols = <%d>\n",
                                    num_frozen_cols));
	                _NFIdebug ((fname, "NFI_MAX_COLUMNS = <%d>\n",
                                    NFI_MAX_COLUMNS));
	                _NFIdebug ((fname, "MAX_NO_VISIBLE_ROWS = <%d>\n",
                                    MAX_NO_VISIBLE_ROWS));
	                _NFIdebug ((fname, "no rows in buffer = <%d>\n",
                                    data_list->rows));

			attr_mask = FI_VERT_SCROLL | FI_DISABLE_HSCROLL;

                        if ((num_frozen_cols == NFI_MAX_COLUMNS) &&
                            (MAX_NO_VISIBLE_ROWS < data_list->rows))
			      attr_mask |= FI_DISPLAY_VSCROLL;

			break;

		case BOTTOM_RIGHT_MCF:

			attr_mask = FI_VERT_SCROLL | FI_HORT_SCROLL;
			attr_mask |= FI_DISPLAY_VSCROLL | FI_NO_ROW_BUTTONS;

			if (total_cols > vis_columns)
				attr_mask |= FI_DISPLAY_HSCROLL;
			else
				attr_mask |= FI_DISABLE_HSCROLL;

			break;
	  }

	_NFIdebug ((fname, "Setting mcf attributes\n"));

	if ((status = FImcf_set_attr (form, label, attr_mask)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FImcf_set_attr = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_set_attr", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Set the number of visible columns  */

	switch (label)
	  {
		case TOP_LEFT_MCF:
		case TOP_RIGHT_MCF:
		case BOTTOM_LEFT_MCF:

			_NFIdebug ((fname,
				"Setting number of visible columns to %d\n", vis_columns));

			if ((status = FImcf_set_num_vis_cols
				(form, label, vis_columns)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
				ERRload_struct (NFI,
					NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }

			break;

		case BOTTOM_RIGHT_MCF:

			_NFIdebug ((fname,
				"Setting number of visible columns to %d\n", vis_columns));

			if ((status = FImcf_set_num_vis_cols
				(form, label, vis_columns)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FImcf_set_num_vis_cols = <%d>\n", status));
				ERRload_struct (NFI,
					NFI_E_FORM, "%s%d", "FImcf_set_num_vis_cols", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }

			/*  Link the scrolling of the bottom one to the top  */

			_NFIdebug ((fname, "Linking the scrolling to the top mcf\n"));

			if ((status = FImcf_set_scroll_link
				(form, label, TOP_RIGHT_MCF)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FImcf_set_scroll_link = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FImcf_set_scroll_link", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }

			break;
	  }

	/*  Activate the gadget  */

	_NFIdebug ((fname, "Activating the mcf\n"));

	if ((status = FIg_activate (form, label)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_activate = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_activate", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFlist_load_mcf_data (form, num_frozen_cols,
top_label1, top_label2, bottom_label1, bottom_label2, attr_list, data_list)
  Form		form;
  int		num_frozen_cols;
  int		top_label1;
  int		top_label2;
  int		bottom_label1;
  int		bottom_label2;
  MEMptr	attr_list;
  MEMptr	data_list;
  {
	int		i, j, k;
	int		column;
	int		fields;
	int		label;
	long	status;
	char	**attr_ptr;
	char	**data_ptr;
	short	first_time;

	static	char *fname = "_WFFlist_load_mcf_data";

	/*  External functions  */

	extern	long _WFFfind_list_offsets ();

	_NFIdebug ((fname, "top_label1 = <%d>\n", top_label1));
	_NFIdebug ((fname, "top_label2 = <%d>\n", top_label2));
	_NFIdebug ((fname, "bottom_label1 = <%d>\n", bottom_label1));
	_NFIdebug ((fname, "bottom_label2 = <%d>\n", bottom_label2));

	if (attr_list != NULL)
	  {
		/*  The attr_list contains one column and that is the synonyms  */

		attr_ptr = (char **) attr_list->data_ptr;

		/*  Set the top mcfs to reflect the name  */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	 */
	FIg_set_font(form, top_label1, "7x13bold", 15);
	FIg_set_font(form, top_label2, "7x13bold", 15);
#endif
		first_time = TRUE;
		fields = attr_list->columns * attr_list->rows;
		for (i = 0, column = 0; i < fields; ++i, ++column)
		  {
			if ((column < num_frozen_cols) && (first_time == TRUE))
			  {
				/*  Use the top left mcf  */

				label = top_label1;
			  }
			else
			  {
				/*  Use the top right mcf  */

				label = top_label2;

				if (first_time == TRUE)
				  {
					/*  Start with the top right mcf  */

					column = 0;
					first_time = FALSE;
				  }
			  }

			_NFIdebug ((fname, "Setting <%s>\n", attr_ptr[i]));
			_NFIdebug ((fname,
				"in row %d, col %d in label <%d>\n", 0, column, label));

			if ((status = FIfld_set_text (form, label,
				0, column, attr_ptr[i], FALSE)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }
		  }
	  }
	else
	  {
		/*  Set the top mcfs to reflect the column names in the data_list  */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	 */
	FIg_set_font(form, top_label1, "7x13bold", 15);
	FIg_set_font(form, top_label2, "7x13bold", 15);
#endif
		first_time = TRUE;
		attr_ptr = (char **) data_list->column_ptr;
		for (i = 0, column = 0; i < data_list->columns; ++i, ++column)
		  {
			if ((i < num_frozen_cols) && (first_time == TRUE))
			  {
				/*  Use the top left mcf  */

				label = top_label1;
			  }
			else
			  {
				/*  Use the top right mcf  */

				label = top_label2;

				if (first_time == TRUE)
				  {
					/*  Start with the top right mcf  */

					column = 0;
					first_time = FALSE;
				  }
			  }

			/*  Set the top mcf to reflect the name  */

			_NFIdebug ((fname, "Setting <%s>\n", attr_ptr[i]));
			_NFIdebug ((fname,
				"in row %d, col %d in label <%d>\n", 0, column, label));

			if ((status = FIfld_set_text
				(form, label, 0, column, attr_ptr[i], FALSE)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }
		  }
	  }

	/*  Set the number of rows to 0 to clear out the field  */

	_NFIdebug ((fname,
		"Setting the number of rows to 0 to clear out the field\n"));

	if ((status = FIfld_set_num_rows (form, bottom_label1, 0)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = FIfld_set_num_rows (form, bottom_label2, 0)) != FI_SUCCESS)
	  {
		/*  See if the gadget was created  */

		if (status != FI_NO_SUCH_GADGET)
		  {
			_NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }

	/*  Set the number of rows  */

	_NFIdebug ((fname, "Setting the number of rows to %d\n", data_list->rows));

	if ((status = FIfld_set_num_rows
		(form, bottom_label1, data_list->rows)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = FIfld_set_num_rows
		(form, bottom_label2, data_list->rows)) != FI_SUCCESS)
	  {
		/*  See if the gadget was created  */

		if (status != FI_NO_SUCH_GADGET)
		  {
			_NFIdebug ((fname, "FIfld_set_num_rows = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIfld_set_num_rows", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }

	/*  Put the values in the mcf  */

/* IGI Intel Solaris Port - CN 31/5/95 */
#if defined(OS_SCO_UNIX) || defined(OS_INTELSOL)
	/* To set font for SCO - CRN 25 Feb 94	*/
	FIg_set_font(form, bottom_label1, "7x13bold", 15);
	FIg_set_font(form, bottom_label2, "7x13bold", 15);
#endif
	data_ptr = (char **) data_list->data_ptr;
	for (i = 0, k = -1; i < data_list->rows; ++i)
	  {
		first_time = TRUE;
		for (j = 0, column = 0; j < data_list->columns; ++j, ++column)
		  {
			if ((j < num_frozen_cols) && (first_time == TRUE))
			  {
				/*  Use the bottom left mcf  */

				label = bottom_label1;
			  }
			else
			  {
				/*  Use the bottom right mcf  */

				label = bottom_label2;

				if (first_time == TRUE)
				  {
					/*  Start with the bottom right mcf  */

					column = 0;
					first_time = FALSE;
				  }
			  }

			++k;

			/*  Set the bottom mcfs to reflect the data_list  */

			_NFIdebug ((fname, "Setting <%s>\n", data_ptr[k]));
			_NFIdebug ((fname,
				"in row %d, col %d in label <%d>\n", i, column, label));

			if ((status = FIfld_set_text
				(form, label, i, column, data_ptr[k], FALSE)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIfld_set_text = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIfld_set_text", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }
		  }
	  }

	/*  Display the mcf  */

	_NFIdebug ((fname, "Displaying the mcfs\n"));

	if ((status = FIg_display (form, top_label1)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_display = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = FIg_display (form, top_label2)) != FI_SUCCESS)
	  {
		/*  See if the gadget was created  */

		if (status != FI_NO_SUCH_GADGET)
		  {
			_NFIdebug ((fname, "FIg_display = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }

	if ((status = FIg_display (form, bottom_label1)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_display = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = FIg_display (form, bottom_label2)) != FI_SUCCESS)
	  {
		/*  See if the gadget was created  */

		if (status != FI_NO_SUCH_GADGET)
		  {
			_NFIdebug ((fname, "FIg_display = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_display", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }


long _WFFlist_position_mcfs (form)
  Form	form;
  {
	int		status;
	int		xpos, ypos;
	int		xsize, ysize;
	int		fx_size, fy_size;
	int		left_xpos, left_ypos;
	int		left_xsize, left_ysize;
	int		right_xsize, right_ysize;
	int		num_left_cols = 0, num_vis_right_cols = 0;
	short	no_right_side_gadgets = FALSE;

	static	char *fname = "_WFFlist_position_mcfs";

	/*  See if the number of visible columns
	    is less than the total number of columns  */

	if ((status = FImcf_get_num_cols
		(form, TOP_LEFT_MCF, &num_left_cols)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FImcf_get_num_cols = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_cols", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = FImcf_get_num_vis_cols
		(form, TOP_RIGHT_MCF, &num_vis_right_cols)) != FI_SUCCESS)
	  {
		/*  See if the gadget was created last time  */

		if (status != FI_NO_SUCH_GADGET)
		  {
			_NFIdebug ((fname, "FImcf_get_num_vis_cols = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FImcf_get_num_vis_cols", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		no_right_side_gadgets = TRUE;
	  }

	_NFIdebug ((fname, "num_left_cols + num_vis_right_cols = <%d>\n",
                    num_left_cols + num_vis_right_cols));

	/*  Position the top left and bottom left mcfs  */

	if ((num_left_cols + num_vis_right_cols) < NFI_MAX_LISTING_COLS)
	  {
		/*  Get the size of the form  */

		if ((status = FIf_get_size (form, &fx_size, &fy_size)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIf_get_size = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIf_get_size", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		/*  Center the top left mcf on the form  */

		if ((status = FIg_get_location
			(form, TOP_LEFT_MCF, &left_xpos, &left_ypos)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if ((status = FIg_get_size
			(form, TOP_LEFT_MCF, &left_xsize, &left_ysize)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
			ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if (no_right_side_gadgets == TRUE)
		  {
			right_xsize = 0;
			right_ysize = 0;
		  }
		else
		  {
			if ((status = FIg_get_size (form,
				TOP_RIGHT_MCF, &right_xsize, &right_ysize)) != FI_SUCCESS)
			  {
				_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
				ERRload_struct
					(NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_FORM);
			  }
		  }

		left_xpos = (fx_size / 2) - ((left_xsize + right_xsize) / 2);

		if ((status = FIg_set_location
			(form, TOP_LEFT_MCF, left_xpos, left_ypos)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_set_location = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIg_set_location", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		/*  Center the bottom left mcf on the form  */

		if ((status = FIg_get_location
			(form, BOTTOM_LEFT_MCF, &xpos, &ypos)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }

		if ((status = FIg_set_location
			(form, BOTTOM_LEFT_MCF, left_xpos, ypos)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_set_location = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIg_set_location", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }

	/*  Position the top right and bottom right mcfs  */

	if ((status = FIg_get_location
		(form, TOP_LEFT_MCF, &xpos, &ypos)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = FIg_get_size
		(form, TOP_LEFT_MCF, &xsize, &ysize)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	/*  Position the top right mcf next to the top left mcf  */

	xpos += xsize - ROW_SELECT_BUTTON_SIZE;

	if (no_right_side_gadgets == FALSE)
	  {
		if ((status = FIg_set_location
			(form, TOP_RIGHT_MCF, xpos, ypos)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_set_location = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIg_set_location", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }

	if ((status = FIg_get_location
		(form, BOTTOM_LEFT_MCF, &xpos, &ypos)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_location = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_location", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if ((status = FIg_get_size
		(form, BOTTOM_LEFT_MCF, &xsize, &ysize)) != FI_SUCCESS)
	  {
		_NFIdebug ((fname, "FIg_get_size = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_FORM, "%s%d", "FIg_get_size", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_FORM);
	  }

	if (no_right_side_gadgets == FALSE)
	  {
		/*  Position the bottom right mcf next to the bottom left mcf  */

		xpos += xsize - ROW_SELECT_BUTTON_SIZE;

		if ((status = FIg_set_location
			(form, BOTTOM_RIGHT_MCF, xpos, ypos)) != FI_SUCCESS)
		  {
			_NFIdebug ((fname, "FIg_set_location = <%d>\n", status));
			ERRload_struct
				(NFI, NFI_E_FORM, "%s%d", "FIg_set_location", status);
			_NFIdebug ((fname, " returning FAILURE\n"));
			return (NFI_E_FORM);
		  }
	  }

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }
