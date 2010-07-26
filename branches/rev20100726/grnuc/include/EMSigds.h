# ifndef EMSigds_include
# define EMSigds_include 1

/*
DESCRIPTION

This file is used in code which translates to and from IGDS.

HISTORY

27 Jul 1988 jBk Genesis.
*/

struct IGDS_sv1819 /* surface or solid (types 18 and 19) */
{
    struct GUcommon_header_info header;
    IGRshort                    wds_in_descript;
    IGRshort                    num_elements;
    IGRchar                     svType;
    IGRchar                     curvesPerBoundary;
};

# endif /* EMSigds_include */
