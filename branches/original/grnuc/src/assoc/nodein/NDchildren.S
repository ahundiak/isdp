/*
  ABSTRACT
 
  This class is the parent class for all objects using the
  channel "children" to connect root objects to theirs 
  dependents.


  HISTORY

  Unknown
*/

class specification NDchildren (0:1) of Root;

/*------------------ INSTANCE DATA SECTION -------------------*/

instance NDchildren
{
  channel {(many_to_many,
            rel_ordered) 
          NDfather.father;} children;
};

end specification NDchildren;
