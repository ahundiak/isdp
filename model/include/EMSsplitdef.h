/*
  This file contains the defined constants for extracting a partial
  surface and windowing of the loopset.
*/

# ifndef EMSsplitdef_include
# define EMSsplitdef_include 1

/* Split direction
*/

#define		SPLIT_U		0
#define		SPLIT_V		1
#define		SPLIT_BOTH	2

 
/* If split is across seam
*/

#define		NOT_ACROSS_SEAM		0x0000
#define 	ACROSS_SEAM_U		0x0001
#define		ACROSS_SEAM_V		0x0002
#define		ACROSS_SEAM_BOTH	0x0004

# endif
