/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRmodule
	METHOD NAME:	DPupdate       update all window

	Abstract:  this method will channel send to eveay window
                   connected to module a update message.

-----
%SC%

	value = DPupdate (msg,update_all)

-----
%EN%

	ON ENTRY:

	NAME		DATA TYPE	     DESCRIPTION
       ------  		-----------    	     ----------------------------

       *update_all	IGRboolean	     this flags tells hidden
					     line windows to ignore
					     the update method
       
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

		IGEwindow.DPupdate

-----
%RL%

	RELATIONS REFERENCED:


-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	HT  01/09/86	: Design date.

-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	  This method is used to update all windows.  The method
	channel sends to all windows connected on the module_to_window
        channel.

----*/
/*EH*/

   

	class implementation GRmodule;

	    method DPupdate (IGRlong *msg; struct DPdit_range *range; 
				IGRboolean *update_all)


 	    {
	      
	       IGRint sts;	

	       OM_S_CHANSELECT	chandef;
	
		*msg = MSSUCC;

		chandef.type = OM_e_name;
		chandef.u_sel.name = "windows";

		

		sts = om$send(mode = OM_e_wrt_object,
                              msg = message IGEdisplay.DPupdate(msg,NULL,
							update_all),
                              senderid = my_id,
                              p_chanselect = &chandef,
                              from = NULL,
                              to = NULL);

		if (!(sts & 1))
		{
#ifdef DEBUG
		  printf("Error in GRmodule send to Window's DPupdate, Error: ");
		  om$report_error(sts = sts);
#endif
		  *msg = MSFAIL;
		}

	return(sts);


	}
	end implementation GRmodule;
