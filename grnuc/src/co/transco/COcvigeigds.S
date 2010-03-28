/* #######################    APOGEE COMPILED   ######################## */
class specification COcvigeigds (1:1) of COconst;

instance COcvigeigds
{
    IGRint	select_view_num;
    IGRchar	file_name[80];
    struct GRid view_setup[8];
};

override init, wakeup, execute, sleep;


end specification COcvigeigds;
