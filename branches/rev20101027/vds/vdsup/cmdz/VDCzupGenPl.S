class specification VDCzupGenPl (1:0) of VDCzupGen;

message PlaceMacro( long * sts );
message hello     ( long * sts );

override init,sleep,wakeup;
override form_notification;

end specification VDCzupGenPl;
