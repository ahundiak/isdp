/*
Name
        GRowner.GRgetrang

Description
        This method will return the range of an owner.  If the world flag is
        set the range is in world coordinates. Otherwise use identity to find
        the range.

Synopsis
        long      *msg          Completion code
        short     *matrix_type  The type of matrix
        IGRmatrix matrix        The matrix to use if world is set.
        IGRboolean world        Use the matrix to define the world 
                                coordinate system
        GRrange range           The range of owner.

Return Values
        MSSUCC   -  if successful
        MSFAIL   -  if failure
 
History
        Gray Winn       09/09/87    Design Date
        jay wallingford 04/29/89    Optimized the making of the chansel
        jhw             10/17/89    Modified to support zero components
        ashok           11/28/90    Corrected an error in indexing the
                                    subscript of 'range' in the "for" loop
                                    executed when count=0
        mrm             03/20/92    Support NULL matrix, matrix_type when
                                    *world is FALSE.
        henry           07/07/92    Don't choke on objects that don't
                                    understand the GRgetrang message.
        mrm             07/30/92    Restore fix from 03/20/92.
	rmn		12/30/94    range problem fix
*/

class implementation GRowner;

#include "OMprimitives.h"
#include "grimport.h"
#include "msdef.h"
#include "gocmacros.h"
#include "AS_status.h"

extern IGRint   GRget_to_comp_info ();

method GRgetrang(IGRlong *msg; IGRshort *matrix_type; IGRmatrix matrix; 
                 IGRboolean *world; GRrange range)
{
    long              om_msg, ret_msg;
    int               i, j, count, range_found = 0;
    short             local_mx_type,world_mx_type;
    double            *world_mx;
    IGRmatrix         local_matrix,world_mx_buffer;
    GRrange           go_range;
    OM_S_CHANSELECT   chansel;
    GRclassid         classId;


    /* 
     * For rg_collectors, the message should fail
     *   -- fix for improper range of certain Route components
     */

    om_msg = om$get_classid( 	objid		= my_id,
				p_classid	= &classId );
    if( !(om_msg & 1) )
    {
        *msg = MSFAIL;
        return OM_S_SUCCESS;
    }

    if( om$is_ancestry_valid(	subclassid	= classId,
				superclassname	= "ACrg_collect" )
			== OM_S_SUCCESS )
    {
        *msg = MSFAIL;
        return OM_S_SUCCESS ;
    }


    if (*world)
    {
        world_mx = matrix;
        world_mx_type = *matrix_type;
    }
    else
    {
        MAidmx(msg, world_mx_buffer);
        world_mx = world_mx_buffer;
        world_mx_type = MAIDMX;
    }

    /* 
     *  Get the number of objects on my channel.
     */
    om_msg = GRget_to_comp_info(&chansel, OM_Gw_current_OS, my_id, &count);
    if(!(om_msg&1)) goto wrapup;

    /*
     *  Get the component matrix.
     */
    om_msg = om$send(msg = message GRowner.GRget_matrix(msg,
                                                        &world_mx_type, 
                                                        world_mx, 
                                                        &local_mx_type,
                                                        local_matrix),
                      targetid = my_id);

    /* 
     * Cumulate component ranges
     */
    for (i = 0; i < count; i++)
    {
        /*
         *  Get the range of the object.
         */
        om_msg = om$send(msg = message GRvg.GRgetrang(msg, &local_mx_type, 
                                                      local_matrix, world,
                                                      go_range), 
                         p_chanselect = &chansel,
                         from = i,
                         to = i);

        if ((om_msg & *msg & 1) && (om_msg != OM_I_CHAN_EMPTY))
        {
            if (range_found) 
                GRaccumulate_range(&ret_msg, go_range, range);
            else
            {
                range_found = 1;
                for (j = 0; j < 6; j++) 
                    range [j] = go_range [j];
            }
        }
    }

wrapup:

    *msg = MSSUCC;

    if(!range_found){
	*msg = MSFAIL ;
        for (i = 0; i < 6; i++) 
            range [i] = 0.0;
    }

    return OM_S_SUCCESS;
}


end implementation GRowner;
