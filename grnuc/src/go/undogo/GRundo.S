/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
Name
        GRundo

Description
        This class implements an undo ability, initially limited to undelete.

History
        mrm     09/05/86    Creation
                10/22/87    subclass with GRcmpowner
                02/29/88    override wakeup & sleep to disallow undelete 
                            between design sessions
*/

class specification GRundo (2:0) of GRcmpowner, global_class;

#include "igrtypedef.h"
#include "igetypedef.h"
#include "gr.h"

instance GRundo
{
    IGRchar                 undo_on;     /* is undo on? */
    IGRchar                 can_undo;    /* is undo valid ? */
    IGRchar                 was_gra_set; /* last obj saved a graphics set? */
    struct  GRmd_env        context;     /* context of original */
    channel
    {
        (many_to_many,
         rel_ordered,
         initial=1,
         increment=1)
    }                       to_grset;    /* save graphic sets here */

};

/*
 *  method declarations
 */

/*
Name    GRudsave

Description
        This method saves a deleted object on a channel for
        future undeletion.  Objects being saved when this method is
        invoked are deleted.  If undelete is off when this method is
        invoked the object is deleted immediately.
*/

message GRudsave (IGRlong *msg; struct GRid *add_id; struct GRmd_env *add_mod);

/*
Name
        GRudundo

Description
        This method "undoes" a previous deletion by restoring 
        displayability and locatability to the object.
*/

message GRudundo (IGRlong *msg; IGRint *undo_status);

/*
Name
        GRudonoff

Description
        This method toggles the status of undo.
*/

message GRudonoff (IGRlong *msg; IGRint *undo_on);

/*
 *  overrides
 */

/*
Name
        super_construct

Motivation
        This method initializes the instance data of the undo object.
*/

override super_construct,

/*
Name
        wake_up

Motivation
        This method deletes any objects saved in a previous design
        session, since undelete is not allowed to carry between sessions.
*/
        wake_up,

/*
Name
        sleep

Motivation
        This method deletes any objects being saved for undeletion, since
        undelete is not allowed to carry between sessions.
*/
        sleep;

end specification GRundo;
