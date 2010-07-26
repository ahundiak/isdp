/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	GRmodule
	METHOD NAME:	DPdisbyoid	display element(s) by object id

	Abstract:  Will display the graphics objects that are sent to this
		   routine in all window associated with this Window.

-----
%SC%

	value = DPdisbyoid (msg,mode,buffer,no_oids,type,matrix)

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

       *buffer		struct GRid	        buffer containing graphic 
						object ids and corresponding
						object space numbers

       *no_oids		IGRlong			number of object ids


       *type		IGRshort		type of the matrix

       *matrix[]		IGRmatrix		matrix associated with
						object id

       *alt_symb	struct IGRaltdisplay	alternate display symbology

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

		IGEwindow.disbyoid

-----
%RL%

	RELATIONS REFERENCED:


-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	AET  01/09/86	: Design date.
	AET  07/30/88	: Added alternate symbology
-----
%PD%
--------------------------------------------------------------------
	      M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

	  This method is used to display element(s) (graphic object)
	which has not been formatted for display.  The method
	channel sends to all views connected on the active channel.

----*/
/*EH*/

   

	class implementation GRmodule;

	    method DPdisbyoid (IGRlong *msg;enum GRdpmode *mode;
			       struct GRid *buffer; IGRlong *no_oids;
			       IGRshort *type; IGRmatrix *matrix[];
			       struct IGRaltdisplay *alt_symb)



 	    {
	      
	       IGRint sts;	
	       OM_S_CHANSELECT	chandef;

		*msg = MSSUCC;


		chandef.type = OM_e_name;
		chandef.u_sel.name = "windows";

		sts = om$send(mode = OM_e_wrt_object,
                              msg = message IGEdisplay.DPdisbyoid(msg,mode,
						buffer,no_oids, type,matrix,
						alt_symb),
                              senderid = my_id,
                              p_chanselect = &chandef,
                              from = NULL,
                              to = NULL);

		if (!(sts & 1))
		{
#ifdef DEBUG
		  printf("Error in GRmodule send to Window's DPdisbyoid, Error: ");
		  om$report_error(sts = sts);
#endif
		  *msg = MSFAIL;
		}

	return(sts);


	}
	end implementation GRmodule;
