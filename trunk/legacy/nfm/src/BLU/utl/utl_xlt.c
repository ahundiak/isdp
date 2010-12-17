/******************************************************************************

Doc:	utl_xlate_points

	Copyright (c) 1992, 1993
	Intergraph Corporation; All Rights Reserved
	Including Application Programs, File Formats, and Visual Displays

Source:	utl_xlate.c

Author:	Jeff Silvaggi

Date:	09-APR-1992

SDM Number:

Description:	This function converts the input points to actual points
	based on the orientation of the file and the current rotation
	angle.

Examples:
	status = utl_xlate_points( angle, p1, p2, xsize, ysize, orient, direction )

Return Status:
	 0 = Successful completion
	-1 = Error

History:
******************************************************************************/
#include "point.h"

utl_xlate_points( angle, p1, p2, xsize, ysize, orient, direction )
int angle;				/* I - Display angle */
PTS *p1, *p2;				/* I/O - Pointer to points */
int xsize;				/* I - Width of image in pixels */
int ysize;				/* I - Height of image in scanlines */
int orient;				/* I - Orientation:  0=row major  1=column major */
int direction;				/* I - Direction: 0=rotation to file  1=file to rotation */
{
int x1, y1, x2, y2;
int x;

/* Get current display rotation angle */
angle /= 90;

/* Set points in case 0 degrees */
x1 = p1->x;
y1 = p1->y;
x2 = p2->x;
y2 = p2->y;

/* Adjust for lower-left-vertical files */
if( orient )
    if( ++angle > 3 ) angle = 0;

if( direction && ( angle == 1 || angle == 3 ) )
{
  x = xsize;
  xsize = ysize;
  ysize = x;

  if( angle == 1 )
    angle = 3;
  else if( angle == 3 )
    angle = 1;
}

/* Adjust points */
switch( angle )
{
  /* 90 degree */
  case 1:
    x1 = xsize - p1->y - 1;
    y1 = p1->x;
    x2 = xsize - p2->y - 1;
    y2 = p2->x;
    break;

  /* 180 degree */
  case 2:
    x1 = xsize - p1->x - 1;
    y1 = ysize - p1->y - 1;
    x2 = xsize - p2->x - 1;
    y2 = ysize - p2->y - 1;
    break;

  /* 270 degree */
  case 3:
    x1 = p1->y;
    y1 = ysize - p1->x - 1;
    x2 = p2->y;
    y2 = ysize - p2->x - 1;
    break;
}

/* Ensure points are correct */
if( x1 > x2 )
{
  x = x1;
  x1 = x2;
  x2 = x;
}
if( y1 > y2 )
{
  x = y1;
  y1 = y2;
  y2 = x;
}

/* Reset users points and return */
p1->x = x1;
p1->y = y1;
p2->x = x2;
p2->y = y2;

return(0);
} /* end of utl_xlate_points() */
