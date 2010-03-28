/*
Name
        GR3dcircle.debug

Description
        This method is overridden to dump instance data for this class.

History
        mrm     08/09/91    creation
*/

class implementation GR3dcircle;

method debug()
{
    int sts, i;

    sts = om$send(mode = OM_e_wrt_message,
                  msg = message GRvg.debug(),
                  targetid = my_id);
    if (!(sts & 1)) om$report_error(sts = sts);
    printf("GR3dcircle->radius = %g\n", me->radius);
    printf("GR3dcircle->origin = %g, %g, %g\n",
           me->origin[0], me->origin[1], me->origin[2]);
    for (i = 0; i < 9; i += 3)
        printf("GR3dcircle->rot_matrix = %g, %g, %g\n",
               me->rot_matrix[i], me->rot_matrix[i+1], me->rot_matrix[i+2]);

    return(OM_S_SUCCESS);
}

end implementation GR3dcircle;
