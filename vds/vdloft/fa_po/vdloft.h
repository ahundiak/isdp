#ifndef vdloft_def
#define vdloft_def

#define geomNull	0x00000000	/* null object		  */
#define	geomLine	0x00000001	/* this element is a line */
#define	geomCircle	0x00010004	/* this element is an arc */
#define	geomArc		0x00020004	/* this element is an arc */

struct	geomStruct {
	
  IGRint	type;	/* type of object stored */

  union {

	IGRdouble      	Line[6];	/* array to store start and end point */

	struct 	IGRarc 	Arc;		/* structure to store arc or circle   */

  }uGeom;

};

struct cvGrePa {

        IGRdouble       pa;
        IGRdouble       dist;

        };

struct sfGrePa {

        IGRdouble       u;
        IGRdouble       v;
        IGRdouble       dist;

        };

#endif
