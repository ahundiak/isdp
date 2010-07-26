/*
  ABSTRACT

  This class of owner geometries consists of entities  which relate 
  other graphics objects.  This class implies that the subclasses share
  a common channel which relates the owner object to one or more other
  graphics objects.  This class provides a default interpretation for 
  all messages. 
  The owner class has the following properties:
     -  contains no geometry 
     -  contains no symbology
     -  can not be a member of the rtree
     -  can be a member of the btree
     -  can be nested as long as an acyclic graph is formed

  The subclases of the owner class has the following properties:
     -  can contain geometry
     -  can contain symbology and level
     -  can not be a member of the rtree
     -  can be a member of the btree 
     -  can be nested as long as an acyclic graph is formed

  This class provides an abstract class for owners which allow their
  components to be modified.  If the component can be geometrically
  modified then the range can change when modified. This implies that
  the components should be a member of the R-tree and that the owners
  should not be a member of an R-tree.

  There are two types of flexible owners, the first will treat its
  components as a logical group of elements and the second will treat
  its components as a spatial group of elements. These two types of
  groups share many things in common the only difference is in which 
  object is located for operations that perform spatial queries (e.g.
  fence contents).  The logical group will allow its components to be 
  located individual while the spatial group will allow only its header
  to be located.  Thus both spatial and logical groupings can be 
  combined into one class with a properties word to distinguish the 
  type of owner.


  NOTES

  Classes which do not wish to inherit the properties word should
  reject the instance data of this class and override the 
  GRget_owner_properties and GRchg_owner_properties messages.


  HISTORY

  Gray Winn   10/21/87    Design and Coding Date.
*/

class specification GRflxown (1:0) of GRowner;

#include "growner.h"

/*------------------ INSTANCE DATA SECTION -------------------*/

instance GRflxown
{
  IGRshort owner_properties; 
};

override 
  GRvg;

/*--------------- MESSAGE DECLARATION SECTION ----------------*/

override 
  GRget_channel_type,        
  GRget_owner_properties,
  GRchg_owner_properties;

#ifndef BASE_EMS

override
  GRprismrel_owner,          
  GRget_locate_properties,   
  GRcomponent_disconnecting; 

#endif

end specification GRflxown;
