/*
Name
        GRvg.debug

Description
        This method is overridden to dump the GRvg instance data.

History
        mrm     08/09/91    creation
*/

class implementation GRvg;

method debug()
{
    int sts;

    sts = om$send(mode = OM_e_wrt_message,
                  msg = message GRgraphics.debug(),
                  targetid = my_id);
    if (!(sts & 1)) om$report_error(sts = sts);
    printf("GRvg->display_attr.color = %d\n", me->display_attr.color);
    printf("GRvg->display_attr.weight = %d\n", me->display_attr.weight);
    printf("GRvg->display_attr.style = %d\n", me->display_attr.style);
    return(OM_S_SUCCESS);
}

end implementation GRvg;
