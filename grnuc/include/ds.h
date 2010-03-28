/*******************************************************************

     ds.h

General Description:

     The ds.h include file defines structures needed for the macros
     defined in dsmacros.h.

Dependencies:

     dsdef.h

*********************************************************************/

#ifndef ds_include
#define ds_include

#include "dsdef.h"

/*
 * Macro Drawing Sheet Standard structure
 */
struct ds_standard {
     IGRchar             name[MAX_STANDARD_LEN];
     unsigned int        units:1;                 /* Imperial or Metric */
     unsigned int        imperial:1;              /* Supported or Not */
     unsigned int        metric:1;                /* Supported or Not */
     unsigned int        projection_angle:1;      /* Third or First Angle */
     unsigned int        third:1;                 /* Supported or Not */
     unsigned int        first:1;                 /* Supported or Not */
};

/*
 * Macro Drawing Sheet structure
 */
struct ds_sheet {
     IGRchar             name[MAX_SHEET_LEN];
     IGRchar 	         standard[MAX_STANDARD_LEN];
     IGRchar             file[MAX_FILE_LEN];      /* Cell Library or Reference File */
     IGRchar             view[MAX_CELL_LEN];      /* Cell Name or Saved View Name */
     unsigned int        units:1;                 /* Imperial or Metric */
     unsigned int        projection_angle:1;      /* Third or First Angle */
     unsigned int         filetype:1;              /* Cell Library or Reference File */
     IGRdouble           width;                   /* Stored in internal units */
     IGRdouble           height;                  /* Stored in internal units */
};

/*
 * Object Drawing Sheet Standard structure
 */
struct GRds_standard {
     IGRchar             name[MAX_STANDARD_LEN];
     unsigned int        props;
};

/*
 * Object Drawing Sheet structure
 */
struct GRds_sheet {
     IGRchar             name[MAX_SHEET_LEN];
     IGRchar 	         standard[MAX_STANDARD_LEN];
     IGRchar             file[MAX_FILE_LEN];      /* Cell Library or Reference File */
     IGRchar             view[MAX_CELL_LEN];      /* Cell Name or Saved View Name */
     unsigned int        props;                   /* Sheet properties */
     IGRdouble           width;                   /* Stored in internal units */
     IGRdouble           height;                  /* Stored in internal units */
};

#endif

