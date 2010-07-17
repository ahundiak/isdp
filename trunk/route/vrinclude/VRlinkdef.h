/*
        File    VRlinkdef.h
        Date    01-Oct-1993
        Auteur  AdZ (ISDC Hsv)

        Desciption :	

*/
#ifndef VRlinkdef_include

#define VRlinkdef_include

/*
 * expressions names
 */
#define VRLINK_SUPPORT		"support"
#define VRLINK_COLLECT		"attr"

#define	VRLINK_LINK		"link"
#define	VRLINK_VIRT_PARENT	"link1"
#define	VRLINK_LINE		"line"

#define	VRLINK_DEF		"VRlinkpar"

/*
 * template/feet names limitation
 */
#define VRLINK_TEMPMAX	20
#define VRLINK_FEETMAX	50

#define	VRLINK_TEMPCHAR	10
#define	VRLINK_FEETCHAR	10

/*
 * command object types
 */
#define	VRLINK_PLACE	0
#define	VRLINK_MODIFY	1
#define	VRLINK_DELETE	2

/*
 * allocation values.
 */
#define	VRLINK_POINTS	90
#define	VRLINK_INCR	30

/*
 * gad distance
 */
#define VRLINK_GAP	4.0 

/*
 * attributes flags
 */
#define	VRLINK_NONFLAG	0x0
#define	VRLINK_FLAG	0x1

/*
 * attributes types
 */
#define	VRLINK_NONTYPE	0
#define	VRLINK_TYPE1	1

struct	VRlinkln
{
	IGRdouble	bpnt[3];
	IGRdouble	epnt[3];
	IGRdouble	bval;		
	IGRdouble	eval;
};

#endif
