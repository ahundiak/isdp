/*
Name
        GRstatus_display_button

Description
        This function is used to turn the status display button on or
        off.  If "on" is true, then the button on the menu bar is
        highlighted.  If "on" is false, then the status display button
        is dimmed.

History
        mrm     09/18/91    creation
        mrm     07/23/93    changed to call GRhilite_button, which contains
                            the code formerly found here, but in a generic
                            version
*/

#define CMDKEY          "GRStFr"
#define FILLED_SYMBOL   81
#define OUTLINE_SYMBOL  3

void GRstatus_display_button(int on)
{
    GRhilite_button(CMDKEY, on, FILLED_SYMBOL, OUTLINE_SYMBOL);
}
