/*
  This file contains the options used by the EMSloop.EMnext_edge method to
  get the edges from a loop based on these options.

History
	SM	02-Dec-87	Creation
*/

# ifndef emsgeteddef_include
# define emsgeteddef_include 1

#define EMGetEd_Next		0x0001		/* Get the edge next to
					   	   reference edge
						*/
					
#define EMGetEd_Previous	0x0002		/* Get the edge previous
						   to ref. edge.
						*/
						
#define EMGetEd_Last		0x0004		/* Get last edge in loop
						*/
						
#define EMGetEd_First		0x0008		/* Get first edge in loop
						*/
						
#define EMGetEd_NonDegenerate	0x0010		/* Get the edge
						   according to one of the
						   above options plus non
						   degenerate. Degenerate
						   edges are of class
						   EMSptedge.
						*/
						
						

# endif
