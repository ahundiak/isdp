
/* Possible types of constrain on the planes */

#define VR_CNS_VECT   0x0007  /* vectorial constraint        */

#define VR_CNS_FIX_V  0x0001  /* fixed plane      */
#define VR_CNS_PARA   0x0002  /* parallel plane   */
#define VR_CNS_ANG    0x0003  /* plane with angle */

#define VR_CNS_AFF    0x0f00  /* affine constrain  */

#define VR_CNS_FIX_PT 0x0100  /* plane with a fix point      */
#define VR_CNS_PT     0x0200  /* planes with a common point  */

#define VR_CNS_VAL    0x0300  /* planes at a given  distance */
#define VR_CNS_MIN    0x0400  /* planes with minimum distance */
#define VR_CNS_MAX    0x0500  /* planes with maximum distance */
			      /* This relation must go with VR_CNS_PARA. The  */
			      /* distance has a sign and is measured on the   */
			      /* normal of the first plane                    */

/* possible state of the constrain solver */

#define VR_SOLVER_INACTIVE  0 /* inactive				      */
#define VR_SOLVER_INITIAL   1 /* active and waiting for the first constrain   */
                              /* to take into account			      */
#define VR_SOLVER_FIRST     2 /* First resolution after a move                */
#define VR_SOLVER_PROPAGATE 3 /* propagating modification to other elements   */
#define VR_SOLVER_CONVERGE  4 /* trying to solve constraint by modifiing the  */
			      /* request				      */


/* possible state of constrained objects */

#define VR_CONS_INIT  0x1 /* Constrained object moved by the user             */
#define VR_CONS_EXT   0x2 /* Constrained object external to the evaluated     */
			  /* graph of dependency			      */
#define VR_CONS_FREE  0x4 /* Constrained object freed for modification        */
#define VR_CONS_FIXED 0x8 /* Constrained object with a fix position           */

#define VR_CONS_STATE 0xf /* Union of the bits used to define constrain state*/


#define VR_CONS_ERROR 0X80 /* This plane does not verify some constrain      */
#define VR_HAVE_EQ   0x100 /* I already have the equation of the plane       */
#define VR_VECTORIEL 0x200 /* This plane define a vectorial family           */
#define VR_REVERSE   0X400 /* reverse normal of the plane to have positive   */
			   /* direction for the family                       */


/* possible eror when solving constrain system */

#define VR_ALL_OK        0X1 /* All the constrains are verified              */
#define VR_SIMPLEX_ERROR 0x0 /* Error in simplex resolution. Should never    */
			     /* occurs if math OK in the solver 	     */
#define VR_MOVE_FREED    0X2 /* Need to move freed plane to verify coontrain */
#define VR_MOVE_EXTERN   0X4 /* Need to move extern plane to verify coontrain*/
#define VR_MOVE_INITIAL  0X8 /* Need to move plane moved by user to verify   */
			     /* coontrain*/
#define VR_MOVE_FIXED   0X10 /* Need to move fixed plane to verify constrain */
