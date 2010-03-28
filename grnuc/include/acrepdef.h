#ifndef acrepdef_include
#define acrepdef_include

/* The following values define how an entity supports representation    */
/* management and what is its current representation			*/

/* name given to the template corresponding to representation */

#define TEMP_REP_NAME "~rep"

/* -- assoc level  */

#define AC_ASSOC_REP 0x70  /* bits 0 to 3 reserved for assoc management  */
 
#define AC_NO_REP    0x0   /* entity does not support representation mngt    */
#define AC_FREE_REP  0x10  /* entity has a representation free to change     */
#define AC_DEP_REP   0x20  /* entity representation depends upon parent rep. */
#define AC_ERROR_REP 0x40  /* This element is AC_DEP_REP with inconsistent   */
			   /* parent representation		            */
/* -- complex level */

#define AC_CPX_REP   0x1    /* bit 1 reserved for cpx representation */

#define AC_INTERNAL  0x1 /* A complex entity is represented by its components*/
			 /* Their internal representation is used if defined */
#define AC_EXTERNAL  0x0 /* A complex is represented as a global entity      */
			 /* VDS representation is used if defined            */


/* -- VDS level */

#define AC_VDS_REP    0xf /* bits 2 to 4 reserved for vds representation */

#define AC_2D_REP     0x2 /* schematic representation */
#define AC_3D_REP     0x4 /* detailed representation  */
#define AC_ENV_REP    0x8 /* envelope representation  */


/* -- SUB representation						     */
/* a unique subrepresentation is allowed for now. It will not be understood  */
/* by VDS								     */

#define AC_SUB_REP   0x80 /* Reserved for sub representation TBD */ 


/* OLD STUF to not oblige everybody to modify their code */
		
#define NV_external 		1
#define NV_internal_2d 		2
#define NV_internal_3d 		4
#define NV_envelop 		8

#endif
