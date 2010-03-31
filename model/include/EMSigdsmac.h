# ifndef EMSigdsmac_include
# define EMSigdsmac_include 1

/*
DESCRIPTION

This file is used in code which translates to and from IGDS.

HISTORY

06 Mar 1989 jBk Modified to accomodate color changes.
27 Jul 1988 jBk Genesis.
*/

/* symbology derivation macros */

# define IGDS_SYMBOLOGY_TO_IEMS_COLOR(symbology) \
    ((((symbology) & 0xff00) >> 8) + 1)

# define IGDS_SYMBOLOGY_TO_IEMS_WEIGHT(symbology) \
    (((symbology) & 0x00f8) >> 3)

# define IGDS_SYMBOLOGY_TO_IEMS_STYLE(symbology) \
    ((symbology) & 0x0007)

/* macro to extract kind of type 23 element */

# define IGDS_EXTRACT_KIND_OF_TYPE_23(cone_type_word) \
    ((cone_type_word) & 0x0007)

/* macro to determine if type 23 element is a surface (TRUE) or
    if it is a solid (FALSE) */

# define IGDS_EXTRACT_TYPE_23_IS_SOLID(cone_type_word) \
    (!((cone_type_word) & 0x8000))

# endif /* EMSigdsmac_include */
