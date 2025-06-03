#1. Izpišite imena prog, na katerih so se odvijale dirke v zadnjih petih letih.
select distinct c.name
from circuits c join races r on c.circuitId = r.circuitId
where r.year >= YEAR(CURDATE()) - 5;

#2. Izpišite progo (circuit), ki se niso pojavile v nobeni dirki med leti 1950 in 2000.
select distinct c.name
from circuits c join races r on c.circuitId = r.circuitId
where c.circuitId not in (
    select distinct r.circuitId
    from races r
    where r.year between 1950 and 2000);

#3. Izpišite leta, v katerih je tekmovala ekipa McLaren, vendar noben njen voznik ni zmagal tekme.
select distinct r.year
from races r join results e on r.raceId = e.raceId
             join constructors c on e.constructorId = c.constructorId
where c.name = 'McLaren' and 1 < all (select e2.positionOrder
                                      from results e2 join races r2 on e2.raceId = r2.raceId
                                                      join constructors c2 on e2.constructorId = c2.constructorId
                                      where c2.name = 'McLaren' and r.year = r2.year)
order by r.year;

#4. Izpišite leta, v katerih je vsaj en voznik ekip McLaren in Mercedes, zmagal navsaj eni tekmi.
select distinct r.year
from races r join results e on r.raceId = e.raceId
             join constructors c on e.constructorId = c.constructorId
where (e.positionOrder = 1 and c.name = 'Mercedes') and 1 = any (select e2.positionOrder
                                                                 from results e2
                                                                          join races r2 on e2.raceId = r2.raceId
                                                                          join constructors c2 on e2.constructorId = c2.constructorId
                                                                 where c2.name = 'McLaren' and r.year = r2.year);

#5. Izpišite top 10 voznikov, urejenih po številu zmag. Če si več voznikov deli 10to mesto izpišite vse
with skupne_zmage as (
    select d.forename, d.surname, count(*) as st_zmag
    from drivers d join results r on d.driverId = r.driverId
    where r.positionOrder = 1
    group by d.forename, d.surname
),
najmansi as (
    select *
    from skupne_zmage
    order by st_zmag desc limit 10
)
select *
from skupne_zmage
where st_zmag >= (
    select min(st_zmag) from najmansi)
order by st_zmag desc;

#6. Izpišite voznike, ki so dirko več kot 10x končali s trkom (status collision)
select d.forename, d.surname, count(*) as st_trkou
from status s join results r on s.statusId = r.statusId
join drivers d on r.driverId = d.driverId
where s.status = "Collision"
group by d.forename, d.surname
having st_trkou > 10
order by st_trkou;

#7. Za vsako ekipo iz leta 1950 izpišite število prog, na katerih je ta ekipa tekmovala,
#vendar njihovi vozniki niso zmagali tekme.
with ekipe_1950 as (
    select distinct c.name, r.positionOrder, c.constructorId
    from results r join races ra on r.raceId = ra.raceId
                   join constructors c on r.constructorId = c.constructorId
    where ra.year = 1950),
     nezmage as (
         select r.constructorId, ra.circuitId
         from results r join races ra on r.raceId = ra.raceId
                        join races on r.raceId = ra.raceId
         where ra.year = 1950
         group by r.constructorId, ra.circuitId
         having min(r.positionOrder) > 1
     )
select distinct e.name, count(distinct n.circuitId)
from ekipe_1950 e left join nezmage n on n.constructorId = e.constructorId
group by e.name
order by count(n.circuitId) desc;

#8. Izpišite ekipe, katerih vozniki so v eni sezoni zasedli vsako možno mesto med 1 in 12.
select distinct c.name
from constructors c join results r on c.constructorId = r.constructorId
                    join races ra on r.raceId = ra.raceId
where r.positionOrder between 1 and 12
group by c.name, ra.year
having count(distinct r.position) = 12;

#9. Izpišite kakšno je največje število postankov v boksih, s katerim je še bilo
#mogoče zmagati na tekmi. Poleg tega izpišite imena voznikov, ki jim je to uspelo
with stevilo_postankou as (
    select distinct d.forename, d.surname, r.raceId , r.driverId, count(p.stop) as st_pitstopou
    from pitstops p join drivers d on p.driverId = d.driverId
    join results r on r.raceId = p.raceId and r.driverId = p.driverId
    where r.positionOrder = 1
    group by d.forename, d.surname, r.raceId, r.driverId
),
najvecji as (
    select max(st_pitstopou) as najvec_postankou
    from stevilo_postankou
)
select p.forename, p.surname, p.st_pitstopou
from stevilo_postankou p join races r on r.raceId = p.raceId
join najvecji n on p.st_pitstopou = n.najvec_postankou;


#10.Izpišite vse danske voznike, ki so tekmovali na vseh različnih progah, prisotnih na turnirjih F1 od leta 2020 dalje.
with proge as (
    select count(distinct circuitId) as st_prog
    from races
    where races.year >= 2020
)
select d.surname, d.forename
from drivers d join results re on d.driverId = re.driverId
               join races r on re.raceId = r.raceId
where d.nationality = 'Danish' and r.year >= 2020
group by d.surname, d.forename, d.driverId
having (select st_prog from proge) = count(distinct r.circuitId);


