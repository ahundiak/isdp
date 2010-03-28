/*
Name
        CEO_LOCATE.status_display_button

Description
        This method is defined here so all COB commands have easy access to a
        method to turn on the status display button on the menu bar.

History
        mrm     09/02/93        creation
*/

class implementation CEO_LOCATE;

method status_display_button(int on)
{
    GRstatus_display_button(on);
    return(OM_S_SUCCESS);
}

end implementation CEO_LOCATE;
