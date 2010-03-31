/* ###################   APOGEE COMPILED   ################## */
class implementation EMShorizon;

method NDmove_to_root (IGRlong         *msg; 
                       struct GRid     *src_grid;
                       struct GRmd_env *md_env )
/*******************************************************************

Description
    If I receive this message, one of my parents has been deleted
    so I should delete myself. 

History
    Jack    10/02/91     Creation

*********************************************************************/
{
  IGRlong sts;

 *msg = EMS_S_Success;

  sts =  om$send(msg      = message Root.delete(1),
                 targetid = my_id,
                 targetos = OM_Gw_current_OS);

 return (sts);
}

end implementation EMShorizon;
