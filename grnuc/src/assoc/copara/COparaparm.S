/*----

    Abstract:  This Command Object creates graphic associative elements 
	       when these associative elements only require 
	       - locate of graphic root
	       - locate of a parameter


    History:
	       momo 18-jan-89 : Design date

---- */

class specification COparaparm (0:1) of COpara;


instance COparaparm
{
 GRclassid 		as_classid;     /* classid of the associative element */
                                	/* to construct                       */

 IGRint			restart_state;  /* state to restard the command       */
                                        /* after construction                 */
 IGRint  		restart_action; /* action to restart the command      */
                                        /* after construction                 */

 IGRint			num_locate;     /* number of elements to locate	      */
 IGRint  		req_type[3];    /* possible geometric type for each   */
                                        /* element located                    */
 IGRlong 		loc[3];         /* array of locate prompt             */
 IGRlong 		acc[3];	        /* array of accept prompt             */
 IGRdouble		snap[3];        /* add information                    */
 IGRboolean 		reput[3];       /* Is accept point to be reput in     */
 struct ret_struct      ret_struct[3];  /* array of ocrresponding ret struct  */
 struct GRmd_env        env_info[3];    /* array of correspondig env info     */

 struct GRid 		list_id[5];     /* array of located element   	      */
                                        /* input queue                        */
 struct GRid 		context[5];     /* array of corresponding context     */

 double first_view_vect[3];             /* view vector for first locate       */
 struct GRevent 	grevent;    	/* first event used by locate 	      */
 double value;				/* value of parameter to create       */
};

override wakeup, execute;

end specification COparaparm;
