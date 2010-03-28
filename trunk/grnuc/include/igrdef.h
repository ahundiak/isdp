




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

#ifndef igrdef_include
#define igrdef_include

#ifndef TRUE
#define TRUE	1
#endif

#ifndef FALSE
#define FALSE   0
#endif

#ifndef NULL
#define NULL	0
#endif

/*
 *
 *  Generic math geometry type identifiers.
 *
 */
				/*       Name		Data Structure	*/
				/* ------------------	--------------	*/
#define IGRPT 0			/* point  		IGRpoint	*/
#define IGRLN 1			/* line			IGRline		*/
#define IGRLS 2			/* line segment		IGRline_seg	*/
#define IGRPY 3			/* polyline		IGRpolyline	*/
#define IGRAR 4			/* arc			IGRarc		*/
#define IGREL 5			/* ellipse		IGRellipse	*/
#define IGRCN 6			/* open cone		IGRcone		*/
#define IGRSC 7			/* solid cone		IGRcone		*/
#define IGRPS 8			/* point string		IGRptstring	*/
#define IGRBC 9			/* B-spline curve	IGRbsp_curve	*/
#define IGRBS 10		/* B-spline surface	IGRbsp_surface	*/
#define IGRLB 11		/* local bounded system	IGRlbsys	*/
#define IGRRP 12		/* right prism		IGRrt_prism	*/
#define IGRPG 13		/* polygon		IGRpolygon	*/
#define IGRCS 14		/* cubic spline curve	IGRcurve	*/
#define IGRPL 15		/* plane		IGRplane	*/
#define IGREA 16		/* elliptical arc	IGRarc		*/
#define IGRCA 17		/* circular arc		IGRarc		*/
#define IGRCR 18		/* circle		IGRellipse	*/
#define IGRQS 19		/* quick B-spline surf	IGRbsp_surface	*/
#define IGRCP 20		/* curve prism		IGRcv_prism	*/
#define IGRRG 21		/* raster graphics	IGRraster	*/
#define IGRFE 22
#define IGRFM 23
#endif
