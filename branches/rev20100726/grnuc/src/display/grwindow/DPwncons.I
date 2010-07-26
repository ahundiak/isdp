/*----
%GP% CODE CLASSIFICATION
-----
%HD%

        CLASS NAME:     GRwindow
        METHOD NAME:    window_cons

        Abstract:
-----
%SC%

        VALUE =

-----
%EN%

        ON ENTRY:
                                                                        
        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

        ON EXIT:

        NAME       DATA TYPE                DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%RL%

        RELATIONS REFERENCED:
                                GRwswn
                                GRwnvw

-----
%NB%


        
-----
%CH%

        CHANGE HISTORY

        MP    09/12/85  : Design date.
        mrm   11/25/91    ifdef'ed out EnvironV call for RUN_X
-----
%PD%
--------------------------------------------------------------------
                M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------

----*/
/*EH*/


class implementation GRwindow;

method window_cons(IGRlong *msg; GRobjid mod_id; IGRchar *name;
                   int win_type; int  screen;
                   IGRboolean dep_indep;IGRdouble min_x, min_y, max_x, max_y;
                   IGRint win_level;
                   IGRshort right_space, left_space, top_space, bottom_space;
                   IGRboolean draw_border;
                   IGRint icon_flags; IGRchar *symbol_name; 
                   IGRshort symbol_number; IGRint collapse;
                   IGRdouble *collapse_pos;
                   IGRlong *cursor_enable_pattern;
                   IGRlong *cursor_data_pattern;
                   IGRlong *cursor_hot_spot)
{
    IGRint stat;
    OM_S_CHANSELECT chandef1,chandef2;	

    stat = om$send(mode = OM_e_wrt_message,
                   msg = message IGEwindow.window_cons(msg,mod_id, name,
                                                       win_type, screen,
                                                       dep_indep, min_x,
                                                       min_y, max_x,
                                                       max_y, win_level,
                                                       right_space,
                                                       left_space,
                                                       top_space,
                                                       bottom_space,
                                                       draw_border,
                                                       icon_flags,
                                                       symbol_name,
                                                       symbol_number,
                                                       collapse,
                                                       collapse_pos,
                                                       cursor_enable_pattern,
                                                       cursor_data_pattern,
                                                       cursor_hot_spot),
                    targetid = my_id);

    if (!(stat & 1))
    {
#ifdef DEBUG
        om$report_error(sts = stat);
#endif
        goto fini;
    }

    /* Connecting the window to the workstation */

    chandef1.type = OM_e_name;
    chandef1.u_sel.name = "GRwindow.module";
                
    chandef2.type = OM_e_name;
    chandef2.u_sel.name = "windows";

    stat = om$send(msg = message Root.connect(chandef2, NULL, my_id,
                                              OM_Gw_current_OS, 
                                              chandef1, NULL ), 
                   senderid = my_id, 
                   targetid = mod_id);

#ifdef DEBUG
    if (!(stat & 1))
    {
        om$report_error(sts = stat);
    }
#endif

  fini:
    return (stat);
}


method activate(IGRlong *msg; IGRint win_no)
{
    IGRint status;

    status = om$send(mode = OM_e_wrt_message,
                     msg = message IGEwindow.activate(msg,win_no),
                     targetid = my_id);

    return(status);

}

end implementation GRwindow;
