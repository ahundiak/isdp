/*
Name
        GR3dinfline.debug

Description
        This method is overridden to dump instance data for this class.

History
        mrm     08/09/91    creation
*/

class implementation GR3dinfline;

method debug()
{
    int sts;

    sts = om$send(mode = OM_e_wrt_message,
                  msg = message GRvg.debug(),
                  targetid = my_id);
    if (!(sts & 1)) om$report_error(sts = sts);
    printf("GR3dinfline->points = %g, %g, %g\n",
           me->points[0], me->points[1], me->points[2]);
    printf("GR3dinfline->points = %g, %g, %g\n",
           me->points[3], me->points[4], me->points[5]);
    return(OM_S_SUCCESS);
}

end implementation GR3dinfline;
