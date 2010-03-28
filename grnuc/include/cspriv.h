/*
Abstract
        cspriv - contains prompts, masks, & defaults for keyins

Dependencies
        grmessage.h

History
        mrm     10/05/87    changed QUERYINFO to reflect current getevent
                            and prompt capabilities
        mrm     12/31/92    moved static data into GRcsinfo.c to avoid
                            unnecessary duplication of the data in the
                            executable - use GRget_cstype_info and
                            GRget_csquery_info to retrieve pointers to the
                            structures
*/

#ifndef cspriv_include

#define cspriv_include
#define NUM_CS_TYPES     3
#define NUM_INPUT_INFO   9

#endif
