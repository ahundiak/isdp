#ifndef FIline_included
#define FIline_included		1

#include "FIgadget.h"
#include "FIgraphic.h"

/******************************************************************/
/***  The FIline_instance was intended to have multi-segment    ***/
/***  line strings inside each line gadget.  However, this      ***/
/***  functionality will never come to pass in X/Forms, so      ***/
/***  I'm commenting it out.            -- JAJ:06/12/91         ***/
/***                                                            ***/
/***  NOTE:  The FIline.num_vertices is still in the binary     ***/
/***  form file, so it will still just be read in, but then     ***/
/***  just discarded.                                           ***/
/***                                                            ***/
/******************************************************************/

/**********************
struct FIline_instance
{
  char  num_vertices;
  struct
    {
	short x,y;
    } *vertices;
};
**********************/


struct FIline_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIgraphic_instance	FIgraphic;
  /*** struct FIline_instance	FIline; ***/
};

#endif
