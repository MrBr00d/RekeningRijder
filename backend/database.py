import sqlite3
import pathlib

def check_and_makedb() -> [sqlite3.Connection, sqlite3.Cursor]:
    if pathlib.Path("data/data.db").is_file():
        con = sqlite3.connect("data/data.db")
        cur = con.cursor()
        return con, cur
    else:
        con = sqlite3.connect("data/data.db")
        cur = con.cursor()
        cur.execute("CREATE TABLE transacties(km, liters)")
        return con, cur

def insert_data(con:sqlite3.connect, cur:sqlite3.Cursor, km:float, liters:float):
    data = (liters,km)
    cur.execute("INSERT INTO transacties VALUES(?, ?)", data)
    con.commit()

def get_averages(con:sqlite3.connect, cur:sqlite3.Cursor) -> tuple[float,float]:
    res = cur.execute("SELECT AVG(km), AVG(liters) FROM transacties")
    avg_km, avg_liters = res.fetchone()
    return avg_km, avg_liters


def get_prijs():
  data = requests.get("https://opendata.cbs.nl/ODataApi/odata/80416ned/TypedDataSet").json()
  df = pd.DataFrame(data["value"])
  prijs = df.iloc[-1,2]

  current_dir = pathlib.Path.cwd()
  root = tk.Tk()
  root.tk.call('tk', 'scaling', 1.0)
  root.withdraw()
  pad = filedialog.askopenfilename(initialdir=current_dir, filetypes=[("Excel files", ".xlsx .xls")], title="Selecteer excel bestand met de ritten")
  root.destroy()
  verbruik = gem_verbruik()
  ritten = get_ritten(pad)

  res = verbruik*ritten*prijs
  res = round(res, 2)

  return res