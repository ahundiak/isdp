#ifndef vlCstructure_include
#define	vlCstructure_include

/* ************************************************************************** */
/* 	This include file groups all the structures of the I/LOFT product.    */
/*	With the prototyping of the functions, it's useful to do it	      */
/*									      */
/*		Marc FOURNIER (COC shipbuilding)	19-Nov-1993	      */
/* ************************************************************************** */

#include	"igrtypedef.h"
#include	"igrdef.h"
#include	"igr.h"
#include	"bstypes.h"
#include	"bserr.h"

/* ********** Jean-Luc LOSCHUTZ (COC shipbuilding) 20-Oct-1992 ****************/
struct cvGrePa {

        IGRdouble       pa;
        IGRdouble       dist;

        };

struct sfGrePa {

        IGRdouble       u;
        IGRdouble       v;
        IGRdouble       dist;

        };
/* ************************************************************************** */

#endif
