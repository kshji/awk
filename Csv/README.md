# CSV parsing using Awk #
Here is some solution to parse csv dynamically and use column names as variable.


Using example:
```sh
awk -v deli=";" -v debug=0 -f csvparser.awk input.csv
# result
B:;Label1;1;1-and-Label1
B:;Label2;2;2-and-Label2

```

