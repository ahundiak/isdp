/*----

    Abstract:  This Command Object implementd the iterator

 CHANGE HISTORY:


	bd          : 18-nov-86  design date
---- */


class specification COiterator (1:0) of COpara;


instance COiterator
{
 struct GRid obj_grid,param_grid;
 struct GRevent grevent0;
 struct GRevent grevent2;
 IGRdouble value;
 IGRint obj_type;
};

override wakeup, execute;

end specification COiterator;
