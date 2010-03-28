/*----

    Abstract:  This Command Object implementd the chronos

 CHANGE HISTORY:


	ch          : sept 88  design date
---- */


class specification COchronos(1:0) of COpara;


instance COchronos
{
 struct GRid param_grid;
 struct GRmd_env mod_env;
 IGRdouble min_val, max_val, incr_val;
};

override wakeup, execute;

end specification COchronos;
