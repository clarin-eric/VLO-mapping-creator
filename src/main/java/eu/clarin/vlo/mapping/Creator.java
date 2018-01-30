package eu.clarin.vlo.mapping;

import ch.qos.logback.classic.Level;
import java.io.File;
import java.io.OutputStreamWriter;
import java.nio.file.Files;
import java.util.List;
import javax.xml.transform.stream.StreamSource;
import joptsimple.OptionParser;
import joptsimple.OptionSet;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;
import nl.mpi.tla.util.Saxon;
import nl.mpi.tla.util.saxon.Listener;
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
        System.err.println("INF: -t=<TMPL> Template file to merge with the Mapping XML");
        System.err.println("INF: -d        Enable debug info");
    }

    public static void main(String[] args) {
        Boolean debug = false;
        File skos = null;
        File tmpl = null;
        File tmp = null;

        OptionParser parser = new OptionParser("ds:t:?*");
        OptionSet options = parser.parse(args);

        debug = options.has("d");
        
        if (debug) {
            ch.qos.logback.classic.Logger logger = (ch.qos.logback.classic.Logger) org.slf4j.LoggerFactory.getLogger("eu.clarin.vlo.mapping");
            logger.setLevel(Level.DEBUG);
        }
        
        if (options.has("s")) {
            skos = new File((String)options.valueOf("s"));
            if (!skos.canRead()) {
                LOGGER.error("Can't read the SKOS file["+skos+"]!");
                System.exit(1);
            }
        }

        if (options.has("t")) {
            tmpl = new File((String)options.valueOf("t"));
            if (!tmpl.canRead()) {
                LOGGER.error("Can't read the template file["+tmpl+"]!");
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
            Listener l = new Listener(LOGGER,"VLO-mapping-creator");

            if (skos!=null) {
                XsltTransformer tf = TO_CSV.load();
                tf.setMessageListener(l);
                tf.setErrorListener(l);
                tf.setParameter(new QName("csv"), new XdmAtomicValue("file:"+csv.getAbsolutePath().toString()));
                tf.setSource(new StreamSource(skos));
                Serializer s = new Serializer();
                tmp = Files.createTempFile("vlo-mapping-create-",".csv").toFile();
                csv = tmp;
                s.setOutputFile(csv);
                tf.setDestination(s);
                tf.transform();
                LOGGER.debug("Created CSV["+csv+"]");
            }
            XsltTransformer tf = TO_XML.load();
            tf.setMessageListener(l);
            tf.setErrorListener(l);
            tf.setParameter(new QName("csv"), new XdmAtomicValue("file:"+csv.getAbsolutePath().toString()));
            if (tmpl!=null)
                tf.setParameter(new QName("defaults"), Saxon.buildDocument(new StreamSource(tmpl)));
            tf.setInitialTemplate(new QName("main"));
            Serializer s = new Serializer();
            s.setOutputWriter(new OutputStreamWriter(System.out, "UTF-8"));
            tf.setDestination(s);
            tf.transform();
            
            if (!debug && tmp!=null) {
                tmp.delete();
                LOGGER.debug("Removed CSV["+csv+"]");
            }
            
        } catch(Throwable t) {
            LOGGER.error("Failed to create the VLO mapping!", t);
            System.exit(1);
        }

    }
    
}
