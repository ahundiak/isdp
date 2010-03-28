class specification CO_exp (0:1) of COroot;

instance CO_exp
  {
  int     Command;
  IGRlong state, action;
};

override
  init,
  wakeup,
  execute;

end specification CO_exp;
