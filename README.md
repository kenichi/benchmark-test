benchmark-test
==============

Analyze and view log files from the benchmark apps!

# View Data

To view data that has been analyzed and placed in the `public/data` folder, simply:

```
ruby app.rb
```

Then, at `http://localhost:4567/` you can view data by using the following url parameters:

```
run=<test_run>
os=[ios|android]
tag=[walking|biking]
wifi=[wifi|nowifi]
```

This corresponds to data stored in `public/data/<run>/<os>_<tag>_<wifi>/`.

Some test runs have already been added, so you can check them out right away!

# Analyze Data

There are some handy rake tasks to help analyze log data from the benchmark apps! The rake task expects the log data to be named in a particular way. All log files should be stored in a directory inside the base benchmark-test directory named descriptively as to the particular test run the log files encompass. Examples might be `test_walk_1`. The log files inside this directory should be named `<type>_<os>_<tag>_<wifi>.txt`, where:

```
type: realtime | region | sdk
os: ios | android
tag: walking | biking
wifi: wifi | nowifi
```

Once all your log files are named, run the following rake task:

```
rake parse:timeline[<run>,<os>,<tag>,<wifi>]
```

for example:

```
rake parse:timeline[test_walk_1,android,walking,wifi]
```

You should see a bunch of stats on the parsed data, and the appropriate files to view the run should be placed into `public/data/<run>/<os>_<tag>_<wifi>/`.

Then if you are running the app you can see this data at:

```
http://localhost:4567/run=<run>&os=<os>&tag=<tag>&wifi=<wifi>
```

for example:

```
http://localhost:4567/run=test_walk_1&os=android&tag=walking&wifi=wifi
```
