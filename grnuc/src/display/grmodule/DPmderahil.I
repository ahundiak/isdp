/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRmodule
	METHOD NAME:	DPerase_hilite       update all window

	Abstract:  this method will channel send to eveay window
                   connected to module a update message.

-----
%SC%

	value = DPerase_hilite (msg)

-----
%EN%

	ON ENTRY:

	NAME		DATA TYPE	     DESCRIPTION
       ------  		-----------    	     ----------------------------

       
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

		IGEwindow.DPerase_hilite

-----
%RL%

	RELATIONS REFERENCED:


-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	AET  03/14/87	: Design date.

-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	  This method is used to erase the highlight plane from all windows.
	  The method channel sends to all windows connected on the 
	   module_to_window channel.

----*/
/*EH*/

   

class implementation GRmodule;

	
	    method DPerase_hilite (IGRlong *msg)


 	    {
	      
	       IGRint sts;	

	       OM_S_CHANSELECT	chandef;
	
		*msg = MSSUCC;

		chandef.type = OM_e_name;
		chandef.u_sel.name = "windows";

		

		sts = om$send(mode = OM_e_wrt_object,
                              msg = message IGEdisplay.DPerase_hilite(msg),
                              senderid = my_id,
                              p_chanselect = &chandef,
                              from = NULL,
                              to = NULL);

		if (!(sts & 1))
		{
#ifdef DEBUG
		  printf("Error in GRmodule send to Window's DPerase_hilite, Error: ");
		  om$report_error(sts = sts);
#endif
		  *msg = MSFAIL;
		}

	return(sts);


	}
	end implementation GRmodule;
