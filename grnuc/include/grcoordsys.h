/*
Name
        grcoordsys.h

Description
        This include file contains structures used for auxiliary
        coordinate systems.

Dependencies
        csdef.h

History
        Kumar Talluri   08/05/87    creation
        mrm             02/04/88    added GRcs_construct
        mrm             09/03/93    renamed from cs.h to avoid conflict with
                                    system header file on SGI
*/

#ifndef grcoordsysinclude

#define grcoordsysinclude

struct GRcstype_info
{
    IGRchar    *cstype;                 /* type of coordinate system */
    IGRshort    num_inputs;             /* # inputs required by user */
    IGRlong     index_into_query_table; /* to query info */
};

struct GRcsquery_info
{
    IGRlong     abs_prompt_key;                 /* absolute (XY) prompt */
    IGRlong     delta_prompt_key;               /* relative (DL) prompt */
    IGRchar     unit_type[GRIO_MAX_ALIAS_SIZE]; /* input type required */
};

struct GRcs_construct
{
    IGRchar    *desc;       /* description of cs being constructed           */
    IGRchar     flag;       /* flag controlling construction parameters      */
                            /*                                               */
                            /* bit 0    controls whether to connect to the   */
                            /*          cs manager.  If this bit indicates   */
                            /*          that the connection is not to be     */
                            /*          made, it is assumed that the creator */
                            /*          will handle the necessary            */
                            /*          connection.                          */
                            /*                                               */
                            /* bit 1    indicates whether to make the cs     */
                            /*          active.                              */
                            /*                                               */
                            /* bits 2-7 reserved                             */
                            /*                                               */
                            /* see csdef.h for #define's for these flags     */
    IGRshort   type;        /* coordinate system type: rect., cyl., sphere.  */
};

#endif
