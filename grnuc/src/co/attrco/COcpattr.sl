/* #######################    APOGEE COMPILED   ######################## */
 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
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

/******************************************************************************

Description:		This class implements following commands:

			     1. Copy Symbology
			     2. Copy Text Parameters
			     3. Copy Element Names to File (List Names)

Abstract class:		No.

Override methods:	from super_command

			form_notification;

Messages:		

	message form_init ();
	message form_update ();
	message list_names ();

History

        jay wallingford	    11/21/87  design and implementation.
        jhw                 06/29/88  created COcpattr class. 
        jhw                 04/23/89  subclassed from COtools and COdpb


Notes

    COMMAND TABLE ENTRIES FOR COcpattr:
   -----------------------------------------------------------------
    cmd_str                            cmd_key        cmd_class  
   --------------------------------------------------
    copy symbology                          COPYSYMB
   --------------------------------------------------
    copy text parameters                    COPYTXPA        
   --------------------------------------------------
    list names                              LISTNAMES
   --------------------------------------------------

Bugs:	No know bugs.

Notes:  This class should be combined with the class which provides
        commands to change non-geometric attributes of graphic objects.
        This new class (COchange in the manipco lib) should be subclassed 
        from COtools, COdpb and CEO_GSLOCATE. This will get rid of a class 
        definition (COcpattr) and reduce the size and complexity of the
        code in the current COchange class.

*******************************************************************************/

class          COcpattr
product_name   "$SOURCE"
super_class    COtools
super_class    COdpb
super_class    CEO_GSLOCATE
spec_path      "$grnuc/co/spec"
path           "."
start_state    terminate
options	       "SItc"
 
specification

#include <fontdef.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIprims.h>
#include "cpattrco.h"

instance
{
    IGRulong mask;
}

implementation

#include <coimport.h>

action form_notification extern
action form_init () extern
action form_update (IGRuint upd_mask) extern

action arg_name_to_value 
{
    *ret_type = _COB_UNKNOWN_ARG;
    *is_const = 0;

    if ( class_name[0] ) 
    {
        if ( ! strcmp ( arg, "mask" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->i = me->mask;
                *ret_type = _COB_arg_i;
            }
            else if ( addr_mode == _COB_address ) 
            {
                data->p = (char *) &me->mask;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
        else if ( ! strcmp ( arg, "fp" ) ) 
        {
            if ( addr_mode == _COB_regular ) 
            {
                data->p = (char *) me->fp;
                *ret_type = _COB_arg_p;
                *is_const = 1;
            }
        }
    }

    if ( *ret_type == _COB_UNKNOWN_ARG ) 
    {
        status = om$send ( msg = message CEO_GSLOCATE.arg_name_to_value 
                                                ( addr_mode,
                                                  class_name,
                                                  arg,
                                                  data,
                                                  ret_type,
                                                  is_const ),
                           mode = OM_e_wrt_message,
                           targetid = my_id );
        _err_ck(status);
    }
}

action list_names ()
{     
    /* misc flags and macro arguments */
    IGRlong             ok;
    OMuint              count, i;
    struct GRobj_env    * objects, *p, objs[50];
    IGRchar             str[80];

    /*
     * Get the number of object ids on the locate channel.
     */
    status = gr$gsinqcount(msg = &ok,
                            count = &count,
                            p_chanselect = &me->located_chansel);
    if ( !(status&ok&1) ) 
    {
        me->ret = status = OM_E_ABORT;
        goto quit;
    }

    /* 
     * Allocate a buffer to hold the object enviroment for the objects.
     */
    if ( count ) 
    {
        objects = objs;
        if (count > 50) 
             objects = (struct GRobj_env *)om$malloc( size = (count * sizeof(struct GRobj_env) ) );

        if ( ! objects ) 
        {
            me->ret = status = OM_E_ABORT;
            goto quit;
        }

        status = gr$gsget_objects( msg = &ok,
                                   array = objects,
                                   size = ( count * sizeof(struct GRobj_env)),
                                   count = &count,
                                   p_chanselect = &me->located_chansel );

        if ( !(status&ok&1) ) 
        {
	    /* Trash the object array */
            if (count > 50) om$dealloc(ptr = objects);
            me->ret = OM_E_ABORT;
            goto quit;
        }

        /*
         * Find the object names for all the objects in the array and write 
         * the object name, objid and osnum out to the file.
         */
        p = objects;
        for ( i=0; i<count; i++ ) 
        {
            status = di$untranslate ( objname = str,
                                      objid = p->obj_id.objid,
                                      osnum = p->obj_id.osnum );
            if ( status&1 ) 
            {
                fprintf((FILE *)me->fp, 
                        "%s,%ld,%ld\n", 
                        str, 
                        p->obj_id.objid, 
                        p->obj_id.osnum);
                fflush((FILE *)me->fp);
            }
            ++p;
        }

        /* Trash the object array */
        if (count > 50) om$dealloc(ptr = objects);
    }

}
