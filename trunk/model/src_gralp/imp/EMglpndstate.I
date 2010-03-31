/* ###################   APOGEE COMPILED   ################## */
class implementation EMSgraloop;

method NDget_state(IGRchar *n_state )

/* ************************************************************************

Description
 We just want to return success at this class since we rejected the instance
 data for NDnodein.

History
    Jack    9/14/91     Creation

************************************************************************** */

{
 return (OM_S_SUCCESS);
}

method NDchg_state (IGRchar mask,n_state) 

{
 return (OM_S_SUCCESS);
}

end implementation EMSgraloop;

