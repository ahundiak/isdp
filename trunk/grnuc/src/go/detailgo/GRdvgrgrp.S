/* #######################    APOGEE COMPILED   ######################## */
/*\
Abstract
   This class represents the drawing view graphic group.

History
   Gray Winn   07/25/88    Design and Coding Date.
\*/

class specification GRdvgrgrp (1:0) of GRgrgrp;

override GRvg;
from GRowner inherit GRprismrel_owner;

override GRrigidconn;


end specification GRdvgrgrp;
