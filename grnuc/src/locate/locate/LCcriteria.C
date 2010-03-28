/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        LCcriteria

Description
        These functions are used to maintain a classlist of object types
        which are valid for locate.

History
        rc      ??/??/??    creation
        mrm     10/23/89    declare functions as ints
*/

#include "grimport.h"
#include "OMminimum.h"

static OM_S_CLASSLIST LC_criteria_class;

int LCget_criteria_class (class1)
OM_p_CLASSLIST *class1;
{
    if (LC_criteria_class.w_count && LC_criteria_class.p_classes)
    {
        *class1 = &LC_criteria_class;
    }
    return (1);
}

int LCput_criteria_class (class1)
OM_p_CLASSLIST class1;
{
    int ii;

    if (class1)
    {
        LC_criteria_class.w_flags = class1->w_flags;
        LC_criteria_class.w_count = class1->w_count;
        LC_criteria_class.p_classes = 
                       (OMuword *) malloc (sizeof (OMuword) * class1->w_count);
        for (ii = 0; ii < (int)class1->w_count; ii++)
        {
            LC_criteria_class.p_classes[ii] = class1->p_classes[ii];
        }
    }
    else
    {
        LC_criteria_class.w_count = 0;
        LC_criteria_class.p_classes = 0;
        LC_criteria_class.w_flags = 0;
    }
    return (1);
}

int LCfree_class_criteria()
{
    if (LC_criteria_class.w_count && LC_criteria_class.p_classes)
    {
        free (LC_criteria_class.p_classes);
    }
    LC_criteria_class.w_count = 0;
    LC_criteria_class.w_flags = 0;
    LC_criteria_class.p_classes = NULL;

    return( 1 );
}
