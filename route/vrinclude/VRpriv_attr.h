/*************************************************************************


Author	: momo

Creation: Feb. 5, 1991

Change History

	 Date	    |   name  | modification's description
        ------------+---------+------------------------------------------

*************************************************************************/


#ifndef VRpriv_attrib_include

#define VRpriv_attrib_include

#define	VR_INIT_SECTION		0
#define	VR_UPDATE_SECTION	1
#define	VR_SWITCH_SECTION	2

#define	VR_NO_TOPO		0
#define	VR_PLANES_NO_TOPO	2
#define	VR_NO_TOPO_PLANES	4
#define	VR_PLANES_PLANES	5

#define	VR_NO_FTF		0
#define	VR_FTF			1

struct VRhvac_param
{
   IGRshort 	shape;
   IGRdouble	G_width;
   IGRdouble	G_depth;
   IGRdouble	R_width;
   IGRdouble	R_depth;
   IGRboolean	bTwist;
};

struct VRpiping_param
{
   IGRdouble	G_diameter;
   IGRdouble	R_diameter;
};

union VRparam_attr
{
  struct VRhvac_param 	hvac_attr;
  struct VRpiping_param	piping_attr;
};

#endif

