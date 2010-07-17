
/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/self.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: self.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:30  pinnacle
 * Created: vrrt/self.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _SELF_
#define _SELF_

/*
These macros enable some nifty abuses of the C preprocessor.  They let you
build up a C identifier in textual pieces.  C code becomes easier to change
and more modular.  For numerous examples, grep for self in the Common modules
and programs.

The self macros have their own header file to make them easier to debug.
If you use a self macro in a module and it won't compile, it can be useful
to see how self expands independently of any other macros:

	1. Copy the module to a temporary file.
	2. In the temporary file, remove all #includes, then add

		#include <self.h>

	3. Run the temporary file through /lib/cpp.  Give cpp the
	   appropriate -I flags on the command line to find the directory
	   containing self.h.  Pipe the output to more, or into a file
	   you can edit.
*/

#define self(x1)x1
#define self2(x1,x2)self(x1)x2
#define self3(x1,x2,x3)self2(x1,x2)x3
#define self4(x1,x2,x3,x4)self3(x1,x2,x3)x4

#endif
