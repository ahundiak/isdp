class implementation NMinters;

method delete (int f_defer_flag)
{
 OM_S_CHANSELECT	to_other_int;
 IGRlong		sts, EMmsg;

 NMmake_chanselect(NMinters_to_other_int, &to_other_int);

 /* Delete the intersection data created by me.
 */
 sts = om$send(msg = message NMinters.NMdelete_inters(&EMmsg, TRUE, FALSE), 
       targetid = my_id);
 if(!(1&EMmsg&sts)) goto wrapup;
 
 sts = om$send(mode = OM_e_wrt_message, 
       msg = message NMassoc.delete(f_defer_flag), 
       p_chanselect = &to_other_int);
 sts = om$send(mode = OM_e_wrt_message, 
       msg = message NMassoc.delete(f_defer_flag), targetid = my_id);

wrapup:
EMWRAPUP(EMmsg, sts, "NMinters.delete");
 return(sts);
}

end implementation NMinters;
