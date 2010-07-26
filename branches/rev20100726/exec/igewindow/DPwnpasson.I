


class implementation IGEwindow;


method passon  (
                       OM_p_MESSAGE     pass_msg;
                       IGRchar          *chan;
                       IGRint           strt_index;
                       IGRint           end_index)
{
    OM_S_CHANSELECT chandef1;

    
   chandef1.type = OM_e_name;
   chandef1.u_sel.name = chan;

    return (om$send(mode = OM_e_wrt_object,
                    msg = pass_msg,
                    senderid = my_id,
                    p_chanselect = &chandef1,
                    from = strt_index,
                    to = end_index));
}


end implementation IGEwindow;
