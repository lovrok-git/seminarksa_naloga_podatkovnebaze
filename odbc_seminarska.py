import sys
import pyodbc
import matplotlib.pyplot as plt
#venv\Scripts\activate!!!!
conn = pyodbc.connect("DSN=pb_ergastf1")
cursor = conn.cursor()

a = sys.argv[1];

cursor.execute("""SELECT
    r.circuitId,
    c.name AS ime_proge,
    CAST(r.date AS CHAR) as datum,
    min(lt.milliseconds)  / 1000 as najhitrejsi_krog,
    avg(lt.milliseconds) / 1000 AS povprecni_krog
FROM races r
         JOIN circuits c ON r.circuitId = c.circuitId
         JOIN results e ON r.raceId = e.raceId
         JOIN laptimes lt ON lt.raceId = r.raceId
where c.name = ?
GROUP BY r.raceId
order by r.date desc ;""", a)
x_os = []
y_os_hitr = []
y_os = []
print("id             ime proge          datum     najhitresji   povrecni")
for id_proge,ime,datum,najhitejsi_krog,popvrecni_krog in cursor.fetchall():
    print(id_proge,ime,datum,najhitejsi_krog,popvrecni_krog)
    letnik = datum.split('-')
    x_os.append(int(letnik[0]))
    y_os.append(popvrecni_krog)
    y_os_hitr.append(najhitejsi_krog)

cursor.close()
conn.close()
plt.plot(x_os, y_os_hitr, color='blue', linewidth=2,
         marker='o', markersize=4, label='Najboljši čas kroga (s)')
plt.plot(x_os, y_os, color='orange', linewidth=2,
         marker='s', markersize=4, label='Povprečen čas kroga (s)')

plt.ylim(min(y_os_hitr) - 5, max(y_os) + 5)
plt.xlim(min(x_os) - 1, max(x_os) + 1)
plt.grid(True)


plt.xlabel('Datum tekme')
plt.ylabel('Čas (s)')
plt.title('Časi za ' + a)

plt.xlabel('Datum tekme')
plt.ylabel('Cas (s)')

plt.title('Casi za ' + a)
plt.legend(loc='best')
plt.show()
