#define BASIC_SIZE  1000000       	/* the size of one memory element in 
					   TOadd_mo */

/* switches for edge comparing and splitting in TOedstitch.I */

#define TOcheck_interval	0x01	/* only check mid_point of an interval*/
#define TOget_interval          0x02	/* get overlap interval
                                           between 2 curve*/
#define TOsplit_edges		0x04	/* determine overlap interval between
          				   two edges and define part edges
                 			   in the topo data structures */
#define TOstitch_top_tol  	0x08	/* use the given tolerance */
#define TOanalyz_p_cont		0x10	/* analyze point continuity */
#define TOanalyz_n_cont		0x20	/* analyze normal continuity */
#define TOanalyz_r_cont		0x40	/* analyze radius continuity */
#define TOstitch_no_range_check 0x80	/* don't compare min-max boxes
					   the edges before computing distance*/
#define TOinvest_p_cont		0x100	/* invest point continuity */
#define TOinvest_n_cont		0x200	/* invest normal continuity */
#define TOinvest_r_cont		0x400	/* invest radius continuity */

/* return values for TOedstitch.I */

#define TOanalyze_failed       	-1	/*calculation in TOedstitch failed*/
#define TOno_conti		 0	/*no point continuity satisfied */
#define TOpoint_conti		 1	/*point continuity satisfied for tole*/
#define TOnormal_conti		 2	/*normal cont satisfied for tolerance*/
#define TOradius_conti		 3	/*radius cont satisfied for tolerance*/
