/* #######################    APOGEE COMPILED   ######################## */
class specification COsdrename (1:0) of COroot;

instance COsdrename
{
    IGRint          asl_defined;
    struct GRid     sym_id;
    struct GRid     mod_id;
    struct GRmd_env asl_mod_env;
};

override init, wakeup, execute;

end specification COsdrename;
