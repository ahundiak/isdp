/*----

    Abstract:  This Command Object creates graphic associative elements 
	       when these associative elements only requires locate
	       of root (no data point, nor dynamics).

	       The created elements are :
	           - intersection point (command or even generator)
		   - by 2 point segments
		   - bitangent line
		   - window referential
		   - by 3 points referential
		   

    History:
	       JLA 13-july-88 : Design date



---- */



class specification COparaloc (0:1) of COpara;


instance COparaloc
{
GRclassid as_classid;     /* classid of the associative element to construct  */
int num_locate;           /* number of elements to locate   		      */
struct GRid list_id[3];   /* array of located element       		      */
struct GRid context[3];   /* array of corresponding context 		      */
struct GRmd_env env_info[3]; /* array of corresponding locate matrix      */
IGRlong loc[3];           /* array of locate prompt         		      */
IGRlong acc[3];		  /* array of accept prompt         		      */
IGRint  req_type[3];      /* possible geometric type for each element located */
IGRint  obt_type[3];      /* obtain type */
IGRboolean reput[3];      /* Is accept point to be reput in input queue       */

IGRint  restart_state;    /* state  to restart the command after construction */
IGRint  restart_action;   /* action to restart the command after construction */
IGRint  reput_locate;     /* Is there a locate to reput and index of this     */
			  /* locate					      */

struct GRevent grevent;   /* first event used by locate 		      */
IGRdouble  snap[16];	  /* additionnal information for associative element  */
};

override wakeup, execute;

end specification COparaloc;
