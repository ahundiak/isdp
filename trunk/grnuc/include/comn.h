/*
Name
        comn.h

Description
        This file contains structures used by the generic manipulation
        commands.

History
        mrm     08/15/88    creation
*/

#ifndef comn_include
#define comn_include

/*
 *  this structure is used to pass information to dynamics functions
 *  through the locate filter
 */

struct COmnlcdyn
{
    IGRint              flags;          /* bit      meaning                 */
                                        /* 0   set if called from locate;   */
                                        /*     clear if called directly     */
                                        /*     from command object          */
                                        /* 1-3 reserved                     */
                                        /* 4-  interpreted as needed        */
    struct GRid         caller;         /* command object                   */
    struct GRmd_env    *curr_mod;       /* current module information       */

    /* exactly one of the next two fields must be filled in */

    OM_S_CHANSELECT    *gschan;         /* graphic set channel; if not      */
                                        /* NULL then points to a channel    */
                                        /* selector containing the results  */
                                        /* of gr$gslocate                   */
    struct GRevent     *event;          /* if not NULL points to an event   */
                                        /* with located_object[0] filled in */
                                        /* as if by lc$locate               */
};

/*
 *  this structure is used to pass info to the copy parallel dynamics function
 */

struct COcppdy
{
    IGRboolean          apparent;
    IGRlong            *msg;
    OM_S_OBJID          caller_id;
    OMuword             caller_os;
    struct GRmd_env     const_mod;
    struct GRevent     *events[3];
    struct GRid         new_object;
};

#endif

