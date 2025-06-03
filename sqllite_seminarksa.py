import sqlite3

conn = sqlite3.connect("sqlite.db")
c = conn.cursor()

c.executescript("""

CREATE TABLE IF NOT EXISTS drivers (
  driverId INTEGER PRIMARY KEY,
  driverRef TEXT,
  number INTEGER,
  code TEXT,
  forename TEXT,
  surname TEXT,
  dob TEXT,
  nationality TEXT
);

CREATE TABLE IF NOT EXISTS driverStandings (
  driverStandingsId INTEGER PRIMARY KEY,
  raceId INTEGER,
  driverId INTEGER,
  points REAL,
  position INTEGER,
  positionText TEXT,
  wins INTEGER,
  FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);

CREATE TABLE IF NOT EXISTS races (
  raceId INTEGER PRIMARY KEY,
  year INTEGER,
  round INTEGER,
  circuitId INTEGER,
  name TEXT,
  date TEXT,
  time TEXT
);
""")
conn.commit()

c.execute("INSERT OR IGNORE INTO drivers VALUES (1,'hamilton',44,'HAM','Lewis','Hamilton','1985-01-07','British')")
c.execute("INSERT OR IGNORE INTO driverStandings VALUES (1, 1001, 1, 347.0, 1, '1', 11)")
c.execute("INSERT OR IGNORE INTO races VALUES (1001, 2021, 1, 1, 'Melbourne Grand Prix Circuit','2021-03-21','05:10:00')")
conn.commit()


c.execute("SELECT * FROM drivers;")
for i in c.fetchall():
    print(i)

c.execute("SELECT * FROM driverStandings;")
for i in c.fetchall():
    print(i)

c.execute("SELECT * FROM races;")
for i in c.fetchall():
    print(i)

conn.close()
