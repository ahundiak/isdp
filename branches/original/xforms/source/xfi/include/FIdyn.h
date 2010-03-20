/*****************************************************************/
/* FIdyn.h -						 	 */
/*	This is an X/Forms ( XFORMSDP SN01252 ) header file.	 */
/*****************************************************************/
/* Copyright 1992 Intergraph Corporation			 */
/* All Rights Reserved, Including this Release Note, the Product */
/* it Describes, its File Formats, and Visual Displays		 */
/*****************************************************************/

/**********************************************************************/
/* FIdyn.h - This header file contains a structure used for the       */
/* dynamic creation of gadgets in the X/Forms system.  This structure */
/* is used with the function FIg_set_standard_variables().  This will */
/* set up the standard variables for dynamic creation of the gadget.  */
/* Some gadgets will require additional setup.  See the Document for  */
/* explanation of what gadgets need extra setup.                      */
/**********************************************************************/


#ifndef FI_DYN_INCLUDED
#define FI_DYN_INCLUDED	1


struct standard_st
{
  /* Coordinates of the gadget relative to the form's window */

  unsigned short xlo;		/* upper left  x-position of gadget */
  unsigned short ylo;		/* upper left  y-position of gadget */
  unsigned short xhi;		/* lower right x-position of gadget */
  unsigned short yhi;		/* lower right y-position of gadget */

   /* Bit masks settings are defined in "FI.h" under characteristics */

  long      attr_mask;		/* Sets the attr_mask and	*/
				/*   the default_attr_mask	*/

  double    value;		/* Sets the value/state and the */
				/*   default value/state	*/

  float     bodysize;		/* bodysize of the font   */

  char     * text;		/* text string to be displayed  */

  char     * help_topic;	/* Help topic to set    */

  char     * command;		/* Command to put on queue  */


  char     * fontname;		/* name of font used; ex. "swiss742" */
				/* or name of symbol file if not a   */
				/* FI_TEXT_GADGET                    */

  char    * user_pointer;	/* pointer that can be used by       */
				/* the programmer         	     */


      /* colors are defined in "FI.h" */

  unsigned char    off_color;	/* off color      */
  unsigned char   on_color;	/* on color      */

  unsigned char   off_color2;	/* off color two FUTURE USE  */
  unsigned char   on_color2;	/* on color two FUTURE USE  */


  unsigned char    symbol_index; /* OFF symbol for a FI_TOGGLE gadget */
			         /* TOP symbol for a FI_BUTTON gadget */

  unsigned char    symbol_index2; /* ON symbol for a FI_TOGGLE gadget */
			          /* BOTTOM symbol for a FI_BUTTON    */
			          /* gadget.            	      */
			          /* NOTE: a value of 0 ==> no symbol */

  int  next_in_seq;		  /* Gadget label to which this       */
			          /* gadget is sequenced.             */
};

#endif
