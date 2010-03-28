class implementation COcpattr;



#include <coimport.h>



method arg_name_to_value ( int addr_mode ; char * class_name ; char * arg ; COB_arg_union * data ; int * ret_type ; char * is_const )
{
  int		  status = OM_S_SUCCESS;

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
quit:
  return OM_S_SUCCESS;
}

method list_names ()
{     
  int		  status = OM_S_SUCCESS;

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

quit:
  return OM_S_SUCCESS;
}

end implementation COcpattr;
