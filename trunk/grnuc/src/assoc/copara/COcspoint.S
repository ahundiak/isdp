/*----

    Abstract:  This Command Object creates and displays the associative
    	       point on coordinate system defined by 3 parameters

 CHANGE HISTORY:
    momo  Nov 1988 :  design date.

---- */

class specification COcspoint (0:1) of COpara;

instance COcspoint
{
    IGRchar		param_type;    /* type of coordinates ( cart... ) */
    struct ret_struct  	cs_struct;     /* structure of the parent         */
    int			msg_numb[3];   /* prompts			  */
    struct GRid        	list_id[4];
    struct GRid        	context[4];
};

override    wakeup, execute;

end specification COcspoint;
