




 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              Intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
Name
        grptn.h

Description
            This file contains structures used in the construction of
        patterning objects and patterns.

Dependencies
        grsymdef.h
        grsym.h

History
        mrm     05/04/87    creation
                11/11/87    renamed pa_construct_data to GRpaconstruct
                            added GRepconstruct, GRapconstruct
*/

#ifndef grptn_include
#define grptn_include

struct GRpaconstruct
{
    IGRchar                    *class_spec; /* data specific to a subclass   */
    IGRdouble                   dx;         /* pattern delta                 */
    IGRpoint                    origin;     /* pattern origin                */
    GRrange                     range;      /* range of reference geometry   */
    struct GRmd_env             ref_env;    /* module data for ref geometry  */
    struct GRactive_symbol_def  sym_def;    /* active symbol definition --   */
                                            /* sym_def.objid == NULL_OBJID   */
                                            /* implies not using symbol      */
};

struct GRepconstruct
{
    IGRpoint                    dir_pt;     /* indicator for closed elements */
    IGRpoint                    stop_pt;    /* pt on element to end pattern  */
};

struct GRapconstruct
{
    IGRdouble                   dy;         /* y delta                       */
};

/*
    The following #define is intended as a temporary workaround for the 1.2.0
    release of I/DRAFT.  Applications should NOT depend upon it; it may be
    removed in ANY subsequent release.

    There are cases when it is desirable to delete a pattern header and
    the pattern components without deleting the patterned object.  Although
    the user normally has this capability with the "Drop" command, it is
    not always possible to use the GRdrop message through software.
    Specifically, when an error occurs during the initial generation of a
    pattern, the original element should not be deleted.  Because of the
    way the pattern header is dependent upon the patterned object, it is
    not possible to remove the patterned object from the channel prior to
    sending the pattern header a GRdelete message.  In most cases, it is
    correct for the pattern header to delete the patterned object along with
    itself and the pattern components.  In the case described above, however,
    the caller wants the patterned object to remain undeleted.  For this
    reason, if the msg argument to GRdelete is set to the #define below
    before sending the message, the patterned object will not be deleted.
*/

#define PATTERN_KLUDGE      (-98789)

#endif
