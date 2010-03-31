/* ###################   APOGEE COMPILED   ################## */
/*
 Description

 This method redirects the construction logic
 for the following simple construction commands:

                 Command                      mytype
        ----------------------------------    -------
        Place solid box by two points           1
        Place box by four points                2
        Place solid box by four points          3
        Place cone by axis and radii            4
        Place solid right trunc. cone           5
        Place cylinder by axis and radius       6
        Place solid right circ. cylinder        7
        Place torus                             8
        Place solid torus                       9
        Place solid right elliptical cylinder   10
        Place solid trunc. elliptical cone      11
        Place ellipsoid - foci axis len.        12
        Place ellipsoid - ctr. axis rad.        13
        Place solid 4 face 4 vert. polyhedron   14
        Place solid 5 face 5 vert. polyhedron   15
        Place solid 5 face 6 vert. polyhedron   16
        Place solid 6 face 7 vert. polyhedron   17
        Place solid 6 face 8 vert. polyhedron   18
        Place rectangular plane by 3 points     19
        Place parallelogram plane by 3 points   20
        Place solid right angle wedge           21
        Rho conic                               22
        Conic by 3 points and 2 tangents        23
        Conic by 4 points and 1 tangent         24
        Conic by 5 points                       25
        Place sphere by center and radius       26
        Place solid globe                       27
        Place solid ellipsoid - foci axis len.  28
        Place solid ellipsoid - ctr. axis rad.  29
        Place right elliptical cylinder         30
        Place trunc. elliptical cone            31
        Place part of curve                     32
        Place parabola tangent to 2 curves      33
        Place blend between 2 curves            34
        Place helix                             36
        Place partial surface                   37
        Place surface of revolution             38
        Place solid of revolution               39
        Project curve onto surface along norm   40
        Project point along vector onto surf    41
        Project curve along vector onto surf    42
        Place surface by 3 boundaries           43
        Place surface by 4 boundaries           44

        Place offset surface                    45
        code for Place offset surface is moved to
        src_testco/imp ECcsoffseti.I

        Blend 2 surfaces - interior             46
        Blend 2 surfaces - exterior             47
        Place plane tangent to surface          49
        Place plane tangent to curve            50
        Extract iso curves                      52
        Place surface of projection             83
        Place solid of projection               84
        Intersect elements                      85
        Place conic by linestring               93
        Place plane normal to curve             94
	Place solid by offsetting surface	109
        Create wireframe model			112
        Place parting lines as curves		113
	Place parting lines as features		201
	Display isophotes                       202
	Place angular parting surface		203
	
 History

 10/28/87 : rlw : The beginning
 03/19/93 : sam : code for place offset surface (case 45)is moved to
                  src_testco/imp/ECcsoffseti.I. --sampath
*/

class implementation ECconstruct;

method perform_construction()
{
  switch (me->mytype)
    {
    case /*Place solid box by two points*/           1:
    case /*Place box by four points*/                2:
    case /*Place solid box by four points*/          3:
    case /*Place cone by axis and radii*/            4:
    case /*Place solid right trunc. cone*/           5:
    case /*Place cylinder by axis and radius*/       6:
    case /*Place solid right circ. cylinder*/        7:
    case /*Place torus*/                             8:
    case /*Place solid torus*/                       9:
    case /*Place solid right elliptical cylinder*/   10:
    case /*Place solid trunc. elliptical cone*/      11:
    case /*Place ellipsoid - foci axis len*/         12:
    case /*Place ellipsoid - ctr. axis rad*/         13:
    case /*Place solid 4 face 4 vert. polyhedron*/   14:
    case /*Place solid 5 face 5 vert. polyhedron*/   15:
    case /*Place solid 5 face 6 vert. polyhedron*/   16:
    case /*Place solid 6 face 7 vert. polyhedron*/   17:
    case /*Place solid 6 face 8 vert. polyhedron*/   18:
    case /*Place rectangular plane by 3 points*/     19:
    case /*Place parallelogram plane by 3 points*/   20:
    case /*Place solid right angle wedge*/           21:
    case /*Place sphere by center and radius*/       26:
    case /*Place solid globe*/                       27:
    case /*Place solid ellipsoid - foci axis len*/   28:
    case /*Place solid ellipsoid - ctr. axis rad*/   29:
    case /*Place right elliptical cylinder*/         30:
    case /*Place trunc. elliptical cone*/            31:
    case /*Place surface of revolution*/             38:
    case /*Place solid of revolution*/               39:
    case /*Place plane tangent to surface*/          49:
    case /*Place plane tangent to curve*/            50:
    case /*Place surface of projection*/             83:
    case /*Place solid of projection*/               84:
    case /*Place plane normal to curve*/             94:

      return (om$send (msg = message ECconstruct.perform_prim_construction(),
              targetid = my_id));

    case /*Place surface by 3 boundaries*/           43:
    case /*Place surface by 4 boundaries*/           44:
    case /*Blend 2 surfaces - interior*/             46:
    case /*Blend 2 surfaces - exterior*/             47:
    case /*Place Angular parting surface*/           203:
    case /*Place partial surface*/                   37:
    case /*Place offset surface code is moved 
           to src_testco/imp/ECcsoffseti.I */        45:
    case /*Place solid by offsetting surface*/       109:

      return (om$send (msg = message ECconstruct.perform_free_construction(),
              targetid = my_id));

    case /*Rho conic*/                               22:
    case /*Conic by 3 points and 2 tangents*/        23:
    case /*Conic by 4 points and 1 tangent*/         24:
    case /*Conic by 5 points*/                       25:
    case /*Place part of curve*/                     32:
    case /*Place parabola tangent to 2 curves*/      33:
    case /*Place blend between 2 curves*/            34:
    case /*Place helix*/                             36:
    case /*Project curve onto surface along norm*/   40:
    case /*Project point along vector onto surf*/    41:
    case /*Project curve along vector onto surf*/    42:
    case /*Extract iso curves*/                      52:
    case /*Intersect elements*/                      85:
    case /*Create wireframe model*/                  112:
    case /*Place parting lines as curves*/           113:
    case /*Place parting lines as features*/         201:
    case /*Display isophotes*/                       202:
    case /*Place conic by linestring*/               93:

      return (om$send (msg = message ECconstruct.perform_wframe_construction(),
              targetid = my_id));

  default:
    return (OM_E_ABORT);
  }
}

end implementation ECconstruct;
