class specification CEO_LOCATE (1:0) of CEO;

#include <igr.h>
#include <igrdp.h>
#include <gr.h>
#include <godef.h>
#include <griodef.h>
#include <go.h>
#include <grio.h>
#include <dp.h>

#include <grdpbdef.h>
#include <grdpb.h>

#include <lcdef.h>
#include <lc.h>


instance CEO_LOCATE
{
	/*****************************************************************/
	/**		  "SEMI-PRIVATE" instance data			**/
	/**  This instance data is set up and referenced by COB.  Users	**/
	/**  may reference these variables directly when necessary,	**/
	/**  although users should not change these variables except	**/
	/**  in cases outlined in the COB Users Guide and/or release	**/
	/**  notes.							**/
	/*****************************************************************/

  struct GRmd_env         ModuleInfo;   	/* module information	      */
  struct GRevent	  event1;		/* a place to put a GR event  */
  long			  event_mask1;		/* mask for GRevent, locate   */
  int 			  event_size;		/* sizeof GRevent	      */
  enum GRdpmode		  DisplayMode;
  enum GRdpmode		  HilightMode;		/* arg to lc$locate() 	      */
  enum GRdpmode		  UnhilightMode;	/* arg to lc$locate() 	      */
  char			* value_type;		/* pointer to value type str  */
						/*  for event value type in   */
						/*  co$getevent().	      */
  char			* value_type_locate;	/* pointer to value type str  */
						/*  for value type of LOCATE  */
						/*  event for lc$locate() and */
						/*  gr$gslocate().	      */
  char			* value_type_accept;	/* pointer to value type str  */
						/*  for value type of ACCEPT  */
						/*  event for lc$locate() and */
						/*  gr$gslocate().	      */

  char			  DatabaseType[MAX_DB_TYPE_SIZE];
  struct GRdpb_scale	  ActiveScale;		/* active x, y, & z scale     */
  struct IGRdisplay	  ActiveDisplay;	/* active display	      */
  IGRdouble		  ActiveAngle;		/* active angle (in radians)  */
  short			  ActiveLevel;		/* active level		      */

  channel {(rel_ordered, many_to_many,
	   initial=1, increment=1)}		located_graphics;
  OM_S_CHANSELECT	  located_chansel;	/* located gra chan select    */
  char			  acc_prompt [_max_key];/* accept prompt for locate   */
  char			  reloc_prompt[_max_key];/* relocate prompt           */
  struct GRevent	  event2;		/* another GR event	      */
  long			  event_mask2;		/* another mask		      */
  int			  nbytes2;		/* # bytes returned by locate */
  struct GRlc_locate	  attributes;		/* locate attributes	      */
  struct GRlc_stack	  stack;		/* locate data stack	      */
  OM_S_CLASSLIST	* locate_eligible;	/* ptr to "eligible_classes"  */
						/*   arg for lc$locate();     */
						/*   defaults to NULL	      */
  OM_S_CLASSLIST	* locate_rtree;		/* ptr to "rtree_classes" arg */
						/*   for lc$locate();	      */
						/*   defaults to NULL	      */
  variable OMuword	  rtree_classids[0];	/* goes inside structure below*/
  variable OMuword	  eligible_classids[0]; /* goes inside structure below*/
  OM_S_CLASSLIST	  locate_rtree_thing;	/* actual CLASSLIST thing     */
  OM_S_CLASSLIST	  locate_eligible_thing;/* actual CLASSLIST thing     */
  long			  display_flag;		/* one or all views etc.      */
  struct GRlc_dynamics  * dyn;		        /* default is NULL	      */
  int			  type;			/* default 0 => boreline or   */
						/*   point depending on DPB   */
					        /*   1 => boreline locate     */
					        /*   2 => point locate        */
  char			  (*action_handler)();  /* ptr to user-supplied func  */
						/*   to check objs to be      */
						/*   placed on locate stack;  */
						/*   defaults to NULL	      */
  char			* action_args;		/* args for above function    */
  struct GRevent	  event3;		/* another GR event for	      */
						/*   gs$gslocate 	      */
  int			  regex;		/* flag for reg expression    */
						/*   evaluation in lc$locate  */
  int			  stack_size;		/* # of objs to be put on     */
						/*   locate stack; default = 1*/
  char			  (*select)();		/* ptr to user-supplied func  */
						/*   to handle accept/reject  */
						/*   cycle; defaults to NULL  */
  char			* select_args;		/* args for above function    */
  int			  (*range_handler)();	/* ptr to user-supplied func  */
						/*   to handle range checking */
						/*   in lc$locate(); defaults */
						/*   to NULL		      */
  char			* range_args;		/* args for above function    */
 
  int			  scale_flag;		/* scale flag argument for    */
						/*   co$getevent, lc$locate,  */
						/*   and gr$gslocate filters  */

  struct GRmd_env         locate_ModuleInfo;   	/* module information saved   */
						/*   during lc$locate()	      */
};


	/*****************************************************************/
	/**			"PRIVATE" messages			**/
	/**  These messages are for INTERNAL COB USE ONLY, and		**/
	/**  should *NOT* BE SENT or OVERRIDDEN by COB users.		**/
	/*****************************************************************/

override predicate;


	/*****************************************************************/
	/**		     "SEMI-PRIVATE" messages			**/
	/**  These messages are used internally by COB, but they may 	**/
	/**  be sent and/or overridden by COB users as directed in the  **/
	/**  COB Users Guide and release notes.  In general, if any of	**/
	/**  these methods are overridden by the COB user, then the	**/
	/**  user's method should include a send with respect to	**/
	/**  message of the CEO method that was overridden.		**/
	/*****************************************************************/

override init;

override wakeup;

override execute; /* int * response; char * response_data; int position; */

override sleep;

override delete;

override action; /* int	action_selector; int int_or_str_ptr; int * sts; */

override filter; /* int filter; int * response; char * response_data; */

message display_located ( 
                /* display the objects on the located channel */
                /* things are added to this channel when the filter == locate */
  long		* sts );	/* returned status code */
				/* whatever from GRgraphics.GRdisplay */

message disconnect_constructed ( /* clear constructed_graphics channel */
  long		* sts );

message display_constructed ( /* display constructed_graphics channel objects */
  long     * sts );	/* returned status code */
			/* whatever from GRgraphics.GRdisplay */

override arg_name_to_value;  /* translate a string from the state table into */
			    /*   its variable name value */
	/* Incoming */
  /* int	  addr_mode;	/* == _COB_regular   for regular data */
				/* == _COB_indirect  for  "*<arg>"    */
				/* == _COB_indirect2 for "**<arg>"    */
				/* == _COB_address   for  "&<arg>"    */
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

/* A VERSION 2.4 ENHANCEMENT FOR SMART SKETCH FUNCTIONALITY - SRH 07/16/93 */
/*

Name
  SSenter

Abstract
  Enters (initializes but does not activate) the Smart Sketch environment

Synopsis
  message SSenter() :  no arguments

Description
  Should be called from the wakeup method of commands that support Smart
  Sketch.

Notes

Index

Keywords
  smart-sketch,command

History
  07/17/93 : Shelley R. Heard : Transfered from COnpt class to CEO_LOCATE.

 */
message SSenter();


/*

Name
  SSactivate 

Abstract
  Activates the Smart Sketch environment (turns it on).

Synopsis
  message SSactivate()

Description
  Should be called from the execute method of commands before filter or
  dynamics calls in states where Smart Sketch needs to be turned on.

Notes
  Has no effect on interface if global DPB Smart Sketch Lock is OFF.
  The Smart Sketch environment must bi initialized before this call occurs
  (see SSenter, above).

Index

Keywords
  smart-sketch,command

History
  07/17/93 : Shelley R. Heard : Transfered from COnpt class to CEO_LOCATE.

 */
message SSactivate ();


/*

Name
  SSdeactivate

Abstract
  Deactivate (turns Smart Sketch OFF) but does not exit the Smart Sketch
  environment.

Synopsis
  message SSdeactivate()

Description
  Should be called from the execute method of command objects that support
  Smart Sketch in states where Smart Sketch needs to be turned OFF temporarily.
  A common example of when this would be used is in a command state where
  not data point is entered (e.g. "Enter number of sides").

Notes

Index

Keywords
  smart-sketch,command

History
  07/17/93 : Shelley R. Heard : Transfered from COnpt class to CEO_LOCATE.

 */
message SSdeactivate ();


/*

Name
  SSexit

Abstract
  Exits (and deactivate!) the Smart Sketch environment.

Synopsis
  message SSexit()

Description
  Should be called from the sleep method of commands that support Smart
  Sketch.

Notes
  SSdeactive need not be called before calling this routine.

Index

Keywords
  smart-sketch,command

History
  07/17/93 : Shelley R. Heard : Transfered from COnpt class to CEO_LOCATE.

 */
message SSexit();


/*

Name
  SSOptions(int *sts );

Abstract
  Creates and displays the Smart Sketch Options Form.

Synopsis
  message SSOptions ( int *sts );

  sts  returns   MSSUCC - successful
                 MSFAIL - could not create the form

Description
  Should be called if the Smart Sketch Options form need to be accessed.

Notes
  This is a Save/Restore form.

Index

Keywords
  smart-sketch,command

History
  07/17/93 : Shelley R. Heard : Transfered from COnpt class to CEO_LOCATE.

 */
message SSOptions(int *sts );

/*

Name
  SSSetNewElement

Abstract
  Tells Smart Sketch that a new element is being created and gives it enough
  information (data points) to graphically aid in the construction.

Synopsis
  message SSSetNewElement (int *sts; int ele_type ; int index )
    sts      MSSUCC = success; MSFAIL = failure
    ele_type (see SMdef.h)
    index    for LINE Mode only - index of event containing start point of line

Description
  (Abstract says it all)

Notes
  Rejected because the mechanism for defining the points (gathered by a filter)
  may vary from command class to command class.

Index

Keywords
  smart-sketch,command

History
  07/17/93 : Shelley R. Heard : Transfered from COnpt class to CEO_LOCATE.
  11/30/93 : Shelley R. Heard : Added index arg 

 */
message SSSetNewElement (int *sts; int ele_type; int index );


/*

Name
  SSSmartSketchLock

Abstract
  Queries/Sets/Toggles the Smart Sketch Lock.  

Synopsis
  message SSSmartSketchLock ( int *sts; int flag )
    sts   OUT return code that can be switched on in COB state tables
                OM_E_ABORT  - if method did not do the requested task
                if flag was set to 3 (query) then *sts will retutn as:
                  0 if lock is currently set OFF
                  1 if lock is currently set ON
                NOTE! be careful when checking the value of *sts in
                query mode.  A 0 does not mean failure!

    flag  IN  0 - sets the lock to OFF
              1 - sets the lock to ON
              2 - toggles the lock
              3 - query lock value (result returned in *sts)

Description
  ( see  Abstract/Synopsis )

Notes

Index

Keywords
  smart-sketch,command

History
  07/17/93 : Shelley R. Heard : Transfered from COnpt class to CEO_LOCATE.

 */
message SSSmartSketchLock (int *sts; int flag );


/* to be overriden by commands */
reject SSSetNewElement;

/*
Name
        status_display_button

Description
        This method highlights/dims the status display button on the bar
        menu.

History
        mrm     09/02/93        moved from COnpt
*/

message status_display_button(int on);

end specification CEO_LOCATE;
