class specification COexp (1:0) of COnpt, CEO_GSLOCATE;



from COnpt       inherit dynamics;


instance COexp
{
    IGRboolean          manual_mode;     /* auto or manual mode */
    struct Explode_list
    {
       struct GRid   grid;
       IGRdouble     lo_parm,
                     hi_parm,
                     lo_point[3],
                     hi_point[3];
    }                   stationary_guy;

};


override filter;

message set_manual_explode ( int     *sts;
                           int      flag );

message check_manual_explode ( long * sts );

message move_along_vec ( long * sts );

message DYmove_vector ( long * sts );

message get_stationary ( long * sts );

message explode_view ( long * sts );

end specification COexp;
