/*
Name
        GRgraphics.debug

Description
        This method is overridden to dump the GRgraphics instance data.

History
        mrm     08/09/91    creation
*/

class implementation GRgraphics;

method debug()
{
    int sts;
    char classname[32];

    sts = om$get_classname(object = me, classname = classname);
    if (!(sts & 1))
    {
        sprintf(classname, "Unknown class");
        om$report_error(sts = sts);
    }
    printf("Object (%d, %d) %s\n", OM_Gw_current_OS, my_id, classname);
    printf("GRgraphics->properties = %#x\n", me->properties);
    printf("GRgraphics->level = %d\n", me->level);
    return(OM_S_SUCCESS);
}

end implementation GRgraphics;
