/*
  DESCRIPTION

    This command locates a Boolean DPR and redoes/prints the Boolean tree, 
    upto a specified depth. When any non-Boolean node is hit, it is
    considered a primitive. Save-side op is treated as a Boolean.

    It can optionally perform the redo in incremental steps starting from
    the top. That is, it will undo to the next level and redo back up.
    Then, undo two levels down and backup one level. It prints out
    relevant information at every step. But at the end of such an execution
    the solid is not restored. This can be used to simply find the first
    problem node encountered top-down.

  HISTORY

    SS  :  11/02/92
*/

class specification ECrebool (2:2) of ECelements;

override execute, get_locate_criteria;

end specification ECrebool;
