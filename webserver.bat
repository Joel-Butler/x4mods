rem launches webserver from argument directory - assumes this is the cats folder with scriptproperties.html
cd %1
start python -m http.server 8001
start http://localhost:8001/scriptproperties.html