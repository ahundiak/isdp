struct header
{
 double	maxX;
 double maxY;
 double minX;
 double minY;
 double	meanSize;
 int	numObjs;
};
typedef	struct header HEAD;
typedef struct header *pHEAD;

struct outObjRecord
{
 double x1;
 double y1;
 double x2;
 double y2;
 int	size;
 int	flag;	/* nonzero means bigish guy 20% or greater range */
 double xc;
 double yc;
};
typedef struct outObjRecord	OutObjRec;
typedef struct outObjRecord	*pOutObjRec;
typedef struct outObjRecord	Pk1Rec;
typedef struct outObjRecord	*pPk1Rec;

struct inObjRecord
{
 double x1;
 double y1;
 double x2;
 double y2;
 int	size;
};
typedef struct inObjRecord	InObjRec;
typedef struct inObjRecord	*pInObjRec;


typedef unsigned int  uint;


struct  pk2Rec
{
  double    x1;
  double    y1;
  double    x2;
  double    y2;
  uint      size;
  uint      clustNum;
};
typedef struct  pk2Rec  Pk2Rec;
typedef struct  pk2Rec  *pPk2Rec;

struct  gridPt
{
  int       count;
  int       totalSize;
  int       visited;
  int       idxSize;
  int       *objIdxs;
  uint      clustNum;
};
typedef struct  gridPt  GridPt;
typedef struct  gridPt  *pGridPt;


