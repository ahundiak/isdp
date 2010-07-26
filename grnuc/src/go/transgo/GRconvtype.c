/*
Name
        GRconversion_type
        GRset_conversion_type

Description
        These functions allow lower level routines to know whether the
        conversion taking place is to pure IGDS or to a plotting metafile.
        Many of the same routines are used for both conversions, and sometimes
        this knowlege is useful (and sometimes downright necessary).  This is
        yet another piece of info that should eventually be added to the
        arguments passed around

History
        mrm     02/14/92    creation
*/

#include "transdef.h"

static int filetype = GRNoConversionInProgress;

int GRconversion_type()
{
    return(filetype);
}

int GRset_conversion_type(newtype)
int newtype;
{
    return(filetype = newtype);
}
