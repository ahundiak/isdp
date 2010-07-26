/*
Name
        GR3dellarc.debug

Description
        This method is overridden to dump instance data for this class.

History
        mrm     08/09/91    creation
*/

class implementation GR3dellarc;

method debug()
{
    int sts, i;

    sts = om$send(mode = OM_e_wrt_message,
                  msg = message GRvg.debug(),
                  targetid = my_id);
    if (!(sts & 1)) om$report_error(sts = sts);
    printf("GR3dellarc->prim_axis = %g\n", me->prim_axis);
    printf("GR3dellarc->sec_axis = %g\n", me->sec_axis);
    printf("GR3dellarc->origin = %g, %g, %g\n",
           me->origin[0], me->origin[1], me->origin[2]);
    for (i = 0; i < 9; i += 3)
        printf("GR3dellarc->rot_matrix = %g, %g, %g\n",
               me->rot_matrix[i], me->rot_matrix[i+1], me->rot_matrix[i+2]);
    printf("GR3dellarc->start_angle = %g\n", me->start_angle);
    printf("GR3dellarc->sweep_angle = %g\n", me->sweep_angle);

    return(OM_S_SUCCESS);
}

end implementation GR3dellarc;
