/*
Name
        GR3dpoint.debug

Description
        This method is overridden to dump instance data for this class.

History
        mrm     08/09/91    creation
*/

class implementation GR3dpoint;

method debug()
{
    int sts;

    sts = om$send(mode = OM_e_wrt_message,
                  msg = message GRvg.debug(),
                  targetid = my_id);
    if (!(sts & 1)) om$report_error(sts = sts);
    printf("GR3dpoint->point = %g, %g, %g\n",
           me->point[0], me->point[1], me->point[2]);
    return(OM_S_SUCCESS);
}

end implementation GR3dpoint;
