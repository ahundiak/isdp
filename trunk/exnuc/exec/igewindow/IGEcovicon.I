
/*----
%GP% CODE CLASSIFICATION
-----
%HD%

	CLASS NAME:	IGEgadget
	METHOD NAME:	covicon

	Abstract:
		This method will handle window uncovered condition
-----
%SC%

	VALUE = covicon (*msg )

-----
%EN%

	ON ENTRY:
									
	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------
	
-----
%EX%

	ON EXIT:

	NAME       DATA TYPE      	    DESCRIPTION
     ----------   ------------   -----------------------------------
      *msg         IGRlong         return condition code
				
-----
%RL%

	RELATIONS REFERENCED:


-----
%NB%

	NOTES:

-----
%CH%

	CHANGE HISTORY

	HT   04/29/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
		M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
      This method will send update message to window that is uncovered.
----*/
/*EH*/


class implementation IGEgadget;

method covicon( IGRlong *msg;struct IGEdit_range *range)
{	
    IGRlong status;
    OMuint  count;
    OM_S_CHANSELECT  chandef;
   
    *msg = MSSUCC;

    chandef.type = OM_e_name;
    chandef.u_sel.name = "to_children";



    status = om$get_channel_count(objid = my_id, 
				  p_chanselect =&chandef, 
				  count = &count);

				
    if ( ! ( 1 & status ) )
    {
	om$report_error(sts = status );
	*msg = MSFAIL;
	goto wrapup;
    }

    if (count)
    {
       status = om$send(mode = OM_e_wrt_object,
                     msg = message IGEgadget.covicon(msg, range),
                     senderid = my_id,
                     p_chanselect = &chandef);

       if ( ! ( 1 & status ) )
       {
	   om$report_error(sts = status );
	   *msg = MSFAIL;
       }
    }

wrapup:
    return ( status );
}

end implementation IGEgadget;
