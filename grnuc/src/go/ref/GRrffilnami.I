class implementation GRreffile;

method GRrfgetfilename(long *msg; char *name)
{
    *msg = OM_S_SUCCESS;
    if (name)
        strcpy(name, me->filename);

    return (OM_S_SUCCESS);
}
end implementation GRreffile;
