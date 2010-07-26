/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                          < 1986, 1987, 1988 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

class specification CEO_GSLOCATE (1:0) of CEO_LOCATE;

#include <grgsmacros.h>

instance CEO_GSLOCATE
{
	/*****************************************************************/
	/**		  "SEMI-PRIVATE" instance data			**/
	/**  This instance data is set up and referenced by COB.  Users	**/
	/**  may reference these variables directly when necessary,	**/
	/**  although users should not change these variables except	**/
	/**  in cases outlined in the COB Users Guide and/or release	**/
	/**  notes.							**/
	/*****************************************************************/

/** see the gr$gslocate() documentation for more info about these **/
  char	  spec_prompt1[_max_key]; /* prompt for input event 1;		*/
				  /*   defaults to NULL			*/
  char	  spec_prompt2[_max_key]; /* prompt for input event 1;		*/
				  /*   defaults to NULL			*/
  long	  spec_mask1;		  /* input mask for first event, iff it */
				  /*   was a spec obj; defaults to 0    */
  long	  spec_mask2;		  /* input mask for 2nd event, iff it   */
				  /*   was a spec obj; defaults to 0    */
  int	  locate_state;		  /* current state of the locate filter */
  int	  num_inputs;		  /* # of inputs to be returned iff the */
				  /*   first input was a specified      */
				  /*   object; defaults to 1            */
};

	/*****************************************************************/
	/**		     "SEMI-PRIVATE" messages			**/
	/**  These messages are used internally by COB, but they may 	**/
	/**  be sent and/or overridden by COB users as directed in the  **/
	/**  COB Users Guide and release notes.  In general, if any of	**/
	/**  these methods are overridden by the COB user, then the	**/
	/**  user's method should include a send with respect to	**/
	/**  message of the CEO method that was overridden.		**/
	/*****************************************************************/

override init; /* int type; char * str_ptr */

override delete; /* int f_defer_flag (not used) */
  /* delete the graphic set object (along with the CEO and CDO objects) */

override action; /* int	selector; int int_or_str_ptr; int * sts; */

override filter; /* int filter; int * response; char * response_data; */

override disconnect_constructed; /* clear constructed_graphics channel */
  /* int  * sts -- returned status code whatever from gr$gsempty */

override display_located; /* display the objects on the located channel */
  /* int  * sts -- returned status code whatever from gr$gsdisplay */

override display_constructed; /* display constructed_graphics channel objects */
  /* int  * sts -- returned status code whatever from gr$gsdisplay */

override arg_name_to_value;  /* translate a string from the state table into */
			    /*   its variable name value */
	/* Incoming */
  /* int	  addr_mode;	/* == _COB_regular  for regular data  */
				/* == _COB_indirect for "*<arg>"      */
				/* == _COB_address  for "&<arg>"      */
  /* char	* class_name;	/* not NULL => argname used to start  */
				/*   with "me(class_name)->" of some  */
				/*   form; now this has been stripped */
				/* NULL => original arg had no "me->" */
  /* char  	* arg;		/* arg string to find a value for     */
	/* Outgoing */
  /* COB_arg_union * data;	/* value of arg string variable       */
  /* int	* ret_type;	/* type of value found for arg string */
				/*   (see COB_arg.h)		      */
  /* char	* is_const );	/* set to 1 => this variable value is */
				/*   "constant" and needn't be looked */
				/*   up ever again		      */

end specification CEO_GSLOCATE;
