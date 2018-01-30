# VLO-mapping-creator
Tool to create a VLO mapping file based on a CSV and optionally a CLAVAS vocabulary.

## CSV

```CSV
"resourceclass","resourceclass","genre"
"AnnotatedTextCorpus","annotatedText;text","some"
"SongsAnthologiesLinguistic corporaCorpus","audioRecording","other"
"~Speech*","audioRecording","foo"
"Spoken Corpus","audioRecording","bar"
"OralCorpus","corpus",
OralCorpus,"audioRecording",
"AnthologiesDevotional, ""literature""","plainText",
```

- Row 1: column headers referring to facets
- Column A: source
- Column B and higher: targets, each facet should appear only once
- Source values (row 2 and higher, column A): if starting with a tilde (‘~’) the value is assumed to be a regular expression (see line 4)
- Target values (row 2 and higher, column B and higher): multiple values for one target facet are to be separated by semicolon (‘;’) (see line 2)

- Make sure all rows have an equal number of columns!
- Double quote (‘“‘) in the value can be escaped by doubling (“foo””bar”) (see line 8)
- Double quotes (‘“‘) are only mandatory if the value contains a comma (‘,’) (see line 7 and 8)

- Source values are grouped into the mapping XML (see line 6 and 7)

