#ifndef HSe2_mesher_include
#define HSe2_mesher_include 1

#include "igrtypedef.h"
#include "hsmath.h"

#define IN		0
#define OUT		1

#define ON_AEL		0x00000010
#define LIVE_EDGE	0x00000020

#define ORIGINAL_EDGE	0x00000000
#define ADDED_EDGE	0x00000001
#define	HORIZONTAL_EDGE	0x00000002

#define LOCAL_MINIMUM	0x00000001
#define LOCAL_MAXIMUM	0x00000002

#define MONO_MADE	0x00000004

#define HANDLED		0
#define CANNOT_HANDLE	4

#define ONE_K		1024

#define WITHIN_TOLERANCE( y1, y2, tol )	\
	( ( FABS( ((y2) - (y1)) ) <= (tol) ) )


struct HStri_point
   {
   float x, y, z;
   };

struct HStri_color
   {
   float red;
   float green;
   float blue;
   };

struct HStri_mesh
   {
   int numVerts;
   int numFacetNormals;
   struct HStri_point *verts;
   struct HStri_color *vColors;
   struct HStri_point *vNorms;
   struct HStri_color *fColors;
   struct HStri_point *fNorms;
   };
 
struct HStri_vertex
{
   double coord[4];
   double norm[3];
   struct HStri_vertex *next;
   unsigned short LocalExtremity;
   struct Edge *In[4], *Out[4];
   short InCardinality, OutCardinality;
};


struct HStri_loop
{
   struct HStri_vertex *loop;
   struct HStri_loop *next;
   int Vertices;
};

struct Edge
{
   struct HStri_vertex *Top, *Bottom;
   double SlopeInverse, x_intercept;
   unsigned short EdgeStatus;
   struct HStri_vertex *Extreme_y;
   struct Edge *Next;
};

struct PolygonVert {
	short Side; /* LEFT_SIDE, RIGHT_SIDE, or NEITHER_SIDE */
	short VertNo;
	struct HStri_vertex *Vertex;
	struct PolygonVert *Next;
};

#endif
