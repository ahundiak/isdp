#ifndef PDMS_MACRO_PRO_H
#define PDMS_MACRO_PRO_H

#include "PDMstruct.h"

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __PDMS
#define __PDMS(args) args
#endif
#else
#ifndef __PDMS
#define __PDMS(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* ./macros/PDMm_parts.c */
extern void PDMppl_query_for_parts      __PDMS((int *status, char *catalog, int *count, PDMparts *parts));
extern void PDMppl_query_for_catalogs   __PDMS((int *status, int *count, PDMcatalogs *catalogs));
extern void PDMppl_ris_query            __PDMS((int *status, char *query, int *rows, char **output_buffer_stream, int *ris_err_code));
extern void PDMppl_ris_stmt             __PDMS((int *status, char *statement, int *ris_err_code));
extern void PDMppl_query_bom            __PDMS((int *status, int *count, PDMboms *boms));
extern void PDMppl_set_alt_bom_switch   __PDMS((int *status, char *alt_parent_attr));
extern void PDMppl_reset_alt_bom_switch __PDMS((int *status));

#if defined(__cplusplus)
}
#endif

#endif
