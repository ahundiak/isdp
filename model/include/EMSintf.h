/*
This file contains the options and structures used for the interference
analysis.
*/

#define EMSintf_NoReport	0x0001	/* No written report desired. */
#define EMSintf_ReportBoth	0x0002  /* Report to file & stdout */
#define EMSintf_NoCurves	0x0004  /* output of intersection curves
					   not desired.
					*/
#define EMSintf_NoStatMsg	0x0010  
#define EMSintf_NoVolElems	0x0020  /* Intf volume elements should not
					   be added to the database.
					*/
#define EMSintf_Display		0x0040  /* Display curves/volumes as they
					   are computed.
					*/
#define EMSintf_NoAreaElems	0x0080

#define EMSintf_InputXsec	0x0100	/* Valid only for intf along xsec.
					   Indicates that the input elements
					   are cross sections instead of
					   original solids.
					   The method will thus not compute
					   cross sections again.
					   Input cross section remain
					   unchanged.
					*/
#define EMSintf_NoCrossHatch	0x0200	/* For interference areas output, do
					   not do cross hatching.
					*/

/* Following structure conveys the qualitative intf info for every interfering
   element from the check set. There will be one of these for every element
   from the check set with which an element from the primary set has some
   interference.
*/
struct EMSintf_qualitative
{
 struct GRlc_info against_eleminfo;	  /* interfering elem id */
 struct GRid volelem;		  /* intf volume element id. If not asked
				     for, will be NULL_OBJID.
				  */
 struct GRid inters;		  /* intersection curves as graphic group.
				     If not asked for, will be NULL_OBJID.
				  */
};


/* Following structure conveys the quantitative intf info along a cross section
   for every interfering element from the check set. There will be one of these
   for every element in the check set against which an element from the 
   primary set is being checked.
*/

#define	NumIntfCases	4
#define NumAreas	3

#define Intf		0
#define NestedCl	1
#define DisjointCl	2
#define NestedIntf	3

enum EMSintfType
{
 EMintf, 
 EMnested_cl, 
 EMdisjoint_cl,
 EMnested_intf, 
 EMunknown
};


struct EMSintf_xsec
{
 struct GRlc_info against_eleminfo;
 struct GRid areas[NumAreas], *linesegs[NumIntfCases][2];
 IGRdouble dist[NumIntfCases][2];
 IGRint NumOcc[NumIntfCases][2];
};



union EMSintfInfo
{
 struct EMSintf_qualitative *qualitative;
 struct EMSintf_xsec *xsec;
};

/* Following indicates what kind of analysis has been done.
*/
enum EMSintfInfoType
{
 EMqualitative, 
 EMxsection
};

/* Following conveys the interference information.
*/
struct EMSintf
{
 struct GRlc_info eleminfo;		  /* elements having interference*/
 IGRint numintf;		  /* if qualitative indicates number of
				     interfering elements.
				     if along CS is same as number of
				     elements in the check set.
				  */
 enum EMSintfInfoType intfInfoType;  /* interference type qualitative, 
						       along xsection.
				  */
 union EMSintfInfo info;	  /* interfernce information.
				  */
};


struct EMSintf_failure
{
 enum EMSintfInfoType type;  
 struct GRid ele1, ele2;
 IGRlong msgcode;
};







