/* $Revision: 1.1 $ */
/* Function:	x_dummy */

/*
	This function is stubbed out, and put in dba.a because it is
        not necessary to setup the cursor unless we are using X-Windows.
        When x.o is linked in this stub should never come out 
        of the library.

        XSync is being called from dba_fldtrm, the notification
        routine in order to be sure that the buttons go down before
        we go off and do what the button does.

*/
int *dba_display;
void dba_x_cursor() {}
void dba_x_form() {}
void dba_xsync() {}
