/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRmodule
	METHOD NAME:	DPdisbybuf	display element(s) by buf

	Abstract:  Will display the graphics objects that are sent to this
		   routine in all window associated with this GRmodule.
-----
%SC%

	value = DPdisbybuf (msg,mode,buffer,no_elem)

-----
%EN%

	ON ENTRY:

	NAME		DATA TYPE	     DESCRIPTION
       ------  		-----------    	     ----------------------------
       *mode		GRdpmode		The mode of the object
					     EX:
						GRbd    GRbe
						GRhd    GRhe
						GRbdhd  GRbehe
						GRbdhe  GRbehd

       *buffer		struct DPele_header     buffer containing section
						of elem

       *no_elem		IGRlong			number of object ids


-----
%EX%

	ON EXIT:

	NAME	DATA TYPE	DESCRIPTION
       ------  -----------    ----------------------------
	msg	IGRlong		return status
				  MSSUCC - successfully completed
				  MSFAIL - unsuccessfully completed
-----
%MD%

	MODULES AND METHODS INVOKED:

		IGEwindow.disbybuf
-----
%RL%

	RELATIONS REFERENCED:

		module_to_window

-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	HT  05/19/86	: Design date.
-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	  This method is used to display element(s) temporarily (no object
        is created)
	The method channel sends to all views connected on the active channel.

----*/
/*EH*/

   

class implementation GRmodule;

#include "dpstruct.h"

method DPdisbybuf (IGRlong *msg;enum GRdpmode *mode;
			struct DPele_header *buffer; IGRlong *no_elem;
			IGRint view_ind; IGRint view_ind_type;
			IGRdouble *view_ind_point)



    {
	      
	       IGRint sts;
	       OM_S_CHANSELECT	chandef;
	
		*msg = MSSUCC;

		chandef.type = OM_e_name;
		chandef.u_sel.name = "windows";
		

		sts = om$send(mode = OM_e_wrt_object,
                              msg = message IGEdisplay.DPdisbybuf(msg,mode,
							buffer,no_elem,
							view_ind,view_ind_type,
							view_ind_point),
                              senderid = my_id,
                              p_chanselect = &chandef,
                              from = NULL,
                              to = NULL);

		if (!(sts & 1))
		{
#ifdef DEBUG
		  printf("Error in GRmodule send to Window's DPdisbybuf, Error: ");
		  om$report_error(sts = sts);
#endif
		  *msg = MSFAIL;
		}

	return(sts);


	}
	end implementation GRmodule;
