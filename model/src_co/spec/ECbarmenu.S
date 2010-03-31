/*
Name
        ECbarmenu

Description
        This command object class is used to swap the bar menus from
        modeling to detailing.  It is anticipated that I/FORMS changes
        will eventually make this command obsolete.

History
        mrm     09/17/91    creation (from ppl commands)
                02/29/92    override help
*/

class specification ECbarmenu (2:0) of super_cmd;

override help, execute;

end specification ECbarmenu;
