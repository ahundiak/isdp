/*
** TOdsl.h - include file for dsl structures
**
*/

#include "EMSbnddef.h"
#include "EMSbnd.h"

/*
** the Ext_data structure contains all values, which
** are not known to the "ta" routines, because they are
** depended on EMS. The "ta" routines will use
** only a pointer to Ext_data, and routines from "dsl"
** have to fill this pointer
*/
struct Ext_data_surface {
       struct GRid     referenced_object; /* reference to object id
                                          ** of element, which is
                                          ** referenced
                                          */
       struct GRid     displayed_object;  /* Object id of temporary
                                          ** object, which is used
                                          ** to display special aspects
                                          ** of the object
                                          */
       struct IGRbsp_surface *surf;       /* pointer to allocated
                                          ** surface data
                                          */
   };

struct Ext_data_edge {
       struct GRid     referenced_object; /* reference to object id
                                          ** of element, which is
                                          ** referenced
                                          */
       struct GRid     displayed_object;  /* Object id of temporary
                                          ** object, which is used
                                          ** to display special aspects
                                          ** of the object
                                          */
       struct IGRbsp_curve *edge;         /* pointer to allocated
                                          ** curve data
                                          */
       struct EMSedgebound  bound[2];     /* boundaries for the displayed 
                                          ** object
                                          */
       IGRushort            props;        /* edge properties, see file
                                          ** EMSprop.h
					  */
   };
struct Ext_data_tmp {
       struct GRid     referenced_object; /* reference to object id
                                          ** of element, which is
                                          ** referenced
                                          */
       struct GRid     displayed_object;  /* Object id of temporary
                                          ** object, which is used
                                          ** to display special aspects
                                          ** of the object
                                          */
   };
