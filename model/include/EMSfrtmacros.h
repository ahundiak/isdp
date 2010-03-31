# ifndef EMSfrtmacros_include
# define EMSfrtmacros_include

# omdef frt$update(rc,
                   mx_type = NULL, mx = NULL,
                   rlt,
                   bs_attr = NULL,
                   surface = NULL,
                   buffer = NULL,
                   buffer_size = 0,
                   partol_basis = NULL,
                   osnum = OM_Gw_current_OS,
                   objid ^ channel_selector,
                   from_index = 0, to_index = MAXINT)

#   if om$specified(channel_selector)

    om$send(msg = message EMSgradata.EMupdate((rc), (mx_type), (mx),
            (rlt), (bs_attr), (surface), (buffer), (buffer_size),
            (partol)), p_chanselect = (channel_selector),
            from = (from_index), to = (to_index))

#   elif om$specified(osnum)

    om$send(msg = message EMSgradata.EMupdate((rc), (mx_type), (mx),
            (rlt), (bs_attr), (surface), (buffer), (buffer_size),
            (partol)), targetid = (objid), targetos = (osnum))

#   else

    om$send(msg = message EMSgradata.EMupdate((rc), (mx_type), (mx),
            (rlt), (bs_attr), (surface), (buffer), (buffer_size),
            (partol)), targetid = (objid))

#   endif

# endomdef

# endif
