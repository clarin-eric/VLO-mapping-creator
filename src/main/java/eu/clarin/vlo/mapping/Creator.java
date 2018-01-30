package eu.clarin.vlo.mapping;

import java.io.File;
import java.io.OutputStreamWriter;
import static java.lang.System.out;
import java.nio.file.Files;
import java.util.List;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;
import nl.mpi.tla.util.Saxon;
import org.slf4j.LoggerFactory;

/*
 * @author menwin
 */
public class Creator {
    
    private static final org.slf4j.Logger LOGGER = LoggerFactory.getLogger(Creator.class.getName());
    
    static final XsltExecutable TO_CSV;
    static final XsltExecutable TO_XML;
    
    static {
        XsltExecutable xsl = null;
        try {        
            xsl = Saxon.buildTransformer(Creator.class.getResource("/MappingCreator/toCSV.xsl"));
        } catch (Exception ex) {
            LOGGER.error("Couldn't setup toCSV transformer!", ex);
            System.exit(1);
        } finally {
            TO_CSV = xsl;
        }
        xsl = null;
        try {        
            xsl = Saxon.buildTransformer(Creator.class.getResource("/MappingCreator/toXML.xsl"));
        } catch (Exception ex) {
            LOGGER.error("Couldn't setup toXML transformer!", ex);
            System.exit(1);
        } finally {
            TO_XML = xsl;
        }
    }
    
    private static void help() {
        System.err.println("INF: java -jar vlo-mapping-creator.jar <OPTION>* <CSV>, where <OPTION> is one of those:");
        System.err.println("INF: -s=<SKOS> SKOS file to merge with the CSV");
    }

    public static void main(String[] args) {
        File skos = null;

        OptionParser parser = new OptionParser("s:?*");
        OptionSet options = parser.parse(args);
        if (options.has("s")) {
            skos = new File((String)options.valueOf("s"));
            if (!skos.canRead()) {
                LOGGER.error("Can't read the SKOS file["+skos+"]!");
                System.exit(1);
            }
        }
        if (options.has("?")) {
            help();
            System.exit(0);
        }
        
        List arg = options.nonOptionArguments();
        if (arg.size()!=1) {
            help();
            System.exit(1);
        }
        File csv = new File((String)arg.get(0));
        if (!csv.canRead()) {
            LOGGER.error("Can't read the CSV file["+csv+"]!");
            System.exit(1);
        }
        
        try {
            if (skos!=null) {
                XsltTransformer tf = TO_CSV.load();
                tf.setParameter(new QName("csv"), new XdmAtomicValue("file:"+csv.getAbsolutePath().toString()));
                tf.setSource(new StreamSource(skos));
                Serializer s = new Serializer();
                csv = Files.createTempFile("vlo-mapping-create-",".csv").toFile();
                s.setOutputFile(csv);
                tf.setDestination(s);
                tf.transform();
                LOGGER.debug("Created CSV["+csv+"]");
            }
            XsltTransformer tf = TO_XML.load();
            tf.setParameter(new QName("csv"), new XdmAtomicValue("file:"+csv.getAbsolutePath().toString()));
            tf.setInitialTemplate(new QName("main"));
            Serializer s = new Serializer();
            s.setOutputWriter(new OutputStreamWriter(System.out, "UTF-8"));
            tf.setDestination(s);
            tf.transform();
        } catch(Throwable t) {
            LOGGER.error("Failed to create the VLO mapping!", t);
            System.exit(1);
        }

    }
    
}
