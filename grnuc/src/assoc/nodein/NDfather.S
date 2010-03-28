/*
  ABSTRACT

  This class is the parent class for all objects using the
  channel "father" to connect dependent objects to root
  objects.


  HISTORY

  Unknown
*/

class specification NDfather (0:1) of Root;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance NDfather
{
  channel {(many_to_many,
            rel_ordered) 
          NDchildren.children;} father;
};

end specification NDfather;
