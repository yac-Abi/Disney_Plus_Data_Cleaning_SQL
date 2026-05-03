# Cleaning the Disney+ Dataset with SQL

### Why this project?
When I first grabbed this dataset, it was a mess straight away when i opened it in excel. Between the encoding errors, the dates in the wrong format, and the durations that mixed "minutes" and "seasons" in the same column, I couldn't run a single clean query . 

---
This project shows how I took that raw CSV and turned it into a clean, usable SQL database.

### The real challenges I faced:

* **The "Hidden" Delimiter:** The file looked like a standard CSV, but it actually used semicolons (`;`). I had to open first the file on notebook to see that semicolons where used to separate comlumns. The standard MySQL Import Wizard couldn't handle it properly, so I had to write a custom `LOAD DATA LOCAL INFILE` script to get the data in correctly.
* **Fixing Corrupted Text:** I noticed titles and names were full of weird characters like `Ã©` or `â€™`. I spent time identifying these encoding artifacts and replacing them with the correct accents and apostrophes so the data actually looks professional.
* **The Duration Mess:** You can't calculate the average length of a movie if the column also contains "3 Seasons". I split this into two separate numerical columns: one for minutes and one for seasons. Much better for analysis.
* **Cleaning up Duplicates:** I used `ROW_NUMBER()` and `PARTITION BY` to find and remove  duplicate entries based on title, type, and year.

---

### What I actually did (The Workflow):
1. **Cleanup:** Stripped out useless spaces and turned empty strings into proper `NULL` values.
2. **Date Fixing:** Converted those messy text dates into standard SQL `YYYY-MM-DD` formats.
3. **Data Integrity:** Used `REGEXP` to make sure IDs and years actually followed a logic.
4. **Performance:** I didn't leave everything as `TEXT`. I converted columns to `INT`, `VARCHAR`, and `DATE` to make the database faster and lighter.

---

### How to use it:
* Grab the `disney_plus_titles.csv` and the `.sql` script.
* **Quick Note:** You'll need to change the file path in the `LOAD DATA` command to match where you saved the CSV on your computer.
* Make sure `local_infile` is turned on in your MySQL settings.
* Also, to have a general view of the data, u can open it on excel first and clic on one colonne and go to data tab then
  clic on convert text to column, choose delimited by comas and clic on finish.

---
For the full strategic analysis (Audience insights, Top actors,...), please refer to the Disney_plus_EDA_analysis.sql file in this repository.

### Tech Stack:
`MySQL` ; `Data Cleaning` ; `ETL` ; `Problem Solving`
