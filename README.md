restring
========

```
restring.pl from-string to-string [file ...]
```

`restring.pl` goes through each line of `[file ...]`, or `STDIN` if no files
are specified, and replaces all occurences of `from-string` with `to-string`.
It correctly handles string encoded via PHP serialization, as long as all
quotes (and other metacharacters) are escaped with backslashes. This makes it
useful to naively go through an SQL dump (from a system like Drupal), and
replace all instances of one string (e.g., the site's old hostname) with
another (e.g., the site's new hostname).

