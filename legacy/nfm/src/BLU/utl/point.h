/****************************************************************
Copyright (c) 1990 and 1991
Intergraph Corporation; All Rights Reserved
Including Application Programs, File Formats, and Visual Displays

File:		point.h

Purpose: 	This header file defines the data type PTS
	which is used to select image pixel locations.

Author:	Jeff Silvaggi

Date:	01-03-89

Change History:
**********************************************************************/
#ifndef _POINT_H
#define _POINT_H

typedef struct PTS {
  int x;
  int y;
} PTS, POINT;

#endif
