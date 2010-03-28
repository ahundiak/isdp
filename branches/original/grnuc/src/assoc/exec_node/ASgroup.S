/* ###################   APOGEE COMPILED   ################## */
class specification ASgroup (2:0) of ASnode;


/* ********************************************************************

Description

 This class provides for managing multiple rigid components from
 an associative sense. It allows connection to the rigid components
 through the pretend machinery.


History
 PP: Creation : 06/16/92

  ********************************************************************* */ 

instance ASgroup
{
};

override GRget_locate_properties,
         GRcopy,
         ACreturn_foot;

end specification ASgroup;
