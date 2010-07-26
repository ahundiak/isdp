
/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     IGEgadget
        METHOD NAME:    movicon

        Abstract:
                This method will handle window move icon .
                (move window, stretch window, stretch and move window)
-----
%SC%

        VALUE = movicon (*msg, *win_no,*flag,*minx,*miny,*maxx,*maxy)

-----
%EN%

        ON ENTRY:
                                                                        
        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------
      *win_no      IGRint        pointer to hardware window number
      *flag        IGRint        flag = 0 move, 1 stretch, 2 stretch+move
      *minx        IGRint      
      *miny        IGRint
      *maxx        IGRint
      *maxy        IGRint
        
-----
%EX%

        ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
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
         This method will update window size information in instance
         data and send update message to self.
----*/
/*EH*/


class implementation IGEgadget;


method movicon( IGRlong *msg; IGRint *win_no; IGRint *flag;
        IGRint *minx;IGRint *miny; IGRint *maxx; IGRint *maxy)
{       
        
    IGRlong status;
    OMuint  count;
    OM_S_CHANSELECT  chandef;

    status = OM_S_SUCCESS;

   
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
                     msg = message IGEgadget.movicon(msg, win_no, flag, 
                                                minx, miny, maxx, maxy),
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
