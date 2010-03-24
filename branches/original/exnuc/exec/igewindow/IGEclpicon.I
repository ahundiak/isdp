
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
	CLASS NAME:	IGEgadget
	METHOD NAME:	clpicon
 
     	Abstract: This method toggles the active bit setting in window
		  instance data and send update message to window if
                  uncollapsed. If the window collapsed, toggle the
                  active bit.
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
      *flag        IGRint           flag = 0 uncollapsed
					 = 1 collapsed
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg           IGRlong	 MSSUCC -- successful completion

-----
%RL%

	RELATIONS REFERENCED:

-----
%NB%

     NOTES:
-----
%CH%
     CHANGE HISTORY:

	HT 04/29/86  : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------

     	 This method toggles the active bit setting in window
         instance data and send update message to window if
         uncollapsed. If the window collapsed, toggle the
         active bit.
----*/
/*EH*/

class implementation IGEgadget;


method clpicon (IGRlong *msg; IGRint *flag)

{

IGRlong status ;
OMuint  count;
OM_S_CHANSELECT chandef;

status = OM_S_SUCCESS;
*msg = MSSUCC;

   chandef.type = OM_e_name;
   chandef.u_sel.name = "to_children";



   status = om$get_channel_count(objid = my_id, 
				 p_chanselect = &chandef, 
				 count = &count);



   if (!(status & 1))
   {
	om$report_error(sts = status);
	goto wrapup;
   }
				
   if (count)				
   {

      status = om$send(mode = OM_e_wrt_object,
                    msg = message IGEgadget.clpicon(msg,flag),
                    senderid = my_id,
		    p_chanselect = &chandef);

      if ( !(1 & status) )
      {
          om$report_error(sts = status);
          printf("Error: collapse icon send to gadgets clpicon\n");
 
     }
   }

wrapup:
  return (status);

}
end implementation IGEgadget;
