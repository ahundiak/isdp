/*
Name
        GRreffile.debug

Description
        This function will dump the instance data for a reference file
        objects.

History
        mrm     07/20/92    creation
*/

class implementation GRreffile;

%safe
char *not_initialized = "not initialized";
%endsafe

#define safe_string(s)  (s) ? s : not_initialized

method debug()
{
    int i, sts;

    sts = om$send(mode = OM_e_wrt_message,
                  msg = message GRvg.debug(),
                  targetid = my_id);
    if (!(sts & 1)) om$report_error(sts = sts);
    printf("GRreffile->filename = %s\n", safe_string(me->filename));
    printf("GRreffile->osname = %s\n", safe_string(me->osname));
    printf("GRreffile->saved_view = %s\n", safe_string(me->saved_view));
    printf("GRreffile->ref_properties = %#x\n", me->ref_properties);
    printf("GRreffile->description = %s\n", safe_string(me->description));
    printf("GRreffile->scale_factor = %s\n", safe_string(me->scale_factor));
    printf("GRreffile->range = %g, %g, %g\n",
           me->range[0], me->range[1], me->range[2]);
    printf("                   %g, %g, %g\n",
           me->range[3], me->range[4], me->range[5]);
    printf("GRreffile->vw_volume = %g, %g, %g\n",
           me->vw_volume[0], me->vw_volume[1], me->vw_volume[2]);
    printf("                   %g, %g, %g\n",
           me->vw_volume[3], me->vw_volume[4], me->vw_volume[5]);
    printf("GRreffile->vw_rotation = \n");
    for (i = 0; i < 15; i += 4)
        printf("\t%g\t%g\t%g\t%g\n",
               me->vw_rotation[i],
               me->vw_rotation[i + 1],
               me->vw_rotation[i + 2],
               me->vw_rotation[i + 3]);
    printf("GRreffile->vw_origin = %g, %g, %g\n",
           me->vw_origin[0], me->vw_origin[1], me->vw_origin[2]);
    printf("GRreffile->dp_levels = \n");
    for (i = 0; i < 32; i += 8)
        printf("\t%x %x %x %x %x %x %x %x\n",
               me->dp_levels[i],
               me->dp_levels[i + 1],
               me->dp_levels[i + 2],
               me->dp_levels[i + 3],
               me->dp_levels[i + 4],
               me->dp_levels[i + 5],
               me->dp_levels[i + 6],
               me->dp_levels[i + 7]);
    printf("GRreffile->master_to_ref_matrix = \n");
    for (i = 0; i < 15; i += 4)
        printf("\t%g\t%g\t%g\t%g\n",
               me->master_to_ref_matrix[i],
               me->master_to_ref_matrix[i + 1],
               me->master_to_ref_matrix[i + 2],
               me->master_to_ref_matrix[i + 3]);
    printf("GRreffile->ref_to_master_matrix = \n");
    for (i = 0; i < 15; i += 4)
        printf("\t%g\t%g\t%g\t%g\n",
               me->ref_to_master_matrix[i],
               me->ref_to_master_matrix[i + 1],
               me->ref_to_master_matrix[i + 2],
               me->ref_to_master_matrix[i + 3]);
    return(OM_S_SUCCESS);
}

end implementation GRreffile;
