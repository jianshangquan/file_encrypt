### Command

<code>-a</code> for Algorithm name default use <code>PASSWORD-BINARY-REVERSE</code>
<code>-i</code> for input file path or a directory
<code>-o</code> for output directory 
<code>-p</code> for password
<code>-d</code> decrypt mode (is optional)



```cmd
bin/file-encrypt.exe -i <input file path> -o <output path> -p <password> -a <algorithm name> -d
```


#### Sample command

```cmd
./bin/file-encrypt.exe -i ../test-file/video.mp4 -o ../test-file/output -p password
./bin/file-encrypt.exe -i ../test-file/output/video.encrypted -o ../test-file/output -p password


dart ./bin/dart_file_encrypt.dart -i ../test-file -o ../test-file/output -p password
dart ./bin/dart_file_encrypt.dart -i ../test-file/output -o ../test-file/ -p password -d

```