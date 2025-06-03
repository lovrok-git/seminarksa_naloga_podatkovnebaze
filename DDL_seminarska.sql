create table menjavemostev (
    id int,
    driverId int,
    idPrejsnegaMostava int,
    idTrenutnegaMostva int
);

alter table menjavemostev
modify column id int auto_increment primary key;

alter table menjavemostev
add column systime timestamp default current_timestamp;