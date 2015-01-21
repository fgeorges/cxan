d=../servlex/webapps/ROOT/WEB-INF/lib

java -cp $d/calabash.jar:$d/saxon9he.jar:$d/httpclient-4.2.5.jar:$d/httpcore-4.2.4.jar:$d/httpmime-4.2.5.jar:$d/commons-logging-1.1.1.jar com.xmlcalabash.drivers.Main "$@"
