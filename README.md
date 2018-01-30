# VLO-mapping-creator
Tool to create a VLO mapping file based on a CSV and optionally a CLAVAS vocabulary.

## CSV

See [CSV file](src/test/resources/resourceclass-full.csv)

|   | A                                        | B                  | C     |
| - | ---------------------------------------- | ------------------ | ----- |
| 1 | resourceclass                            | resourceclass      | genre |
| 2 | AnnotatedTextCorpus                      | annotatedText;text | some  |
| 3 | SongsAnthologiesLinguistic corporaCorpus | audioRecording     | other |
| 4 | ~Speech*                                 | audioRecording     | foo   |
| 5 | Spoken Corpus                            | audioRecording     | bar   |
| 6 | OralCorpus                               | corpus             |       |
| 7 | OralCorpus                               | audioRecording     |       |
| 8 | AnthologiesDevotional, "literature"      | plainText          |       |

- Row 1: column headers referring to facets
- Column A: source
- Column B and higher: targets, each facet should appear only once
- Source values (row 2 and higher, column A): if starting with a tilde (`~`) the value is assumed to be a regular expression (see line 4)
- Target values (row 2 and higher, column B and higher): multiple values for one target facet are to be separated by semicolon (`;`) (see line 2)
- Make sure all rows have an equal number of columns!
- Source values are grouped into the mapping XML (see line 6 and 7)

```
"resourceclass","resourceclass","genre"
"AnnotatedTextCorpus","annotatedText;text","some"
"SongsAnthologiesLinguistic corporaCorpus","audioRecording","other"
"~Speech*","audioRecording","foo"
"Spoken Corpus","audioRecording","bar"
"OralCorpus","corpus",
OralCorpus,"audioRecording",
"AnthologiesDevotional, ""literature""","plainText",
```

- Double quote (`“`) in the value can be escaped by doubling (`foo””bar`) (see line 8)
- Double quotes (`“`) are only mandatory if the value contains a comma (`,`) (see line 7 and 8)

## SKOS

The VLO Mapping Creator can merge a SKOS file with a CSV file. The process add mappings from `altLabel`s and `hiddenLabel`s to the `prefLabel`.

### Caveats

- This only works for simple cases at the moment, i.e., the curation of a single facet where the CSV file has as source (column A) the same facet as the target (column B).
- Also regexps are not yet supported.

## Template

In a mapping file the behaviour of intergrating the target value into the target facet can be tweaked, e.g., to overwrite all existing values. The default behaviour for a facet can taken from a template file.

```XML
<def>
    <target-facet name="resourceclass" removeSourceValue="true" overrideExistingValues="false"/>
</def>
``` 

## Command Line

```sh
$ java -jar vlo-mapping-creator.jar -?
INF: java -jar vlo-mapping-creator.jar <OPTION>* <CSV>, where <OPTION> is one of those:
INF: -s=<SKOS> SKOS file to merge with the CSV
INF: -t=<TMPL> Template file to merge with the Mapping XML
INF: -d        Enable debug info
```

### Examples

```sh
$ java -jar vlo-mapping-creator.jar -s src/test/resources/resourceclass.skos -t src/test/resources/default.xml src/test/resources/resourceclass.csv
```
```XML
<?xml version="1.0" encoding="UTF-8"?>
<value-mappings>
    <origin-facet name="resourceclass">
        <value-map>
            <target-facet name="resourceclass" removeSourceValue="true" overrideExistingValues="false"/>
            <target-value-set>
                <target-value facet="resourceclass">annotatedText</target-value>
                <target-value facet="resourceclass">text</target-value>
                <source-value>AnnotatedTextCorpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">audioRecording</target-value>
                <source-value>SongsAnthologiesLinguistic corporaCorpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">audioRecording</target-value>
                <source-value>SpeechCorpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">audioRecording</target-value>
                <source-value>Spoken Corpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">corpus</target-value>
                <target-value facet="resourceclass">audioRecording</target-value>
                <source-value>OralCorpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">plainText</target-value>
                <source-value>AnthologiesDevotional literature</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">tool</target-value>
                <source-value>tol</source-value>
            </target-value-set>
        </value-map>
    </origin-facet>
</value-mappings>
```

```sh
$ java -jar target/vlo-mapping-creator.jar -t src/test/resources/default.xml src/test/resources/resourceclass-full.csv
```
```XML
<?xml version="1.0" encoding="UTF-8"?>
<value-mappings>
    <origin-facet name="resourceclass">
        <value-map>
            <target-facet name="resourceclass" removeSourceValue="true" overrideExistingValues="false"/>
            <target-value-set>
                <target-value facet="resourceclass">annotatedText</target-value>
                <target-value facet="resourceclass">text</target-value>
                <target-value facet="genre">some</target-value>
                <source-value>AnnotatedTextCorpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">audioRecording</target-value>
                <target-value facet="genre">other</target-value>
                <source-value>SongsAnthologiesLinguistic corporaCorpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">audioRecording</target-value>
                <target-value facet="genre">foo</target-value>
                <source-value isRegex="true">Speech*</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">audioRecording</target-value>
                <target-value facet="genre">bar</target-value>
                <source-value>Spoken Corpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">corpus</target-value>
                <target-value facet="resourceclass">audioRecording</target-value>
                <source-value>OralCorpus</source-value>
            </target-value-set>
            <target-value-set>
                <target-value facet="resourceclass">plainText</target-value>
                <source-value>AnthologiesDevotional, "literature"</source-value>
            </target-value-set>
        </value-map>
    </origin-facet>
</value-mappings>
```

## TODO

- [X] XSL log messages are not handled correctly yet
- [ ] add tests
- [ ] it needs to be possible to provide a vocabulary specific XSLT to process the SKOS mapping in more advanced cases