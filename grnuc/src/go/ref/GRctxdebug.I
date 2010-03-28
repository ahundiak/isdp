/*
Name
        GRcontext.debug

Description
        This function will dump the instance data for a context file object.

History
        mrm     07/20/92    creation
*/

class implementation GRcontext;

method debug()
{
    int i;

    printf("GRcontext->mx_type = %d\n", me->mx_type);
    printf("GRcontext->matrix = \n");
    for (i = 0; i < 16; i += 4)
        printf("\t%g\t%g\t%g\t%g\n",
               me->matrix[i],
               me->matrix[i + 1],
               me->matrix[i + 2],
               me->matrix[i + 3]);
    printf("GRcontext->flags = %#x\n", me->flags);
    printf("GRcontext->osnum = %d\n", me->osnum);
    return(OM_S_SUCCESS);
}

end implementation GRcontext;
