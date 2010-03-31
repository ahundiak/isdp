# ifndef emsbool_include
# define emsbool_include 1

/*
HISTORY
06/21/89    DLB Added DISJ_DUE_TO_RETRY bit to indicate that the disjoint
                operation is due to an intersecting boolean retry rather than
                as a result of a disjoint boolean by definition.
21 Nov 1988 jBk Added EMSbool_delDisjArea to EMSbooltype
                enumeration.
13 Apr 1988 jBk Added sixteen more types to EMSbooltype
                enumeration.
                Added NOTE.
                Changed "EMSbool_hollowDif" to
                "EMSbool_interiorD."  Has same value.
04 Dec 1987 jBk Added disjoint and hollow types to EMSbooltype.
??-???-???? ??? Creation.  (Who dat who say, "Who dat?")

NOTE

A regularization of the order of the EMSbooltype enumeration is
not desirable until a database change is allowed, if then.
*/

#define DISJ_DUE_TO_RETRY 0x80 /*See above history note.*/

/*
EMSbooltype is used to specify the boolean operation between two
or more objects.
*/

enum EMSbooltype 
{
    EMSbool_intersect,  /* Boolean intersection (abbreviation:  intxn)  */
    EMSbool_union,      /* Boolean union                                */
    EMSbool_difference, /* Boolean difference                           */

    EMSbool_saveside,   /* cut with infinite plane saving 1 side        */

    EMSbool_disjointU,  /* union with elements occupying disjoint space */
    EMSbool_interiorD,  /* diff with wholly interior element(s)         */
    EMSbool_disjointD,  /* diff with elements occupying disjoint space  */
    EMSbool_surroundD,  /* diff with disjoint, encompassing element(s)  */
    EMSbool_interiorU,  /* union with wholly interior element(s)        */
    EMSbool_surroundU,  /* union with disjoint, encompassing element(s) */
    EMSbool_interiorI,  /* intxn with wholly interior element(s)        */
    EMSbool_disjointI,  /* intxn with elements occupying disjoint space */
    EMSbool_surroundI,  /* intxn with disjoint, encompassing element(s) */

    EMSbool_solidNullU, /* union of something with empty set */
    EMSbool_nullSolidU, /* union of empty set with something */
    EMSbool_solidNullD, /* something difference with empty set */
    EMSbool_nullSolidD, /* empty set difference with something */
    EMSbool_solidNullI, /* something intersect with empty set */
    EMSbool_nullSolidI, /* empty set intersect with something */

    EMSbool_nullNullU,  /* union of empty sets */
    EMSbool_nullNullD,  /* difference of empty sets */
    EMSbool_nullNullI,  /* intersection of empty sets */

    EMSbool_delDisjArea, /* modified by deletion of disjoint area(s) */
    EMSbool_TrimCompsfs  /* Trimmed composite surface state */
};

# endif
