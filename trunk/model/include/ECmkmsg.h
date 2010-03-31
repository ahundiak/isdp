# ifndef ECmkmsg_include
# define ECmkmsg_include 1

/************************************************************************
        Include file for general construct method
 ************************************************************************/

#define EC_max_func  8

#include <igrtypedef.h>
#include <igr.h>
#include <OMminimum.h>

/************************************************************************
        Functions for making messages for constructs
 ************************************************************************/

/**************************************************************************
   It is necessary to use %safe in order to force OPP to ignore the
   following declarations.  OPP considers the use of pointers to functions
   as an error.  It is recommended that the external function declarations
   also be included within the %safe ... %endsafe construct.  This is an
   OPP construct and not a C language construct.
 *************************************************************************/

%safe

/*
extern IGRlong ECcyl_mkmsg();
extern IGRlong ECsphere_mkmsg();
*/
/*
extern IGRlong ECbox_mkmsg();
extern IGRlong ECcone_mkmsg();
extern IGRlong ECplane_mkmsg();
extern IGRlong ECtorus_mkmsg();
extern IGRlong ECtube_mkmsg();
extern IGRlong ECconics_mkmsg();
*/

IGRlong ECdummy_func();

/************************************************************************
        Array of pointers to make message functions
 ************************************************************************/

typedef IGRlong (*ECmkmsg_funcptr)();

ECmkmsg_funcptr ECmkmsg_func[] =
{
 ECdummy_func/*,*/      /* 0 */
/* ECcyl_mkmsg,*/       /* 1 */
/* ECsphere_mkmsg,*/    /* 2
 ECbox_mkmsg,        3
 ECcone_mkmsg,       4
 ECplane_mkmsg,      5
 ECtorus_mkmsg,      6
 ECtube_mkmsg,       7
 ECconics_mkmsg,     8
*/
};

%endsafe

IGRlong ECdummy_func(status)
    IGRint  status;
{
    status = OM_E_ABORT;
    return(status);
}

IGRboolean EC_index_in_range(index)
    IGRint      index;
{
    if ((index > 0) && (index <= EC_max_func))
        return(TRUE);
    else
        return(FALSE);
}

void ECfree_msg(mssage)
    OM_S_MESSAGE    *mssage;
{
    free(mssage->p_arglist);
}

# endif /* ECmkmsg_include */
