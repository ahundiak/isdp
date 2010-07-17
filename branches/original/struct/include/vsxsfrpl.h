/*
	I/STRUCT

	Dependency: vssectiondef.h
*/
#ifndef vsxsfrpl_include
#	define vsxsfrpl_include

struct VS_s_2dPoint {
	double	x, y ;
} ;

typedef struct VS_s_2dPoint VS2dPoint ;


/*
 *		<-------- length ------->
 *		+-----------------------+ ^		^ y-axis
 *		|			| | thickness   |
 *		+-----------------------+ v		---> x-axis
 *		^ botLeftCorner
 * type = VS_K_HORIZONTAL or VS_K_VERTICAL
 */
struct VS_s_xsPlateDef {
	double		thickness,
			length ;
	int		type ;
} ;
typedef struct VS_s_xsPlateDef VSxsPlateDef ;

/*
 * "Connection" between two plates (ie. touching sides).
 * plate1 : index of 1st plate (horizontal or vertical)
 * plate2 : index of 2nd plate (vertical or horizontal)
 * side1  : side of 1st plate which touches 2nd plate
 * side2  : side of 2nd plate which touches 1st plate
 * offset : offset of plate2 from plate1
 *          from x-axis if plate1 is horizontal
 *	    from y-axis if plate1 is vertical
 *
 *		+-plate1----------------+ 
 *		|			|
 *		+----------+---+--------+
 *		<- offset->|   |		Here : side1 = VS_K_BOTTOM
 *			   |   |plate2		       side2 = VS_K_TOP
 *			   |   |		We now VS_K_BOTTOM means the
 *			   |   |		bottom "length" side since
 *			   |   |		plate1 is horizontal, and that
 *			   +---+		VS_K_TOP means the top
 * 						"thickness" side since plate2
 *						is vertical.
 */
struct VS_s_xsPlConn {
	double		offset ;
	unsigned char	plate1,
			plate2,
			side1,
			side2 ;
} ;
typedef struct VS_s_xsPlConn VSxsPlConn ;

struct VS_s_log2dPnt {
	unsigned char	plateNo,
			pointNo ;
} ;
typedef struct VS_s_log2dPnt VSlog2dPnt ;

struct VS_s_contourPnt {
	VSlog2dPnt	log ;
	VS2dPoint	coord ;
} ;
typedef struct VS_s_contourPnt VScontourPnt ;

/*
 * Plate information: definition + computed coordinates of corner points
 * where the ralative position between plates has been taken into account.
 */
struct VS_s_xsPlInfo {
	VSxsPlateDef	def ;
	VScontourPnt	corners[VS_K_NBCORNERS] ;
} ;
typedef struct VS_s_xsPlInfo VSxsPlInfo ;

typedef VSlog2dPnt	VSxsPlFrontier[2] ;

struct VS_s_xsPlContour {
	VScontourPnt	points[VS_K_MAXCNTPTS] ;
	VSxsPlFrontier	frontier[VS_K_MAX_XSPLATES][2] ;
	unsigned char	npoints,
			nfrontiers ;
} ;
typedef struct VS_s_xsPlContour VSxsPlContour ;

struct VS_s_xsPlParms {
	double	width,
		height,
		flgThickness,
		webThickness ;
} ;
typedef struct VS_s_xsPlParms VSxsPlParms ;

struct VS_s_xsFrPlsAttr {
	int		plCount ;
	VSxsPlateDef	*plDefs ;
	int		cnxCount;
	VSxsPlConn	*plCnxs ;
	char		*thicknesses[VS_K_MAX_XSPLATES] ;
} ;

struct VS_s_xsPlShpDesc {
	/*
	 * Type of shape (I,L,T,etc.).
	 */
	int	shapeType,
	/*
	 * Name of shape sides ( side # -> code of name ).
	 */
		nmIndices[VS_K_sc_MAXFACES],
	/*
	 * For computing mass properties of plate from beam object:
	 * plate # -> beam face to be used for mass properties.
	 */
		plToBmFace[VS_K_MAX_XSPLATES] ;
} ;
typedef struct VS_s_xsPlShpDesc VSxsPlShpDesc ;

typedef struct VS_s_xsFrPlsAttr VSxsFrPlsAttr ;

struct VS_s_xsPlType {
	char	*material,	/* Of all plates	*/
		*family,	/* Of all plates	*/
		*profileType ;	/* Of profile		*/
} ;

typedef struct VS_s_xsPlType VSxsPlType ;

#endif

