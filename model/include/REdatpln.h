#ifndef REdatpln_h
#define REdatpln_h 1

/*
 * This structure highlights the format of the recomputation information
 * for the following reference plane types.
 * Reference plane parallel to a planar face
 * Reference plane angle to a planar element
 * Reference plane on a planar face.
 */

#define EMS_ASfrom_planar_element 1
#define EMS_ASparallel_to_planar_element 2
#define EMS_ASangle_to_planar_element 3
#define EMS_ASparallel_to_planar_element_new 4
/* 
 * Recomputation information for the above defined types follow 
 */
struct EMSdatpln_planar_element_info
{
#define  EMS_TOP_ELEMENT 0x1 
#define  EMS_RIGHT_ELEMENT 0x2
#define  EMS_BOTTOM_ELEMENT 0x4
#define  EMS_LEFT_ELEMENT 0x8
#define  EMS_REVERSE_DIR 0x10
  unsigned char props;
};

struct EMSrefpln_planar_element_info
{
#define  EMS_X_EDGE 0x1  
#define  EMS_Y_EDGE 0x2
#define  EMS_EDGE_REV 0x4
#define  EMS_X_EDGE_PRIMARY 0x8
#define  EMS_PLANE_REV 0x10
#define  EMS_THRU_POINT 0x20
#define  EMS_OFFSET_VALUE 0x40
  unsigned char props;
};
#endif
