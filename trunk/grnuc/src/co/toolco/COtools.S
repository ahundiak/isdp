/*

Class: 

    COtool

Description:    

    This class provides misc methods for use in a command object's state 
    table.

Abstract class: 

    Yes

Messages:   

unix files:

    access_file
    open_file
    close_file

event manipulation:

    store_event
    copy_event
    fetch_event
    push_event

comparisons and assignments:

    assign
    compare
    inrange
    add
    
directory lookup and actions:

    translate
    cd
    path

graphic manipulation:

    change_name

graphic sets manipulation:

    make_grset
    delete_grset
    empty_channel

misc actions:

    wait
    erase_highlight
    confirm
    color_menu_button

History:    

    jay wallingford     04/10/89    creation date
    jhw                 09/15/89    added inrange method
    jhw                 10/17/89    added cd and path
    jhw                 06/11/90    added increment and decrement
    mrm                 07/22/93    added confirm
    mrm                 08/11/93    added color_menu_button

Bugs:       
     
    There are no known bugs.

Notes:
*/

class specification COtools (1:0) of Root;

#include "OMprimitives.h"
#include "OMminimum.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "ODE.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "griodef.h"
#include "grio.h"
#include "bsvalues.h"
#include "msdef.h"
#include "toolco.h"

instance COtools
{
    char *  fp;	/* Can't use FILE * because of opp prob with shared lib */
    variable struct GRevent events[];
};

/*
 * access_file  : Checks the access of a file. If the path pointer is 
 *                specified the full path is returned. The mask indicates
 *                the mode, type and existence of the file.
 *
 *                existence CO_file_exists, CO_no_file
 *                type      CO_file_dir, CO_file_reg
 *                mode      CO_file_read, CO_file_write, CO_file_execute
 * 
 * return       : MSSUCC - success, file passes mask check
 *                MSFAIL - failure, file doesn't pass mask check
 */ 
message access_file ( IGRint * msg;
                      IGRint mask;
                      IGRchar * name;
                      IGRchar * path );

/*
 * open_file    : Opens and/or checks a file.
 *
 * return       : MSSUCC
 *                MSFAIL - failure, file failed to open
 */
message open_file ( IGRint * msg;
                    IGRchar * name;
                    IGRchar * op );

/*
 * close_file   : Closes file associated with fp.
 */
message close_file ();


/*
 * store_event : Stores a event into a specific index in
 *               an array of events. The event array is 
 *               variable.
 */

message store_event ( struct GRevent * event;
                      IGRint to_index );

/*
 * copy_event   : Copies an event from index to index.
 */
message copy_event ( IGRint from_index;
                     IGRint to_index );

/*
 * fetch_event  : Fetches an event from index to event pointer.
 */
message fetch_event ( IGRint from_index;
                      struct GRevent * event );

/*
 * push_event   : Pushes an event onto the input queue.
 */
message push_event ( struct GRevent * event );

/*
 * assign       : Assigns an value to another value. The value types of 
 *                the assignments are listed in comco.h.
 */
message assign ( IGRchar * from_value;
                 IGRchar * to_value;
                 IGRint type );

/*
 * compare      : Compares a value to another value. 
 *                Only equivalence comparisons are valid with the types 
 *                CO_matrix, CO_point and CO_string.
 *
 * return       : relation is returned
 *          
 */
message compare ( IGRint * relation;
                  IGRchar * from_value;
                  IGRchar * to_value;
                  IGRint type );

/*
 * inrange      : Determine whether a value is within a range.
 *                CO_dbl_to_int, CO_int_to_int and CO_str_to_str
 *                are the only types currently supported.
 *
 * return       : MSSUCC or MSFAIL
 *          
 */
message inrange ( IGRint * result;
                  IGRchar * value;
                  IGRchar * low_value;
                  IGRchar * high_value;
                  IGRint type );

/*
 * erase_highlight : Erases the highlight plane for the current module.
 */
message erase_highlight ();

/*
 * empty_channel  : Empties the channel pointed to by p_chansel.
 */
message empty_channel ( OM_S_CHANSELECT * p_chansel );

/*
 * change_name : Changes the name of the object on channel.
 */
message change_name ( IGRint * msg;
                      OM_S_CHANSELECT * p_chansel;
                      IGRchar * name );

/*
 * wait : Wait a specified number of 60ths of a second.
 */
message wait ( IGRint timer );

/*
 * cd : Changes current working directory.
 */
message cd ( IGRchar * dirname );

/*
 * path : Constructs a system path from the input name.
 */
message path ( IGRchar * name; 
               IGRchar * path );

/*
 * translate : Returns an objid and osnum for the input name.
 */
message translate ( IGRint * msg;
                    IGRchar * name;
                    OM_S_OBJID * objid;
                    OMuword * osnum );

/*
 * make_grset : Creates a graphics set from a list of object ids
 *              and returns an EX_OBJID event containing the grset id.
 */
message make_grset ( IGRint * msg;
                     struct GRid * gr_ids;
                     IGRint num;
                     struct GRevent * event );

/*
 * delete_grset : Deletes all objects in the graphics set on the specified
 *                chanselect.
 */
message delete_grset ( IGRint * msg;
                       OM_S_CHANSELECT * chansel );

/*
 * add          : Adds j to an integer.
 */
message add (IGRint * i; IGRint j);

/*
 * confirm : Uses the confirm box to ask the user a yes/no question.
 *           Yes returns a TRUE in answer, No returns FALSE.
 */
message confirm(int message_key; int *answer);

/*
 * color_menu_button : Highlights a menu bar button by changing its icon color.
 */
message color_menu_button(char *cmdkey; int color);

end specification COtools;
