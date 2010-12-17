#include "machine.h"
#include "WFF.h"
#include "WFFvlt.h"

/*  Global WFF structure  */

extern struct WFFglobal_st WFFglobal;

long _WFFsetup_vlt ()
  {
	int	vs, status;
	struct	vlt_slot *vlt;
	struct	scr_info info[MAX_SCREENS];

	static	char *fname = "_WFFsetup_vlt";

	if (status = Inq_screen_info (info))
	  {
		_NFIdebug ((fname, "Inq_screen_info = <%d>\n", status));
		ERRload_struct
			(NFI, NFI_E_GRAPHICS, "%s%d", "Inq_screen_info", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_GRAPHICS);
	  }

	if (status = Inq_displayed_vs (&vs))
	  {
		_NFIdebug ((fname, "Inq_displayed_vs = %d\n", status));
		ERRload_struct
			(NFI, NFI_E_GRAPHICS, "%s%d", "Inq_displayed_vs", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_GRAPHICS);
	  }

	if (info[vs].vsi_screen_num == -1)
	  {
		_NFIdebug ((fname, "error getting screen info\n"));
		ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "screen number", -1);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_GRAPHICS);
	  }

	if ((info[vs].vsi_flags & VSI_VIRTUAL_SCREEN) == 0)
	  {
		_NFIdebug ((fname, "virtual screen %d is not usable\n", vs));
		ERRload_struct (NFI, NFI_E_GRAPHICS, "%s%d", "virtual screen", vs);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_GRAPHICS);
	  }

	if (info[vs].vsi_flags & VSI_VLT_FIXED)
	  {
		_NFIdebug ((fname, "There is a fixed vlt present\n"));
		_NFIdebug ((fname, " returning NFI_I_FIXED_VLT\n"));
		return (NFI_I_FIXED_VLT);
	  }

	WFFglobal.numslots = info[vs].vsi_VLT_size;

	/*  Find out what kind of vlt hardware is present  */

	switch (WFFglobal.numslots)
	  {
		case VLT_TWO_SIZE:

			_NFIdebug ((fname, "Loading a vlt with 2 slots ...\n"));

			if (status = Loadvlt (vs, vlt_two, WFFglobal.numslots))
			  {
				_NFIdebug ((fname, "Loadvlt = <%d>\n", status));
				ERRload_struct (NFI, NFI_E_VLT, "%s%d", "Loadvlt", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_VLT);
			  }

		case VLT_FOUR_SIZE:

			_NFIdebug ((fname, "Loading a vlt with 4 slots ...\n"));

			if (status = Loadvlt (vs, vlt_four, WFFglobal.numslots))
			  {
				_NFIdebug ((fname, "Loadvlt = <%d>\n", status));
				ERRload_struct (NFI, NFI_E_VLT, "%s%d", "Loadvlt", status);
				_NFIdebug ((fname, " returning FAILURE\n"));
				return (NFI_E_VLT);
			  }


		default:

			/*  Handle all other cases below  */

			break;
	  }

	if ((vlt = (struct vlt_slot *) malloc
		(WFFglobal.numslots * sizeof (struct vlt_slot))) == NULL)
	  {
		_NFIdebug ((fname, "malloc failed; size = <%d>\n",
			WFFglobal.numslots * sizeof (struct vlt_slot)));
		ERRload_struct (NFI, NFI_E_MALLOC,
			"%d", WFFglobal.numslots * sizeof (struct vlt_slot));
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_MALLOC);
	  }

	if (status = Readvlt (vs, vlt, WFFglobal.numslots, 0))
	  {
		_NFIdebug ((fname, "Readvlt = <%d>\n", status));
		ERRload_struct (NFI, NFI_E_VLT, "%s%d", "Readvlt", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_VLT);
	  }

	/*  Black  */

	vlt[0].v_slot   = (unsigned short) 0;
	vlt[0].v_red    = (unsigned short) 0;
	vlt[0].v_green  = (unsigned short) 0;
	vlt[0].v_blue   = (unsigned short) 0;

	/*  Off white  */

	vlt[1].v_slot   = (unsigned short) 1;
	vlt[1].v_red    = (unsigned short) (MAX_INTENSITY / 15) * 14;
	vlt[1].v_green  = (unsigned short) (MAX_INTENSITY / 15) * 14;
	vlt[1].v_blue   = (unsigned short) (MAX_INTENSITY / 15) * 13;

	/*  Dark grey  */

	vlt[2].v_slot   = (unsigned short) 2;
	vlt[2].v_red    = (unsigned short) (MAX_INTENSITY / 15) * 5;
	vlt[2].v_green  = (unsigned short) (MAX_INTENSITY / 15) * 5;
	vlt[2].v_blue   = (unsigned short) (MAX_INTENSITY / 15) * 5;

	/*  Black  */

	vlt[3].v_slot   = (unsigned short) 3;
	vlt[3].v_red    = (unsigned short) 0;
	vlt[3].v_green  = (unsigned short) 0;
	vlt[3].v_blue   = (unsigned short) 0;

	/*  Yellow  */

	vlt[4].v_slot   = (unsigned short) 4;
	vlt[4].v_red    = (unsigned short) MAX_INTENSITY;
	vlt[4].v_green  = (unsigned short) MAX_INTENSITY;
	vlt[4].v_blue   = (unsigned short) 0;

	/*  Light grey  */

	vlt[5].v_slot   = (unsigned short) 5;
	vlt[5].v_red    = (unsigned short) (MAX_INTENSITY / 15) * 11;
	vlt[5].v_green  = (unsigned short) (MAX_INTENSITY / 15) * 11;
	vlt[5].v_blue   = (unsigned short) (MAX_INTENSITY / 15) * 11;

	/*  Medium grey  */

	vlt[6].v_slot   = (unsigned short) 6;
	vlt[6].v_red    = (unsigned short) (MAX_INTENSITY / 15) * 8;
	vlt[6].v_green  = (unsigned short) (MAX_INTENSITY / 15) * 8;
	vlt[6].v_blue   = (unsigned short) (MAX_INTENSITY / 15) * 8;

	/*  White  */

	vlt[7].v_slot   = (unsigned short) 7;
	vlt[7].v_red    = (unsigned short) MAX_INTENSITY;
	vlt[7].v_green  = (unsigned short) MAX_INTENSITY;
	vlt[7].v_blue   = (unsigned short) MAX_INTENSITY;

	/*  Red  */

	vlt[8].v_slot   = (unsigned short) 8;
	vlt[8].v_red    = (unsigned short) MAX_INTENSITY;
	vlt[8].v_green  = (unsigned short) 0;
	vlt[8].v_blue   = (unsigned short) 0;

	/*  Green  */

	vlt[9].v_slot   = (unsigned short) 9;
	vlt[9].v_red    = (unsigned short) 0;
	vlt[9].v_green  = (unsigned short) MAX_INTENSITY;
	vlt[9].v_blue   = (unsigned short) 0;

	/*  Blue  */

	vlt[10].v_slot  = (unsigned short) 10;
	vlt[10].v_red   = (unsigned short) 0;
	vlt[10].v_green = (unsigned short) 0;
	vlt[10].v_blue  = (unsigned short) MAX_INTENSITY;

	/*  Light yellow  */

	vlt[11].v_slot  = (unsigned short) 11;
	vlt[11].v_red   = (unsigned short) MAX_INTENSITY;
	vlt[11].v_green = (unsigned short) MAX_INTENSITY;
	vlt[11].v_blue  = (unsigned short) (MAX_INTENSITY / 15) * 11;

	/*  Dark red  */

	vlt[12].v_slot  = (unsigned short) 12;
	vlt[12].v_red   = (unsigned short) (MAX_INTENSITY / 15) * 13;
	vlt[12].v_green = (unsigned short) 0;
	vlt[12].v_blue  = (unsigned short) 0;

	/*  Dark green  */

	vlt[13].v_slot  = (unsigned short) 13;
	vlt[13].v_red   = (unsigned short) 0;
	vlt[13].v_green = (unsigned short) (MAX_INTENSITY / 15) * 11;
	vlt[13].v_blue  = (unsigned short) 0;

	/*  Dark blue  */

	vlt[14].v_slot  = (unsigned short) 14;
	vlt[14].v_red   = (unsigned short) 0;
	vlt[14].v_green = (unsigned short) 0;
	vlt[14].v_blue  = (unsigned short) (MAX_INTENSITY / 15) * 12;

	/*  White  */

	vlt[15].v_slot  = (unsigned short) 15;
	vlt[15].v_red   = (unsigned short) MAX_INTENSITY;
	vlt[15].v_green = (unsigned short) MAX_INTENSITY;
	vlt[15].v_blue  = (unsigned short) MAX_INTENSITY;

	if (status = Loadvlt (vs, vlt, WFFglobal.numslots))
	  {
		_NFIdebug ((fname, "Loadvlt = <%d>\n", status));
		free (vlt);
		ERRload_struct (NFI, NFI_E_VLT, "%s%d", "Loadvlt", status);
		_NFIdebug ((fname, " returning FAILURE\n"));
		return (NFI_E_VLT);
	  }

	free (vlt);

	_NFIdebug ((fname, " returning SUCCESS\n"));
	return (NFI_S_SUCCESS);
  }



int _WFFtranslate_color (vs, color)
  int   vs;
  int	color;		
  {
    vs = vs;

    switch (color)
    {
	case FI_RED:
		switch (WFFglobal.numslots)
	        {
			case VLT_TWO_SIZE:
				return (0);       /*  Black               */

			case VLT_FOUR_SIZE:
				return (0);       /*  Black               */

			default:
				return (8);       /*  Red                 */
                }

	case FI_BLUE:
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (0);       /*  Black               */

			case VLT_FOUR_SIZE:
				return (0);       /*  Black               */

			default:
				return (10);      /*  Blue                */
		  }

	case FI_YELLOW:
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (1);       /*  White               */

			case VLT_FOUR_SIZE:
				return (3);       /*  White               */

			default:
				return (4);       /*  Yellow              */
		  }

	case FI_BLACK:
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (0);       /*  Black               */

			case VLT_FOUR_SIZE:
				return (0);       /*  Black               */

			default:
				return (0);       /*  Black               */
		  }

	case FI_DK_GREY:
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (1);       /*  White               */

			case VLT_FOUR_SIZE:
				return (0);       /*  Black               */

			default:
				return (6);       /*  Dark grey           */
		  }

	case FI_MED_GREY:
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (0);       /*  Black               */

			case VLT_FOUR_SIZE:
				return (1);       /*  Medium grey         */

			default:
				return (2);       /*  Medium grey         */
		  }

	case FI_LT_GREY:
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (1);       /*  White               */

			case VLT_FOUR_SIZE:
				return (2);       /*  Light grey          */

			default:
				return (5);       /*  Light grey          */
		  }

	case FI_GREEN:
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (1);       /*  White               */

			case VLT_FOUR_SIZE:
				return (3);       /*  White               */

			default:
				return (9);       /*  Green               */
		  }

	case FI_OFF_WHITE:
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (1);       /*  White               */

			case VLT_FOUR_SIZE:
				return (3);       /*  White               */

			default:
				return (1);       /*  Off white           */
		  }

	default: 
		switch (WFFglobal.numslots)
		  {
			case VLT_TWO_SIZE:
				return (1);       /*  White               */

			case VLT_FOUR_SIZE:
				return (3);       /*  White               */

			default:
				return (7);       /*  White               */
		  }
	}
}
