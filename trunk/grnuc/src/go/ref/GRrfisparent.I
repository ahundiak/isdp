/*
Name
        GRreffile.GRisparent

Description
        This file contains the GRreffile override of the GRisparent method,
        which may be used to determine whether the reference file contains
        associative relationships.

        The reference file is assumed to contain associative relationships if
        it is attached to a context object which is attached to a source
        object.

History
        mrm     07/21/93        creation
        jhw     12/3/93         fixed a couple of problems
*/

class implementation GRreffile;
  
#include <alloca.h>

extern OMuword OPP_ASsource_class_id;
extern OM_p_CHANSELECT GRget_GRreffile_to_context();
extern OM_p_CHANSELECT GRget_GRcontext_to_misc();

method GRisparent(IGRlong *msg; IGRboolean *isparent)
{
    int sts, i, j;
    OMuword classid;
    OMuint count, to_context_count = 0, to_misc_count;
    OM_p_OBJECT_LINKAGE to_context_list, to_misc_list;
    OM_p_CHANSELECT reffile_to_context, context_to_misc;

    *msg = TRUE;
    *isparent = FALSE;

    // is the reference file connected to a context object?
    reffile_to_context = GRget_GRreffile_to_context(NULL);
    sts = om$get_channel_count(objid = my_id,
                               p_chanselect = reffile_to_context,
                               count = &to_context_count);
    if (!(sts & 1))
    {   
        *msg = FALSE;
        goto bail;
    }
    if (to_context_count < 1)
        goto bail;

    // grab a list of context objects
    to_context_list = (OM_p_OBJECT_LINKAGE)
        alloca(sizeof(OM_S_OBJECT_LINKAGE) * to_context_count);
    sts = om$get_channel_objects(objid = my_id,
                                 p_chanselect = reffile_to_context,
                                 list = to_context_list,
                                 size = to_context_count,
                                 count = &count);

    // check each context object...
    context_to_misc = GRget_GRcontext_to_misc(NULL);    
    for (i = 0; i < to_context_count && !(*isparent); i++, to_misc_count = 0)
    {
        // ...for anything hooked up on the to_misc channel
        sts = om$get_channel_count(objid = to_context_list[i].S_objid,
                                   p_chanselect = context_to_misc,
                                   count = &to_misc_count);
        if (!(sts & 1) || (to_misc_count < 1))
            continue;

        // grab a list of the objects
        to_misc_list = (OM_p_OBJECT_LINKAGE)
            alloca(sizeof(OM_S_OBJECT_LINKAGE) * to_misc_count);
        sts = om$get_channel_objects(objid = to_context_list[i].S_objid,
                                     p_chanselect = context_to_misc,
                                     list = to_misc_list,
                                     size = to_misc_count,
                                     count = &count);
        if (!(sts & 1))
            continue;

        // loop over the list of objects connected to the context
        for (j = 0; j < to_misc_count; j++)
        {
            // check whether the object is a subclass of ASsource
            om$get_classid(objid = to_misc_list[j].S_objid,
                           p_classid = &classid);
            sts = om$is_ancestry_valid(subclassid = classid,
                                       superclassid = OPP_ASsource_class_id);
            if (sts & 1)
            {
                *isparent = TRUE;
                break; /* out of j loop, i loop will end when *isparent = 1 */
            }
        }
    }
    
  bail:
    
    return(OM_S_SUCCESS);
}

end implementation GRreffile;
