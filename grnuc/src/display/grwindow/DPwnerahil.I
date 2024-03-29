/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     GRwindow
        METHOD NAME:    DPerase_hilite       erase highlight plane

        Abstract:  this method will channel send to eveay window
                   connected to GRwindow a erase highlight message.

-----
%SC%

        value = DPupdate (msg)

-----
%EN%

        ON ENTRY:

        NAME            DATA TYPE            DESCRIPTION
       ------           -----------          ----------------------------
       
-----
%EX%

        ON EXIT:

        NAME    DATA TYPE       DESCRIPTION
       ------  -----------    ----------------------------
        msg     IGRlong         return status
                                  MSSUCC - successfully completed
                                  MSFAIL - unsuccessfully completed


-----
%MD%

        MODULES AND METHODS INVOKED:

                IGEgragad.DPerase_hilite

-----
%RL%

        RELATIONS REFERENCED:


-----
%NB%

        NOTES:

-----
%CH%

        CHANGE HISTORY

        AET  03/16/87    : Design date.

-----
%PD%
--------------------------------------------------------------------
              M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

          This method is used to update all windows.  The method
        channel sends to all windows connected on the GRwindow_to_window
        channel.

----*/
/*EH*/

   

        class implementation GRwindow;


            method DPerase_hilite (IGRlong *msg)


            {
              
               IGRint sts;      
               OMuint count;
               OM_S_CHANSELECT  chandef;
        
                *msg = MSSUCC;

                chandef.type = OM_e_name;
                chandef.u_sel.name = "to_children";


                sts = om$get_channel_count(objid = my_id, 
                                 p_chanselect = &chandef, 
                                 count = &count);



                if (!(sts & 1))
                {
#ifdef DEBUG
                   om$report_error(sts = sts);
#endif
                   goto wrapup;
                }
                                
                if (count)                              
                {
                

                   sts = om$send(mode = OM_e_wrt_object,
                              msg = message IGEdisplay.DPerase_hilite(msg),
                              senderid = my_id,
                              p_chanselect = &chandef,
                              from = NULL,
                              to = NULL);

                   if (!(sts & 1))
                   {
#ifdef DEBUG
                      printf("Error in GRwindow send to IGEgragad's DPerase_hilite, Error: ");
                      om$report_error(sts = sts);
#endif
                      *msg = MSFAIL;
                    }
                }
                
wrapup:         
        return(sts);


        }
        end implementation GRwindow;
