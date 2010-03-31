/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method outputs the command string in the command field
 for the following simple construction commands:

                 Command                      my_type
        ----------------------------------    -------
	Place solid box by two points		1
	Place box by four points		2
	Place solid box by four points		3
	Place cone by axis and radii		4
  	Place solid right trunc. cone		5
	Place cylinder by axis and radius	6
	Place solid right circ. cylinder	7
	Place torus				8
	Place solid torus			9
	Place solid right elliptical cylinder	10
	Place solid trunc. elliptical cone	11
	Place ellipsoid - foci axis len.	12
	Place ellipsoid - ctr. axis rad.	13
	Place solid 4 face 4 vert. polyhedron	14
	Place solid 5 face 5 vert. polyhedron	15
	Place solid 5 face 6 vert. polyhedron	16
	Place solid 6 face 7 vert. polyhedron	17
	Place solid 6 face 8 vert. polyhedron	18
	Place rectangular plane by 3 points	19
	Place parallelogram plane by 3 points	20
	Place solid right angle wedge		21
	Rho conic				22
	Conic by 3 points and 2 tangents	23
	Conic by 4 points and 1 tangent		24
	Conic by 5 points			25
	Place sphere by center and radius	26
	Place solid globe			27
	Place solid ellipsoid - foci axis len.	28
	Place solid ellipsoid - ctr. axis rad.	29
	Place right elliptical cylinder		30
	Place trunc. elliptical cone		31
	Place part of curve			32
	Place parabola tangent to 2 curves	33
	Place blend between 2 curves		34
	Place plane encompassing planar element	35
	Place helix				36
	Place partial surface			37
	Place surface of revolution		38
	Place solid of revolution		39
        Project curve onto surface along norm   40
        Project point along vector onto surf    41
        Project curve along vector onto surf    42
	Place surface by 3 boundaries		43
	Place surface by 4 boundaries		44

	Place offset surface			45
        code for Place offset surface is moved to
        src_testco/imp ECcsoffseti.I

        Blend 2 surfaces - interior		46
	Blend 2 surfaces - exterior		47
	Place fillet surface			48
	Place plane tangent to surface		49
	Place plane tangent to curve		50
						51
        Extract iso curves			52
	Place curve by poles - points		53
	Place curve by poles - linestring	54
	Place convex fit curve			55
	Place direct fit curve			56
	Place least squares fit curve		57
	Place surface by poles			58
	Place direct fit surface - linestrings	59
	Place least squares fit surface		60
	Place direct fit surface - curves	61
	Place surface through a network		62
						--
	Change curve order			71
	Change surface order			72
	Increase curve order			73
	Increase surface order			74
	Change rule line display		75
	Place solid by capping surface		76
	Toggle polygon on/off			77
	Insert pole without changing shape	78
	Insert knot				79
	Extend surface - linear			80
	Extend surface - circular		81
	Extend surface - polynomial		82
	Place surface of projection		83
	Place solid of projection		84
	Intersect elements			85
	Delete surface boundaries		86
	Align 2 curves				87
	Align 2 surfaces			88
	Bezier curves from a bspline curve	89
	Bezier surfaces from a bspline surface	90
	Insert knotline				91
	Place ruled surface			92
	Place conic by linestring		93
	Place plane normal to curve		94
						--
	Place blending surface			105
	Modify curve shape			106
	Reduce curve data			107
	Modify surface shape			108
	Place solid by offsetting surface	109
	Change curve direction			110
	Cross hatch				111
        Create wireframe model			112
        Place parting lines as curves		113
        Reduce surface data			114
        Place fillet surface with auto trim	115
	Place fitted curve			116
	Place fitted surface			117
	Place parting lines as features		201
	Display Isophotes                       202
	Place angular parting surface		203
	
 History

 10/27/87 : rlw : The beginning
 12/14/87 : rlw : Added some more commands
 12/30/87 : rlw : Added some more commands
 01/04/88 : rlw : Added some more commands
 01/05/88 : rlw : Added some more commands
 02/16/88 : rlw : Added place ruled surface command
 03/22/88 : rlw : Added place conic by linestring command and
                  place plane normal to curve command.
 06/29/88 : rlw : Added place blending surface command
 07/04/88 : rlw : Added modify curve shape command
                  Added place reduced fit curve command
 07/12/88 : rlw : Added modify surface shape command
                  Added Place solid by offsetting surface command
 07/20/88 : rlw : Added Change curve direction command
 07/28/88 : rlw : Added Cross hatch command
 08/01/88 : rlw : Added Create wireframe model command, note that this
                  was originally witten by Sunit on 01/21/88.
                  Added Place parting lines command.
 08/05/88 : rlw : Added surface data reduction
 09/02/88 : rlw : Added fillet with auto trim
                  Added curve fitting via data reduction
 02/28/89 : rlw : Modified to add conditional compilation statements
                  for the I/DRAW product.
 08/01/89 : pp  : Added a command to place angular parting lines.
 21-Sep-89: SM  : Added Place angular parting surface.
 02-Aug-90:ashok: Added/Modified conditional compilation statements to
		  include commands "conic by ......" (23, 24 and 25) in the
		  MDS(I/DRAW) product.
 Sep 5,90:Inasu : Added/modified conditional compilation statements  to
                  include command 33.
 03/19/93:sam   : code for place offset surface (case 45)is moved to
                  src_testco/imp/ECcsoffseti.I. --sampath
 */

class implementation ECconstruct;


%safe
#include <math.h>
%endsafe

#include "EMS.h"		/* Shared library stuff */
#include "ems_m_inc.h"		/* Includes everything */
#include "EC_M.h"		/* Message keys for command strings */

method output_command_string()

{
 IGRlong	key;
/*
 * Initialize
 */
 me->msg = MSSUCC;
/*
 * This function is basically one gaint switch statement
 */
 switch (me->mytype)
  {
#ifndef IDRAW
   case  1:
    key = EM_M_0001;
    break;
   case  2:
    key = EM_M_0002;
    break;
   case  3:
    key = EM_M_0003;
    break;
   case  4:
    key = EM_M_0004;
    break;
   case  5:
    key = EM_M_0005;
    break;
   case  6:
    key = EM_M_0006;
    break;
   case  7:
    key = EM_M_0007;
    break;
   case  8:
    key = EM_M_0008;
    break;
   case  9:
    key = EM_M_0009;
    break;
   case 10:
    key = EM_M_0010;
    break;
   case 11:
    key = EM_M_0011;
    break;
   case 12:
    key = EM_M_0012;
    break;
   case 13:
    key = EM_M_0013;
    break;
   case 14:
    key = EM_M_0014;
    break;
   case 15:
    key = EM_M_0015;
    break;
   case 16:
    key = EM_M_0016;
    break;
   case 17:
    key = EM_M_0017;
    break;
   case 18:
    key = EM_M_0018;
    break;
   case 19:
    key = EM_M_0019;
    break;
   case 20:
    key = EM_M_0020;
    break;
   case 21:
    key = EM_M_0021;
    break;
#endif
   case 22:
    key = EM_M_0022;
    break;
/* #ifndef IDRAW 02/aug/90 commented */
   case 23:
    key = EM_M_0023;
    break;
   case 24:
    key = EM_M_0024;
    break;
   case 25:
    key = EM_M_0025;
    break;
#ifndef IDRAW /* moved this line from above */
   case 26:
    key = EM_M_0026;
    break;
   case 27:
    key = EM_M_0027;
    break;
   case 28:
    key = EM_M_0028;
    break;
   case 29:
    key = EM_M_0029;
    break;
   case 30:
    key = EM_M_0030;
    break;
   case 31:
    key = EM_M_0031;
    break;
   case 32:
    key = EM_M_0032;
    break;
#endif /* endif to include the following message in MDS -Inasu*/
   case 33:
    key = EM_M_0033;
    break;
#ifndef IDRAW /* added this to include the above in MDS */
   case 34:
    key = EM_M_0034;
    break;
   case 35:
    key = EM_M_0035;
    break;
   case 36:
    key = EM_M_0036;
    break;
   case 37:
    key = EM_M_0037;
    break;
   case 38:
    key = EM_M_0038;
    break;
   case 39:
    key = EM_M_0039;
    break;
   case 40:
    key = EM_M_0040;
    break;
   case 41:
    key = EM_M_0041;
    break;
   case 42:
    key = EM_M_0042;
    break;
   case 43:
    key = EM_M_0043;
    break;
   case 44:
    key = EM_M_0044;
    break;
   case 45:        /* code is moved to src_testco/imp/ECcsoffseti.I 
			    for case 45.*/
    key = EM_M_0045;
    break;
   case 46:
    key = EM_M_0046;
    break;
   case 47:
    key = EM_M_0047;
    break;
   case 48:
    key = EM_M_0048;
    break;
   case 49:
    key = EM_M_0049;
    break;
   case 50:
    key = EM_M_0050;
    break;
   case 52:
    key = EM_M_0052;
    break;
   case 53:
    key = EM_M_0053;
    break;
   case 54:
    key = EM_M_0054;
    break;
   case 55:
    key = EM_M_0055;
    break;
   case 56:
    key = EM_M_0056;
    break;
   case 57:
    key = EM_M_0057;
    break;
   case 58:
    key = EM_M_0058;
    break;
   case 59:
    key = EM_M_0059;
    break;
   case 60:
    key = EM_M_0060;
    break;
   case 61:
    key = EM_M_0061;
    break;
   case 62:
    key = EM_M_0062;
    break;
/*
   case 71:
    key = EM_M_0071;
    break;
   case 72:
    key = EM_M_0072;
    break;
*/
   case 73:
    key = EM_M_0073;
    break;
   case 74:
    key = EM_M_0074;
    break;
   case 75:
    key = EM_M_0075;
    break;
   case 76:
    key = EM_M_0076;
    break;
   case 77:
    key = EM_M_0077;
    break;
   case 78:
    key = EM_M_0078;
    break;
   case 79:
    key = EM_M_0079;
    break;
   case 80:
    key = EM_M_0080;
    break;
   case 81:
    key = EM_M_0081;
    break;
   case 82:
    key = EM_M_0082;
    break;
   case 83:
    key = EM_M_0083;
    break;
   case 84:
    key = EM_M_0084;
    break;
#endif
   case 85:
    key = EM_M_0085;
    break;
#ifndef IDRAW
   case 86:
    key = EM_M_0086;
    break;
#endif
   case 87:
    key = EM_M_0087;
    break;
#ifndef IDRAW
   case 88:
    key = EM_M_0088;
    break;
   case 89:
    key = EM_M_0089;
    break;
   case 90:
    key = EM_M_0090;
    break;
   case 91:
    key = EM_M_0091;
    break;
   case 92:
    key = EM_M_0092;
    break;
#endif
   case 93:
    key = EM_M_0093;
    break;
#ifndef IDRAW
   case 94:
    key = EM_M_0094;
    break;
   case 105:
    key = EM_M_0105;
    break;
#endif
   case 106:
    key = EM_M_0106;
    break;
#ifndef IDRAW
   case 107:
    key = EM_M_0107;
    break;
   case 108:
    key = EM_M_0108;
    break;
   case 109:
    key = EM_M_0109;
    break;
   case 110:
    key = EM_M_0110;
    break;
   case 111:
    key = EM_M_0111;
    break;
   case 112:
    key = EM_M_0112;
    break;
   case 113:
   case 201:
    key = EM_M_0113;
    break;
   case 114:
    key = EM_M_0114;
    break;
   case 115:
    key = EM_M_0115;
    break;
#endif
   case 116:
    key = EM_M_0116;
    break;
#ifndef IDRAW
   case 117:
    key = EM_M_0117;
    break;
   case 202:
    key = EM_M_0202;
    break;
   case 203:
    key = EM_M_PlAngPrtSf;
    break;
#endif
   default:
    me->msg = MSFAIL;
    goto wrapup;
  } /* switch (me->mytype) */
/*
 * Output the command string
 */
 ex$message(msgnumb = key)
/*
 * eof
 */
wrapup:
 if (1 & me->msg)
  return(OM_S_SUCCESS);
 else
  return(OM_E_ABORT);
}

end implementation ECconstruct;
